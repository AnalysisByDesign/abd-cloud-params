#!/bin/bash
# --------------------------------------------------------------------------------------------
# ECS host user data (ECS-optimised Amazon Linux 2023). Rendered by Terraform's templatefile,
# so the dollar-brace value below is a Terraform variable; there are no shell variables here.
# --------------------------------------------------------------------------------------------

cat >> /etc/ecs/ecs.config <<'CONFIG'
ECS_CLUSTER=${ecs_cluster_name}
ECS_ENABLE_CONTAINER_METADATA=true
ECS_RESERVED_MEMORY=256
ECS_CONTAINER_STOP_TIMEOUT=30s
ECS_AWSVPC_BLOCK_IMDS=true
CONFIG
