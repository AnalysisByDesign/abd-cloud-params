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

# False until nameservers have been delegated at the registrar and DNS validation can succeed
ssl_cert_enabled = false

# Our new target website domain
public_apex_domain = "tulox.co.uk"

subject_alternative_names = ["www.tulox.co.uk"]

public_sub_domain = ""

delegate_set_name = "tuloxcouk"

# The Wordpress subdomain equivalent
wp_apex_domain = "abd-wp.uk"

wp_sub_domain = "tuloxcouk"

# The main Wordpress load balancer
wp_lb_name = "ec2-asg"
