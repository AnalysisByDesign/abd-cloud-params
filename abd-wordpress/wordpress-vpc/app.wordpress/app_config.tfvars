# --------------------------------------------------------------------------------------------
# Global tag definitions - these will be overridden at each level as required.
# These should all be lower-case for consistency and compatability
# --------------------------------------------------------------------------------------------
# common_tag_owner = "abd"             - The business unit responsible for this resource
# common_tag_project = "abd"           - Helps to identify infrastructure
# common_tag_subsystem = "unknown"     - Allows splitting of project components into groups
# common_tag_component = "unknown"     - AWS resource such as vpc, storage, database, web, app
# common_tag_environment = "unknown"   - dev, preprod, production

common_tag_component = "app"

# --------------------------------------------------------------------------------------------
# PHP delivery scaling group configuration parameters
# --------------------------------------------------------------------------------------------

name = "ec2-asg"

asg_ec2_instance_type = "t4g.small"

asg_min_size = 1

asg_desired_capacity = 1

asg_max_size = 4

# --------------------------------------------------------------------------------------------

# This path returns a blank page, so we don't hit the DB, or anything
alb_health_check_path = "/license.txt"

# --------------------------------------------------------------------------------------------
# Which AMI image do we want to find the latest release of
#asg_ami_image_glob = "amzn2-ami-hvm-2.0*x86_64-gp2"
#asg_ami_image_owner = "amazon"

asg_ami_image_glob  = "abd-wp-php83-*"
asg_ami_image_owner = "813984516777"

asg_iam_profile_name = "ec2-asg"

user_data_script = "cloud-init.sh"

# --------------------------------------------------------------------------------------------
# S3 content bucket

s3_name        = "abd-wordpress-html"
s3_kms_key_arn = "arn:aws:kms:eu-west-1:800653036500:key/bb72ad25-373e-4793-bd39-792d01a448ad"

# --------------------------------------------------------------------------------------------
# SSH Connectivity

asg_ssh_key_name = "ec2-asg"

# --------------------------------------------------------------------------------------------
# Security groups

rds_security_group = "mysql"

efs_security_group = "html-efs"

# --------------------------------------------------------------------------------------------
# DNS Configuration

public_apex_domain = "abd-wp.uk"

public_sub_domain = ""

# --------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------
# --------------------------------------------------------------------------------------------
