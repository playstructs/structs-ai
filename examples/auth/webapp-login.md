---
title: Webapp login authentication example
description: "Web application authentication worked through: successful login, failed login, authenticated requests, and handling a 401."
---

# Webapp login authentication example

**Version**: 1.0.0
**Category**: Authentication

---

Examples of webapp authentication flows including login, authenticated requests, unauthorized handling, and logout.

The webapp does **not** use username/password. Login proves control of a Cosmos address by signing a deterministic message with that address's key; POST `/api/auth/login` returns a session cookie. POST `/api/auth/token` accepts the same proof and returns an opaque bearer token (not a JWT). These examples describe integration `5991ca95`; confirm the guild has deployed the matching API.

## Successful Webapp Login

**Signed message format** (`SignatureValidationManager::buildLoginMessage`):

```
LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}
```

For example, signing into guild `0-1` as `structs1abc...` at unix time `1715000000` signs the literal string `LOGIN_GUILD0-1ADDRESSstructs1abc...DATETIME1715000000`. The `unix_timestamp` must be a canonical decimal string less than 600 seconds (10 minutes) from server time in either direction or login is rejected.

Sign SHA-256 of the UTF-8 message using secp256k1. Encode the compressed 33-byte
public key and 64-byte raw signature as hex; the strings below are placeholders.

**Request:**

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/auth/login",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "address": "structs1abc...",
    "signature": "hex-raw-R-then-S-signature",
    "pubkey": "hex-compressed-pubkey",
    "guild_id": "0-1",
    "unix_timestamp": "1715000000"
  }
}
```

**Response (200):**

```json
{
  "headers": {
    "Set-Cookie": "PHPSESSID=abc123def456; Path=/; HttpOnly",
    "Content-Type": "application/json"
  },
  "body": {
    "success": true,
    "errors": [],
    "data": null
  }
}
```

**Next Steps:**

1. Store session cookie: `session.cookie = 'PHPSESSID=abc123def456'`
2. Use the cookie for private reads (for example, `GET /api/player/1-11`). Browsers use `credentials: 'include'` and manage HttpOnly cookies themselves; do not copy them into JavaScript storage.

---

## Failed Webapp Login

Login failure (bad signature, expired timestamp, or unknown address) returns HTTP 401 with a **keyed** `errors` object — not a `message` string.

**Request:**

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/auth/login",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "address": "structs1abc...",
    "signature": "bad-signature",
    "pubkey": "hex-compressed-pubkey",
    "guild_id": "0-1",
    "unix_timestamp": "1715000000"
  }
}
```

**Response (401):**

```json
{
  "body": {
    "success": false,
    "errors": {
      "signature_validation_failed": "Invalid signature"
    },
    "data": null
  }
}
```

Other possible error keys: `player_address_does_not_exists` (no approved address for that guild), `player_does_not_exists`.

### Error Handling

- **Action**: Do not retry blindly — inspect the `errors` key.
- **Recovery**: Re-sign with a fresh `unix_timestamp` (signatures expire after 600s), confirm the address is an approved member of the target guild, and verify the signed-message format above.

---

## Authenticated Request

Make an authenticated request using the session cookie obtained at login. The endpoint below needs authentication; the guild discovery routes do not.

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/player/1-11",
  "headers": {
    "Cookie": "PHPSESSID=abc123def456",
    "Accept": "application/json"
  }
}
```

**Response (200):**

The response uses the standard envelope; `data` is the player read model. Preserve
its readiness metadata and exact amount strings. `/api/guild/this` instead returns
the infrastructure guild and is public, as are the explicitly listed
[guild reads](../../api/webapp/auth.md#public-guild-reads).

---

## Unauthorized Request

A session-gated request made without a valid `PHPSESSID` cookie returns HTTP 401. (Note: `/api/guild/this` itself is public; use a session-gated route such as `/api/reactor/all/page/1` to see this.)

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/reactor/all/page/1",
  "headers": {
    "Accept": "application/json"
  }
}
```

**Response (401):** the request is rejected by `PlayerAuthenticator` before reaching the controller.

### Error Handling

- **Action**: Re-authenticate
- **Recovery**: Login first (signature flow above), then retry the request with the session cookie

---

## Logout

Logout invalidates the server session and revokes a supplied bearer token. This does not revoke the native signing address.

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/auth/logout",
  "headers": {
    "Cookie": "PHPSESSID=abc123def456"
  }
}
```

**Response (200):**

```json
{
  "success": true,
  "errors": [],
  "data": null
}
```

**Next Steps:**

1. Clear locally saved credentials even if the HTTP request fails. A successfully
   invalidated cookie cannot authenticate again.
2. Preserve public evidence of uncertain native submissions; never turn logout
   into a replacement transaction or a claim that a send failed.

## Bearer variant

Submit the same signed body to POST `/api/auth/token`. Read
`data.access_token`, `data.token_type` (`Bearer`), `data.expires_in` (`86400`) and
`data.player_id` from the successful envelope. Keep the token as an opaque secret
and pass `Authorization: Bearer <token>` on private requests and logout. A malformed,
expired or revoked Bearer token cannot rescue itself through an accompanying valid
cookie. A different token remains valid after logout of the presented token.

Browser CORS is a separate deployment requirement. For anonymous cross-guild reads,
omit cookies and Authorization entirely. See [auth.md](../../api/webapp/auth.md)
for the exact public paths and request-header policy.

---

## Related Documentation

- [Authentication Protocol](../../protocols/authentication.md)
- [Authenticated Guild Query Workflow](../workflows/authenticated-guild-query.md)
- [Error Handling Protocol](../../protocols/error-handling.md)
