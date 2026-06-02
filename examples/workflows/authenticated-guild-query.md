# Authenticated Guild Query

**Version**: 1.0.0
**Workflow**: authenticated-guild-query
**Category**: Authentication

---

## Description

Authenticate by Cosmos signature, then query guild information.

## Prerequisites

- `webapp_address` (a Cosmos address that is an approved member of the target guild)
- `webapp_pubkey` and the corresponding private key for signing
- `webapp_guild_id` (the guild to log into, type 0 e.g. `0-1`)

## Steps

### 1. Authenticate with Webapp

- **Endpoint**: `webapp-auth-login`
- **Method**: `POST`
- **URL**: `http://localhost:8080/api/auth/login`

Sign the message `LOGIN_GUILD{guild_id}ADDRESS{address}DATETIME{unix_timestamp}` (timestamp within 600s of server time) and submit the signature.

**Request Body**:

```json
{
  "address": "{{webapp_address}}",
  "signature": "{{login_signature}}",
  "pubkey": "{{webapp_pubkey}}",
  "guild_id": "{{webapp_guild_id}}",
  "unix_timestamp": "{{unix_timestamp}}"
}
```

**Request Headers**:

| Header | Value |
|--------|-------|
| Content-Type | `application/json` |

**Data Extraction**:

- `session_cookie` from `response.headers.Set-Cookie`
- `session_id` from `response.headers.Set-Cookie` (extract PHPSESSID value)

**Expected Response**:

- **Status**: `200` — body `{ "success": true, "errors": {}, "data": null }`
- **Schema**: `schemas/responses.md#/definitions/AuthResponse`

**Error Handling**:

| Status | Action |
|--------|--------|
| 401 | `errors.signature_validation_failed` (re-sign with fresh timestamp) or `errors.player_address_does_not_exists` (address not an approved member) |
| 500 | Server error - retry with exponential backoff |

### 2. Get the Host/Infrastructure Guild

- **Endpoint**: `webapp-guild-this`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/this`

> `/api/guild/this` returns the deployment's host guild (`guild_meta.this_infrastructure = TRUE`), not the logged-in player's guild. It is public. For the operator's own guild, read `session.guild_id` (set at login) or the player record.

**Request Headers**:

| Header | Value |
|--------|-------|
| Accept | `application/json` |

**Data Extraction**:

- `guild_id` from `response.body.data.id`
- `guild_name` from `response.body.data.name`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/entities.md#/definitions/Guild` (inside `data`)

**Error Handling**:

| Status | Action |
|--------|--------|
| 500 | Server error - retry with exponential backoff |

### 3. Get Guild Member Count

- **Endpoint**: `webapp-guild-member-count`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/{{step2.extract.guild_id}}/members/count`

**Request Headers** (session required):

| Header | Value |
|--------|-------|
| Cookie | `{{step1.extract.session_cookie}}` |
| Accept | `application/json` |

**Data Extraction**:

- `member_count` from `response.body.data.count`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/responses.md#/definitions/CountResponse` (inside `data`)

## Result

```json
{
  "guild": {
    "id": "{{step2.extract.guild_id}}",
    "name": "{{step2.extract.guild_name}}",
    "member_count": "{{step3.extract.member_count}}"
  },
  "session": {
    "cookie": "{{step1.extract.session_cookie}}"
  }
}
```

## Error Handling Summary

| Step | Status | Action |
|------|--------|--------|
| 1 | 401 | Signature/timestamp invalid or address not an approved member - cannot proceed |
| 1 | 500 | Server error - retry with exponential backoff |
| 3 | 401 | Session expired - re-authenticate and retry |

## Notes

This workflow demonstrates authentication followed by authenticated API calls. The session cookie from step 1 is used in subsequent requests.
