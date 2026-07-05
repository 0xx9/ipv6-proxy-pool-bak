#!/bin/bash

# Stop IPv6 Proxy Pool

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/../proxy-pool.pid"

echo "================================"
echo "Stopping IPv6 Proxy Pool"
echo "================================"
echo ""

if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  No PID file found. Proxy pool may not be running."
    
    # Try to find and kill any running instances
    PIDS=$(pgrep -f "proxy-server.js")
    if [ -n "$PIDS" ]; then
        echo "Found running processes: $PIDS"
        read -p "Kill these processes? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill $PIDS
            echo "✅ Processes terminated"
        fi
    fi
    exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" > /dev/null 2>&1; then
    echo "🛑 Stopping proxy pool (PID: $PID)..."
    kill "$PID"
    
    # Wait for process to stop
    for i in {1..10}; do
        if ! ps -p "$PID" > /dev/null 2>&1; then
            break
        fi
        sleep 1
    done
    
    # Force kill if still running
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  Process did not stop gracefully, forcing..."
        kill -9 "$PID"
    fi
    
    rm -f "$PID_FILE"
    echo "✅ Proxy pool stopped successfully"
else
    echo "⚠️  Process $PID is not running"
    rm -f "$PID_FILE"
fi
