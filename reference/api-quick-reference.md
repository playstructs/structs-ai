# API Quick Reference

**Version**: 1.1.0  
**Last Updated**: January 1, 2026  
**Purpose**: Quick reference guide for AI agents

---

## Base URLs

### Consensus Network API
- **Base URL**: `http://localhost:1317`
- **Base Path**: `/structs`
- **RPC URL**: `http://localhost:26657`

### Web Application API
- **Base URL**: `http://localhost:8080`
- **Base Path**: `/api`

### Streaming (GRASS/NATS)
- **NATS Protocol**: `nats://localhost:4222`
- **NATS WebSocket**: `ws://localhost:1443`

---

## Common Endpoints

### Player Endpoints

**Get Player (Consensus)**:
```
GET /structs/player/{id}
```

**Get Player (Webapp)**:
```
GET /api/player/{player_id}
```

**Get Player Ore Stats**:
```
GET /api/player/{player_id}/ore/stats
```

**Get Player's Planets**:
```
GET /structs/planet_by_player/{playerId}
```

### Planet Endpoints

**Get Planet (Consensus)**:
```
GET /structs/planet/{id}
```

**Get Planet (Webapp)**:
```
GET /api/planet/{planet_id}
```

**Get Planet Shield Health**:
```
GET /api/planet/{planet_id}/shield/health
```

### Guild Endpoints

**Get Guild (Consensus)**:
```
GET /structs/guild/{id}
```

**Get Guild (Webapp)**:
```
GET /api/guild/{guild_id}
```

**Get Guild Member Count**:
```
GET /api/guild/{guild_id}/members/count
```

**Get Guild Power Stats**:
```
GET /api/guild/{guild_id}/power/stats
```

### Struct Endpoints

**Get Struct (Consensus)**:
```
GET /structs/struct/{id}
```

**Get Struct (Webapp)**:
```
GET /api/struct/{struct_id}
```

**Get Struct Type (Consensus)**:
```
GET /structs/struct_type/{id}
```

**Get Struct Type with Cosmetics (Webapp)**:
```
GET /api/struct-type/{structTypeId}/full?language=en&guildId={guildId}
```

### Cosmetic Sets and Skins Endpoints

**List Sets**:
```
GET /api/cosmetic-sets?active=true&guildId={guildId}
```

**Get Set Details**:
```
GET /api/cosmetic-sets/{setHash}
```

**Get Cosmetic by Class**:
```
GET /api/cosmetic/class/{class}?language=en&guildId={guildId}
```

**Install Mod** (converts to Sets/Skins):
```
POST /api/cosmetic-mods/install
Content-Type: multipart/form-data
file: [ZIP file or directory path]
```

**Validate Mod** (mod file format):
```
POST /api/cosmetic-mods/validate
Content-Type: multipart/form-data
file: [ZIP file or directory path]
```

**Delete Set**:
```
DELETE /api/cosmetic-sets/{setHash}
```

**Activate/Deactivate Set**:
```
POST /api/cosmetic-sets/{setHash}/activate
POST /api/cosmetic-sets/{setHash}/deactivate
```

**Note**: `setHash` and `skinHash` are SHA-256 hashes (64-character hexadecimal). Cosmetics are linked to struct types via the `class` field (e.g., "Miner", "Reactor").

**Get Structs by Planet**:
```
GET /api/struct/planet/{planet_id}
```

### Transaction Endpoints

**Submit Transaction**:
```
POST /cosmos/tx/v1beta1/txs
```

**Get Transaction**:
```
GET /cosmos/tx/v1beta1/txs/{hash}
```

---

## Response Formats

### Success Response (Webapp)
```json
{
  "success": true,
  "data": {...}
}
```

### Error Response (Webapp)
```json
{
  "success": false,
  "data": null,
  "errors": ["Error message"]
}
```

### Success Response (Consensus)
```json
{
  "Player": {...}
}
```

### Error Response (Consensus)
```json
{
  "code": 2,
  "message": "codespace structs code 1900: object not found",
  "details": []
}
```

---

## Common HTTP Status Codes

- **200** - Success
- **400** - Bad Request
- **404** - Not Found
- **429** - Rate Limit Exceeded
- **500** - Internal Server Error
- **503** - Service Unavailable

---

## Rate Limiting

**Default Limits**:
- Consensus Network: 60 requests/minute
- Web Application: 100 requests/minute
- RPC: 30 requests/minute

**Headers**:
- `X-RateLimit-Limit` - Maximum requests
- `X-RateLimit-Remaining` - Remaining requests
- `X-RateLimit-Reset` - Reset timestamp
- `Retry-After` - Seconds to wait (when rate limited)

**See**: `api/rate-limits.md` for complete details

---

## Error Handling

### Retryable Errors
- `500` - Internal Server Error
- `503` - Service Unavailable
- `429` - Rate Limit (with delay)
- Network errors
- Timeout errors

### Non-Retryable Errors
- `400` - Bad Request
- `404` - Not Found
- `401` - Unauthorized (re-authenticate)
- `403` - Forbidden

**See**: `api/error-codes.md` for complete error catalog

---

## Streaming (GRASS/NATS)

### Subject Patterns

**Player Events**: `structs.player.*`  
**Guild Events**: `structs.guild.*`  
**Planet Events**: `structs.planet.*`  
**Struct Events**: `structs.struct.*`  
**Fleet Events**: `structs.fleet.*`  
**Global Events**: `structs.global`

### Event Categories

