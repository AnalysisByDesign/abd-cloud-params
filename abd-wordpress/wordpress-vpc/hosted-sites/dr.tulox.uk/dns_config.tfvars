# --------------------------------------------------------------------------------------------
# Global tag definitions
# --------------------------------------------------------------------------------------------

common_tag_component   = "dns"
common_tag_environment = "dev"

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

# Create dr.tulox.uk and delegate it from the existing tulox.uk public zone.
delegation_enabled = true

# This zone serves development records and does not require a certificate.
ssl_cert_enabled = false

public_apex_domain = "tulox.uk"
public_sub_domain  = "dr"

# The main load balancer
enable_wordpress = false
# trg_lb_name      = "ec2-asg"

wildcard_dns_enabled = false
enable_www_redirect  = false

delegate_set_name = "drtuloxuk"

# No email for this zone - override the account level MX records
mx_records = []

# The developer machine's Tailscale address.
# Both records are required, the wildcard does not cover its own parent.
dns_extra = [
  {
    type  = "A"
    name  = ""
    ttl   = "300"
    value = "100.126.16.1"
  },
  {
    type  = "A"
    name  = "*"
    ttl   = "300"
    value = "100.126.16.1"
  },
]

# --------------------------------------------------------------------------------------------
# DNS Challenge User
# --------------------------------------------------------------------------------------------

# IAM user for Caddy's ACME DNS-01 challenge, scoped to this zone only.
# The access key is created by hand after apply, it is never held in Terraform state.
dns_challenge_user_name = "tulox-caddy-dns-dr"
