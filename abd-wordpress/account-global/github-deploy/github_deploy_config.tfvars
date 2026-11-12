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

    # This repository uses GitHub's immutable OIDC subject (owner and repository IDs)
    github_subject_prefix = "repo:AnalysisByDesign@4380764/abd-cloud-containers@1452488510"

    # Premium WordPress plugins and themes for the site images (WP-05 ruling 23), and
    # the abd-wordpress-html bucket's KMS key (storage/s3.wordpress)
    s3_read_prefixes     = ["abd-wordpress-html/premium/"]
    kms_decrypt_key_arns = ["arn:aws:kms:eu-west-1:800653036500:key/bb72ad25-373e-4793-bd39-792d01a448ad"]
  }
}

# --------------------------------------------------------------------------------------------
# ECS deploy roles (WP-04 ruling 7): CI registers task definition revisions and updates
# its own services
# --------------------------------------------------------------------------------------------

ecs_deploy_roles = {
  abd-cloud-containers = {
    github_repo      = "AnalysisByDesign/abd-cloud-containers"
    role_name        = "github-ecs-deploy-abd-cloud-containers"
    cluster_name     = "abd-wordpress-cluster"
    services         = ["hello", "smtp", "analysisbydesign-co-uk", "amyegillin-uk", "baltihot-co-uk", "blacklit-uk", "daverix-ai", "oranjj-uk"]
    role_name_prefix = "abd-wordpress"

    # This repository uses GitHub's immutable OIDC subject (owner and repository IDs)
    github_subject_prefix = "repo:AnalysisByDesign@4380764/abd-cloud-containers@1452488510"
  }
}
