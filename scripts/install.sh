#!/bin/bash

# IPv6 Proxy Pool - Installation Script

set -e

echo "================================"
echo "IPv6 Proxy Pool - Installation"
echo "================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (sudo ./install.sh)"
    exit 1
fi

# Check if IPv6 is enabled
if ! ip -6 addr show | grep -q "inet6"; then
    echo "⚠️  WARNING: IPv6 does not appear to be enabled on this system"
    echo "Please enable IPv6 before continuing"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

echo "📦 Installing dependencies..."

# Detect OS
if [ -f /etc/debian_version ]; then
    # Debian/Ubuntu
    apt-get update
    apt-get install -y nodejs npm curl net-tools iproute2
elif [ -f /etc/redhat-release ]; then
    # CentOS/RHEL
    yum install -y nodejs npm curl net-tools iproute
else
    echo "⚠️  Unsupported OS. Please install: nodejs, npm, curl, net-tools manually"
fi

echo ""
echo "📦 Installing Node.js dependencies..."
cd "$(dirname "$0")/../server"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Creating package.json..."
    npm init -y
fi

# Install required packages
npm install http-proxy http socks express

echo ""
echo "🔧 Setting up permissions..."
cd "$(dirname "$0")/.."
chmod +x scripts/*.sh

echo ""
echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "1. Edit config/ipv6.conf with your IPv6 subnet"
echo "2. Run: sudo ./scripts/setup-ipv6.sh"
echo "3. Run: sudo ./scripts/start.sh"
echo ""
