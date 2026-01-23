#!/bin/bash

# Claude Code Enhanced Status Line Setup Script
# Installs full-featured statusline v2.14.0 with 5-line display

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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATUSLINE_SOURCE="$SCRIPT_DIR/statusline"

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

    # Install bash 4+ if needed
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        print_status "Installing bash 4+..."
        brew install bash
        print_success "bash 4+ installed"
    else
        print_success "bash 4+ already installed"
    fi

    print_success "All dependencies installed"
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

# Backup existing statusline
backup_statusline() {
    if [[ -d "$HOME/.claude/statusline" ]]; then
        BACKUP_DIR="$HOME/.claude/statusline.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backing up existing statusline..."
        mv "$HOME/.claude/statusline" "$BACKUP_DIR"
        print_success "Statusline backed up to: $BACKUP_DIR"
        echo "$BACKUP_DIR"
    fi
}

# Install full statusline system
install_statusline() {
    print_status "Installing enhanced statusline v2.14.0..."

    # Check if source statusline exists
    if [[ ! -d "$STATUSLINE_SOURCE" ]]; then
        print_error "Statusline source not found at: $STATUSLINE_SOURCE"
        print_error "Please ensure you're running this script from the correct directory"
        exit 1
    fi

    # Copy statusline to ~/.claude/
    rm -rf "$HOME/.claude/statusline"
    mkdir -p "$HOME/.claude/statusline"
    cp -r "$STATUSLINE_SOURCE/"* "$HOME/.claude/statusline/"

    # Set execute permission
    chmod +x "$HOME/.claude/statusline/statusline.sh"

    # Clean up cache files (shouldn't be in source, but just in case)
    rm -f "$HOME/.claude/statusline/.Config.cache.sh"
    rm -f "$HOME/.claude/statusline/.Config.checksum"

    print_success "Statusline system installed"
    print_status "  • Main program: statusline.sh"
    print_status "  • Configuration: Config.toml"
    print_status "  • Modules: lib/ (19 modules)"
    print_status "  • Version: v2.14.0"
}

# Update Claude Code settings
update_settings() {
    SETTINGS_FILE="$HOME/.claude/settings.json"
    STATUSLINE_COMMAND="bash $HOME/.claude/statusline/statusline.sh"

    print_status "Updating Claude Code settings..."

    # Backup settings
    if [[ -f "$SETTINGS_FILE" ]]; then
        BACKUP_FILE="$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$SETTINGS_FILE" "$BACKUP_FILE"
        print_status "Settings backed up to: $BACKUP_FILE"
    fi

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
    if [[ ! -f "$HOME/.claude/statusline/statusline.sh" ]]; then
        print_error "statusline.sh not found"
        exit 1
    fi

    if [[ ! -f "$HOME/.claude/statusline/Config.toml" ]]; then
        print_error "Config.toml not found"
        exit 1
    fi

    if [[ ! -d "$HOME/.claude/statusline/lib" ]]; then
        print_error "lib/ directory not found"
        exit 1
    fi

    # Check version
    VERSION=$(cat "$HOME/.claude/statusline/version.txt" 2>/dev/null || echo "unknown")
    print_success "Installed version: $VERSION"

    # Test statusline
    print_status "Running health check..."
    if "$HOME/.claude/statusline/statusline.sh" --health &> /dev/null; then
        print_success "Health check passed"
    else
        print_warning "Health check has warnings (optional features may be missing)"
    fi

    print_success "All core files installed correctly"
}

# Show installation summary
show_summary() {
    echo
    echo "========================================"
    print_success "Installation Complete!"
    echo "========================================"
    echo
    print_status "Enhanced Statusline Features:"
    echo "  ✓ 5-line display with rich information"
    echo "  ✓ Catppuccin theme (warm colors)"
    echo "  ✓ Cost tracking (session/daily/weekly/monthly)"
    echo "  ✓ MCP server monitoring"
    echo "  ✓ Context window usage"
    echo "  ✓ Code productivity stats"
    echo "  ✓ Cache efficiency display"
    echo
    print_status "Display format:"
    echo "  Line 1: Repository info (path, branch, status)"
    echo "  Line 2: Model, commits, version, time"
    echo "  Line 3: Cost analytics (5 dimensions)"
    echo "  Line 4: Performance metrics"
    echo "  Line 5: MCP status, reset timer"
    echo
    print_warning "IMPORTANT: Restart Claude Code to see the new statusline"
    echo
    print_status "Useful commands:"
    echo "  ~/.claude/statusline/statusline.sh --help          # Show all options"
    echo "  ~/.claude/statusline/statusline.sh --health        # Health check"
    echo "  ~/.claude/statusline/statusline.sh --list-themes   # Available themes"
    echo "  ~/.claude/statusline/statusline.sh --validate      # Validate config"
    echo
    print_status "Configuration file:"
    echo "  ~/.claude/statusline/Config.toml"
    echo
    if [[ -n "$BACKUP_PATH" ]]; then
        print_warning "To restore backup:"
        echo "  rm -rf ~/.claude/statusline"
        echo "  mv $BACKUP_PATH ~/.claude/statusline"
        echo
    fi
}

# Main installation process
main() {
    clear
    echo "========================================"
    echo "  Claude Code Enhanced Status Line"
    echo "        Setup v2.14.0"
    echo "========================================"
    echo

    check_os
    install_dependencies
    create_claude_dir
    BACKUP_PATH=$(backup_statusline)
    install_statusline
    update_settings
    verify_installation
    show_summary
}

# Run main function
main "$@"
