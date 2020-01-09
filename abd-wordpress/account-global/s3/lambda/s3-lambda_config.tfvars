# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "lambda"

# --------------------------------------------------------------------------------------------
# S3 specific configuration parameters
# --------------------------------------------------------------------------------------------

s3_name = "abd-wordpress-lambda"

# The policy template file
policy_file = "lambda.tpl.json"
