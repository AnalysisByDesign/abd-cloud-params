# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------

common_tag_component = "ecs"

# --------------------------------------------------------------------------------------------
# hello (WP-04): a trivial nginx service proving the ECS service pattern on a test hostname.
# The image comes through the ECR Public pull-through cache (WP-02); CI pins it by digest
# on each rollout (ruling 6), and a bad tag is the circuit breaker test.
# --------------------------------------------------------------------------------------------

name         = "hello"
cluster_name = "abd-wordpress-cluster"

containers = [
  {
    name               = "web"
    image              = "800653036500.dkr.ecr.eu-west-1.amazonaws.com/ecr-public/docker/library/nginx:stable-alpine"
    port               = 80
    memory_reservation = 32
    memory             = 128

    # Proves the EFS access point pattern: the task does not start if the mount fails
    mount_points = [
      { source_volume = "efs-test", container_path = "/usr/share/nginx/html/efs", read_only = true },
    ]
  },
]

efs_access_points = {
  "efs-test" = { path = "/ecs/hello", read_only = true }
}

# --------------------------------------------------------------------------------------------
# Routing: hello.abd-wp.uk on the existing ALB (covered by its *.abd-wp.uk certificate)
# --------------------------------------------------------------------------------------------

hostnames              = ["hello.abd-wp.uk"]
listener_rule_priority = 900
dns_zone_name          = "abd-wp.uk"
health_check_path      = "/"

enable_alarms = true
