# Web Application API Protocol

**Category**: Query
**Status**: Stable
**Last Updated**: May 13, 2026

## Overview

The Web Application API Protocol defines how AI agents should interact with the `structs-webapp` service. This API provides enhanced game state information, player statistics, guild data, paginated catalog reads, live tunables, time-series stats, and authentication services.

**Implementation**: The webapp API is implemented in a PHP Symfony application ([`structs-webapp`](https://github.com/playstructs/structs-webapp)). This is the main user-facing API for the game.

The surface has two layers:

1. **Bespoke entity endpoints** — return joined / aggregated objects for common UI flows (e.g. `/api/player/{player_id}` returns the player + reactor staking summary; `/api/planet/{planet_id}/shield/health` returns the planet shield).
2. **Catalog read endpoints** — uniform paginated lists under `/api/{entity}[/{filter}]/page/{page}`. Use these when iterating, syncing, or analysing rather than rendering a single screen.

## Base Configuration

```json
{
  "baseUrl": "http://localhost:8080",
  "basePath": "/api",
  "timeout": 5000,
  "retryPolicy": {
    "maxRetries": 3,
    "retryDelay": 1000,
    "retryOn": ["timeout", "5xx", "network"]
  }
}
```

For the public Orbital Hydro guild webapp use `http://crew.oh.energy` as the base URL.

## Authentication

### Session-Based Authentication

The webapp uses session-based authentication via cookies.

**Login Flow**:
```json
{
  "request": {
    "method": "POST",
    "url": "/api/auth/login",
    "headers": {
      "Content-Type": "application/json"
    },
    "body": {
      "username": "player_username",
      "password": "player_password"
    }
  },
  "response": {
    "status": 200,
    "headers": {
      "Set-Cookie": "PHPSESSID=..."
    },
    "body": {
      "success": true,
      "message": "Login successful"
    }
  }
}
```

**Using Authenticated Requests**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/guild/this",
    "headers": {
      "Cookie": "PHPSESSID=..."
    }
  }
}
```

## Query Patterns

### Pattern 1: Player Information

**Use Case**: Get enhanced player information from webapp

**Format**: `GET /api/player/{player_id}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/player/1",
    "headers": {
      "Accept": "application/json"
    }
  },
  "response": {
    "status": 200,
    "body": {
      "player": {...},
      "stats": {...},
      "planets": [...]
    }
  }
}
```

**Related Endpoints**:
- `GET /api/player/{player_id}/ore/stats` - Ore statistics
- `GET /api/player/{player_id}/planet/completed` - Completed planets
- `GET /api/player/{player_id}/raid/launched` - Launched raids
- `GET /api/player/{player_id}/action/last/block/height` - Last action block height

### Pattern 2: Planet Information

**Use Case**: Get enhanced planet information

**Format**: `GET /api/planet/{planet_id}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/planet/1-1"
  },
  "response": {
    "status": 200,
    "body": {
      "planet": {...},
      "shield": {
        "health": 100,
        "maxHealth": 100
      },
      "structs": [...]
    }
  }
}
```

**Related Endpoints**:
- `GET /api/planet/{planet_id}/shield/health` - Shield health
- `GET /api/planet/{planet_id}/shield` - Shield information
- `GET /api/planet/{planet_id}/raid/active` - Active raid
- `GET /api/planet/raid/active/fleet/{fleet_id}` - Active raid for fleet

### Pattern 3: Guild Information

**Use Case**: Get guild information and statistics

**Format**: `GET /api/guild/{guild_id}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/guild/1"
  },
  "response": {
    "status": 200,
    "body": {
      "guild": {...},
      "members": [...],
      "stats": {...}
    }
  }
}
```

**Related Endpoints**:
- `GET /api/guild/this` - Current user's guild (requires auth)
- `GET /api/guild/{guild_id}/roster` - Guild roster
- `GET /api/guild/{guild_id}/power/stats` - Power statistics
- `GET /api/guild/{guild_id}/members/count` - Member count
- `GET /api/guild/{guild_id}/planet/complete/count` - Completed planet count
- `GET /api/guild/directory` - Guild directory
- `GET /api/guild/count` - Total guild count

### Pattern 4: Struct Information

**Use Case**: Get struct information

**Format**: `GET /api/struct/{struct_id}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/struct/1"
  },
  "response": {
    "status": 200,
    "body": {
      "struct": {...}
    }
  }
}
```

**Related Endpoints**:
- `GET /api/struct/planet/{planet_id}` - Structs on planet
- `GET /api/struct/type` - Struct types

### Pattern 5: Ledger Information

**Use Case**: Get transaction ledger for player

**Format**: `GET /api/ledger/player/{player_id}/page/{page}`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/ledger/player/1/page/1"
  },
  "response": {
    "status": 200,
    "body": {
      "transactions": [...],
      "page": 1,
      "totalPages": 10
    }
  }
}
```

**Related Endpoints**:
- `GET /api/ledger/player/{player_id}/count` - Transaction count
- `GET /api/ledger/{tx_id}` - Transaction by ID

### Pattern 6: Search Endpoints

**Use Case**: Search for raids, transfers, etc.

**Format**: `GET /api/player/raid/search` or `GET /api/player/transfer/search`

