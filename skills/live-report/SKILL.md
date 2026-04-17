---
name: live-report
description: This skill should be used when the user asks to "set up monitoring", "enable telemetry", "start live report", "show session status", "open Grafana dashboard", "parse session history", "configure OpenTelemetry", "view token usage", "track cost", "analyze JSONL transcripts", or mentions Claude Code observability, metrics, or telemetry.
argument-hint: "setup | start | status | dashboard | history"
allowed-tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep", "WebFetch"]
---

# Live Report — Claude Code Telemetry & Dashboards

Set up and manage real-time Claude Code observability via OpenTelemetry export to a Grafana stack (Prometheus + Loki + Tempo), with historical analysis from local JSONL session transcripts.

## Subcommands

Parse the user's argument to determine which subcommand to run. If no argument is provided, default to `status`.

| Argument    | Action                                                  |
|-------------|---------------------------------------------------------|
| `setup`     | Configure OTEL env vars and optionally deploy Docker stack |
| `start`     | Enable telemetry for the current session                |
| `status`    | Show current telemetry state and connectivity           |
| `dashboard` | Open Grafana in the browser                             |
| `history`   | Parse JSONL transcripts for historical session analysis |

---

## setup

Goal: Configure Claude Code's native OpenTelemetry export and optionally spin up the Grafana monitoring stack.

### Steps

1. **Check for existing settings** — read `.claude/live-report.local.md` if it exists.
2. **Ask user for configuration** (or use defaults):
   - Grafana URL (default `http://localhost:3000`)
   - OTLP endpoint (default `http://localhost:4317`)
   - OTLP protocol (default `grpc`)
   - Whether to enable traces beta (default `yes`)
   - Whether to deploy the Docker stack (default `yes`)
3. **Write settings** to `.claude/live-report.local.md`:

   ```markdown
   ---
   enabled: true
   grafana_url: http://localhost:3000
   otlp_endpoint: http://localhost:4317
   otlp_protocol: grpc
   traces_beta: true
   ---
   ```

4. **If deploying Docker stack**, run:

   ```bash
   docker compose -f ${CLAUDE_PLUGIN_ROOT}/stack/docker-compose.yml up -d
   ```

   Verify all 5 services are healthy (otel-collector, prometheus, loki, tempo, grafana).

5. **Configure Claude Code settings** — use the `update-config` skill or instruct the user to add these environment variables to `.claude/settings.json` under `env`:

   ```json
   {
     "env": {
       "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
       "OTEL_METRICS_EXPORTER": "otlp",
       "OTEL_LOGS_EXPORTER": "otlp",
       "OTEL_TRACES_EXPORTER": "otlp",
       "CLAUDE_CODE_ENHANCED_TELEMETRY_BETA": "1",
       "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
       "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317"
     }
   }
   ```

6. **Remind user** to restart Claude Code for env vars to take effect.

---

## start

Goal: Verify telemetry is active in the current session and the collector is reachable.

### Steps

1. Read `.claude/live-report.local.md` settings.
2. Check environment variables are set:

   ```bash
   echo "CLAUDE_CODE_ENABLE_TELEMETRY=$CLAUDE_CODE_ENABLE_TELEMETRY"
   echo "OTEL_METRICS_EXPORTER=$OTEL_METRICS_EXPORTER"
   echo "OTEL_EXPORTER_OTLP_ENDPOINT=$OTEL_EXPORTER_OTLP_ENDPOINT"
   ```

3. Test collector connectivity:

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/skills/live-report/scripts/check-collector.sh
   ```

4. Report status to user with a summary table.

---

## status

Goal: Show current telemetry configuration, Docker stack health, and data freshness.

### Steps

1. Read `.claude/live-report.local.md` for configuration.
2. Check Docker stack status:

   ```bash
   docker compose -f ${CLAUDE_PLUGIN_ROOT}/stack/docker-compose.yml ps --format json 2>/dev/null
   ```

3. Check OTEL env vars in current environment.
4. Test Grafana connectivity:

   ```bash
   curl -sf "${GRAFANA_URL}/api/health" 2>/dev/null
   ```

5. Present a summary:

   | Component       | Status |
   |-----------------|--------|
   | OTEL Env Vars   | ✅/❌  |
   | OTel Collector  | ✅/❌  |
   | Prometheus      | ✅/❌  |
   | Loki            | ✅/❌  |
   | Tempo           | ✅/❌  |
   | Grafana         | ✅/❌  |

---

## dashboard

Goal: Open Grafana in the user's browser.

### Steps

1. Read Grafana URL from `.claude/live-report.local.md` (default `http://localhost:3000`).
2. Open in browser:

   ```bash
   open "${GRAFANA_URL}" 2>/dev/null || xdg-open "${GRAFANA_URL}" 2>/dev/null
   ```

3. Show user the URL and available dashboard panels:
   - Token Usage (by type and model)
   - Cost Tracking (running total)
   - Session Activity (count + active time)
   - Productivity (LOC, commits, PRs)
   - Tool Usage Analysis
   - API Performance (latency histograms)
   - Cache Efficiency (hit ratio)
   - Trace Waterfall (Tempo)

---

## history

Goal: Parse local JSONL session transcripts for historical analysis.

### Steps

1. Determine project transcript directory:

   ```bash
   bash ${CLAUDE_PLUGIN_ROOT}/skills/live-report/scripts/parse-jsonl.sh --project "$(pwd)"
   ```

2. Parse JSONL files and produce a summary:
   - Total sessions
   - Total tokens (input, output, cache read, cache creation)
   - Estimated cost
   - Models used
   - Top tools by invocation count
   - Session durations
   - Compaction events

3. If user asks for a specific session, parse that session's JSONL in detail showing the conversation flow with token counts per turn.

4. Offer to export the summary as Markdown.

---

## Available Metrics (Reference)

These metrics are exported by Claude Code when OTEL is enabled:

| Metric                                | Description               |
|---------------------------------------|---------------------------|
| `claude_code.token.usage`             | Tokens by type and model  |
| `claude_code.cost.usage`              | Cost in USD               |
| `claude_code.session.count`           | Sessions started          |
| `claude_code.lines_of_code.count`     | Lines added/removed       |
| `claude_code.commit.count`            | Git commits               |
| `claude_code.pull_request.count`      | PRs created               |
| `claude_code.code_edit_tool.decision` | Edit decisions            |
| `claude_code.active_time.total`       | Active time (user/cli)    |

## Available Events (Reference)

| Event                           | Key Attributes                              |
|---------------------------------|---------------------------------------------|
| `claude_code.user_prompt`       | prompt_length                               |
| `claude_code.api_request`       | model, cost_usd, duration_ms, tokens        |
| `claude_code.api_error`         | model, error, status_code                   |
| `claude_code.tool_result`       | tool_name, success, duration_ms             |
| `claude_code.tool_decision`     | tool_name, decision, source                 |
| `claude_code.plugin_installed`  | plugin.name                                 |
| `claude_code.skill_activated`   | skill.name                                  |

## Additional Resources

### Reference Files

- **`references/otel-config.md`** — Full OTEL environment variable reference and Grafana dashboard panel definitions
- **`references/jsonl-schema.md`** — JSONL transcript field reference for historical parsing

### Utility Scripts

- **`scripts/check-collector.sh`** — Test OTLP collector connectivity
- **`scripts/parse-jsonl.sh`** — Parse JSONL transcripts and produce session summaries
