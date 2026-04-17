# Peer Connections (Federation)

## Overview

Manantial is designed as a self-hosted personal micro-blog where each instance runs on its own domain. This system enables instances to "connect" with one another — forming a lightweight, peer-to-peer social network without relying on a central server or third-party protocol.

Each person runs their own Manantial instance at their own domain (e.g., `jaggdl.com`). The domain acts as the username/identity. When two instances connect, they exchange cryptographic access keys that allow them to make authenticated requests to each other — enabling future features like cross-instance post sharing, likes, and replies.

## How It Works

1. **Initiate** — Instance A sends a POST request to `https://<peer-domain>/peers/connection` with its hostname
2. **Verify** — Before proceeding, the receiving instance makes an HTTPS GET to `<peer-domain>/peers/connection/verify` to prove that peer actually controls that domain
3. **Exchange keys** — Both instances exchange cryptographic access tokens (64-char hex strings generated via `SecureRandom.hex(32)`)
4. **Active** — Once both sides have each other's tokens, the connection is active and either instance can make authenticated requests to the other

## Design Decisions

- **No central registry** — Connections are established directly between instances
- **Hostname as identity** — The domain name is the username; no accounts or emails needed for federation
- **Mutual auth** — Both sides get a token, enabling bidirectional API access
- **HTTPS required** — All peer communication happens over HTTPS to protect tokens in transit
- **Manual setup** — Users enter peer hostnames manually (no discovery service)

## Implementation Plan

### 1. Database — `connections` table

| Column | Type | Notes |
|--------|------|-------|
| `hostname` | string, unique | The peer instance domain (e.g., "jaggdl.com") |
| `status` | enum/string | `"pending"`, `"active"`, `"rejected"` |
| `access_key` | string | Token we give them (for their → our requests) |
| `peer_access_key` | string | Token they gave us (for our → their requests, set after confirm) |
| `error_message` | text | Nullable, for failed attempts |
| timestamps | — | standard |

### 2. Model — `Connection`

- `generate_tokens!` — creates both tokens with `SecureRandom.hex(32)`
- `accept!(their_token)` — sets status to active and saves their token
- `reject!` / `disconnect!` — cleans up state
- Validates hostname format (must be valid URL, HTTPS only)

### 3. API Endpoints — `Api::ConnectionsController`

| Method | Path | Purpose |
|--------|------|---------|
| `POST /api/connect` | Initiate connection to a peer hostname. Returns `{ token: "...", nonce: "..." }`. |
| `POST /api/connect/confirm` | Receives the peer's response with their token + nonce. Verifies nonce against our instance first, then saves the connection as active. |
| `DELETE /api/connect/:hostname` | Revoke a connection — deletes local record and calls `/api/connect/revoke` on the peer if active. |

### 4. Verification Endpoint — `Api::ConnectsController#verify` (or separate)

- `POST /api/connect/verify` — receives `{ nonce: "..." }`, validates it, returns `{ verified: true, hostname: "<our_host>" }`
- This is the proof-of-ownership step: B calls this on A to confirm A controls that instance before proceeding with token exchange.

### 5. UI — Connections section in Profile page

- List of connected hostnames with status badges (active/pending)
- "Add connection" input field + button
- Disconnect button per connection
- Error messages shown inline for failed connections

## Implementation order:

1. Migration + `Connection` model
2. API endpoints (`/api/connect`) — the core protocol logic
3. Verification endpoint (`/api/connect/verify`) — nonce challenge-response
4. UI additions to profile page
5. Tests (if test suite exists)
