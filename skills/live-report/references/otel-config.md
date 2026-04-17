# OpenTelemetry Configuration Reference

## Environment Variables (Full List)

| Variable | Description | Default |
|----------|-------------|---------|
| `CLAUDE_CODE_ENABLE_TELEMETRY` | Master switch (required) | — |
| `OTEL_METRICS_EXPORTER` | Metrics exporter | `none` |
| `OTEL_LOGS_EXPORTER` | Logs/events exporter | `none` |
| `OTEL_TRACES_EXPORTER` | Traces exporter (beta) | `none` |
| `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` | Enable traces | — |
| `OTEL_EXPORTER_OTLP_PROTOCOL` | Protocol | `http/protobuf` |
| `OTEL_EXPORTER_OTLP_ENDPOINT` | Collector endpoint | — |
| `OTEL_EXPORTER_OTLP_HEADERS` | Auth headers | — |
| `OTEL_METRIC_EXPORT_INTERVAL` | Metrics flush interval (ms) | `60000` |
| `OTEL_LOGS_EXPORT_INTERVAL` | Logs flush interval (ms) | `5000` |
| `OTEL_TRACES_EXPORT_INTERVAL` | Traces flush interval (ms) | `5000` |
| `OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE` | Temporality | `delta` |
| `OTEL_METRICS_INCLUDE_SESSION_ID` | Include session.id | `true` |
| `OTEL_RESOURCE_ATTRIBUTES` | Custom resource attributes | — |
| `OTEL_SERVICE_NAME` | Override service name | `claude-code` |

## Privacy Controls

| Variable | What It Enables | Default |
|----------|-----------------|---------|
| `OTEL_LOG_USER_PROMPTS=1` | Prompt content in events/spans | Disabled |
| `OTEL_LOG_TOOL_DETAILS=1` | Tool parameters (commands, paths) | Disabled |
| `OTEL_LOG_TOOL_CONTENT=1` | Full tool I/O in spans (60KB limit) | Disabled |
| `OTEL_LOG_RAW_API_BODIES=1` | Full API request/response JSON | Disabled |

## Metrics

| Metric | Unit | Attributes |
|--------|------|------------|
| `claude_code.token.usage` | tokens | `type` (input/output/cacheRead/cacheCreation), `model` |
| `claude_code.cost.usage` | USD | `model` |
| `claude_code.session.count` | count | — |
| `claude_code.lines_of_code.count` | count | `type` (added/removed) |
| `claude_code.commit.count` | count | — |
| `claude_code.pull_request.count` | count | — |
| `claude_code.code_edit_tool.decision` | count | `tool_name`, `decision`, `source`, `language` |
| `claude_code.active_time.total` | seconds | `type` (user/cli) |

## Events

| Event | Key Attributes |
|-------|----------------|
| `claude_code.user_prompt` | `prompt_length` |
| `claude_code.api_request` | `model`, `cost_usd`, `duration_ms`, `input_tokens`, `output_tokens`, `cache_read_tokens`, `cache_creation_tokens` |
| `claude_code.api_error` | `model`, `error`, `status_code`, `duration_ms`, `attempt` |
| `claude_code.tool_result` | `tool_name`, `success`, `duration_ms`, `error` |
| `claude_code.tool_decision` | `tool_name`, `decision`, `source` |
| `claude_code.plugin_installed` | `plugin.name`, `plugin.version` |
| `claude_code.skill_activated` | `skill.name`, `skill.source`, `plugin.name` |

## Trace Spans (Beta)

| Span | Description |
|------|-------------|
| `claude_code.interaction` | Full turn: prompt → response |
| `claude_code.llm_request` | API call with model, latency, tokens |
| `claude_code.tool` | Tool invocation with child spans |
| `claude_code.tool.blocked_on_user` | Permission wait time |
| `claude_code.tool.execution` | Actual tool execution |
| `claude_code.hook` | Hook execution |

## Resource Attributes

All signals include: `service.name`, `service.version`, `os.type`, `os.version`, `host.arch`, `session.id`, `user.id`, `user.account_uuid`, `user.email`, `organization.id`, `terminal.type`

## Grafana Dashboard Panels

The pre-provisioned dashboard (`claude-code-live-report`) includes:

1. **Token Usage** — Stacked bar chart by type (input, output, cacheRead, cacheCreation)
2. **Session Cost** — Running total stat panel with color thresholds
3. **Cost Over Time** — Time series of cost rate
4. **Active Sessions** — Counter
5. **Active Time** — Time series by type (user/cli)
6. **Lines of Code** — Stat panel (added/removed)
7. **Commits** — Counter
8. **Pull Requests** — Counter
9. **Cache Efficiency** — Gauge (cacheRead / total input ratio)
10. **Token Usage by Model** — Pie chart
11. **Tool Usage** — Table from Loki events
12. **API Latency** — Histogram from Loki events
