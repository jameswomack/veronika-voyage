# .ai/ — AI Agent Context System

Single, vendor-neutral source of truth for AI coding assistant context in this repo.
Tool-specific entry points (`CLAUDE.md`, `.claude/*`, `.cursorrules`, `.augment/*`,
`GEMINI.md`) are generated/symlinked from here by `.ai/scripts/setup-ai-symlinks.sh` —
they are never hand-edited directly.

Start with [`.ai/shared/repo-context.md`](shared/repo-context.md) for what this repo is.

## Layout

| Path | What it is |
|------|-----------|
| `SPEC.md` | Living spec — repo structure, feature registry, deploy notes, working agreements |
| `CHANGELOG.md` | Notable changes to the site and to this `.ai/` system |
| `shared/repo-context.md` | Canonical agent context — symlinked as `CLAUDE.md` / `AGENTS.md` |
| `tool-configs/` | Per-vendor rule files (Gemini, Cursor, Augment) + generated Claude settings template |
| `hooks/` | Claude Code hook scripts (SessionStart, PostToolUse, Stop reminders/lint) |
| `tools/claim-id.sh` | Reserves a `.ai/SPEC.md` ID before creating a worktree |
| `agents/` | Shared subagent personas (symlinked into `.claude/agents`, `.augment/agents`) |
| `scripts/` | Setup/validate/heal scripts for the symlinks + Claude settings |
| `workflows/` | `worktree.md`, `hooks.md`, `readme-maintenance.md` — process docs |
| `session-history/` | Gitignored — exported AI chat sessions (see `scripts/export-all-sessions.sh`) |

## First-time setup / after pulling

```shell
.ai/scripts/setup-ai-symlinks.sh
```

Regenerates `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules`, `.augment/`,
`.claude/skills`, `.claude/agents`, and `.claude/settings.json`, and wires
`.githooks/` so this self-heals on future checkouts/merges/rebases.

## Validate

```shell
.ai/scripts/validate-ai-symlinks.sh
```

## Superpowers plugin

This repo pins and enables `superpowers@claude-plugins-official` via
`.ai/tool-configs/claude/settings.template.json` → generated `.claude/settings.json`, so
anyone opening this repo in Claude Code gets it automatically, regardless of machine —
same pattern as mlb-projections and womack-audio. Version pin lives in
`.ai/tool-configs/claude/superpowers.manifest.json`.
