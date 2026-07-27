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
public_apex_domain = "amyegillin.uk"

subject_alternative_names = ["www.amyegillin.uk"]

public_sub_domain = ""

delegate_set_name = "amyegillin"

# The Wordpress subdomain equivalent
wp_apex_domain = "abd-wp.uk"
wp_sub_domain  = "amyegillinuk"

# The main Wordpress load balancer
trg_lb_name = "ec2-asg"

# Email records
mx_records = [
  "10 mx00.1and1.co.uk",
  "20 mx01.1and1.co.uk",
]
