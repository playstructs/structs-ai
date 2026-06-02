# Webapp Login

**Version**: 1.0.0
**Category**: Authentication

---

Examples of webapp authentication flows including login, authenticated requests, unauthorized handling, and logout.

The webapp does **not** use username/password. Login proves control of a Cosmos address by signing a deterministic message with that address's key; on success the server issues a `PHPSESSID` session cookie (there is no JWT/bearer token).

## Successful Webapp Login

**Signed message format** (`SignatureValidationManager::buildLoginMessage`):

```
LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}
```

For example, signing into guild `0-1` as `structs1abc...` at unix time `1715000000` signs the literal string `LOGIN_GUILD0-1ADDRESSstructs1abc...DATETIME1715000000`. The `unix_timestamp` must be within 600 seconds (10 minutes) of server time or login is rejected.

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
    "signature": "base64-encoded-signature",
    "pubkey": "base64-encoded-pubkey",
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
    "errors": {},
    "data": null
  }
}
```

**Next Steps:**

1. Store session cookie: `session.cookie = 'PHPSESSID=abc123def456'`
2. Use cookie in subsequent requests (e.g., `GET /api/guild/this` with `Cookie` header). Browser clients must set `credentials: include`.

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
    "pubkey": "base64-encoded-pubkey",
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

Make an authenticated request using the session cookie obtained at login.

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/guild/this",
  "headers": {
    "Cookie": "PHPSESSID=abc123def456",
    "Accept": "application/json"
  }
}
```

**Response (200):**

`/api/guild/this` returns the **host/infrastructure guild** for this deployment (`guild_meta.this_infrastructure = TRUE`) — not the logged-in player's guild. It is one of the few public routes. Guild IDs are type `0`.

```json
{
  "success": true,
  "errors": {},
  "data": {
    "id": "0-1",
    "name": "My Guild"
  }
}
```

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

Logout and clear the session.

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
  "errors": {},
  "data": null
}
```

**Next Steps:**

1. Clear session cookie: `session.cookie = null`

---

## Related Documentation

- [Authentication Protocol](../../protocols/authentication.md)
- [Authenticated Guild Query Workflow](../workflows/authenticated-guild-query.md)
- [Error Handling Protocol](../../protocols/error-handling.md)
