#!/bin/bash
# Utility functions for test script

# Get the directory of this script (lib directory)
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=colors.sh
source "${LIB_DIR}/colors.sh"

# Print functions
print_header() {
    local text="$1"
    echo -e "${COLOR_BOLD_CYAN}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo "  ${text}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "${COLOR_RESET}"
}

print_section() {
    local step="$1"
    local title="$2"
    echo -e "${COLOR_BOLD_BLUE}───────────────────────────────────────────────────────────────────────────────${COLOR_RESET}"
    echo -e "${COLOR_BOLD_YELLOW}[${step}]${COLOR_RESET} ${COLOR_BOLD}${title}${COLOR_RESET}"
    echo -e "${COLOR_DIM}$(date '+%Y-%m-%d %H:%M:%S')${COLOR_RESET}"
    echo ""
}

print_success() {
    echo -e "${COLOR_BOLD_GREEN}✓${COLOR_RESET} $*"
}

print_error() {
    echo -e "${COLOR_BOLD_RED}✗${COLOR_RESET} $*"
}

print_warning() {
    echo -e "${COLOR_BOLD_YELLOW}⚠${COLOR_RESET} $*"
}

print_info() {
    echo -e "${COLOR_CYAN}ℹ${COLOR_RESET} $*"
}

print_result() {
    local result="$1"
    if [[ -n "${result}" ]]; then
        echo -e "${COLOR_DIM}${result}${COLOR_RESET}"
    fi
}

print_separator() {
    echo ""
}

print_footer() {
    echo -e "${COLOR_BOLD_CYAN}"
    echo "═══════════════════════════════════════════════════════════════════════════════"
    echo -e "${COLOR_RESET}"
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Extract token from login response
extract_token() {
    local response="$1"
    local token=""
    
    if command_exists jq; then
        token=$(echo "${response}" | jq -r '.return[0].token // empty' 2>/dev/null)
    else
        token=$(echo "${response}" | grep -o '"token":"[^"]*' | head -1 | cut -d'"' -f4)
    fi
    
    echo "${token}"
}

# Check if response is valid JSON
is_valid_json() {
    local response="$1"
    echo "${response}" | grep -q '"return"'
}

# Truncate long output
truncate_output() {
    local output="$1"
    local max_lines="${2:-20}"
    local line_count
    
    line_count=$(echo "${output}" | wc -l)
    
    if [[ ${line_count} -gt ${max_lines} ]]; then
        echo "${output}" | head -n "${max_lines}"
        echo -e "${COLOR_DIM}... (${line_count} lines total, showing first ${max_lines})${COLOR_RESET}"
    else
        echo "${output}"
    fi
}
