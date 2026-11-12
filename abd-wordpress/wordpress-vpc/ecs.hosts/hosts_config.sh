#!/bin/bash

build_resources="compute/ec2-asg"
statefile_basename="${vpc_name}/ecs-hosts/ec2-asg"

# The ECS hosts have no SSH access in normal use (SSM Session Manager is available), but
# the ec2-asg template always registers a key pair, so reuse the WordPress public key.
TF_VAR_asg_ssh_public_key_file="$(pwd)/../app.wordpress/files/abd-wp-ssh.pub"
export TF_VAR_asg_ssh_public_key_file

# User data (ECS cluster join) lives alongside this config
TF_VAR_user_data_script_folder="$(pwd)/files"
export TF_VAR_user_data_script_folder
