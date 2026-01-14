#!/bin/bash
# API helper functions

# Make API call to root endpoint
call_api() {
    curl -sSk "${API_URL}" \
        -H "Accept: application/json" \
        -H "X-Auth-Token: ${TOKEN}" \
        "$@"
}

# Make API call to specific endpoint
call_endpoint() {
    local endpoint="$1"
    shift
    curl -sSk "${API_URL}${endpoint}" \
        -H "Accept: application/json" \
        -H "X-Auth-Token: ${TOKEN}" \
        "$@"
}

# Login and get token
api_login() {
    local username="$1"
    local password="$2"
    
    curl -sSk "${API_URL}/login" \
        -H "Accept: application/json" \
        -d "username=${username}" \
        -d "password=${password}" \
        -d "eauth=sharedsecret"
}

# Execute command on minions
api_exec() {
    local target="$1"
    local function="$2"
    shift 2
    
    local args=()
    for arg in "$@"; do
        args+=(-d "arg=${arg}")
    done
    
    call_api \
        -d "client=local" \
        -d "tgt=${target}" \
        -d "fun=${function}" \
        "${args[@]}"
}

# Execute runner function
api_runner() {
    local function="$1"
    shift
    
    local args=()
    for arg in "$@"; do
        args+=(-d "arg=${arg}")
    done
    
    call_api \
        -d "client=runner" \
        -d "fun=${function}" \
        "${args[@]}"
}

# Execute wheel function
api_wheel() {
    local function="$1"
    shift
    
    local args=()
    for arg in "$@"; do
        args+=(-d "arg=${arg}")
    done
    
    call_api \
        -d "client=wheel" \
        -d "fun=${function}" \
        "${args[@]}"
}

# Execute async command
api_exec_async() {
    local target="$1"
    local function="$2"
    shift 2
    
    local args=()
    for arg in "$@"; do
        args+=(-d "arg=${arg}")
    done
    
    call_api \
        -d "client=local_async" \
        -d "tgt=${target}" \
        -d "fun=${function}" \
        "${args[@]}" 2>&1
}
