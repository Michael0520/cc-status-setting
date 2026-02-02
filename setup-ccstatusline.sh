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

# Generate rate limit helper script
cat > ~/.config/ccstatusline/claude-ratelimit.sh << 'RATELIMIT_EOF'
#!/bin/bash
# Claude Code rate limit display for ccstatusline custom-command widget
# Usage: echo '{}' | claude-ratelimit.sh 5h|7d
# Output: "5h: 45%" or "7d: 23%" with ANSI color (red ≥80%, yellow ≥50%, green <50%)

set -e

WINDOW="${1:-5h}"

# Drain stdin (ccstatusline pipes Claude Code JSON)
cat > /dev/null

# Colorize output based on utilization percentage
colorize() {
  local pct="$1"
  local text="${WINDOW}: ${pct}%"
  if [[ "$pct" -ge 80 ]]; then
    printf '\033[91m%s\033[0m' "$text"   # bright red
  elif [[ "$pct" -ge 50 ]]; then
    printf '\033[93m%s\033[0m' "$text"   # bright yellow
  else
    printf '\033[96m%s\033[0m' "$text"   # bright cyan
  fi
}

CACHE_FILE="/tmp/claude-ratelimit-cache.json"
CACHE_TTL=300

# Check cache
if [[ -f "$CACHE_FILE" ]]; then
  cache_age=$(( $(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || echo 0) ))
  if [[ "$cache_age" -lt "$CACHE_TTL" ]]; then
    if [[ "$WINDOW" == "5h" ]]; then
      val=$(jq -r '.five_hour.utilization // empty' "$CACHE_FILE" 2>/dev/null)
    else
      val=$(jq -r '.seven_day.utilization // empty' "$CACHE_FILE" 2>/dev/null)
    fi
    if [[ -n "$val" ]]; then
      pct=$(printf "%.0f" "$val" 2>/dev/null)
      colorize "$pct"
      exit 0
    fi
  fi
fi

# Read OAuth token from macOS Keychain
creds=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null) || exit 0
token=$(echo "$creds" | jq -r '.claudeAiOauth.accessToken // .accessToken // .access_token // empty' 2>/dev/null)
[[ -z "$token" ]] && exit 0

# Fetch usage from API
response=$(curl -s --max-time 5 \
  -H "Authorization: Bearer $token" \
  -H "Content-Type: application/json" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Accept: application/json" \
  "https://api.anthropic.com/api/oauth/usage" 2>/dev/null) || exit 0

# Validate response
echo "$response" | jq -e '.five_hour' &>/dev/null || exit 0

# Write cache
echo "$response" > "$CACHE_FILE"

# Extract requested window
if [[ "$WINDOW" == "5h" ]]; then
  val=$(echo "$response" | jq -r '.five_hour.utilization // empty' 2>/dev/null)
else
  val=$(echo "$response" | jq -r '.seven_day.utilization // empty' 2>/dev/null)
fi

[[ -z "$val" ]] && exit 0
pct=$(printf "%.0f" "$val" 2>/dev/null)
colorize "$pct"
RATELIMIT_EOF
chmod +x ~/.config/ccstatusline/claude-ratelimit.sh
echo "Created ~/.config/ccstatusline/claude-ratelimit.sh"

# Write ccstatusline settings (uses EOF without quotes to expand $HOME)
cat > ~/.config/ccstatusline/settings.json << EOF
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
      { "id": "7", "type": "custom-command", "commandPath": "$HOME/.config/ccstatusline/claude-ratelimit.sh 5h", "timeout": 8000 },
      { "id": "8", "type": "custom-command", "commandPath": "$HOME/.config/ccstatusline/claude-ratelimit.sh 7d", "timeout": 8000 },
      { "id": "9", "type": "separator" },
      { "id": "10", "type": "session-cost", "color": "brightGreen" },
      { "id": "11", "type": "session-clock", "color": "brightBlack" }
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
