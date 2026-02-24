# Performance Optimization

**Version**: 1.0.0  
**Category**: Patterns  
**Status**: Stable  
**Last Updated**: January 1, 2026

## Overview

This guide provides performance optimization tips for AI agents working with Structs. It covers optimization strategies for reactor staking queries, permission checking, database queries, and caching strategies.

---

## Reactor Staking Query Optimization

### Optimization 1: Batch Reactor Queries

**Problem**: Querying each reactor individually is slow

**Solution**: Query all player reactors at once

**Before**:
```json
{
  "approach": "Sequential queries",
  "queries": [
    "GET /structs/reactor/3-1",
    "GET /structs/reactor/3-2",
    "GET /structs/reactor/3-3"
  ],
  "time": "3 × query_time"
}
```

**After**:
```json
{
  "approach": "Batch query",
  "query": "GET /structs/reactor?ownerId=1-11",
  "time": "1 × query_time",
  "improvement": "3x faster"
}
```

**Reference**: `api/queries/reactor.md`, `patterns/caching.md`

---

### Optimization 2: Cache Reactor Staking Status

**Problem**: Reactor staking status changes infrequently

**Solution**: Cache reactor staking status with appropriate TTL

**Strategy**:
- **Cache TTL**: 5 minutes (staking status changes slowly)
- **Invalidate on**: Infuse, defuse, migration, cancel defusion actions
- **Cache Key**: `reactor:{reactorId}:staking`

**Implementation**:
```json
{
  "cache": {
    "key": "reactor:3-1:staking",
    "ttl": 300,
    "invalidateOn": [
      "reactor-infuse",
      "reactor-defuse",
      "reactor-begin-migration",
      "reactor-cancel-defusion"
    ]
  }
}
```

**Reference**: `patterns/caching.md`, `schemas/entities/reactor.md`

---

### Optimization 3: Parallel Reactor Status Checks

**Problem**: Checking multiple reactors sequentially is slow

**Solution**: Check reactor statuses in parallel

**Before**:
```json
{
  "approach": "Sequential",
  "time": "n × query_time",
  "reactors": ["3-1", "3-2", "3-3"]
}
```

**After**:
```json
{
  "approach": "Parallel",
  "time": "1 × query_time",
  "reactors": ["3-1", "3-2", "3-3"],
  "improvement": "n× faster"
}
```

**Reference**: `patterns/workflow-patterns.md#/parallel-patterns`

---

## Permission Checking Optimization

### Optimization 4: Cache Permission Values

**Problem**: Permission checks require API queries

**Solution**: Cache permission values with appropriate TTL

**Strategy**:
- **Cache TTL**: 5 minutes (permissions change infrequently)
- **Invalidate on**: Permission grant/revoke actions
- **Cache Key**: `permission:{permissionId}`

**Implementation**:
```json
{
  "cache": {
    "key": "permission:0-1@1-11",
    "ttl": 300,
    "invalidateOn": [
      "permission-grant",
      "permission-revoke"
    ]
  }
}
```

**Reference**: `patterns/caching.md`, `api/queries/permission.md`

---

### Optimization 5: Batch Permission Queries

**Problem**: Checking multiple permissions sequentially is slow

**Solution**: Query permissions by object or player

**Before**:
```json
{
  "approach": "Individual queries",
  "queries": [
    "GET /structs/permission/0-1@1-11",
    "GET /structs/permission/0-1@1-12",
    "GET /structs/permission/0-1@1-13"
  ]
}
```

**After**:
```json
{
  "approach": "Batch query",
  "query": "GET /structs/permission/object/0-1",
  "filters": ["1-11", "1-12", "1-13"],
  "improvement": "Single query for all permissions"
}
```

**Reference**: `api/queries/permission.md`, `patterns/caching.md`

---

### Optimization 6: Bitwise Permission Checks

**Problem**: String conversion and parsing is slow

**Solution**: Use bitwise operations directly

**Before**:
```json
{
  "approach": "String parsing",
  "steps": [
    "Parse permission.value to integer",
    "Check bit 64",
    "Return result"
  ]
}
```

**After**:
```json
{
  "approach": "Bitwise operations",
  "check": "(permissionValue & 64) == 64",
  "improvement": "Direct bitwise check, no parsing"
}
```

**Reference**: `schemas/game-state.md#/definitions/Permission`

---

## Database Query Optimization

### Optimization 7: Filter Destroyed Structs

**Problem**: Queries return destroyed structs unnecessarily

**Solution**: Always filter by `destroyed = false`

**Before**:
```sql
SELECT * FROM struct WHERE owner_id = '1-11';
-- Returns destroyed structs too
```

**After**:
```sql
SELECT * FROM struct 
WHERE owner_id = '1-11' 
AND destroyed = false;
-- Only active structs
```

**Reference**: `schemas/database-schema.md#/tables/struct`, `troubleshooting/edge-cases.md`

---

### Optimization 8: Index Permission Hash Queries

**Problem**: Permission hash queries are slow

**Solution**: Use indexed queries for permission_hash

**Strategy**:
- Use `permission_hash` level in database queries
- Query by permission_hash index if available
- Combine with object_id for faster lookups

**Implementation**:
```sql
SELECT * FROM view.permission 
WHERE permission_hash = true 
AND object_id = '0-1';
-- Uses permission_hash index
```

