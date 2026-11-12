# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------

common_tag_component = "ecs"

# --------------------------------------------------------------------------------------------
# daverix.ai (WP-05): the site image abd/wp-daverix-ai (nginx and PHP-FPM in one
# container, port 8080). CI pins the image by digest on each rollout (WP-04 ruling 6); the
# floating tag here is only the first revision's.
# --------------------------------------------------------------------------------------------

name         = "daverix-ai"
cluster_name = "abd-wordpress-cluster"

containers = [
  {
    name  = "web"
    image = "800653036500.dkr.ecr.eu-west-1.amazonaws.com/abd/wp-daverix-ai:8.3"
    port  = 8080

    # FPM ondemand, at most 10 children (WP-05 ruling 13), at WP_MEMORY_LIMIT 100M
    memory_reservation = 256
    memory             = 768

    # Non-secret settings (WP-05 ruling 26): daverix.ai is the same site as daverix.uk and
    # takes its wp-config.php (ruling 15), so the daverix_uk database and daverix.uk mail
    environment = {
      WORDPRESS_DB_NAME = "daverix_uk"
      WORDPRESS_DB_USER = "daverix_uk"
      WORDPRESS_DB_HOST = "mysql-rw.int.wp.abd-wp.uk:3306"
      WP_TABLE_PREFIX   = "wp_"

      # Preview hostname until cutover (WP-05 ruling 27): then https://daverix.ai, and
      # WP_COOKIE_DOMAIN as the old wp-config.php had it
      WP_HOME    = "https://daverix-ai.abd-wp.uk"
      WP_SITEURL = "https://daverix-ai.abd-wp.uk"

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
      WPMS_MAIL_FROM      = "no-reply@daverix.uk"
      WPMS_MAIL_FROM_NAME = "Dave Rix"
    }

    # Secrets, one SecureString each, named after the variable (WP-05 ruling 26); split
    # from daverix.uk's wp-config.php into daverix.ai's own path
    secrets = {
      WORDPRESS_DB_PASSWORD      = "/abd-wordpress/daverix.ai/WORDPRESS_DB_PASSWORD"
      WORDPRESS_AUTH_KEY         = "/abd-wordpress/daverix.ai/WORDPRESS_AUTH_KEY"
      WORDPRESS_SECURE_AUTH_KEY  = "/abd-wordpress/daverix.ai/WORDPRESS_SECURE_AUTH_KEY"
      WORDPRESS_LOGGED_IN_KEY    = "/abd-wordpress/daverix.ai/WORDPRESS_LOGGED_IN_KEY"
      WORDPRESS_NONCE_KEY        = "/abd-wordpress/daverix.ai/WORDPRESS_NONCE_KEY"
      WORDPRESS_AUTH_SALT        = "/abd-wordpress/daverix.ai/WORDPRESS_AUTH_SALT"
      WORDPRESS_SECURE_AUTH_SALT = "/abd-wordpress/daverix.ai/WORDPRESS_SECURE_AUTH_SALT"
      WORDPRESS_LOGGED_IN_SALT   = "/abd-wordpress/daverix.ai/WORDPRESS_LOGGED_IN_SALT"
      WORDPRESS_NONCE_SALT       = "/abd-wordpress/daverix.ai/WORDPRESS_NONCE_SALT"
      WPMS_SMTP_USER             = "/abd-wordpress/daverix.ai/WPMS_SMTP_USER"
      WPMS_SMTP_PASS             = "/abd-wordpress/daverix.ai/WPMS_SMTP_PASS"
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
# old tree left as it is for rollback (WP-05 ruling 8). W3TC's settings come from
# daverix.uk's directory (ruling 15).
efs_access_points = {
  "uploads"     = { path = "/ecs/daverix.ai/uploads" }
  "w3tc-config" = { path = "/ecs/daverix.ai/w3tc-config" }
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
# Routing: the preview hostname on the existing ALB (WP-05 ruling 27). At cutover add
# "daverix.ai" and "www.daverix.ai": their DNS and certificate stay with
# hosted-sites/daverix.ai, and removing them hands the site back to the old host.
# --------------------------------------------------------------------------------------------

hostnames              = ["daverix-ai.abd-wp.uk"]
listener_rule_priority = 105
dns_zone_name          = "abd-wp.uk"
health_check_path      = "/healthz"

enable_alarms = true
