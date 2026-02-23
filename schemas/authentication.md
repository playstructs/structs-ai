# Authentication Data Structures

**Version**: 1.0.0
**Category**: authentication
**Schema**: JSON Schema Draft-07
**Description**: Authentication schemas for webapp, consensus network, and streaming services.

---

## Data Structures

### WebappLoginRequest

Webapp login request.

- **Endpoint**: `POST /api/auth/login`

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| username | string | Yes | Player username |
| password | string | Yes | Player password |

### WebappLoginResponse

Webapp login response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| success | boolean | Yes | Login success status |
| message | string | No | Response message |

### WebappSession

Webapp session data.

| Field | Type | Required | Format | Description |
|-------|------|----------|--------|-------------|
| cookie | string | Yes | | Session cookie (PHPSESSID) |
| expires | string | No | date-time | Session expiration time |
| lastUsed | string | No | date-time | Last session usage time |

### ConsensusAccount

Consensus network account information.

| Field | Type | Required | Format | Description |
|-------|------|----------|--------|-------------|
| address | string | Yes | blockchain-address | Account address |
| pub_key | object | No | | Public key |
| account_number | string | Yes | | Account number |
| sequence | string | Yes | | Account sequence (nonce) |

### TransactionSigner

Transaction signer information.

| Field | Type | Required | Sensitive | Description |
|-------|------|----------|-----------|-------------|
| address | string | Yes | No | Signer address (blockchain-address format) |
| privateKey | string | No | **Yes** | Private key (never expose in production) |
| publicKey | string | No | No | Public key |
| sequence | string | No | No | Current sequence number |

### SignedTransaction

Signed transaction ready for submission.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| body | object | Yes | Transaction body |
| auth_info | object | Yes | Authentication information |
| signatures | array of string | Yes | Transaction signatures |

#### body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| messages | array | Yes | Transaction messages |
| memo | string | No | Transaction memo |

#### auth_info

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| signer_infos | array | Yes | Signer information |
| fee | object | Yes | Transaction fee |

The `fee` object:

| Field | Type | Description |
|-------|------|-------------|
| amount | array | Fee amount |
| gas_limit | string | Gas limit |

### NATSConnection

NATS connection configuration.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| url | string | Yes | NATS server URL: `nats://localhost:4222` or `ws://localhost:1443` |
| protocol | string | Yes | Protocol, always `NATS` |
| transport | string | No | Transport protocol: `tcp` or `WebSocket` |
| authentication | object | No | NATS authentication (optional, see below) |

#### authentication

| Field | Type | Description |
|-------|------|-------------|
| type | string | Authentication type: `token` or `username_password` |
| token | string | NATS token (if type is `token`) |
| username | string | NATS username (if type is `username_password`) |
| password | string | NATS password (if type is `username_password`). **Sensitive.** |

### AuthenticationConfig

Complete authentication configuration covering all three services.

#### webapp

| Field | Type | Sensitive | Description |
|-------|------|-----------|-------------|
| baseURL | string | No | Webapp base URL |
| username | string | No | Webapp username |
| password | string | **Yes** | Webapp password |
| session | WebappSession | No | Current session data |

#### consensus

| Field | Type | Description |
|-------|------|-------------|
| rpcURL | string | RPC URL |
| apiURL | string | API URL |
| signer | TransactionSigner | Signer information |

#### streaming

Uses the NATSConnection structure defined above.

---

## Authentication Flows

### Webapp Login Flow

**ID**: `webapp-login`
**Status**: Needs Verification

Session-based authentication for webapp API.

**Steps**:

1. **POST /api/auth/login** -- Submit login request (WebappLoginRequest), receive WebappLoginResponse. Store session.
2. **Use session cookie** -- Include `Cookie: {{session.cookie}}` header in subsequent requests.

**Error Handling**:

| Code | Action |
|------|--------|
| 401 | Session expired, re-authenticate |
| 403 | Invalid credentials or insufficient permissions |

### Consensus Transaction Flow

**ID**: `consensus-transaction`
**Status**: Implemented

Transaction signing for consensus network.

**Steps**:

1. **GET /cosmos/auth/v1beta1/accounts/{address}** -- Get account information including sequence number. Store as `account`.
2. **Create transaction** -- Use `account.sequence` for replay protection.
3. **Sign transaction** -- Sign with private key (never expose private key). Produces `signedTransaction`.
4. **POST /cosmos/tx/v1beta1/txs** -- Submit signed transaction (SignedTransaction) to network.

**Error Handling**:

| Code | Action |
|------|--------|
| 400 | Invalid transaction format |
| 401 | Invalid signature |
| 500 | Network error, retry with backoff |

### NATS Connection Flow

**ID**: `nats-connection`
**Status**: Implemented

NATS connection for GRASS streaming (authentication optional).

**Steps**:

1. **Connect to NATS** -- Use NATSConnection configuration. Authentication is optional.
2. **Subscribe to subjects** -- Subscribe to GRASS event subjects (e.g., `structs.player.*`, `structs.planet.*`).
3. **Handle messages** -- Process incoming real-time events via callback.

**Error Handling**:

| Error | Action |
|-------|--------|
| connection_failed | Retry with exponential backoff |
| authentication_failed | Check NATS credentials if authentication enabled |

### Wallet Signature Flow

**ID**: `wallet-signature`
**Status**: Planned

Wallet signature authentication (planned feature).

**Steps**:

1. **Request signature from wallet** -- Request wallet to sign authentication message.
2. **POST /api/auth/login** -- Submit signed message (WebappLoginRequest) for authentication.
3. **Receive authentication token** -- Store token for subsequent requests.

This flow is planned but not yet implemented. See `roadmap.md` for status.

### API Key Authentication

**ID**: `api-key`
**Status**: Planned

API key authentication (planned feature).

**Steps**:

1. **Include API key in request headers** -- Include `X-API-Key: {{apiKey}}` header in requests.

This flow is planned but not yet implemented. See `roadmap.md` for status.

---

## Authentication Status Summary

| Service | Status | Description | Implementation |
|---------|--------|-------------|----------------|
| Webapp | Implemented | Session-based authentication for webapp API | PHP Symfony application (structs-webapp). Main user-facing API. |
| Consensus | Implemented | Transaction signing required for all transactions | All transactions must be signed with private key |
| Streaming | Implemented | NATS authentication is optional | NATS connection works without authentication; optional if configured |
| Wallet Signature | Planned | Wallet signature authentication | Not yet implemented, see `roadmap.md` |
| API Key | Planned | API key authentication | Not yet implemented, see `roadmap.md` |
| OAuth | Planned | OAuth integration | Not yet implemented, see `roadmap.md` |

---

## Security Notes

- **Private Keys**: Never expose private keys in code, logs, or documentation
- **Sessions**: Store sessions securely, handle expiration gracefully
- **Tokens**: Store API tokens securely if implemented
- **HTTPS**: Always use HTTPS/WSS in production

---

## References

- `protocols/authentication.md` - Complete authentication protocol
- `protocols/error-handling.md` - Error handling for authentication
- `protocols/streaming.md` - NATS connection details
- `roadmap.md` - Planned authentication features
