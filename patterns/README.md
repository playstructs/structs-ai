# API Patterns

**Purpose**: Common patterns and best practices for AI agents interacting with Structs APIs

---

## Overview

This directory contains pattern documentation for common API interaction scenarios. Patterns provide reusable solutions to common problems and help AI agents implement correct API usage.

---

## Patterns

### `pagination.md`
Complete guide to handling paginated API responses.

**Covers**:
- Key-based pagination (Consensus Network)
- Offset-based pagination (Web Application)
- Pagination strategies
- Edge case handling
- Best practices

**Use When**:
- Fetching lists of entities
- Handling large datasets
- Implementing incremental loading

### `rate-limiting.md`
Complete guide to handling API rate limits effectively.

**Covers**:
- Rate limit detection (headers, status codes)
- Rate limiting strategies (throttling, backoff, queuing)
- Default rate limits per API
- Error handling for 429 responses
- Best practices and monitoring

**Use When**:
- Making frequent API requests
- Handling 429 rate limit errors
- Implementing request throttling
- Monitoring API usage

### `caching.md`
Complete guide to implementing effective response caching strategies.

**Covers**:
- Cache strategies (TTL, event-based, version-based, hybrid)
- Cache key patterns
- Cache invalidation patterns
- Recommended TTL values by data type
- Implementation examples
- Best practices and monitoring

**Use When**:
- Reducing API calls
- Improving performance
- Staying within rate limits
- Handling frequently accessed data
- Implementing offline capability

### `polling-vs-streaming.md`
Complete guide to choosing between polling and streaming for real-time data.

**Covers**:
- Decision framework (when to use each)
- Comparison matrix
- Polling patterns (fixed, adaptive, event-triggered)
- Streaming patterns (single, wildcard, multi-subject)
- Hybrid patterns (initial load + streaming, fallback)
- Performance considerations
- Cost analysis
- Decision tree

**Use When**:
- Deciding how to access real-time data
- Optimizing API usage
- Balancing latency and resource usage
- Implementing update mechanisms

### `retry-strategies.md`
Comprehensive guide to implementing effective retry strategies for API requests.

**Covers**:
- Retryable vs non-retryable errors
- Basic retry strategies (exponential backoff, fixed delay, linear)
- Advanced patterns (circuit breaker, retry with validation, adaptive retry)
- Error-specific retry strategies
- Retry configuration recommendations
- Best practices and monitoring
- Integration with other patterns

**Use When**:
- Implementing retry logic for failed requests
- Handling transient errors
- Preventing cascading failures
- Optimizing retry behavior

### `workflow-patterns.md`
Complete guide to implementing multi-step API workflows and parallel request patterns.

**Covers**:
- Sequential workflow patterns (linear chain, conditional chain, retry chain)
- Parallel workflow patterns (independent parallel, parallel with dependency, batch parallel)
- State management patterns (workflow state, checkpoint pattern)
- Error handling in workflows (fail fast, continue on error, retry with fallback)
- Workflow examples
- Best practices
- Integration with other patterns

**Use When**:
- Implementing multi-step operations
- Coordinating multiple API calls
- Managing dependencies between operations
- Executing parallel requests
- Handling workflow state

### `security.md`
Security best practices and patterns for AI agents.

**Covers**:
- Credential management (environment variables, secure storage, rotation)
- Session security (secure storage, expiration handling, validation)
- Private key security (never log, secure loading, key derivation)
- Input validation and sanitization
- Secure communication (HTTPS/WSS, certificate validation)
- Error handling security (sanitize errors, secure logging)
- Authentication security
- Monitoring and detection

**Use When**:
- Handling credentials and secrets
- Managing authentication and sessions
- Implementing secure communication
- Validating and sanitizing inputs
- Logging and error handling
- Monitoring security events

### `validation-patterns.md`
Complete guide to transaction validation and verification patterns.

**Covers**:
- Transaction validation flow (pending → broadcast → validation)
- Verification patterns (checking actual game state)
- Common validation failures and how to handle them
- Requirement checking before actions
- State verification after actions

**Use When**:
- Submitting transactions
- Verifying action results
- Handling validation failures
- Checking requirements before actions
- Debugging failed actions

### `state-sync.md`
Complete guide to synchronizing AI agent state with game state.

**Covers**:
- Polling-based synchronization
- Event-driven synchronization
- Hybrid synchronization patterns
- State change detection
- Conflict resolution

**Use When**:
- Keeping local state synchronized
- Detecting game state changes
- Implementing real-time updates
- Managing state consistency
- Handling state conflicts

### `gameplay-strategies.md`
Gameplay strategy patterns for AI agents.

**Covers**:
- Resource security patterns
- Power management patterns
- Build requirements patterns
- Combat preparation patterns
- Defense patterns
- Expansion patterns
- 5X Framework patterns

**Use When**:
- Implementing gameplay logic
- Optimizing resource management
- Planning combat strategies
- Managing expansion
- Following proven gameplay patterns

### `performance-optimization.md`
Performance optimization tips for AI agents.

