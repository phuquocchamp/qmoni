---
name: live-report
description: Auto-triggers when the user discusses monitoring, telemetry, observability, metrics, token tracking, cost tracking, OpenTelemetry, Grafana, OTEL, or Claude Code session analytics.
allowed-tools: ["Read", "Bash", "Glob", "Grep"]
---

# Live Report — Claude Code Telemetry & Dashboards

Real-time Claude Code observability via OpenTelemetry export to a Grafana stack (Prometheus + Loki + Tempo), with historical analysis from local JSONL session transcripts.

## Commands

Use these commands to manage the monitoring system:

| Command        | Purpose                                                    |
|----------------|------------------------------------------------------------|
| `/setup`       | Configure OTEL env vars and deploy the Docker stack        |
| `/start`       | Enable telemetry for the current session                   |
| `/status`      | Show telemetry state, stack health, and data freshness     |
| `/dashboard`   | Open Grafana in the browser                                |
| `/history`     | Parse JSONL transcripts for historical session analysis    |

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
