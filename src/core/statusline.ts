import { writeFile } from 'node:fs/promises'
import { statusColors } from '../utils/colors'
import { paths } from '../utils/fs'

export const statuslineTemplate = `#!/bin/bash

# Read JSON from stdin if no argument provided
if [ -z "$1" ]; then
    JSON_INPUT=$(cat)
else
    JSON_INPUT="$1"
fi

# Color codes
GRAY='${statusColors.time}'
PURPLE='${statusColors.model}'
GREEN='${statusColors.git}'
YELLOW='${statusColors.cost}'
RESET='${statusColors.reset}'

# Get current time
TIME=$(date +%H:%M:%S)

# Get model name from JSON input (passed by Claude Code)
# Use printf instead of echo for better security (no escape sequence interpretation)
MODEL=$(printf '%s' "$JSON_INPUT" | jq -r '.model.display_name // "Unknown Model"' 2>/dev/null || echo "Unknown Model")

# Get current git branch
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "not in git")

# Get usage credits from ccusage
if command -v ccusage &> /dev/null; then
    # Use ccusage daily command with stdin closed to prevent hanging
    # This is much faster and more reliable than ccusage statusline
    TODAY=$(date +%m-%d)
    # Extract cost from ccusage daily output (safe: TODAY format is always MM-DD)
    COST=$(ccusage daily --no-color --no-offline < /dev/null 2>&1 | grep -B1 "\${TODAY}" | grep -oE '\\$[0-9]+\\.[0-9]+' | tail -1)

    if [ -n "$COST" ]; then
        CREDITS="$COST today"
    else
        CREDITS="N/A"
    fi
else
    CREDITS="ccusage not installed"
fi

# Output the formatted status line with icons
echo -e "\${GRAY}🕐 \${TIME}\${RESET} | \${PURPLE}🤖 \${MODEL}\${RESET} | \${GREEN}🌿 \${GIT_BRANCH}\${RESET} | \${YELLOW}💰 \${CREDITS}\${RESET}"
`

export async function createStatuslineScript(): Promise<void> {
  await writeFile(paths.statusline, statuslineTemplate, 'utf-8')
  
  // Make script executable
  await import('node:fs').then(fs => 
    fs.promises.chmod(paths.statusline, 0o755)
  )
}

export interface StatuslineConfig {
  showTime: boolean
  showModel: boolean
  showGit: boolean
  showCost: boolean
  colors: {
    time: string
    model: string
    git: string
    cost: string
  }
}

export const defaultConfig: StatuslineConfig = {
  showTime: true,
  showModel: true,
  showGit: true,
  showCost: true,
  colors: {
    time: statusColors.time,
    model: statusColors.model,
    git: statusColors.git,
    cost: statusColors.cost,
  },
}