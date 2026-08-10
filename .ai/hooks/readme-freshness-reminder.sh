#!/usr/bin/env bash
# PostToolUse(Edit|Write): README.md documents the file layout, the Drive
# photo IDs, SITE_URL replacement, and personalization params. When a change
# touches something README.md describes but leaves README.md itself
# untouched, nudge a review. Advisory only — always exits 0, never blocks.
# See .ai/workflows/readme-maintenance.md for the policy this enforces.

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

# Only fire for files whose content README.md specifically documents.
case "$FILE_PATH" in
  */index.html|*/email.html|*/map/index.html) ;;
  */assets/*) ;;
  *) exit 0 ;;
esac

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0

# Only nudge if the edited content plausibly affects something README.md
# claims: data-srcs / SITE_URL / og-card / photo IDs / RSVP contact info.
CHANGED_HUNK=$(git -C "$REPO_ROOT" diff -- "$FILE_PATH" 2>/dev/null)
if echo "$CHANGED_HUNK" | grep -qiE 'data-srcs|SITE_URL|og:url|og-card|drive\.google|mailto:|tel:'; then
  if ! git -C "$REPO_ROOT" status --porcelain -- README.md 2>/dev/null | grep -q .; then
    echo "REMINDER: this edit touches something README.md documents (photo sources, SITE_URL, RSVP contact, or the OG card) — check README.md is still accurate. See .ai/workflows/readme-maintenance.md." >&2
  fi
fi

exit 0
