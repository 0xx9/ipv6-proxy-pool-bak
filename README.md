# ipv6-proxy-pool

Run a pool of HTTP/SOCKS5 proxies on one server, each bound to a different IPv6 address. Good when you need rotating outbound IPs but only have one IPv4.

Proxies listen on a port range (default 12000–12499) on your server's IPv4. Outbound traffic goes through unique IPv6 addresses from your /64 subnet.

## Requirements

Your VPS needs an IPv6 /64 subnet. Check with:

```bash
ip -6 addr show
```

## Install

```bash
cd ipv6-proxy-pool
sudo ./scripts/install.sh

cp config/ipv6.conf.example config/ipv6.conf
cp config/auth.conf.example config/auth.conf
# edit ipv6.conf with your subnet

sudo ./scripts/setup-ipv6.sh
sudo ./scripts/start.sh
```

## Usage

Each proxy is `http://YOUR_IP:PORT` where PORT is in your configured range.

Export the full list:

```bash
./scripts/export-proxies.sh
```

Check status:

```bash
./scripts/status.sh
```

## API mode

There's also a REST API for getting proxies programmatically:

```bash
./scripts/start-api.sh
```

See `examples/` for curl, Python, and Node.js usage.

## systemd

```bash
sudo ./scripts/install-service.sh
sudo systemctl enable ipv6-proxy-pool
sudo systemctl start ipv6-proxy-pool
```

## Config files

| File | Purpose |
|------|---------|
| `config/ipv6.conf` | Subnet, interface, port range |
| `config/auth.conf` | Optional username/password auth |

Both are gitignored — copy from the `.example` files and fill in your values.

See `QUICK_START.md` for a shorter walkthrough.
