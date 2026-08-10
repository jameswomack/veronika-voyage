#!/usr/bin/env bash
# .ai/scripts/setup-worktree.sh
#
# Bootstraps a fresh git worktree for this repo. There is still no build step
# (static HTML/CSS/JS, deployed byte-for-byte to GitHub Pages) — npm here is
# only for tiny dev-time tooling (serve, markdownlint-cli2) — so this stays
# much thinner than the equivalent script in framework projects. It wires the
# AI agent symlinks, installs devDependencies, and gets the site previewable.
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

step "Installing devDependencies (serve, markdownlint-cli2)"
if [[ -f "$WORKTREE/package.json" ]] && command -v npm >/dev/null 2>&1; then
  (cd "$WORKTREE" && npm install --prefer-offline 2>&1 | tail -5 | sed 's/^/  /')
  ok "node_modules installed"
else
  echo "  ⚠  npm not found or no package.json — skipping (falls back to global tools / python3)"
fi

echo -e "\n${GREEN}Worktree ready.${NC}"
echo ""
echo "  Preview locally:  cd $WORKTREE && npm run dev      (or: npm start / python3 -m http.server 8989)"
echo "  Open:              http://localhost:3000/           (index.html — the e-vite, via \`serve\`)"
echo "                      http://localhost:3000/map/       (voyage map)"
echo ""
