#!/usr/bin/env node

/**
 * IPv6 Proxy Pool - API Server
 * Provides HTTP endpoints to access proxy list
 */

const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8080;
const PROXY_FILE = path.join(__dirname, '../proxies.txt');

// Generate proxy list if not exists
function generateProxyList() {
    const configPath = path.join(__dirname, '../config/ipv6.conf');
    let startPort = 12000;
    let endPort = 12499;
    let publicIP = '45.13.226.156';

    // Try to get actual public IP
    try {
        const { execSync } = require('child_process');
        publicIP = execSync('curl -s https://api.ipify.org').toString().trim();
    } catch (err) {
        console.warn('Could not detect public IP, using default');
    }

    // Generate proxy list
    const proxies = [];
    for (let port = startPort; port <= endPort; port++) {
        proxies.push(`${publicIP}:${port}`);
    }

    fs.writeFileSync(PROXY_FILE, proxies.join('\n'));
    console.log(`Generated ${proxies.length} proxies`);
    return proxies;
}

// Read proxy list
function getProxyList() {
    try {
        if (!fs.existsSync(PROXY_FILE)) {
            return generateProxyList();
        }
        const content = fs.readFileSync(PROXY_FILE, 'utf8');
        return content.trim().split('\n');
    } catch (err) {
        console.error('Error reading proxy file:', err);
        return [];
    }
}

// Handle requests
const server = http.createServer((req, res) => {
    const url = req.url;

    // CORS headers
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.writeHead(200);
        res.end();
        return;
    }

    // Route: GET /api/v1/data/proxy/ip2.txt
    if (url === '/api/v1/data/proxy/ip2.txt' || url === '/api/v1/data/proxy/ip2.txt/') {
        const proxies = getProxyList();
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(proxies.join('\n'));
        console.log(`[${new Date().toISOString()}] GET ${url} - 200 (${proxies.length} proxies)`);
        return;
    }

    // Route: GET /api/v1/proxies (JSON format)
    if (url === '/api/v1/proxies' || url === '/api/v1/proxies/') {
        const proxies = getProxyList();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            success: true,
            count: proxies.length,
            proxies: proxies
        }, null, 2));
        console.log(`[${new Date().toISOString()}] GET ${url} - 200 (${proxies.length} proxies)`);
        return;
    }

    // Route: GET /proxies.txt (direct file)
    if (url === '/proxies.txt' || url === '/proxies.txt/') {
        const proxies = getProxyList();
        res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
        res.end(proxies.join('\n'));
        console.log(`[${new Date().toISOString()}] GET ${url} - 200 (${proxies.length} proxies)`);
        return;
    }

    // Route: GET /status
    if (url === '/status' || url === '/status/') {
        const proxies = getProxyList();
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({
            status: 'online',
            proxyCount: proxies.length,
            portRange: '12000-12499',
            endpoints: {
                'Proxy List (Text)': '/api/v1/data/proxy/ip2.txt',
                'Proxy List (JSON)': '/api/v1/proxies',
                'Direct File': '/proxies.txt',
                'Status': '/status'
            }
        }, null, 2));
        console.log(`[${new Date().toISOString()}] GET ${url} - 200`);
        return;
    }

    // Route: GET / (welcome page)
    if (url === '/' || url === '/') {
        const proxies = getProxyList();
        res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
        res.end(`
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>IPv6 Proxy Pool API</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 800px; 
            margin: 50px auto; 
            padding: 20px;
            background: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        h1 { color: #333; }
        .endpoint { 
            background: #f8f9fa; 
            padding: 15px; 
            margin: 10px 0; 
            border-radius: 5px;
            border-left: 4px solid #007bff;
        }
        code { 
            background: #e9ecef; 
            padding: 2px 6px; 
            border-radius: 3px;
            font-family: monospace;
        }
        .count {
            font-size: 48px;
            color: #28a745;
            font-weight: bold;
            text-align: center;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 IPv6 Proxy Pool API</h1>
        <div class="count">${proxies.length}</div>
        <p style="text-align: center; color: #666;">Available Proxies</p>
        
        <h2>📡 API Endpoints</h2>
        
        <div class="endpoint">
            <strong>Proxy List (Text Format)</strong><br>
            <code>GET /api/v1/data/proxy/ip2.txt</code><br>
            <small>Returns all proxies in plain text format (one per line)</small>
        </div>
        
        <div class="endpoint">
            <strong>Proxy List (JSON Format)</strong><br>
            <code>GET /api/v1/proxies</code><br>
            <small>Returns all proxies in JSON format with metadata</small>
        </div>
        
        <div class="endpoint">
            <strong>Direct File Access</strong><br>
            <code>GET /proxies.txt</code><br>
            <small>Direct access to proxy list file</small>
        </div>
        
        <div class="endpoint">
            <strong>Status Check</strong><br>
            <code>GET /status</code><br>
            <small>API status and information</small>
        </div>

        <h2>💡 Usage Example</h2>
        <pre style="background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto;">
# Get proxy list
curl http://YOUR_SERVER:3000/api/v1/data/proxy/ip2.txt

# Get JSON format
curl http://YOUR_SERVER:3000/api/v1/proxies

# Use with your scripts
proxies=$(curl -s http://YOUR_SERVER:3000/api/v1/data/proxy/ip2.txt)
        </pre>
        
        <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; color: #666; text-align: center;">
            Port Range: <strong>12000-12499</strong> | Each proxy uses unique IPv6 address
        </p>
    </div>
</body>
</html>
        `);
        return;
    }

    // 404 Not Found
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
        error: 'Not Found',
        message: 'Endpoint not found',
        availableEndpoints: [
            '/api/v1/data/proxy/ip2.txt',
            '/api/v1/proxies',
            '/proxies.txt',
            '/status'
        ]
    }, null, 2));
    console.log(`[${new Date().toISOString()}] GET ${url} - 404`);
});

// Start server
server.listen(PORT, '0.0.0.0', () => {
    console.log('================================');
    console.log('IPv6 Proxy Pool - API Server');
    console.log('================================');
    console.log('');
    console.log(`✅ API Server running on port ${PORT}`);
    console.log('');
    console.log('Available endpoints:');
    console.log(`  http://YOUR_IP:${PORT}/api/v1/data/proxy/ip2.txt`);
    console.log(`  http://YOUR_IP:${PORT}/api/v1/proxies`);
    console.log(`  http://YOUR_IP:${PORT}/proxies.txt`);
    console.log(`  http://YOUR_IP:${PORT}/status`);
    console.log('');
    
    const proxies = getProxyList();
    console.log(`📊 Total proxies available: ${proxies.length}`);
    console.log('');
});

// Handle shutdown
process.on('SIGTERM', () => {
    console.log('Received SIGTERM, shutting down...');
    server.close(() => {
        process.exit(0);
    });
});

process.on('SIGINT', () => {
    console.log('Received SIGINT, shutting down...');
    server.close(() => {
        process.exit(0);
    });
});
