#!/bin/bash
# health_check.sh — Verify the app is alive after deployment

URL="http://localhost/health"
MAX_RETRIES=5
WAIT_SECONDS=5

echo "🔍 Starting health check for $URL ..."

for i in $(seq 1 $MAX_RETRIES); do
  echo "Attempt $i of $MAX_RETRIES..."

  HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

  if [ "$HTTP_STATUS" -eq 200 ]; then
    echo "✅ Health check passed! App returned HTTP $HTTP_STATUS."
    exit 0
  else
    echo "⚠️  Got HTTP $HTTP_STATUS. Waiting ${WAIT_SECONDS}s before retry..."
    sleep "$WAIT_SECONDS"
  fi
done

echo "❌ Health check failed after $MAX_RETRIES attempts."
exit 1
