#!/bin/bash

# Stop IPv6 Proxy Pool API Server

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/../api-server.pid"

echo "================================"
echo "Stopping IPv6 Proxy Pool API"
echo "================================"
echo ""

if [ ! -f "$PID_FILE" ]; then
    echo "⚠️  No PID file found. API server may not be running."
    
    # Try to find and kill any running instances
    PIDS=$(pgrep -f "api/server.js")
    if [ -n "$PIDS" ]; then
        echo "Found running processes: $PIDS"
        kill $PIDS
        echo "✅ Processes terminated"
    fi
    exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" > /dev/null 2>&1; then
    echo "🛑 Stopping API server (PID: $PID)..."
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
    echo "✅ API server stopped successfully"
else
    echo "⚠️  Process $PID is not running"
    rm -f "$PID_FILE"
fi
