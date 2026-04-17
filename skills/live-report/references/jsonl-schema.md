# JSONL Transcript Schema Reference

## File Location

```
~/.claude/projects/<escaped-project-path>/
├── <session-uuid>.jsonl          # Main session transcript
├── <session-uuid>/
│   └── subagents/
│       └── agent-<id>.jsonl      # Subagent transcripts
```

Path encoding: forward slashes → hyphens (e.g., `/Users/foo/project` → `-Users-foo-project`)

## Entry Types

| Type | Description |
|------|-------------|
| `permission-mode` | Session start, contains `sessionId` and `permissionMode` |
| `user` | User message with full content |
| `assistant` | API response with usage, model, content blocks |
| `system` | System events (local commands, compaction, errors) |
| `attachment` | Image/file attachments |
| `file-history-snapshot` | Undo/redo tracking |
| `last-prompt` | Last prompt marker |
| `queue-operation` | Queue operations |

## Common Fields

| Field | Type | Description |
|-------|------|-------------|
| `type` | string | Entry type |
| `uuid` | string | Unique entry ID (UUID v4) |
| `parentUuid` | string | Parent entry UUID |
| `sessionId` | string | Session UUID |
| `timestamp` | string | ISO 8601 timestamp |
| `cwd` | string | Working directory |
| `entrypoint` | string | Launch method (`cli`, `vscode`) |
| `version` | string | Claude Code version |
| `gitBranch` | string | Current git branch |
| `isSidechain` | boolean | Sidechain conversation flag |

## Assistant Entry — `message` Object

| Field | Type | Description |
|-------|------|-------------|
| `message.id` | string | API message ID |
| `message.model` | string | Model (e.g., `claude-sonnet-4.6`) |
| `message.stop_reason` | string | `end_turn`, `tool_use`, etc. |
| `message.usage.input_tokens` | number | Input tokens |
| `message.usage.output_tokens` | number | Output tokens |
| `message.usage.cache_creation_input_tokens` | number | Cache creation tokens |
| `message.usage.cache_read_input_tokens` | number | Cache read tokens |
| `message.content` | array | Content blocks (text, thinking, tool_use, tool_result) |

## System Entry — Additional Fields

| Field | Type | Description |
|-------|------|-------------|
| `subtype` | string | `local_command`, `compact_boundary`, etc. |
| `compactMetadata` | object | `trigger`, `preTokens`, `postTokens`, `durationMs` |

## Stats Cache (`~/.claude/stats-cache.json`)

```json
{
  "version": 3,
  "lastComputedDate": "2026-04-15",
  "dailyActivity": [
    { "date": "2026-03-03", "messageCount": 148, "sessionCount": 17, "toolCallCount": 1 }
  ]
}
```

## Tracing Patterns

| What to Trace | Where to Find It |
|---------------|------------------|
| Session timeline | `timestamp` field |
| Conversation flow | `parentUuid` → `uuid` chains |
| Token consumption | `assistant` → `message.usage` |
| Model used | `assistant` → `message.model` |
| Tool calls | `assistant` content with `type: "tool_use"` |
| Tool results | `user` entries with `toolUseResult` |
| Errors | `system` entries with error content |
| Compaction | `system` with `subtype: "compact_boundary"` |
