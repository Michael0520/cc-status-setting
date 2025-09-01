# Claude Code Custom Status Line

Zero-configuration setup for enhanced Claude Code status line on macOS.

## ✨ What You Get

Your Claude Code status line will show:

- 🕐 **Current Time**
- 🤖 **Claude Model** 
- 🌿 **Git Branch**
- 💰 **Daily Cost** (auto-installed)

Example: `🕐 20:53:49 | 🤖 Sonnet 4 | 🌿 main | 💰 $16.67 today`

## 🚀 One Command Install

```bash
# Download and run (installs everything automatically)
curl -O https://raw.githubusercontent.com/Michael0520/cc-status-setting/main/setup-claude-statusline.sh
chmod +x setup-claude-statusline.sh
./setup-claude-statusline.sh
```

## 📋 Requirements

- **macOS**
- **Claude Code** installed

That's it! Everything else is auto-installed.

## 🔧 Troubleshooting

**Status line not showing?**
- Restart Claude Code
- Check: `cat ~/.claude/settings.json`

**Cost showing "N/A"?**
- ccusage should be auto-installed during setup
- If still showing "N/A", manually run: `brew install ccusage`

**Restore backup:**
```bash
ls ~/.claude/settings.json.backup.*
cp ~/.claude/settings.json.backup.* ~/.claude/settings.json
```

## 📁 Files Created

```
~/.claude/
├── statusline-command.sh
├── settings.json
└── settings.json.backup.*
```

---

Enjoy your enhanced Claude Code status line! 🎉