#!/bin/bash
# Common functions and configuration for all tests

# Get library directory
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load libraries
source "${LIB_DIR}/colors.sh"
source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/api.sh"

# Configuration
export API_URL="${API_URL:-http://localhost:8000}"
export USERNAME="${USERNAME:-salt}"
export PASSWORD="${SALT_SHARED_SECRET:-changeme_insecure_default}"

# Token file location
export TOKEN_FILE="${LIB_DIR}/../.token"

# Load token from file
load_token() {
    if [[ -f "${TOKEN_FILE}" ]]; then
        TOKEN=$(cat "${TOKEN_FILE}")
        export TOKEN
    else
        print_error "Token file not found. Please run 01-auth-login.sh first."
        exit 1
    fi
}

# Print test header
print_test_header() {
    local name="$1"
    local endpoint="$2"
    
    echo ""
    print_section "TEST" "${name}"
    print_info "Endpoint: ${endpoint}"
    print_info "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
}

# Print test footer
print_test_footer() {
    echo ""
    print_separator
}
