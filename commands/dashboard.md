---
name: dashboard
description: Open the Grafana monitoring dashboard in the browser
allowed-tools: ["Read", "Bash"]
---

# Dashboard — Open Grafana in Browser

## Steps

### 1. Read Grafana URL

Read `.claude/live-report.local.md` from the project root and parse the `grafana_url` from YAML frontmatter. Default to `http://localhost:3000` if not configured.

### 2. Open in browser

```bash
open "${GRAFANA_URL}" 2>/dev/null || xdg-open "${GRAFANA_URL}" 2>/dev/null
```

Replace `${GRAFANA_URL}` with the resolved URL from step 1.

### 3. Show available dashboard panels

Tell the user the Grafana URL that was opened, and list the available dashboard panels:

- **Token Usage** — Tokens by type (input, output, cache read, cache creation) and model
- **Cost Tracking** — Running cost total in USD
- **Session Activity** — Session count and active time
- **Productivity** — Lines of code, commits, PRs
- **Tool Usage Analysis** — Tool invocations and success rates
- **API Performance** — Latency histograms for API requests
- **Cache Efficiency** — Cache hit ratio
- **Trace Waterfall** — Distributed traces via Tempo
