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

# The main load balancer
enable_wordpress = false
# trg_lb_name      = "ec2-asg"

wildcard_dns_enabled = false
enable_www_redirect  = false

delegate_set_name = "devtuloxuk"

dns_extra = [
  {
    type  = "A"
    name  = ""
    ttl   = "86400"
    value = "192.168.0.123"
  },
  {
    type  = "A"
    name  = "*"
    ttl   = "86400"
    value = "192.168.0.123"
  },
]
