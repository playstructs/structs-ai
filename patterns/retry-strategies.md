# Retry Strategies Pattern

**Version**: 1.0.0  
**Category**: API Patterns  
**Purpose**: Comprehensive guide for AI agents on implementing effective retry strategies for API requests

---

## Overview

This pattern provides detailed implementation strategies for retrying failed API requests. It complements the Error Handling Protocol by focusing specifically on retry logic, circuit breakers, and advanced retry patterns.

**Key Principles**:
1. **Retry only retryable errors** - Don't retry non-retryable errors
2. **Use exponential backoff** - Avoid overwhelming the server
3. **Implement circuit breakers** - Prevent cascading failures
4. **Set reasonable limits** - Don't retry indefinitely
5. **Log retry attempts** - Monitor and debug retry behavior

---

## Retryable vs Non-Retryable Errors

### Retryable Errors

**Always Retry**:
- `GENERAL_ERROR` (code: 1)
- `INVALID_SIGNATURE` (code: 3) - May succeed on retry
- `INSUFFICIENT_GAS` (code: 4) - May succeed if gas available
- `INTERNAL_SERVER_ERROR` (code: 500)
- `REQUEST_TIMEOUT` (timeout)
- `NETWORK_ERROR` (network)
- `RATE_LIMIT_EXCEEDED` (code: 429) - Retry after delay

### Non-Retryable Errors

**Never Retry** (will always fail):
- `INSUFFICIENT_FUNDS` (code: 2)
- `INVALID_MESSAGE` (code: 5)
- `PLAYER_HALTED` (code: 6)
- `INSUFFICIENT_CHARGE` (code: 7)
- `INVALID_LOCATION` (code: 8)
- `INVALID_TARGET` (code: 9)
- `ENTITY_NOT_FOUND` (code: 404)
- `BAD_REQUEST` (code: 400)

**Reference**: See `protocols/error-handling.md` for complete error categorization

---

## Basic Retry Strategies

### Strategy 1: Exponential Backoff

**Best For**: Most retryable errors

**Implementation**:
```json
{
  "strategy": "exponential-backoff",
  "maxRetries": 3,
  "initialDelay": 1000,
  "maxDelay": 10000,
  "backoffMultiplier": 2,
  "jitter": true
}
```

**Delay Calculation**:
```json
{
  "attempt": 1,
  "delay": 1000,
  "calculation": "initialDelay * (backoffMultiplier ^ (attempt - 1))"
}
```

**Example Delays**:
- Attempt 1: 1000ms (1 second)
- Attempt 2: 2000ms (2 seconds)
- Attempt 3: 4000ms (4 seconds)
- Attempt 4: 8000ms (8 seconds, capped at maxDelay)

**With Jitter** (randomization to prevent thundering herd):
```json
{
  "jitter": {
    "enabled": true,
    "type": "full",
    "range": "0 to calculated delay"
  }
}
```

**Code Example**:
```javascript
async function retryWithExponentialBackoff(fn, maxRetries = 3) {
  let attempt = 0;
  let delay = 1000;
  
  while (attempt < maxRetries) {
    try {
      return await fn();
    } catch (error) {
      if (!isRetryableError(error)) {
        throw error; // Don't retry non-retryable errors
      }
      
      attempt++;
      if (attempt >= maxRetries) {
        throw error; // Max retries reached
      }
      
      // Calculate delay with jitter
      const jitter = Math.random() * delay;
      await sleep(delay + jitter);
      
      // Exponential backoff
      delay = Math.min(delay * 2, 10000); // Cap at 10 seconds
    }
  }
}
```

### Strategy 2: Fixed Delay Retry

**Best For**: Rate limiting (429 errors)

**Implementation**:
```json
{
  "strategy": "fixed-delay",
  "maxRetries": 3,
  "delay": 5000,
  "useWhen": "rate-limit-errors"
}
```

**Example**:
```json
{
  "rateLimitRetry": {
    "error": 429,
    "delay": 5000,
    "reason": "Wait for rate limit window to reset",
    "maxRetries": 3
  }
}
```

