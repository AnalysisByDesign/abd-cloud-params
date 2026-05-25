# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_owner = "abd"

common_tag_project = "abd"

common_tag_subsystem = "wordpress"

common_tag_environment = "wordpress"

# --------------------------------------------------------------------------------------------
# Account specific configuration
# --------------------------------------------------------------------------------------------

# Account specific CIDR ranges
account_cidr = "10.240.0.0/12"

# Does this account need to be monitored by NewRelic
newrelic_required = false

# --------------------------------------------------------------------------------------------
# Account Level Direct-Connect Configuration Options
# --------------------------------------------------------------------------------------------

connect_to_mpls = false

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

public_apex_domain = "abd-wp.uk"

delegate_set_name = "abd-wordpress"

public_sub_domain = ""

delegation_enabled = false

mx_records = [
  "10 mx00.ionos.co.uk",
  "20 mx01.ionos.co.uk",
]

# --------------------------------------------------------------------------------------------
# Docker Repository
# --------------------------------------------------------------------------------------------

docker_repository_required = true

docker_repository_name = "abd-wordpress"

# --------------------------------------------------------------------------------------------
# GitHub Actions OIDC
# Leave github_org empty in this account — the OIDC role lives only in abd-global.
# GitHub Actions assumes the management account role which then chains to this account's
# existing terraform role via the Terraform AWS provider assume_role configuration.
# --------------------------------------------------------------------------------------------

github_org = ""
