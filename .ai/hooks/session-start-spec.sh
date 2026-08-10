#!/usr/bin/env bash
# SessionStart: print branch context + the most recent CHANGELOG entries so
# each session begins grounded in current project state.

CWD=$(pwd)
[[ "$CWD" != *veronika-voyage* ]] && exit 0

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
CHANGELOG="$REPO_ROOT/.ai/CHANGELOG.md"
[[ ! -f "$CHANGELOG" ]] && exit 0

BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [[ -n "$BRANCH" ]]; then
  DIRTY=$(git status --porcelain 2>/dev/null | grep -c .)
  echo "── Branch: $BRANCH ($DIRTY uncommitted file(s)) ──"
fi

echo "── Recent .ai/CHANGELOG.md entries ──"
awk '
  /^##+ / {
    count++
    if (count > 3) exit
  }
  count >= 1 && count <= 3 { print }
' "$CHANGELOG" | head -80
echo "──────────────────────────────────"

exit 0
