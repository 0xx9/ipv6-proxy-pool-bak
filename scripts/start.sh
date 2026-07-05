#!/bin/bash

# Start IPv6 Proxy Pool

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVER_DIR="$SCRIPT_DIR/../server"
PID_FILE="$SCRIPT_DIR/../proxy-pool.pid"
LOG_FILE="$SCRIPT_DIR/../proxy-pool.log"

echo "================================"
echo "Starting IPv6 Proxy Pool"
echo "================================"
echo ""

# Check if already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "⚠️  Proxy pool is already running (PID: $PID)"
        echo "Run ./scripts/stop.sh first to restart"
        exit 1
    else
        echo "🧹 Cleaning up stale PID file..."
        rm -f "$PID_FILE"
    fi
fi

# Check if server file exists
if [ ! -f "$SERVER_DIR/proxy-server.js" ]; then
    echo "❌ Server file not found: $SERVER_DIR/proxy-server.js"
    exit 1
fi

echo "🚀 Starting proxy server..."

cd "$SERVER_DIR"

# Start server in background
nohup node proxy-server.js > "$LOG_FILE" 2>&1 &
PID=$!

echo $PID > "$PID_FILE"

# Wait a moment and check if it's still running
sleep 2

if ps -p "$PID" > /dev/null 2>&1; then
    echo "✅ Proxy pool started successfully!"
    echo ""
    echo "PID: $PID"
    echo "Log: $LOG_FILE"
    echo ""
    echo "📊 Status:"
    echo "   Ports: 12000-12099 (100 proxies)"
    echo ""
    echo "📝 View logs: tail -f $LOG_FILE"
    echo "🛑 Stop: sudo ./scripts/stop.sh"
else
    echo "❌ Failed to start proxy server"
    echo "Check log: cat $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