**Code Example**:
```javascript
async function retryWithFixedDelay(fn, delay = 5000, maxRetries = 3) {
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      return await fn();
    } catch (error) {
      if (error.status === 429) {
        attempt++;
        if (attempt >= maxRetries) {
          throw error;
        }
        await sleep(delay); // Fixed delay for rate limits
      } else {
        throw error; // Don't retry non-rate-limit errors
      }
    }
  }
}
```

### Strategy 3: Linear Backoff

**Best For**: Predictable retry scenarios

**Implementation**:
```json
{
  "strategy": "linear-backoff",
  "maxRetries": 5,
  "initialDelay": 1000,
  "increment": 1000,
  "maxDelay": 5000
}
```

**Delay Calculation**:
```json
{
  "attempt": 1,
  "delay": 1000,
  "calculation": "initialDelay + (increment * (attempt - 1))"
}
```

**Example Delays**:
- Attempt 1: 1000ms
- Attempt 2: 2000ms
- Attempt 3: 3000ms
- Attempt 4: 4000ms
- Attempt 5: 5000ms

---

## Advanced Retry Patterns

### Pattern 1: Circuit Breaker

**Purpose**: Prevent cascading failures by stopping retries after repeated failures

**States**:
- **Closed**: Normal operation, requests pass through
- **Open**: Circuit is open, requests fail immediately
- **Half-Open**: Testing if service recovered

**Implementation**:
```json
{
  "circuitBreaker": {
    "failureThreshold": 5,
    "successThreshold": 2,
    "timeout": 60000,
    "halfOpenRetries": 1,
    "states": ["closed", "open", "half-open"]
  }
}
```

**State Transitions**:
```json
{
  "transitions": {
    "closed-to-open": "After 5 consecutive failures",
    "open-to-half-open": "After timeout (60 seconds)",
    "half-open-to-closed": "After 2 successful requests",
    "half-open-to-open": "After 1 failure"
  }
}
```

**Code Example**:
```javascript
class CircuitBreaker {
  constructor(options = {}) {
    this.failureThreshold = options.failureThreshold || 5;
    this.successThreshold = options.successThreshold || 2;
    this.timeout = options.timeout || 60000;
    this.state = 'closed';
    this.failureCount = 0;
    this.successCount = 0;
    this.nextAttempt = Date.now();
  }
  
  async execute(fn) {
    if (this.state === 'open') {
      if (Date.now() < this.nextAttempt) {
        throw new Error('Circuit breaker is open');
      }
      this.state = 'half-open';
      this.successCount = 0;
    }
    
    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }
  
  onSuccess() {
    this.failureCount = 0;
    
    if (this.state === 'half-open') {
      this.successCount++;
      if (this.successCount >= this.successThreshold) {
        this.state = 'closed';
      }
    }
  }
  
  onFailure() {
    this.failureCount++;
    
    if (this.state === 'half-open') {
      this.state = 'open';
      this.nextAttempt = Date.now() + this.timeout;
    } else if (this.failureCount >= this.failureThreshold) {
      this.state = 'open';
      this.nextAttempt = Date.now() + this.timeout;
    }
  }
}
```

### Pattern 2: Retry with Validation

**Purpose**: Validate conditions before retrying

**Implementation**:
```json
{
  "retryWithValidation": {
    "validateBeforeRetry": true,
    "validations": [
      "Check if error is retryable",
      "Verify retry count < max retries",
      "Validate request parameters unchanged",
      "Check if conditions changed (e.g., player online)"
    ]
  }
}
```

**Example**:
```json
{
  "scenario": "Retry mining after insufficient charge",
  "validation": {
    "beforeRetry": [
      "Query player charge level",
      "Verify charge >= required amount",
      "Check player is not halted"
    ],
    "retryIf": "charge >= required AND player.halted === false"
  }
}
```

**Code Example**:
```javascript
async function retryWithValidation(fn, validator, maxRetries = 3) {
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      return await fn();
    } catch (error) {
      if (!isRetryableError(error)) {
        throw error;
      }
      
      // Validate before retrying
      const canRetry = await validator(error, attempt);
      if (!canRetry) {
        throw error;
      }
      
      attempt++;
      if (attempt >= maxRetries) {
        throw error;
      }
      
      await sleep(calculateDelay(attempt));
    }
  }
}
```