**Reference**: `schemas/database-schema.md`, `api/queries/permission.md`

---

### Optimization 9: Cache Database Query Results

**Problem**: Database queries are expensive

**Solution**: Cache database query results

**Strategy**:
- **Cache TTL**: 30 seconds (database changes frequently)
- **Invalidate on**: Related actions
- **Cache Key**: `db:{table}:{query_hash}`

**Implementation**:
```json
{
  "cache": {
    "key": "db:struct:owner_1-11",
    "ttl": 30,
    "invalidateOn": [
      "struct-build-initiate",
      "struct-build-complete",
      "struct-destroy"
    ]
  }
}
```

**Reference**: `patterns/caching.md`, `schemas/database-schema.md`

---

## Caching Strategies for New Features

### Optimization 10: Cache Struct Type Cheatsheet Details

**Problem**: Struct type queries are frequent but data changes rarely

**Solution**: Cache struct type data with long TTL

**Strategy**:
- **Cache TTL**: 1 hour (struct types change rarely)
- **Cache Key**: `struct-type:{typeId}`
- **Invalidate**: Never (or on explicit update)

**Implementation**:
```json
{
  "cache": {
    "key": "struct-type:14",
    "ttl": 3600,
    "data": {
      "cheatsheet_details": "...",
      "cheatsheet_extended_details": "..."
    }
  }
}
```

**Reference**: `schemas/database-schema.md#/tables/struct_type`, `patterns/caching.md`

---

### Optimization 11: Cache Permission Hash Status

**Problem**: Permission hash checks require database queries

**Solution**: Cache permission hash status

**Strategy**:
- **Cache TTL**: 5 minutes
- **Cache Key**: `permission-hash:{objectId}@{playerId}`
- **Invalidate on**: Permission changes

**Implementation**:
```json
{
  "cache": {
    "key": "permission-hash:0-1@1-11",
    "ttl": 300,
    "value": true,
    "invalidateOn": ["permission-grant", "permission-revoke"]
  }
}
```

**Reference**: `schemas/database-schema.md`, `patterns/caching.md`

---

### Optimization 12: Cache Destroyed Struct Status

**Problem**: Checking if struct is destroyed requires queries

**Solution**: Cache destroyed status with short TTL

**Strategy**:
- **Cache TTL**: 10 seconds (destroyed status changes during delay)
- **Cache Key**: `struct:{structId}:destroyed`
- **Account for**: StructSweepDelay (5 blocks)

**Implementation**:
```json
{
  "cache": {
    "key": "struct:5-1:destroyed",
    "ttl": 10,
    "value": false,
    "note": "Account for StructSweepDelay (5 blocks)"
  }
}
```

**Reference**: `lifecycles/struct-lifecycle.md#/structsweepdelay`, `patterns/caching.md`

---

## General Optimization Tips

### Optimization 13: Use Parallel Requests

**Problem**: Sequential requests are slow

**Solution**: Execute independent requests in parallel

**Strategy**:
- Identify independent requests
- Execute in parallel using Promise.all() or equivalent
- Batch similar operations together

**Reference**: `patterns/workflow-patterns.md#/parallel-patterns`

---

### Optimization 14: Use Streaming for Real-time Data

**Problem**: Polling for real-time data is inefficient

**Solution**: Use streaming API for frequently-changing data

**Strategy**:
- Use streaming for: Planet shield health, fleet movement, resource amounts
- Use polling for: Static data, infrequent changes
- Choose based on update frequency

**Reference**: `patterns/polling-vs-streaming.md`

---

### Optimization 15: Monitor Rate Limits

**Problem**: Exceeding rate limits causes failures

**Solution**: Monitor rate limit usage and throttle requests

**Strategy**:
- Track rate limit headers
- Throttle requests to stay within limits
- Use caching to reduce API calls
- Implement backoff on rate limit errors

**Reference**: `patterns/rate-limiting.md`

---

## Performance Metrics

### Key Metrics to Monitor

- **API Call Count**: Track number of API calls per operation
- **Cache Hit Rate**: Monitor cache effectiveness
- **Query Time**: Track database query performance
- **Rate Limit Usage**: Monitor rate limit consumption
- **Parallel Efficiency**: Measure parallel request improvements

---

## Best Practices

### 1. Cache Aggressively

Cache static and slowly-changing data with appropriate TTLs.

### 2. Use Parallel Requests

Execute independent requests in parallel when possible.

### 3. Filter Queries

Always filter queries to return only needed data.

### 4. Monitor Performance

Track performance metrics to identify bottlenecks.

### 5. Use Streaming

Use streaming API for real-time data instead of polling.

### 6. Batch Operations

Batch similar operations together when possible.

### 7. Optimize Bitwise Operations

Use bitwise operations directly for permission checks.

---

## Related Documentation

- **Caching**: `caching.md` - Caching strategies
- **Rate Limiting**: `rate-limiting.md` - Rate limit handling
- **Workflow Patterns**: `workflow-patterns.md` - Parallel patterns
- **Polling vs Streaming**: `polling-vs-streaming.md` - Data update strategies
- **Reactor Staking**: `../troubleshooting/reactor-staking-issues.md` - Reactor staking troubleshooting

---

*Last Updated: January 1, 2026*

