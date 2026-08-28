#!/bin/bash
# tag_stable.sh — Tag the currently running image as "previous_stable" on DockerHub
# Run this BEFORE each new deployment so rollback always has a target.

DOCKERHUB_USERNAME="${1:?Usage: tag_stable.sh <dockerhub_username>}"

echo "🏷️  Tagging current image as previous_stable..."

# Find the image ID of the currently running techflow-app container
CURRENT_IMAGE=$(docker inspect techflow-app --format='{{.Config.Image}}' 2>/dev/null)

if [ -z "$CURRENT_IMAGE" ]; then
  echo "⚠️  No running techflow-app container found. Skipping stable tag."
  exit 0
fi

echo "Current image: $CURRENT_IMAGE"

# Pull it locally (it may already be cached, but ensure it's present)
docker pull "$CURRENT_IMAGE"

# Tag it as previous_stable
STABLE_TAG="$DOCKERHUB_USERNAME/techflow-app:previous_stable"
docker tag "$CURRENT_IMAGE" "$STABLE_TAG"

# Push to DockerHub
if docker push "$STABLE_TAG"; then
  echo "✅ Successfully tagged and pushed $STABLE_TAG"
else
  echo "❌ Failed to push $STABLE_TAG to DockerHub."
  exit 1
fi
