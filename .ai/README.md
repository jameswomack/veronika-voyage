# .ai/ — AI Agent Context System

Single, vendor-neutral source of truth for AI coding assistant context in this repo.
Tool-specific entry points (`CLAUDE.md`, `.claude/*`, `.cursorrules`, `.augment/*`,
`GEMINI.md`) are **committed symlinks** into this directory — never hand-edited
directly. Unlike mlb-projections/womack-audio, this repo has no package manager to
auto-regenerate them on install, so the symlinks themselves are checked into git: a
plain `git clone` is enough to activate them, with no setup step required.

Start with [`.ai/shared/repo-context.md`](shared/repo-context.md) for what this repo is.

## Layout

| Path | What it is |
|------|-----------|
| `SPEC.md` | Living spec — repo structure, feature registry, deploy notes, working agreements |
| `CHANGELOG.md` | Notable changes to the site and to this `.ai/` system |
| `shared/repo-context.md` | Canonical agent context — symlinked as `CLAUDE.md` / `AGENTS.md` |
| `tool-configs/` | Per-vendor rule files (Gemini, Cursor, Augment) + the Claude settings template (`.claude/settings.json` symlinks to it) |
| `hooks/` | Claude Code hook scripts (SessionStart, PostToolUse, Stop reminders/lint) |
| `tools/claim-id.sh` | Reserves a `.ai/SPEC.md` ID before creating a worktree |
| `agents/` | Shared subagent personas (symlinked into `.claude/agents`, `.augment/agents`) |
| `scripts/` | Setup/validate/heal scripts for the symlinks + Claude settings |
| `workflows/` | `worktree.md`, `hooks.md`, `readme-maintenance.md` — process docs |
| `session-history/` | Gitignored — exported AI chat sessions (see `scripts/export-all-sessions.sh`) |

## First-time setup

Nothing to run. `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules`, `.augment/`,
`.claude/skills`, `.claude/agents`, and `.claude/settings.json` are all committed
symlinks — `git clone` alone puts them in place, including Superpowers enablement.

`.ai/scripts/setup-ai-symlinks.sh` is only needed to (re)create a symlink that got
clobbered (some GUI git clients / zip re-uploads don't preserve symlinks), or to wire
`.githooks/` so future checkouts/merges/rebases self-heal automatically.

## Validate

```shell
.ai/scripts/validate-ai-symlinks.sh
```

## Superpowers plugin

This repo pins and enables `superpowers@claude-plugins-official` via
`.ai/tool-configs/claude/settings.template.json`, which `.claude/settings.json` is a
committed symlink to — so anyone opening this repo in Claude Code gets it automatically,
regardless of machine, from a plain clone. (mlb-projections and womack-audio achieve the
same end state via an npm-postinstall-generated, gitignored copy instead; this repo has
no package manager, so the committed-symlink approach is what makes the guarantee hold
here.) Version pin lives in `.ai/tool-configs/claude/superpowers.manifest.json`.
