# Testing Guide

This document explains how to test the Claude Code Status Line setup.

## Quick Test

Run the test suite to verify all functionality:

```bash
./test.sh
```

## Test Coverage

The test suite covers:

### ✅ Core Functionality Tests

1. **File Existence** - Verifies required files are present
2. **Script Syntax** - Checks bash syntax validity  
3. **OS Detection** - Confirms macOS detection works
4. **Statusline Generation** - Tests output format with sample JSON
5. **Dependency Detection** - Verifies detection logic for brew/jq/ccusage
6. **README Content** - Ensures documentation is complete
7. **Color Codes** - Confirms ANSI colors are properly defined
8. **Auto-Install Logic** - Checks installation commands are present
9. **Backup Functionality** - Verifies settings backup logic
10. **Integration Test** - Placeholder for full installation test

### 🔍 Test Output Example

```
==========================================
  Claude Code Status Line - Test Suite
==========================================

[TEST] Checking if required files exist
[PASS] All required files exist
[TEST] Checking script syntax
[PASS] Script syntax is valid
[TEST] Testing OS detection
[PASS] macOS detection works correctly
...
==========================================
  Test Results
==========================================
Tests Run:    10
Tests Passed: 10
Tests Failed: 0

[PASS] All tests passed! ✅
```

## Manual Testing

### Test Statusline Script Directly

```bash
# Test the statusline script with sample input
echo '{"model": {"display_name": "Test Model"}}' | bash ~/.claude/statusline-command.sh
```

Expected output:
```
🕐 HH:MM:SS | 🤖 Test Model | 🌿 git-branch | 💰 $X.XX today
```

### Test Installation (Safe Environment Recommended)

```bash
# Create a backup first
cp ~/.claude/settings.json ~/.claude/settings.json.manual.backup

# Run the installer
./setup-claude-statusline.sh

# Verify installation
cat ~/.claude/settings.json | grep statusLine
```

### Test Dependencies

```bash
# Check if tools are available
which brew
which jq  
which ccusage

# Test each tool
brew --version
jq --version
ccusage --version
```

## Development Testing

When modifying the scripts, run specific tests:

### Test Script Changes

```bash
# Check syntax
bash -n setup-claude-statusline.sh

# Test specific functions (extract and test manually)
```

### Test Statusline Changes

```bash
# Test different JSON inputs
echo '{"model": {"display_name": "Claude 3.5 Sonnet"}}' | bash statusline-script.sh
echo '{"model": {"display_name": "Claude 3 Opus"}}' | bash statusline-script.sh
echo '{}' | bash statusline-script.sh  # Test error handling
```

### Test Color Output

```bash
# Test in different terminals
echo -e "\033[90mGray\033[0m \033[35mPurple\033[0m \033[32mGreen\033[0m \033[33mYellow\033[0m"
```

## Troubleshooting Tests

### Common Test Failures

**Test fails: "Required files missing"**
- Ensure you're running tests from the project directory
- Check `setup-claude-statusline.sh` and `README.md` exist

**Test fails: "Script has syntax errors"** 
- Run `bash -n setup-claude-statusline.sh` to see specific errors
- Check for unclosed quotes, missing brackets, etc.

**Test fails: "Statusline script output format incorrect"**
- The statusline script extracted from setup script may be malformed
- Manually check the heredoc section in the setup script

### Test Environment Issues

**Running on non-macOS:**
- OS detection test will fail (expected)
- Some tools may not be available

**Missing dependencies:**
- Tests will note missing tools but should still pass
- Actual functionality requires the tools to be installed

## Continuous Testing

### Before Committing Changes

```bash
# Always run the test suite
./test.sh

# Test with verbose output if needed
./test.sh -v

# Manual verification
echo '{"model": {"display_name": "Test"}}' | bash ~/.claude/statusline-command.sh
```

### After Installation 

```bash
# Verify Claude Code shows the new status line
# (Requires restarting Claude Code)

# Check files were created correctly
ls -la ~/.claude/statusline-command.sh
ls -la ~/.claude/settings.json*
```

## Test Automation

The test script is designed to be:
- **Safe** - No actual installations
- **Fast** - Completes in seconds  
- **Comprehensive** - Covers all major functionality
- **Portable** - Works on any macOS system

Run it before any changes to ensure nothing breaks!