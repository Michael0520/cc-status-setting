#!/usr/bin/env bash
# ============================================================================
# Claude Code Lightweight Statusline (v3.0.0)
# ============================================================================
# Replaces the modular 7700-line version with a single ~200-line script.
# All external calls run in parallel. Executes in <3 seconds.
#
# Output (5 lines):
#   Line 1: ~/path (branch) [clean/dirty]
#   Line 2: Model | Commits:N | CC:X.X.X | HH:MM
#   Line 3: REPO $X.XX | 30DAY $X.XX | 7DAY $X.XX | DAY $X.XX | LIVE $X.XX
#   Line 4: $X.XX/hr | Cache: XX% hit | Est: $X.XX (XX.XM)
#   Line 5: MCP:?/? | 5H at HH:MM (X hr Y min) Z% * 7DAY ... (Z%)
# ============================================================================

set -euo pipefail

# ============================================================================
# CATPPUCCIN MOCHA THEME (hardcoded)
# ============================================================================
C_RED=$'\033[38;2;243;139;168m'       # #f38ba8
C_BLUE=$'\033[38;2;137;180;250m'      # #89b4fa
C_GREEN=$'\033[38;2;166;227;161m'     # #a6e3a1
C_YELLOW=$'\033[38;2;249;226;175m'    # #f9e2af
C_MAGENTA=$'\033[38;2;203;166;247m'   # #cba6f7
C_CYAN=$'\033[38;2;137;220;235m'      # #89dceb
C_WHITE=$'\033[38;2;205;214;244m'     # #cdd6f4
C_ORANGE=$'\033[38;2;250;179;135m'    # #fab387
C_TEAL=$'\033[38;2;148;226;213m'      # #94e2d5
C_GRAY=$'\033[38;2;166;173;200m'      # #a6adc8
C_DIM=$'\033[2m'
C_ITALIC=$'\033[3m'
C_RESET=$'\033[0m'
SEP="${C_GRAY}|${C_RESET}"

# ============================================================================
# 1. READ STDIN JSON (zero external calls)
# ============================================================================
input=$(cat)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // empty')
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')

# Cache tokens from stdin (native Anthropic data)
cache_read=$(echo "$input" | jq -r '.current_usage.cache_read_input_tokens // 0')
cache_creation=$(echo "$input" | jq -r '.current_usage.cache_creation_input_tokens // 0')

if [[ -z "$current_dir" || "$current_dir" == "null" ]]; then
    echo "ERROR: missing workspace.current_dir" >&2
    exit 1
fi

