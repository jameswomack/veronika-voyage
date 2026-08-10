#!/usr/bin/env bash
# Setup or repair AI agent symlinks for this repo.
#
# These symlinks (CLAUDE.md, .claude/settings.json, etc.) are COMMITTED to git,
# not gitignored — this repo has no package manager / postinstall step to
# regenerate them automatically, so the committed symlinks themselves are what
# guarantees Superpowers + repo hooks activate for every collaborator on every
# machine straight from `git clone`, with no setup step required.
#
# Re-running this script is still useful after adding a new agent/tool-config,
# or to repair a symlink that got clobbered by an editor/tool that doesn't
# preserve symlinks (e.g. some GUI git clients, or a raw zip re-upload).

set -e

ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || { echo "Not inside a git repo" >&2; exit 1; }
cd "$ROOT"

echo "🔧 Setting up AI agent symlinks..."

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

setup_symlink() {
    local link_path=$1
    local target=$2
    local description=$3

    if [ -d "$link_path" ] && [ ! -L "$link_path" ]; then
        echo -e "${YELLOW}⚠${NC}  Removing existing directory $link_path"
        rm -rf "$link_path"
    elif [ -e "$link_path" ] || [ -L "$link_path" ]; then
        echo -e "${YELLOW}⚠${NC}  Removing existing $link_path"
        rm -f "$link_path"
    fi

    mkdir -p "$(dirname "$link_path")"
    ln -s "$target" "$link_path"
    echo -e "${GREEN}✓${NC} Created $description: $link_path → $target"
}

echo ""
setup_symlink "CLAUDE.md" ".ai/shared/repo-context.md" "Claude context"
setup_symlink "AGENTS.md" ".ai/shared/repo-context.md" "Codex/cross-vendor context"
setup_symlink "GEMINI.md" ".ai/tool-configs/gemini-context.md" "Gemini context"
setup_symlink ".cursorrules" ".ai/tool-configs/cursor-rules.md" "Cursor rules"
setup_symlink ".augment/rules/project-context.md" "../../.ai/tool-configs/augment-rules.md" "Augment rules"
setup_symlink ".claude/skills" "../.ai/skills" "Claude Code skills"
setup_symlink ".claude/agents" "../.ai/agents" "Claude Code agents"
setup_symlink ".claude/settings.json" "../.ai/tool-configs/claude/settings.template.json" "Claude settings (enables Superpowers + repo hooks)"

# Replace Augment agent files with symlinks to shared source
echo ""
echo "Setting up Augment agent symlinks..."
mkdir -p .augment/agents
if [ -d ".ai/agents" ]; then
    for agent_file in .ai/agents/*.md; do
        [ -e "$agent_file" ] || continue
        agent_name=$(basename "$agent_file")
        [ "$agent_name" = "README.md" ] && continue
        setup_symlink ".augment/agents/$agent_name" "../../.ai/agents/$agent_name" "Augment agent: $agent_name"
    done
fi

SUPERPOWERS_MANIFEST=".ai/tool-configs/claude/superpowers.manifest.json"

# Ensure vendored hook scripts and tools are executable
if [ -d ".ai/hooks" ]; then
    chmod +x .ai/hooks/*.sh 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Marked .ai/hooks/*.sh executable"
fi
if [ -d ".ai/tools" ]; then
    chmod +x .ai/tools/*.sh 2>/dev/null || true
fi
if [ -d ".ai/scripts" ]; then
    chmod +x .ai/scripts/*.sh 2>/dev/null || true
fi

# Verify the installed Superpowers plugin matches the pinned version
if [ -f "$SUPERPOWERS_MANIFEST" ] && command -v jq >/dev/null 2>&1; then
    PIN_VER=$(jq -r '.version' "$SUPERPOWERS_MANIFEST")
    INSTALLED="$HOME/.claude/plugins/cache/claude-plugins-official/superpowers/$PIN_VER"
    if [ -d "$INSTALLED" ]; then
        echo -e "${GREEN}✓${NC} Superpowers $PIN_VER is installed"
    else
        echo -e "${YELLOW}⚠${NC}  Superpowers $PIN_VER not found. Install with:"
        echo "      claude plugin install superpowers@claude-plugins-official"
    fi
fi

# enforce-worktree is a GLOBAL cross-repo hook; warn if it is not active
USER_SETTINGS="$HOME/.claude/settings.json"
if [ -f "$USER_SETTINGS" ] && ! grep -q "enforce-worktree" "$USER_SETTINGS"; then
    echo -e "${YELLOW}⚠${NC}  Worktree enforcement is NOT active in $USER_SETTINGS."
    echo "      This repo keeps a reference copy at .ai/hooks/enforce-worktree.sh but does"
    echo "      not wire it (it must protect ALL your repos). Add to $USER_SETTINGS hooks:"
    echo '        PreToolUse matcher "Edit|Write|NotebookEdit" ->'
    echo "          bash \"\$HOME/.claude/scripts/enforce-worktree.sh\""
    echo "      See .ai/workflows/worktree.md for the exact snippet."
fi

# Route git hooks (post-checkout/post-merge/post-rewrite) through the
# committed .githooks/ dir so a branch switch / pull / rebase self-heals
# this workspace without needing npm/husky.
if [ -d ".githooks" ]; then
    git config core.hooksPath .githooks
    chmod +x .githooks/* 2>/dev/null || true
    echo -e "${GREEN}✓${NC} Wired .githooks/ (core.hooksPath) for auto-heal on checkout/merge/rebase"
fi

# --- Personal (gitignored) files for linked worktrees ---
# When run inside a linked worktree, copy gitignored personal files from the
# main worktree if missing. Most important: .claude/settings.local.json — the
# permission allow-list. Without it a worktree session prompts on every tool call.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
   && GIT_DIR=$(cd "$(git rev-parse --git-dir)" && pwd -P) \
   && GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" && pwd -P) \
   && [ "$GIT_DIR" != "$GIT_COMMON" ]; then
    MAIN_ROOT=$(git -C "$GIT_COMMON/.." rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$MAIN_ROOT" ] && [ "$MAIN_ROOT" != "$(pwd -P)" ]; then
        echo ""
        echo "Provisioning personal (gitignored) files from main worktree..."
        if [ ! -f ".claude/settings.local.json" ] && [ -f "$MAIN_ROOT/.claude/settings.local.json" ]; then
            mkdir -p .claude
            cp "$MAIN_ROOT/.claude/settings.local.json" ".claude/settings.local.json"
            echo -e "${GREEN}✓${NC} Copied .claude/settings.local.json (permission allow-list)"
        fi
    fi
fi

echo ""
echo -e "${GREEN}✓ All AI agent symlinks configured successfully!${NC}"
echo ""
echo "Symlink structure:"
echo "  CLAUDE.md → .ai/shared/repo-context.md"
echo "  AGENTS.md → .ai/shared/repo-context.md"
echo "  GEMINI.md → .ai/tool-configs/gemini-context.md"
echo "  .cursorrules → .ai/tool-configs/cursor-rules.md"
echo "  .augment/rules/project-context.md → ../.ai/tool-configs/augment-rules.md"
echo "  .claude/skills → .ai/skills"
echo "  .claude/agents → .ai/agents"
echo "  .augment/agents/*.md → .ai/agents/*.md"
echo "  .claude/settings.json → .ai/tool-configs/claude/settings.template.json"
echo "  .ai/hooks/*.sh (executable; wired via settings, enforce-worktree global)"
echo ""
echo "All of the above are COMMITTED symlinks — a plain git clone is enough."
echo "Only .claude/settings.local.json (personal permission allow-list) stays local."
