# .ai/ Directory Changelog

All notable changes to the site and to the `.ai/` agent-context system will be
documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Changed — adopted npm for dev tooling (2026-08-10)

`package.json` (added separately, tracking `serve` for local preview) is now used more
fully: `markdownlint-cli2` is a devDependency instead of an optional global tool, and
`.ai/hooks/lint-changed-files.sh` prefers the pinned `node_modules/.bin` copy over a
global install. Added `npm run setup:ai` / `validate:ai` / `lint:md` scripts and a
`postinstall` hook that re-runs `.ai/scripts/setup-ai-symlinks.sh` as a self-heal — on
top of, not instead of, the committed symlinks from the previous fix (npm install is
still not guaranteed to run before someone opens Claude Code here, so the symlinks stay
committed either way). `.ai/scripts/setup-worktree.sh` now also runs `npm install`.
Root `.markdownlint.jsonc` gained `MD060: disabled` (dropped by mistake when this file
was first written — restores the setting mlb-projections uses) and `.ai/agents/` got a
scoped override disabling `MD041` (agent persona files intentionally don't open with an
H1). This repo is still not gaining a build step — `npm run build` remains a no-op; npm
here is exclusively for tiny dev-time tooling. See `.ai/shared/repo-context.md` for the
full npm-scripts table.

### Fixed — Superpowers wasn't actually guaranteed on a fresh clone (2026-08-09)

The initial `.ai/` setup gitignored `CLAUDE.md`, `.claude/settings.json`, and the other
vendor entry points, following the mlb-projections/womack-audio pattern exactly — but
those repos regenerate them via an npm-postinstall (husky) hook, which this repo has no
equivalent of (no `package.json`). The practical effect: a brand-new collaborator cloning
this repo got no `CLAUDE.md` and no `.claude/settings.json` at all until they thought to
manually run `.ai/scripts/setup-ai-symlinks.sh` — so Superpowers activation was never
actually guaranteed, contrary to the goal.

Fix: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.cursorrules`, `.claude/skills`,
`.claude/agents`, `.claude/settings.json`, and `.augment/*` are now **committed symlinks**
into `.ai/` rather than gitignored/generated files. `.claude/settings.json` in particular
now symlinks directly to `.ai/tool-configs/claude/settings.template.json` instead of
being a copy — no drift possible, no generation step needed. A plain `git clone` is now
sufficient; `.ai/scripts/setup-ai-symlinks.sh` is only needed to repair a symlink
clobbered by a tool that doesn't preserve them. Only `.claude/settings.local.json`
(personal permission allow-list) remains gitignored.

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
