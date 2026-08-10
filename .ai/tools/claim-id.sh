#!/usr/bin/env bash
# claim-id — atomically reserves a SPEC.md ID on main before worktree creation.
#
# This repo has no Node/npm toolchain, so unlike mlb-projections' claim-id.ts
# this is a plain bash port of the same idea: same ID format, same
# reservation-table mechanic, same "commit directly to main" contract.
#
# Usage:
#   .ai/tools/claim-id.sh <prefix> "<task description>"
#   .ai/tools/claim-id.sh --list
#
# Prints the claimed ID (e.g. B-envelope-timing-a3f2) to stdout.
# Side effect: appends a row to the "ID Reservations" table in main's
# .ai/SPEC.md and commits it directly to main.

set -euo pipefail

declare -A PREFIX_REGISTRY=(
  [F]="feature (new page/section/behavior)"
  [B]="bug/fix"
  [C]="content (copy, photo, wording change)"
  [S]="spec/infra (this .ai/ system itself)"
)

usage() {
  local prefixes
  prefixes=$(IFS='|'; echo "${!PREFIX_REGISTRY[*]}")
  echo "Usage: claim-id.sh <${prefixes}> \"<task description>\""
  echo ""
  echo "Prefixes:"
  for k in "${!PREFIX_REGISTRY[@]}"; do
    echo "  $k — ${PREFIX_REGISTRY[$k]}"
  done
}

if [[ "${1:-}" == "--list" || "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

PREFIX="${1:-}"
shift || true
DESCRIPTION="$*"

PREFIX_UPPER=$(echo "$PREFIX" | tr '[:lower:]' '[:upper:]' | xargs)

if [[ -z "$PREFIX_UPPER" || -z "${PREFIX_REGISTRY[$PREFIX_UPPER]+x}" ]]; then
  usage >&2
  exit 1
fi

if [[ -z "$DESCRIPTION" ]]; then
  echo "Error: task description is required" >&2
  exit 1
fi

ROOT=$(git rev-parse --show-toplevel)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
SPEC_PATH="$ROOT/.ai/SPEC.md"

[[ -f "$SPEC_PATH" ]] || { echo "Error: could not read $SPEC_PATH" >&2; exit 1; }

slugify() {
  echo "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9[:space:]-]//g' \
    | sed -E 's/[[:space:]]+/-/g; s/-+/-/g; s/^-|-$//g' | cut -c1-32
}

SLUG=$(slugify "$DESCRIPTION")

random_suffix() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 3
  else
    printf '%06x' "$((RANDOM * RANDOM % 16777216))"
  fi
}

ID=""
for _ in $(seq 1 10); do
  CANDIDATE="${PREFIX_UPPER}-${SLUG}-$(random_suffix)"
  if ! grep -qF "| $CANDIDATE " "$SPEC_PATH"; then
    ID="$CANDIDATE"
    break
  fi
done

[[ -n "$ID" ]] || { echo "Error: could not generate a unique ID after 10 attempts" >&2; exit 1; }

DATE=$(date +%Y-%m-%d)
ROW="| $ID | $DESCRIPTION | $BRANCH | $DATE |"

if ! grep -q '^## ID Reservations' "$SPEC_PATH"; then
  {
    echo ""
    echo "## ID Reservations"
    echo ""
    echo "| ID | Description | Branch | Reserved at |"
    echo "|----|-------------|--------|-------------|"
  } >> "$SPEC_PATH"
fi

# Insert the row right after the reservations table header.
awk -v row="$ROW" '
  { print }
  /^\|----\|-------------\|--------\|-------------\|$/ && !done { print row; done=1 }
' "$SPEC_PATH" > "$SPEC_PATH.tmp" && mv "$SPEC_PATH.tmp" "$SPEC_PATH"

git -C "$ROOT" add .ai/SPEC.md
git -C "$ROOT" commit -m "chore(spec): reserve $ID — ${DESCRIPTION:0:60}" >/dev/null

echo "$ID"