- **Consensus**: `block`
- **Guild**: `guild_consensus`, `guild_meta`, `guild_membership`
- **Planet**: `raid_status`, `planet_activity` (includes `struct_health` details), `fleet_arrive`, `fleet_advance`, `fleet_depart`
- **Struct**: `struct_status`, `struct_move`, `struct_attack`, `struct_block_build_start`
- **Player**: `player_consensus`, `player_meta`

**See**: `protocols/streaming.md` for complete documentation

---

## Authentication

### Web Application (Session-Based)

**Login**:
```
POST /api/auth/login
Body: {"username": "...", "password": "..."}
Response: Set-Cookie header with session
```

**Authenticated Request**:
```
GET /api/guild/this
Headers: {"Cookie": "PHPSESSID=..."}
```

### Consensus Network (Transaction Signing)

**Process**:
1. Get account info
2. Create transaction
3. Sign with private key
4. Submit transaction

**See**: `protocols/authentication.md` for complete documentation

---

## Pagination

**Consensus Network**:
```
GET /structs/player?pagination.limit=10&pagination.offset=0
```

**Response**:
```json
{
  "Player": [...],
  "pagination": {
    "next_key": "...",
    "total": "100"
  }
}
```

---

## Common Patterns

### Get Player and Planets
1. `GET /api/player/{player_id}`
2. `GET /structs/planet_by_player/{playerId}`

**Pattern**: Linear Chain  
**See**: `examples/workflows/get-player-and-planets.md`

### Get Guild Stats
1. `GET /api/guild/{guild_id}`
2. `GET /api/guild/{guild_id}/members/count` (parallel)
3. `GET /api/guild/{guild_id}/power/stats` (parallel)

**Pattern**: Parallel with Dependency  
**See**: `examples/workflows/query-guild-stats.md`

### Monitor Planet Shield
1. `GET /api/planet/{planet_id}` (initial load)
2. Subscribe to `structs.planet.{id}` (streaming)

**Pattern**: Hybrid (Query + Streaming)  
**See**: `examples/workflows/monitor-planet-shield.md`

**See**: `examples/workflows/README.md` for complete workflow examples

### Install and Use Cosmetic Mod
1. `POST /api/cosmetic-mods/validate` - Validate mod (Phase 1 format)
2. `POST /api/cosmetic-mods/install` - Install mod (converts to Sets/Skins)
3. `GET /api/cosmetic-sets/{setHash}` - Verify set installation (if type is 'set')
4. `GET /api/cosmetic/class/{class}` - Get cosmetic skin data by class
5. `GET /api/struct-type/{id}/full?class={class}` - Get merged data (alternative)

**See**: `examples/workflows/install-and-use-cosmetic-mod.md` for complete workflow

**Note**: Mods (Phase 1) are converted to Sets/Skins (Phases 2-4) during ingestion. Use `setHash`/`skinHash` for management and `class` for cosmetic queries.

---

## Schema References

**Request Schemas**: `schemas/requests.md`  
**Response Schemas**: `schemas/responses.md`  
**Entity Schemas**: `schemas/entities.md`  
**Error Schemas**: `schemas/errors.md`

---

## Documentation Files

**Protocols**:
- `protocols/query-protocol.md` - Query API protocol
- `protocols/action-protocol.md` - Transaction protocol
- `protocols/webapp-api-protocol.md` - Webapp API protocol
- `protocols/streaming.md` - GRASS/NATS streaming
- `protocols/authentication.md` - Authentication
- `protocols/error-handling.md` - Error handling
- `protocols/testing-protocol.md` - Testing
- `protocols/cosmetic-mod-integration.md` - Cosmetic Sets/Skins integration

**API Documentation**:
- `api/endpoints.md` - Complete endpoint catalog
- `api/endpoints-by-entity.md` - Entity-based organization
- `api/error-codes.md` - Error code catalog
- `api/rate-limits.md` - Rate limiting
- `api/streaming/` - Streaming documentation
- `api/cosmetic-mods.md` - Cosmetic Sets/Skins API

**Examples**:
- `examples/workflows/` - Workflow examples
- `examples/errors/` - Error examples
- `examples/auth/` - Authentication examples

**Reference**:
- `reference/endpoint-index.md` - Endpoint index
- `reference/action-index.md` - Action index
- `reference/action-quick-reference.md` - Action quick reference
- `reference/api-quick-reference.md` - This file

---

## Patterns Reference

### Data Retrieval Patterns
- **Pagination**: `patterns/pagination.md` - Handle paginated responses
- **Caching**: `patterns/caching.md` - Cache API responses
- **Polling vs Streaming**: `patterns/polling-vs-streaming.md` - Choose data access method

### Error Handling Patterns
- **Rate Limiting**: `patterns/rate-limiting.md` - Handle rate limits
- **Retry Strategies**: `patterns/retry-strategies.md` - Retry failed requests

### Workflow Patterns
- **Workflow Patterns**: `patterns/workflow-patterns.md` - Multi-step operations
- **Workflow Examples**: `examples/workflows/README.md` - Complete examples

### Security Patterns
- **Security**: `patterns/security.md` - Security best practices

**See**: `patterns/README.md` for complete pattern catalog

---

## Quick Tips

1. **Always check response status** before processing
2. **Validate responses** against schemas
3. **Handle errors gracefully** with retry logic
4. **Respect rate limits** and use headers
5. **Cache responses** when possible
6. **Use appropriate authentication** for each API
7. **Test endpoints** before production use
8. **Monitor streaming events** for real-time updates
9. **Use patterns** for common scenarios (see Patterns Reference above)
10. **Follow workflow examples** for multi-step operations

---

*API Documentation Specialist - December 7, 2025*

