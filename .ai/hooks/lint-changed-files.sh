#!/usr/bin/env bash
# Stop hook: best-effort lint of changed files in the veronika-voyage project.
# Markdown via the repo's pinned node_modules/.bin/markdownlint-cli2 (falls
# back to a global install if node_modules is missing, e.g. before the first
# `npm install`); HTML via tidy if present. Never blocks.

CWD=$(pwd)
[[ "$CWD" != *veronika-voyage* ]] && exit 0

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
cd "$REPO_ROOT" || exit 0

CHANGED=$(git diff --name-only HEAD 2>/dev/null; git ls-files --others --exclude-standard 2>/dev/null)
[[ -z "$CHANGED" ]] && exit 0

MD_FILES=$(echo "$CHANGED" | grep -E '\.md$' || true)
HTML_FILES=$(echo "$CHANGED" | grep -E '\.html$' || true)

ISSUES=""

if [[ -n "$MD_FILES" ]] && [[ -x "$REPO_ROOT/node_modules/.bin/markdownlint-cli2" ]]; then
  MD_OUT=$(echo "$MD_FILES" | xargs "$REPO_ROOT/node_modules/.bin/markdownlint-cli2" 2>&1) || ISSUES+="$MD_OUT"$'\n'
elif [[ -n "$MD_FILES" ]] && command -v markdownlint-cli2 >/dev/null 2>&1; then
  MD_OUT=$(echo "$MD_FILES" | xargs markdownlint-cli2 2>&1) || ISSUES+="$MD_OUT"$'\n'
fi

if [[ -n "$HTML_FILES" ]] && command -v tidy >/dev/null 2>&1; then
  for f in $HTML_FILES; do
    [[ -f "$f" ]] || continue
    TIDY_OUT=$(tidy -q -errors --show-warnings no "$f" 2>&1) || ISSUES+="$f:"$'\n'"$TIDY_OUT"$'\n'
  done
fi

if [[ -n "$ISSUES" ]]; then
  echo "Lint issues in changed files:" >&2
  echo "$ISSUES" >&2
fi

exit 0
