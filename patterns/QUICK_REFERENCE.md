# Patterns Quick Reference

**Version**: 1.0.0  
**Purpose**: Quick lookup guide for AI agents to find the right pattern

---

## When to Use Each Pattern

### Data Retrieval

**Need to fetch paginated data?**
→ Use `pagination.md`
- Key-based pagination (Consensus Network)
- Offset-based pagination (Web Application)
- Handling large datasets

**Want to cache API responses?**
→ Use `caching.md`
- TTL-based caching
- Event-based invalidation
- Reducing API calls

**Need real-time data?**
→ Use `polling-vs-streaming.md`
- Decision framework
- Polling vs streaming comparison
- Hybrid approaches

---

### Error Handling

**Getting rate limit errors (429)?**
→ Use `rate-limiting.md`
- Rate limit detection
- Throttling strategies
- Handling 429 responses

**Need to retry failed requests?**
→ Use `retry-strategies.md`
- Exponential backoff
- Circuit breakers
- Error-specific retry strategies

---

### Workflows

**Implementing multi-step operations?**
→ Use `workflow-patterns.md`
- Sequential workflows
- Parallel workflows
- State management
- Error handling in workflows

**Need workflow examples?**
→ See `examples/workflows/README.md`
- Complete workflow examples
- Categorized by use case
- Ready-to-use templates

---

### Security

**Handling credentials or authentication?**
→ Use `security.md`
- Credential management
- Session security
- Private key security
- Secure communication
- Input validation
- Secure logging

---

### Validation

**Need to verify transaction results?**
→ Use `validation-patterns.md`
- Transaction validation flow
- State verification after actions
- Requirement checking before actions
- Handling validation failures

---

### State Synchronization

**Need to sync local state with game state?**
→ Use `state-sync.md`
- Polling-based synchronization
- Event-driven synchronization
- Hybrid synchronization patterns
- State change detection

---

### Gameplay Strategies

**Implementing gameplay logic?**
→ Use `gameplay-strategies.md`
- Resource security patterns
- Power management patterns
- Build requirements patterns
- Combat preparation patterns
- Defense and expansion patterns

**Need decision trees?**
→ Use decision tree JSON files
- `decision-tree-resource-security.md`
- `decision-tree-power-management.md`
- `decision-tree-build-requirements.md`
- `decision-tree-combat.md`
- `decision-tree-5x-framework.md`
- And more...

---

## Pattern Decision Tree

```
Start
  │
  ├─ Need to fetch data?
  │   ├─ Paginated? → pagination.md
  │   ├─ Want to cache? → caching.md
  │   └─ Real-time? → polling-vs-streaming.md
  │
  ├─ Getting errors?
  │   ├─ Rate limit (429)? → rate-limiting.md
  │   └─ Other errors? → retry-strategies.md
  │
  ├─ Multi-step operation?
  │   └─ workflow-patterns.md
  │
  ├─ Need to validate transactions?
  │   └─ validation-patterns.md
  │
  ├─ Need to sync state?
  │   └─ state-sync.md
  │
  ├─ Gameplay logic?
  │   ├─ Strategies → gameplay-strategies.md
  │   └─ Decisions → decision-tree-*.md
  │
  └─ Security concerns?
      └─ security.md
```

---

## Pattern Quick Lookup

### By Problem

| Problem | Pattern | File |
|---------|--------|------|
| Rate limit errors (429) | Rate Limiting | `rate-limiting.md` |
| Too many API calls | Caching | `caching.md` |
| Need real-time data | Polling vs Streaming | `polling-vs-streaming.md` |
| Failed requests | Retry Strategies | `retry-strategies.md` |
| Multi-step operations | Workflow Patterns | `workflow-patterns.md` |
| Credential management | Security | `security.md` |
| Paginated responses | Pagination | `pagination.md` |
| Circuit breaker needed | Retry Strategies | `retry-strategies.md` |
| Parallel API calls | Workflow Patterns | `workflow-patterns.md` |
| Session expiration | Security | `security.md` |
| Transaction validation | Validation Patterns | `validation-patterns.md` |
| State synchronization | State Sync | `state-sync.md` |
| Gameplay strategies | Gameplay Strategies | `gameplay-strategies.md` |
| Decision making | Decision Trees | JSON files |

### By Use Case

| Use Case | Pattern | File |
|----------|---------|------|
| Reduce API calls | Caching | `caching.md` |
| Handle 429 errors | Rate Limiting | `rate-limiting.md` |
| Retry failed requests | Retry Strategies | `retry-strategies.md` |
| Chain API calls | Workflow Patterns | `workflow-patterns.md` |
| Choose update method | Polling vs Streaming | `polling-vs-streaming.md` |
| Secure credentials | Security | `security.md` |
| Fetch large lists | Pagination | `pagination.md` |
| Execute parallel requests | Workflow Patterns | `workflow-patterns.md` |
| Prevent cascading failures | Retry Strategies | `retry-strategies.md` |
| Validate inputs | Security | `security.md` |
| Manage workflow state | Workflow Patterns | `workflow-patterns.md` |
| Verify action results | Validation Patterns | `validation-patterns.md` |
| Sync game state | State Sync | `state-sync.md` |
| Resource management | Gameplay Strategies | `gameplay-strategies.md` |
| Make strategic decisions | Decision Trees | JSON files |

