#!/bin/bash
set -e

# Start salt-minion in the background
echo "Starting salt-minion..."
salt-minion -l debug &
MINION_PID=$!

# Wait for salt-minion to initialize
sleep 3

# Start Node Exporter in the background
echo "Starting Node Exporter..."
/usr/local/node_exporter/node_exporter \
  --web.listen-address=:9100 \
  --web.telemetry-path=/metrics &
NODE_EXPORTER_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "Shutting down..."
    kill $MINION_PID $NODE_EXPORTER_PID 2>/dev/null || true
    wait $MINION_PID $NODE_EXPORTER_PID 2>/dev/null || true
}

trap cleanup SIGTERM SIGINT EXIT

# Wait for both processes
while kill -0 $MINION_PID 2>/dev/null && kill -0 $NODE_EXPORTER_PID 2>/dev/null; do
    sleep 2
done

# If we get here, one process has died
echo "ERROR: One of the processes has exited unexpectedly"
exit 1