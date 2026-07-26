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

# This zone serves development records and does not require a certificate.
ssl_cert_enabled = false

public_apex_domain = "tulox.uk"
public_sub_domain  = "dev"

wildcard_dns_enabled = true

delegate_set_name = "devtuloxuk"
