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
public_apex_domain = "abd.training"

subject_alternative_names = ["www.abd.training"]

public_sub_domain = ""

delegate_set_name = "abdtraining"

# The Wordpress subdomain equivalent
wp_apex_domain = "abd-wp.uk"

wp_sub_domain = "abdtraining"

# The main Wordpress load balancer
wp_lb_name = "ec2-asg"

# Email records
mx_records = [
  "10 mx00.1and1.co.uk",
  "20 mx01.1and1.co.uk",
]

# Extra DNS Records
dns_extra = [
  {
    type  = "CNAME"
    name  = "123456"
    ttl   = "86400"
    value = "verify.bing.com"
  },
  {
    type  = "TXT"
    name  = ""
    ttl   = "86400"
    value = "google-site-verification=123456"
  },
]
