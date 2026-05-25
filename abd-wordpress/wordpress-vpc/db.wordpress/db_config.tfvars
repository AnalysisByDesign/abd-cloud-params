# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "database"

# --------------------------------------------------------------------------------------------
# RDS MySQL specific configuration parameters
# --------------------------------------------------------------------------------------------

name = "mysql"

admin_password = "ThisIsThePassword"

skip_final_snapshot = false

final_snapshot_identifier = "final"

backup_retention = 7

# Updated to reflect actual state (engine upgraded out of band from 5.7.26 -> 8.4.7)
engine_version = "8.4.7"

storage_type = "gp3"

param_group_name = "rds-manual-8-4"

monitoring_interval = "0"

cloudwatch_logging = []
