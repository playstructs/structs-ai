# API Error Codes

**Version**: 1.0.0
**Last Updated**: 2025-01-XX
**Description**: Complete catalog of API error codes for AI agents

---

## Error Code Reference

### HTTP Status Code Errors

| Code | Name | Category | Retryable | Action | Recovery |
|------|------|----------|-----------|--------|----------|
| 400 | BAD_REQUEST | client_error | No | Validate request parameters and format | Check request body, headers, and parameter types |
| 404 | NOT_FOUND | client_error | No | Verify resource ID and try again | Check if resource ID is correct, or query list to find valid IDs |
| 429 | RATE_LIMIT_EXCEEDED | rate_limit | Yes | Wait for retry_after seconds before retrying | Implement rate limiting: reduce request frequency, use exponential backoff, respect Retry-After header |
| 500 | INTERNAL_SERVER_ERROR | server_error | Yes | Retry with exponential backoff | If error persists, report issue with request_id |
| 503 | SERVICE_UNAVAILABLE | server_error | Yes | Wait for retry_after seconds, then retry | Service may be under maintenance or overloaded |

### Consensus Network Error Codes

| Code | Name | Category | Retryable | Action | Recovery |
|------|------|----------|-----------|--------|----------|
| 0 | SUCCESS | success | No | Continue processing | -- |
| 1 | GENERAL_ERROR | error | Yes | Log and retry with backoff | Max 3 retries with exponential backoff |
| 2 | INSUFFICIENT_FUNDS | error | No | Wait for resources | Check player inventory, wait for resources to accumulate |
| 3 | INVALID_SIGNATURE | error | Yes | Re-sign transaction | Verify signature generation, re-sign with correct private key |
| 4 | INSUFFICIENT_GAS | error | Yes | Increase gas limit | Estimate gas requirements, increase gas limit in transaction |
| 5 | INVALID_MESSAGE | error | No | Validate message format | Check message structure against schema, verify all required fields |
| 6 | PLAYER_HALTED | error | No | Wait for player online | Check player status, wait for player to come online |
| 7 | INSUFFICIENT_CHARGE | error | No | Wait for charge to accumulate | Check charge levels, wait for charge to regenerate |
| 8 | INVALID_LOCATION | error | No | Validate location | Check location format and validity |
| 9 | INVALID_TARGET | error | No | Validate target | Check target format and validity |
| 1900 | OBJECT_NOT_FOUND | error | No | Verify resource ID | Consensus Network returns 200 with error code, not 404. Check response.code field. |

### Network Errors

| Code | Name | Category | Retryable | Action | Recovery |
|------|------|----------|-----------|--------|----------|
| timeout | REQUEST_TIMEOUT | network_error | Yes | Retry with exponential backoff | Increase timeout duration or reduce request complexity |
| network | NETWORK_ERROR | network_error | Yes | Retry with exponential backoff | Check network connectivity, verify server is running |

### Cosmetic Mod Error Codes

| Code | Name | HTTP Status | Retryable | Action | Recovery |
|------|------|-------------|-----------|--------|----------|
| COSMETIC_MOD_NOT_FOUND | Cosmetic mod not found | 404 | No | Verify mod ID and check installed mods | List installed mods to find correct mod ID |
| COSMETIC_MOD_INVALID | Cosmetic mod validation failed | 400 | No | Fix mod file and retry | Check validation errors, fix mod manifest and structure, then retry |
| COSMETIC_MOD_INSTALL_FAILED | Cosmetic mod installation failed | 500 | Yes | Retry installation after checking disk space | Check disk space, verify mod file integrity, then retry |
| COSMETIC_MOD_CONFLICT | Cosmetic mod conflicts with existing mod | 409 | No | Uninstall existing mod or use different mod ID | Uninstall conflicting mod first, or use different mod ID/version |
| COSMETIC_MOD_UNSUPPORTED_VERSION | Cosmetic mod version incompatible | 400 | No | Update game or use compatible mod version | Check mod compatibility, update game or find compatible mod version |
| COSMETIC_STRUCT_TYPE_NOT_FOUND | Struct type referenced in mod not found | 400 | No | Fix mod to reference valid struct types | Verify struct type IDs in mod match game struct types, update mod manifest |

