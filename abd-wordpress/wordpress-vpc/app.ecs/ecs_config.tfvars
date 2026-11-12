# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "ecs"

# --------------------------------------------------------------------------------------------
# ECS cluster (WP-04): abd-wordpress-cluster
# --------------------------------------------------------------------------------------------

name = "cluster"

# Container Insights off for now (WP-04 ruling 11); enabled or enhanced to switch on
ecs_insights = "disabled"

# Capacity providers, keyed by host ASG name without the VPC prefix. Each one is created on
# the first apply after its ASG exists, so apply this target, then ecs.hosts, then this
# target again (WP-04 ruling 1). The on-demand base of 1 always runs on these hosts.
capacity_providers = {
  "ecs-hosts" = {
    base   = 1
    weight = 1
  }
}

# Cloud Map namespace for awsvpc services, e.g. smtp.abd-wordpress.internal (WP-04 ruling 16)
service_discovery_namespace = "abd-wordpress.internal"

# Deployment failures, placement failures and failed tasks to abd-alerts (WP-04 ruling 11)
enable_alerts = true
