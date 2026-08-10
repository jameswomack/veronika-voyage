# Shared AI Agents

This directory is the **single source of truth** for all AI coding assistant agents
(subagents / personas). Platform-specific directories symlink here via
`.ai/scripts/setup-ai-symlinks.sh`.

## How it works

```text
.ai/agents/                <- Source of truth (this directory)
  html-email-specialist.md
  static-site-reviewer.md
  link-preview-auditor.md

.augment/agents/           <- Symlinks to .ai/agents/*.md
  html-email-specialist.md -> ../../.ai/agents/html-email-specialist.md

.claude/agents/            <- Symlink to ../.ai/agents (entire directory)
```

## Adding a new agent

1. Create `your-agent.md` in this directory with frontmatter:

   ```yaml
   ---
   name: your-agent
   description: One-line description of what this agent does
   model: claude-sonnet-4-6
   color: green
   ---
   ```

2. Run `.ai/scripts/setup-ai-symlinks.sh` to create platform symlinks.
3. The agent is now available in Claude Code and Augment (and any other platform that
   reads from `.ai/agents/`).

## Writing platform-agnostic agents

- Do NOT reference a specific platform (e.g., "Augment's context engine" or "Claude's
  tools"). Use generic phrasing: "You have access to the full codebase and can run
  terminal commands."
- Use the canonical Anthropic model ID for `model` (e.g., `claude-sonnet-4-6`), not a
  shorthand like `sonnet4.6`.
- The `color` field is Augment-specific; Claude Code ignores it. Unrecognized fields are
  silently ignored per-platform, so it's safe to include platform-specific decoration.

## Available agents

This repo is a small static HTML/CSS/JS site (e-vite + trip map + paste-ready email
fragment), not a framework application — the agent roster is scoped accordingly rather
than mirroring the larger set used in framework-heavy repos.

| Agent | Purpose |
|-------|---------|
| `html-email-specialist` | Keeps `email.html` a compatible, paste-ready fragment for real email clients |
| `static-site-reviewer` | Cross-browser/mobile rendering, accessibility, and performance review for `index.html` / `map/index.html` |
| `link-preview-auditor` | Social link-preview metadata (OG/Twitter tags, `SITE_URL` consistency, og-card) |
