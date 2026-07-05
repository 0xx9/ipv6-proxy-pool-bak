#!/usr/bin/env python3
"""
Example: Using IPv6 Proxy Pool with Python
"""

import requests
import random

# Your server's public IPv4
PROXY_HOST = "152.42.134.66"  # Change this to your server IP

# Available proxy ports
PROXY_PORTS = list(range(12000, 12100))

def get_random_proxy():
    """Get a random proxy from the pool"""
    port = random.choice(PROXY_PORTS)
    return f"http://{PROXY_HOST}:{port}"

def get_my_ip(proxy):
    """Get external IP using proxy"""
    proxies = {
        'http': proxy,
        'https': proxy
    }
    
    try:
        response = requests.get('https://api.ipify.org?format=json', 
                              proxies=proxies, 
                              timeout=10)
        return response.json()['ip']
    except Exception as e:
        return f"Error: {e}"

# Example 1: Single request with random proxy
print("Example 1: Single request")
print("-" * 50)
proxy = get_random_proxy()
print(f"Using proxy: {proxy}")
ip = get_my_ip(proxy)
print(f"My IP: {ip}")
print()

# Example 2: Multiple requests with different proxies
print("Example 2: Multiple requests with rotation")
print("-" * 50)
for i in range(5):
    proxy = get_random_proxy()
    ip = get_my_ip(proxy)
    print(f"Request {i+1}: {proxy} → IP: {ip}")
print()

# Example 3: Using specific proxies in sequence
print("Example 3: Sequential proxy usage")
print("-" * 50)
for port in range(12000, 12005):
    proxy = f"http://{PROXY_HOST}:{port}"
    ip = get_my_ip(proxy)
    print(f"Port {port} → IP: {ip}")
