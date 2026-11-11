# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "github-deploy"

# --------------------------------------------------------------------------------------------
# GitHub Actions deploy roles - one per application repository
# --------------------------------------------------------------------------------------------

deploy_roles = {
  property-calculator = {
    github_repo = "AnalysisByDesign/property-calculator"
    role_name   = "github-deploy-property-calculator"
  }
  tulox = {
    github_repo = "AnalysisByDesign/tulox"
    role_name   = "github-deploy-tulox"
  }
}

instance_tag_key   = "SubSystem"
instance_tag_value = "wordpress"

# --------------------------------------------------------------------------------------------
# GitHub Actions ECR push roles - one per image-building repository (WP-02)
# Each may push only to its own namespaces (repository/<prefix>/*), from main only.
# --------------------------------------------------------------------------------------------

ecr_push_roles = {
  abd-cloud-containers = {
    github_repo         = "AnalysisByDesign/abd-cloud-containers"
    role_name           = "github-ecr-push-abd-cloud-containers"
    repository_prefixes = ["abd"]
  }
}
