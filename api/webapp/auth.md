# Webapp Authentication API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Auth
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| POST | `/api/auth/signup` | Register a new player (signature) | No (public) |
| POST | `/api/auth/login` | Authenticate via Cosmos signature | No (public) |
| GET | `/api/auth/logout` | Clear the current session | No (public prefix) |
| GET | `/api/auth/player-address/{address}/guild/{guild_id}/player-id` | Resolve a player ID from an address + guild | No (public prefix) |
| POST | `/api/auth/player-address` | Propose a pending signing address (signature-validated) | No (public) |

All `/api/auth/*` routes are public (no session enforced by `PlayerAuthenticator`). `logout` operates on the current session cookie if one is present. The two `/api/auth/player-address*` routes are part of address registration — see [`player-address.md`](player-address.md) for the full address-management surface.

---

## Endpoint Details

### POST `/api/auth/signup`

Register a new player with the operating guild. Asynchronous: persisting the pending player triggers a `GuildMembershipJoinProxy` chain message and the player ID is assigned later — login must be called separately once the ID exists.

- **ID**: `webapp-auth-signup`
- **Authentication**: None

**Request body:** `primary_address`, `signature`, `pubkey`, `guild_id` (required); `username`, `pfp` (optional). Signed message (`buildGuildMembershipJoinProxyMessage`): `GUILD{guildId}ADDRESS{address}NONCE{nonce}` (nonce `0`).

Returns the standard envelope: `202 Accepted` with `{ "success": true, "errors": {}, "data": null }`, or `400`/`409` with keyed errors (`signature_validation_failed`, `resource_already_exists`).

> **Signup is the whole onboarding path — no activation code, no funds, no prior account.** A brand-new, unfunded key signs its own join request; the guild fronts the join fee on-chain via `MsgGuildMembershipJoinProxy`. Do **not** confuse this with activation codes: those belong to a *different* flow — adding another address/device to an **already-existing** player — documented in [`player-address.md`](player-address.md). A fresh player never needs a code from anywhere.

---

### POST `/api/auth/login`

Authenticate by Cosmos signature and receive a `PHPSESSID` session cookie. There is no username/password and no JWT/bearer token.

- **ID**: `webapp-auth-login`
- **Authentication**: None (this is how you obtain a session)

**Request body:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `address` | string | Yes | Cosmos address logging in (e.g. `structs1...`) |
| `signature` | string | Yes | Base64 signature over the login message |
| `pubkey` | string | Yes | Base64 public key for `address` |
| `guild_id` | string | Yes | Guild being logged into, type 0 (e.g. `0-1`) |
| `unix_timestamp` | string | Yes | Unix seconds; must be within 600s of server time |

**Signed message** (`SignatureValidationManager::buildLoginMessage`):

```
LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}
```

**Success (200):** `{ "success": true, "errors": {}, "data": null }` plus `Set-Cookie: PHPSESSID=...`.

**Failure (401):** `{ "success": false, "errors": { "signature_validation_failed": "Invalid signature" }, "data": null }`. Other keys: `player_address_does_not_exists`, `player_does_not_exists`.

See `examples/auth/webapp-login.md` for full flows.

---

### GET `/api/auth/logout`

Clear the current session. Returns the standard envelope `{ "success": true, "errors": {}, "data": null }`.

- **ID**: `webapp-auth-logout`
- **Authentication**: Public route (`^/api/auth/`); acts on the current session cookie if present

---

## Related Documentation

- **Protocol**: `../../protocols/authentication.md` - Authentication patterns
- **Example**: `../../examples/auth/webapp-login.md` - Working login example

---

*Last Updated: January 1, 2026*
