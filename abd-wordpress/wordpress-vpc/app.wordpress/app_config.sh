#!/bin/bash

build_resources="compute/ec2-asg"
statefile_basename="${vpc_name}/app.wordpress/ec2-asg"

# Specify the location of the public SSH key part to upload here
# so that we can use relative file paths.
export TF_VAR_asg_ssh_public_key_file="`pwd`/files/abd-wp-ssh.pub"

export TF_VAR_user_data_script_folder="`pwd`/files"
