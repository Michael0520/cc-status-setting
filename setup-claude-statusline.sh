#!/bin/bash

# Claude Code Status Line Setup Script
# One-click installation for custom status line

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on macOS
check_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "Detected macOS"
    else
        print_error "This script is designed for macOS only"
        exit 1
    fi
}

# Install dependencies
install_dependencies() {
    print_status "Installing dependencies..."
    
    # Install Homebrew if not present
    if ! command -v brew &> /dev/null; then
        print_status "Homebrew not found. Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for current session
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        # Verify Homebrew installation
        if ! command -v brew &> /dev/null; then
            print_error "Homebrew installation failed. Please install manually: https://brew.sh"
            exit 1
        fi
        print_success "Homebrew installed successfully"
    else
        print_success "Homebrew already installed"
    fi
    
    # Install jq
    if ! command -v jq &> /dev/null; then
        print_status "Installing jq..."
        brew install jq
        print_success "jq installed"
    else
        print_success "jq already installed"
    fi
    
    # Install ccusage (optional)
    if ! command -v ccusage &> /dev/null; then
        print_warning "ccusage not found (cost tracking will show 'N/A')"
        print_warning "Install manually: brew install ccusage"
    else
        print_success "ccusage installed"
    fi
}

# Create Claude directory if it doesn't exist
create_claude_dir() {
    CLAUDE_DIR="$HOME/.claude"
    if [[ ! -d "$CLAUDE_DIR" ]]; then
        print_status "Creating .claude directory..."
        mkdir -p "$CLAUDE_DIR"
        print_success "Directory created"
    else
        print_success ".claude directory exists"
    fi
}

# Backup existing settings
backup_settings() {
    SETTINGS_FILE="$HOME/.claude/settings.json"
    if [[ -f "$SETTINGS_FILE" ]]; then
        BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backing up existing settings..."
        cp "$SETTINGS_FILE" "$BACKUP_FILE"
        print_success "Settings backed up"
    fi
}

# Create statusline command script
create_statusline_script() {
    STATUSLINE_SCRIPT="$HOME/.claude/statusline-command.sh"
    print_status "Creating statusline script..."
    
    cat > "$STATUSLINE_SCRIPT" << 'EOF'
#!/bin/bash

# Read JSON from stdin if no argument provided
if [ -z "$1" ]; then
    JSON_INPUT=$(cat)
else
    JSON_INPUT="$1"
fi

# Color codes
GRAY='\033[90m'      # Light gray for time
PURPLE='\033[35m'    # Purple for model
GREEN='\033[32m'     # Green for git branch
YELLOW='\033[33m'    # Yellow for money/credits
RESET='\033[0m'      # Reset color

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
        CREDITS=$(echo "$CCUSAGE_OUTPUT" | grep -oE '\$[0-9]+\.[0-9]+ today' | head -1 || echo "N/A")
    else
        CREDITS="N/A"
    fi
else
    CREDITS="ccusage not installed"
fi

# Output the formatted status line with icons
echo -e "${GRAY}🕐 ${TIME}${RESET} | ${PURPLE}🤖 ${MODEL}${RESET} | ${GREEN}🌿 ${GIT_BRANCH}${RESET} | ${YELLOW}💰 ${CREDITS}${RESET}"
EOF
    
    chmod +x "$STATUSLINE_SCRIPT"
    print_success "Statusline script created"
}

# Update Claude Code settings
update_settings() {
    SETTINGS_FILE="$HOME/.claude/settings.json"
    STATUSLINE_COMMAND="bash $HOME/.claude/statusline-command.sh"
    
    print_status "Updating Claude Code settings..."
    
    if [[ -f "$SETTINGS_FILE" ]]; then
        # Update existing settings file
        TEMP_FILE=$(mktemp)
        jq --arg cmd "$STATUSLINE_COMMAND" '
            .statusLine = {
                "type": "command",
                "command": $cmd
            }
        ' "$SETTINGS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SETTINGS_FILE"
    else
        # Create new settings file
        cat > "$SETTINGS_FILE" << EOF
{
  "statusLine": {
    "type": "command",
    "command": "$STATUSLINE_COMMAND"
  }
}
EOF
    fi
    
    print_success "Settings updated"
}

# Verify installation
verify_installation() {
    print_status "Verifying installation..."
    
    # Check if files exist
    if [[ -f "$HOME/.claude/statusline-command.sh" && -f "$HOME/.claude/settings.json" ]]; then
        print_success "All files installed correctly"
    else
        print_error "Installation verification failed"
        exit 1
    fi
    
    # Test statusline script
    TEST_JSON='{"model": {"display_name": "Test Model"}}'
    if echo "$TEST_JSON" | bash "$HOME/.claude/statusline-command.sh" &> /dev/null; then
        print_success "Statusline script test passed"
    else
        print_error "Statusline script test failed"
        exit 1
    fi
}

# Main installation process
main() {
    echo "========================================"
    echo "    Claude Code Status Line Setup"
    echo "========================================"
    echo
    
    check_os
    install_dependencies
    create_claude_dir
    backup_settings
    create_statusline_script
    update_settings
    verify_installation
    
    echo
    echo "========================================"
    print_success "Installation Complete!"
    echo "========================================"
    echo
    print_status "Status line will show:"
    echo "  🕐 Time | 🤖 Claude Model | 🌿 Git Branch | 💰 Daily Cost"
    echo
    print_status "Restart Claude Code to see the new status line"
    echo
    print_warning "To restore backup if needed:"
    echo "  ls ~/.claude/settings.json.backup.*"
    echo
}

# Run main function
main "$@"