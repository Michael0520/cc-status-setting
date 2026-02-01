#!/bin/bash
# Setup ccstatusline for Claude Code
# Usage: ./setup-ccstatusline.sh

set -e

echo "=== Setting up ccstatusline for Claude Code ==="

# Clean up old statusline (v2.14.0 custom shell-based version)
if [ -d "$HOME/.claude/statusline" ]; then
  rm -rf "$HOME/.claude/statusline"
  echo "Removed old ~/.claude/statusline/"
fi
# Clean up old backups
rm -rf "$HOME/.claude/statusline.backup."* 2>/dev/null
rm -f "$HOME/.claude/settings.json.backup."* 2>/dev/null

# Check if bun is installed
if ! command -v bun &> /dev/null; then
  echo "Bun not found. Installing..."
  curl -fsSL https://bun.sh/install | bash
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  echo "Bun installed."
else
  echo "Bun found: $(bun --version)"
fi

# Create ccstatusline settings
mkdir -p ~/.config/ccstatusline
cat > ~/.config/ccstatusline/settings.json << 'EOF'
{
  "version": 3,
  "lines": [
    [
      { "id": "1", "type": "current-working-dir", "color": "magenta" },
      { "id": "2", "type": "git-branch", "color": "brightRed" },
      { "id": "3", "type": "git-worktree" },
      { "id": "4", "type": "separator" }
    ],
    [
      { "id": "5", "type": "model", "color": "white" },
      { "id": "6", "type": "context-percentage", "color": "cyan" },
      { "id": "7", "type": "separator" },
      { "id": "8", "type": "session-cost", "color": "brightGreen" },
      { "id": "9", "type": "session-clock", "color": "brightBlack" }
    ]
  ],
  "flexMode": "full-minus-40",
  "compactThreshold": 60,
  "colorLevel": 3,
  "inheritSeparatorColors": false,
  "defaultPadding": " ",
  "globalBold": false,
  "powerline": {
    "enabled": false,
    "separators": [""],
    "separatorInvertBackground": [false],
    "startCaps": [],
    "endCaps": [],
    "autoAlign": false
  }
}
EOF
echo "Created ~/.config/ccstatusline/settings.json"

# Update Claude Code settings
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
mkdir -p ~/.claude

STATUSLINE='{ "type": "command", "command": "bunx -y ccstatusline@latest", "padding": 0 }'

if ! command -v node &> /dev/null; then
  echo "Error: Node.js is required but not found. Please install Node.js first."
  exit 1
fi

if [ -f "$CLAUDE_SETTINGS" ]; then
  # Merge statusLine into existing settings, preserving other fields
  node -e "
    const fs = require('fs');
    const settings = JSON.parse(fs.readFileSync('$CLAUDE_SETTINGS', 'utf8'));
    settings.statusLine = $STATUSLINE;
    fs.writeFileSync('$CLAUDE_SETTINGS', JSON.stringify(settings, null, 2) + '\n');
  "
  echo "Updated statusLine in $CLAUDE_SETTINGS"
else
  cat > "$CLAUDE_SETTINGS" << EOF
{
  "statusLine": $STATUSLINE
}
EOF
  echo "Created $CLAUDE_SETTINGS"
fi

echo ""
echo "=== Done! Restart Claude Code to see the status line. ==="
