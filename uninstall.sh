#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "=================================="
echo "  Archon Plugin Uninstaller"
echo "=================================="
echo ""

# Find shell RC file
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
fi

# Remove shell alias
echo -n "Removing shell alias... "
if [ -n "$SHELL_RC" ] && grep -q "# Archon Claude Code plugin" "$SHELL_RC" 2>/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/# Archon Claude Code plugin/d' "$SHELL_RC"
        sed -i '' '/alias claude=.*plugin-dir.*archon/d' "$SHELL_RC"
    else
        sed -i '/# Archon Claude Code plugin/d' "$SHELL_RC"
        sed -i '/alias claude=.*plugin-dir.*archon/d' "$SHELL_RC"
    fi
    echo -e "${GREEN}REMOVED${NC}"
    echo "  Removed alias from $SHELL_RC"
else
    echo -e "${GREEN}NOT FOUND (already clean)${NC}"
fi

echo ""
echo "=================================="
echo "  Uninstallation Complete!"
echo "=================================="
echo ""
echo "Removed:"
echo "  - /dev:spec command"
echo "  - /dev:work command"
echo "  - dev:specifier skill"
echo "  - Linear MCP server configuration"
echo "  - Figma MCP server configuration"
echo ""
echo "Note: compound-engineering agents remain available if installed separately."
echo ""
echo -e "${YELLOW}Next step:${NC}"
echo "  Reload your shell: source $SHELL_RC"
echo ""
echo "Note: This script does not delete the plugin files."
echo "To completely remove, delete this repository."
echo ""
