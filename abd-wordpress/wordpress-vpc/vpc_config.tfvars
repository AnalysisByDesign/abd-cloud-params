# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "vpc"

common_tag_environment = "wordpress"

common_tag_subsystem = "wordpress"

r53_name = "wordpress"

# --------------------------------------------------------------------------------------------
# VPC configuration parameters
# --------------------------------------------------------------------------------------------

vpc_name = "abd-wordpress"

# An x.x/21 = 2048 IPs
# 10.240.0.0   - 10.240.7.255
vpc_cidr = "10.240.0.0/21"

# --------------------------------------------------------------------------------------------
# Subnets and Availability Zones
# --------------------------------------------------------------------------------------------

# Public spare 10.240.0.192/26
public_subnets = ["10.240.0.0/26", "10.240.0.64/26", "10.240.0.128/26"]

# Web spare 10.240.2.128/25
private_web_subnets = ["10.240.1.0/25", "10.240.1.128/25", "10.240.2.0/25"]

# App spare 10.240.6.0/24
private_app_subnets = ["10.240.3.0/24", "10.240.4.0/24", "10.240.5.0/24"]

# Cache spare 10.240.7.96/27
private_cache_subnets = ["10.240.7.0/27", "10.240.7.32/27", "10.240.7.64/27"]

# DB spare 10.240.7.224/27
private_db_subnets = ["10.240.7.128/27", "10.240.7.160/27", "10.240.7.192/27"]

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

delegation_enabled = true

delegate_set_name = "abd-wordpress"

public_sub_domain = "wp"

# --------------------------------------------------------------------------------------------
# S3 VPC Endpoints
# --------------------------------------------------------------------------------------------

vpc_endpoint_s3_enable = true

s3_name = "abd-wordpress"
