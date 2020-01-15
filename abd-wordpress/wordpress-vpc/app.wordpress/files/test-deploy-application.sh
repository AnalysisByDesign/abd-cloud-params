#!/bin/bash

# ---------------------------------------------
# NOTE - This script lives in source control
#  - but must be manually placed in the
#  - /builds folder on the target server
#  - BEFORE creating the AMI.
#
# This could be changed to deploy this script
# from source control or S3 bucket from within
# the user data script during server startup.
# ---------------------------------------------

version="v1.2"

# ---------------------------------------------
# Get parameters from the command line
# Eg. preprod used in AWS resource
short_env=$1
if [ "${short_env}" == "" ]; then
    echo "No environment supplied..."
    exit 1
fi
name=$2
if [ "${name}" == "" ]; then
    echo "No application name supplied..."
    exit 1
fi

environment=""
[ "${short_env}" == "test" ] && environment="test"
[ "${short_env}" == "sit" ] && environment="sit"
[ "${short_env}" == "preprod" ] && environment="pre-production"
[ "${short_env}" == "prod" ] && environment="production"
if [ "${environment}" == "" ]; then
    echo No environment specified - ${short_env}
    exit 1
fi

# Eg. test-app
s3_bucket="${short_env}-app"

build_num=`date "+%Y-%m-%d-%H%M"`
apache_path="/etc/apache2/sites-available"
config_path="/builds/${build_num}/config/environment/${environment}"
db_conf_file="${config_path}/doctrine.local.php"
s3_conf_file="${config_path}/aws.s3.local.php"

export HOME=/root
export APPLICATION_ENV="${environment}"

# IAM creds for S3 access
#s3_key_id=`aws ssm get-parameter --name "/test-app/${name}/s3/access-key-id"`
#s3_access_key=`aws ssm get-parameter --name "/test-app/${name}/s3/secret-access-key"`
s3_key_id=`aws ssm get-parameter --with-decryption --name "/${short_env}-app/${name}/s3/access-key-id" | jq -r '.Parameter.Value'`
s3_access_key=`aws ssm get-parameter --with-decryption --name "/${short_env}-app/${name}/s3/secret-access-key" | jq -r '.Parameter.Value'`

# Need this just in case there are dodgy chars
s3_key=`printf "%q" "${s3_key_id}"`
s3_access=`printf "%q" "${s3_access_key}"`

# Git repository for the application
release_tag="${short_env}_release"
repo_user=`aws ssm get-parameter --with-decryption --name "/${short_env}-app/${name}/jenkins/username" | jq -r '.Parameter.Value'`
repo_pwd=`aws ssm get-parameter --with-decryption --name "/${short_env}-app/${name}/jenkins/password" | jq -r '.Parameter.Value'`

# RDS user details
connection_string="db-rw.int.app.${short_env}"
db_username=`aws ssm get-parameter --with-decryption --name "/${short_env}-app/${name}/database/username" | jq -r '.Parameter.Value'`
db_password=`aws ssm get-parameter --with-decryption --name "/${short_env}-app/${name}/database/password" | jq -r '.Parameter.Value'`

echo "-----------------------------------------"
echo Starting application deployment - ${version}

# ---------------------------------------------
# Now we are ready to do things!
echo Stopping apache2
systemctl stop apache2

# ---------------------------------------------
echo Clean logs areas
rm -rf /var/log/apache2/* /var/log/awslogs.log* /var/www/logs/permit-app/*

# ---------------------------------------------
# Change to the correct working directory
cd /builds

# ---------------------------------------------
echo Prepare Apache config file for ${environment}
echo " - ${apache_path}/app.conf"
cp template.conf/apache2.conf ${apache_path}/app.conf
sed -i "s/PLACEHOLDER_ENVVAR/${environment}/" ${apache_path}/app.conf
ln -sf ${apache_path}/app.conf /etc/apache2/sites-enabled/app.conf

# ---------------------------------------------
echo Prepare the AWS config file
mkdir -p /.aws
cp template.conf/aws_creds /.aws/credentials
sed -i "s/PLACEHOLDER_KEY_ID/${s3_key}/" /.aws/credentials
sed -i "s/PLACEHOLDER_ACCESS_KEY/${s3_access}/" /.aws/credentials

# ---------------------------------------------
echo Clone the app repository for tag ${release_tag}
git clone -b ${release_tag} --single-branch --depth 1 git_repository_location ${build_num} > /dev/null

# ---------------------------------------------
echo Preparing application config files in ${config_path}
cd /builds/${build_num}

# ---------------------------------------------
echo Prepare the app DB config file with user ${db_username}
echo in ${db_conf_file}
sed -i "s/PLACEHOLDER_CONN/${connection_string}/" ${db_conf_file}
sed -i "s/PLACEHOLDER_DB_USER/${db_username}/" ${db_conf_file}
sed -i "s/PLACEHOLDER_DB_PWD/${db_password}/" ${db_conf_file}

# ---------------------------------------------
echo Prepare the app S3 config file for s3://${s3_bucket}
echo in ${s3_conf_file}
sed -i "s/PLACEHOLDER_S3_PATH/${s3_bucket}/" ${s3_conf_file}

# ---------------------------------------------
echo Prepare the NewRelic PHP Application name
sed -i "s/PLACEHOLDER_APP_NAME/Permit app (${short_env})/" /etc/php/7.2/mods-available/newrelic.ini

# ---------------------------------------------
echo Run composer install and preparation
composer install > /dev/null
composer setup > /dev/null

# ---------------------------------------------
# Set up the environments and stuff
# Set permissions
cd /builds
chown -R www-data:www-data ${build_num}

# ---------------------------------------------
# Swap the release symlink, start apache and finish!
rm -f release 2>/dev/null; ln -s ./${build_num} ./release

echo Restart apache2
systemctl start apache2

echo App deploy complete!
echo "-----------------------------------------"

