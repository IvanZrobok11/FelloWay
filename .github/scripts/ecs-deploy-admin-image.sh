#!/usr/bin/env bash
# Register a new ECS task definition revision with the given admin image, then update the service.
set -euo pipefail

CLUSTER="${1:?cluster}"
SERVICE="${2:?service}"
TASK_FAMILY="${3:?task family}"
IMAGE_URI="${4:?image uri}"
CONTAINER_NAME="${5:-admin}"

TASK_DEF="$(aws ecs describe-task-definition --task-definition "$TASK_FAMILY" --query taskDefinition)"

echo "$TASK_DEF" | jq --arg IMAGE "$IMAGE_URI" --arg NAME "$CONTAINER_NAME" '
  .containerDefinitions |= map(if .name == $NAME then .image = $IMAGE else . end) |
  del(
    .taskDefinitionArn,
    .revision,
    .status,
    .requiresAttributes,
    .compatibilities,
    .registeredAt,
    .registeredBy,
    .deregisteredAt
  )
' > task-def.json

NEW_ARN="$(aws ecs register-task-definition --cli-input-json file://task-def.json --query taskDefinition.taskDefinitionArn --output text)"
echo "Registered $NEW_ARN"

aws ecs update-service \
  --cluster "$CLUSTER" \
  --service "$SERVICE" \
  --task-definition "$NEW_ARN" \
  --force-new-deployment \
  --output text \
  --query 'service.serviceName'

echo "ECS admin service $SERVICE updated with image $IMAGE_URI"
