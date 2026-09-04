# 🔀 BUBMIX

[← Back to BUB TUNNEL](../../README.md)

BUBMIX is BUB's multi-transport management capability for **Reverse** tunnels.

It can manage multiple configured carriers, observe their availability, and provide automatic failover capabilities when network conditions change.

Each underlying transport keeps its own configuration and behavior.

<p align="center"><img src="https://github.com/user-attachments/assets/4c22f687-3771-4bbc-8bc7-460bd78a5b2b" alt="BUBMIX transport configuration" width="520"></p>

> Public documentation describes BUBMIX at the feature level. Internal carrier-selection, health, failover, session, scheduling and probe implementation details are proprietary.