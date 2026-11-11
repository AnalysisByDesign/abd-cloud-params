#!/bin/bash
# --------------------------------------------------------------------------------
# NAT instance boot script (WP-01), rendered by Terraform templatefile.
# Terraform values are written as $${...}; shell variables are written as $var
# (no braces) so that templatefile leaves them alone.
#
# 1. Disable source/destination checking on this instance (needed to forward)
# 2. (Re)start fck-nat on the primary interface and confirm forwarding is on
# 3. Confirm this instance has its own internet egress
# 4. Repoint each private route table's 0.0.0.0/0 at this instance (route flip)
# 5. Complete the launch lifecycle hook, which marks the instance healthy
#
# Any failure before step 4 abandons the instance, leaving the routes untouched.
# --------------------------------------------------------------------------------
set -euo pipefail
exec > >(tee -a /var/log/nat-route-flip.log) 2>&1

HOOK_NAME="${lifecycle_hook_name}"
ASG_NAME="${asg_name}"
RT_NAME_PREFIX="${route_table_name_prefix}"

imds() {
  token=$(curl -sf -X PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
  curl -sf -H "X-aws-ec2-metadata-token: $token" "http://169.254.169.254/latest/meta-data/$1"
}

INSTANCE_ID=$(imds instance-id)
REGION=$(imds placement/region)
MAC=$(imds mac)
VPC_ID=$(imds "network/interfaces/macs/$MAC/vpc-id")
export AWS_DEFAULT_REGION=$REGION

complete_hook() {
  aws autoscaling complete-lifecycle-action \
    --lifecycle-hook-name "$HOOK_NAME" \
    --auto-scaling-group-name "$ASG_NAME" \
    --instance-id "$INSTANCE_ID" \
    --lifecycle-action-result "$1" || true
}
trap 'echo "$(date -Is) route flip failed, abandoning instance"; complete_hook ABANDON' ERR

echo "$(date -Is) starting NAT setup on $INSTANCE_ID in $VPC_ID"

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
echo "$(date -Is) public IP $(curl -sf --max-time 10 https://checkip.amazonaws.com)"

# 4. Route flip
ROUTE_TABLES=$(aws ec2 describe-route-tables \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag:Name,Values=$RT_NAME_PREFIX*" \
  --query 'RouteTables[].RouteTableId' --output text)
[ -n "$ROUTE_TABLES" ]

for rt in $ROUTE_TABLES; do
  echo "$(date -Is) pointing 0.0.0.0/0 in $rt at $INSTANCE_ID"
  aws ec2 replace-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0 --instance-id "$INSTANCE_ID" ||
    aws ec2 create-route --route-table-id "$rt" --destination-cidr-block 0.0.0.0/0 --instance-id "$INSTANCE_ID"
done

# 5. Healthy
trap - ERR
complete_hook CONTINUE
echo "$(date -Is) NAT setup complete"
