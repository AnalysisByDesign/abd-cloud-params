# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "storage"

name = "html"

throughput_mode = "bursting"

# Get the data back into regular storage
lifecycle_policy_transition_to_primary_storage_class = "AFTER_1_ACCESS"

# DO NOT ENABLE THIS, SMALL FILES END UP WITH A MIN OF 128Kb BLOCKS
# AND IT COSTS MORE TO RETRIVE THE DATA SHOULD IT BE NEEDED!
# lifecycle_policy_transition_to_ia                    = "AFTER_30_DAYS"
