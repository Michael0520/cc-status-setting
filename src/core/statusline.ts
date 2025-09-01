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
MODEL=$(echo "$JSON_INPUT" | jq -r '.model.display_name // "Unknown Model"' 2>/dev/null || echo "Unknown Model")

# Get current git branch
GIT_BRANCH=$(git branch --show-current 2>/dev/null || echo "not in git")

# Get usage credits from ccusage
if command -v ccusage &> /dev/null; then
    # Build complete JSON for ccusage statusline if needed fields are missing
    if echo "$JSON_INPUT" | jq -e '.session_id and .transcript_path and .workspace' > /dev/null 2>&1; then
        # Claude Code provided complete JSON
        CCUSAGE_OUTPUT=$(echo "$JSON_INPUT" | ccusage statusline 2>/dev/null || echo "")
    else
        # Build minimal JSON with required fields
        CWD=$(pwd)
        COMPLETE_JSON=$(echo "$JSON_INPUT" | jq --arg cwd "$CWD" '
            . + {
                session_id: "claude-code-session",
                transcript_path: "/tmp/claude-transcript",
                cwd: $cwd,
                workspace: {
                    current_dir: $cwd,
                    project_dir: $cwd
                }
            } | 
            if .model and .model.display_name and (.model.id | not) then
                .model.id = "claude-3-5-sonnet"
            else . end
        ' 2>/dev/null || echo '{}')
        CCUSAGE_OUTPUT=$(echo "$COMPLETE_JSON" | ccusage statusline 2>/dev/null || echo "")
    fi
    
    # Extract just the money part from ccusage output (e.g., "$3.18 today")
    if [ -n "$CCUSAGE_OUTPUT" ]; then
        # Extract the cost information (looking for patterns like $X.XX today)
        CREDITS=$(echo "$CCUSAGE_OUTPUT" | grep -oE '\\$[0-9]+\\.[0-9]+ today' | head -1 || echo "N/A")
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