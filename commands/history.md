---
name: history
description: Parse local JSONL session transcripts for historical analysis
allowed-tools: ["Read", "Bash", "Glob", "Grep"]
---

# History — JSONL Session Transcript Analysis

## Steps

### 1. Parse JSONL transcripts

Run the parsing script for the current project:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/skills/live-report/scripts/parse-jsonl.sh --project "$(pwd)"
```

### 2. Produce summary

From the parsed output, present a summary covering:

- **Total sessions** — Number of sessions found
- **Total tokens** — Broken down by type: input, output, cache read, cache creation
- **Estimated cost** — Total cost in USD
- **Models used** — List of models with usage counts
- **Top tools** — Tools ranked by invocation count
- **Session durations** — Average, min, max session length
- **Compaction events** — Number of context compactions across sessions

### 3. Detailed session view

If the user asks about a specific session, parse that session's JSONL file in detail showing the conversation flow with token counts per turn.

### 4. Export option

Offer to export the summary as a Markdown file. If the user accepts, write the report to a file such as `.claude/session-history-report.md` in the project root.
