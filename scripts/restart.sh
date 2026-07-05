#!/bin/bash

# Restart IPv6 Proxy Pool

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🔄 Restarting IPv6 Proxy Pool..."
echo ""

"$SCRIPT_DIR/stop.sh"
sleep 2
"$SCRIPT_DIR/start.sh"
