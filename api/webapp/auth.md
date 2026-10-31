---
description: "Wallet-signature session and bearer authentication, logout, and the public guild API boundary."
---

# Webapp Authentication API Endpoints

**Category**: webapp
**Base URL**: the guild's advertised webapp origin; paths below include `/api`.
**Reviewed implementation**: structs-webapp `581fcd0f` (integration branch).

These contracts require the matching API deployment. A chain version or a database
image alone does not establish that a guild serves them.

## Endpoint Summary

| Method | Path | Purpose | API authentication |
|---|---|---|---|
| POST | `/api/auth/signup` | Submit signed guild proxy signup | Public, signature validated |
| POST | `/api/auth/login` | Establish a session cookie | Public, signature validated |
| POST | `/api/auth/token` | Obtain a bearer token | Public, same signature validation |
| POST | `/api/auth/logout` | Invalidate the presented session and revoke the presented bearer | Public |
| GET | `/api/auth/player-address/{address}/guild/{guild_id}/player-id` | Resolve approved player membership | Public |
| GET | `/api/auth/activation-code/{code}` | Resolve the active code's player and activation identity | Public |
| GET | `/api/auth/player-address/{address}/player/{player_id}/proof` | Read native registration proof context | Public |
| GET | `/api/auth/player-address/{address}/player/{player_id}/registration` | Read native and indexed registration status | Public |
| POST | `/api/auth/player-address` | Submit one device's signed consent | Public, signature and activation validated |

The [device API](player-address.md) defines activation and private metadata routes.
An API session is separate from the signing key's chain authority.

## Registration request limits

The proof/status GET routes and pending-consent POST share a client token bucket (12-request burst, one token per two seconds) and a container-wide bucket (60-request burst, ten tokens per second). Symfony uses trusted-proxy-aware client IPs, normalizes IPv4-mapped IPv6 to IPv4 and groups other IPv6 addresses by /64. Filesystem cache and flock locks share budgets across PHP workers. Rejection returns 429, Retry-After and Cache-Control: no-store before native queries. The stock deployment supports one webapp replica. Shared sessions, bearer/cache state and locks are required before adding replicas. Configure explicit trusted proxies for deployment; this is not a substitute for an edge limit. Other public signup/discovery routes retain their existing access policy.

Native reads through `ChainSnapshotManager` also consume a shared budget across
routes: 120 tokens/client replenished at 12/second and 480 global tokens at
48/second. Retained-funds cache misses have their own window budget as well.
Exhaustion of native reads can appear as unavailable evidence or 503 from the
calling manager; it does not always use the registration subscriber's 429 envelope.
Back off and keep unknown values distinct from zero.

## Signed login request

`POST /api/auth/login` and `POST /api/auth/token` accept the same JSON body:

| Field | Type | Meaning |
|---|---|---|
| `address` | string | Approved signing address belonging to the requested guild |
| `signature` | string | Hex-encoded raw secp256k1 signature (`R` followed by `S`) (64 bytes / 128 hex characters) |
| `pubkey` | string | Hex-encoded compressed secp256k1 public key (33 bytes / 66 hex characters) |
| `guild_id` | string | Guild ID, such as `0-1` |
| `unix_timestamp` | string | Canonical decimal Unix seconds, less than 600 seconds from server time in either direction |

Sign SHA-256 of the UTF-8 bytes of this exact string:

```text
LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}
```

Use a fresh timestamp. The login proof does not use the address-registration nonce
or an Amino document. A matching public key/signature is insufficient if the indexed
address is not approved in that guild or its player does not exist.

Success from `/login` is HTTP 200 with a session cookie and:

```json
{"success":true,"errors":[],"data":null}
```

Success from `/token` is HTTP 200 with:

```json
{
  "success": true,
  "errors": [],
  "data": {
    "access_token": "<opaque credential>",
    "token_type": "Bearer",
    "expires_in": 86400,
    "player_id": "1-11"
  }
}
```

Treat the bearer as opaque; it is HMAC-signed, not a JWT. Carry it in
`Authorization: Bearer <token>`. A syntactically valid Bearer header with an invalid,
expired or revoked token returns 401 even if a valid session cookie accompanies it.
No token is needed for the explicitly public guild reads below.

