# Polling vs Streaming Pattern

**Version**: 1.0.0  
**Category**: API Patterns  
**Purpose**: Guide for AI agents on choosing between polling and streaming for real-time data

---

## Overview

This pattern helps AI agents decide when to use polling (repeated API requests) versus streaming (GRASS/NATS real-time updates) for accessing game state data. Each approach has trade-offs in terms of performance, accuracy, and resource usage.

---

## Decision Framework

### Use Polling When

**Characteristics**:
- ✅ Data changes infrequently
- ✅ Need occasional updates
- ✅ Simple implementation preferred
- ✅ Low update frequency acceptable
- ✅ No real-time requirement

**Examples**:
- Player profile information
- Guild roster (changes occasionally)
- Struct type definitions
- Static configuration data

### Use Streaming When

**Characteristics**:
- ✅ Data changes frequently
- ✅ Need real-time updates
- ✅ Low latency required
- ✅ High update frequency
- ✅ Event-driven architecture

**Examples**:
- Planet shield health (during raids)
- Fleet movement status
- Resource amounts (during mining)
- Player online status
- Combat events

### Use Hybrid When

**Characteristics**:
- ✅ Initial load via polling
- ✅ Updates via streaming
- ✅ Fallback to polling if streaming fails
- ✅ Best of both worlds

**Examples**:
- Load player data, then stream updates
- Load planet data, then monitor shield via streaming
- Load guild info, then stream member changes

---

## Comparison Matrix

| Factor | Polling | Streaming |
|--------|---------|-----------|
| **Latency** | High (poll interval) | Low (real-time) |
| **Accuracy** | Stale until next poll | Real-time |
| **API Calls** | Many (repeated requests) | Few (one connection) |
| **Rate Limits** | Consumes quota | No rate limits |
| **Complexity** | Simple | Moderate |
| **Resource Usage** | CPU/Network per poll | Persistent connection |
| **Error Handling** | Per-request | Connection-level |
| **Offline Support** | None | Reconnection needed |

---

## Polling Patterns

### Pattern 1: Fixed Interval Polling

**Approach**: Poll at regular intervals

**Implementation**:
```json
{
  "pattern": "fixed-interval-polling",
  "interval": 5000,
  "unit": "milliseconds",
  "endpoint": "/api/planet/{planet_id}/shield/health"
}
```

**Example**:
```json
{
  "polling": {
    "interval": 5000,
    "action": "Poll planet shield every 5 seconds",
    "code": "setInterval(() => pollPlanetShield(), 5000)"
  }
}
```

**Use When**:
- Predictable update needs
- Simple implementation
- Acceptable latency

### Pattern 2: Adaptive Polling

**Approach**: Adjust poll interval based on activity

**Implementation**:
```json
{
  "pattern": "adaptive-polling",
  "intervals": {
    "active": 1000,
    "inactive": 10000,
    "idle": 60000
  },
  "trigger": "activity-detected"
}
```

**Example**:
```json
{
  "adaptivePolling": {
    "duringRaid": {
      "interval": 1000,
      "reason": "High activity, need frequent updates"
    },
    "normal": {
      "interval": 5000,
      "reason": "Normal activity"
    },
    "idle": {
      "interval": 30000,
      "reason": "Low activity, reduce polling"
    }
  }
}
```

**Use When**:
- Activity levels vary
- Want to optimize API usage
- Can detect activity state

### Pattern 3: Event-Triggered Polling

**Approach**: Poll when specific events occur

**Implementation**:
```json
{
  "pattern": "event-triggered-polling",
  "trigger": "external-event",
  "action": "poll-on-demand"
}
```

**Example**:
```json
{
  "eventTriggered": {
    "onUserAction": "Poll player data",
    "onNotification": "Poll related entity",
    "onTimer": "Poll at scheduled time"
  }
}
```

**Use When**:
- Updates needed on-demand
- User-triggered actions
- Scheduled updates

---

## Streaming Patterns

### Pattern 1: Single Subject Subscription

**Approach**: Subscribe to one specific subject

**Implementation**:
```json
{
  "pattern": "single-subject-streaming",
  "subject": "structs.planet.2-1",
  "events": ["raid_status", "fleet_arrive", "fleet_depart"]
}
```

