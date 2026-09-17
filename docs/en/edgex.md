# Edge X

Edge X is BUB Tunnel's resilient Reverse-mode multi-carrier capability for difficult and unstable network paths.

It is designed to keep one logical tunnel available across multiple independent carriers and to recover quickly when a carrier becomes unhealthy or unavailable.

## Highlights

- Reverse-mode operation
- Multiple independent carriers inside one logical tunnel
- Fast carrier failover
- Session continuity during carrier changes where possible
- Zero-link protection and rapid refill/recovery behavior
- Multipath operation
- Live carrier health and runtime visibility
- Isolation from existing transport implementations

## Carrier families

Edge X can use supported carrier families such as TCP/TLS, ICMP, GRE, authenticated UDP/KCP, and IP-in-IP according to the build and deployment configuration.

Each carrier keeps its own transport behavior. Edge X acts as an orchestration and resilience layer rather than rewriting the internal behavior of existing transports.

## Design goal

The primary goal is to minimize user-visible interruption when a network path degrades, disappears, or returns, while preserving throughput, latency, and stability.

Internal scheduling, authentication, recovery, carrier-ranking, session, replay, and failover implementation details are intentionally not documented in the public repository.
