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
# On boot it disables source/dest checking, starts fck-nat, then repoints the private
# route tables' 0.0.0.0/0 at itself (route flip) before completing its lifecycle hook.
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

# Accept all traffic from the VPC for forwarding
asg_ingress_cidr_blocks = ["10.240.0.0/21"]

# --------------------------------------------------------------------------------------------
# Lifecycle hooks
#  - nat-route-flip: the instance completes this itself (CONTINUE) only after the route flip.
#    Any failure before the flip abandons the instance and leaves the routes untouched.
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
extra_template_vars = {
  account_id              = "800653036500"
  region                  = "eu-west-1"
  asg_name                = "abd-wordpress-nat"
  lifecycle_hook_name     = "nat-route-flip"
  route_table_name_prefix = "abd-wordpress-private-"
}

# --------------------------------------------------------------------------------------------
# Alarms to the abd-alerts topic (alerts_topic_name is set in the account tfvars)
# --------------------------------------------------------------------------------------------

enable_alarms = true
