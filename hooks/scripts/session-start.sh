#!/bin/bash
set -euo pipefail

# SessionStart hook: auto-set OTEL env vars if live-report is configured
STATE_FILE=".claude/live-report.local.md"

if [[ ! -f "$STATE_FILE" ]]; then
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$STATE_FILE")
ENABLED=$(echo "$FRONTMATTER" | grep '^enabled:' | sed 's/enabled: *//' | sed 's/^"\(.*\)"$/\1/')

if [[ "$ENABLED" != "true" ]]; then
  exit 0
fi

# Read configuration
OTLP_ENDPOINT=$(echo "$FRONTMATTER" | grep '^otlp_endpoint:' | sed 's/otlp_endpoint: *//' | sed 's/^"\(.*\)"$/\1/')
OTLP_PROTOCOL=$(echo "$FRONTMATTER" | grep '^otlp_protocol:' | sed 's/otlp_protocol: *//' | sed 's/^"\(.*\)"$/\1/')
TRACES_BETA=$(echo "$FRONTMATTER" | grep '^traces_beta:' | sed 's/traces_beta: *//' | sed 's/^"\(.*\)"$/\1/')

# Defaults
OTLP_ENDPOINT="${OTLP_ENDPOINT:-http://localhost:4317}"
OTLP_PROTOCOL="${OTLP_PROTOCOL:-grpc}"
TRACES_BETA="${TRACES_BETA:-true}"

# Write env vars to CLAUDE_ENV_FILE so they persist for the session
if [[ -n "${CLAUDE_ENV_FILE:-}" ]]; then
  cat >> "$CLAUDE_ENV_FILE" <<EOF
export CLAUDE_CODE_ENABLE_TELEMETRY=1
export OTEL_METRICS_EXPORTER=otlp
export OTEL_LOGS_EXPORTER=otlp
export OTEL_EXPORTER_OTLP_PROTOCOL=${OTLP_PROTOCOL}
export OTEL_EXPORTER_OTLP_ENDPOINT=${OTLP_ENDPOINT}
EOF

  if [[ "$TRACES_BETA" == "true" ]]; then
    cat >> "$CLAUDE_ENV_FILE" <<EOF
export OTEL_TRACES_EXPORTER=otlp
export CLAUDE_CODE_ENHANCED_TELEMETRY_BETA=1
EOF
  fi
fi
