# Caching Pattern

**Version**: 1.0.0  
**Category**: API Patterns  
**Purpose**: Guide for AI agents on implementing effective response caching strategies

---

## Overview

Caching API responses reduces server load, improves performance, and helps stay within rate limits. This pattern explains when and how to cache API responses effectively while maintaining data freshness.

---

## Caching Basics

### What Is Caching?

Caching stores API responses locally to avoid redundant requests:
- **Reduces API calls**: Reuse previous responses
- **Improves performance**: Faster response times
- **Saves rate limit quota**: Fewer requests = more quota available
- **Offline capability**: Access cached data when offline

### When to Cache

**Good Candidates for Caching**:
- Static or slowly-changing data
- Frequently accessed endpoints
- Expensive queries
- Rate-limited endpoints
- Data that doesn't require real-time accuracy

**Don't Cache**:
- Real-time data (use streaming instead)
- Transaction results
- Authentication tokens (unless appropriate)
- Data that changes frequently
- User-specific sensitive data

---

## Cache Strategies

### Strategy 1: Time-Based Caching (TTL)

**Approach**: Cache responses for a fixed time period

**Implementation**:
```json
{
  "strategy": "time-based-ttl",
  "cache": {
    "ttl": 300,
    "unit": "seconds",
    "key": "player-{id}",
    "invalidate": "after-ttl"
  }
}
```

**Example TTL Values**:
- **Static data** (struct types): 3600 seconds (1 hour)
- **Slowly-changing** (player info): 300 seconds (5 minutes)
- **Moderately-changing** (guild info): 60 seconds (1 minute)
- **Frequently-changing** (planet shield): 10 seconds

**Use When**:
- Data changes predictably
- Acceptable to show slightly stale data
- Simple implementation needed

### Strategy 2: Event-Based Invalidation

**Approach**: Invalidate cache when related events occur

**Implementation**:
```json
{
  "strategy": "event-based-invalidation",
  "cache": {
    "key": "player-{id}",
    "invalidateOn": [
      "structs.player.{id}",
      "structs.planet.{id}",
      "structs.guild.{id}"
    ]
  }
}
```

**Example**:
- Cache player data
- Listen to `structs.player.{id}` events via GRASS/NATS
- Invalidate cache when player update event received
- Fetch fresh data on next request

**Use When**:
- Using GRASS/NATS streaming
- Need near-real-time accuracy
- Want to minimize API calls

### Strategy 3: Version-Based Caching

**Approach**: Cache based on data version/ETag

**Implementation**:
```json
{
  "strategy": "version-based",
  "cache": {
    "key": "player-{id}",
    "version": "response.headers.ETag",
    "check": "If-None-Match header",
    "invalidate": "when-version-changes"
  }
}
```

**Use When**:
- API supports ETag headers
- Need to minimize bandwidth
- Want conditional requests

### Strategy 4: Hybrid Caching

**Approach**: Combine multiple strategies

**Implementation**:
```json
{
  "strategy": "hybrid",
  "cache": {
    "ttl": 300,
    "eventInvalidation": true,
    "versionCheck": true,
    "fallback": "ttl"
  }
}
```

**Use When**:
- Need flexibility
- Multiple data sources
- Complex requirements

---

## Cache Key Patterns

### Entity-Based Keys

**Pattern**: `{entity}-{id}`

**Examples**:
```json
{
  "keys": {
    "player": "player-{id}",
    "planet": "planet-{id}",
    "guild": "guild-{id}",
    "struct": "struct-{id}"
  }
}
```

### Query-Based Keys

**Pattern**: `{endpoint}-{params}`

**Examples**:
```json
{
  "keys": {
    "playerPlanets": "player-{id}-planets",
    "guildMembers": "guild-{id}-members",
    "planetStructs": "planet-{id}-structs"
  }
}
```

### Composite Keys

**Pattern**: `{entity}-{id}-{language}-{guildId}`

**Examples**:
```json
{
  "keys": {
    "structTypeWithCosmetics": "struct-type-{id}-{language}-{guildId}",
    "playerWithGuild": "player-{id}-guild-{guildId}"
  }
}
```

---

## Cache Implementation Examples

### Example 1: Simple TTL Cache

