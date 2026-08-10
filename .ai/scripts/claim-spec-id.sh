#!/usr/bin/env bash
# claim-spec-id — reserve a SPEC.md ID on main before creating a worktree.
#
# Usage:
#   .ai/scripts/claim-spec-id.sh <F|B|C|S> "<task description>"
#
# Prefixes: F feature · B bug/fix · C content · S spec/infra
# Run `.ai/scripts/claim-spec-id.sh --list` for the authoritative registry.
#
# Prints the claimed ID (e.g. B-envelope-timing-a3f2) to stdout.
# Use that ID as both the SPEC identifier and the worktree branch name:
#
#   ID=$(.ai/scripts/claim-spec-id.sh B "envelope opens too fast on mobile")
#   git worktree add ../veronika-voyage-worktrees/$ID -b $ID
#
# NOTE: This script modifies .ai/SPEC.md on main directly (via absolute path)
# and commits it. It is intentionally exempt from the enforce-worktree.sh
# PreToolUse hook, which only blocks the Edit/Write tools — not Bash commands.
# The reservation commit must land on main before the worktree is created so
# the claimed ID is visible to all parallel agents immediately.

set -euo pipefail

AI_DIR="$(cd "$(dirname "$0")/.." && pwd)"
exec bash "$AI_DIR/tools/claim-id.sh" "$@"
