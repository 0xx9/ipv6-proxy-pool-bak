# IPv6 Proxy Pool - Quick Start Guide

## ✅ What's Running

- **500 HTTP/HTTPS Proxies** on ports 12000-12499
- **IPv6 Auto-Rotation** every 60 seconds
- **API Server** on port 8080

## 🌐 Access Your Proxies

### Method 1: Direct Access via IP:Port

Your server IP: **45.13.226.156**

```
45.13.226.156:12000
45.13.226.156:12001
45.13.226.156:12002
...
45.13.226.156:12499
```

### Method 2: API Endpoint

Get full proxy list:
```bash
curl http://45.13.226.156:8080/api/v1/data/proxy/ip2.txt
```

Web interface:
```
http://45.13.226.156:8080/
```

## 🔄 IPv6 Rotation

Each proxy automatically rotates to a new IPv6 address **every 60 seconds**.

- Total IPv6 pool: 500 unique addresses
- Each proxy randomly selects from the pool every minute
- Different exit IP for each request after rotation

## 💡 Usage Examples

### cURL
```bash
# Single request
curl -x 45.13.226.156:12000 https://api.ipify.org

# Check IPv6
curl -x 45.13.226.156:12000 https://api64.ipify.org
```

### Python
```python
import requests

proxy = "http://45.13.226.156:12000"
proxies = {"http": proxy, "https": proxy}

response = requests.get("https://api.ipify.org", proxies=proxies)
print(response.text)  # Shows IPv6 address
```

### Node.js
```javascript
const axios = require('axios');

const proxy = {
  host: '45.13.226.156',
  port: 12000
};

axios.get('https://api.ipify.org', { proxy })
  .then(res => console.log(res.data));
```

## 📊 Management Commands

```bash
# Check status
cd /root/ipv6-proxy-pool
./scripts/status.sh

# View logs (see rotation in action)
tail -f proxy-pool.log

# Restart proxy server
./scripts/restart.sh

# Export proxy list
./scripts/export-proxies.sh

# Stop/Start API
./scripts/stop-api.sh
./scripts/start-api.sh
```

## 🔍 Monitor Rotation

Watch the rotation happen live:
```bash
tail -f /root/ipv6-proxy-pool/proxy-pool.log | grep "Rotated"
```

You'll see messages like:
```
🔄 [2026-05-17T02:50:00.000Z] Rotated 500 proxies to new IPv6 addresses
```

## 📡 API Endpoints

- `http://45.13.226.156:8080/api/v1/data/proxy/ip2.txt` - Plain text list
- `http://45.13.226.156:8080/api/v1/proxies` - JSON format
- `http://45.13.226.156:8080/proxies.txt` - Direct file
- `http://45.13.226.156:8080/status` - API status

## ⚡ Quick Test

Test 5 different proxies:
```bash
for i in {0..4}; do
  PORT=$((12000 + i))
  IP=$(curl -x 45.13.226.156:$PORT -s https://api64.ipify.org)
  echo "Port $PORT: $IP"
done
```

## 🛠️ Troubleshooting

### Check if proxies are running
```bash
ps aux | grep proxy-server
```

### Check if ports are listening
```bash
netstat -tlnp | grep 12000
```

### Restart everything
```bash
cd /root/ipv6-proxy-pool
./scripts/stop.sh
sleep 2
./scripts/start.sh
```

## 📝 File Locations

- Proxy server: `/root/ipv6-proxy-pool/server/proxy-server.js`
- Configuration: `/root/ipv6-proxy-pool/config/ipv6.conf`
- Logs: `/root/ipv6-proxy-pool/proxy-pool.log`
- Proxy list: `/root/ipv6-proxy-pool/proxies.txt`

## 🎯 Features

✅ 500 unique rotating proxies
✅ Auto IPv6 rotation every 60 seconds
✅ HTTP and HTTPS support
✅ REST API for proxy list
✅ No authentication required (can be enabled)
✅ High performance (1000+ concurrent connections)
✅ Automatic restart on reboot (via systemd)

---

**Your proxies are ready to use!** 🚀