**Covers**:
- Reactor staking query optimization
- Permission checking optimization
- Database query optimization
- Caching strategies for new features
- Parallel request patterns
- General optimization tips

**Use When**:
- Optimizing API call performance
- Reducing query times
- Improving cache effectiveness
- Optimizing permission checks
- Improving database query performance

### Decision Trees

Structured JSON decision trees for common gameplay scenarios:

- **`decision-tree-resource-security.md`** - Resource security decision tree
- **`decision-tree-power-management.md`** - Power management decision tree
- **`decision-tree-build-requirements.md`** - Build requirements decision tree
- **`decision-tree-combat.md`** - Combat decision tree
- **`decision-tree-5x-framework.md`** - 5X Framework decision tree
- **`decision-tree-resource-allocation.md`** - Resource allocation decision tree
- **`decision-tree-reactor-vs-generator.md`** - Reactor vs Generator decision tree
- **`decision-tree-trading.md`** - Trading decision tree

**Use When**:
- Implementing decision logic
- Following structured decision processes
- Creating gameplay workflows
- Making strategic choices

---

## Pattern Categories

### Data Retrieval Patterns
- **Pagination**: Handling paginated responses (`pagination.md`)
- **Filtering**: Querying with filters
- **Caching**: Response caching strategies (`caching.md`)

### Error Handling Patterns
- **Retry Logic**: Exponential backoff (`retry-strategies.md`)
- **Circuit Breaker**: Handling repeated failures (`retry-strategies.md`)
- **Fallback**: Providing fallback behavior

### Authentication Patterns
- **Session Management**: Webapp session handling (`security.md`)
- **Transaction Signing**: Consensus network signing (`security.md`)
- **Token Refresh**: Token renewal strategies (`security.md`)
- **Security Best Practices**: Credential management, secure storage (`security.md`)

### Workflow Patterns
- **Multi-Step Operations**: Chaining API calls (`workflow-patterns.md`)
- **Parallel Requests**: Concurrent API calls (`workflow-patterns.md`)
- **State Management**: Tracking operation state (`workflow-patterns.md`)

### Validation Patterns
- **Transaction Validation**: Verifying action results (`validation-patterns.md`)
- **State Verification**: Checking game state after actions (`validation-patterns.md`)
- **Requirement Checking**: Validating requirements before actions (`validation-patterns.md`)

### State Synchronization Patterns
- **Polling-Based Sync**: Periodic state updates (`state-sync.md`)
- **Event-Driven Sync**: Real-time state updates (`state-sync.md`)
- **Hybrid Sync**: Combined polling and event-driven (`state-sync.md`)

### Gameplay Patterns
- **Strategy Patterns**: Proven gameplay strategies (`gameplay-strategies.md`)
- **Decision Trees**: Structured decision-making (JSON files)
- **Resource Management**: Resource optimization patterns (`gameplay-strategies.md`)
- **Combat Patterns**: Combat preparation and execution (`gameplay-strategies.md`)

---

## Using Patterns

### 1. Identify Your Use Case

Determine which pattern applies to your scenario:
- Fetching lists? → Use **Pagination** pattern
- Handling errors? → Use **Error Handling** patterns
- Authenticating? → Use **Authentication** patterns
- Complex workflows? → Use **Workflow** patterns
- Validating transactions? → Use **Validation** patterns
- Syncing state? → Use **State Sync** patterns
- Gameplay strategies? → Use **Gameplay Strategies** patterns
- Making decisions? → Use **Decision Trees** (JSON files)

### 2. Review Pattern Documentation

Read the relevant pattern file for:
- Pattern description
- Implementation examples
- Best practices
- Edge cases

### 3. Adapt to Your Needs

Customize the pattern for your specific requirements:
- Adjust parameters
- Add validation
- Implement error handling
- Add logging

### 4. Test Your Implementation

Verify your implementation:
- Test with real API
- Handle edge cases
- Monitor performance
- Check error handling

---

## Pattern Examples

### Pagination Pattern

```json
{
  "pattern": "pagination",
  "implementation": {
    "fetchAll": true,
    "pageSize": 100,
    "strategy": "key-based"
  }
}
```

### Error Handling Pattern

```json
{
  "pattern": "error-handling",
  "implementation": {
    "retryStrategy": "exponential-backoff",
    "maxRetries": 3,
    "handleRateLimits": true
  }
}
```

---

## Contributing Patterns

When adding new patterns:

1. **Create pattern file** in this directory
2. **Follow naming convention**: `{pattern-name}.md`
3. **Include sections**:
   - Overview
   - Use cases
   - Implementation
   - Examples
   - Best practices
   - Related documentation
4. **Update this README** with pattern description

---

## Quick Reference

For a quick lookup guide to find the right pattern, see:
- **`QUICK_REFERENCE.md`** - Quick pattern lookup by problem or use case

---

## Related Documentation

- **Protocols**: `../protocols/` - API protocols
- **Schemas**: `../schemas/` - Data schemas
- **Examples**: `../examples/` - Code examples
- **API Reference**: `../api/` - API documentation

---

*API Documentation Specialist - January 1, 2026*

