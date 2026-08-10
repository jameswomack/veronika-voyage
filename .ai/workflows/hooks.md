# Hooks

Five hook scripts live in `.ai/hooks/`. Four are repo-native (this project is too small
to share mlb-projections' global hook set — no dev server to guard, no search-engine
memory to update). `enforce-worktree` stays global-only, same as every other repo.

| Script | Event / matcher | Behavior | Exit |
|--------|-----------------|----------|------|
| `session-start-spec.sh` | `SessionStart` | Injects branch context + last 3 `.ai/CHANGELOG.md` sections | 0 |
| `spec-changelog-reminder.sh` | `PostToolUse(Edit\|Write)` on `index.html`/`email.html`/`map/index.html`/`assets/*` | Ship-Commit-Track nudge: site content changed but SPEC/CHANGELOG didn't | 0 |
| `readme-freshness-reminder.sh` | `PostToolUse(Edit\|Write)` on the same site files | Nudge to check `README.md` when the diff touches `data-srcs`, `SITE_URL`, `og:url`, `og-card`, a Drive link, or `mailto:`/`tel:` | 0 |
| `lint-changed-files.sh` | `Stop` | Best-effort markdownlint + `tidy` (HTML) on changed files, if installed | 0 |
| `enforce-worktree.sh` | `PreToolUse(Edit\|Write\|NotebookEdit)` — **global only** | Blocks edits on `main`/`master` | 0 / 2 |

All four repo-native hooks are wired in `.ai/tool-configs/claude/settings.template.json`,
which `.ai/scripts/setup-ai-symlinks.sh` copies to `.claude/settings.json` (gitignored,
generated — never hand-edit `.claude/settings.json` directly).

## Self-healing after checkout/merge/rebase

`.ai/scripts/setup-ai-symlinks.sh` runs `git config core.hooksPath .githooks`, so
`.githooks/post-checkout`, `post-merge`, and `post-rewrite` (all one-liners calling
`.ai/scripts/heal-ai-workspace.sh`) automatically regenerate the gitignored vendor files
(`.claude/settings.json`, `CLAUDE.md`, etc.) after a branch switch, pull, or rebase — no
npm/husky needed, since this repo has no package manager.
