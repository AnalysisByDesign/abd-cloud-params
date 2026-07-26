# --------------------------------------------------------------------------------------------
# Global tag definitions
# --------------------------------------------------------------------------------------------

common_tag_component   = "dns"
common_tag_environment = "dev"

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

# Create dev.tulox.uk and delegate it from the existing tulox.uk public zone.
delegation_enabled = true

# This zone serves development records and does not require a cert or wildcard alias.
ssl_cert_enabled     = false
wildcard_dns_enabled = false

public_apex_domain = "tulox.uk"
public_sub_domain  = "dev"

delegate_set_name = "devtuloxuk"

# Required by the wp-dns template.
wp_apex_domain = "abd-wp.uk"
wp_sub_domain  = "devtuloxuk"
wp_lb_name     = "ec2-asg"
