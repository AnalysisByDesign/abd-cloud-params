# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "nat"

# --------------------------------------------------------------------------------------------
# NAT instance (WP-01): replaces the NAT gateway with a self-healing fck-nat instance.
# On boot (in Pending:Wait) it disables source/dest checking, starts fck-nat, then repoints
# the managed route tables' 0.0.0.0/0 at itself (route flip) before completing its
# lifecycle hook. A failed flip is rolled back to the previous targets.
# --------------------------------------------------------------------------------------------

name = "nat"

asg_ec2_instance_type = "t4g.nano"

# A single NAT instance; max of 2 leaves room for launch-before-terminate refreshes
asg_min_size         = 1
asg_desired_capacity = 1
asg_max_size         = 2

asg_enable_instance_refresh                 = true
asg_instance_refresh_min_healthy_percentage = 100
asg_instance_refresh_max_healthy_percentage = 110
asg_instance_refresh_instance_warmup        = 60

# fck-nat publishes public AMIs; arm64 suits the t4g family
asg_ami_image_glob  = "fck-nat-al2023-*-arm64-ebs"
asg_ami_image_owner = "568608671756"

asg_iam_profile_name = "nat"
asg_ssh_key_name     = "nat"

user_data_script    = "nat-route-flip.sh"
ec2_policy_template = "nat-instance-policy.tpl.json"

# --------------------------------------------------------------------------------------------
# No load balancer; public subnets with an auto-assigned (floating) public IP
# --------------------------------------------------------------------------------------------

enable_load_balancer  = false
asg_subnet_tier       = "public"
asg_require_public_ip = true

# --------------------------------------------------------------------------------------------
# Egress routing: the private route tables of these AZs are flipped to this instance.
# One ASG serves every AZ today, and can launch in any AZ for resilience.
# To scale out, copy this target per AZ (e.g. nat-a with name = "nat-a"), give each a
# single AZ here and the same AZ in asg_availability_zones, and never list an AZ in two
# targets, or their instances will take the routes from each other on every launch.
# --------------------------------------------------------------------------------------------

managed_route_table_azs = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
# asg_availability_zones = ["eu-west-1a"]

# Accept all traffic from the VPC for forwarding
asg_ingress_cidr_blocks = ["10.240.0.0/21"]

# --------------------------------------------------------------------------------------------
# Lifecycle hooks
#  - nat-route-flip: the instance completes this itself (CONTINUE) only after the route flip.
#    Any failure abandons the instance, restoring the previous route targets first.
#  - nat-drain: nothing completes this, so a terminating instance stays up for 2 minutes
#    to let in-flight connections drain, then terminates.
# --------------------------------------------------------------------------------------------

asg_initial_lifecycle_hooks = [
  {
    name                 = "nat-route-flip"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result       = "ABANDON"
    heartbeat_timeout    = 300
  },
  {
    name                 = "nat-drain"
    lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 120
  },
]

# Values for the user data and IAM policy templates
# (asg_name, route_table_ids and route_table_arns are supplied by the template)
extra_template_vars = {
  account_id          = "800653036500"
  region              = "eu-west-1"
  lifecycle_hook_name = "nat-route-flip"
}

# --------------------------------------------------------------------------------------------
# Alarms to the abd-alerts topic (alerts_topic_name is set in the account tfvars)
# --------------------------------------------------------------------------------------------

enable_alarms = true
