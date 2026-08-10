#!/usr/bin/env bash
# Re-run AI workspace setup quietly so a branch switch / pull / rebase does not
# leave the workspace stale (regenerates the gitignored vendor symlinks and
# .claude/settings.json, re-marks hooks executable).
# Invoked from .githooks/post-checkout, post-merge, post-rewrite.

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$ROOT" || exit 0
[ -x .ai/scripts/setup-ai-symlinks.sh ] || exit 0

if bash .ai/scripts/setup-ai-symlinks.sh >/dev/null 2>&1; then
  echo "↻ AI workspace synced (.ai symlinks + .claude/settings.json)"
fi
exit 0