Failure is HTTP 401 with `success:false`, `data:null` and keyed `errors`, including
`signature_validation_failed`, `player_address_does_not_exists` or
`player_does_not_exists`. Handle an API outage separately from a rejected identity.

## Authenticated requests and logout

Same-origin browser requests use `credentials: 'include'`; other clients preserve
the session cookie or use the bearer. Private API reads and writes still enforce
their owning-player checks. Bearer support does not by itself enable browser CORS:
verify the deployment's origin policy before using private routes across origins.

`POST /api/auth/logout` returns the success envelope above, also when already logged
out. A GET is not a logout request; POST prevents cross-site links/images from
ending a SameSite=Lax session. It loads and invalidates the cookie's server session, clears its player/guild
claims, and revokes a presented valid bearer until that token expires. A different
bearer is unaffected. Revocation records live in the application's cache, which
must survive as required by the deployment's token lifetime.

Clear the local wallet/session when logging out even if the HTTP request fails.
Preserve public evidence of uncertain signed transactions; local logout is not
proof of native address revocation. See the [login example](../../examples/auth/webapp-login.md).

## Public guild reads

These exact routes accept anonymous GET/HEAD for signup discovery and cross-guild
statistics:

- `/api/guild/this`, `/api/guild/name`, `/api/guild/count`, `/api/guild/directory`
- `/api/guild/{guild_id}`, `/api/guild/{guild_id}/name`
- `/api/guild/{guild_id}/members/count`, `/api/guild/{guild_id}/power/stats`
- `/api/guild/{guild_id}/roster`, `/api/guild/{guild_id}/planet/complete/count`

`guild_id` has the `0-N` form. The allowlist is exact; placing one of these strings
inside a private path or query does not make that request public. These reads use
`Access-Control-Allow-Origin: *`. Cross-origin callers omit cookies and tokens.
OPTIONS preflight supports GET/HEAD with Accept/Content-Type request headers, not
Authorization, credentialed requests or writes.

The `/api/auth/`, `/api/timestamp` and `/api/setting` firewall paths and exact
`/api/onboarding/events` route are public too. Struct, reactor, ledger, player and
planet-activity reads remain authenticated. Device metadata and account management
remain private. The authenticated `/api/` firewall also has an
`IS_AUTHENTICATED` access-control backstop. Explicit public firewalls bypass that
rule; do not make arbitrary private paths public to resolve a 401.

## POST `/api/auth/signup`

Signup accepts required `primary_address`, `signature`, `pubkey`, `guild_id` and
optional `username`, `pfp`, `pfp_client_render_attributes`. Sign
`GUILD{guildId}ADDRESS{address}NONCE0` using the same hex encoding. Persisting the
pending row starts asynchronous guild proxy onboarding; 202 means accepted, not
registered on chain. Poll approved membership and then log in separately. The guild
fronts the on-chain cost, so an unfunded new key can use this path.

Invalid input/signature returns 400; an existing pending/approved address returns
409 `resource_already_exists`. Resolve that address's actual player before adopting
an existing signup. No activation code is needed for a new player; activation adds
a device to an existing player.

## OIDC provider operations

Separately from wallet-signature login, the guild webapp can act as an OpenID Connect
provider for Matrix Authentication Service. Structs-pg stores the operator-managed
client registry in `structs.oidc_client` and short-lived flow state in
`oidc_authorization_request`, `oidc_authorization_code`, and `oidc_access_token`.
These hold client metadata, hashes, redirect URIs, scopes, PKCE/state/nonce data,
player IDs and expiry/revocation timestamps, never wallet material.

The `structs_webapp` role owns that row lifecycle. `oidc_cleaner` runs every 59 seconds;
it removes expired requests/codes after a one-hour grace period and expired access
tokens after one day. Client seeding and endpoint configuration are deployment concerns.

*OIDC storage/cleanup retains its separate verification against structs-pg `f66fd81`
(`table-oidc-20260826-provider`, `role-structs-webapp-20260826-oidc`). Authentication,
public-route and logout behavior reviewed against webapp `581fcd0f`; real signed
session/bearer HTTP checks passed against an isolated release node.*

*Scoped changes reviewed at webapp `461bba5a`: POST-only logout, the private API authentication backstop, ClientKey normalization and NativeReadBudget. The earlier full authentication and OIDC reviews above retain their stated scope.*
