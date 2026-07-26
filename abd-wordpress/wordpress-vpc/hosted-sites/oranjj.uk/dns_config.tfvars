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
public_apex_domain = "oranjj.uk"

subject_alternative_names = ["www.oranjj.uk"]

public_sub_domain = ""

delegate_set_name = "oranjj"

# The Wordpress subdomain equivalent
wp_apex_domain = "abd-wp.uk"
wp_sub_domain  = "oranjjuk"

# The main Wordpress load balancer
trg_lb_name = "ec2-asg"

# Email records
mx_records = [
  "10 mx00.ionos.co.uk",
  "20 mx01.ionos.co.uk",
]

# Extra DNS Records
dns_extra = [
  {
    type  = "TXT"
    name  = ""
    ttl   = "86400"
    value = "google-site-verification=wX1uDOdVCLuPBz_5PLVr0mDdceb0YYO5Nm4xRqb-MCw###v=spf1 include:_spf-eu.ionos.com include:_spf.google.com ~all"
  },
  {
    type  = "CNAME"
    name  = "7c0f00ccee8f7934f996386e6c47b04d"
    ttl   = "86400"
    value = "verify.bing.com"
  },
  {
    type  = "CNAME"
    name  = "sumomail"
    ttl   = "86400"
    value = "whitelabel-5.sumomail.com"
  },
  {
    type  = "CNAME"
    name  = "s1._domainkey"
    ttl   = "86400"
    value = "s1.whitelabel-5.sumomail.com"
  },
  {
    type  = "CNAME"
    name  = "s2._domainkey"
    ttl   = "86400"
    value = "s2.whitelabel-5.sumomail.com"
  },
  {
    type  = "CNAME"
    name  = "k1._domainkey"
    ttl   = "86400"
    value = "dkim.mcsv.net"
  },
]
