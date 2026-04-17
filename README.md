# qmoni

Live session telemetry and Grafana dashboards for Claude Code via OpenTelemetry + JSONL transcript parsing.

## What It Does

- **Real-time monitoring** — Configures Claude Code's native OpenTelemetry export to send metrics, events, and traces to a Grafana stack
- **Pre-built dashboards** — Ships Grafana dashboards for token usage, cost tracking, cache efficiency, tool usage, and more
- **Historical analysis** — Parses local JSONL session transcripts for per-session and cross-session analysis
- **Auto-configuration** — SessionStart hook automatically sets OTEL env vars when configured

## Architecture

```
Claude Code → OTLP gRPC :4317 → OTel Collector → Prometheus (metrics)
                                                → Loki (events/logs)
                                                → Tempo (traces)
                                                → Grafana (dashboards)
```

## Installation

### Install via Claude Code Marketplace (Recommended)

**Step 1** — Add the marketplace:

```bash
# From inside Claude Code
/plugin marketplace add phuquocchamp/qmoni

# Or from the CLI
claude plugin marketplace add phuquocchamp/qmoni
```

**Step 2** — Install the plugin:

```bash
# From inside Claude Code
/plugin install live-report@qmoni

# Or from the CLI
claude plugin install live-report@qmoni
```

### Install from local clone

```bash
git clone https://github.com/phuquocchamp/qmoni.git
claude plugin marketplace add ./qmoni
/plugin install live-report@qmoni
```

### Verify installation

```bash
claude plugin list
```

You should see `live-report` in the output.

## Quick Start

1. Install the plugin (see above)

2. Run setup inside Claude Code:

   ```
   /live-report setup
   ```

3. Restart Claude Code. Telemetry begins automatically.

4. Open dashboard:
   ```
   /live-report dashboard
   ```

## Commands

| Command                  | Description                                        |
| ------------------------ | -------------------------------------------------- |
| `/live-report setup`     | Configure OTEL env vars + deploy Docker stack      |
| `/live-report start`     | Verify telemetry is active and collector reachable |
| `/live-report status`    | Show stack health and data freshness               |
| `/live-report dashboard` | Open Grafana in browser                            |
| `/live-report history`   | Parse JSONL transcripts for historical analysis    |

## Configuration

Create `.claude/live-report.local.md` in your project (created automatically by `setup`):

```markdown
---
enabled: true
grafana_url: http://localhost:3000
otlp_endpoint: http://localhost:4317
otlp_protocol: grpc
traces_beta: true
---
```

## Prerequisites

- Docker and Docker Compose (for the monitoring stack)
- Claude Code v2.1+ (for OpenTelemetry support)
- `jq` (for JSONL parsing in `history` command)

## Docker Stack

The included stack runs 5 services:

| Service        | Port       | Purpose            |
| -------------- | ---------- | ------------------ |
| OTel Collector | 4317, 4318 | Receives OTLP data |
| Prometheus     | 9090       | Stores metrics     |
| Loki           | 3100       | Stores events/logs |
| Tempo          | 3200       | Stores traces      |
| Grafana        | 3000       | Dashboards         |

Manage manually:

```bash
# Start
docker compose -f stack/docker-compose.yml up -d

# Stop
docker compose -f stack/docker-compose.yml down

# Logs
docker compose -f stack/docker-compose.yml logs -f
```

## Dashboard Panels

1. **Token Usage** — Stacked bar chart (input, output, cacheRead, cacheCreation)
2. **Session Cost** — Running total with color thresholds
3. **Cost Over Time** — Rate of spend
4. **Active Sessions** — Counter
5. **Active Time** — User vs CLI time
6. **Lines of Code / Commits / PRs** — Productivity stats
7. **Cache Efficiency** — Gauge (cache hit ratio)
8. **Token Usage by Model** — Pie chart
9. **Tool Usage** — Table from Loki events
10. **API Latency** — Histogram

## Privacy

All telemetry is local (localhost). No data leaves your machine unless you configure an external endpoint. Prompt content, tool details, and API bodies are **disabled by default** and require explicit opt-in via environment variables.

## License

MIT
