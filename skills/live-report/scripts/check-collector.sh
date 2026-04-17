#!/bin/bash
set -euo pipefail

# Check OTLP collector connectivity
STATE_FILE=".claude/live-report.local.md"

if [[ -f "$STATE_FILE" ]]; then
  FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
  ENDPOINT=$(echo "$FRONTMATTER" | grep '^otlp_endpoint:' | sed 's/otlp_endpoint: *//' | sed 's/^"\(.*\)"$/\1/')
fi

ENDPOINT="${ENDPOINT:-http://localhost:4317}"

# Extract host and port
HOST=$(echo "$ENDPOINT" | sed -E 's|https?://||' | cut -d: -f1)
PORT=$(echo "$ENDPOINT" | sed -E 's|https?://||' | cut -d: -f2)
PORT="${PORT:-4317}"

# Test TCP connectivity
if nc -z -w 3 "$HOST" "$PORT" 2>/dev/null; then
  echo "OK: OTLP collector reachable at ${HOST}:${PORT}"
  exit 0
else
  echo "FAIL: Cannot reach OTLP collector at ${HOST}:${PORT}" >&2
  echo "Ensure the collector is running: docker compose -f \${CLAUDE_PLUGIN_ROOT}/stack/docker-compose.yml up -d" >&2
  exit 2
fi
