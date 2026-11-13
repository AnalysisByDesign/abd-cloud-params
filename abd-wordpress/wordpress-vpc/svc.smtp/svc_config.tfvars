# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------

common_tag_component = "ecs"

# --------------------------------------------------------------------------------------------
# smtp (WP-04 rulings 14 to 16): a postfix relay for anything without its own SMTP settings
# (the system, cron, any app pointed at a local relay), at smtp.abd-wordpress.internal:25.
# It relays to IONOS with the login in /abd-wordpress/shared/postfix/sasl_passwd, one
# postfix map line ("[host]:port user:password"). WordPress sites keep sending to IONOS
# directly through WP Mail SMTP. The image is abd/postfix from abd-cloud-containers; CI pins
# it by digest on each rollout (ruling 6).
#
# awsvpc, so the task has its own address for the Cloud Map A record. A t4g.small host has
# 3 network interfaces, so it runs at most 2 awsvpc tasks (ENI trunking is not available).
# --------------------------------------------------------------------------------------------

name         = "smtp"
cluster_name = "abd-wordpress-cluster"
network_mode = "awsvpc"

containers = [
  {
    name               = "postfix"
    image              = "800653036500.dkr.ecr.eu-west-1.amazonaws.com/abd/postfix:trixie"
    port               = 25
    memory_reservation = 32
    memory             = 128
    stop_timeout       = 30

    environment = {
      MYHOSTNAME = "smtp.abd-wordpress.internal"
      # The private app subnets, where the ECS hosts and awsvpc tasks run
      MYNETWORKS = "10.240.3.0/24 10.240.4.0/24 10.240.5.0/24"
      # Every From: header becomes "abd-cloud" <MAIL_FROM>; the envelope sender is the
      # IONOS login from SASL_PASSWD (WP-04 ruling 21). Required by the image.
      MAIL_FROM = "abd-cloud@analysisbydesign.co.uk"
    }

    secrets = {
      SASL_PASSWD = "/abd-wordpress/shared/postfix/sasl_passwd"
    }

    health_check = {
      command      = ["CMD-SHELL", "postfix status"]
      start_period = 15
    }
  },
]

# --------------------------------------------------------------------------------------------
# Network: inbound SMTP from the private app subnets only, found by name in Cloud Map
# --------------------------------------------------------------------------------------------

awsvpc_ingress_ports        = [25]
awsvpc_ingress_cidr_blocks  = ["10.240.3.0/24", "10.240.4.0/24", "10.240.5.0/24"]
service_discovery_namespace = "abd-wordpress.internal"
