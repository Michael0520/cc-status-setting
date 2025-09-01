# Claude Code Status Line

Enhanced Claude Code status line with time, model, git branch, and daily cost.

## Features

- 🕐 Current Time
- 🤖 Claude Model 
- 🌿 Git Branch
- 💰 Daily Cost

Example: `🕐 20:53:49 | 🤖 Sonnet 4 | 🌿 main | 💰 $16.67 today`

## Installation

```bash
# One-liner installation
npx @michael0520/claude-status install
```

### Alternative Methods

```bash
# Install globally
npm install -g @michael0520/claude-status
claude-status install

# Using pnpm
pnpm dlx @michael0520/claude-status install

# Legacy shell script
curl -O https://raw.githubusercontent.com/Michael0520/cc-status-setting/main/setup-claude-statusline.sh
chmod +x setup-claude-statusline.sh && ./setup-claude-statusline.sh
```

## Requirements

- macOS
- Claude Code installed

Everything else is auto-installed.

## CLI Commands

```bash
npx @michael0520/claude-status install        # Install
npx @michael0520/claude-status config         # Configure  
npx @michael0520/claude-status test           # Test
npx @michael0520/claude-status uninstall      # Remove
npx @michael0520/claude-status --help         # Help
```

## Troubleshooting

**Status line not showing?**
- Restart Claude Code
- Run `claude-status test` for diagnostics

**Restore backup:**
```bash
claude-status uninstall  # Follow restore prompts
```