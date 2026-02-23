# State Synchronization Patterns

**Version**: 1.0.0  
**Category**: Pattern  
**Status**: Stable

## Overview

State synchronization patterns for keeping AI agent state synchronized with game state.

## Pattern 1: Polling-Based Sync

**Use Case**: Simple bots, low-frequency updates

**Strategy**:
```json
{
  "pattern": "polling",
  "frequency": 10000,
  "queries": [
    "GET /blockheight",
    "GET /structs/player/{playerId}",
    "GET /structs/planet_by_player/{playerId}"
  ],
  "updateState": "on change"
}
```

**Implementation**:
```json
{
  "syncLoop": {
    "interval": 10000,
    "steps": [
      "1. Query block height",
      "2. Compare with last known block height",
      "3. If changed, query relevant entities",
      "4. Update local state",
      "5. Trigger state change handlers"
    ]
  }
}
```

## Pattern 2: Event-Driven Sync

**Use Case**: Real-time bots, high-frequency updates

**Strategy**:
```json
{
  "pattern": "event-driven",
  "method": "GRASS streaming",
  "channels": [
    "player.{playerId}",
    "planet.{planetId}",
    "struct.{structId}"
  ],
  "updateState": "on event"
}
```

**Implementation**:
```json
{
  "streaming": {
    "connect": "ws://localhost:1443/ws",
    "subscribe": [
      "player.1",
      "planet.1-1",
      "struct.1-1"
    ],
    "onEvent": {
      "action": "update local state",
      "trigger": "state change handlers"
    }
  }
}
```

## Pattern 3: Hybrid Sync

**Use Case**: Most bots, balance of efficiency and accuracy

**Strategy**:
```json
{
  "pattern": "hybrid",
  "initial": "polling (full state)",
  "updates": "streaming (incremental)",
  "fallback": "polling (if streaming fails)"
}
```

**Implementation**:
```json
{
  "syncStrategy": {
    "startup": {
      "method": "polling",
      "queries": "full state",
      "frequency": "once"
    },
    "runtime": {
      "method": "streaming",
      "channels": "relevant entities",
      "fallback": "polling if disconnected"
    },
    "recovery": {
      "method": "polling",
      "queries": "changed entities only",
      "frequency": "until streaming restored"
    }
  }
}
```

## Pattern 4: Incremental Sync

**Use Case**: Large state, minimize queries

**Strategy**:
```json
{
  "pattern": "incremental",
  "track": "last synced block height",
  "query": "only entities changed since last sync",
  "update": "incremental updates only"
}
```

**Implementation**:
```json
{
  "incrementalSync": {
    "track": {
      "lastBlockHeight": 0,
      "lastSyncTime": 0
    },
    "sync": {
      "query": "GET /blockheight",
      "compare": "if blockHeight > lastBlockHeight",
      "then": {
        "query": "entities changed since lastBlockHeight",
        "update": "local state",
        "update": "lastBlockHeight"
      }
    }
  }
}
```

## State Management

### Local State Structure

```json
{
  "localState": {
    "blockHeight": 0,
    "lastSyncTime": 0,
    "players": {},
    "planets": {},
    "structs": {},
    "fleets": {},
    "guilds": {},
    "reactors": {},
    "substations": {},
    "providers": {},
    "agreements": {},
    "allocations": {}
  }
}
```

### State Update Rules

```json
{
  "updateRules": {
    "blockHeight": {
      "always": "update",
      "trigger": "state change handlers"
    },
    "players": {
      "update": "on change",
      "merge": true,
      "preserve": "local metadata"
    },
    "planets": {
      "update": "on change",
      "merge": true,
      "preserve": "local metadata"
    }
  }
}
```

## Conflict Resolution

### Strategy 1: Server Wins

```json
{
  "conflictResolution": "server-wins",
  "rule": "always use server state",
  "action": "overwrite local state"
}
```

### Strategy 2: Timestamp Wins

```json
{
  "conflictResolution": "timestamp-wins",
  "rule": "use state with newer timestamp",
  "action": "compare timestamps, use newer"
}
```

### Strategy 3: Merge Strategy

```json
{
  "conflictResolution": "merge",
  "rule": "merge server and local state",
  "action": "merge non-conflicting fields, resolve conflicts"
}
```

## Performance Optimization

### Optimization 1: Selective Sync

```json
{
  "optimization": "selective",
  "strategy": "only sync entities needed for current task",
  "benefit": "reduced queries, faster sync"
}
```

### Optimization 2: Batch Sync

```json
{
  "optimization": "batch",
  "strategy": "batch related queries",
  "benefit": "reduced network overhead"
}
```

### Optimization 3: Cached Sync

```json
{
  "optimization": "cached",
  "strategy": "cache static data, sync dynamic data",
  "benefit": "reduced queries for static data"
}
```

## Best Practices

1. **Track Block Height**: Always track block height to detect changes
2. **Use Streaming When Possible**: Use GRASS streaming for real-time updates
3. **Fallback to Polling**: Have polling fallback if streaming fails
4. **Incremental Updates**: Use incremental updates when possible
5. **Cache Static Data**: Cache struct types, player info (changes infrequently)
6. **Handle Conflicts**: Have conflict resolution strategy
7. **Monitor Sync Status**: Monitor sync status and handle failures
8. **Optimize Queries**: Only query what you need

---

*Last Updated: January 2025*

