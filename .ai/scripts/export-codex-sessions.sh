#!/bin/bash
# Export Codex chat sessions to readable markdown files
# Usage: ./scripts/export-codex-sessions.sh [output_dir]

set -e

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default output directory
OUTPUT_DIR="${1:-.ai/session-history/codex}"

# Codex sessions directory
SESSIONS_DIR="$HOME/.codex/sessions"

echo -e "${BLUE}🔍 Codex Session Exporter${NC}"
echo ""

# Check if sessions directory exists
if [ ! -d "$SESSIONS_DIR" ]; then
    echo -e "${YELLOW}⚠ No Codex sessions found at $SESSIONS_DIR${NC}"
    exit 1
fi

# Count sessions (recursively)
SESSION_COUNT=$(find "$SESSIONS_DIR" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')

if [ "$SESSION_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}⚠ No session files found${NC}"
    exit 1
fi

echo -e "Found ${GREEN}$SESSION_COUNT${NC} session(s)"
echo ""

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Export each session
find "$SESSIONS_DIR" -name "*.json" | while read session_file; do
    # Extract date from path (e.g., 2026/01/09)
    session_date=$(echo "$session_file" | grep -oE '[0-9]{4}/[0-9]{2}/[0-9]{2}' | tr '/' '-' || echo "unknown-date")
    
    # Get filename without extension
    filename=$(basename "$session_file" .json)
    
    # Create output filename
    if [ "$session_date" != "unknown-date" ]; then
        output_file="$OUTPUT_DIR/${session_date}-${filename}.md"
    else
        output_file="$OUTPUT_DIR/${filename}.md"
    fi
    
    echo -e "Exporting session ${BLUE}$filename${NC}..."
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo -e "${YELLOW}⚠ jq not installed - copying raw JSON${NC}"
        cp "$session_file" "$OUTPUT_DIR/${filename}.json"
        continue
    fi
    
    # Extract session metadata and messages
    {
        echo "# Codex Chat Session"
        echo ""
        echo "**Session File:** $filename"
        echo "**Date:** $session_date"
        echo "**Source:** $session_file"
        echo "**Exported:** $(date)"
        echo ""
        
        # Try to extract workspace/project info
        workspace=$(jq -r '.workspace // .project // "Unknown"' "$session_file" 2>/dev/null)
        echo "**Workspace:** $workspace"
        echo ""
        
        # Try to extract created/modified dates
        created=$(jq -r '.created // .createdAt // "Unknown"' "$session_file" 2>/dev/null)
        modified=$(jq -r '.modified // .updatedAt // "Unknown"' "$session_file" 2>/dev/null)
        echo "**Created:** $created"
        echo "**Modified:** $modified"
        echo ""
        
        echo "---"
        echo ""
        
        # Extract messages (structure may vary)
        jq -r '
            if .messages then
                .messages[] | 
                "## \(.role // "Unknown Role")\n\n\(.content // .text // "No content")\n\n---\n"
            elif .history then
                .history[] |
                "## \(.role // "Unknown Role")\n\n\(.content // .text // "No content")\n\n---\n"
            elif .turns then
                .turns[] |
                "## Turn \(.index // "?")\n\n**Request:**\n\(.request.content // "No request")\n\n**Response:**\n\(.response.content // "No response")\n\n---\n"
            else
                "Unable to parse session structure. See raw JSON file.\n"
            end
        ' "$session_file" 2>/dev/null || echo "Unable to parse messages. See raw JSON: $OUTPUT_DIR/${filename}.json"
        
    } > "$output_file"
    
    # Also save raw JSON for reference
    cp "$session_file" "$OUTPUT_DIR/${filename}.json"
    
    echo -e "  ✓ Markdown: ${GREEN}$output_file${NC}"
    echo -e "  ✓ JSON: ${GREEN}$OUTPUT_DIR/${filename}.json${NC}"
done

echo ""
echo -e "${GREEN}✓ Exported $SESSION_COUNT session(s) to $OUTPUT_DIR${NC}"
echo ""
echo "Files created:"
echo "  - *.md - Human-readable markdown format"
echo "  - *.json - Raw JSON data"

