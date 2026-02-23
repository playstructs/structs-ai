# API Rate Limits

**Version**: 1.0.0
**Last Updated**: 2025-01-XX
**Description**: Rate limiting information for API endpoints

Rate limits may vary by deployment and are subject to change. Always check response headers for current limits.

---

## Rate Limit Headers

| Header | Description |
|--------|-------------|
| `X-RateLimit-Limit` | Maximum number of requests allowed in the time window |
| `X-RateLimit-Remaining` | Number of requests remaining in the current time window |
| `X-RateLimit-Reset` | Unix timestamp when the rate limit window resets |
| `Retry-After` | Number of seconds to wait before retrying (when rate limit exceeded) |

---

## Default Rate Limits

| API Tier | Requests/Minute | Requests/Hour | Window | Notes |
|----------|----------------|---------------|--------|-------|
| Consensus Network | 60 | 3,600 | 1 minute | Default limits for Consensus Network API endpoints |
| Web Application | 100 | 6,000 | 1 minute | Default limits for Web Application API endpoints |
| RPC | 30 | 1,800 | 1 minute | Default limits for RPC endpoints |

---

## Endpoint-Specific Rate Limits

### Consensus Network API

| Endpoint | Path | Method | Req/Min | Req/Hour | Notes |
|----------|------|--------|---------|----------|-------|
| player-by-id | `/structs/player/{id}` | GET | 60 | 3,600 | Standard query endpoint limit |
| player-list | `/structs/player` | GET | 30 | 1,800 | List endpoints may have lower limits due to pagination overhead |
| submit-transaction | `/cosmos/tx/v1beta1/txs` | POST | 10 | 600 | Transaction submission has stricter limits |

### Web Application API

| Endpoint | Path | Method | Req/Min | Req/Hour | Notes |
|----------|------|--------|---------|----------|-------|
| webapp-player-by-id | `/api/player/{player_id}` | GET | 100 | 6,000 | Standard webapp query endpoint |
| webapp-player-username-update | `/api/player/username` | PUT | 10 | 100 | Write operations have stricter limits |
| webapp-guild-directory | `/api/guild/directory` | GET | 30 | 1,800 | Directory/list endpoints may have lower limits |

### RPC Endpoints

| Endpoint | Path | Method | Req/Min | Req/Hour | Notes |
|----------|------|--------|---------|----------|-------|
| rpc-status | `/status` | GET | 30 | 1,800 | RPC endpoints have lower default limits |

---

## Rate Limit Error Response

**HTTP Status**: 429

**Headers**:

| Header | Example Value |
|--------|---------------|
| Content-Type | `application/json` |
| Retry-After | `60` |
| X-RateLimit-Limit | `100` |
| X-RateLimit-Remaining | `0` |
| X-RateLimit-Reset | `1704067260` |

**Body** (schema: `schemas/responses.md#RateLimitErrorResponse`):

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

---

## Best Practices

### Monitor Rate Limit Headers

Always check `X-RateLimit-*` headers in responses:

```json
{
  "X-RateLimit-Limit": "100",
  "X-RateLimit-Remaining": "95",
  "X-RateLimit-Reset": "1704067260"
}
```

### Implement Request Throttling

Throttle requests to stay within limits. Use a token bucket or sliding window algorithm.

### Respect Retry-After Header

When receiving 429, wait for `Retry-After` seconds:

```javascript
if (response.status === 429) {
  const retryAfter = parseInt(response.headers['Retry-After']);
  await sleep(retryAfter * 1000);
  // Retry request
}
```

### Use Exponential Backoff

For rate limit errors, use exponential backoff:

```json
{
  "initialDelay": 1000,
  "maxDelay": 60000,
  "backoffMultiplier": 2,
  "maxRetries": 3
}
```

### Cache Responses

Cache GET requests with appropriate TTL to reduce API calls.

### Batch Requests

Batch multiple operations when possible (not all endpoints support batching).

### Prioritize Critical Requests

Prioritize critical operations (e.g., transaction submission) over non-critical ones (e.g., status queries).

---

## Rate Limit Strategies

### Token Bucket

```json
{
  "tokens": 100,
  "refillRate": 100,
  "refillInterval": 60000,
  "maxTokens": 100
}
```

### Sliding Window

```json
{
  "windowSize": 60000,
  "maxRequests": 100,
  "trackRequests": true
}
```

### Fixed Window

```json
{
  "windowSize": 60000,
  "maxRequests": 100,
  "resetAt": "top of minute"
}
```

---

## Handling Rate Limits

### When Exceeded

1. **Check Retry-After header** - Read `Retry-After` value from response header
2. **Wait for retry window** - Wait for `Retry-After` seconds before retrying
3. **Implement backoff** - Use exponential backoff if `Retry-After` not provided
4. **Reduce request rate** - Reduce overall request frequency
5. **Cache responses** - Increase caching to reduce API calls

### Prevention

- Monitor rate limit headers in all responses
- Implement client-side rate limiting
- Use request queuing for high-volume operations
- Cache responses aggressively
- Batch operations when possible
- Prioritize critical requests

---

## Code Examples

### Check Rate Limit Headers

```javascript
const response = await fetch('/api/player/1-11');
const limit = response.headers.get('X-RateLimit-Limit');
const remaining = response.headers.get('X-RateLimit-Remaining');
const reset = response.headers.get('X-RateLimit-Reset');

console.log(`Limit: ${limit}, Remaining: ${remaining}, Reset: ${new Date(reset * 1000)}`);
```

### Handle Rate Limit Error

```javascript
async function makeRequestWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    const response = await fetch(url);

    if (response.status === 429) {
      const retryAfter = parseInt(response.headers.get('Retry-After') || '60');
      console.log(`Rate limited. Waiting ${retryAfter} seconds...`);
      await sleep(retryAfter * 1000);
      continue;
    }

    return response;
  }
  throw new Error('Max retries exceeded');
}
```

### Implement Request Throttling

```javascript
class RateLimiter {
  constructor(requestsPerMinute) {
    this.requestsPerMinute = requestsPerMinute;
    this.requests = [];
  }

  async waitIfNeeded() {
    const now = Date.now();
    const oneMinuteAgo = now - 60000;

    this.requests = this.requests.filter(time => time > oneMinuteAgo);

    if (this.requests.length >= this.requestsPerMinute) {
      const oldestRequest = this.requests[0];
      const waitTime = 60000 - (now - oldestRequest);
      await sleep(waitTime);
    }

    this.requests.push(now);
  }
}
```

---

## Related Documentation

- `api/error-codes.md` - Error code reference (including 429)
- `patterns/rate-limiting.md` - Rate limiting patterns
- `patterns/retry-strategies.md` - Retry strategy patterns
- `patterns/caching.md` - Caching strategies
