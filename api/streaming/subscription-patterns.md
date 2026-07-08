# Subscription Patterns

**Version**: 1.1.0
**Last Updated**: 2026-07-07
**Description**: Subscription patterns for GRASS/NATS streaming

---

## Connection Types

| Protocol | URL | Use Case |
|----------|-----|----------|
| NATS | `nats://localhost:4222` | Server-side applications, bots, automated systems (recommended) |
| WebSocket | `ws://localhost:1443` | Browser applications, WebSocket-only clients (requires NATS server WebSocket support) |

---

## Patterns

> **Subjects carry the owner `player_id`, and NATS `*` matches exactly one token.** Grid and planet subjects end with the owning player id (`structs.grid.{object_type}.{object_id}.{player_id}`, `structs.planet.{planet_id}.{player_id}`; `noPlayer` when unresolved) as of 2026-07-07. The player subject is `structs.player.{guild_id}.{player_id}`. Match a variable trailing segment with a per-token `*` or the multi-token `>` — e.g. `structs.planet.3-1.*` (one planet, any owner), `structs.planet.>` (all planets), `structs.player.>` (all players). A bare `structs.planet.*` no longer matches anything.

### Subscribe to Player Updates

- **Subject**: `structs.player.>`
- **Example subject**: `structs.player.0-1.1-11`
- **Wildcard**: Yes

**Events**:

| Type | Schema |
|------|--------|
| player_consensus | `event-schemas.md#PlayerConsensusEvent` |

```json
// Subscribe:
{
  "action": "subscribe",
  "subject": "structs.player.>"
}

// Received message:
{
  "subject": "structs.player.0-1.1-11",
  "category": "player_consensus",
  "id": "1-11",
  "updated_at": "2025-01-01T00:00:00Z",
  "data": {
    "id": "1-11",
    "guildId": "0-1",
    "primaryAddress": "cosmos1..."
  }
}
```

### Subscribe to Guild Updates

- **Subject**: `structs.guild.*`
- **Example subject**: `structs.guild.0-1`
- **Wildcard**: Yes

**Events**:

| Type | Schema |
|------|--------|
| guild_consensus | `event-schemas.md#GuildConsensusEvent` |
| guild_meta | `event-schemas.md#GuildMetaEvent` |
| guild_membership | `event-schemas.md#GuildMembershipEvent` |

```json
// Subscribe:
{
  "action": "subscribe",
  "subject": "structs.guild.0-1"
}
```

### Subscribe to Planet Updates

- **Subject**: `structs.planet.3-1.*` (one planet, any owner) or `structs.planet.>` (all)
- **Example subject**: `structs.planet.3-1.1-11`
- **Wildcard**: Yes — note the trailing `player_id` segment

**Events**:

| Type | Schema |
|------|--------|
| raid_status | `event-schemas.md#PlanetRaidStatusEvent` |
| fleet_arrive | `event-schemas.md#FleetArriveEvent` |

```json
// Subscribe (trailing * matches the owner player_id segment):
{
  "action": "subscribe",
  "subject": "structs.planet.3-1.*"
}
```

### Subscribe to Multiple Entities

Subscribe to multiple entity types on a single connection.

**Subscriptions**:

| Subject | Description |
|---------|-------------|
| `structs.player.0-1.1-11` | Specific player |
| `structs.planet.3-1.*` | Specific planet (any owner) |
| `structs.guild.0-1` | Specific guild |

```json
// Subscribe to multiple:
[
  {
    "action": "subscribe",
    "subject": "structs.player.0-1.1-11"
  },
  {
    "action": "subscribe",
    "subject": "structs.planet.3-1.*"
  },
  {
    "action": "subscribe",
    "subject": "structs.guild.0-1"
  }
]
```

### Subscribe to Global Updates

- **Subject**: `structs.global`

**Events**:

| Type | Schema |
|------|--------|
| block | `event-schemas.md#BlockEvent` |

```json
// Subscribe:
{
  "action": "subscribe",
  "subject": "structs.global"
}
```

---

## Best Practices

| Practice | Description | Recommendation |
|----------|-------------|----------------|
| Use wildcards for discovery | Start with wildcard subscriptions to discover available events | `structs.player.>` |
| Narrow to specific subjects | Once you know what you need, subscribe to specific subjects | `structs.player.0-1.1-11` |
| Mind the token count | `*` matches one token, `>` matches the rest; grid/planet subjects end in `player_id` | `structs.planet.3-1.*`, not `structs.planet.3-1` |
| Limit subscriptions | Limit active subscriptions to avoid overwhelming your client | Maximum 10-20 concurrent subscriptions per connection |
| Implement reconnection | Implement automatic reconnection with exponential backoff | See reconnection config below |
| Validate messages | Validate all incoming messages against schemas | Use JSON Schema validation for all event payloads |
| Handle errors gracefully | Implement error handling for connection failures and invalid messages | Log errors, implement retry logic, handle edge cases |

### Reconnection Configuration

```json
{
  "reconnect": {
    "enabled": true,
    "maxAttempts": 10,
    "initialDelay": 1000,
    "maxDelay": 60000,
    "backoffMultiplier": 2
  }
}
```

---

## Related Documentation

- `api/streaming/event-types.md` - Event type definitions
- `api/streaming/event-schemas.md` - Event schema definitions
- `protocols/streaming.md` - Streaming protocol
- `api/streaming/README.md` - Streaming overview
