---
name: setup
description: Configure OTEL telemetry env vars and deploy the Docker monitoring stack
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "AskUserQuestion"]
---

# Setup — Configure OTEL Telemetry & Monitoring Stack

## Steps

### 1. Check for existing settings

Read `.claude/live-report.local.md` in the current project root. If it exists, parse the YAML frontmatter to load any previously saved configuration. Show the user what's currently configured.

### 2. Ask user for configuration

Prompt the user for each setting, showing the current value (if any) or the default:

| Setting | Default | Description |
|---------|---------|-------------|
| Grafana URL | `http://localhost:3000` | URL for the Grafana dashboard |
| OTLP endpoint | `http://localhost:4317` | OpenTelemetry collector endpoint |
| OTLP protocol | `grpc` | Protocol for OTLP export (`grpc` or `http/protobuf`) |
| Enable traces beta | `yes` | Enable Claude Code enhanced telemetry beta |
| Deploy Docker stack | `yes` | Spin up the Grafana monitoring stack via Docker Compose |

### 3. Write settings

Write the configuration to `.claude/live-report.local.md` with YAML frontmatter:

```markdown
---
enabled: true
grafana_url: <GRAFANA_URL>
otlp_endpoint: <OTLP_ENDPOINT>
otlp_protocol: <OTLP_PROTOCOL>
traces_beta: <true|false>
---
```

### 4. Deploy Docker stack (if requested)

Run:

```bash
docker compose -f ${CLAUDE_PLUGIN_ROOT}/stack/docker-compose.yml up -d
```

After deployment, verify all 5 services are healthy:

```bash
docker compose -f ${CLAUDE_PLUGIN_ROOT}/stack/docker-compose.yml ps --format json
```

Expected healthy services:
- **otel-collector** — OpenTelemetry Collector
- **prometheus** — Metrics storage
- **loki** — Log aggregation
- **tempo** — Distributed tracing
- **grafana** — Dashboard UI

If any service is not healthy, report the issue and suggest troubleshooting steps.

### 5. Configure Claude Code OTEL env vars

Use the `update-config` skill or instruct the user to add these 7 environment variables to their Claude Code settings (`.claude/settings.json` or `.claude/settings.local.json` under `"env"`):

```json
{
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
    "OTEL_METRICS_EXPORTER": "otlp",
    "OTEL_LOGS_EXPORTER": "otlp",
    "OTEL_TRACES_EXPORTER": "otlp",
    "CLAUDE_CODE_ENHANCED_TELEMETRY_BETA": "1",
    "OTEL_EXPORTER_OTLP_PROTOCOL": "<OTLP_PROTOCOL>",
    "OTEL_EXPORTER_OTLP_ENDPOINT": "<OTLP_ENDPOINT>"
  }
}
```

Replace `<OTLP_PROTOCOL>` and `<OTLP_ENDPOINT>` with the values from step 2.

### 6. Remind user to restart

Tell the user:

> **Restart Claude Code** for the environment variables to take effect. After restarting, run `/start` to verify telemetry is active.