**Example**:
```json
{
  "subscription": {
    "subject": "structs.planet.2-1",
    "description": "Monitor specific planet",
    "events": [
      "raid_status",
      "fleet_arrive",
      "fleet_advance",
      "fleet_depart"
    ]
  }
}
```

**Use When**:
- Monitoring single entity
- Need all events for that entity
- Simple subscription

### Pattern 2: Wildcard Subscription

**Approach**: Subscribe to multiple entities with pattern

**Implementation**:
```json
{
  "pattern": "wildcard-streaming",
  "subject": "structs.player.*",
  "description": "Monitor all players"
}
```

**Example**:
```json
{
  "subscription": {
    "subject": "structs.player.*",
    "description": "Monitor all player updates",
    "filter": "Process only relevant players"
  }
}
```

**Use When**:
- Monitoring multiple entities
- Pattern-based filtering
- Need broad coverage

### Pattern 3: Multi-Subject Subscription

**Approach**: Subscribe to multiple specific subjects

**Implementation**:
```json
{
  "pattern": "multi-subject-streaming",
  "subjects": [
    "structs.player.1-1",
    "structs.planet.2-1",
    "structs.guild.0-1"
  ]
}
```

**Example**:
```json
{
  "subscriptions": {
    "player": "structs.player.1-1",
    "planet": "structs.planet.2-1",
    "guild": "structs.guild.0-1"
  }
}
```

**Use When**:
- Monitoring specific entities
- Need targeted updates
- Multiple related entities

---

## Hybrid Patterns

### Pattern 1: Initial Load + Streaming Updates

**Approach**: Load initial state via polling, then stream updates

**Implementation**:
```json
{
  "pattern": "initial-load-streaming",
  "steps": [
    {
      "step": 1,
      "method": "polling",
      "action": "GET /api/player/{id}",
      "description": "Load initial player data"
    },
    {
      "step": 2,
      "method": "streaming",
      "action": "Subscribe to structs.player.{id}",
      "description": "Stream updates"
    }
  ]
}
```

**Benefits**:
- Fast initial load
- Real-time updates
- Efficient API usage

### Pattern 2: Streaming with Polling Fallback

**Approach**: Use streaming, fallback to polling if connection lost

**Implementation**:
```json
{
  "pattern": "streaming-with-fallback",
  "primary": "streaming",
  "fallback": "polling",
  "reconnect": true,
  "fallbackInterval": 5000
}
```

**Example**:
```json
{
  "strategy": {
    "primary": {
      "method": "streaming",
      "subject": "structs.planet.2-1"
    },
    "fallback": {
      "method": "polling",
      "interval": 5000,
      "trigger": "streaming-connection-lost"
    },
    "reconnect": {
      "enabled": true,
      "strategy": "exponential-backoff"
    }
  }
}
```

**Benefits**:
- Real-time when available
- Graceful degradation
- Reliable updates

### Pattern 3: Selective Streaming

**Approach**: Stream high-frequency data, poll low-frequency data

**Implementation**:
```json
{
  "pattern": "selective-streaming",
  "streaming": {
    "data": ["planet_shield", "fleet_status", "raid_status"],
    "reason": "High frequency, real-time needed"
  },
  "polling": {
    "data": ["player_profile", "guild_info", "struct_types"],
    "interval": 300000,
    "reason": "Low frequency, acceptable latency"
  }
}
```

**Benefits**:
- Optimized resource usage
- Real-time where needed
- Efficient for mixed data

---

## Performance Considerations

### Polling Performance

**Factors**:
- Poll interval
- Number of endpoints
- Response size
- Rate limit constraints

**Optimization**:
```json
{
  "optimization": {
    "reduceInterval": "When rate limit allows",
    "batchRequests": "When possible",
    "cacheResponses": "To reduce API calls",
    "prioritizeEndpoints": "Focus on critical data"
  }
}
```

### Streaming Performance

**Factors**:
- Connection stability
- Message processing speed
- Number of subscriptions
- Event frequency

**Optimization**:
```json
{
  "optimization": {
    "filterEvents": "Process only relevant events",
    "batchProcessing": "Process multiple events together",
    "connectionPooling": "Reuse connections",
    "backpressure": "Handle high event rates"
  }
}
```

---

## Cost Analysis

### Polling Costs

**API Calls**: High (repeated requests)
**Rate Limit Usage**: High
**Network Bandwidth**: Moderate
**Server Load**: High (many requests)

