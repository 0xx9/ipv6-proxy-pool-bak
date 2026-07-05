#!/usr/bin/env node
/**
 * Example: Using IPv6 Proxy Pool with Node.js
 */

const axios = require('axios');
const { HttpsProxyAgent } = require('https-proxy-agent');

// Your server's public IPv4
const PROXY_HOST = '152.42.134.66'; // Change this to your server IP

// Available proxy ports
const PROXY_PORTS = Array.from({ length: 100 }, (_, i) => 12000 + i);

// Get random proxy from pool
function getRandomProxy() {
    const port = PROXY_PORTS[Math.floor(Math.random() * PROXY_PORTS.length)];
    return `http://${PROXY_HOST}:${port}`;
}

// Get external IP using proxy
async function getMyIP(proxyUrl) {
    try {
        const agent = new HttpsProxyAgent(proxyUrl);
        const response = await axios.get('https://api.ipify.org?format=json', {
            httpsAgent: agent,
            timeout: 10000
        });
        return response.data.ip;
    } catch (error) {
        return `Error: ${error.message}`;
    }
}

// Example 1: Single request with random proxy
async function example1() {
    console.log('Example 1: Single request');
    console.log('-'.repeat(50));
    
    const proxy = getRandomProxy();
    console.log(`Using proxy: ${proxy}`);
    
    const ip = await getMyIP(proxy);
    console.log(`My IP: ${ip}`);
    console.log();
}

// Example 2: Multiple requests with different proxies
async function example2() {
    console.log('Example 2: Multiple requests with rotation');
    console.log('-'.repeat(50));
    
    for (let i = 0; i < 5; i++) {
        const proxy = getRandomProxy();
        const ip = await getMyIP(proxy);
        console.log(`Request ${i + 1}: ${proxy} → IP: ${ip}`);
    }
    console.log();
}

// Example 3: Using specific proxies in sequence
async function example3() {
    console.log('Example 3: Sequential proxy usage');
    console.log('-'.repeat(50));
    
    for (let port = 12000; port < 12005; port++) {
        const proxy = `http://${PROXY_HOST}:${port}`;
        const ip = await getMyIP(proxy);
        console.log(`Port ${port} → IP: ${ip}`);
    }
}

// Run all examples
async function main() {
    await example1();
    await example2();
    await example3();
}

main().catch(console.error);
