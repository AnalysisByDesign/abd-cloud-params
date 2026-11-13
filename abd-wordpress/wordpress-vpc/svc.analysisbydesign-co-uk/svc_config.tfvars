# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------

common_tag_component = "ecs"

# --------------------------------------------------------------------------------------------
# analysisbydesign.co.uk (WP-05): the site image abd/wp-analysisbydesign-co-uk (nginx and PHP-FPM in one
# container, port 8080). CI pins the image by digest on each rollout (WP-04 ruling 6); the
# floating tag here is only the first revision's.
# --------------------------------------------------------------------------------------------

name         = "analysisbydesign-co-uk"
cluster_name = "abd-wordpress-cluster"

containers = [
  {
    name  = "web"
    image = "800653036500.dkr.ecr.eu-west-1.amazonaws.com/abd/wp-analysisbydesign-co-uk:8.3"
    port  = 8080

    # FPM ondemand, at most 10 children (WP-05 ruling 13), at WP_MEMORY_LIMIT 100M
    memory_reservation = 256
    memory             = 768

    # Non-secret settings, from the site's wp-config.php (WP-05 ruling 26)
    environment = {
      WORDPRESS_DB_NAME = "analysisbydesign_co_uk"
      WORDPRESS_DB_USER = "analysisbydesign_co_uk"
      WORDPRESS_DB_HOST = "mysql-rw.int.wp.abd-wp.uk:3306"
      WP_TABLE_PREFIX   = "wp_"

      # The real domain since cutover (WP-05 ruling 27); the preview hostname was
      # https://analysisbydesign-co-uk.abd-wp.uk. WP_COOKIE_DOMAIN is left unset, so
      # cookies are for analysisbydesign.co.uk exactly.
      WP_HOME    = "https://analysisbydesign.co.uk"
      WP_SITEURL = "https://analysisbydesign.co.uk"

      WP_MEMORY_LIMIT = "100M"
      WP_CACHE        = "true"

      # WP-Cron runs as a scheduled task instead (WP-05 ruling 7)
      WP_DISABLE_CRON = "true"

      # WP Mail SMTP, straight to IONOS (WP-05 ruling 6)
      WPMS_ON             = "true"
      WPMS_MAILER         = "smtp"
      WPMS_SMTP_HOST      = "smtp.ionos.co.uk"
      WPMS_SMTP_PORT      = "587"
      WPMS_SSL            = "tls"
      WPMS_SMTP_AUTH      = "true"
      WPMS_MAIL_FROM      = "no-reply@analysisbydesign.co.uk"
      WPMS_MAIL_FROM_NAME = "Dave Rix"
    }

    # Secrets, one SecureString each, named after the variable (WP-05 ruling 26)
    secrets = {
      WORDPRESS_DB_PASSWORD      = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_DB_PASSWORD"
      WORDPRESS_AUTH_KEY         = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_AUTH_KEY"
      WORDPRESS_SECURE_AUTH_KEY  = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_SECURE_AUTH_KEY"
      WORDPRESS_LOGGED_IN_KEY    = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_LOGGED_IN_KEY"
      WORDPRESS_NONCE_KEY        = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_NONCE_KEY"
      WORDPRESS_AUTH_SALT        = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_AUTH_SALT"
      WORDPRESS_SECURE_AUTH_SALT = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_SECURE_AUTH_SALT"
      WORDPRESS_LOGGED_IN_SALT   = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_LOGGED_IN_SALT"
      WORDPRESS_NONCE_SALT       = "/abd-wordpress/analysisbydesign.co.uk/WORDPRESS_NONCE_SALT"
      WPMS_SMTP_USER             = "/abd-wordpress/analysisbydesign.co.uk/WPMS_SMTP_USER"
      WPMS_SMTP_PASS             = "/abd-wordpress/analysisbydesign.co.uk/WPMS_SMTP_PASS"
    }

    # Writable paths (WP-05 rulings 8 and 14): uploads and W3TC's settings on EFS, the
    # page cache in memory
    mount_points = [
      { source_volume = "uploads", container_path = "/var/www/html/wp-content/uploads" },
      { source_volume = "w3tc-config", container_path = "/var/www/html/wp-content/w3tc-config" },
    ]
    tmpfs = [
      { container_path = "/var/www/html/wp-content/cache", size_mib = 128 },
    ]

    health_check = {
      command      = ["CMD-SHELL", "curl -fsS http://127.0.0.1:8080/healthz || exit 1"]
      start_period = 30
    }
  },
]

# New directories, owned by the image's user (10001); filled by rsync at cutover, with the
# old tree left as it is for rollback (WP-05 ruling 8)
efs_access_points = {
  "uploads"     = { path = "/ecs/analysisbydesign.co.uk/uploads" }
  "w3tc-config" = { path = "/ecs/analysisbydesign.co.uk/w3tc-config" }
}

# --------------------------------------------------------------------------------------------
# WP-Cron (WP-05 ruling 7): due events every 5 minutes, as a one-off task
# --------------------------------------------------------------------------------------------

scheduled_tasks = {
  "wp-cron" = {
    schedule  = "rate(5 minutes)"
    container = "web"
    command   = ["wp", "cron", "event", "run", "--due-now"]
  }
}

# --------------------------------------------------------------------------------------------
# Routing on the existing ALB (WP-05 ruling 27): analysisbydesign.co.uk and
# www.analysisbydesign.co.uk since cutover, plus the preview hostname. Their DNS and
# certificate stay with hosted-sites/analysisbydesign.co.uk; removing them (and setting
# WP_HOME and WP_SITEURL back to the preview) hands the site back to the old host.
# WordPress redirects www and the preview hostname to https://analysisbydesign.co.uk.
# --------------------------------------------------------------------------------------------

hostnames              = ["analysisbydesign.co.uk", "www.analysisbydesign.co.uk", "analysisbydesign-co-uk.abd-wp.uk"]
listener_rule_priority = 101
dns_zone_name          = "abd-wp.uk"
health_check_path      = "/healthz"

# abd-wordpress-analysisbydesign-co-uk is 36 characters, over the 32 a target group name allows
target_group_name = "abd-wp-analysisbydesign-co-uk"

enable_alarms = true
