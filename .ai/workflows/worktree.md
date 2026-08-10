# Worktree Workflow

Every code change happens in a sibling worktree on its own branch. `main` is never edited
directly — it's what GitHub Pages serves live, so treat it as production even though this
is a small static site.

## Start

1. Derive a short kebab-case branch name (e.g. `fix-envelope-timing`), or claim a tracked
   ID first: `.ai/scripts/claim-spec-id.sh <F|B|C|S> "<description>"` and use the returned
   ID as the branch name.
2. From the main repo root:
   `git worktree add ../veronika-voyage-worktrees/<branch> -b <branch>`
3. `cd` into the worktree and run `bash .ai/scripts/setup-worktree.sh` (wires the AI
   symlinks — which are also committed, so this is a repair/convenience step, not a
   requirement — and runs `npm install` for the devDependencies: `serve`,
   `markdownlint-cli2`). Or just `.ai/scripts/setup-ai-symlinks.sh` if you don't need
   `npm install`.
4. Do all edits, commits, and tests in the worktree.

## Personal files in worktrees (automatic)

Gitignored personal files do not exist in a fresh worktree — most importantly
`.claude/settings.local.json` (the permission allow-list). Without it, the worktree
session loses every pre-approved permission and prompts on each tool call.

`.ai/scripts/setup-ai-symlinks.sh`, run inside a linked worktree, auto-copies
`.claude/settings.local.json` from the main worktree if missing. Always run it right
after `git worktree add`. (Claude Code may need a session restart in the worktree to pick
up a newly copied `settings.local.json`.)

## Preview locally

```shell
npm run dev                      # serve -s . (http://localhost:3000/)
# or, no npm install needed:
npm start                        # python3 -m http.server 8989 (http://[::]:8989/)
```

Either way: `/` is `index.html` (the e-vite), `/map/` is the voyage map.

## Finish (after the user confirms tested and good)

1. Final commit in the worktree.
2. From the main repo: `git merge --no-ff <branch>`
3. `git worktree remove ../veronika-voyage-worktrees/<branch>`
4. `git branch -d <branch>`

## Enforcement (global hook — activate on your machine)

`enforce-worktree` blocks `Edit`/`Write`/`NotebookEdit` on `main`/`master` (exit 2). It is
a CROSS-REPO policy, so it lives in your global `~/.claude/settings.json`, NOT in this
repo's settings. The repo keeps a reference copy at `.ai/hooks/enforce-worktree.sh`.

Activate it by adding to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$HOME/.claude/scripts/enforce-worktree.sh\""
          }
        ]
      }
    ]
  }
}
```

`.ai/scripts/setup-ai-symlinks.sh` warns if this is not present.
