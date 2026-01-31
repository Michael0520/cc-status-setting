# CLAUDE.md

## Project Overview

Team-shared setup script for [ccstatusline](https://github.com/sirmalloc/ccstatusline), a status line formatter for Claude Code CLI.

## Repository Structure

```
cc-status-setting/
├── README.md                  # Usage docs for teammates
├── setup-ccstatusline.sh      # One-command install script
└── CLAUDE.md                  # This file
```

## What the Script Does

`setup-ccstatusline.sh` performs these steps in order:

1. **Clean up old version** — removes `~/.claude/statusline/` and backup files from the previous custom shell-based statusline
2. **Install Bun** — auto-installs via `curl` if not found
3. **Write ccstatusline config** — overwrites `~/.config/ccstatusline/settings.json` with team-shared settings
4. **Update Claude Code settings** — merges `statusLine` into `~/.claude/settings.json` using Node.js, preserving all other fields

## Dependencies

- **Node.js** — required, used for safe JSON merge of `~/.claude/settings.json`
- **Bun** — required for runtime, auto-installed if missing

## Config Files Touched

| File | Action |
|------|--------|
| `~/.config/ccstatusline/settings.json` | Always overwritten |
| `~/.claude/settings.json` | Merged (only `statusLine` key updated) |
| `~/.claude/statusline/` | Deleted if exists (old version cleanup) |

## Editing Guidelines

- Keep the script as a single self-contained file with no external dependencies beyond Node.js and Bun
- Widget type names must match ccstatusline's registered types (verify against source if adding new widgets)
- When updating the settings JSON inside the heredoc, ensure it remains valid JSON
- Test on both fresh machines (no existing config) and machines with prior installations
