#!/bin/bash
# rollback.sh — Stop the broken container and restore the previous stable image

DOCKERHUB_USERNAME="${1:?Usage: rollback.sh <dockerhub_username>}"
STABLE_IMAGE="$DOCKERHUB_USERNAME/techflow-app:previous_stable"

echo "🔄 Rolling back to $STABLE_IMAGE ..."

# Stop and remove the broken container
docker stop techflow-app 2>/dev/null && echo "Stopped broken container."
docker rm   techflow-app 2>/dev/null && echo "Removed broken container."

# Pull the previous stable image
echo "Pulling $STABLE_IMAGE ..."
if ! docker pull "$STABLE_IMAGE"; then
  echo "❌ Could not pull $STABLE_IMAGE. No rollback target available."
  exit 1
fi

# Start the stable container
docker run -d \
  --name techflow-app \
  --restart unless-stopped \
  -p 80:5000 \
  "$STABLE_IMAGE"

echo "✅ Rollback complete. Verifying health..."

# Verify rollback succeeded
if /home/ubuntu/scripts/health_check.sh; then
  echo "✅ Rollback successful — previous stable version is running."
  exit 0
else
  echo "❌ Rollback health check also failed. Manual intervention required!"
  exit 1
fi
