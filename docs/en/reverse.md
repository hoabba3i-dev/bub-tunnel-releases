# ↩️ Reverse Setup

[← Back to BUB TUNNEL](../../README.md)

Typical direction:

```text
Foreign / Client
       │
       ▼
    Reverse
       │
       ▼
 Iran / Server
```

## Setup

1. Run `bub` on Iran.
2. Choose `Setup Server`.
3. Select `Reverse`.
4. Select the transport and complete Server configuration.
5. Run `bub` on Foreign.
6. Choose `Setup Client`.
7. Select `Reverse`.
8. Enter matching tunnel parameters, token and transport settings.
9. Start the tunnel and verify Status.

Transport-specific settings must match where required. BUBMIX is available for Reverse tunnels when multiple transport options are required.