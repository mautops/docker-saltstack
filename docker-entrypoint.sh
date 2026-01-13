#!/bin/bash
set -e

# Start salt-master in the background
echo "Starting salt-master..."
salt-master -l debug &
MASTER_PID=$!

# Wait a bit for salt-master to initialize
sleep 5

# Start salt-api in the foreground
echo "Starting salt-api..."
salt-api -l debug &
API_PID=$!

# Wait for either process to exit
wait -n $MASTER_PID $API_PID

# Exit with status of process that exited first
exit $?
