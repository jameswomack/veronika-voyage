#!/usr/bin/env bash
# .ai/scripts/setup-worktree.sh
#
# Bootstraps a fresh git worktree for this repo. There is no build step and
# no npm/Prisma here (static HTML/CSS/JS), so this is much thinner than the
# equivalent script in framework projects — it exists mainly to wire the AI
# agent symlinks and preview the site immediately.
#
# Usage (from the MAIN repo root, after git worktree add):
#   bash .ai/scripts/setup-worktree.sh <worktree-path>
#
# Or from INSIDE the worktree root (no argument needed):
#   bash .ai/scripts/setup-worktree.sh

set -euo pipefail

if [[ $# -ge 1 ]]; then
  WORKTREE="$(cd "$1" && pwd)"
else
  WORKTREE="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
fi

MAIN="$(cd "$(git -C "$WORKTREE" rev-parse --git-common-dir)/.." && pwd)"

if [[ "$MAIN" == "$WORKTREE" ]]; then
  echo "ERROR: You appear to be running this from the main repo, not a worktree." >&2
  echo "       Pass the worktree path as an argument: bash .ai/scripts/setup-worktree.sh <path>" >&2
  exit 1
fi

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

step() { echo -e "\n${CYAN}▸ $*${NC}"; }
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }

BRANCH="$(git -C "$WORKTREE" branch --show-current 2>/dev/null || echo 'unknown')"
echo -e "\n${CYAN}Setting up worktree: ${WORKTREE}${NC}"
echo -e "${CYAN}Branch: ${BRANCH}${NC}"
echo -e "${CYAN}Main repo: ${MAIN}${NC}"

step "Wiring AI agent symlinks"
(cd "$WORKTREE" && bash .ai/scripts/setup-ai-symlinks.sh 2>&1 | grep -E "✓|⚠" | sed 's/^/  /')

echo -e "\n${GREEN}Worktree ready.${NC}"
echo ""
echo "  Preview locally:  cd $WORKTREE && python3 -m http.server 8989"
echo "  Open:              http://[::]:8989/            (index.html — the e-vite)"
echo "                      http://[::]:8989/map/        (voyage map)"
echo ""
