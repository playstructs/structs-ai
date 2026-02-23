# 500 Server Error

**Version**: 1.0.0
**Error Type**: `500-server-error`
**HTTP Status**: 500 / 503

---

Server error examples including internal server errors and service unavailable responses. These are transient errors that should be retried with appropriate backoff strategies.

## Scenario: Internal Server Error

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

**Response (500):**

```json
{
  "error": "Internal server error",
  "code": 500,
  "details": [
    "An unexpected error occurred"
  ],
  "request_id": "req_1234567890"
}
```

### Error Handling

- **Action**: Retry with exponential backoff
- **Retry**: Yes
- **Strategy**: Exponential backoff
- **Initial delay**: 1000 ms
- **Max delay**: 60000 ms
- **Max retries**: 5
- **Recovery**: If error persists, report the issue with the `request_id`

---

## Scenario: Service Unavailable

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

**Response (503):**

```json
{
  "headers": {
    "Content-Type": "application/json",
    "Retry-After": "30"
  },
  "body": {
    "error": "Service unavailable",
    "code": 503,
    "details": [
      "Service is temporarily unavailable"
    ],
    "retry_after": 30
  }
}
```

### Error Handling

- **Action**: Wait for `retry_after` seconds, then retry
- **Retry**: Yes
- **Retry after**: Use `response.retry_after` value
- **Max retries**: 10
- **Recovery**: Service may be under maintenance or overloaded

---

## Best Practices

- Implement exponential backoff for retry logic
- Log the `request_id` for debugging
- Respect the `Retry-After` header when present
- Implement the circuit breaker pattern for repeated failures
- Monitor error rates to detect systemic issues

---

## Related Documentation

- [Error Response Schema](../../schemas/responses.md)
- [Retry Strategies](../../patterns/retry-strategies.md)
- [Error Handling Protocol](../../protocols/error-handling.md)