# Format directory path
if [[ "$current_dir" == "$HOME"/* ]]; then
    dir_display="~${current_dir#$HOME}"
else
    dir_display="$current_dir"
fi

# ============================================================================
# 2. TEMP FILES (unique per PID to avoid collisions)
# ============================================================================
TMP="/tmp/sl_$$"
trap 'rm -f ${TMP}_*.json ${TMP}_*.txt 2>/dev/null' EXIT

# ============================================================================
# 3. LAUNCH ALL EXTERNAL CALLS IN PARALLEL
# ============================================================================
# Compute YYYYMMDD dates for ccusage --since (requires this format, not "7d")
SINCE_7D=$(date -v-7d +%Y%m%d)
SINCE_30D=$(date -v-30d +%Y%m%d)

bunx ccusage blocks --active --json          > "${TMP}_blocks.json"  2>/dev/null &
bunx ccusage session --json                  > "${TMP}_session.json"  2>/dev/null &
bunx ccusage daily --since "$SINCE_7D" --json  > "${TMP}_daily7.json"   2>/dev/null &
bunx ccusage daily --since "$SINCE_30D" --json > "${TMP}_daily30.json"  2>/dev/null &

# Usage limits API (requires OAuth token from keychain)
(
    token_raw=$(security find-generic-password -s "Claude Code-credentials" -w 2>/dev/null || true)
    if [[ -n "$token_raw" ]]; then
        access_token=$(echo "$token_raw" | jq -r '.claudeAiOauth.accessToken // .accessToken // .access_token // empty' 2>/dev/null)
        if [[ -n "$access_token" && "$access_token" != "null" ]]; then
            curl -s --max-time 5 \
                -H "Authorization: Bearer $access_token" \
                -H "Content-Type: application/json" \
                -H "anthropic-beta: oauth-2025-04-20" \
                -H "Accept: application/json" \
                "https://api.anthropic.com/api/oauth/usage"
        fi
    fi
) > "${TMP}_usage.json" 2>/dev/null &

claude --version > "${TMP}_version.txt" 2>/dev/null &

# ============================================================================
# 4. GIT COMMANDS (fast, <0.05s total)
# ============================================================================
cd "$current_dir" 2>/dev/null || true

branch=$(git symbolic-ref --short HEAD 2>/dev/null || echo "")
if [[ -n "$branch" ]]; then
    if git diff --quiet 2>/dev/null && git diff --cached --quiet 2>/dev/null; then
        git_status="clean"
    else
        git_status="dirty"
    fi
    commits_today=$(git log --since="today 00:00" --oneline 2>/dev/null | wc -l | tr -d ' ')
else
    git_status="not_git"
    commits_today="0"
fi

# ============================================================================
# 5. WAIT FOR ALL BACKGROUND JOBS
# ============================================================================
wait

# ============================================================================
# 6. PARSE ALL JSON RESULTS
# ============================================================================

# --- REPO cost (from session data, match by current_dir path) ---
session_id=$(echo "$current_dir" | sed 's|/|-|g')
repo_cost=$(jq -r --arg sid "$session_id" \
    '[.sessions[]? | select(.sessionId | contains($sid))] | map(.totalCost // 0) | add // 0' \
    "${TMP}_session.json" 2>/dev/null || echo "0")
repo_cost=$(printf "%.2f" "$repo_cost" 2>/dev/null || echo "0.00")

# --- 30DAY cost ---
cost_30d=$(jq -r '.totals.totalCost // 0' "${TMP}_daily30.json" 2>/dev/null || echo "0")
cost_30d=$(printf "%.2f" "$cost_30d" 2>/dev/null || echo "0.00")

# --- 7DAY cost (total from 7d query) ---
cost_7d=$(jq -r '.totals.totalCost // 0' "${TMP}_daily7.json" 2>/dev/null || echo "0")
cost_7d=$(printf "%.2f" "$cost_7d" 2>/dev/null || echo "0.00")

# --- DAY cost (today only, from 7d data) ---
today_date=$(date +%Y-%m-%d)
cost_day=$(jq -r --arg d "$today_date" \
    '[.daily[]? | select(.date == $d)] | map(.totalCost // 0) | add // 0' \
    "${TMP}_daily7.json" 2>/dev/null || echo "0")
cost_day=$(printf "%.2f" "$cost_day" 2>/dev/null || echo "0.00")

# --- LIVE cost, burn rate, projection (from blocks) ---
live_cost=$(jq -r '.blocks[0].costUSD // 0' "${TMP}_blocks.json" 2>/dev/null || echo "0")
live_cost=$(printf "%.2f" "$live_cost" 2>/dev/null || echo "0.00")

burn_rate=$(jq -r '.blocks[0].burnRate.costPerHour // 0' "${TMP}_blocks.json" 2>/dev/null || echo "0")
burn_rate=$(printf "%.2f" "$burn_rate" 2>/dev/null || echo "0.00")

proj_cost=$(jq -r '.blocks[0].projection.totalCost // 0' "${TMP}_blocks.json" 2>/dev/null || echo "0")
proj_cost=$(printf "%.2f" "$proj_cost" 2>/dev/null || echo "0.00")

proj_tokens=$(jq -r '.blocks[0].projection.totalTokens // 0' "${TMP}_blocks.json" 2>/dev/null || echo "0")
proj_tokens_m=$(awk "BEGIN {printf \"%.1f\", $proj_tokens / 1000000}" 2>/dev/null || echo "0.0")

# --- Cache hit % (from stdin JSON) ---
cache_total=$((cache_read + cache_creation))
if [[ "$cache_total" -gt 0 ]]; then
    cache_pct=$(awk "BEGIN {printf \"%.0f\", $cache_read * 100 / $cache_total}")
else
    cache_pct="0"
fi

# --- Claude version ---
cc_version=$(head -1 "${TMP}_version.txt" 2>/dev/null | sed 's/ *(Claude Code).*$//' | sed 's/^[^0-9]*//')
[[ -z "$cc_version" ]] && cc_version="?.?.?"

# --- Usage limits ---
five_hour_pct=$(jq -r '.five_hour.utilization // empty' "${TMP}_usage.json" 2>/dev/null || true)
five_hour_pct=$(printf "%.0f" "${five_hour_pct:-0}" 2>/dev/null || echo "0")
five_hour_reset=$(jq -r '.five_hour.resets_at // empty' "${TMP}_usage.json" 2>/dev/null || true)

seven_day_pct=$(jq -r '.seven_day.utilization // empty' "${TMP}_usage.json" 2>/dev/null || true)
seven_day_pct=$(printf "%.0f" "${seven_day_pct:-0}" 2>/dev/null || echo "0")
seven_day_reset=$(jq -r '.seven_day.resets_at // empty' "${TMP}_usage.json" 2>/dev/null || true)

# Format reset times
format_reset() {
    local iso="$1"
    [[ -z "$iso" || "$iso" == "null" ]] && echo "" && return
    local cleaned
    cleaned=$(echo "$iso" | sed 's/\.[0-9]*//')
    local mac_ts
    mac_ts=$(echo "$cleaned" | sed 's/+00:00/+0000/; s/Z$/+0000/; s/+\([0-9][0-9]\):\([0-9][0-9]\)/+\1\2/')
    local epoch
    epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$mac_ts" "+%s" 2>/dev/null || echo "")
    [[ -z "$epoch" ]] && echo "" && return
    local now diff
    now=$(date "+%s")
    diff=$((epoch - now))
    if [[ "$diff" -le 0 ]]; then
        echo "now"
    elif [[ "$diff" -lt 3600 ]]; then
        echo "$((diff / 60)) min"
    elif [[ "$diff" -lt 86400 ]]; then
        local h=$((diff / 3600)) m=$(((diff % 3600) / 60))
        [[ "$m" -gt 0 ]] && echo "${h} hr ${m} min" || echo "${h} hr"
    else
        date -j -f "%s" "$epoch" "+%a %H:%M" 2>/dev/null
    fi
}

clock_time() {
    local iso="$1"
    [[ -z "$iso" || "$iso" == "null" ]] && echo "" && return
    local cleaned
    cleaned=$(echo "$iso" | sed 's/\.[0-9]*//')
    local mac_ts
    mac_ts=$(echo "$cleaned" | sed 's/+00:00/+0000/; s/Z$/+0000/; s/+\([0-9][0-9]\):\([0-9][0-9]\)/+\1\2/')
    local epoch
    epoch=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$mac_ts" "+%s" 2>/dev/null || echo "")
    [[ -z "$epoch" ]] && echo "" && return
    date -j -f "%s" "$epoch" "+%H:%M" 2>/dev/null
}

five_hr_remaining=$(format_reset "$five_hour_reset")
five_hr_clock=$(clock_time "$five_hour_reset")
seven_day_remaining=$(format_reset "$seven_day_reset")

# ============================================================================
# 7. FORMAT AND OUTPUT 5 LINES
# ============================================================================

# Model emoji
case "$model_name" in
    *Opus*|*opus*)     model_emoji="🎭" ;;
    *Haiku*|*haiku*)   model_emoji="🌸" ;;
    *Sonnet*|*sonnet*) model_emoji="📝" ;;
    *)                 model_emoji="🤖" ;;
