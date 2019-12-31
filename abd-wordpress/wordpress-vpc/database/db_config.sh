#!/bin/bash

build_resources="database/rds-mysql"
statefile_basename="${vpc_name}/database/rds-mysql"

# These are special params for RDS that we need to configure through Bash
export TF_VAR_name="mysql"
export TF_VAR_final_snapshot_identifier="${TF_VAR_name}-${theDTS}"