```json
{
  "implementation": "simple-ttl-cache",
  "code": {
    "javascript": "class SimpleCache {\n  constructor(ttl = 300) {\n    this.cache = new Map();\n    this.ttl = ttl * 1000; // Convert to ms\n  }\n  \n  get(key) {\n    const item = this.cache.get(key);\n    if (!item) return null;\n    \n    if (Date.now() > item.expires) {\n      this.cache.delete(key);\n      return null;\n    }\n    \n    return item.value;\n  }\n  \n  set(key, value) {\n    this.cache.set(key, {\n      value,\n      expires: Date.now() + this.ttl\n    });\n  }\n}"
  },
  "usage": {
    "example": "const cache = new SimpleCache(300); // 5 min TTL\n\nasync function getPlayer(id) {\n  const cached = cache.get(`player-${id}`);\n  if (cached) return cached;\n  \n  const response = await fetch(`/api/player/${id}`);\n  const data = await response.json();\n  cache.set(`player-${id}`, data);\n  return data;\n}"
  }
}
```

### Example 2: Event-Based Cache with Streaming

```json
{
  "implementation": "event-based-cache",
  "code": {
    "javascript": "class EventBasedCache {\n  constructor() {\n    this.cache = new Map();\n    this.nats = null;\n  }\n  \n  async connectNATS() {\n    // Connect to GRASS/NATS\n    this.nats = await connect({ servers: ['nats://localhost:4222'] });\n    \n    // Subscribe to invalidation events\n    this.nats.subscribe('structs.player.*', (msg) => {\n      const data = JSON.parse(msg.data.toString());\n      this.invalidate(`player-${data.id}`);\n    });\n  }\n  \n  invalidate(key) {\n    this.cache.delete(key);\n  }\n  \n  get(key) {\n    return this.cache.get(key);\n  }\n  \n  set(key, value) {\n    this.cache.set(key, value);\n  }\n}"
  },
  "usage": {
    "example": "const cache = new EventBasedCache();\nawait cache.connectNATS();\n\n// Cache will auto-invalidate on player updates"
  }
}
```

### Example 3: Hybrid Cache (TTL + Events)

```json
{
  "implementation": "hybrid-cache",
  "code": {
    "javascript": "class HybridCache {\n  constructor(ttl = 300) {\n    this.cache = new Map();\n    this.ttl = ttl * 1000;\n    this.nats = null;\n  }\n  \n  get(key) {\n    const item = this.cache.get(key);\n    if (!item) return null;\n    \n    // Check TTL\n    if (Date.now() > item.expires) {\n      this.cache.delete(key);\n      return null;\n    }\n    \n    return item.value;\n  }\n  \n  set(key, value) {\n    this.cache.set(key, {\n      value,\n      expires: Date.now() + this.ttl\n    });\n  }\n  \n  invalidate(key) {\n    this.cache.delete(key);\n  }\n  \n  // Subscribe to events for invalidation\n  async setupEventInvalidation() {\n    this.nats = await connect({ servers: ['nats://localhost:4222'] });\n    \n    this.nats.subscribe('structs.player.*', (msg) => {\n      const data = JSON.parse(msg.data.toString());\n      this.invalidate(`player-${data.id}`);\n    });\n  }\n}"
  }
}
```

---

## Cache Invalidation Patterns

### Pattern 1: TTL Expiration

**When**: Cache entry expires after TTL

**Implementation**:
```json
{
  "invalidation": "ttl-expiration",
  "check": "on-get",
  "action": "delete-if-expired"
}
```

### Pattern 2: Event-Driven Invalidation

**When**: Related event received via GRASS/NATS

**Implementation**:
```json
{
  "invalidation": "event-driven",
  "events": {
    "structs.player.{id}": "invalidate-player-{id}",
    "structs.planet.{id}": "invalidate-planet-{id}",
    "structs.guild.{id}": "invalidate-guild-{id}"
  }
}
```

### Pattern 3: Manual Invalidation

**When**: Explicitly invalidate cache

**Implementation**:
```json
{
  "invalidation": "manual",
  "methods": [
    "cache.invalidate(key)",
    "cache.clear()",
    "cache.invalidatePattern(pattern)"
  ]
}
```

### Pattern 4: Dependency-Based Invalidation

**When**: Related entity changes

**Implementation**:
```json
{
  "invalidation": "dependency-based",
  "dependencies": {
    "player-{id}": [
      "player-{id}-planets",
      "player-{id}-guild",
      "guild-{guildId}-members"
    ]
  }
}
```

---

## Recommended TTL Values

### Static Data (Long TTL)

**Examples**: Struct types, game constants

**TTL**: 3600 seconds (1 hour) or longer

```json
{
  "staticData": {
    "structTypes": 3600,
    "gameConstants": 7200,
    "structTypeCosmetics": 1800
  }
}
```

### Slowly-Changing Data (Medium TTL)

