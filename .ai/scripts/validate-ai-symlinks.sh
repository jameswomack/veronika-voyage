#!/usr/bin/env bash
# Validate that all AI agent symlinks are correctly configured.
# Run manually, or wire into a pre-commit hook, to catch drift.

set -e

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not inside a git repo" >&2; exit 1; }
cd "$ROOT"

echo "🔍 Validating AI agent symlinks..."

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

ERRORS=0

check_symlink() {
    local link_path=$1
    local expected_target=$2
    local description=$3

    if [ ! -L "$link_path" ]; then
        echo -e "${RED}✗${NC} $description: $link_path is not a symlink"
        ERRORS=$((ERRORS + 1))
        return 1
    fi

    actual_target=$(readlink "$link_path")
    if [ "$actual_target" != "$expected_target" ]; then
        echo -e "${RED}✗${NC} $description: $link_path points to $actual_target (expected $expected_target)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi

    if [ ! -e "$link_path" ]; then
        echo -e "${RED}✗${NC} $description: $link_path is a broken symlink (target doesn't exist)"
        ERRORS=$((ERRORS + 1))
        return 1
    fi

    echo -e "${GREEN}✓${NC} $description: $link_path → $expected_target"
    return 0
}

echo ""
echo "Checking agent-specific symlinks..."

check_symlink "CLAUDE.md" ".ai/shared/repo-context.md" "Claude context"
check_symlink "AGENTS.md" ".ai/shared/repo-context.md" "Codex/cross-vendor context"
check_symlink "GEMINI.md" ".ai/tool-configs/gemini-context.md" "Gemini context"
check_symlink ".cursorrules" ".ai/tool-configs/cursor-rules.md" "Cursor rules"
check_symlink ".augment/rules/project-context.md" "../../.ai/tool-configs/augment-rules.md" "Augment rules"
check_symlink ".claude/skills" "../.ai/skills" "Claude Code skills"
check_symlink ".claude/agents" "../.ai/agents" "Claude Code agents"

echo ""
echo "Checking agent symlinks..."

if [ -d ".augment/agents" ]; then
    for agent_file in .ai/agents/*.md; do
        [ -e "$agent_file" ] || continue
        agent_name=$(basename "$agent_file")
        [ "$agent_name" = "README.md" ] && continue
        check_symlink ".augment/agents/$agent_name" "../../.ai/agents/$agent_name" "Augment agent: $agent_name"
    done
fi

echo ""
echo "Checking that target files exist..."

TARGETS=(
    ".ai/shared/repo-context.md"
    ".ai/tool-configs/gemini-context.md"
    ".ai/tool-configs/cursor-rules.md"
    ".ai/tool-configs/augment-rules.md"
)

for target in "${TARGETS[@]}"; do
    if [ ! -f "$target" ]; then
        echo -e "${RED}✗${NC} Target file missing: $target"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} Target exists: $target"
    fi
done

echo ""
echo "Checking Claude settings + hooks..."

CLAUDE_SETTINGS_TEMPLATE=".ai/tool-configs/claude/settings.template.json"
CLAUDE_SETTINGS_OUT=".claude/settings.json"

if [ ! -f "$CLAUDE_SETTINGS_TEMPLATE" ]; then
    echo -e "${RED}✗${NC} Missing $CLAUDE_SETTINGS_TEMPLATE"
    ERRORS=$((ERRORS + 1))
elif [ ! -f "$CLAUDE_SETTINGS_OUT" ]; then
    echo -e "${RED}✗${NC} Missing $CLAUDE_SETTINGS_OUT (run .ai/scripts/setup-ai-symlinks.sh)"
    ERRORS=$((ERRORS + 1))
elif ! diff -q "$CLAUDE_SETTINGS_TEMPLATE" "$CLAUDE_SETTINGS_OUT" >/dev/null; then
    echo -e "${RED}✗${NC} $CLAUDE_SETTINGS_OUT has drifted from the template (run setup to regenerate)"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓${NC} $CLAUDE_SETTINGS_OUT in sync with template"
fi

for h in session-start-spec spec-changelog-reminder readme-freshness-reminder lint-changed-files enforce-worktree; do
    if [ ! -x ".ai/hooks/$h.sh" ]; then
        echo -e "${RED}✗${NC} Hook missing or not executable: .ai/hooks/$h.sh"
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓${NC} Hook present: .ai/hooks/$h.sh"
    fi
done

echo ""
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All AI agent symlinks are correctly configured!${NC}"
    exit 0
else
    echo -e "${RED}✗ Found $ERRORS error(s) in AI agent symlink configuration${NC}"
    echo ""
    echo "To fix symlinks, run:"
    echo "  .ai/scripts/setup-ai-symlinks.sh"
    exit 1
fi
