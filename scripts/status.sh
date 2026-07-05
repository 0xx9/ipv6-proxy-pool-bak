#!/bin/bash

# Check Proxy Pool Status

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PID_FILE="$SCRIPT_DIR/../proxy-pool.pid"
LOG_FILE="$SCRIPT_DIR/../proxy-pool.log"
CONFIG_FILE="$SCRIPT_DIR/../config/ipv6.conf"

echo "================================"
echo "IPv6 Proxy Pool - Status"
echo "================================"
echo ""

# Check if running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "🟢 Status: RUNNING"
        echo "📍 PID: $PID"
        
        # Get memory usage
        MEM=$(ps -p "$PID" -o rss= | awk '{print $1/1024 " MB"}')
        echo "💾 Memory: $MEM"
        
        # Get CPU usage
        CPU=$(ps -p "$PID" -o %cpu= | awk '{print $1 "%"}')
        echo "⚡ CPU: $CPU"
    else
        echo "🔴 Status: STOPPED (stale PID file)"
    fi
else
    echo "🔴 Status: STOPPED"
fi

echo ""
echo "📊 Configuration:"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    echo "   Subnet: $IPV6_SUBNET"
    echo "   Interface: $INTERFACE"
    echo "   Ports: $START_PORT-$END_PORT"
fi

echo ""
echo "🌐 IPv6 Addresses:"
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
    COUNT=$(ip -6 addr show dev "$INTERFACE" 2>/dev/null | grep "$IPV6_SUBNET" | wc -l)
    echo "   Configured: $COUNT/500"
fi

echo ""
echo "📝 Recent Logs:"
if [ -f "$LOG_FILE" ]; then
    tail -5 "$LOG_FILE"
else
    echo "   No log file found"
fi

echo ""
