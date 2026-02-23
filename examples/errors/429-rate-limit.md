# 429 Rate Limit Exceeded

**Version**: 1.0.0
**Error Type**: `429-rate-limit`
**HTTP Status**: 429

---

Rate limit exceeded error example. This error occurs when the client sends too many requests within a given time window.

## Scenario: Rate Limit Exceeded

**Endpoint**: Any

**Request:**

```json
{
  "method": "GET",
  "url": "http://localhost:8080/api/player/1-11",
  "headers": {
    "Accept": "application/json"
  }
}
```

**Response (429):**

```json
{
  "headers": {
    "Content-Type": "application/json",
    "Retry-After": "60",
    "X-RateLimit-Limit": "100",
    "X-RateLimit-Remaining": "0",
    "X-RateLimit-Reset": "1704067260"
  },
  "body": {
    "error": "Rate limit exceeded",
    "code": 429,
    "retry_after": 60,
    "limit": 100,
    "remaining": 0,
    "reset_at": "2025-01-01T00:01:00Z"
  }
}
```

### Error Handling

- **Action**: Wait for `retry_after` seconds before retrying
- **Retry**: Yes
- **Retry after**: Use `response.retry_after` value
- **Strategy**: Exponential backoff
- **Max retries**: 3
- **Recovery**: Reduce request frequency, use exponential backoff, and respect the `Retry-After` header

### Rate Limit Headers

| Header | Description |
|---|---|
| `Retry-After` | Seconds to wait before the next request |
| `X-RateLimit-Limit` | Maximum requests allowed per window |
| `X-RateLimit-Remaining` | Requests remaining in current window |
| `X-RateLimit-Reset` | Unix timestamp when the rate limit resets |

---

## Best Practices

- Implement request throttling to stay within limits
- Respect the `Retry-After` header
- Use exponential backoff when rate limited
- Monitor rate limit headers proactively
- Cache responses when possible to reduce API calls

---

## Related Documentation

- [Rate Limit Response Schema](../../schemas/responses.md)
- [Rate Limiting Patterns](../../patterns/rate-limiting.md)
- [Caching Patterns](../../patterns/caching.md)
- [Error Handling Protocol](../../protocols/error-handling.md)
