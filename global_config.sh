#!/bin/bash
# --------------------------------------------------------------------------------------------
# Global platform configuration
# --------------------------------------------------------------------------------------------

# Set some global defaults which we should override in order to continue
build_resources=""
statefile_basename="global"

# Authentication account - source of user console logins
acct_auth="813984516777"

# Apex account - where the primary TLD apex zone lives
acct_apex="813984516777"

# Target account - where are we going to build resources
acct_target="813984516777"

# List of accounts defined within this configuration
# used to define path names within DynamoDB statefile locations
acct_list=(
  813984516777:authentication
  813984516777:abd-global
  800653036500:abd-wordpress
)

# Terraform execution configuration params
lock="false"
locktimeout="0"
[ "" = "${parallelism}" ] && parallelism="10"
