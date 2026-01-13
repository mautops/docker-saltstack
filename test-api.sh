#!/bin/bash
# Test script for Salt API
# This demonstrates how to use the Salt API from external applications

set -e

API_URL="http://localhost:8000"
USERNAME="salt"
PASSWORD="${SALT_SHARED_SECRET:-changeme_insecure_default}"

echo "==================================="
echo "Salt API Test Script"
echo "==================================="
echo ""

# Step 1: Login and get token
echo "1. Logging in to Salt API..."
LOGIN_RESPONSE=$(curl -sSk "${API_URL}/login" \
  -H "Accept: application/json" \
  -d username="${USERNAME}" \
  -d password="${PASSWORD}" \
  -d eauth=sharedsecret)

TOKEN=$(echo "${LOGIN_RESPONSE}" | grep -o '"token":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "ERROR: Failed to get authentication token"
  echo "Response: ${LOGIN_RESPONSE}"
  exit 1
fi

echo "✓ Successfully authenticated"
echo "Token: ${TOKEN:0:20}..."
echo ""

# Step 2: Test ping
echo "2. Testing minion connectivity (test.ping)..."
PING_RESPONSE=$(curl -sSk "${API_URL}" \
  -H "Accept: application/json" \
  -H "X-Auth-Token: ${TOKEN}" \
  -d client=local \
  -d tgt='*' \
  -d fun=test.ping)

echo "Response: ${PING_RESPONSE}"
echo ""

# Step 3: Get minion status
echo "3. Getting minion grains (basic info)..."
GRAINS_RESPONSE=$(curl -sSk "${API_URL}" \
  -H "Accept: application/json" \
  -H "X-Auth-Token: ${TOKEN}" \
  -d client=local \
  -d tgt='*' \
  -d fun=grains.item \
  -d arg=os \
  -d arg=osrelease)

echo "Response: ${GRAINS_RESPONSE}"
echo ""

echo "==================================="
echo "API Test Complete!"
echo "==================================="
echo ""
echo "You can now use this API from any application that can make HTTP requests."
echo "See README.md for more examples and production security recommendations."
