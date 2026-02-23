# Simple Bot Example

**Version**: 1.0.0
**Category**: Bot Implementation
**Purpose**: Monitor player state and perform basic actions

---

## Overview

SimpleBot is a minimal bot implementation for Structs that demonstrates core patterns: periodic state monitoring and conditional action execution. It polls game state on a fixed interval and builds structs when resource thresholds are met.

## Configuration

The bot connects to the consensus network API and operates on behalf of a single player. Actions can be individually enabled or disabled.

```json
{
  "baseUrl": "http://localhost:1317",
  "playerId": "1",
  "updateFrequency": 10000,
  "actions": {
    "enabled": ["monitor", "build"],
    "disabled": ["attack", "raid"]
  }
}
```

## Bot State

The bot maintains local state that is refreshed each monitoring cycle:

| Field | Type | Description |
|-------|------|-------------|
| `blockHeight` | number | Current chain block height |
| `lastSyncTime` | number | Timestamp of last state sync |
| `player` | object | Player entity data |
| `planets` | array | Player's planets |
| `structs` | array | Player's structs |

## Behaviors

### Monitor Game State

Runs every 10 seconds. Queries the chain for the player's current game state.

**Step 1** -- Query current block height:

```json
{
  "action": "query",
  "endpoint": "GET /blockheight",
  "store": "state.blockHeight"
}
```

**Step 2** -- Query player data:

```json
{
  "action": "query",
  "endpoint": "GET /structs/player/{playerId}",
  "store": "state.player"
}
```

**Step 3** -- Query player's planets:

```json
{
  "action": "query",
  "endpoint": "GET /structs/planet_by_player/{playerId}",
  "store": "state.planets"
}
```

**Step 4** -- Query player's structs (filtered by owner):

```json
{
  "action": "query",
  "endpoint": "GET /structs/struct",
  "filter": "ownerId == {playerId}",
  "store": "state.structs"
}
```

### Build Struct When Possible

Triggered when the player has sufficient resources. This is a two-step build process: initiate the build, then complete it with proof-of-work.

**Precondition checks** (abort if any fail):

1. Player must not be halted (`state.player.halted == false`)
2. Player must have at least 1,000,000 Alpha Matter
3. Player must own at least one planet

**Step 1** -- Submit build initiation transaction:

```json
{
  "action": "transaction",
  "type": "MsgStructBuild",
  "params": {
    "creator": "{playerAddress}",
    "structType": "1",
    "locationType": 1,
    "locationId": "{firstPlanetId}"
  }
}
```

**Step 2** -- Wait for transaction confirmation.

**Step 3** -- Query the new struct and wait until its state is `building`.

**Step 4** -- Compute proof-of-work for the struct.

**Step 5** -- Submit build completion transaction:

```json
{
  "action": "transaction",
  "type": "MsgStructBuildComplete",
  "params": {
    "creator": "{playerAddress}",
    "structId": "{structId}",
    "hash": "{proofOfWorkHash}",
    "nonce": "{proofOfWorkNonce}"
  }
}
```

## Error Handling

| Error | Action | Retry |
|-------|--------|-------|
| `404` (Not Found) | Log the error | No |
| `500` (Server Error) | Retry with exponential backoff | Up to 3 attempts |
| `PLAYER_HALTED` | Wait until the player comes online | N/A |
| `INSUFFICIENT_RESOURCES` | Wait until resources are available | N/A |

For retryable server errors, the bot uses exponential backoff starting at 1 second, doubling each attempt up to a maximum of 3 retries.

## Cross-References

- Action protocol: [protocols/action-protocol.md](../protocols/action-protocol.md)
- Entity schemas: [schemas/entities.md](../schemas/entities.md)
- Error handling patterns: [protocols/error-handling.md](../protocols/error-handling.md)
- Retry strategies: [patterns/retry-strategies.md](../patterns/retry-strategies.md)
