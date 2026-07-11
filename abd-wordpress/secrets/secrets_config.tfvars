# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "secrets"

common_tag_environment = "wordpress"

# --------------------------------------------------------------------------------------------
# ParamStore Secret parameters
# --------------------------------------------------------------------------------------------


secrets = {

  # Wordpress configuration files
  "abd-wordpress/db.wordpress/admin" = {
    description = "WordPress application RDS credentials"
    type        = "SecureString"
    value       = <<-JSON
      {
        "username": "wordpress",
        "password": "change_me"
      }
    JSON
  }
  "abd-wordpress/shared/postfix/sasl_passwd" = {
    description = "Postfix SMTP relay credentials for abd-wordpress estate"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/abd.training/wp-config.php" = {
    description = "Wordpress configuration file for abd.training"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/amyegillin.uk/wp-config.php" = {
    description = "Wordpress configuration file for amyegillin.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/analysisbydesign.co.uk/wp-config.php" = {
    description = "Wordpress configuration file for analysisbydesign.co.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/baltihot.co.uk/wp-config.php" = {
    description = "Wordpress configuration file for baltihot.co.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/blacklit.uk/wp-config.php" = {
    description = "Wordpress configuration file for blacklit.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/daverix.ai/wp-config.php" = {
    description = "Wordpress configuration file for daverix.ai"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/daverix.uk/wp-config.php" = {
    description = "Wordpress configuration file for daverix.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/oranjj.uk/wp-config.php" = {
    description = "Wordpress configuration file for oranjj.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "abd-wordpress/rixinteriors.co.uk/wp-config.php" = {
    description = "Wordpress configuration file for rixinteriors.co.uk"
    type        = "SecureString"
    value       = "change_me"
  }

  # Mortgage Calculator configuration files
  "laravel/mortgage.daverix.ai/env" = {
    description = "Laravel configuration file for mortgage.daverix.ai"
    type        = "SecureString"
    value       = "change_me"
  }
  "laravel/mortgage.daverix.ai/deploy-key" = {
    description = "Github deploy key for mortgage.daverix.ai"
    type        = "SecureString"
    value       = "change_me"
  }


  # Tulox configuration files
  "laravel/tulox.uk/env" = {
    description = "Laravel configuration file for tulox.uk"
    type        = "SecureString"
    value       = "change_me"
  }
  "laravel/tulox.uk/deploy-key" = {
    description = "Github deploy key for tulox.uk"
    type        = "SecureString"
    value       = "change_me"
  }

}