**Example**:
- Poll every 5 seconds = 12 requests/minute
- 10 entities = 120 requests/minute
- Consumes significant rate limit quota

### Streaming Costs

**API Calls**: Low (one connection)
**Rate Limit Usage**: None
**Network Bandwidth**: Low (persistent connection)
**Server Load**: Low (one connection)

**Example**:
- One connection for multiple entities
- No rate limit consumption
- Efficient resource usage

---

## Best Practices

### 1. Choose Based on Update Frequency

**High Frequency** (changes every few seconds):
- ✅ Use streaming
- ❌ Don't poll (wasteful)

**Low Frequency** (changes every few minutes):
- ✅ Use polling
- ❌ Don't stream (unnecessary)

### 2. Use Hybrid for Best Results

**Initial Load**: Polling (fast, simple)
**Updates**: Streaming (real-time, efficient)

### 3. Monitor and Adjust

**Metrics**:
- Poll frequency vs. update frequency
- Streaming connection stability
- API call reduction with streaming
- Latency improvements

### 4. Implement Fallbacks

**Always**:
- Fallback to polling if streaming fails
- Reconnect logic for streaming
- Error handling for both methods

### 5. Cache Polling Results

**When Polling**:
- Cache responses to reduce API calls
- Invalidate cache on streaming events
- Use TTL-based expiration

---

## Implementation Examples

### Example 1: Planet Shield Monitoring (Streaming)

**Use Case**: Monitor planet shield during raid

**Implementation**:
```json
{
  "useCase": "planet-shield-monitoring",
  "method": "streaming",
  "reason": "High frequency updates during raid",
  "implementation": {
    "subscribe": "structs.planet.2-1",
    "filter": "raid_status events",
    "action": "Update shield health on event"
  }
}
```

**Benefits**:
- Real-time shield updates
- No rate limit consumption
- Efficient during active raids

### Example 2: Player Profile (Polling)

**Use Case**: Display player profile information

**Implementation**:
```json
{
  "useCase": "player-profile",
  "method": "polling",
  "reason": "Changes infrequently",
  "implementation": {
    "interval": 300000,
    "endpoint": "/api/player/{id}",
    "cache": true,
    "ttl": 300
  }
}
```

**Benefits**:
- Simple implementation
- Acceptable latency
- Low resource usage

### Example 3: Guild Dashboard (Hybrid)

**Use Case**: Display guild information with real-time member updates

**Implementation**:
```json
{
  "useCase": "guild-dashboard",
  "method": "hybrid",
  "implementation": {
    "initialLoad": {
      "method": "polling",
      "endpoints": [
        "/api/guild/{id}",
        "/api/guild/{id}/members/count",
        "/api/guild/{id}/power/stats"
      ]
    },
    "updates": {
      "method": "streaming",
      "subjects": [
        "structs.guild.{id}",
        "structs.player.*"
      ],
      "filter": "guild-related events"
    }
  }
}
```

**Benefits**:
- Fast initial load
- Real-time updates
- Efficient API usage

---

## Decision Tree

```
Start
  │
  ├─ Data changes every few seconds?
  │   ├─ Yes → Use Streaming
  │   └─ No → Continue
  │
  ├─ Need real-time accuracy?
  │   ├─ Yes → Use Streaming
  │   └─ No → Continue
  │
  ├─ High update frequency expected?
  │   ├─ Yes → Use Streaming
  │   └─ No → Continue
  │
  ├─ Simple implementation preferred?
  │   ├─ Yes → Use Polling
  │   └─ No → Continue
  │
  └─ Use Hybrid (Initial Load + Streaming)
```

---

## Related Documentation

- **Streaming Protocol**: `protocols/streaming.md` - Complete GRASS/NATS streaming guide
- **Query Protocol**: `protocols/query-protocol.md` - Polling/query patterns
- **Caching Pattern**: `patterns/caching.md` - Caching strategies (complements polling)
- **Rate Limiting**: `patterns/rate-limiting.md` - Rate limit handling (affects polling)

---

## Quick Reference

### Use Polling For
- Static or slowly-changing data
- Simple implementations
- Low update frequency needs
- Initial data loading

### Use Streaming For
- Frequently-changing data
- Real-time requirements
- High update frequency
- Event-driven updates

### Use Hybrid For
- Best of both worlds
- Initial load + updates
- Fallback scenarios
- Optimized performance

---

*Pattern Version: 1.0.0 - January 2025*
