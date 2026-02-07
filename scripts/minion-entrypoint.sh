#!/bin/bash
# 不使用 set -e，避免因单个命令失败而退出

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

# Start Filebeat in the background
echo "Starting Filebeat for log collection..."
filebeat -c /etc/filebeat/filebeat.yml -e &
FILEBEAT_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "Shutting down..."
    kill $MINION_PID $NODE_EXPORTER_PID $FILEBEAT_PID 2>/dev/null || true
    wait $MINION_PID $NODE_EXPORTER_PID $FILEBEAT_PID 2>/dev/null || true
}

trap cleanup SIGTERM SIGINT EXIT

# Monitor processes - only exit if critical processes die
while true; do
    # Check if Node Exporter is still running (critical for monitoring)
    if ! kill -0 $NODE_EXPORTER_PID 2>/dev/null; then
        echo "ERROR: Node Exporter has exited unexpectedly"
        exit 1
    fi
    
    # Check if Filebeat is still running (critical for logging)
    if ! kill -0 $FILEBEAT_PID 2>/dev/null; then
        echo "ERROR: Filebeat has exited unexpectedly"
        exit 1
    fi
    
    # Salt minion failures are logged but don't stop the container
    if ! kill -0 $MINION_PID 2>/dev/null; then
        echo "WARNING: Salt minion has exited, continuing to run monitoring services..."
        # Remove minion PID from cleanup
        MINION_PID=""
    fi
    
    sleep 5
done