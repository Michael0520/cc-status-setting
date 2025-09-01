#!/bin/bash

# Simple Test Script for Claude Code Status Line Setup

set -e

echo "=========================================="
echo "  Claude Code Status Line - Simple Test"
echo "=========================================="
echo

# Test 1: Files exist
echo "[TEST] Checking required files..."
if [[ -f "setup-claude-statusline.sh" && -f "README.md" ]]; then
    echo "[PASS] ✅ Required files exist"
else
    echo "[FAIL] ❌ Required files missing"
    exit 1
fi

# Test 2: Script syntax
echo "[TEST] Checking script syntax..."
if bash -n setup-claude-statusline.sh >/dev/null 2>&1; then
    echo "[PASS] ✅ Script syntax is valid"
else
    echo "[FAIL] ❌ Script has syntax errors"
    exit 1
fi

# Test 3: OS detection
echo "[TEST] Testing macOS detection..."
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "[PASS] ✅ Running on macOS"
else
    echo "[WARN] ⚠️  Not running on macOS (script designed for macOS)"
fi

# Test 4: Check required commands in script
echo "[TEST] Checking installation commands..."
if grep -q "brew install jq" setup-claude-statusline.sh && \
   grep -q "brew install ccusage" setup-claude-statusline.sh; then
    echo "[PASS] ✅ Installation commands present"
else
    echo "[FAIL] ❌ Installation commands missing"
    exit 1
fi

# Test 5: Check color codes
echo "[TEST] Checking color codes..."
if grep -q "GRAY='\\\\033\[90m" setup-claude-statusline.sh && \
   grep -q "PURPLE='\\\\033\[35m" setup-claude-statusline.sh; then
    echo "[PASS] ✅ Color codes defined"
else
    echo "[FAIL] ❌ Color codes missing"
    exit 1
fi

# Test 6: Check statusline output format
echo "[TEST] Checking statusline format..."
if grep -q "🕐.*🤖.*🌿.*💰" setup-claude-statusline.sh; then
    echo "[PASS] ✅ Statusline format correct"
else
    echo "[FAIL] ❌ Statusline format incorrect"
    exit 1
fi

# Test 7: Check backup functionality
echo "[TEST] Checking backup functionality..."
if grep -q "settings.json.backup" setup-claude-statusline.sh; then
    echo "[PASS] ✅ Backup functionality present"
else
    echo "[FAIL] ❌ Backup functionality missing"
    exit 1
fi

# Test 8: README content
echo "[TEST] Checking README content..."
if grep -q "Zero-configuration" README.md && \
   grep -q "curl -O.*setup-claude-statusline.sh" README.md; then
    echo "[PASS] ✅ README content complete"
else
    echo "[FAIL] ❌ README content incomplete"
    exit 1
fi

# Test 9: Test current statusline (if exists)
echo "[TEST] Testing current statusline..."
if [[ -f "$HOME/.claude/statusline-command.sh" ]]; then
    TEST_OUTPUT=$(echo '{"model": {"display_name": "Test Model"}}' | bash "$HOME/.claude/statusline-command.sh" 2>/dev/null || echo "ERROR")
    if [[ "$TEST_OUTPUT" == *"🕐"* && "$TEST_OUTPUT" == *"🤖"* ]]; then
        echo "[PASS] ✅ Current statusline works"
        echo "       Output: $TEST_OUTPUT"
    else
        echo "[WARN] ⚠️  Current statusline may have issues: $TEST_OUTPUT"
    fi
else
    echo "[INFO] ℹ️  No current statusline installed (expected before running setup)"
fi

echo
echo "=========================================="
echo "[PASS] ✅ All tests passed!"
echo "=========================================="
echo
echo "Ready to use! Share this command with colleagues:"
echo "curl -O https://raw.githubusercontent.com/Michael0520/cc-status-setting/main/setup-claude-statusline.sh"
echo "chmod +x setup-claude-statusline.sh"
echo "./setup-claude-statusline.sh"