#!/bin/bash

# Start IPv6 Proxy Pool API Server

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
API_DIR="$SCRIPT_DIR/../api"
PID_FILE="$SCRIPT_DIR/../api-server.pid"
LOG_FILE="$SCRIPT_DIR/../api-server.log"

echo "================================"
echo "Starting IPv6 Proxy Pool API"
echo "================================"
echo ""

# Check if already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  API server is already running (PID: $PID)"
        echo "Run ./scripts/stop-api.sh first to restart"
        exit 1
    else
        echo "🧹 Cleaning up stale PID file..."
        rm -f "$PID_FILE"
    fi
fi

# Check if server file exists
if [ ! -f "$API_DIR/server.js" ]; then
    echo "❌ Server file not found: $API_DIR/server.js"
    exit 1
fi

echo "🚀 Starting API server..."

cd "$API_DIR"

# Start server in background
nohup node server.js > "$LOG_FILE" 2>&1 &
PID=$!

echo $PID > "$PID_FILE"

# Wait a moment and check if it's still running
sleep 2

if ps -p "$PID" > /dev/null 2>&1; then
    echo "✅ API server started successfully!"
    echo ""
    echo "PID: $PID"
    echo "Port: 8080"
    echo "Log: $LOG_FILE"
    echo ""
    echo "📡 Endpoints:"
    echo "   http://YOUR_IP:8080/api/v1/data/proxy/ip2.txt"
    echo "   http://YOUR_IP:8080/api/v1/proxies"
    echo "   http://YOUR_IP:8080/proxies.txt"
    echo ""
    echo "📝 View logs: tail -f $LOG_FILE"
    echo "🛑 Stop: ./scripts/stop-api.sh"
else
    echo "❌ Failed to start API server"
    echo "Check log: cat $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