**Example**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/player/raid/search",
    "queryParams": {
      "player_id": "1",
      "status": "active"
    }
  },
  "response": {
    "status": 200,
    "body": {
      "raids": [...]
    }
  }
}
```

### Pattern 7: Catalog Read

**Use Case**: Iterate or scan rows for any catalog entity (player, planet, struct, allocation, agreement, agreement, defusion, fleet, grid, infusion, ledger, permission, permission-guild-rank, planet-activity, planet-attribute, provider, reactor, struct-attribute, struct-defender, substation, address-tag, banned-word, guild-membership-application).

**Format**: `GET /api/{entity}[/{filter_name}/{filter_value}]/page/{page}`

Conventions:

- `page` is **1-indexed** and constrained to `\d+` by the controller — non-numeric pages are 404.
- Endpoints with names containing a dash use kebab-case (e.g. `/api/banned-word/all/page/1`, `/api/permission-guild-rank/object/{object_id}/page/1`).
- For entities that **also** have bespoke single-object routes (`ledger`, `infusion`, `fleet`, `player`, `planet`, `guild`, `struct`), the catalog list lives under `/list/...` to avoid shadowing those routes (e.g. `/api/ledger/list/all/page/{page}` does not collide with `/api/ledger/{tx_id}`).

**Example**:

```json
{
  "request": {
    "method": "GET",
    "url": "/api/allocation/source/4-1/page/1"
  },
  "response": {
    "status": 200,
    "body": {
      "rows": [...],
      "page": 1,
      "page_size": 100
    }
  }
}
```

### Pattern 8: Time-Series Stats

**Use Case**: Pull a metric for one object across a time window.

**Format**: `GET /api/stat/{metric}/object/{object_key}/range/page/{page}?start_time={unix_seconds}&end_time={unix_seconds}`

**Example**:

```json
{
  "request": {
    "method": "GET",
    "url": "/api/stat/power/object/1-11/range/page/1?start_time=1715000000&end_time=1715600000"
  },
  "response": {
    "status": 200,
    "body": {
      "rows": [
        { "ts": 1715000300, "value": 1024 },
        { "ts": 1715000600, "value": 1018 }
      ],
      "page": 1
    }
  }
}
```

If `start_time` or `end_time` is missing, the endpoint returns `400 Bad Request` with `errors.start_time_end_time_required` set to `start_time and end_time query params are required (unix seconds)`.

### Pattern 9: Live Tunables

**Use Case**: Read the chain's economy/gameplay constants once at startup.

**Format**: `GET /api/setting`

Returns every entry from the `setting` table as a name/value map. Treat the response as an open-ended map — new keys are added over time. Known keys: `REACTOR_RATIO`, `PLAYER_RESUME_CHARGE`, `PLANETARY_SHIELD_BASE`, `PLAYER_PASSIVE_DRAW`, `PLANET_STARTING_ORE`, `PLANET_STARTING_SLOTS`.

## Error Handling

### Standard Error Response

```json
{
  "error": {
    "code": "NOT_FOUND",
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
    "401": {
      "action": "authenticate",
      "retry": true,
      "fallback": "request login"
    },
    "403": {
      "action": "log",
      "retry": false,
      "fallback": "return null"
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

1. **Use Session Cookies**: Maintain session cookies for authenticated requests
2. **Handle Authentication**: Check for 401 errors and re-authenticate if needed
3. **Cache Strategically**: Cache static data (struct types, guild directory)
4. **Don't Cache Dynamic Data**: Don't cache player stats, raid status, shield health
5. **Use Pagination**: Use pagination for ledger queries
6. **Combine with Consensus API**: Use webapp API for enhanced data, consensus API for authoritative state
7. **Handle Errors Gracefully**: Always handle 404, 401, 403, 500 errors

## Comparison with Consensus API

### When to Use Webapp API

**Use Webapp API for**:
- Enhanced player statistics (ore stats, completed planets)
- Guild information and rosters
- Shield health and planet details
- Ledger/transaction history
- Search functionality (raids, transfers)
- Authentication and user management
- **Catalog reads** (paginated lists per entity, joined with metadata) when you would otherwise reach into the chain's `pagination.key` API
- **Time-series stats** for one object across a time window
- **Live tunables** (`/api/setting`) — chain constants without parameter queries
- **Banned word list** to preflight UGC name validation client-side

### When to Use Consensus API

**Use Consensus API for**:
- Authoritative game state
- Transaction submission
- real-time state queries
- Block height and chain information
- Module parameters

### Combined Strategy

```json
{
  "strategy": "hybrid",
  "consensusAPI": {
    "useFor": [
      "authoritative state",
      "transactions",
      "block height"
    ]
  },
  "webappAPI": {
    "useFor": [
      "enhanced statistics",
      "guild information",
      "ledger history",
      "search functionality"
    ]
  }
}
```

## Performance Optimization

### Optimization 1: Parallel Queries

```json
{
  "strategy": "parallel",
  "queries": [
    "GET /api/player/1",
    "GET /api/player/1/ore/stats",
    "GET /api/player/1/planet/completed"
  ],
  "maxConcurrency": 10
}
```

### Optimization 2: Caching Strategy

```json
{
  "cachePolicy": {
    "structTypes": {
      "ttl": 3600,
      "endpoint": "/api/struct/type"
    },
    "guildDirectory": {
      "ttl": 300,
      "endpoint": "/api/guild/directory"
    },
    "guildCount": {
      "ttl": 60,
      "endpoint": "/api/guild/count"
    },
    "settings": {
      "ttl": 300,
      "endpoint": "/api/setting"
    },
    "bannedWords": {
      "ttl": 300,
      "endpoint": "/api/banned-word/all/page/1"
    }
  }
}
```
