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

common_tag_subsystem = "global"

common_tag_environment = "global"

# --------------------------------------------------------------------------------------------
# Account specific configuration
# --------------------------------------------------------------------------------------------

# Account specific CIDR ranges
account_cidr = "10.0.0.0/12"

# Does this account need to be monitored by NewRelic
newrelic_required = false

# --------------------------------------------------------------------------------------------
# Account Level Direct-Connect Configuration Options
# --------------------------------------------------------------------------------------------

connect_to_mpls = false

# --------------------------------------------------------------------------------------------
# Route53 Configuration Options
# --------------------------------------------------------------------------------------------

public_apex_domain = "analysisbydesign.co.uk"

delegate_set_name = "global-abd"

public_sub_domain = "global-abd"

delegation_enabled = true

mx_records = [
  "10 mx00.ionos.co.uk",
  "20 mx01.ionos.co.uk",
]

# --------------------------------------------------------------------------------------------
# Docker Repository
# --------------------------------------------------------------------------------------------

docker_repository_required = true

# --------------------------------------------------------------------------------------------
# GitHub Actions OIDC
# Set github_org to create the OIDC provider and role in this (management) account.
# Run this account template manually first to bootstrap the role, then use GitHub Actions.
# --------------------------------------------------------------------------------------------

github_org               = "AnalysisByDesign"
github_actions_role_name = "github-actions-terraform"
github_repos             = ["abd-cloud"]
