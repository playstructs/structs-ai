---
description: "Exact wallet login proofs, session and bearer responses, native signing identity, and streaming authentication boundaries."
---

# Authentication Data Structures

**Category**: authentication. These are wire-contract summaries, not a JSON Schema
validator. The [authentication reference](../api/webapp/auth.md) defines the routes;
[authentication protocol](../protocols/authentication.md) explains their use.

## Data Structures

### WebappLoginRequest

POST `/api/auth/login` for a server session, or `/api/auth/token` for an opaque
bearer token. Both accept the same JSON body and validate an approved address in
the requested guild and its existing player.

| Field | Type | Required | Encoding |
|---|---|---|---|
| `address` | string | Yes | Signing address; a vault is not a login address |
| `signature` | string | Yes | 128 hex characters: raw secp256k1 R followed by S |
| `pubkey` | string | Yes | 66 hex characters: compressed secp256k1 public key |
| `guild_id` | string | Yes | Guild ID such as `0-1` |
| `unix_timestamp` | string | Yes | Canonical decimal Unix seconds, less than 600 seconds from server time in either direction |

Sign SHA-256 of the UTF-8 bytes of this exact message, without added spaces:

```text
LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}
```

The wallet proof uses hex. Native protobuf public keys/signatures use their own
encoding; do not copy base64 native fields into this login body. Never transmit a
private key or recovery phrase to either endpoint.

### WebappLoginResponse

| Field | Type | Meaning |
|---|---|---|
| `success` | boolean | Whether login succeeded |
| `errors` | array or object | Empty array on success; keyed errors on failure |
| `data` | null or object | Session login returns null; token login returns the fields below |

Session login sets the server session cookie. Token login returns:

```json
{
  "success": true,
  "errors": [],
  "data": {
    "token": "opaque-token",
    "token_type": "Bearer",
    "expires_in": 86400
  }
}
```

The opaque token is not a JWT. `Authorization: Bearer <token>` authenticates
subsequent private requests. An invalid bearer credential does not fall back to a
valid cookie. Keep cookies/tokens private; the login response does not expose the
internal session's fields as a public object.

### WebappSession

The browser preserves the server cookie using its normal cookie policy; cross-origin
requests require appropriate credentials/CORS configuration. Logout clears Symfony's
security token and invalidates the server session; it also revokes a supplied bearer
token. [Public guild reads](../api/webapp/auth.md#public-guild-reads) do not require
login. Private device and entity/catalog reads do.

Browser-local key/session removal and on-chain address revocation are different
operations. Local logout can clear this browser without Delete permission; revoking
another key requires native authority and confirmed indexed completion. Preserve
public uncertain-transaction evidence across logout.

### ConsensusAccount

| Field | Encoding | Meaning |
|---|---|---|
| `address` | bech32 string | Native account identity |
| `account_number` | exact decimal string | uint64 account number |
| `sequence` | exact decimal string | uint64 signing sequence |
| `pub_key` | protobuf account field, possibly absent | Native public key |

Account JSON can be wrapped by the account type. Parse supported native types and
preserve exact integers. A missing account is not always proof of a spendable empty
BaseAccount; adopted vault accounts can have spend restrictions.

The account sequence is distinct from the Structs address-registration proxy nonce.
Read current nonce/owner/permissions for registration proof context; never substitute
one for the other.

### TransactionSigner

The signer is an approved ordinary player address with its own permission mask.
Its bits are a ceiling, even if the player or a guild grant authorizes more. The
message's asset-owner/delegator address is a subject, not a second signing identity.
A vault holds assets but does not become a signing key. Private material stays in
the wallet or TSA keyring, outside persisted public submission evidence.

### SignedTransaction

A signed protobuf `TxRaw` contains body bytes, auth-info bytes and signature bytes.
The LCD broadcast request contains base64 `tx_bytes` and a broadcast mode; a
human-readable `{body,auth_info,signatures}` description is not that request body.
The reference client persists the actual signed bytes, computed hash, chain,
signing address, account number, sequence and request identity before transport.

`CheckTx` success means admission. Confirm the matching hash/bytes in a committed
block and inspect its DeliverTx code. A timeout, HTTP failure, absent transaction
search result or changed account sequence does not prove non-inclusion. See
[retry strategies](../patterns/retry-strategies.md) before recovering a submission.

### NATSConnection

Use the NATS client configuration for the deployed server. Common transports are
`nats://localhost:4222` and `ws://localhost:1443`; authenticated deployments may
require a token or user/password. Webapp session/bearer credentials do not grant
native signing or NATS access. Protect transport credentials and use HTTPS/WSS
where the deployment requires secure browser transport.

### AuthenticationConfig

Keep API origin, chain ID, RPC/LCD origins, guild ID and signing address explicit.
Scope cached private reads and public submission journals to the applicable identity.
Store private keys and API credentials separately from shareable configuration.
Do not log full login bodies, cookies, bearer tokens or key material.

## Authentication Flows

### Webapp Login Flow

1. Build the current timestamped login message and sign with the selected address.
2. Submit the exact hex proof to the session or token route.
3. Retain the resulting credential privately and use it only on its intended origin.
4. On an expired private session, reauthenticate once. A rejected login must not
   recursively call its own reauthentication hook. A terminal rejection returns to
   the existing login flow while preserving the local key; it does not prove native
   revocation. Transient connection failure can retry a read without enabling sends.

### Consensus Transaction Flow

1. Resolve current protocol, native account/authority, exact amounts and action eligibility.
2. Prepare/simulate the intended message and sign once with exact account state.
3. Persist the signed identity before the one broadcast attempt.
4. Observe that identity to definitive rejection or committed success/failure.
   Revalidate later actions from fresh state; never replace an uncertain transaction.

### NATS Connection Flow

Connect using deployment credentials, subscribe to actual subject shapes, and
refresh authoritative state on reconnect. `structs.planet.{planet_id}.*` includes
the owner token; `structs.planet.*` does not. A reconnect is not event replay and a
notification is not signing authority. See [GRASS](../develop/client/realtime-grass.md).

### Wallet Signature Flow

Wallet-signature login is the implemented webapp session/token flow above. Native
device registration uses a separate proof and consent/activation identity; see
[player-address API](../api/webapp/player-address.md).

### API Key Authentication

The reviewed webapp authentication contract uses a session or issued opaque bearer
token. Do not invent an `X-API-Key` credential or treat an arbitrary API key as a
wallet signature. The separate OIDC provider is not a native transaction signer.

## Authentication Status Summary

| Service | Credential / authority |
|---|---|
| Webapp | Wallet-proof session or issued opaque bearer token; explicit public-read routes |
| Chain | Native signature, ordinary address ownership and current permissions |
| Streaming | Deployment-specific NATS authentication |
| Device registration | Target consent plus ordinary signing authority and current native proof context |

## Security Notes

Credentials and private keys remain private. Public signed submission evidence must
survive logout/restart until its outcome is established. Never repair an authentication
failure by widening permissions, inserting a vault into signing-address tables, or
clearing unresolved submissions.

## References

- [Authentication protocol](../protocols/authentication.md)
- [Authentication routes](../api/webapp/auth.md)
- [Signing lifecycle](../develop/client/actions-and-signing.md)
- [Streaming](../develop/client/realtime-grass.md)

**Verified against:** webapp integration `43bc1086`, its authentication/security and
signed-submission implementation. Native semantics use structsd release `96cea3a`;
an independently deployed guild API must expose this contract before clients use it.
