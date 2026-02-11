#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$SCRIPT_DIR/plugins/dev"

echo ""
echo "=================================="
echo "  Archon Plugin Installer"
echo "=================================="
echo ""

# Step 1: Check if Claude Code is installed
echo -n "Checking for Claude Code... "
if ! command -v claude &> /dev/null; then
    echo -e "${RED}NOT FOUND${NC}"
    echo ""
    echo "Claude Code is required. Install from:"
    echo "  https://claude.ai/code"
    exit 1
fi
echo -e "${GREEN}OK${NC}"

# Step 2: Find shell RC file
SHELL_RC=""
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
fi

if [ -z "$SHELL_RC" ]; then
    echo -e "${RED}Could not find shell RC file (.zshrc, .bashrc, or .bash_profile)${NC}"
    exit 1
fi

# Step 3: Check for old superform alias
if grep -q "alias claude=.*plugin-dir.*superform" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}WARNING: Old superform plugin alias detected in $SHELL_RC${NC}"
    echo "  Run the superform uninstall.sh first, or remove the alias manually."
    echo "  The old alias will be replaced by the Archon alias."
    echo ""
fi

# Step 4: Remove any old alias and add new one
echo -n "Configuring shell alias... "

# Remove old archon aliases
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/# Archon Claude Code plugin/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '' '/alias claude=.*plugin-dir.*archon/d' "$SHELL_RC" 2>/dev/null || true
    # Also remove old superform aliases
    sed -i '' '/# Superform Claude Code plugin/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '' '/alias claude=.*plugin-dir.*superform/d' "$SHELL_RC" 2>/dev/null || true
else
    sed -i '/# Archon Claude Code plugin/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '/alias claude=.*plugin-dir.*archon/d' "$SHELL_RC" 2>/dev/null || true
    # Also remove old superform aliases
    sed -i '/# Superform Claude Code plugin/d' "$SHELL_RC" 2>/dev/null || true
    sed -i '/alias claude=.*plugin-dir.*superform/d' "$SHELL_RC" 2>/dev/null || true
fi

# Add the new alias
echo "" >> "$SHELL_RC"
echo "# Archon Claude Code plugin" >> "$SHELL_RC"
echo "alias claude='claude --plugin-dir \"$PLUGIN_DIR\"'" >> "$SHELL_RC"

echo -e "${GREEN}CONFIGURED${NC}"
echo "  Added alias to $SHELL_RC"

# Step 5: Summary
echo ""
echo "=================================="
echo "  Installation Complete!"
echo "=================================="
echo ""
echo "Available commands:"
echo "  /dev:spec <feature-name>        Create feature specification (80% planning)"
echo "  /dev:work <spec-path>           Execute spec with adaptive agent teams (20% execution)"
echo ""
echo "Available skill (auto-triggers):"
echo "  dev:specifier                   Triggers on 'create a spec', 'plan a feature'"
echo ""
echo "MCP Servers (auto-configured, optional):"
echo "  linear                          Read-only access to Linear issues"
echo "  figma                           Design specifications (--figma flag)"
echo ""
echo -e "${YELLOW}Figma MCP setup:${NC}"
echo "  Requires Figma account with Dev or Full seat on paid plan."
echo "  Setup: https://figma.com -> Dev Mode -> Enable MCP server"
echo "  Guide: https://help.figma.com/hc/en-us/articles/32132100833559"
echo ""
echo "Powered by compound-engineering (via Task tool):"
echo "  Research agents:"
echo "    repo-research-analyst         Codebase research"
echo "    best-practices-researcher     Best practices"
echo "    framework-docs-researcher     Framework docs"
echo "    spec-flow-analyzer            Spec validation"
echo "  Review agents (optional, user choice):"
echo "    security-sentinel             Security review"
echo "    performance-oracle            Performance review"
echo "    code-simplicity-reviewer      Code quality review"
echo ""
echo "Adaptive team execution:"
echo "  Solo:  Simple sequential work (score 0-25)"
echo "  Lean:  2 parallel streams (score 26-50)"
echo "  Full:  3+ parallel streams (score 51+)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Reload your shell: source $SHELL_RC"
echo "  2. Start Claude Code: claude"
echo "  3. Run: /dev:spec my-feature"
echo ""
echo "To uninstall, run: ./uninstall.sh"
echo ""