---

## Common Combinations

### High-Frequency API Usage

**Patterns**: Caching + Rate Limiting + Retry Strategies

**Use When**:
- Making many API calls
- Need to stay within rate limits
- Want to reduce redundant requests

**Implementation**:
1. Cache responses (caching.md)
2. Monitor rate limits (rate-limiting.md)
3. Retry with backoff (retry-strategies.md)

---

### Real-time monitoring

**Patterns**: Polling vs Streaming + Caching + Workflow Patterns

**Use When**:
- Need real-time updates
- Want to minimize API calls
- Coordinating multiple operations

**Implementation**:
1. Choose streaming for real-time (polling-vs-streaming.md)
2. Cache initial data (caching.md)
3. Coordinate with workflows (workflow-patterns.md)

---

### Secure Bot Operations

**Patterns**: Security + Retry Strategies + Error Handling

**Use When**:
- Handling credentials
- Need secure communication
- Handling authentication errors

**Implementation**:
1. Secure credential storage (security.md)
2. Retry auth failures (retry-strategies.md)
3. Handle auth errors gracefully

---

## Pattern Dependencies

### Caching Dependencies
- **Works with**: Rate Limiting, Polling vs Streaming
- **Complements**: Retry Strategies (cache as fallback)

### Rate Limiting Dependencies
- **Works with**: Caching, Retry Strategies
- **Complements**: Polling vs Streaming (affects polling frequency)

### Retry Strategies Dependencies
- **Works with**: Rate Limiting, Error Handling
- **Complements**: Caching (use cache on retry failure)

### Workflow Patterns Dependencies
- **Works with**: All patterns
- **Uses**: Retry Strategies, Caching, Rate Limiting
- **Complements**: Polling vs Streaming (for real-time workflows)

### Security Dependencies
- **Works with**: All patterns
- **Required for**: Authentication workflows
- **Complements**: Retry Strategies (secure retry logic)

### Polling vs Streaming Dependencies
- **Works with**: Caching, Workflow Patterns
- **Complements**: Retry Strategies (fallback to polling if streaming fails)

---

## Quick Implementation Checklist

### Setting Up a New Bot

1. **Security** (`security.md`)
   - [ ] Store credentials securely
   - [ ] Use environment variables
   - [ ] Implement secure session handling

2. **Rate Limiting** (`rate-limiting.md`)
   - [ ] Monitor rate limit headers
   - [ ] Implement throttling
   - [ ] Handle 429 errors

3. **Caching** (`caching.md`)
   - [ ] Implement response caching
   - [ ] Set appropriate TTL values
   - [ ] Invalidate cache on updates

4. **Retry Strategies** (`retry-strategies.md`)
   - [ ] Implement exponential backoff
   - [ ] Handle retryable errors
   - [ ] Set max retry limits

5. **Workflows** (`workflow-patterns.md`)
   - [ ] Identify dependencies
   - [ ] Use parallel execution when possible
   - [ ] Handle errors appropriately
   - [ ] Track workflow state

6. **Polling vs Streaming** (`polling-vs-streaming.md`)
   - [ ] Choose appropriate method
   - [ ] Implement hybrid approach if needed
   - [ ] Handle connection failures

7. **Validation Patterns** (`validation-patterns.md`)
   - [ ] Verify transaction results after submission
   - [ ] Check game state to confirm actions
   - [ ] Handle validation failures appropriately
   - [ ] Check requirements before actions

8. **State Synchronization** (`state-sync.md`)
   - [ ] Choose sync method (polling, event-driven, hybrid)
   - [ ] Implement state change detection
   - [ ] Handle state conflicts
   - [ ] Keep local state synchronized

9. **Gameplay Strategies** (`gameplay-strategies.md`)
   - [ ] Implement resource security patterns
   - [ ] Use power management patterns
   - [ ] Follow build requirements patterns
   - [ ] Apply combat preparation patterns

10. **Decision Trees** (JSON files)
    - [ ] Use appropriate decision tree for scenario
    - [ ] Follow structured decision process
    - [ ] Implement decision logic

---

## Related Documentation

- **Complete Pattern Guide**: `README.md` - Full pattern documentation index
- **Workflow Examples**: `../examples/workflows/README.md` - Workflow examples
- **Error Handling**: `../protocols/error-handling.md` - Error handling protocol
- **Authentication**: `../protocols/authentication.md` - Authentication protocol
- **API Usage Guide**: `../guides/api-usage-guide.md` - General API usage

---

*Quick Reference Version: 1.0.0 - December 7, 2025*

