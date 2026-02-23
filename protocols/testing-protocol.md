# Testing Protocol

**Version**: 1.0.0  
**Category**: Testing  
**Status**: Stable

---

## Overview

The Testing Protocol defines how AI agents should test API endpoints, validate responses, and ensure correct integration with Structs APIs.

**Key Principles**:
1. **Test all endpoints** before using in production
2. **Validate responses** against schemas
3. **Handle errors gracefully** in tests
4. **Test edge cases** (empty results, invalid IDs, etc.)
5. **Verify data consistency** across endpoints

---

## Testing Strategy

### Test Levels

1. **Unit Tests**: Test individual endpoints in isolation
2. **Integration Tests**: Test workflows and multi-step operations
3. **End-to-End Tests**: Test complete user scenarios
4. **Error Tests**: Test error handling and edge cases

### Test Categories

**Query Tests**:
- Test all query endpoints
- Verify response formats
- Test pagination
- Test filtering

**Action Tests**:
- Test transaction submission
- Verify request validation
- Test error responses

**Streaming Tests**:
- Test NATS connection
- Verify event reception
- Test subscription patterns

---

## Endpoint Testing Patterns

### Pattern 1: Basic Endpoint Test

**Test Structure**:
```json
{
  "test": {
    "name": "Get player by ID",
    "endpoint": "webapp-player-by-id",
    "method": "GET",
    "url": "http://localhost:8080/api/player/1-11",
    "expectedStatus": 200,
    "expectedSchema": "schemas/responses.md#/definitions/WebappPlayerResponse",
    "validations": [
      "response.status === 200",
      "response.body.player.id === '1-11'",
      "response.body.player.id matches pattern '^1-[0-9]+$'"
    ]
  }
}
```

### Pattern 2: Error Case Test

**Test Structure**:
```json
{
  "test": {
    "name": "Get non-existent player",
    "endpoint": "webapp-player-by-id",
    "method": "GET",
    "url": "http://localhost:8080/api/player/1-999",
    "expectedStatus": 404,
    "expectedSchema": "schemas/responses.md#/definitions/ErrorResponse",
    "validations": [
      "response.status === 404",
      "response.body.error contains 'not found'",
      "response.body.code === 404"
    ]
  }
}
```

### Pattern 3: Pagination Test

**Test Structure**:
```json
{
  "test": {
    "name": "List players with pagination",
    "endpoint": "player-list",
    "method": "GET",
    "url": "http://localhost:1317/structs/player",
    "parameters": {
      "pagination.limit": 10
    },
    "expectedStatus": 200,
    "validations": [
      "response.body.Player is array",
      "response.body.Player.length <= 10",
      "response.body.pagination exists",
      "if response.body.pagination.next_key exists, can fetch next page"
    ]
  }
}
```

---

## Response Validation

### Schema Validation

**Validate against JSON Schema**:
```json
{
  "validation": {
    "type": "schema",
    "schema": "schemas/responses.md#/definitions/WebappPlayerResponse",
    "response": "response.body",
    "strict": false
  }
}
```

### Field Validation

**Validate specific fields**:
```json
{
  "validations": [
    {
      "field": "response.body.player.id",
      "type": "string",
      "pattern": "^1-[0-9]+$",
      "required": true
    },
    {
      "field": "response.body.player.username",
      "type": "string",
      "minLength": 3,
      "maxLength": 20,
      "required": false
    }
  ]
}
```

### Type Validation

**Validate data types**:
```json
{
  "typeValidations": {
    "player.id": "string",
    "player.stats.total_ore": "integer",
    "player.guild": "object|null"
  }
}
```

---

## Error Testing

### Test Error Responses