**Examples**: Player info, guild info

**TTL**: 300 seconds (5 minutes)

```json
{
  "slowlyChanging": {
    "playerInfo": 300,
    "guildInfo": 300,
    "planetInfo": 180
  }
}
```

### Moderately-Changing Data (Short TTL)

**Examples**: Planet resources, guild stats

**TTL**: 60 seconds (1 minute)

```json
{
  "moderatelyChanging": {
    "planetResources": 60,
    "guildStats": 60,
    "playerStats": 120
  }
}
```

### Frequently-Changing Data (Very Short TTL)

**Examples**: Planet shield, raid status

**TTL**: 10-30 seconds

```json
{
  "frequentlyChanging": {
    "planetShield": 10,
    "raidStatus": 15,
    "fleetStatus": 30
  }
}
```

---

## Cache Best Practices

### 1. Use Appropriate TTL Values

**Do**:
- Use longer TTL for static data
- Use shorter TTL for dynamic data
- Adjust based on data change frequency

**Don't**:
- Use same TTL for all data
- Cache real-time data
- Use TTL longer than data freshness requirements

### 2. Implement Cache Warming

**Do**:
```json
{
  "cacheWarming": {
    "onStartup": [
      "Load frequently accessed data",
      "Pre-fetch critical entities",
      "Subscribe to invalidation events"
    ]
  }
}
```

**Benefits**:
- Faster initial responses
- Better user experience
- Reduced API load

### 3. Monitor Cache Performance

**Metrics to Track**:
- Cache hit rate
- Cache miss rate
- Average response time
- Cache size

**Example**:
```json
{
  "monitoring": {
    "metrics": {
      "hitRate": 0.85,
      "missRate": 0.15,
      "averageResponseTime": 50,
      "cacheSize": 1000
    }
  }
}
```

### 4. Handle Cache Failures Gracefully

**Do**:
```json
{
  "errorHandling": {
    "cacheMiss": "fetch-from-api",
    "cacheError": "fetch-from-api",
    "cacheCorruption": "clear-and-refetch"
  }
}
```

**Don't**:
- Fail requests if cache fails
- Block on cache operations
- Ignore cache errors

### 5. Use Streaming for Real-time Data

**Do**:
```json
{
  "realTimeData": {
    "use": "GRASS/NATS streaming",
    "benefit": "No caching needed",
    "example": "Planet shield updates, raid status"
  }
}
```

**Benefits**:
- Real-time accuracy
- No cache invalidation needed
- Efficient updates

---

## Cache and Rate Limiting

### How Caching Helps Rate Limits

**Benefits**:
- Reduces API calls
- Preserves rate limit quota
- Allows more requests when needed

**Example**:
```json
{
  "scenario": "100 requests/minute limit",
  "withoutCache": {
    "requests": 100,
    "remaining": 0
  },
  "withCache": {
    "requests": 30,
    "cacheHits": 70,
    "remaining": 70
  }
}
```

### Combining Caching and Rate Limiting

**Strategy**:
1. Cache responses aggressively
2. Monitor rate limit headers
3. Use cached data when rate limit is low
4. Fetch fresh data when quota available

---

## Cache Storage Options

### In-Memory Cache

**Use When**:
- Single process/instance
- Fast access needed
- Limited data size

**Example**: JavaScript Map, Python dict

### Persistent Cache

**Use When**:
- Multiple processes
- Need persistence across restarts
- Large data size

**Example**: Redis, SQLite, file system

### Distributed Cache

**Use When**:
- Multiple instances
- Shared cache needed
- High availability required

**Example**: Redis cluster, Memcached

---

## Related Documentation

- **Rate Limiting**: `patterns/rate-limiting.md` - Rate limit patterns
- **Streaming**: `protocols/streaming.md` - GRASS/NATS streaming (alternative to caching)
- **API Usage**: `guides/api-usage-guide.md` - API usage best practices
- **Error Handling**: `protocols/error-handling.md` - Error handling patterns

---

## Quick Reference

### Cache Key Patterns
- Entity: `{entity}-{id}`
- Query: `{endpoint}-{params}`
- Composite: `{entity}-{id}-{language}-{guildId}`

### Recommended TTL
- Static: 3600s (1 hour)
- Slow: 300s (5 minutes)
- Moderate: 60s (1 minute)
- Fast: 10-30s

### Best Practices
1. Use appropriate TTL values
2. Implement cache warming
3. Monitor cache performance
4. Handle failures gracefully
5. Use streaming for real-time data

---

*Pattern Version: 1.0.0 - December 7, 2025*
