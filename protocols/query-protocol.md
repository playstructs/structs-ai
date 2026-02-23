# Query Protocol

**Version**: 1.0.0  
**Category**: Query  
**Status**: Stable

## Overview

The Query Protocol defines how AI agents should query game state from the Structs API. All queries use HTTP GET requests to REST endpoints.

## Base Configuration

```json
{
  "baseUrl": "http://localhost:1317",
  "basePath": "/structs",
  "timeout": 5000,
  "retryPolicy": {
    "maxRetries": 3,
    "retryDelay": 1000,
    "retryOn": ["timeout", "5xx", "network"]
  }
}
```

## Query Patterns

### Pattern 1: Single Entity Query

**Use Case**: Get a specific entity by ID

**Format**: `GET {basePath}/{entity}/{id}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/player/1",
    "headers": {
      "Accept": "application/json"
    }
  },
  "response": {
    "status": 200,
    "body": {
      "player": {...},
      "gridAttributes": {...},
      "playerInventory": {...},
      "halted": false
    }
  }
}
```

**Error Cases**:
- `404`: Entity not found
- `400`: Invalid ID format
- `500`: Server error

### Pattern 2: List Query

**Use Case**: Get all entities of a type (with pagination)

**Format**: `GET {basePath}/{entity}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/player",
    "queryParams": {
      "pagination.key": "",
      "pagination.limit": 100
    }
  },
  "response": {
    "status": 200,
    "body": {
      "player": [...],
      "pagination": {
        "next_key": "...",
        "total": 1000
      }
    }
  }
}
```

**Pagination Strategy**:
1. Start with empty `pagination.key`
2. Use `next_key` from response for next page
3. Continue until `next_key` is null
4. Use `pagination.limit` to control page size (max 100)

### Pattern 3: Filtered Query

**Use Case**: Get entities filtered by relationship

**Format**: `GET {basePath}/{entity}_by_{filter}/{filterValue}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/planet_by_player/1"
  },
  "response": {
    "status": 200,
    "body": {
      "planet": [...]
    }
  }
}
```

**Available Filters**:
- `planet_by_player/{playerId}` - Planets owned by player
- `address_by_player/{playerId}` - Addresses for player
- `agreement_by_provider/{providerId}` - Agreements for provider
- `allocation_by_source/{sourceId}` - Allocations from source
- `allocation_by_destination/{destinationId}` - Allocations to destination
- `infusion_by_destination/{destinationId}` - Infusions to destination
- `permission/object/{objectId}` - Permissions for object
- `permission/player/{playerId}` - Permissions for player

### Pattern 4: Attribute Query

**Use Case**: Get specific attributes of an entity

**Format**: `GET {basePath}/{entity}_attribute/{entityId}/{attributeType}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/planet_attribute/1-1/ore"
  },
  "response": {
    "status": 200,
    "body": {
      "planetAttribute": {...}
    }
  }
}
```

## Query Strategies

### Strategy 1: Incremental State Building

**Use Case**: Build complete game state incrementally

**Steps**:
1. Query block height: `GET /blockheight`
2. Query all players: `GET /structs/player` (paginated)
3. For each player, query their planets: `GET /structs/planet_by_player/{playerId}`
4. For each planet, query structs and resources
5. Continue building relationships

**Example Flow**:
```json
{
  "step1": {
    "query": "GET /blockheight",
    "store": "gameState.blockHeight"
  },
  "step2": {
    "query": "GET /structs/player",
    "store": "gameState.players",
    "pagination": true
  },
  "step3": {
    "forEach": "gameState.players",
    "query": "GET /structs/planet_by_player/{playerId}",
    "store": "gameState.planets[playerId]"
  }
}
```

### Strategy 2: Focused Queries

**Use Case**: Query only what you need for specific task

**Steps**:
1. Identify required entities
2. Query only those entities
3. Query relationships only if needed

**Example**:
```json
{
  "task": "Monitor player 1's planets",
  "queries": [
    "GET /structs/player/1",
    "GET /structs/planet_by_player/1"
  ],
  "updateFrequency": "every 10 seconds"
}
```

### Strategy 3: Relationship Traversal

**Use Case**: Follow relationships between entities

**Pattern**:
1. Start with root entity
2. Query related entities using relationship endpoints
3. Continue traversing as needed

**Example**:
```json
{
  "start": "player/1",
  "traverse": [
    {
      "entity": "player",
      "id": "1",
      "relationships": [
        {
          "type": "owns",
          "entity": "planet",
          "query": "GET /structs/planet_by_player/1"
        },
        {
          "type": "owns",
          "entity": "struct",
          "query": "GET /structs/struct",
          "filter": "ownerId == 1"
        }
      ]
    }
  ]
}
```

## Caching Strategy

### When to Cache

**Cache These**:
- Struct types (rarely change)
- Player information (changes infrequently)
- Planet information (changes infrequently)
- Guild information (changes infrequently)

**Don't Cache These**:
- Block height (changes every block)
- Real-time combat state
- Energy allocations (changes frequently)
- Fleet positions (changes frequently)

### Cache Invalidation

```json
{
  "cachePolicy": {
    "structTypes": {
      "ttl": 3600,
      "invalidateOn": ["blockHeight change"]
    },
    "players": {
      "ttl": 300,
      "invalidateOn": ["player update event"]
    },
    "planets": {
      "ttl": 60,
      "invalidateOn": ["planet update event"]
    }
  }
}
```

## Error Handling

### Standard Error Response

```json
{
  "error": {
    "code": "ENTITY_NOT_FOUND",
    "message": "Player with ID '1' not found",
    "details": {
      "entity": "Player",
      "id": "1"
    }
  }
}
```

### Error Handling Strategy

```json
{
  "onError": {
    "404": {
      "action": "log",
      "retry": false,
      "fallback": "return null"
    },
    "400": {
      "action": "log",
      "retry": false,
      "fallback": "validate input"
    },
    "500": {
      "action": "retry",
      "maxRetries": 3,
      "backoff": "exponential"
    },
    "timeout": {
      "action": "retry",
      "maxRetries": 3,
      "backoff": "exponential"
    }
  }
}
```

## Best Practices

1. **Use Pagination**: Always use pagination for list queries
2. **Cache Strategically**: Cache static data, don't cache dynamic data
3. **Handle Errors**: Always handle 404, 400, 500 errors
4. **Rate Limiting**: Respect rate limits (see rate-limiting.md)
5. **Batch Queries**: When possible, batch related queries
6. **Use Filtered Queries**: Use filtered queries instead of filtering client-side
7. **Monitor Block Height**: Track block height to detect state changes

## Performance Optimization

### Optimization 1: Parallel Queries

```json
{
  "strategy": "parallel",
  "queries": [
    "GET /structs/player/1",
    "GET /structs/planet_by_player/1",
    "GET /structs/fleet",
    "GET /structs/struct"
  ],
  "maxConcurrency": 10
}
```

### Optimization 2: Selective Queries

```json
{
  "strategy": "selective",
  "onlyQuery": [
    "entities needed for current task"
  ],
  "skipQuery": [
    "entities not needed"
  ]
}
```

### Optimization 3: Incremental Updates

```json
{
  "strategy": "incremental",
  "initialQuery": "full state",
  "subsequentQueries": "only changes",
  "useStreaming": true
}
```

---

*Last Updated: January 2025*

