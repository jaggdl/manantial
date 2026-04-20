# Peer Connections (Federation)

## Overview

Manantial is designed as a self-hosted personal micro-blog where each instance runs on its own domain. This system enables instances to "connect" with one another — forming a lightweight, peer-to-peer social network without relying on a central server or third-party protocol.

Each person runs their own Manantial instance at their own domain (e.g., `jaggdl.com`). The domain acts as the username/identity. When two instances connect, they exchange cryptographic access keys that allow them to make authenticated requests to each other — enabling future features like cross-instance post sharing, likes, and replies.

## How It Works

Connections require **manual approval**. One instance initiates, the other accepts. No connection becomes active until both sides explicitly agree.

### Connection Lifecycle

1. **Initiate (outgoing)** — Instance A generates its access key and sends a POST to `https://<peer-domain>/peers/connection` with `{ hostname: "a.com", access_key: "..." }`
2. **Receive (incoming)** — Instance B verifies A's domain, creates a pending connection with A's token, generates a nonce, and returns `{ nonce: "..." }`
3. **Accept** — Instance A sees a pending outgoing request. Instance B sees a pending incoming request. B clicks "Accept" in the UI, generates its own access key, and calls A's `/peers/connection/confirm` with `{ access_key: "...", nonce: "...", hostname: "b.com" }`
4. **Active** — A validates the nonce, stores B's token, marks the connection active. Both sides now have each other's keys.

### Disconnection

Either side can disconnect at any time. The initiator calls `DELETE /peers/connection/:hostname` on the peer, then deletes locally. The peer receives the DELETE and removes its record too.

## Design Decisions

- **No central registry** — Connections are established directly between instances
- **Hostname as identity** — The domain name is the username; no accounts or emails needed for federation
- **Mutual auth** — Both sides get a token, enabling bidirectional API access
- **Manual approval** — Incoming requests must be accepted; no auto-connections
- **Delayed key exchange** — The receiver only reveals its access key upon acceptance
- **HTTPS required** — All peer communication happens over HTTPS to protect tokens in transit
- **Manual setup** — Users enter peer hostnames manually (no discovery service)

## Architecture

There are two controllers:

| Controller | Path | Purpose |
|------------|------|---------|
| `Peers::ConnectionRequestsController` | `/peers/connection/*` | Federation API — other instances call these endpoints. No authentication required. |
| `Peers::ConnectionsController` | `/connections/*` | User management UI — the owner views pending requests, accepts/rejects, and disconnects. Requires login. |

## Database — `connections` table

| Column | Type | Notes |
|--------|------|-------|
| `hostname` | string, unique | The peer instance domain (e.g., "jaggdl.com") |
| `status` | enum/string | `"pending"`, `"active"`, `"rejected"` |
| `access_key` | string | Token we give them (for their → our requests). Generated on outgoing initiation or incoming acceptance. |
| `peer_access_key` | string | Token they gave us (for our → their requests). Set when we receive their create or confirm. |
| `nonce` | string | Challenge-response token for verification during the handshake. Unique, indexed. |
| `error_message` | text | Nullable, for failed attempts |
| timestamps | — | standard |

### Key scopes

- `Connection.incoming` — pending connections where `peer_access_key` is set but `access_key` is nil (someone wants to connect with us)
- `Connection.outgoing` — pending connections where `access_key` is set but `peer_access_key` is nil (we sent a request, waiting for them)
- `Connection.active` — both keys present, connection is live
- `Connection.rejected` — user explicitly rejected

## Model — `Peers::Connection`

- `generate_access_key` — creates `access_key` with `SecureRandom.hex(32)`
- `accept!(peer_access_key = nil)` — generates our key if missing, stores theirs, sets status to active
- `reject!` — sets rejected, clears all keys and nonce
- `disconnect!` — destroys the record
- `self.initiate_outgoing!(hostname, origin_host)` — full outgoing handshake: creates record with our key, calls peer's create, stores peer's nonce
- `self.complete_acceptance!(hostname, origin_host)` — full incoming acceptance: generates our key, calls peer's confirm with our key + nonce, marks active on success
- `self.verify_peer(hostname, nonce)` — POSTs nonce to peer's verify endpoint, checks response
- `self.normalize_hostname(hostname)` — strips `https://` and trailing slashes

## Federation API Endpoints — `Peers::ConnectionRequestsController`

| Method | Path | Purpose |
|--------|------|---------|
| `POST /peers/connection` | Receives an incoming connection request. Body: `{ hostname: "...", access_key: "..." }`. Verifies peer, creates pending incoming connection, returns `{ nonce: "..." }`. |
| `POST /peers/connection/confirm` | Receives acceptance confirmation. Body: `{ access_key: "...", nonce: "...", hostname: "..." }`. Validates nonce, stores peer's key, marks active. |
| `POST /peers/connection/verify` | Proof-of-ownership. Body: `{ nonce: "..." }`. Returns `{ verified: true, hostname: "<our_host>" }`. |
| `POST /peers/connection/revoke` | Peer notifies us they disconnected. Body: `{ hostname: "..." }`. Destroys local record. |
| `DELETE /peers/connection/:hostname` | Peer requests disconnection. Destroys local record. |

## Management UI Endpoints — `Peers::ConnectionsController`

| Method | Path | Purpose |
|--------|------|---------|
| `GET /connections` | List all connections grouped by status (active, incoming, outgoing, rejected). |
| `POST /connections` | User initiates outgoing connection. Calls peer's create endpoint. |
| `POST /connections/:hostname/accept` | User accepts an incoming request. Generates our key, calls peer's confirm. |
| `POST /connections/:hostname/reject` | User rejects an incoming request. |
| `DELETE /connections/:hostname` | User disconnects. Notifies peer via revoke, destroys local record. |

## UI — `/connections`

- **Active** — green indicator, hostname, disconnect button
- **Incoming Requests** — blue indicator, hostname, accept/reject buttons
- **Outgoing Requests** — yellow indicator, hostname, cancel button, error message if failed
- **Rejected** — red indicator, hostname, remove button
- **Add Connection** — hostname input + "Connect" button (top of page)

## Implementation Order

1. Migration + `Connection` model with scopes and handshake methods
2. Federation API controller (`/peers/connection/*`) — the protocol other instances use
3. Management controller (`/connections/*`) — user-facing views and actions
4. End-to-end testing between two running instances
5. Tests (if test suite exists)