### Pattern 3: Retry with Context

**Purpose**: Pass context between retry attempts

**Implementation**:
```json
{
  "retryWithContext": {
    "context": {
      "requestId": "unique-request-id",
      "attempt": 1,
      "previousErrors": [],
      "metadata": {}
    },
    "updateContext": "On each retry attempt"
  }
}
```

**Use Cases**:
- Track retry history
- Pass state between attempts
- Log retry attempts with context
- Adjust strategy based on context

### Pattern 4: Adaptive Retry

**Purpose**: Adjust retry strategy based on error patterns

**Implementation**:
```json
{
  "adaptiveRetry": {
    "strategy": "adaptive",
    "adjustments": {
      "ifManyTimeouts": "Increase initial delay",
      "ifManyRateLimits": "Use fixed delay",
      "ifManyServerErrors": "Use exponential backoff",
      "ifManyNetworkErrors": "Increase max retries"
    }
  }
}
```

**Example**:
```json
{
  "adaptiveStrategy": {
    "timeoutErrors": {
      "count": 5,
      "action": "Increase initial delay to 2000ms"
    },
    "rateLimitErrors": {
      "count": 3,
      "action": "Switch to fixed delay strategy"
    }
  }
}
```

---

## Error-Specific Retry Strategies

### Rate Limit Errors (429)

**Strategy**: Fixed delay based on rate limit headers

**Implementation**:
```json
{
  "rateLimitRetry": {
    "error": 429,
    "strategy": "fixed-delay",
    "delaySource": "Retry-After header or default 5000ms",
    "maxRetries": 3
  }
}
```

**Code Example**:
```javascript
async function handleRateLimit(error, fn) {
  const retryAfter = error.headers['retry-after'] || 5;
  const delay = parseInt(retryAfter) * 1000;
  
  await sleep(delay);
  return await fn();
}
```

### Timeout Errors

**Strategy**: Exponential backoff with longer initial delay

**Implementation**:
```json
{
  "timeoutRetry": {
    "error": "timeout",
    "strategy": "exponential-backoff",
    "initialDelay": 2000,
    "maxDelay": 30000,
    "maxRetries": 5
  }
}
```

### Network Errors

**Strategy**: Exponential backoff with connection check

**Implementation**:
```json
{
  "networkErrorRetry": {
    "error": "network",
    "strategy": "exponential-backoff",
    "validateConnection": true,
    "maxRetries": 5
  }
}
```

### Server Errors (500)

**Strategy**: Exponential backoff with circuit breaker

**Implementation**:
```json
{
  "serverErrorRetry": {
    "error": 500,
    "strategy": "exponential-backoff",
    "circuitBreaker": true,
    "maxRetries": 3
  }
}
```

---

## Retry Configuration

### Recommended Configurations

**Default Configuration**:
```json
{
  "default": {
    "maxRetries": 3,
    "strategy": "exponential-backoff",
    "initialDelay": 1000,
    "maxDelay": 10000,
    "backoffMultiplier": 2,
    "jitter": true
  }
}
```

**Rate Limit Configuration**:
```json
{
  "rateLimit": {
    "maxRetries": 3,
    "strategy": "fixed-delay",
    "delay": 5000,
    "useRetryAfterHeader": true
  }
}
```

**Network Error Configuration**:
```json
{
  "networkError": {
    "maxRetries": 5,
    "strategy": "exponential-backoff",
    "initialDelay": 2000,
    "maxDelay": 30000
  }
}
```

**Timeout Configuration**:
```json
{
  "timeout": {
    "maxRetries": 5,
    "strategy": "exponential-backoff",
    "initialDelay": 2000,
    "maxDelay": 30000
  }
}
```

---

## Best Practices

### 1. Set Reasonable Limits

**Do**:
- Set max retries (typically 3-5)
- Set max delay (typically 10-30 seconds)
- Use jitter to prevent thundering herd

