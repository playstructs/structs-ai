# Webapp Login

**Version**: 1.0.0
**Category**: Authentication

---

Examples of webapp authentication flows including login, authenticated requests, unauthorized handling, and logout.

## Successful Webapp Login

Login to the webapp and receive a session cookie.

**Request:**

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/auth/login",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "username": "player_username",
    "password": "player_password"
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
    "message": "Login successful"
  }
}
```

**Next Steps:**

1. Store session cookie: `session.cookie = 'PHPSESSID=abc123def456'`
2. Use cookie in subsequent requests (e.g., `GET /api/guild/this` with `Cookie` header)

---

## Failed Webapp Login

Login failure with invalid credentials.

**Request:**

```json
{
  "method": "POST",
  "url": "http://localhost:8080/api/auth/login",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": {
    "username": "invalid_user",
    "password": "wrong_password"
  }
}
```

**Response (401):**

```json
{
  "body": {
    "success": false,
    "message": "Invalid credentials"
  }
}
```

### Error Handling

- **Action**: Do not retry
- **Recovery**: Request new credentials or check username/password

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

```json
{
  "guild": {
    "id": "1",
    "name": "My Guild"
  }
}
```

---

## Unauthorized Request

Request made without authentication.

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/guild/this",
  "headers": {
    "Accept": "application/json"
  }
}
```

**Response (401):**

```json
{
  "error": "Unauthorized",
  "message": "Authentication required"
}
```

### Error Handling

- **Action**: Re-authenticate
- **Recovery**: Login first, then retry request with session cookie

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
  "message": "Logged out successfully"
}
```

**Next Steps:**

1. Clear session cookie: `session.cookie = null`

---

## Related Documentation

- [Authentication Protocol](../../protocols/authentication.md)
- [Authenticated Guild Query Workflow](../workflows/authenticated-guild-query.md)
- [Error Handling Protocol](../../protocols/error-handling.md)
