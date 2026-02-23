# API Endpoint Quick Lookup

**Version**: 1.0.0
**Category**: reference
**Description**: Quick lookup table for common API endpoints by use case

---

## Entity Lookups (Consensus vs Webapp)

### getPlayer

| API | Endpoint ID | Method | Path | Full URL |
|-----|-------------|--------|------|----------|
| Consensus | player-by-id | GET | `/structs/player/{id}` | `http://localhost:1317/structs/player/{id}` |
| Webapp | webapp-player-by-id | GET | `/api/player/{player_id}` | `http://localhost:8080/api/player/{player_id}` |

### getPlanet

| API | Endpoint ID | Method | Path | Full URL |
|-----|-------------|--------|------|----------|
| Consensus | planet-by-id | GET | `/structs/planet/{id}` | `http://localhost:1317/structs/planet/{id}` |
| Webapp | webapp-planet-by-id | GET | `/api/planet/{planet_id}` | `http://localhost:8080/api/planet/{planet_id}` |

### getGuild

| API | Endpoint ID | Method | Path | Full URL |
|-----|-------------|--------|------|----------|
| Consensus | guild-by-id | GET | `/structs/guild/{id}` | `http://localhost:1317/structs/guild/{id}` |
| Webapp | webapp-guild-by-id | GET | `/api/guild/{guild_id}` | `http://localhost:8080/api/guild/{guild_id}` |

### getStruct

| API | Endpoint ID | Method | Path | Full URL |
|-----|-------------|--------|------|----------|
| Consensus | struct-by-id | GET | `/structs/struct/{id}` | `http://localhost:1317/structs/struct/{id}` |
| Webapp | webapp-struct-by-id | GET | `/api/struct/{struct_id}` | `http://localhost:8080/api/struct/{struct_id}` |

---

## Consensus-Only Lookups

| Use Case | Endpoint ID | Method | Path | Full URL |
|----------|-------------|--------|------|----------|
| getPlayerPlanets | planet-by-player | GET | `/structs/planet_by_player/{playerId}` | `http://localhost:1317/structs/planet_by_player/{playerId}` |
| getBlockHeight | block-height | GET | `/blockheight` | `http://localhost:1317/blockheight` |
| submitTransaction | submit-transaction | POST | `/cosmos/tx/v1beta1/txs` | `http://localhost:1317/cosmos/tx/v1beta1/txs` |

> **submitTransaction** requires transaction signing (authentication required).

---

## Webapp-Only Lookups

| Use Case | Endpoint ID | Method | Path | Full URL |
|----------|-------------|--------|------|----------|
| getPlanetShield | webapp-planet-shield-health | GET | `/api/planet/{planet_id}/shield/health` | `http://localhost:8080/api/planet/{planet_id}/shield/health` |
| getGuildMembers | webapp-guild-member-count | GET | `/api/guild/{guild_id}/members/count` | `http://localhost:8080/api/guild/{guild_id}/members/count` |
| getGuildPower | webapp-guild-power-stats | GET | `/api/guild/{guild_id}/power/stats` | `http://localhost:8080/api/guild/{guild_id}/power/stats` |
| getPlayerOreStats | webapp-player-ore-stats | GET | `/api/player/{player_id}/ore/stats` | `http://localhost:8080/api/player/{player_id}/ore/stats` |
| getTimestamp | webapp-timestamp | GET | `/api/timestamp` | `http://localhost:8080/api/timestamp` |

---

## Streaming (GRASS/NATS)

| Use Case | Protocol | Address | Documentation |
|----------|----------|---------|---------------|
| connectNATS | NATS | `nats://localhost:4222` | [streaming.md](../protocols/streaming.md) |
| connectWebSocket | WebSocket | `ws://localhost:1443` | [streaming.md](../protocols/streaming.md) |

### Subscription Subjects

| Use Case | Subject Pattern | Example | Documentation |
|----------|----------------|---------|---------------|
| subscribePlayer | `structs.player.*` | `structs.player.0-1.1-11` | [subscription-patterns.md](../api/streaming/subscription-patterns.md) |
| subscribeGuild | `structs.guild.*` | `structs.guild.0-1` | [subscription-patterns.md](../api/streaming/subscription-patterns.md) |
| subscribePlanet | `structs.planet.*` | `structs.planet.3-1` | [subscription-patterns.md](../api/streaming/subscription-patterns.md) |

---

## Authentication

| Use Case | Endpoint ID | Method | Path | Full URL | Documentation |
|----------|-------------|--------|------|----------|---------------|
| webappLogin | webapp-auth-login | POST | `/api/auth/login` | `http://localhost:8080/api/auth/login` | [authentication.md](../protocols/authentication.md) |
| webappSignup | webapp-auth-signup | POST | `/api/auth/signup` | `http://localhost:8080/api/auth/signup` | [authentication.md](../protocols/authentication.md) |

---

## Error Codes

| Name | Code | Description |
|------|------|-------------|
| success | 0 | Operation succeeded |
| generalError | 1 | General error |
| insufficientFunds | 2 | Insufficient funds |
| invalidSignature | 3 | Invalid signature |
| insufficientGas | 4 | Insufficient gas |
| invalidMessage | 5 | Invalid message |
| playerHalted | 6 | Player is halted (offline) |
| insufficientCharge | 7 | Insufficient charge |
| invalidLocation | 8 | Invalid location |
| invalidTarget | 9 | Invalid target |
| badRequest | 400 | Bad request |
| notFound | 404 | Entity not found |
| rateLimitExceeded | 429 | Rate limit exceeded |
| internalServerError | 500 | Internal server error |
| serviceUnavailable | 503 | Service unavailable |

See: [error-codes.md](../api/error-codes.md)

---

## Rate Limits

| API | Requests/Minute | Requests/Hour |
|-----|-----------------|---------------|
| Consensus Network | 60 | 3,600 |
| Web Application | 100 | 6,000 |
| RPC | 30 | 1,800 |

See: [rate-limits.md](../api/rate-limits.md)

---

## Related Documentation

### Schemas

| Name | Path |
|------|------|
| Requests | [requests.md](../schemas/requests.md) |
| Responses | [responses.md](../schemas/responses.md) |
| Entities | [entities.md](../schemas/entities.md) |
| Errors | [errors.md](../schemas/errors.md) |
| Authentication | [authentication.md](../schemas/authentication.md) |

### Protocols

| Name | Path |
|------|------|
| Query | [query-protocol.md](../protocols/query-protocol.md) |
| Action | [action-protocol.md](../protocols/action-protocol.md) |
| Webapp | [webapp-api-protocol.md](../protocols/webapp-api-protocol.md) |
| Streaming | [streaming.md](../protocols/streaming.md) |
| Authentication | [authentication.md](../protocols/authentication.md) |
| Error Handling | [error-handling.md](../protocols/error-handling.md) |
| Testing | [testing-protocol.md](../protocols/testing-protocol.md) |

### Examples

| Name | Path |
|------|------|
| Workflows | `examples/workflows/` |
| Errors | `examples/errors/` |
| Auth | `examples/auth/` |
| Bots | `examples/*-bot.md` |
