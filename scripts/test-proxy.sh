#!/bin/bash

# Test Single Proxy

if [ -z "$1" ]; then
    echo "Usage: ./test-proxy.sh <port>"
    echo "Example: ./test-proxy.sh 12000"
    exit 1
fi

PORT=$1

echo "Testing proxy on port $PORT..."
echo ""

# Test HTTP proxy
echo "🧪 Testing HTTP connection..."
RESULT=$(curl -x "localhost:$PORT" -s https://api64.ipify.org?format=json 2>&1)

if [ $? -eq 0 ]; then
    echo "✅ Proxy is working!"
    echo "Exit IP: $RESULT"
else
    echo "❌ Proxy test failed"
    echo "Error: $RESULT"
    exit 1
fi

echo ""
echo "🌐 Testing with ipify.org..."
curl -x "localhost:$PORT" -s https://ipify.org

echo ""
echo ""
echo "✅ Test complete for port $PORT"
