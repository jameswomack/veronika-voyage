#!/usr/bin/env bash
# Blocks file edits on main/master — all code changes must happen in a worktree.
# Exit 0 = allow. Exit 2 = block with message to Claude.

# Read tool input from stdin (Claude Code passes it as JSON)
TOOL_INPUT=$(cat)

# Not a git repo — nothing to enforce
git rev-parse --is-inside-work-tree &>/dev/null || exit 0

# Per-repo exemptions: repos that opt out of the worktree policy (edit main directly)
REPO_TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
REPO_NAME=$(basename "$REPO_TOPLEVEL")
EXEMPT_REPOS=("intuit-interview")
for exempt in "${EXEMPT_REPOS[@]}"; do
  if [[ "$REPO_NAME" == "$exempt" ]]; then
    exit 0
  fi
done

# If the tool input contains a file_path inside a worktree on a non-main branch,
# allow it — the subagent CWD may be main but the target file is in a worktree.
if command -v python3 &>/dev/null && [[ -n "$TOOL_INPUT" ]]; then
  FILE_PATH=$(python3 -c "
import json, sys
try:
  data = json.loads(sys.stdin.read())
  # Claude Code wraps tool params under 'tool_input'; fall back to top-level for direct calls
  inner = data.get('tool_input') or data
  fp = inner.get('file_path') or inner.get('path') or ''
  print(fp)
except Exception:
  print('')
" <<< "$TOOL_INPUT" 2>/dev/null)
  if [[ -n "$FILE_PATH" ]]; then
    FILE_DIR=$(dirname "$FILE_PATH")
    while [[ -n "$FILE_DIR" && ! -d "$FILE_DIR" && "$FILE_DIR" != "/" ]]; do
      FILE_DIR=$(dirname "$FILE_DIR")
    done
    if [[ -d "$FILE_DIR" ]]; then
      FILE_TOPLEVEL=$(git -C "$FILE_DIR" rev-parse --show-toplevel 2>/dev/null)
      CWD_TOPLEVEL=$(git rev-parse --show-toplevel 2>/dev/null)
      # Allow: file outside any git repo, or in a different repo than CWD
      if [[ -z "$FILE_TOPLEVEL" || "$FILE_TOPLEVEL" != "$CWD_TOPLEVEL" ]]; then
        exit 0
      fi
      # Allow writes to gitignored files (e.g. .claude/settings.json, .env)
      if git -C "$FILE_DIR" check-ignore -q "$FILE_PATH" 2>/dev/null; then
        exit 0
      fi

      FILE_BRANCH=$(git -C "$FILE_DIR" rev-parse --abbrev-ref HEAD 2>/dev/null)
      if [[ -n "$FILE_BRANCH" && "$FILE_BRANCH" != "main" && "$FILE_BRANCH" != "master" ]]; then
        exit 0
      fi
    fi
  fi
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  cat >&2 <<'MSG'
WORKTREE POLICY VIOLATION: You are attempting to edit files on the protected branch.

MANDATORY WORKFLOW — follow these steps before making any code change:
1. Derive a short kebab-case branch name from the task (e.g. fix-search-timeout)
2. Run: git worktree add ../<repo>-worktrees/<branch> -b <branch>
3. cd into the new worktree directory
4. Do ALL work there
5. When the user confirms the work is tested and good:
   a. git commit (if anything uncommitted)
   b. cd back to the main repo
   c. git merge --no-ff <branch>
   d. git worktree remove ../<repo>-worktrees/<branch>
   e. git branch -d <branch>
6. The cycle then restarts fresh on the next task

DO NOT edit files on main/master under any circumstance.
MSG
  exit 2
fi

exit 0
