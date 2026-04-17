---
name: start
description: Verify telemetry is active and the OTLP collector is reachable
allowed-tools: ["Read", "Bash"]
---

# Start — Verify Telemetry & Collector Connectivity

## Steps

### 1. Read settings

Read `.claude/live-report.local.md` from the project root and parse the YAML frontmatter for `otlp_endpoint`, `otlp_protocol`, and `enabled` values.

If the file does not exist, inform the user to run `/setup` first.

### 2. Check environment variables

Verify the required OTEL env vars are set in the current session:

```bash
echo "CLAUDE_CODE_ENABLE_TELEMETRY=$CLAUDE_CODE_ENABLE_TELEMETRY"
echo "OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER"
echo "OTEL_LOGS_EXPORTER=$OTEL_LOGS_EXPORTER"
echo "OTEL_TRACES_EXPORTER=$OTEL_TRACES_EXPORTER"
echo "OTEL_EXPORTER_OTLP_PROTOCOL=$OTEL_EXPORTER_OTLP_PROTOCOL"
echo "OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT"
```

Flag any that are unset or empty.

### 3. Test collector connectivity

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/live-report/scripts/check-collector.sh
```

### 4. Report status

Present a summary table to the user:

| Check | Status |
|-------|--------|
| Settings file exists | ✅/❌ |
| OTEL env vars configured | ✅/❌ (list any missing) |
| OTLP Collector reachable | ✅/❌ |
| Telemetry active | ✅/❌ |

If everything passes, confirm: **Telemetry is active and the collector is receiving data.**

If any check fails, provide specific remediation steps (e.g., "Run `/setup` to configure" or "Restart Claude Code to load env vars").
