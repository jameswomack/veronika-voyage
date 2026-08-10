# .ai/ Directory Changelog

All notable changes to the site and to the `.ai/` agent-context system will be
documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added — `.ai/` agent-context system (2026-08-09)

Set up the `.ai/` standard used across other repos (mlb-projections, womack-audio) so
Claude Code, Augment, Cursor, and Gemini all read from one committed, vendor-neutral
source of truth instead of duplicated tool-specific config.

- `.ai/SPEC.md` — living spec: repo structure, feature registry, deploy notes, working
  agreements, ID reservation table.
- `.ai/shared/repo-context.md` — canonical context (symlinked as `CLAUDE.md`/`AGENTS.md`):
  what each file is for, GitHub Pages deploy model, `email.html`'s specific job.
- `.ai/tool-configs/` — Gemini, Cursor, Augment rule files + `claude/settings.template.json`
  (declares `superpowers@claude-plugins-official`, wires repo hooks) and a
  `superpowers.manifest.json` version pin (6.2.0).
- `.ai/hooks/` — `session-start-spec.sh` (branch + recent changelog on session start),
  `spec-changelog-reminder.sh` (nudge to update SPEC/CHANGELOG when site pages change),
  `readme-freshness-reminder.sh` (nudge to check README.md when photo sources, SITE_URL,
  or RSVP contact info change), `lint-changed-files.sh` (best-effort markdown/HTML lint on
  Stop), and a reference copy of the global `enforce-worktree.sh`.
- `.ai/tools/claim-id.sh` + `.ai/scripts/claim-spec-id.sh` — bash port of mlb-projections'
  TypeScript `claim-id.ts` (this repo has no Node/npm toolchain, so no `tsx` dependency).
- `.ai/agents/` — `html-email-specialist`, `static-site-reviewer`, `link-preview-auditor`,
  sized for a static HTML/CSS/JS project rather than the framework-heavy agent roster in
  mlb-projections.
- `.ai/scripts/setup-ai-symlinks.sh`, `setup-worktree.sh`, `validate-ai-symlinks.sh`,
  `heal-ai-workspace.sh` — adapted from mlb-projections, stripped of monorepo/Prisma/npm
  steps that don't apply here.
- `.githooks/` (`post-checkout`, `post-merge`, `post-rewrite`) wired via
  `git config core.hooksPath .githooks` — self-heals the generated symlinks after a
  branch switch, without needing husky/npm.
- `.ai/workflows/` — `worktree.md`, `hooks.md`, `readme-maintenance.md`.

No site content changed in this pass — this is tooling only.

---

## Prior history (pre-`.ai/`)

Reconstructed from git log for context; not maintained retroactively beyond this point.

- Gated the cruise booking link behind a click-triggered instructions popover; renamed
  the `[i]` info button to `cruise-info-*` and removed it.
- Slowed the envelope-opening animation (2x duration + 0.3s) for a less jarring reveal;
  added the enveloper PSD source asset.
- Updated the email eyebrow copy in `email.html`.
- Added local-preview instructions to `README.md`.
