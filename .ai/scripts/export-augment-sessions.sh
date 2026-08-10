#!/bin/bash
# Export Augment chat sessions to readable markdown files
# Usage: ./scripts/export-augment-sessions.sh [output_dir]

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default output directory
OUTPUT_DIR="${1:-.ai/chat-history}"

# Augment sessions directory
SESSIONS_DIR="$HOME/.augment/sessions"

echo -e "${BLUE}🔍 Augment Session Exporter${NC}"
echo ""

# Check if sessions directory exists
if [ ! -d "$SESSIONS_DIR" ]; then
    echo -e "${YELLOW}⚠ No Augment sessions found at $SESSIONS_DIR${NC}"
    exit 1
fi

# Count sessions
SESSION_COUNT=$(ls -1 "$SESSIONS_DIR"/*.json 2>/dev/null | wc -l | tr -d ' ')

if [ "$SESSION_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No session files found${NC}"
    exit 1
fi

echo -e "Found ${GREEN}$SESSION_COUNT${NC} session(s)"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Export each session
for session_file in "$SESSIONS_DIR"/*.json; do
    session_id=$(basename "$session_file" .json)
    output_file="$OUTPUT_DIR/${session_id}.md"
    
    echo -e "Exporting session ${BLUE}$session_id${NC}..."
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠ jq not installed - copying raw JSON${NC}"
        cp "$session_file" "$OUTPUT_DIR/${session_id}.json"
        continue
    fi
    
    # Extract session metadata and messages
    {
        echo "# Augment Chat Session"
        echo ""
        echo "**Session ID:** $session_id"
        echo "**File:** $session_file"
        echo "**Exported:** $(date)"
        echo ""
        
        # Try to extract workspace info
        workspace=$(jq -r '.workspace // "Unknown"' "$session_file" 2>/dev/null)
        echo "**Workspace:** $workspace"
        echo ""
        
        # Try to extract created/modified dates
        created=$(jq -r '.created // "Unknown"' "$session_file" 2>/dev/null)
        modified=$(jq -r '.modified // "Unknown"' "$session_file" 2>/dev/null)
        echo "**Created:** $created"
        echo "**Modified:** $modified"
        echo ""
        
        echo "---"
        echo ""
        
        # Extract messages (structure may vary)
        # This is a best-effort extraction - adjust based on actual JSON structure
        jq -r '
            if .messages then
                .messages[] | 
                "## \(.role // "Unknown Role")\n\n\(.content // .text // "No content")\n\n---\n"
            elif .turns then
                .turns[] |
                "## Turn \(.index // "?")\n\n**Request:**\n\(.request.content // "No request")\n\n**Response:**\n\(.response.content // "No response")\n\n---\n"
            else
                "Unable to parse session structure. See raw JSON file.\n"
            end
        ' "$session_file" 2>/dev/null || echo "Unable to parse messages. See raw JSON: $OUTPUT_DIR/${session_id}.json"
        
    } > "$output_file"
    
    # Also save raw JSON for reference
    cp "$session_file" "$OUTPUT_DIR/${session_id}.json"
    
    echo -e "  ✓ Markdown: ${GREEN}$output_file${NC}"
    echo -e "  ✓ JSON: ${GREEN}$OUTPUT_DIR/${session_id}.json${NC}"
done

echo ""
echo -e "${GREEN}✓ Exported $SESSION_COUNT session(s) to $OUTPUT_DIR${NC}"
echo ""
echo "Files created:"
echo "  - *.md - Human-readable markdown format"
echo "  - *.json - Raw JSON data"

