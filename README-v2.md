# Claude Code Custom Status Line v2.0

**Modern TypeScript CLI** for enhanced Claude Code status line on macOS.

## ✨ What's New in v2.0

- 🚀 **Modern TypeScript CLI** - Built with cutting-edge tools
- 🎨 **Interactive Configuration** - Customize colors and features  
- 🧪 **Comprehensive Testing** - Built-in test suite
- 📦 **Multiple Installation Methods** - npm, npx, or legacy shell script
- ⚙️ **Smart Dependency Management** - Auto-installs everything needed

## 🎯 Features

Your Claude Code status line will show:

- 🕐 **Current Time**
- 🤖 **Claude Model** 
- 🌿 **Git Branch**
- 💰 **Daily Cost** (auto-installed)

Example: `🕐 20:53:49 | 🤖 Sonnet 4 | 🌿 main | 💰 $16.67 today`

## 🚀 Installation

### ⚡ Quick Start (Recommended)

```bash
# One-liner installation (no global install needed)
npx @michael0520/claude-status install
```

### Alternative Methods

```bash
# Install globally first
npm install -g @michael0520/claude-status
claude-status install

# Using pnpm
pnpm dlx @michael0520/claude-status install
```

### Legacy Installation (Still Works)

```bash
curl -O https://raw.githubusercontent.com/Michael0520/cc-status-setting/main/setup-claude-statusline.sh
chmod +x setup-claude-statusline.sh
./setup-claude-statusline.sh
```

## 📋 Requirements

- **macOS** 
- **Claude Code** installed

That's it! Everything else is auto-installed.

## 🛠️ CLI Commands

```bash
# Using npx (no installation needed)
npx @michael0520/claude-status install        # Install status line
npx @michael0520/claude-status config         # Interactive configuration
npx @michael0520/claude-status test           # Test installation  
npx @michael0520/claude-status uninstall      # Clean removal
npx @michael0520/claude-status --help         # Show help

# If installed globally
claude-status install        # Install status line
claude-status config         # Interactive configuration
claude-status test           # Test installation  
claude-status uninstall      # Clean removal
claude-status --help         # Show help
```

### Interactive Configuration

```bash
$ claude-status config

⚙️  Configure Claude Code Status Line
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

? What information do you want to show?
  ✓ 🕐 Current time
  ✓ 🤖 Claude model
  ✓ 🌿 Git branch  
  ✓ 💰 Daily cost

? Choose your color scheme:
  ❯ Default (Gray, Purple, Green, Yellow)
    Monochrome (All white)
    Bright colors
    Custom...
```

### Smart Testing

```bash
$ claude-status test

🧪 Claude Code Status Line - Test Suite
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ System requirements
✓ Required files exist  
✓ Dependencies installed
✓ Status line script execution
✓ Claude Code settings

Tests passed: 5/5
✅ All tests passed!
```

## 🏗️ Development

Built with modern tools:

- **Package Manager**: `pnpm` 
- **CLI Framework**: `cac`
- **Interactive UI**: `prompts` + `kolorist`
- **Build Tool**: `tsup` 
- **Test Framework**: `vitest`
- **Code Linting**: `oxlint` (50-100x faster than ESLint)

### Local Development

```bash
git clone https://github.com/Michael0520/cc-status-setting.git
cd cc-status-setting

pnpm install           # Install dependencies
pnpm dev install       # Test CLI locally
pnpm build             # Build for production
pnpm test              # Run tests
pnpm typecheck         # Type checking
pnpm lint              # Code linting with oxlint
```

## 🔧 Troubleshooting

**Status line not showing?**
- Restart Claude Code
- Run `claude-status test` for diagnostics

**Installation issues?**
- Ensure you have admin privileges
- Check internet connection
- Try `claude-status install --force`

**Restore backup:**
```bash
ls ~/.claude/settings.json.backup.*
claude-status uninstall  # Follow restore prompts
```

## 🆚 v1.0 vs v2.0

| Feature | v1.0 (Shell) | v2.0 (TypeScript) |
|---------|-------------|-------------------|
| Installation | Shell script | npm/npx + shell |
| Configuration | Manual editing | Interactive CLI |
| Testing | Basic script | Comprehensive suite |
| Error Handling | Limited | Detailed + recovery |
| Maintenance | Manual | Automated updates |
| Customization | Code editing | GUI prompts |

## 📁 Files Created

```
~/.claude/
├── statusline-command.sh      # Status line script
├── settings.json             # Claude Code config
├── config.json              # v2.0 configuration
└── settings.json.backup.*   # Auto backups
```

---

**Legacy v1.0 Documentation**: See [README.md](./README.md)

Enjoy your enhanced Claude Code status line! 🎉