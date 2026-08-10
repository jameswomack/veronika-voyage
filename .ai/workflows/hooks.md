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

All four repo-native hooks are wired in `.ai/tool-configs/claude/settings.template.json`.
`.claude/settings.json` is a **committed symlink** to that file (not a gitignored copy) —
this repo has no package manager / postinstall step to regenerate it, so committing the
symlink is what guarantees Superpowers and these hooks are active for every collaborator,
on every machine, straight from `git clone`. Never hand-edit `.claude/settings.json`;
edit `.ai/tool-configs/claude/settings.template.json` instead — the symlink picks it up
automatically, no regeneration step needed.

## Self-healing after checkout/merge/rebase

The committed symlinks (`CLAUDE.md`, `.claude/settings.json`, etc.) travel with `git
clone`/`checkout` on their own — no script needed for the common case. `.ai/scripts/
setup-ai-symlinks.sh` still exists to (re)create them if one gets clobbered by a tool
that doesn't preserve symlinks, and it runs `git config core.hooksPath .githooks` so
`.githooks/post-checkout`, `post-merge`, and `post-rewrite` (all one-liners calling
`.ai/scripts/heal-ai-workspace.sh`) repair them automatically after a branch switch,
pull, or rebase — no npm/husky needed, since this repo has no package manager.
