---
name: myn-a2a
description: "Connect OpenClaw to Mind Your Now (MYN) via the A2A (Agent-to-Agent) protocol.
  Use when the user wants to link their OpenClaw agent to Kaia (MYN's AI assistant),
  pair with MYN, send messages to Kaia, receive delegated tasks, or share capabilities.
  Implements openclaw-a2a-lite-v1 protocol."
version: "1.0.0"
triggers:
  - "connect to myn"
  - "pair with kaia"
  - "kaia delegation"
  - "myn agent"
  - "a2a"
  - "agent-to-agent"
  - "openclaw myn"
globs: []
---

# MYN A2A Integration Skill

## Overview

This skill implements the `openclaw-a2a-lite-v1` protocol to connect your OpenClaw agent
to Kaia, MYN's AI assistant. Once connected, Kaia can delegate real-world tasks to your
agent and receive information briefings.

## Pairing Flow

1. **User generates invite code**: In MYN → Settings → Kaia → Connected Agents → "Connect Agent"
2. **OpenClaw redeems invite**: Call `POST /api/v1/agent/redeem-invite` with:
   ```json
   {
     "inviteCode": "ABC-12345",
     "agentName": "my-openclaw",
     "displayName": "My OpenClaw",
     "outboundEndpoint": "https://my-openclaw.example.com/a2a/message",
     "capabilityHash": "<sha256 of capabilities manifest>",
     "capabilityManifest": { ... }
   }
   ```
   Either `capabilityHash` or `capabilityManifest` may be provided; if both, manifest takes precedence.
3. **Receive keys**: Response contains `mynInboundKey` (use as `X-Agent-Key` header for calls to MYN).
4. **Start exchanging**: Use `X-Agent-Key: <mynInboundKey>` on all calls to `/a2a/message`.

## Endpoints

### Discover Kaia's Capabilities
```
GET /.well-known/agent.json
```
Returns AgentCard with protocol, endpoint, and capabilities.

### Send a Message to Kaia
```
POST /a2a/message
X-Agent-Key: <your-inbound-key>

{
  "from": "my-openclaw",
  "intent": "chat | briefing | ping",
  "message": "...",
  "conversationId": "oc-my-openclaw-abc123",
  "capabilityHash": "<current-hash>"
}
```

### Receive Messages from Kaia
Your endpoint (`outboundEndpoint`) receives:
```
POST <your-endpoint>
X-Agent-Key: <your-outbound-key>

{
  "from": "kaia-myn",
  "intent": "chat | briefing | ping",
  "message": "...",
  "conversationId": "del-<uuid>",
  "delegationId": "<uuid>"
}
```

## Capability Manifest

Your agent should publish a capability manifest at your endpoint's `GET /capabilities` path:
```json
{
  "schemaVersion": "1.0",
  "agentInfo": { "name": "my-openclaw", "version": "1.0.0" },
  "capabilities": [
    { "id": "web-search", "name": "Web Search", "description": "Search the web" },
    { "id": "browser", "name": "Browser Automation", "description": "Automate browsers" }
  ]
}
```

Compute the hash: `SHA-256(fast-json-stable-stringify(manifest))`.

## Autonomy Tiers

| Tier | Behavior |
|------|----------|
| FREE / FAMILY_MEMBER | A2A not available |
| PRO / FAMILY | Reactive only — Kaia responds to inbound, won't initiate |
| EXECUTIVE | Fully autonomous — Kaia can proactively delegate tasks |

## Security

- All requests authenticated via `X-Agent-Key` header (SHA-256 hashed on server)
- Keys are AES-256-GCM encrypted at rest
- Circuit breaker suspends agents sending >20 messages in 60 seconds
- Daily limits per tier enforced (info_query, delegation, briefing)
- Irreversible capabilities (payment, exec, browser) always require user confirmation
