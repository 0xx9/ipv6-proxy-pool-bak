#!/bin/bash

# Install systemd service

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (sudo ./install-service.sh)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SERVICE_FILE="$SCRIPT_DIR/../ipv6-proxy-pool.service"

echo "================================"
echo "Installing systemd service"
echo "================================"
echo ""

if [ ! -f "$SERVICE_FILE" ]; then
    echo "❌ Service file not found: $SERVICE_FILE"
    exit 1
fi

echo "📋 Copying service file..."
cp "$SERVICE_FILE" /etc/systemd/system/

echo "🔄 Reloading systemd daemon..."
systemctl daemon-reload

echo "✅ Service installed successfully!"
echo ""
echo "Available commands:"
echo "  sudo systemctl start ipv6-proxy-pool     - Start service"
echo "  sudo systemctl stop ipv6-proxy-pool      - Stop service"
echo "  sudo systemctl enable ipv6-proxy-pool    - Enable auto-start"
echo "  sudo systemctl status ipv6-proxy-pool    - Check status"
echo ""
echo "To enable auto-start on boot:"
echo "  sudo systemctl enable ipv6-proxy-pool"
echo ""
