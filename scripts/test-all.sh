#!/bin/bash

# Test All Proxies

echo "================================"
echo "Testing All Proxies"
echo "================================"
echo ""

FAILED=0
SUCCESS=0

echo "Testing 10 random proxies out of 100..."
echo ""

for i in $(seq 0 9); do
    PORT=$((12000 + i * 10))
    echo -n "Testing port $PORT... "
    
    RESULT=$(curl -x "localhost:$PORT" -s --connect-timeout 5 https://api64.ipify.org 2>&1)
    
    if [ $? -eq 0 ]; then
        echo "✅ OK - IP: $RESULT"
        ((SUCCESS++))
    else
        echo "❌ FAILED"
        ((FAILED++))
    fi
done

echo ""
echo "================================"
echo "Results:"
echo "  Success: $SUCCESS/10"
echo "  Failed: $FAILED/10"
echo "================================"

if [ $FAILED -eq 0 ]; then
    echo "✅ All tested proxies are working!"
else
    echo "⚠️  Some proxies failed. Check server logs."
fi
