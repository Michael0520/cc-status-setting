# Claude Code Status Line Setup

One-command setup for [ccstatusline](https://github.com/sirmalloc/ccstatusline) with team-shared configuration.

## Usage

```bash
git clone git@github.com:Michael0520/cc-status-setting.git
cd cc-status-setting
./setup-ccstatusline.sh
```

Then restart Claude Code.

## What it does

1. Removes old custom statusline (`~/.claude/statusline/`) if present
2. Installs [Bun](https://bun.sh) if not found
3. Writes ccstatusline settings to `~/.config/ccstatusline/settings.json`
4. Updates `~/.claude/settings.json` with statusLine config (preserves existing settings)

## Status Line Layout

**Line 1 - Project info**

| Widget | Color |
|--------|-------|
| Working directory | magenta |
| Git branch | brightRed |
| Git worktree | default |

**Line 2 - Session info**

| Widget | Color | Position |
|--------|-------|----------|
| Model | white | left |
| Tokens input | brightBlack | left |
| Tokens total | brightYellow | left |
| Context % | cyan | left |
| Block timer | brightMagenta | right |
| Session cost | brightGreen | right |
| Session clock | brightBlack | right |

## Requirements

- macOS / Linux
- Node.js (for JSON settings merge)
- Bun (auto-installed if missing)

## Customization

After installation, run the TUI to adjust settings:

```bash
bunx ccstatusline@latest
```
