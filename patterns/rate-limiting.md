# Rate Limiting Pattern

**Version**: 1.0.0  
**Category**: API Patterns  
**Purpose**: Guide for AI agents on handling API rate limits effectively

---

## Overview

Rate limiting protects API servers from overload by restricting the number of requests a client can make within a time period. This pattern explains how to detect, handle, and work within rate limits when using Structs APIs.

---

## Rate Limit Basics

### What Are Rate Limits?

Rate limits restrict how many API requests you can make:
- **Per minute**: Maximum requests allowed in 60 seconds
- **Per hour**: Maximum requests allowed in 3600 seconds
- **Per endpoint**: Some endpoints have different limits

### Why Rate Limits Exist

- **Server Protection**: Prevent server overload
- **Fair Usage**: Ensure all clients get access
- **Cost Control**: Manage infrastructure costs
- **Quality of Service**: Maintain API performance

---

## Rate Limit Detection

### Response Headers

Rate limit information is provided in HTTP response headers:

```json
{
  "headers": {
    "X-RateLimit-Limit": "100",
    "X-RateLimit-Remaining": "45",
    "X-RateLimit-Reset": "1704067200",
    "Retry-After": "60"
  }
}
```

**Header Meanings**:
- `X-RateLimit-Limit`: Maximum requests allowed in the time window
- `X-RateLimit-Remaining`: Requests remaining in current window
- `X-RateLimit-Reset`: Unix timestamp when limit resets
- `Retry-After`: Seconds to wait before retrying (when rate limited)

### Rate Limit Status Codes

**429 Too Many Requests**: Rate limit exceeded

```json
{
  "status": 429,
  "headers": {
    "Retry-After": "60",
    "X-RateLimit-Limit": "100",
    "X-RateLimit-Remaining": "0",
    "X-RateLimit-Reset": "1704067200"
  },
  "body": {
    "error": "Rate limit exceeded",
    "code": 429,
    "message": "Too many requests",
    "retry_after": 60
  }
}
```

---

## Default Rate Limits

### Consensus Network API

**Base Limit**: 60 requests/minute

**Endpoints**:
- Query endpoints: 60/minute
- Transaction endpoints: 30/minute (lower due to processing cost)

### Web Application API

**Base Limit**: 100 requests/minute

**Endpoints**:
- Most endpoints: 100/minute
- Heavy endpoints (queries with joins): 50/minute

### RPC API

**Base Limit**: 30 requests/minute

**Endpoints**:
- All RPC endpoints: 30/minute

---

## Rate Limiting Strategies

### Strategy 1: Monitor and Throttle

**Approach**: Monitor rate limit headers and throttle requests proactively

**Implementation**:
```json
{
  "strategy": "monitor-and-throttle",
  "steps": [
    {
      "step": 1,
      "action": "Check X-RateLimit-Remaining header after each request"
    },
    {
      "step": 2,
      "action": "If remaining < 10, slow down request rate"
    },
    {
      "step": 3,
      "action": "Calculate delay: (60 / limit) * 1.1 seconds between requests"
    },
    {
      "step": 4,
      "action": "Resume normal rate when remaining > 20"
    }
  ]
}
```

**Example**:
- Limit: 100/minute
- Delay: (60 / 100) * 1.1 = 0.66 seconds between requests
- This ensures ~90 requests/minute (safety margin)

### Strategy 2: Exponential Backoff on 429

**Approach**: Retry with exponential backoff when rate limited

**Implementation**:
```json
{
  "strategy": "exponential-backoff",
  "on429": {
    "initialDelay": 1000,
    "maxDelay": 60000,
    "backoffMultiplier": 2,
    "maxRetries": 5,
    "useRetryAfter": true
  },
  "steps": [
    {
      "step": 1,
      "action": "Receive 429 response"
    },
    {
      "step": 2,
      "action": "Read Retry-After header (or use initial delay)"
    },
    {
      "step": 3,
      "action": "Wait for delay period"
    },
    {
      "step": 4,
      "action": "Retry request"
    },
    {
      "step": 5,
      "action": "If still 429, double delay and retry (up to max)"
    }
  ]
}
```

**Example**:
- First retry: Wait 60 seconds (from Retry-After)
- Second retry: Wait 120 seconds
- Third retry: Wait 240 seconds
- Max delay: 60 seconds (cap)

### Strategy 3: Request Queuing

**Approach**: Queue requests and process at rate limit pace

**Implementation**:
```json
{
  "strategy": "request-queuing",
  "queue": {
    "maxSize": 1000,
    "processingRate": "100/minute",
    "batchSize": 10
  },
  "steps": [
    {
      "step": 1,
      "action": "Add requests to queue"
    },
    {
      "step": 2,
      "action": "Process queue at rate limit pace"
    },
    {
      "step": 3,
      "action": "Monitor rate limit headers"
    },
    {
      "step": 4,
      "action": "Adjust processing rate based on remaining"
    }
  ]
}
```

**Benefits**:
- Smooth request distribution
- No wasted requests
- Predictable behavior

---

## Best Practices

### 1. Always Check Rate Limit Headers

**Do**:
```json
{
  "afterEachRequest": {
    "check": "response.headers.X-RateLimit-Remaining",
    "action": "Adjust request rate if low"
  }
}
```

**Don't**:
- Ignore rate limit headers
- Make requests blindly
- Assume unlimited requests

### 2. Respect Retry-After Header

