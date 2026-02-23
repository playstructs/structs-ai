# Pagination Patterns

**Version**: 1.0.0  
**Category**: Pattern  
**Status**: Stable

---

## Overview

Pagination patterns define how AI agents should handle paginated API responses when querying lists of entities. Structs APIs use key-based pagination for efficient data retrieval.

**Key Principles**:
1. **Use pagination keys** to navigate through large datasets
2. **Respect page size limits** (typically max 100 items per page)
3. **Handle empty results** gracefully
4. **Continue until next_key is null** to fetch all data
5. **Cache pagination state** for resumable operations

---

## Pagination Methods

### 1. Key-Based Pagination (Consensus Network)

**Format**: Uses `pagination.key` and `pagination.limit` parameters

**Request**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/player",
    "queryParams": {
      "pagination.key": "",
      "pagination.limit": 100
    }
  }
}
```

**Response**:
```json
{
  "response": {
    "status": 200,
    "body": {
      "Player": [...],
      "pagination": {
        "next_key": "base64_encoded_key",
        "total": "1000"
      }
    }
  }
}
```

**Next Page Request**:
```json
{
  "request": {
    "method": "GET",
    "url": "/structs/player",
    "queryParams": {
      "pagination.key": "base64_encoded_key",
      "pagination.limit": 100
    }
  }
}
```

### 2. Offset-Based Pagination (Some Webapp Endpoints)

**Format**: Uses `offset` and `limit` parameters

**Request**:
```json
{
  "request": {
    "method": "GET",
    "url": "/api/guild/directory",
    "queryParams": {
      "offset": 0,
      "limit": 50
    }
  }
}
```

**Response**:
```json
{
  "response": {
    "status": 200,
    "body": {
      "guilds": [...],
      "pagination": {
        "offset": 0,
        "limit": 50,
        "total": 200,
        "hasMore": true
      }
    }
  }
}
```

---

## Pagination Parameters

### Consensus Network Parameters

**pagination.key** (string, optional):
- Base64-encoded pagination key
- Empty string or omitted for first page
- Use `next_key` from previous response for subsequent pages
- `null` or empty indicates last page

**pagination.limit** (integer, optional):
- Maximum number of items per page
- Default: varies by endpoint
- Maximum: typically 100
- Recommended: 50-100 for optimal performance

**pagination.offset** (integer, optional):
- Number of items to skip (alternative to key-based)
- Used in some endpoints
- Less efficient than key-based for large datasets

### Web Application Parameters

**offset** (integer, optional):
- Number of items to skip
- Default: 0
- Increment by `limit` for next page

**limit** (integer, optional):
- Maximum number of items per page
- Default: varies by endpoint
- Maximum: typically 100

---

## Pagination Strategies

### Strategy 1: Fetch All Items

**Use Case**: Need complete dataset

**Pattern**:
```json
{
  "strategy": "fetch-all",
  "steps": [
    {
      "step": 1,
      "action": "fetch-first-page",
      "pagination": {
        "key": "",
        "limit": 100
      }
    },
    {
      "step": 2,
      "action": "check-next-key",
      "condition": "response.pagination.next_key !== null"
    },
    {
      "step": 3,
      "action": "fetch-next-page",
      "pagination": {
        "key": "{{previous_response.pagination.next_key}}",
        "limit": 100
      },
      "repeat": "until next_key is null"
    }
  ]
}
```

**Implementation Example**:
```typescript
async function fetchAllPlayers() {
  const allPlayers = [];
  let nextKey = '';
  
  do {
    const response = await fetch(
      `/structs/player?pagination.key=${nextKey}&pagination.limit=100`
    );
    const data = await response.json();
    
    allPlayers.push(...data.Player);
    nextKey = data.pagination?.next_key || '';
  } while (nextKey);
  
  return allPlayers;
}
```

### Strategy 2: Fetch Specific Page

**Use Case**: Need specific page of results

**Pattern**:
```json
{
  "strategy": "fetch-specific-page",
  "page": 3,
  "pageSize": 50,
  "steps": [
    {
      "step": 1,
      "action": "calculate-offset",
      "offset": "(page - 1) * pageSize"
    },
    {
      "step": 2,
      "action": "fetch-page",
      "pagination": {
        "offset": 100,
        "limit": 50
      }
    }
  ]
}
```

### Strategy 3: Incremental Fetching

**Use Case**: Load data incrementally as needed

**Pattern**:
```json
{
  "strategy": "incremental-fetch",
  "steps": [
    {
      "step": 1,
      "action": "fetch-initial-page",
      "pagination": {
        "key": "",
        "limit": 50
      },
      "store": "last_key"
    },
    {
      "step": 2,
      "action": "fetch-more-when-needed",
      "pagination": {
        "key": "{{last_key}}",
        "limit": 50
      },
      "trigger": "user-scrolls-or-requests-more"
    }
  ]
}
```

---

## Pagination Response Formats

### Consensus Network Format

**Standard Format**:
```json
{
  "Entity": [...],
  "pagination": {
    "next_key": "base64_key_or_null",
    "total": "1000"
  }
}
```

**Fields**:
- `Entity` (array): Array of entity objects
- `pagination.next_key` (string|null): Key for next page, null if last page
- `pagination.total` (string): Total number of items (may be approximate)

### Web Application Format

**Standard Format**:
```json
{
  "data": [...],
  "pagination": {
    "offset": 0,
    "limit": 50,
    "total": 200,
    "hasMore": true
  }
}
```

**Fields**:
- `data` (array): Array of data objects
- `pagination.offset` (integer): Current offset
- `pagination.limit` (integer): Page size
- `pagination.total` (integer): Total number of items
- `pagination.hasMore` (boolean): Whether more pages exist

---

## Handling Edge Cases

### Empty Results

**Scenario**: No items match query

**Response**:
```json
{
  "Player": [],
  "pagination": {
    "next_key": null,
    "total": "0"
  }
}
```

**Handling**:
- Check if array is empty
- `next_key` will be null
- No need to fetch more pages

### Single Page Results

**Scenario**: All results fit in one page

**Response**:
```json
{
  "Player": [...],
  "pagination": {
    "next_key": null,
    "total": "25"
  }
}
```

**Handling**:
- Check if `next_key` is null
- No additional pages to fetch

### Large Datasets

**Scenario**: Thousands of items

**Best Practice**:
- Use reasonable page sizes (50-100)
- Implement caching
- Consider filtering if possible
- Use incremental loading for UI

---

## Best Practices

### 1. Use Appropriate Page Size

**Recommendation**: 50-100 items per page

**Why**:
- Balance between performance and data transfer
- Reduces server load
- Faster response times
- Better user experience

### 2. Cache Pagination State

**Pattern**:
```json
{
  "cache": {
    "lastKey": "base64_key",
    "lastPage": 5,
    "totalFetched": 500,
    "timestamp": "2025-01-01T00:00:00Z"
  }
}
```

**Benefits**:
- Resume pagination after interruption
- Avoid refetching previous pages
- Track progress

### 3. Handle Errors Gracefully

**Pattern**:
```json
{
  "errorHandling": {
    "networkError": "retry-current-page",
    "rateLimit": "wait-and-retry",
    "serverError": "skip-page-and-continue"
  }
}
```

### 4. Monitor Rate Limits

**Best Practice**: 
- Space out pagination requests
- Respect rate limit headers
- Use exponential backoff on rate limit errors

### 5. Validate Pagination Data

**Checks**:
- Verify `next_key` format (base64 or null)
- Validate `total` is non-negative
- Check array length matches expectations
- Verify no duplicate items across pages

---

## Pagination Examples

### Example 1: Fetch All Players

```json
{
  "workflow": "fetch-all-players",
  "steps": [
    {
      "step": 1,
      "endpoint": "player-list",
      "method": "GET",
      "url": "/structs/player",
      "parameters": {
        "pagination.key": "",
        "pagination.limit": 100
      },
      "extract": {
        "players": "response.body.Player",
        "nextKey": "response.body.pagination.next_key"
      }
    },
    {
      "step": 2,
      "condition": "nextKey !== null",
      "endpoint": "player-list",
      "method": "GET",
      "url": "/structs/player",
      "parameters": {
        "pagination.key": "{{step1.extract.nextKey}}",
        "pagination.limit": 100
      },
      "repeat": "until nextKey is null"
    }
  ],
  "result": {
    "allPlayers": "{{accumulated_players}}"
  }
}
```

### Example 2: Fetch Guild Directory with Offset

```json
{
  "workflow": "fetch-guild-directory",
  "steps": [
    {
      "step": 1,
      "endpoint": "webapp-guild-directory",
      "method": "GET",
      "url": "/api/guild/directory",
      "parameters": {
        "offset": 0,
        "limit": 50
      },
      "extract": {
        "guilds": "response.body.data",
        "hasMore": "response.body.pagination.hasMore",
        "total": "response.body.pagination.total"
      }
    },
    {
      "step": 2,
      "condition": "hasMore === true",
      "endpoint": "webapp-guild-directory",
      "method": "GET",
      "url": "/api/guild/directory",
      "parameters": {
        "offset": 50,
        "limit": 50
      },
      "repeat": "until hasMore is false"
    }
  ]
}
```

---

## Performance Considerations

### Optimizing Pagination

1. **Use appropriate page sizes**: 50-100 items typically optimal
2. **Cache responses**: Avoid refetching same pages
3. **Parallel fetching**: Fetch multiple pages in parallel (if supported)
4. **Filter early**: Use query filters to reduce dataset size
5. **Monitor rate limits**: Space out requests appropriately

### Avoiding Common Pitfalls

1. **Don't fetch all data unnecessarily**: Only fetch what you need
2. **Don't ignore rate limits**: Respect API rate limits
3. **Don't assume total is exact**: `total` may be approximate
4. **Don't skip error handling**: Handle network and server errors
5. **Don't forget to check for null**: `next_key` can be null

---

## Related Documentation

- **Query Protocol**: `protocols/query-protocol.md`
- **API Endpoints**: `api/endpoints.md`
- **Error Handling**: `protocols/error-handling.md`
- **Rate Limiting**: `api/rate-limits.md`

---

## Version History

- **1.0.0** (January 2025): Initial pagination patterns documentation

---

*API Documentation Specialist - January 2025*

