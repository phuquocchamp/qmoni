#!/bin/bash
set -euo pipefail

# Parse Claude Code JSONL session transcripts and produce a summary
# Usage: parse-jsonl.sh --project /path/to/project [--session UUID]

PROJECT_DIR=""
SESSION_ID=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_DIR="$2"; shift 2 ;;
    --session) SESSION_ID="$2"; shift 2 ;;
    *) shift ;;
  esac
done

if [[ -z "$PROJECT_DIR" ]]; then
  PROJECT_DIR="$(pwd)"
fi

# Compute escaped project path (forward slashes → hyphens)
ESCAPED_PATH=$(echo "$PROJECT_DIR" | sed 's|/|-|g')
TRANSCRIPT_DIR="$HOME/.claude/projects/${ESCAPED_PATH}"

if [[ ! -d "$TRANSCRIPT_DIR" ]]; then
  echo "No transcripts found at $TRANSCRIPT_DIR" >&2
  exit 1
fi

if [[ -n "$SESSION_ID" ]]; then
  # Single session detail
  FILE="$TRANSCRIPT_DIR/${SESSION_ID}.jsonl"
  if [[ ! -f "$FILE" ]]; then
    echo "Session file not found: $FILE" >&2
    exit 1
  fi
  jq -c '{type, timestamp, model: .message.model, input_tokens: .message.usage.input_tokens, output_tokens: .message.usage.output_tokens, cache_read: .message.usage.cache_read_input_tokens, stop_reason: .message.stop_reason}' "$FILE" 2>/dev/null | head -100
else
  # Summary across all sessions
  TOTAL_SESSIONS=$(ls "$TRANSCRIPT_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
  echo "transcript_dir: $TRANSCRIPT_DIR"
  echo "total_sessions: $TOTAL_SESSIONS"
  echo "---"

  # Aggregate token usage across all sessions
  for f in "$TRANSCRIPT_DIR"/*.jsonl; do
    [[ -f "$f" ]] || continue
    SESSION=$(basename "$f" .jsonl)
    TOKENS=$(jq -s '[.[] | select(.type == "assistant") | .message.usage | select(. != null)] | {
      input: ([.[].input_tokens // 0] | add),
      output: ([.[].output_tokens // 0] | add),
      cache_read: ([.[].cache_read_input_tokens // 0] | add),
      cache_creation: ([.[].cache_creation_input_tokens // 0] | add),
      turns: length
    }' "$f" 2>/dev/null)

    if [[ -n "$TOKENS" && "$TOKENS" != "null" ]]; then
      TURNS=$(echo "$TOKENS" | jq -r '.turns')
      INPUT=$(echo "$TOKENS" | jq -r '.input')
      OUTPUT=$(echo "$TOKENS" | jq -r '.output')
      CACHE_R=$(echo "$TOKENS" | jq -r '.cache_read')
      echo "session: $SESSION | turns: $TURNS | input: $INPUT | output: $OUTPUT | cache_read: $CACHE_R"
    fi
  done
fi