esac

# Git status display
if [[ "$git_status" == "clean" ]]; then
    branch_display="${C_GREEN}(${branch})${C_RESET} ${C_GREEN}✅${C_RESET}"
elif [[ "$git_status" == "dirty" ]]; then
    branch_display="${C_YELLOW}(${branch})${C_RESET} ${C_YELLOW}✏️${C_RESET}"
else
    branch_display="${C_GRAY}(no git)${C_RESET}"
fi

# Current time
now_time=$(date +%H:%M)

# Color helper for usage percentages
color_pct() {
    local pct="$1"
    if [[ "$pct" -ge 80 ]]; then
        echo "${C_RED}${pct}%${C_RESET}"
    elif [[ "$pct" -ge 50 ]]; then
        echo "${C_YELLOW}${pct}%${C_RESET}"
    else
        echo "${C_GREEN}${pct}%${C_RESET}"
    fi
}

# --- LINE 1: Path + branch ---
echo -e "${C_BLUE}${dir_display}${C_RESET} ${branch_display}"

# --- LINE 2: Model | Commits | CC version | Time ---
echo -e "${model_emoji} ${C_CYAN}${model_name}${C_RESET} ${SEP} Commits:${C_GREEN}${commits_today}${C_RESET} ${SEP} CC:${C_TEAL}${cc_version}${C_RESET} ${SEP} 🕐 ${C_WHITE}${now_time}${C_RESET}"

