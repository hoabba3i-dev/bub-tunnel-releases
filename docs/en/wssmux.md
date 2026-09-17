# 🌐 WSSMux Guide

[← Back to BUB TUNNEL](../../README.md)

WSSMux carries BUB traffic through secure WebSocket connections.

## 1. Prepare the domain

Create or select a domain/subdomain, configure its DNS record for the intended endpoint, and enable Proxy on the compatible proxy service you use.

## 2. Select WSSMux

During tunnel setup select `WSSMux`.

## 3. Use the same domain on both sides

Enter the same prepared domain on both endpoints.

```text
Foreign: tunnel.example.com
Iran:    tunnel.example.com
```

## 4. Client Server Address and HTTPS port

On the Client, use the proxied domain as `Server Address`, not the Server's direct IP.

Common HTTPS-compatible ports include:

```text
443
2053
2083
2087
2096
8443
```

Example:

```text
Transport: WSSMux
Server Address: tunnel.example.com
Tunnel Port: 443
Domain: tunnel.example.com
```