**Test 404 Not Found**:
```json
{
  "test": {
    "name": "Test 404 error",
    "endpoint": "webapp-player-by-id",
    "method": "GET",
    "url": "http://localhost:8080/api/player/1-999",
    "expectedStatus": 404,
    "expectedError": {
      "code": 404,
      "error": "Player not found"
    },
    "validations": [
      "response.status === 404",
      "response.body.error exists",
      "response.body.code === 404"
    ]
  }
}
```

### Test Rate Limiting

**Test 429 Rate Limit**:
```json
{
  "test": {
    "name": "Test rate limiting",
    "endpoint": "webapp-player-by-id",
    "method": "GET",
    "url": "http://localhost:8080/api/player/1-11",
    "scenario": "Make 100+ requests rapidly",
    "expectedStatus": 429,
    "expectedHeaders": {
      "Retry-After": "number",
      "X-RateLimit-Limit": "number",
      "X-RateLimit-Remaining": "number"
    },
    "validations": [
      "response.status === 429",
      "response.headers['Retry-After'] exists",
      "parseInt(response.headers['Retry-After']) > 0"
    ]
  }
}
```

---

## Workflow Testing

### Test Multi-Step Workflows

**Example: Get Player and Planets**:
```json
{
  "test": {
    "name": "Get player and planets workflow",
    "type": "workflow",
    "steps": [
      {
        "step": 1,
        "name": "Get player",
        "endpoint": "webapp-player-by-id",
        "method": "GET",
        "url": "http://localhost:8080/api/player/1-11",
        "extract": {
          "player_id": "response.body.player.id"
        },
        "validations": [
          "response.status === 200",
          "response.body.player.id exists"
        ]
      },
      {
        "step": 2,
        "name": "Get player's planets",
        "endpoint": "planet-by-player",
        "method": "GET",
        "url": "http://localhost:1317/structs/planet_by_player/{{step1.extract.player_id}}",
        "validations": [
          "response.status === 200",
          "response.body.Planet is array"
        ]
      }
    ],
    "finalValidations": [
      "step1.response.body.player.id === step2.request.parameters.playerId",
      "step2.response.body.Planet is array"
    ]
  }
}
```

---

## Streaming Tests

### Test NATS Connection

**Test Connection**:
```json
{
  "test": {
    "name": "Test NATS connection",
    "type": "streaming",
    "connection": {
      "url": "nats://localhost:4222",
      "timeout": 5000
    },
    "validations": [
      "connection successful",
      "can subscribe to subject",
      "can receive messages"
    ]
  }
}
```

### Test Event Reception

**Test Event Subscription**:
```json
{
  "test": {
    "name": "Test event reception",
    "type": "streaming",
    "subscription": {
      "subject": "structs.player.*",
      "timeout": 10000
    },
    "validations": [
      "subscription successful",
      "can receive events",
      "event format matches schema",
      "event.category is valid"
    ]
  }
}
```

---

## Test Data Management

### Test Data Requirements

**Valid Test Data**:
- Valid player IDs (format: `1-{number}`) - Type 1 = Player
- Valid planet IDs (format: `2-{number}`) - Type 2 = Planet
- Valid guild IDs (format: `0-{number}`) - Type 0 = Guild
- Valid struct IDs (format: `5-{number}`) - Type 5 = Struct
- Valid fleet IDs (format: `9-{number}`) - Type 9 = Fleet

**Invalid Test Data** (for error testing):
- Non-existent IDs: `1-999`, `3-999`, etc.
- Invalid formats: `invalid-id`, `123`, etc.
- Out-of-range values

### Test Data Sources

1. **Query list endpoints** to get valid IDs
2. **Use known test data** from development environment
3. **Generate test data** using test fixtures
4. **Use edge cases** (empty results, single item, large lists)

---

## Test Execution

### Test Execution Flow

1. **Setup**: Prepare test environment and data
2. **Execute**: Run test requests
3. **Validate**: Check responses against expectations
4. **Cleanup**: Clean up test data (if needed)
5. **Report**: Document test results

### Test Reporting

