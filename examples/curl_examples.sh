#!/bin/bash

# cURL Examples for IPv6 Proxy Pool

# Your server's public IPv4
PROXY_HOST="152.42.134.66"  # Change this to your server IP

echo "================================"
echo "IPv6 Proxy Pool - cURL Examples"
echo "================================"
echo ""

# Example 1: Simple request through proxy
echo "Example 1: Check your IP through proxy"
echo "---------------------------------------"
curl -x "$PROXY_HOST:12000" https://api.ipify.org?format=json
echo ""
echo ""

# Example 2: Multiple requests with different proxies
echo "Example 2: Different IPs from different proxies"
echo "------------------------------------------------"
for PORT in 12000 12001 12002 12003 12004; do
    echo -n "Port $PORT: "
    curl -s -x "$PROXY_HOST:$PORT" https://api.ipify.org
    echo ""
done
echo ""

# Example 3: Fetch website through proxy
echo "Example 3: Fetch website through proxy"
echo "---------------------------------------"
curl -x "$PROXY_HOST:12010" -L https://example.com | head -20
echo ""
echo ""

# Example 4: HTTPS request through proxy
echo "Example 4: HTTPS request"
echo "------------------------"
curl -x "$PROXY_HOST:12020" https://httpbin.org/ip
echo ""
echo ""

# Example 5: Custom headers through proxy
echo "Example 5: Custom headers"
echo "-------------------------"
curl -x "$PROXY_HOST:12030" \
     -H "User-Agent: Custom Bot 1.0" \
     https://httpbin.org/headers
echo ""
