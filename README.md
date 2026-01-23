# Claude Code Enhanced Status Line

Full-featured Claude Code statusline with 5-line display, cost tracking, MCP monitoring, and rich metrics.

## ✨ Features

### Display (5 Lines)

**Line 1**: Repository & Git
- 📁 Current directory
- 🌿 Git branch & status
- Commit count today

**Line 2**: Model & Versions
- 🤖 Claude model (Opus/Sonnet/Haiku)
- 📊 Today's commits
- 📦 Submodule status
- 🔧 Claude Code version
- 🕐 Current time

**Line 3**: Cost Analytics
- 💰 Repository cumulative cost
- 📅 30-day total
- 📅 7-day total
- 📅 Daily cost
- 🔥 Live block cost

**Line 4**: Performance Metrics
- 🔥 Token burn rate (per min/hour)
- 💾 Cache efficiency %
- 📈 Block cost projection
- ➕ Code productivity (lines added/removed)
- 🧠 Context window usage

**Line 5**: System Status
- 🔌 MCP servers (connected/total)
- ⏱️ Usage reset countdown

### Configuration

- **Theme**: Catppuccin (warm colors)
- **Customizable**: Full TOML configuration
- **Modular**: 19 plugin modules
- **Extensible**: Support for custom components

## 🚀 Installation

### NPM Package (Recommended)

```bash
npx @michael0520/claude-status
```

The installer will:
- ✅ Check system requirements (macOS only)
- ✅ Install dependencies (Homebrew, jq)
- ✅ Backup existing statusline (if any)
- ✅ Install complete statusline v2.14.0 system
- ✅ Update Claude Code settings

### Alternative: Shell Script

```bash
curl -O https://raw.githubusercontent.com/Michael0520/cc-status-setting/main/setup-claude-statusline.sh
chmod +x setup-claude-statusline.sh
./setup-claude-statusline.sh
```

## 📋 Requirements

- **macOS** (primary support)
- **Claude Code** installed
- **Node.js 18+** (for NPM installation)
- **jq** (auto-installed if missing)

Optional (auto-detected):
- **bash 4.0+** - Enhanced features
- **ccusage** - Cost tracking
- **Chrome DevTools MCP** - MCP monitoring

## 🎨 Customization

Configuration file: `~/.claude/statusline/Config.toml`

### Change Theme

```toml
theme.name = "catppuccin"  # catppuccin, ocean, garden, classic
```

Available themes:
- **catppuccin** - Warm, cozy colors (default)
- **ocean** - Deep blues and teals
- **garden** - Soft pastels
- **classic** - Traditional ANSI

### Adjust Display Lines

```toml
display.lines = 5  # 1-9 lines available
```

### Enable/Disable Features

```toml
features.show_cost_tracking = true
features.show_mcp_status = true
features.show_context_window = true
features.show_code_productivity = true
features.show_prayer_times = false
```

### Customize Components

```toml
# Line 1: Repository info
display.line1.components = ["repo_info"]

# Line 2: Model + Stats
display.line2.components = ["model_info", "commits", "submodules", "version_info", "time_display"]

# Line 3: Cost breakdown
display.line3.components = ["cost_repo", "cost_monthly", "cost_weekly", "cost_daily", "cost_live"]

# Line 4: Performance
display.line4.components = ["burn_rate", "cache_efficiency", "block_projection", "code_productivity", "context_window"]

# Line 5: System
display.line5.components = ["mcp_status", "usage_reset"]
```

## 🔧 Management Commands

### NPM CLI Commands

```bash
# Install/reinstall statusline
npx @michael0520/claude-status

# Configure settings
npx @michael0520/claude-status config

# Test installation
npx @michael0520/claude-status test

# Uninstall
npx @michael0520/claude-status uninstall
```

### Statusline Commands

```bash
# Health check
~/.claude/statusline/statusline.sh --health

# Validate configuration
~/.claude/statusline/statusline.sh --validate

# List available themes
~/.claude/statusline/statusline.sh --list-themes

# Preview a theme
~/.claude/statusline/statusline.sh --preview-theme catppuccin

# Show version
~/.claude/statusline/statusline.sh --version

# Check for updates
~/.claude/statusline/statusline.sh --check-updates

# Interactive setup wizard
~/.claude/statusline/statusline.sh --setup-wizard

# JSON output (for IDE integration)
~/.claude/statusline/statusline.sh --json
```

## 🆘 Troubleshooting

### Status line not showing?

1. Restart Claude Code
2. Verify installation: `~/.claude/statusline/statusline.sh --health`
3. Check settings: `cat ~/.claude/settings.json | grep statusline`

### Permission errors?

```bash
chmod +x ~/.claude/statusline/statusline.sh
```

### Restore backup

```bash
# List backups
ls -la ~/.claude/ | grep statusline.backup

# Restore
rm -rf ~/.claude/statusline
mv ~/.claude/statusline.backup.YYYYMMDD_HHMMSS ~/.claude/statusline
```

### Missing dependencies?

```bash
# Install via Homebrew
brew install jq bash

# Verify
jq --version
bash --version  # Should be 4.0+
```

## 📊 Example Display

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📁 ~/my-project │ 🌿 main ✅ │ Commits: 3
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎵 Sonnet 4.5 │ 3 commits │ SUB: 2 │ CC: 1.15.0 │ 17:03
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
REPO: $0.45 │ 30DAY: $12.50 │ 7DAY: $3.20 │ DAY: $0.80 │ LIVE: $0.15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔥 3.5k/min $2.10/hr │ 💾 85% │ 📈 $8.25 10.5M │ +156/-23 │ 🧠 45% 90K/200K
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
MCP: 3/3 ✓ │ RESET: 2h 15m
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 🔗 Related Projects

- **Based on**: [rz1989s/claude-code-statusline](https://github.com/rz1989s/claude-code-statusline) v2.14.0
- **Team Config Manager**: [Michael0520/milo-claude](https://github.com/Michael0520/milo-claude)

## 📝 Changelog

### v2.14.0 (2026-01-23)

- ✅ Upgraded to full-featured statusline system
- ✅ 5-line display with rich metrics
- ✅ Catppuccin theme (warm colors)
- ✅ Cost tracking (5 dimensions)
- ✅ MCP monitoring
- ✅ Context window usage
- ✅ Code productivity stats
- ✅ 19 modular components
- ✅ Full TOML configuration

### v1.0.0 (Legacy)

- Simple 1-line display
- Time, model, branch, cost
- Basic functionality

## 📄 License

MIT

## 🤝 Contributing

Issues and PRs welcome!

## 👤 Author

**Michael Lo** ([@Michael0520](https://github.com/Michael0520))
