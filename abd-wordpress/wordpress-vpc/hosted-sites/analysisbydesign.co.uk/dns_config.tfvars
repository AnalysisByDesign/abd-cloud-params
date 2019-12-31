# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "dns"

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

# Need to ensure this is false, as we might have inherited another value
delegation_enabled = false

ssl_cert_enabled = true

# Our new target website domain
public_apex_domain = "analysisbydesign.co.uk"

subject_alternative_names = ["www.analysisbydesign.co.uk"]

public_sub_domain = ""

delegate_set_name = "analysisbydesign"

# The Wordpress subdomain equivalent
wp_apex_domain = "abd-wp.uk"

wp_sub_domain = "analysisbydesigncouk"

# The main Wordpress load balancer
wp_lb_name = "ec2-asg"

# Email records
mx_records = [
  "10 mx00.ionos.co.uk",
  "20 mx01.ionos.co.uk",
]

# Extra DNS Records
dns_extra = [
  {
    type = "TXT"
    name = ""
    ttl  = "86400"

    value = "atlassian-domain-verification=DNrS9qBTZd125yihU1EFjH9dNzRXGuW6eWl9dVMa-OY9o3+wvD/SJSY+GoIJWV6+###google-site-verification=dUfZO0WMMfTm60pmvziDQvA2JPFya8X1B2q1JzSW1Cs"
  },
  {
    type  = "CNAME"
    name  = "1a690a73cdaa4a9b68c5b261695e464f"
    ttl   = "86400"
    value = "verify.bing.com"
  },
]
