#!/bin/bash
# --------------------------------------------------------------------------------
# NAT instance boot script (WP-01), rendered by Terraform templatefile.
# Terraform values are written as $${...}; shell variables are written as $var
# (no braces) so that templatefile leaves them alone.
#
# The instance stays in Pending:Wait (launch lifecycle hook) throughout:
#  1. Disable source/destination checking on this instance (needed to forward)
#  2. (Re)start fck-nat on the primary interface and confirm forwarding is on
#  3. Confirm this instance has its own internet egress
#  4. Record the current 0.0.0.0/0 target of each managed route table
#  5. Repoint each managed route table's 0.0.0.0/0 at this instance (route flip)
#  6. Complete the launch lifecycle hook (CONTINUE): the instance goes InService,
#     and during a refresh the ASG then terminates the instance it replaces
#
# The managed route tables are resolved by Terraform from managed_route_table_azs,
# so each NAT ASG only ever touches the AZs it was given.
#
# Any failure abandons the instance. If the flip had started, the recorded targets
# are restored first, so the routes go back to whatever was serving them before.
# --------------------------------------------------------------------------------
set -euo pipefail
exec > >(tee -a /var/log/nat-route-flip.log) 2>&1

HOOK_NAME="${lifecycle_hook_name}"
ASG_NAME="${asg_name}"
ROUTE_TABLE_IDS="${route_table_ids}"
PREVIOUS=/run/nat-route-flip.previous
FLIP_STARTED=0
INSTANCE_ID=""

log() { echo "$(date -Is) $*"; }

imds() {
  token=$(curl -sf -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
  curl -sf -H "X-aws-ec2-metadata-token: $token" "http://169.254.169.254/latest/meta-data/$1"
}

complete_hook() {
  for attempt in 1 2 3 4 5; do
    aws autoscaling complete-lifecycle-action \
      --lifecycle-hook-name "$HOOK_NAME" \
      --auto-scaling-group-name "$ASG_NAME" \
      --instance-id "$INSTANCE_ID" \
      --lifecycle-action-result "$1" && return 0
    log "complete-lifecycle-action $1 failed (attempt $attempt)"
    sleep 5
  done
  return 1
}

restore_routes() {
  [ "$FLIP_STARTED" = "1" ] && [ -s "$PREVIOUS" ] || return 0
  while read -r rt kind target; do
    log "restoring 0.0.0.0/0 in $rt to $target"
    aws ec2 replace-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0 "--$kind" "$target" ||
      log "could not restore $rt (the previous target may no longer exist)"
  done < "$PREVIOUS"
}

fail() {
  trap - ERR
  log "NAT setup failed: restoring routes and abandoning this instance"
  restore_routes
  complete_hook ABANDON || log "could not abandon; the hook will time out and abandon"
  exit 1
}
trap fail ERR

INSTANCE_ID=$(imds instance-id)
REGION=$(imds placement/region)
export AWS_DEFAULT_REGION=$REGION

log "starting NAT setup on $INSTANCE_ID for route tables: $ROUTE_TABLE_IDS"
[ -n "$ROUTE_TABLE_IDS" ]

# The instance has its own public IP, so it can install the CLI if the AMI lacks it
command -v aws >/dev/null || dnf install -y awscli

# 1. Disable source/destination checking
aws ec2 modify-instance-attribute --instance-id "$INSTANCE_ID" --no-source-dest-check

# 2. fck-nat with no ENI configured uses the primary interface
: > /etc/fck-nat.conf
systemctl restart fck-nat
for _ in $(seq 1 30); do
  [ "$(sysctl -n net.ipv4.ip_forward)" = "1" ] && break
  sleep 2
done
[ "$(sysctl -n net.ipv4.ip_forward)" = "1" ]

# 3. Own egress works
log "public IP $(curl -sf --max-time 10 https://checkip.amazonaws.com)"

# 4. Record the current targets so a failed flip can be undone
: > "$PREVIOUS"
for rt in $ROUTE_TABLE_IDS; do
  current=$(aws ec2 describe-route-tables --route-table-ids "$rt" \
    --query "RouteTables[0].Routes[?DestinationCidrBlock=='0.0.0.0/0'] | [0].[NatGatewayId,NetworkInterfaceId]" \
    --output text)
  read -r nat eni <<<"$current"
  if [ -n "$nat" ] && [ "$nat" != "None" ]; then
    echo "$rt nat-gateway-id $nat" >>"$PREVIOUS"
  elif [ -n "$eni" ] && [ "$eni" != "None" ]; then
    echo "$rt network-interface-id $eni" >>"$PREVIOUS"
  fi
  log "$rt currently routes 0.0.0.0/0 to: $current"
done

# 5. Route flip
FLIP_STARTED=1
for rt in $ROUTE_TABLE_IDS; do
  log "pointing 0.0.0.0/0 in $rt at $INSTANCE_ID"
  aws ec2 replace-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0 --instance-id "$INSTANCE_ID" ||
    aws ec2 create-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0 --instance-id "$INSTANCE_ID"
done

# 6. InService
complete_hook CONTINUE || fail
trap - ERR
log "NAT setup complete"
