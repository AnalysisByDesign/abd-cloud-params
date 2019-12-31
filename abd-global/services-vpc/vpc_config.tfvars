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

common_tag_environment = "services"

r53_name = "services"

# --------------------------------------------------------------------------------------------
# VPC configuration parameters
# --------------------------------------------------------------------------------------------

vpc_name = "services"

# An x.x/21 = 2048 IPs
# 10.0.0.0   - 10.0.7.255
vpc_cidr = "10.0.0.0/21"

enable_nat_gateway = false

# --------------------------------------------------------------------------------------------
# Subnets and Availability Zones
# --------------------------------------------------------------------------------------------

# Public spare 10.0.0.192/26
public_subnets = ["10.0.0.0/26", "10.0.0.64/26", "10.0.0.128/26"]

# Web spare 10.0.2.128/25
private_web_subnets = ["10.0.1.0/25", "10.0.1.128/25", "10.0.2.0/25"]

# App spare 10.0.6.0/24
private_app_subnets = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]

# Cache spare 10.0.7.96/27
private_cache_subnets = ["10.0.7.0/27", "10.0.7.32/27", "10.0.7.64/27"]

# DB spare 10.0.7.224/27
private_db_subnets = ["10.0.7.128/27", "10.0.7.160/27", "10.0.7.192/27"]

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

delegation_enabled = true

delegate_set_name = "services-abd"

public_sub_domain = "services"

# --------------------------------------------------------------------------------------------
# S3 VPC Endpoints
# --------------------------------------------------------------------------------------------

vpc_endpoint_s3_enable = true

s3_name = "services-abd"
