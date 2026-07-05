#!/bin/bash

# Export Proxy List

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
OUTPUT_FILE="$SCRIPT_DIR/../proxies.txt"

# Get server's public IPv4
echo "🔍 Detecting public IPv4 address..."
PUBLIC_IP=$(curl -s https://api.ipify.org)

if [ -z "$PUBLIC_IP" ]; then
    echo "⚠️  Could not detect public IP. Using 152.42.134.66 as example."
    PUBLIC_IP="152.42.134.66"
fi

echo "Public IP: $PUBLIC_IP"
echo ""
echo "📝 Generating proxy list..."

# Generate proxy list
> "$OUTPUT_FILE"
for PORT in $(seq 12000 12499); do
    echo "$PUBLIC_IP:$PORT" >> "$OUTPUT_FILE"
done

echo "✅ Proxy list saved to: $OUTPUT_FILE"
echo ""
echo "Total proxies: 500"
echo ""
echo "Preview (first 10):"
head -10 "$OUTPUT_FILE"
echo "..."
echo ""
echo "📋 Copy proxy list:"
echo "   cat $OUTPUT_FILE"
