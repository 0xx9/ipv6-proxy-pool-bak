#!/bin/bash

# IPv6 Address Setup Script

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (sudo ./setup-ipv6.sh)"
    exit 1
fi

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/ipv6.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Configuration file not found: $CONFIG_FILE"
    exit 1
fi

source "$CONFIG_FILE"

echo "================================"
echo "IPv6 Address Setup"
echo "================================"
echo ""
echo "Subnet: $IPV6_SUBNET"
echo "Interface: $INTERFACE"
echo "Port Range: $START_PORT-$END_PORT"
echo ""

# Validate IPv6 subnet format
if [[ ! $IPV6_SUBNET =~ ^[0-9a-fA-F:]+$ ]]; then
    echo "❌ Invalid IPv6 subnet format"
    exit 1
fi

# Check if interface exists
if ! ip link show "$INTERFACE" &> /dev/null; then
    echo "❌ Network interface $INTERFACE does not exist"
    echo "Available interfaces:"
    ip -o link show | awk '{print $2}' | sed 's/://'
    exit 1
fi

echo "🔧 Configuring IPv6 addresses..."

# Remove old addresses (cleanup)
echo "Cleaning up old addresses..."
for i in $(seq 0 499); do
    IPV6_ADDR="$IPV6_SUBNET::$(printf '%x' $((i + 1)))"
    ip -6 addr del "$IPV6_ADDR/64" dev "$INTERFACE" 2>/dev/null || true
done

# Add 500 IPv6 addresses
for i in $(seq 0 499); do
    IPV6_ADDR="$IPV6_SUBNET::$(printf '%x' $((i + 1)))"
    
    if ! ip -6 addr show dev "$INTERFACE" | grep -q "$IPV6_ADDR"; then
        ip -6 addr add "$IPV6_ADDR/64" dev "$INTERFACE"
        echo "✅ Added: $IPV6_ADDR"
    else
        echo "⏭️  Already exists: $IPV6_ADDR"
    fi
done

echo ""
echo "🧪 Testing IPv6 connectivity..."

# Test IPv6 connectivity
TEST_IPV6="$IPV6_SUBNET::1"
if ping6 -c 1 -I "$TEST_IPV6" google.com &> /dev/null; then
    echo "✅ IPv6 connectivity working!"
else
    echo "⚠️  Warning: Could not ping google.com via IPv6"
    echo "This might be normal depending on your network configuration"
fi

echo ""
echo "📋 Configured IPv6 addresses:"
ip -6 addr show dev "$INTERFACE" | grep "$IPV6_SUBNET" | head -10
echo "... (90 more addresses)"

echo ""
echo "✅ IPv6 setup complete!"
echo ""
echo "💾 Making configuration persistent..."

# Create startup script
cat > /etc/network/if-up.d/ipv6-proxy-pool << EOF
#!/bin/bash
# Auto-configure IPv6 addresses for proxy pool

if [ "\$IFACE" = "$INTERFACE" ]; then
    for i in \$(seq 0 499); do
        IPV6_ADDR="$IPV6_SUBNET::\$(printf '%x' \$((i + 1)))"
        ip -6 addr add "\$IPV6_ADDR/64" dev "$INTERFACE" 2>/dev/null || true
    done
fi
EOF

chmod +x /etc/network/if-up.d/ipv6-proxy-pool 2>/dev/null || true

echo "✅ Configuration will persist after reboot"
echo ""
echo "Next step: sudo ./scripts/start.sh"
echo ""
