# Error Handling Protocol

**Version**: 1.0.0  
**Category**: Error  
**Status**: Stable

---

## Overview

The Error Handling Protocol defines how AI agents should handle errors when interacting with Structs APIs. This includes error response formats, retry strategies, error recovery patterns, and best practices.

**Key Principles**:
1. **Always check for errors** before processing responses
2. **Categorize errors** by retryability and severity
3. **Implement retry logic** for retryable errors
4. **Log all errors** for debugging and monitoring
5. **Provide fallback behavior** for non-retryable errors

---

## Error Response Formats

### Consensus Network API Error Response

**Format**:
```json
{
  "code": 2,
  "message": "codespace structs code 1900: object not found",
  "details": []
}
```

**Fields**:
- `code` (number): Error code (2 = not found)
- `message` (string): Human-readable error message with codespace and error code
- `details` (array): Additional error details (may be empty)

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/player/1-999",
    "headers": {
      "Accept": "application/json"
    }
  },
  "response": {
    "status": 400,
    "body": {
      "code": 2,
      "message": "codespace structs code 1900: object not found",
      "details": []
    }
  }
}
```

### Web Application API Error Response

**Format**:
```json
{
  "success": false,
  "data": null,
  "errors": [
    "Error message 1",
    "Error message 2"
  ]
}
```

**Fields**:
- `success` (boolean): Always `false` for errors
- `data` (null): No data on error
- `errors` (array): Array of error messages

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/player/999",
    "headers": {
      "Accept": "application/json"
    }
  },
  "response": {
    "status": 404,
    "body": {
      "success": false,
      "data": null,
      "errors": [
        "Player not found"
      ]
    }
  }
}
```

### HTTP Status Codes

