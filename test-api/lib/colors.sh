#!/bin/bash
# Color definitions for terminal output

# Prevent multiple loading
if [[ -n "${COLORS_LOADED:-}" ]]; then
    return 0
fi
readonly COLORS_LOADED=1

# Check if terminal supports colors
if [[ -t 1 ]] && command -v tput &> /dev/null && tput setaf 1 &> /dev/null; then
    # Colors
    COLOR_RESET='\033[0m'
    COLOR_BOLD='\033[1m'
    COLOR_DIM='\033[2m'
    
    # Foreground colors
    COLOR_RED='\033[0;31m'
    COLOR_GREEN='\033[0;32m'
    COLOR_YELLOW='\033[0;33m'
    COLOR_BLUE='\033[0;34m'
    COLOR_MAGENTA='\033[0;35m'
    COLOR_CYAN='\033[0;36m'
    COLOR_WHITE='\033[0;37m'
    
    # Bold colors
    COLOR_BOLD_RED='\033[1;31m'
    COLOR_BOLD_GREEN='\033[1;32m'
    COLOR_BOLD_YELLOW='\033[1;33m'
    COLOR_BOLD_BLUE='\033[1;34m'
    COLOR_BOLD_MAGENTA='\033[1;35m'
    COLOR_BOLD_CYAN='\033[1;36m'
else
    # No color support
    COLOR_RESET=''
    COLOR_BOLD=''
    COLOR_DIM=''
    COLOR_RED=''
    COLOR_GREEN=''
    COLOR_YELLOW=''
    COLOR_BLUE=''
    COLOR_MAGENTA=''
    COLOR_CYAN=''
    COLOR_WHITE=''
    COLOR_BOLD_RED=''
    COLOR_BOLD_GREEN=''
    COLOR_BOLD_YELLOW=''
    COLOR_BOLD_BLUE=''
    COLOR_BOLD_MAGENTA=''
    COLOR_BOLD_CYAN=''
fi

# Export for use in other scripts
export COLOR_RESET COLOR_BOLD COLOR_DIM
export COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE COLOR_MAGENTA COLOR_CYAN COLOR_WHITE
export COLOR_BOLD_RED COLOR_BOLD_GREEN COLOR_BOLD_YELLOW COLOR_BOLD_BLUE COLOR_BOLD_MAGENTA COLOR_BOLD_CYAN