**Test Report Format**:
```json
{
  "testReport": {
    "testName": "Get player by ID",
    "status": "passed|failed|skipped",
    "duration": 150,
    "request": {
      "method": "GET",
      "url": "http://localhost:8080/api/player/1-11"
    },
    "response": {
      "status": 200,
      "duration": 120
    },
    "validations": [
      {
        "name": "Status code check",
        "status": "passed",
        "expected": 200,
        "actual": 200
      }
    ],
    "errors": []
  }
}
```

---

## Best Practices

### 1. Test All Endpoints

**Practice**: Test every endpoint you plan to use

**Why**: Ensures endpoints work as expected in your environment

### 2. Validate Responses

**Practice**: Always validate responses against schemas

**Why**: Catches format changes and errors early

### 3. Test Error Cases

**Practice**: Test error scenarios (404, 429, 500)

**Why**: Ensures error handling works correctly

### 4. Test Edge Cases

**Practice**: Test empty results, invalid IDs, boundary values

**Why**: Handles real-world scenarios

### 5. Test Workflows

**Practice**: Test multi-step workflows, not just single endpoints

**Why**: Ensures integration works end-to-end

### 6. Monitor Rate Limits

**Practice**: Test rate limiting behavior

**Why**: Prevents production issues

### 7. Use Test Data

**Practice**: Use consistent test data across tests

**Why**: Makes tests reproducible

### 8. Clean Up

**Practice**: Clean up test data after tests

**Why**: Prevents test data pollution

---

## Test Examples

### Example 1: Basic Query Test

```json
{
  "test": {
    "name": "Get player by ID - Success",
    "endpoint": "webapp-player-by-id",
    "method": "GET",
    "url": "http://localhost:8080/api/player/1-11",
    "expectedStatus": 200,
    "validations": [
      "response.status === 200",
      "response.body.player.id === '1-11'",
      "response.body.player.id matches '^1-[0-9]+$'",
      "response.body.player.username is string or null"
    ]
  }
}
```

### Example 2: Error Test

```json
{
  "test": {
    "name": "Get player by ID - Not Found",
    "endpoint": "webapp-player-by-id",
    "method": "GET",
    "url": "http://localhost:8080/api/player/1-999",
    "expectedStatus": 404,
    "validations": [
      "response.status === 404",
      "response.body.error exists",
      "response.body.code === 404"
    ]
  }
}
```

### Example 3: Workflow Test

```json
{
  "test": {
    "name": "Get player and planets workflow",
    "type": "workflow",
    "steps": [
      {
        "step": 1,
        "endpoint": "webapp-player-by-id",
        "url": "http://localhost:8080/api/player/1-11"
      },
      {
        "step": 2,
        "endpoint": "planet-by-player",
        "url": "http://localhost:1317/structs/planet_by_player/{{step1.response.body.player.id}}"
      }
    ]
  }
}
```

---

## Test Tools and Libraries

### Recommended Tools

**HTTP Testing**:
- `curl` - Command-line testing
- `httpie` - User-friendly HTTP client
- `Postman` - GUI testing tool
- `REST Client` - VS Code extension

**Schema Validation**:
- `ajv` - JSON Schema validator (JavaScript)
- `jsonschema` - JSON Schema validator (Python)
- `json-schema-validator` - JSON Schema validator (Java)

**Test Frameworks**:
- `jest` - JavaScript testing framework
- `pytest` - Python testing framework
- `junit` - Java testing framework

---

## Related Documentation

- **Error Handling**: `protocols/error-handling.md`
- **Query Protocol**: `protocols/query-protocol.md`
- **Action Protocol**: `protocols/action-protocol.md`
- **Error Examples**: `examples/errors/`
- **Workflow Examples**: `examples/workflows/`

---

## Version History

- **1.0.0** (January 2025): Initial testing protocol documentation

---

*API Documentation Specialist - January 2025*  
*Based on API testing best practices and Structs API structure*
