#!/usr/bin/env bash
# PostToolUse(Edit|Write): when a site page is changed but .ai/SPEC.md and
# .ai/CHANGELOG.md are untouched in the working tree, remind about
# Ship-Commit-Track. Advisory only — always exits 0, never blocks.

INPUT=$(cat)

FILE_PATH=$(python3 -c "
import json, sys
try:
  d = json.loads(sys.stdin.read())
  inner = d.get('tool_input') or d
  print(inner.get('file_path') or inner.get('path') or '')
except Exception:
  print('')
" <<< "$INPUT" 2>/dev/null)

[[ -z "$FILE_PATH" ]] && exit 0

# Only fire for the actual site pages, not .ai/ content or docs.
case "$FILE_PATH" in
  */index.html|*/email.html|*/map/index.html|*/assets/*) ;;
  *) exit 0 ;;
esac

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

if ! git -C "$REPO_ROOT" status --porcelain -- .ai/SPEC.md .ai/CHANGELOG.md 2>/dev/null | grep -q .; then
  echo "REMINDER (Ship-Commit-Track): site content changed but .ai/SPEC.md and .ai/CHANGELOG.md are unmodified — update them in this unit of work before committing." >&2
fi

exit 0
