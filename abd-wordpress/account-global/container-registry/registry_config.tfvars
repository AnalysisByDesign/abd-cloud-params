# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "container-registry"

# --------------------------------------------------------------------------------------------
# ECR repositories (WP-02). Pushed by abd-cloud-containers (WP-03) through the
# github-ecr-push-abd-cloud-containers role (account-global/github-deploy).
# Defaults: mutable tags (consumers pin by digest), basic scan on push, AES256, expire
# untagged images after 7 days, keep the newest 30 dated (*-20*) images.
# The image generator PoC repository (poc-tulox-image-fleet) is not managed here.
# --------------------------------------------------------------------------------------------

repositories = {
  "abd/base"          = {}
  "abd/php"           = {}
  "abd/laravel"       = {}
  "abd/wordpress"     = {}
  "abd/github-runner" = {}

  # WordPress site images (WP-05), one per site, pushed by abd-cloud-containers' sites.yml.
  # Two weeks of dated images for rollback (a same-day rebuild replaces that day's tag).
  "abd/wp-blacklit-uk" = { keep_dated_images = 14 }

  # Throwaway pushes from CI tests (WP-02 Done when); everything expires after a day
  "abd/ci-test" = { expire_all_after_days = 1 }
}

# --------------------------------------------------------------------------------------------
# Pull-through cache for ECR Public: official images as
# <registry>/ecr-public/docker/library/<image>:<tag> (e.g. valkey, mysql, debian)
# --------------------------------------------------------------------------------------------

pull_through_cache_prefix = "ecr-public"

# --------------------------------------------------------------------------------------------
# Managed pull policy for the ECS execution role (attached by WP-04)
# --------------------------------------------------------------------------------------------

pull_policy_name = "ecr-pull-abd"