# --- LINE 3: Cost summary ---
echo -e "REPO ${C_ORANGE}\$${repo_cost}${C_RESET} ${SEP} 30DAY ${C_MAGENTA}\$${cost_30d}${C_RESET} ${SEP} 7DAY ${C_BLUE}\$${cost_7d}${C_RESET} ${SEP} DAY ${C_YELLOW}\$${cost_day}${C_RESET} ${SEP} 🔥LIVE ${C_RED}\$${live_cost}${C_RESET}"

# --- LINE 4: Burn rate | Cache | Projection ---
echo -e "🔥${C_ORANGE}\$${burn_rate}/hr${C_RESET} ${SEP} Cache: ${C_TEAL}${cache_pct}% hit${C_RESET} ${SEP} Est: ${C_MAGENTA}\$${proj_cost}${C_RESET} (${C_CYAN}${proj_tokens_m}M${C_RESET})"

# --- LINE 5: MCP + Usage limits ---
line5="MCP:${C_GRAY}?/?${C_RESET}"

if [[ -n "$five_hour_pct" && "$five_hour_pct" != "0" ]]; then
    five_colored=$(color_pct "$five_hour_pct")
    if [[ -n "$five_hr_clock" && "$five_hr_remaining" != "now" && -n "$five_hr_remaining" ]]; then
        line5="${line5} ${SEP} ⏱ 5H at ${five_hr_clock} (${five_hr_remaining}) ${five_colored}"
    elif [[ -n "$five_hr_remaining" ]]; then
        line5="${line5} ${SEP} ⏱ 5H ${five_hr_remaining} (${five_colored})"
    else
        line5="${line5} ${SEP} ⏱ 5H ${five_colored}"
    fi
fi

if [[ -n "$seven_day_pct" && "$seven_day_pct" != "0" ]]; then
    seven_colored=$(color_pct "$seven_day_pct")
    if [[ -n "$seven_day_remaining" && "$seven_day_remaining" != "now" ]]; then
        line5="${line5} • 7DAY ${seven_day_remaining} (${seven_colored})"
    else
        line5="${line5} • 7DAY (${seven_colored})"
    fi
fi

echo -e "$line5"

exit 0