**Don't**:
- Retry indefinitely
- Use very long delays
- Retry without limits

### 2. Log Retry Attempts

**Do**:
```json
{
  "logging": {
    "include": [
      "error code and message",
      "retry attempt number",
      "delay used",
      "request details",
      "timestamp"
    ]
  }
}
```

**Benefits**:
- Debug retry behavior
- Monitor retry patterns
- Identify problematic endpoints

### 3. Use Circuit Breakers for Repeated Failures

**Do**:
- Implement circuit breakers
- Open circuit after threshold failures
- Test recovery with half-open state

**Benefits**:
- Prevent cascading failures
- Reduce server load
- Faster failure detection

### 4. Validate Before Retrying

**Do**:
- Check if error is retryable
- Verify conditions changed (if applicable)
- Validate request parameters

**Example**:
```json
{
  "validation": {
    "beforeRetry": [
      "Is error retryable?",
      "Has player come online?",
      "Is charge sufficient?",
      "Are parameters still valid?"
    ]
  }
}
```

### 5. Combine with Caching

**Do**:
- Cache successful responses
- Use cached data on retry failures
- Invalidate cache on successful retry

**Benefits**:
- Faster fallback
- Reduced API calls
- Better user experience

---

## Integration with Other Patterns

### Retry + Rate Limiting

**Pattern**: Combine retry with rate limit handling

```json
{
  "integration": {
    "retry": "Exponential backoff",
    "rateLimit": "Respect rate limit headers",
    "strategy": "Retry after rate limit window"
  }
}
```

**Reference**: `patterns/rate-limiting.md`

### Retry + Caching

**Pattern**: Use cache as fallback during retries

```json
{
  "integration": {
    "retry": "Exponential backoff",
    "cache": "Use cached data if retry fails",
    "strategy": "Retry → Cache → Error"
  }
}
```

**Reference**: `patterns/caching.md`

### Retry + Circuit Breaker

**Pattern**: Use circuit breaker to prevent excessive retries

```json
{
  "integration": {
    "retry": "Exponential backoff",
    "circuitBreaker": "Open after threshold failures",
    "strategy": "Retry → Circuit Breaker → Fail Fast"
  }
}
```

---

## Monitoring and Metrics

### Metrics to Track

**Retry Metrics**:
```json
{
  "metrics": {
    "retryCount": "Number of retries attempted",
    "retrySuccessRate": "Percentage of successful retries",
    "averageRetries": "Average retries per request",
    "retryDelay": "Average delay between retries",
    "circuitBreakerState": "Current circuit breaker state"
  }
}
```

### Monitoring Dashboard

**Key Indicators**:
- Retry rate (retries / total requests)
- Success rate after retry
- Average retry delay
- Circuit breaker state changes
- Error distribution by type

---

## Related Documentation

- **Error Handling Protocol**: `protocols/error-handling.md` - Complete error handling guide
- **Rate Limiting**: `patterns/rate-limiting.md` - Rate limit handling
- **Caching**: `patterns/caching.md` - Caching strategies
- **Error Codes**: `api/error-codes.md` - Complete error code catalog

---

## Quick Reference

### Retryable Errors
- `GENERAL_ERROR` (1)
- `INVALID_SIGNATURE` (3)
- `INSUFFICIENT_GAS` (4)
- `INTERNAL_SERVER_ERROR` (500)
- `REQUEST_TIMEOUT`
- `NETWORK_ERROR`
- `RATE_LIMIT_EXCEEDED` (429)

### Recommended Strategies
- **Most errors**: Exponential backoff (3 retries, 1s initial delay)
- **Rate limits**: Fixed delay (5s, use Retry-After header)
- **Timeouts**: Exponential backoff (5 retries, 2s initial delay)
- **Network errors**: Exponential backoff (5 retries, 2s initial delay)

### Best Practices
1. Set reasonable limits (3-5 retries)
2. Use exponential backoff with jitter
3. Implement circuit breakers
4. Log retry attempts
5. Validate before retrying

---

*Pattern Version: 1.0.0 - January 2025*

