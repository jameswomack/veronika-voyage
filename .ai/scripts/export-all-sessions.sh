#!/bin/bash
# Export all AI agent sessions to .ai/session-history/
# Usage: ./scripts/export-all-sessions.sh

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  AI Agent Session History Exporter                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

BASE_DIR=".ai/session-history"

# Create base directory structure
mkdir -p "$BASE_DIR"/{augment,codex,cursor,gemini,claude,manual}

echo -e "${BLUE}📁 Created directory structure:${NC}"
echo "  $BASE_DIR/"
echo "    ├── augment/"
echo "    ├── codex/"
echo "    ├── cursor/"
echo "    ├── gemini/"
echo "    ├── claude/"
echo "    └── manual/"
echo ""

# Export Augment sessions
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}1. Exporting Augment sessions...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -f "./scripts/export-augment-sessions.sh" ]; then
    ./scripts/export-augment-sessions.sh "$BASE_DIR/augment" || echo -e "${YELLOW}⚠ Augment export failed${NC}"
else
    echo -e "${YELLOW}⚠ export-augment-sessions.sh not found${NC}"
fi
echo ""

# Export Codex sessions
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}2. Exporting Codex sessions...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [ -f "./scripts/export-codex-sessions.sh" ]; then
    ./scripts/export-codex-sessions.sh "$BASE_DIR/codex" || echo -e "${YELLOW}⚠ Codex export failed${NC}"
else
    echo -e "${YELLOW}⚠ export-codex-sessions.sh not found${NC}"
fi
echo ""

# Cursor sessions (manual)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}3. Cursor sessions${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}ℹ Cursor sessions must be exported manually via the Cursor IDE${NC}"
echo -e "  Directory: $BASE_DIR/cursor/"
echo ""

# Gemini sessions (manual)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}4. Gemini sessions${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}ℹ Gemini sessions must be exported manually from Google AI Studio${NC}"
echo -e "  Directory: $BASE_DIR/gemini/"
echo ""

# Claude sessions (manual)
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}5. Claude sessions${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}ℹ Claude sessions must be exported manually from Claude.ai${NC}"
echo -e "  Directory: $BASE_DIR/claude/"
echo ""

# Summary
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║  Export Summary                                        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Count exported files
augment_count=$(find "$BASE_DIR/augment" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
codex_count=$(find "$BASE_DIR/codex" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
cursor_count=$(find "$BASE_DIR/cursor" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
gemini_count=$(find "$BASE_DIR/gemini" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
claude_count=$(find "$BASE_DIR/claude" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
manual_count=$(find "$BASE_DIR/manual" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

total_count=$((augment_count + codex_count + cursor_count + gemini_count + claude_count + manual_count))

echo -e "  Augment:  ${GREEN}$augment_count${NC} sessions"
echo -e "  Codex:    ${GREEN}$codex_count${NC} sessions"
echo -e "  Cursor:   ${GREEN}$cursor_count${NC} sessions"
echo -e "  Gemini:   ${GREEN}$gemini_count${NC} sessions"
echo -e "  Claude:   ${GREEN}$claude_count${NC} sessions"
echo -e "  Manual:   ${GREEN}$manual_count${NC} sessions"
echo ""
echo -e "  ${CYAN}Total:    ${GREEN}$total_count${NC} sessions"
echo ""

echo -e "${GREEN}✓ Session export complete!${NC}"
echo ""
echo -e "${BLUE}📖 Next steps:${NC}"
echo "  1. Review exported sessions in $BASE_DIR/"
echo "  2. Manually export Cursor/Gemini/Claude sessions if needed"
echo "  3. Add summaries and metadata to session files"
echo "  4. Commit to version control"
echo ""
echo -e "${BLUE}📚 Documentation:${NC}"
echo "  - $BASE_DIR/README.md"
echo "  - .ai/README.md"