**Do**:
```json
{
  "on429": {
    "wait": "response.headers.Retry-After",
    "unit": "seconds"
  }
}
```

**Don't**:
- Retry immediately
- Use fixed delays when Retry-After is provided
- Ignore server guidance

### 3. Implement Request Throttling

**Do**:
```json
{
  "throttling": {
    "enabled": true,
    "rate": "90% of limit",
    "monitor": "X-RateLimit-Remaining"
  }
}
```

**Don't**:
- Use 100% of limit (no safety margin)
- Ignore remaining count
- Burst requests

### 4. Cache Responses When Possible

**Do**:
```json
{
  "caching": {
    "enabled": true,
    "ttl": 300,
    "keys": ["player-{id}", "guild-{id}"]
  }
}
```

**Benefits**:
- Reduces API calls
- Stays within rate limits
- Improves performance

### 5. Use Streaming for Real-time Data

**Do**:
```json
{
  "streaming": {
    "use": "GRASS/NATS",
    "subjects": ["structs.player.*", "structs.planet.*"],
    "benefit": "No rate limits on streaming"
  }
}
```

**Benefits**:
- Real-time updates
- No rate limit concerns
- Efficient data delivery

---

## Error Handling

### Handling 429 Responses

**Pattern**:
```json
{
  "errorHandling": {
    "429": {
      "action": "retry-with-backoff",
      "strategy": "exponential-backoff",
      "useRetryAfter": true,
      "maxRetries": 5,
      "onMaxRetries": "queue-for-later"
    }
  }
}
```

**Implementation**:
1. Read `Retry-After` header
2. Wait for specified time
3. Retry request
4. If still 429, use exponential backoff
5. After max retries, queue request for later

### Handling Rate Limit Headers

**Pattern**:
```json
{
  "headerMonitoring": {
    "checkAfterEachRequest": true,
    "headers": [
      "X-RateLimit-Remaining",
      "X-RateLimit-Reset"
    ],
    "actions": {
      "remaining < 10": "throttle-requests",
      "remaining = 0": "stop-requests-until-reset"
    }
  }
}
```

---

## Implementation Examples

### Example 1: Simple Throttling

```json
{
  "implementation": "simple-throttling",
  "code": {
    "javascript": "const delay = (60 / rateLimit) * 1000; // ms\n\nasync function makeRequest(url) {\n  await new Promise(resolve => setTimeout(resolve, delay));\n  return fetch(url);\n}"
  },
  "description": "Simple fixed delay between requests"
}
```

### Example 2: Adaptive Throttling

```json
{
  "implementation": "adaptive-throttling",
  "code": {
    "javascript": "let remaining = 100;\n\nasync function makeRequest(url) {\n  if (remaining < 10) {\n    const delay = (60 / rateLimit) * 2 * 1000; // Double delay\n    await new Promise(resolve => setTimeout(resolve, delay));\n  }\n  \n  const response = await fetch(url);\n  remaining = parseInt(response.headers.get('X-RateLimit-Remaining'));\n  return response;\n}"
  },
  "description": "Adjust delay based on remaining requests"
}
```

### Example 3: Exponential Backoff

```json
{
  "implementation": "exponential-backoff",
  "code": {
    "javascript": "async function makeRequestWithRetry(url, retries = 5) {\n  try {\n    const response = await fetch(url);\n    \n    if (response.status === 429) {\n      const retryAfter = parseInt(response.headers.get('Retry-After')) || 60;\n      await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));\n      \n      if (retries > 0) {\n        return makeRequestWithRetry(url, retries - 1);\n      }\n    }\n    \n    return response;\n  } catch (error) {\n    throw error;\n  }\n}"
  },
  "description": "Retry with exponential backoff on 429"
}
```

---

## Monitoring Rate Limits

### Track Rate Limit Usage

**Metrics to Monitor**:
- Requests per minute
- Rate limit remaining
- 429 error count
- Average delay between requests

**Example**:
```json
{
  "monitoring": {
    "metrics": {
      "requestsPerMinute": 85,
      "rateLimitRemaining": 15,
      "rateLimitLimit": 100,
      "rateLimitReset": "1704067200",
      "429Errors": 2,
      "averageDelay": 0.7
    },
    "alerts": {
      "remaining < 10": "warning",
      "remaining = 0": "error",
      "429Errors > 5": "error"
    }
  }
}
```

---

## Related Documentation

- **Rate Limits**: `api/rate-limits.md` - Complete rate limit catalog
- **Error Handling**: `protocols/error-handling.md` - Error handling protocol
- **Error Codes**: `api/error-codes.md` - Error code definitions
- **Error Examples**: `examples/errors/429-rate-limit.md` - Rate limit error example
- **Streaming**: `protocols/streaming.md` - GRASS/NATS streaming (no rate limits)

---

## Quick Reference

### Rate Limit Headers
- `X-RateLimit-Limit`: Maximum requests
- `X-RateLimit-Remaining`: Remaining requests
- `X-RateLimit-Reset`: Reset timestamp
- `Retry-After`: Seconds to wait

### Default Limits
- Consensus Network: 60/minute
- Web Application: 100/minute
- RPC: 30/minute

### Best Practices
1. Monitor rate limit headers
2. Respect Retry-After header
3. Implement request throttling
4. Cache responses when possible
5. Use streaming for real-time data

---

*Pattern Version: 1.0.0 - December 7, 2025*
