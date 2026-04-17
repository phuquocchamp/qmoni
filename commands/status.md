---
name: status
description: Show monitoring stack health, telemetry config, and data freshness
allowed-tools: ["Read", "Bash"]
---

# Status — Monitoring Stack Health & Telemetry Config

## Steps

### 1. Read settings

Read `.claude/live-report.local.md` from the project root. Parse the YAML frontmatter for `grafana_url`, `otlp_endpoint`, `otlp_protocol`, and `enabled`. Use defaults if the file is missing:

- `grafana_url`: `http://localhost:3000`
- `otlp_endpoint`: `http://localhost:4317`

### 2. Check OTEL environment variables

Verify these env vars are set in the current session:
- `CLAUDE_CODE_ENABLE_TELEMETRY`
- `OTEL_METRICS_EXPORTER`
- `OTEL_LOGS_EXPORTER`
- `OTEL_TRACES_EXPORTER`
- `OTEL_EXPORTER_OTLP_PROTOCOL`
- `OTEL_EXPORTER_OTLP_ENDPOINT`

### 3. Check Docker stack status

```bash
docker compose -f ${CLAUDE_PLUGIN_ROOT}/stack/docker-compose.yml ps --format json 2>/dev/null
```

Parse the JSON output to determine health of each service: otel-collector, prometheus, loki, tempo, grafana.

### 4. Test Grafana connectivity

```bash
curl -sf "${GRAFANA_URL}/api/health" 2>/dev/null
```

Where `${GRAFANA_URL}` is the value from settings (default `http://localhost:3000`).

### 5. Present summary table

| Component | Status |
|-----------|--------|
| OTEL Env Vars | ✅/❌ |
| OTel Collector | ✅/❌ |
| Prometheus | ✅/❌ |
| Loki | ✅/❌ |
| Tempo | ✅/❌ |
| Grafana | ✅/❌ |

For any component showing ❌, include a brief reason (e.g., "container not running", "env var missing", "health check failed") and suggest running `/setup` to fix.
