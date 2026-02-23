# Authenticated Guild Query

**Version**: 1.0.0
**Workflow**: authenticated-guild-query
**Category**: Authentication

---

## Description

Authenticate and query current player's guild information.

## Prerequisites

- `webapp_username`
- `webapp_password`

## Steps

### 1. Authenticate with Webapp

- **Endpoint**: `webapp-auth-login`
- **Method**: `POST`
- **URL**: `http://localhost:8080/api/auth/login`

**Request Body**:

```json
{
  "username": "{{webapp_username}}",
  "password": "{{webapp_password}}"
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

- **Status**: `200`
- **Schema**: `schemas/responses.md#/definitions/AuthResponse`

**Error Handling**:

| Status | Action |
|--------|--------|
| 401 | Invalid credentials - verify username/password |
| 500 | Server error - retry with exponential backoff |

### 2. Get Current Player's Guild

- **Endpoint**: `webapp-guild-current`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/this`

**Request Headers**:

| Header | Value |
|--------|-------|
| Cookie | `{{step1.extract.session_cookie}}` |
| Accept | `application/json` |

**Data Extraction**:

- `guild_id` from `response.body.id`
- `guild_name` from `response.body.name`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/entities.md#/definitions/Guild`

**Error Handling**:

| Status | Action |
|--------|--------|
| 401 | Session expired - re-authenticate (go to step 1) |
| 404 | Player not in a guild |
| 500 | Server error - retry with exponential backoff |

### 3. Get Guild Member Count

- **Endpoint**: `webapp-guild-member-count`
- **Method**: `GET`
- **URL**: `http://localhost:8080/api/guild/{{step2.extract.guild_id}}/members/count`

**Request Headers**:

| Header | Value |
|--------|-------|
| Cookie | `{{step1.extract.session_cookie}}` |
| Accept | `application/json` |

**Data Extraction**:

- `member_count` from `response.body.count`

**Expected Response**:

- **Status**: `200`
- **Schema**: `schemas/responses.md#/definitions/CountResponse`

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
| 1 | 401 | Invalid credentials - cannot proceed |
| 1 | 500 | Server error - retry with exponential backoff |
| 2 | 401 | Session expired - re-authenticate and retry |
| 2 | 404 | Player not in a guild - result.guild will be null |

## Notes

This workflow demonstrates authentication followed by authenticated API calls. The session cookie from step 1 is used in subsequent requests.