**Standard HTTP Status Codes**:
- `200` - Success
- `400` - Bad Request (invalid request format)
- `404` - Not Found (resource doesn't exist)
- `429` - Too Many Requests (rate limit exceeded)
- `500` - Internal Server Error (server error)
- `503` - Service Unavailable (service temporarily unavailable)

---

## Error Categories

### Error Code Schema

All error codes are defined in `schemas/errors.md`. Categories include:

1. **Success** (`code: 0`): Operation successful
2. **Game Errors** (`codes: 1-9`): Game-specific errors
3. **HTTP Errors** (`codes: 400, 404, 500`): HTTP status codes
4. **Network Errors** (`timeout`, `network`): Network-related errors

### Retryable vs Non-Retryable Errors

**Retryable Errors** (can be retried):
- `GENERAL_ERROR` (code: 1)
- `INVALID_SIGNATURE` (code: 3)
- `INSUFFICIENT_GAS` (code: 4)
- `INTERNAL_SERVER_ERROR` (code: 500)
- `REQUEST_TIMEOUT` (timeout)
- `NETWORK_ERROR` (network)

**Non-Retryable Errors** (should not be retried):
- `INSUFFICIENT_FUNDS` (code: 2)
- `INVALID_MESSAGE` (code: 5)
- `PLAYER_HALTED` (code: 6)
- `INSUFFICIENT_CHARGE` (code: 7)
- `INVALID_LOCATION` (code: 8)
- `INVALID_TARGET` (code: 9)
- `ENTITY_NOT_FOUND` (code: 404)
- `BAD_REQUEST` (code: 400)

---

## Retry Strategies

### Exponential Backoff

**Recommended Strategy** for retryable errors:

```json
{
  "retryStrategy": {
    "type": "exponential",
    "maxRetries": 3,
    "initialDelay": 1000,
    "maxDelay": 10000,
    "backoffMultiplier": 2,
    "retryableErrors": ["1", "3", "4", "500", "timeout", "network"]
  }
}
```

**Implementation Example**:
```json
{
  "retryLogic": {
    "attempt": 1,
    "delay": 1000,
    "maxRetries": 3,
    "backoff": {
      "attempt1": 1000,
      "attempt2": 2000,
      "attempt3": 4000
    }
  }
}
```

### Fixed Delay Retry

**Alternative Strategy** for rate limiting:

```json
{
  "retryStrategy": {
    "type": "fixed",
    "maxRetries": 3,
    "delay": 5000,
    "retryableErrors": ["429"]
  }
}
```

### Rate Limit Handling

**When receiving `429 Too Many Requests`**:

```json
{
  "error": {
    "code": 429,
    "name": "RATE_LIMIT_EXCEEDED",
    "response": {
      "retry_after": 60
    },
    "handling": {
      "action": "wait",
      "waitTime": "response.retry_after",
      "retry": true
    }
  }
}
```

**Strategy**:
1. Check `Retry-After` header or `retry_after` in response
2. Wait for specified time
3. Retry request
4. If still rate limited, increase wait time

---

## Error Recovery Patterns

### Pattern 1: Resource Not Found

**Error**: `ENTITY_NOT_FOUND` (404) or `codespace structs code 1900`

**Recovery**:
```json
{
  "error": "ENTITY_NOT_FOUND",
  "recovery": {
    "step1": "Verify entity ID format",
    "step2": "Check if entity exists (list endpoint)",
    "step3": "If doesn't exist, create or use alternative",
    "step4": "If format invalid, correct and retry"
  }
}
```

**Example**:
```json
{
  "scenario": "Get player 1-999 (doesn't exist)",
  "error": {
    "code": 2,
    "message": "codespace structs code 1900: object not found"
  },
  "recovery": {
    "action": "List all players to find valid IDs",
    "fallback": "Use default player or create new"
  }
}
```

### Pattern 2: Insufficient Resources

**Error**: `INSUFFICIENT_FUNDS` (code: 2) or `INSUFFICIENT_CHARGE` (code: 7)

**Recovery**:
```json
{
  "error": "INSUFFICIENT_FUNDS",
  "recovery": {
    "step1": "Check current resources (query player/struct)",
    "step2": "Wait for resources to accumulate",
    "step3": "Monitor resource generation",
    "step4": "Retry when resources available"
  }
}
```

**Example**:
```json
{
  "scenario": "Mining requires charge but struct has insufficient charge",
  "error": {
    "code": 7,
    "name": "INSUFFICIENT_CHARGE",
    "description": "Struct has insufficient charge"
  },
  "recovery": {
    "action": "Query struct charge level",
    "wait": "Monitor charge until sufficient",
    "retry": "Retry mining when charge >= required"
  }
}
```

### Pattern 3: Player Halted

**Error**: `PLAYER_HALTED` (code: 6)

**Recovery**:
```json
{
  "error": "PLAYER_HALTED",
  "recovery": {
    "step1": "Check player status (query player)",
    "step2": "Wait for player to come online",
    "step3": "Monitor player status",
    "step4": "Retry when player online"
  }
}
```

**Example**:
```json
{
  "scenario": "Player is offline/halted",
  "error": {
    "code": 6,
    "name": "PLAYER_HALTED",
    "description": "Player is halted (offline)"
  },
  "recovery": {
    "action": "Query player status periodically",
    "wait": "Wait for player to come online",
    "retry": "Retry action when player.halted = false"
  }
}
```

### Pattern 4: Network Errors

**Error**: `NETWORK_ERROR` or `REQUEST_TIMEOUT`

**Recovery**:
```json
{
  "error": "NETWORK_ERROR",
  "recovery": {
    "step1": "Retry with exponential backoff",
    "step2": "Check network connectivity",
    "step3": "Verify endpoint availability",
    "step4": "Use alternative endpoint if available"
  }
}
```

**Example**:
```json
{
  "scenario": "Network timeout during request",
  "error": {
    "code": "timeout",
    "name": "REQUEST_TIMEOUT"
  },
  "recovery": {
    "retry": {
      "attempt1": "Wait 1 second, retry",
      "attempt2": "Wait 2 seconds, retry",
      "attempt3": "Wait 4 seconds, retry"
    },
    "fallback": "Log error and abort if all retries fail"
  }
}
```

---

## Error Handling Best Practices

### 1. Always Check for Errors

**Pattern**:
```json
{
  "responseHandling": {
    "step1": "Check HTTP status code",
    "step2": "Check response body for error fields",
    "step3": "Categorize error (retryable vs non-retryable)",
    "step4": "Apply appropriate handling strategy"
  }
}
```

### 2. Log All Errors

**Pattern**:
```json
{
  "errorLogging": {
    "include": [
      "error code",
      "error message",
      "request details (method, URL, params)",
      "response details",
      "timestamp",
      "retry attempt (if applicable)"
    ]
  }
}
```

### 3. Implement Circuit Breaker

**Pattern** for repeated failures:

```json
{
  "circuitBreaker": {
    "failureThreshold": 5,
    "timeout": 60000,
    "halfOpenRetries": 1,
    "states": ["closed", "open", "half-open"]
  }
}
```

**Strategy**:
- After 5 consecutive failures, open circuit
- Wait 60 seconds before attempting again
- Try 1 request (half-open state)
- If successful, close circuit; if failed, reopen

### 4. Provide Fallback Behavior

**Pattern**:
```json
{
  "fallback": {
    "nonRetryableError": "Use cached data or default values",
    "retryableError": "Retry with backoff",
    "criticalError": "Abort operation and notify"
  }
}
```

### 5. Validate Before Retry

**Pattern**:
```json
{
  "retryValidation": {
    "step1": "Verify error is retryable",
    "step2": "Check retry count < max retries",
    "step3": "Validate request parameters unchanged",
    "step4": "Apply backoff delay",
    "step5": "Retry request"
  }
}
```

---

## Error Code Reference

**Complete error code catalog**: See `schemas/errors.md`

**Quick Reference**:
- `0` - SUCCESS
- `1` - GENERAL_ERROR (retryable)
- `2` - INSUFFICIENT_FUNDS (not retryable)
- `3` - INVALID_SIGNATURE (retryable)
- `4` - INSUFFICIENT_GAS (retryable)
- `5` - INVALID_MESSAGE (not retryable)
- `6` - PLAYER_HALTED (not retryable)
- `7` - INSUFFICIENT_CHARGE (not retryable)
- `8` - INVALID_LOCATION (not retryable)
- `9` - INVALID_TARGET (not retryable)
- `400` - BAD_REQUEST (not retryable)
- `404` - ENTITY_NOT_FOUND (not retryable)
- `429` - RATE_LIMIT_EXCEEDED (retryable with delay)
- `500` - INTERNAL_SERVER_ERROR (retryable)
- `timeout` - REQUEST_TIMEOUT (retryable)
- `network` - NETWORK_ERROR (retryable)

---

## Examples

### Example 1: Handling Entity Not Found

```json
{
  "scenario": "Get player that doesn't exist",
  "request": {
    "method": "GET",
    "url": "/structs/player/1-999"
  },
  "response": {
    "status": 400,
    "body": {
      "code": 2,
      "message": "codespace structs code 1900: object not found"
    }
  },
  "handling": {
    "errorCode": 2,
    "category": "notRetryable",
    "action": "Verify player ID exists",
    "recovery": {
      "step1": "List all players to find valid IDs",
      "step2": "Use valid player ID or create new player"
    }
  }
}
```

### Example 2: Handling Rate Limit

```json
{
  "scenario": "Rate limit exceeded",
  "request": {
    "method": "GET",
    "url": "/structs/player"
  },
  "response": {
    "status": 429,
    "headers": {
      "Retry-After": "60"
    },
    "body": {
      "error": "Rate limit exceeded",
      "code": 429,
      "retry_after": 60
    }
  },
  "handling": {
    "errorCode": 429,
    "category": "retryable",
    "action": "Wait and retry",
    "recovery": {
      "waitTime": 60,
      "retry": true,
      "strategy": "fixed delay"
    }
  }
}
```

### Example 3: Handling Network Error with Retry

```json
{
  "scenario": "Network timeout",
  "request": {
    "method": "GET",
    "url": "/structs/player/1-1"
  },
  "error": {
    "code": "timeout",
    "name": "REQUEST_TIMEOUT"
  },
  "handling": {
    "errorCode": "timeout",
    "category": "retryable",
    "action": "Retry with exponential backoff",
    "recovery": {
      "attempt1": {
        "delay": 1000,
        "retry": true
      },
      "attempt2": {
        "delay": 2000,
        "retry": true
      },
      "attempt3": {
        "delay": 4000,
        "retry": true
      },
      "maxRetries": 3,
      "fallback": "Log error and abort if all retries fail"
    }
  }
}
```

---

## Integration with Other Protocols

### Query Protocol Integration

When querying, always check for errors:

```json
{
  "queryPattern": {
    "request": "GET /structs/player/{id}",
    "errorHandling": {
      "checkStatus": true,
      "checkBody": true,
      "categorizeError": true,
      "applyRecovery": true
    }
  }
}
```

### Action Protocol Integration

When performing actions, handle errors appropriately:

```json
{
  "actionPattern": {
    "request": "POST /cosmos/tx/v1beta1/txs",
    "errorHandling": {
      "transactionErrors": {
        "INSUFFICIENT_FUNDS": "Wait for resources",
        "INVALID_SIGNATURE": "Re-sign and retry",
        "PLAYER_HALTED": "Wait for player online"
      }
    }
  }
}
```

---

## Testing Error Handling

### Test Cases

1. **Entity Not Found**: Request non-existent entity
2. **Rate Limiting**: Make too many requests
3. **Network Errors**: Simulate network failures
4. **Invalid Requests**: Send malformed requests
5. **Resource Errors**: Attempt actions without sufficient resources

### Validation

- Verify error response format matches schema
- Verify retry logic works correctly
- Verify fallback behavior is appropriate
- Verify error logging captures all details

---

## References

- **Error Code Schema**: `schemas/errors.md`
- **Response Schema**: `schemas/responses.md`
- **Query Protocol**: `protocols/query-protocol.md`
- **Action Protocol**: `protocols/action-protocol.md`
- **API Reference**: `technical/api-reference.md#error-handling`

---

*Last Updated: January 2025*

