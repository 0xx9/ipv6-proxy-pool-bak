#!/usr/bin/env node

/**
 * IPv6 Proxy Pool Server with Auto-Rotation
 * Creates 500 HTTP proxies, each rotating IPv6 address every 1 minute
 */

const http = require('http');
const net = require('net');
const url = require('url');
const fs = require('fs');
const path = require('path');

// Configuration
const CONFIG = {
    startPort: 12000,
    endPort: 12499,
    ipv6Subnet: '2a12:bec4:1561:5ae5',
    bindIpv4: '0.0.0.0',
    enableAuth: false,
    username: 'proxyuser',
    password: 'changeMe123!',
    rotationInterval: 60000, // 1 minute in milliseconds
    totalIPv6Addresses: 500
};

// IPv6 mapping for each proxy (will rotate)
const proxyIPv6Map = new Map();
const totalProxies = CONFIG.endPort - CONFIG.startPort + 1;

// Load configuration from file
function loadConfig() {
    try {
        const configPath = path.join(__dirname, '../config/ipv6.conf');
        if (fs.existsSync(configPath)) {
            const configData = fs.readFileSync(configPath, 'utf8');
            configData.split('\n').forEach(line => {
                if (line.startsWith('IPV6_SUBNET=')) {
                    CONFIG.ipv6Subnet = line.split('=')[1].replace(/"/g, '').trim();
                }
                if (line.startsWith('START_PORT=')) {
                    CONFIG.startPort = parseInt(line.split('=')[1].trim());
                }
                if (line.startsWith('END_PORT=')) {
                    CONFIG.endPort = parseInt(line.split('=')[1].trim());
                }
                if (line.startsWith('BIND_IPV4=')) {
                    CONFIG.bindIpv4 = line.split('=')[1].replace(/"/g, '').trim();
                }
            });
        }

        const authPath = path.join(__dirname, '../config/auth.conf');
        if (fs.existsSync(authPath)) {
            const authData = fs.readFileSync(authPath, 'utf8');
            authData.split('\n').forEach(line => {
                if (line.startsWith('ENABLE_AUTH=')) {
                    CONFIG.enableAuth = line.split('=')[1].trim() === 'true';
                }
                if (line.startsWith('USERNAME=')) {
                    CONFIG.username = line.split('=')[1].replace(/"/g, '').trim();
                }
                if (line.startsWith('PASSWORD=')) {
                    CONFIG.password = line.split('=')[1].replace(/"/g, '').trim();
                }
            });
        }
    } catch (err) {
        console.warn('Warning: Could not load config files, using defaults');
    }
}

loadConfig();

// Get random IPv6 from the pool
function getRandomIPv6() {
    const randomIndex = Math.floor(Math.random() * CONFIG.totalIPv6Addresses);
    return `${CONFIG.ipv6Subnet}::${(randomIndex + 1).toString(16)}`;
}

// Initialize IPv6 for each port
function initializeIPv6Mapping() {
    for (let port = CONFIG.startPort; port <= CONFIG.endPort; port++) {
        proxyIPv6Map.set(port, getRandomIPv6());
    }
    console.log(`✅ Initialized ${proxyIPv6Map.size} proxies with random IPv6 addresses`);
}

// Rotate IPv6 addresses for all proxies
function rotateIPv6Addresses() {
    let rotated = 0;
    for (let port = CONFIG.startPort; port <= CONFIG.endPort; port++) {
        const newIPv6 = getRandomIPv6();
        proxyIPv6Map.set(port, newIPv6);
        rotated++;
    }
    console.log(`🔄 [${new Date().toISOString()}] Rotated ${rotated} proxies to new IPv6 addresses`);
}

// Get IPv6 for a specific port
function getIPv6ForPort(port) {
    return proxyIPv6Map.get(port) || getRandomIPv6();
}

// Authentication check
function checkAuth(req) {
    if (!CONFIG.enableAuth) return true;

    const auth = req.headers['proxy-authorization'];
    if (!auth) return false;

    const credentials = Buffer.from(auth.split(' ')[1], 'base64').toString();
    const [username, password] = credentials.split(':');

    return username === CONFIG.username && password === CONFIG.password;
}

// HTTP CONNECT tunnel handler (for HTTPS)
function handleConnect(req, clientSocket, head, port) {
    const { hostname, port: targetPort } = parseHostPort(req.url, 443);

    // Check authentication
    if (!checkAuth(req)) {
        clientSocket.write('HTTP/1.1 407 Proxy Authentication Required\r\n');
        clientSocket.write('Proxy-Authenticate: Basic realm="Proxy"\r\n');
        clientSocket.write('\r\n');
        clientSocket.end();
        return;
    }

    const ipv6Address = getIPv6ForPort(port);

    // Connect to target using specified IPv6
    const serverSocket = net.connect({
        host: hostname,
        port: targetPort,
        localAddress: ipv6Address,
        family: 6
    }, () => {
        clientSocket.write('HTTP/1.1 200 Connection Established\r\n\r\n');
        serverSocket.write(head);
        serverSocket.pipe(clientSocket);
        clientSocket.pipe(serverSocket);
    });

    serverSocket.on('error', (err) => {
        clientSocket.end();
    });

    clientSocket.on('error', (err) => {
        serverSocket.end();
    });
}

// HTTP proxy handler (for HTTP requests)
function handleHttpProxy(req, res, port) {
    // Check authentication
    if (!checkAuth(req)) {
        res.writeHead(407, { 'Proxy-Authenticate': 'Basic realm="Proxy"' });
        res.end('Proxy Authentication Required');
        return;
    }

    const ipv6Address = getIPv6ForPort(port);
    const parsedUrl = url.parse(req.url);
    const options = {
        hostname: parsedUrl.hostname,
        port: parsedUrl.port || 80,
        path: parsedUrl.path,
        method: req.method,
        headers: req.headers,
        localAddress: ipv6Address,
        family: 6
    };

    // Remove proxy-specific headers
    delete options.headers['proxy-connection'];
    delete options.headers['proxy-authorization'];

    const proxyReq = http.request(options, (proxyRes) => {
        res.writeHead(proxyRes.statusCode, proxyRes.headers);
        proxyRes.pipe(res);
    });

    proxyReq.on('error', (err) => {
        res.writeHead(502, { 'Content-Type': 'text/plain' });
        res.end('Bad Gateway');
    });

    req.pipe(proxyReq);
}

// Parse hostname:port from string
function parseHostPort(hostString, defaultPort) {
    const parts = hostString.split(':');
    return {
        hostname: parts[0],
        port: parseInt(parts[1]) || defaultPort
    };
}

// Create proxy server for a specific port
function createProxyServer(port) {
    const server = http.createServer((req, res) => {
        handleHttpProxy(req, res, port);
    });

    server.on('connect', (req, clientSocket, head) => {
        handleConnect(req, clientSocket, head, port);
    });

    server.listen(port, CONFIG.bindIpv4, () => {
        const ipv6 = getIPv6ForPort(port);
        console.log(`✅ Proxy started: ${CONFIG.bindIpv4}:${port} → ${ipv6}`);
    });

    server.on('error', (err) => {
        if (err.code !== 'EADDRINUSE') {
            console.error(`❌ Error on port ${port}: ${err.message}`);
        }
    });

    return server;
}

// Main startup
function startProxyPool() {
    console.log('================================');
    console.log('IPv6 Proxy Pool Server');
    console.log('With Auto-Rotation Every 1 Min');
    console.log('================================');
    console.log('');
    console.log('Configuration:');
    console.log(`  IPv6 Subnet: ${CONFIG.ipv6Subnet}`);
    console.log(`  Port Range: ${CONFIG.startPort}-${CONFIG.endPort}`);
    console.log(`  Bind Address: ${CONFIG.bindIpv4}`);
    console.log(`  Authentication: ${CONFIG.enableAuth ? 'Enabled' : 'Disabled'}`);
    console.log(`  Rotation Interval: ${CONFIG.rotationInterval / 1000} seconds`);
    console.log(`  Total IPv6 Pool: ${CONFIG.totalIPv6Addresses}`);
    console.log('');

    // Initialize IPv6 mapping
    initializeIPv6Mapping();

    console.log('');
    console.log('Starting proxies...');
    console.log('');

    const servers = [];

    for (let port = CONFIG.startPort; port <= CONFIG.endPort; port++) {
        servers.push(createProxyServer(port));
    }

    console.log('');
    console.log('================================');
    console.log(`✅ All ${servers.length} proxies started successfully!`);
    console.log('================================');
    console.log('');
    console.log(`🔄 IPv6 addresses will rotate every ${CONFIG.rotationInterval / 1000} seconds`);
    console.log('');

    // Start rotation timer
    setInterval(() => {
        rotateIPv6Addresses();
    }, CONFIG.rotationInterval);

    console.log('Usage examples:');
    console.log(`  curl -x localhost:${CONFIG.startPort} https://api.ipify.org`);
    console.log(`  curl -x localhost:${CONFIG.startPort + 1} https://api.ipify.org`);
    console.log('');
}

// Handle shutdown gracefully
process.on('SIGTERM', () => {
    console.log('Received SIGTERM, shutting down gracefully...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('Received SIGINT, shutting down gracefully...');
    process.exit(0);
});

// Start the proxy pool
startProxyPool();
