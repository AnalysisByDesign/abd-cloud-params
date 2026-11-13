# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------

common_tag_component = "ecs"

# --------------------------------------------------------------------------------------------
# ECS hosts (WP-04): ASG abd-wordpress-ecs-hosts, joined to abd-wordpress-cluster
# --------------------------------------------------------------------------------------------

name             = "ecs-hosts"
ecs_cluster_name = "abd-wordpress-cluster"

# t4g.small (ruling 4)
asg_ec2_instance_type = "t4g.small"

# Two hosts at all times, which the two regional t4g RIs already pay for (ruling 21).
# ECS managed scaling owns the desired capacity above that; max leaves room for an
# instance refresh or a short scale-out to a third host
asg_min_size = 2
asg_max_size = 3

# ECS-optimised AL2023 arm64, resolved at each launch, so every refresh takes the latest
# (ruling 3)
asg_ami_ssm_parameter = "/aws/service/ecs/optimized-ami/amazon-linux-2023/arm64/recommended/image_id"

# IMDSv2 only, and a hop limit of 1 so bridge-mode containers cannot reach the host role
asg_metadata_http_tokens                 = "required"
asg_metadata_http_put_response_hop_limit = 1

# Launch before terminate (100/110); managed draining moves tasks off the old host
asg_enable_instance_refresh                 = true
asg_instance_refresh_min_healthy_percentage = 100
asg_instance_refresh_max_healthy_percentage = 110
asg_instance_refresh_instance_warmup        = 120

# Weekly drill: Wednesdays at 03:00 (ruling 13)
asg_scheduled_refresh_expression = "cron(0 3 ? * WED *)"

asg_iam_profile_name = "ecs-hosts"
asg_ssh_key_name     = "ecs-hosts"
user_data_script     = "ecs-host.sh"

# The ECS instance policy is attached by ecs_cluster_name; no extra policy needed
ec2_policy_template = ""

# --------------------------------------------------------------------------------------------
# Networking: private app subnets, no load balancer of its own
# --------------------------------------------------------------------------------------------

enable_load_balancer = false

# The existing ALB reaches tasks on their dynamic host ports
asg_ingress_security_groups = [
  {
    security_group_name = "ec2-asg-alb"
    from_port           = 32768
    to_port             = 65535
    description         = "ALB to ECS dynamic host ports"
  },
]

# Bridge-mode tasks use the host's security group to reach RDS and EFS
rds_security_group = "mysql"
efs_security_group = "html-efs"

# No InService host, failed status checks
enable_alarms = true
