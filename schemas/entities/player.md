# Player Entity Schema

**Version**: 1.0.0
**Category**: core
**Entity**: Player
**Endpoint**: `/structs/player/{id}`
**Source**: `schemas/game-state.md#player`
**Minimal Schema**: `schemas/minimal/player-essential.md`

---

## Player Core Data

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^1-[0-9]+$` | Yes | Unique player identifier in format `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| index | string | | | Yes | Player index number |
| guildId | string | entity-id | `^0-[0-9]+$` | No | Guild ID if player is a member, empty string if not. Format: `type-index` (e.g., `0-1` for guild type 0, index 1). Type 0 = Guild. |
| substationId | string | entity-id | `^4-[0-9]+$` | No | Substation ID if connected, empty string if not. Format: `type-index` (e.g., `4-3` for substation type 4, index 3). Type 4 = Substation. |
| creator | string | blockchain-address | | Yes | Blockchain address that created this player |
| primaryAddress | string | blockchain-address | | Yes | Primary blockchain address for this player |
| planetId | string | entity-id | `^2-[0-9]+$` | No | Planet ID if player owns a planet, empty string if not. Format: `type-index` (e.g., `2-1` for planet type 2, index 1). Type 2 = Planet. |
| fleetId | string | entity-id | `^9-[0-9]+$` | No | Fleet ID if player owns a fleet, empty string if not. Format: `type-index` (e.g., `9-11` for fleet type 9, index 11). Type 9 = Fleet. |

## Grid Attributes

Grid position and resource attributes. All values are string representations of integers.

| Field | Description |
|-------|-------------|
| ore | Current ore amount |
| fuel | Current fuel amount |
| capacity | Total capacity |
| load | Current load |
| structsLoad | Load from structs |
| power | Current power/energy |
| connectionCapacity | Connection capacity |
| connectionCount | Number of connections |
| allocationPointerStart | Start of allocation pointer |
| allocationPointerEnd | End of allocation pointer |
| proxyNonce | Proxy nonce value |
| lastAction | Last action timestamp or block |
| nonce | Nonce value |
| ready | Ready status (0 = not ready, 1 = ready) |
| checkpointBlock | Checkpoint block height |

## Player Inventory

| Field | Type | Description |
|-------|------|-------------|
| rocks | object | Rock inventory -- maps struct type IDs to counts (string representations of integers) |

## Additional Properties

| Field | Type | Description |
|-------|------|-------------|
| halted | boolean | Whether player is halted (cannot perform actions) |

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| guildId | Guild | [guild.md](guild.md) |
| substationId | Substation | substation schema |
| planetId | Planet | [planet.md](planet.md) |
| fleetId | Fleet | [fleet.md](fleet.md) |

## Loading Strategy

**When to load:**

- Need complete Player entity data
- Working with player resources (ore, fuel, power)
- Checking player inventory
- Verifying player state for actions

**When not to load:**

- Simple existence check (use minimal schema instead)
- ID format verification (use `schemas/formats.md` instead)
- Basic status check (use minimal schema instead)

**Related schemas:**

- `schemas/minimal/player-essential.md`
- [planet.md](planet.md)
- [fleet.md](fleet.md)
- [guild.md](guild.md)

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | api-response-verification |
| Confidence | high |
| Code Reference | `x/structs/types/player.pb.go` |
| API Reference | `ai/api/queries/player.md` |

API response schema verified against actual API responses. For code-based field definitions with formulas, see `schemas/entities.md#player`.