---

## Error Response Examples

### 400 BAD_REQUEST

```json
{
  "error": "Bad request",
  "code": 400,
  "details": ["Invalid parameter format"]
}
```

### 404 NOT_FOUND

Affected endpoints: `webapp-player-by-id`, `webapp-planet-by-id`, `webapp-guild-by-id`, `webapp-struct-by-id`, `player-by-id`, `planet-by-id`, `guild-by-id`, `struct-by-id`, `cosmetic-mod-get`

```json
{
  "error": "Player not found",
  "code": 404,
  "details": ["Player ID 1-999 does not exist"]
}
```

### 429 RATE_LIMIT_EXCEEDED

```json
{
  "error": "Rate limit exceeded",
  "code": 429,
  "retry_after": 60,
  "limit": 100,
  "remaining": 0,
  "reset_at": "2025-01-01T00:01:00Z"
}
```

### 500 INTERNAL_SERVER_ERROR

```json
{
  "error": "Internal server error",
  "code": 500,
  "details": ["An unexpected error occurred"],
  "request_id": "req_1234567890"
}
```

### 503 SERVICE_UNAVAILABLE

```json
{
  "error": "Service unavailable",
  "code": 503,
  "details": ["Service is temporarily unavailable"],
  "retry_after": 30
}
```

### Consensus Network Errors (code 1-9, 1900)

Consensus Network errors are returned with HTTP 200 but with a non-zero `code` field in the response body.

```json
{
  "code": 2,
  "message": "codespace structs code 2: insufficient funds",
  "details": []
}
```

```json
{
  "code": 6,
  "message": "codespace structs code 6: player halted",
  "details": []
}
```

### Cosmetic Mod Validation Error

```json
{
  "valid": false,
  "errors": [
    "Invalid setHash format: must be 64-character hexadecimal string (SHA-256)",
    "Missing required field: manifest.version"
  ],
  "warnings": []
}
```

### Cosmetic Mod Conflict

```json
{
  "error": "Mod conflict",
  "code": 409,
  "details": [
    "Mod 'guild-alpha-miner-v1' version 1.0.0 already installed",
    "Use uninstall endpoint to remove existing mod first"
  ]
}
```

---

## Error Categories

| Category | Description | Codes |
|----------|-------------|-------|
| success | Successful operations | 0, 200 |
| client_error | Client-side errors (not retryable) | 400, 404, 5, 6, 7, 8, 9, 1900, COSMETIC_MOD_NOT_FOUND, COSMETIC_MOD_INVALID, COSMETIC_MOD_CONFLICT, COSMETIC_MOD_UNSUPPORTED_VERSION, COSMETIC_STRUCT_TYPE_NOT_FOUND |
| server_error | Server-side errors (retryable) | 500, 503, COSMETIC_MOD_INSTALL_FAILED |
| rate_limit | Rate limiting errors (retryable with delay) | 429 |
| network_error | Network-related errors (retryable) | timeout, network |
| error | Game-specific errors | 1, 2, 3, 4 |

---

## Retry Strategies

### Exponential Backoff

- **Initial delay**: 1000ms
- **Max delay**: 60000ms
- **Backoff multiplier**: 2
- **Max retries**: 5

Use for: server errors (500, 503), general errors (1), network errors

### Fixed Delay

- **Delay**: 5000ms
- **Max retries**: 3

Use for: rate limit errors when Retry-After header is not provided

### Respect Retry-After Header

- **Use header**: Yes
- **Max retries**: 10

Use for: rate limit errors (429) when Retry-After header is provided

---

## Related Documentation

- `schemas/errors.md` - Error schema definitions
- `schemas/responses.md` - Response definitions
- `patterns/retry-strategies.md` - Retry logic patterns
- `protocols/error-handling.md` - Error handling patterns
- `api/rate-limits.md` - Rate limit configuration
