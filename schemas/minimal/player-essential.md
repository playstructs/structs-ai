# Player Essential Schema

**Version**: 1.0.0
**Category**: core
**Minimal**: Yes
**Complete Schema**: [schemas/entities/player.md](../entities/player.md)

---

## Description

Minimal player schema for simple lookups and basic operations. Use this for ID format checks, existence verification, and basic status queries. For complete player data, use the full [Player entity schema](../entities/player.md).

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^1-[0-9]+$` | Yes | Player identifier in format `type-index` (e.g., `1-11` for player type 1, index 11). |
| index | string | -- | -- | Yes | Player index number. |
| guildId | string | entity-id | `^0-[0-9]+$` | No | Guild ID if player is a member, empty string if not. |
| planetId | string | entity-id | `^2-[0-9]+$` | No | Planet ID if player owns a planet, empty string if not. |
| fleetId | string | entity-id | `^9-[0-9]+$` | No | Fleet ID if player owns a fleet, empty string if not. |
| substationId | string | entity-id | `^4-[0-9]+$` | No | Substation ID if connected, empty string if not. |
| halted | boolean | -- | -- | No | Whether player is halted (cannot perform actions). |

## Use Cases

- Check if player exists
- Verify player ID format
- Check basic player status (halted, guild membership)
- Find player's planet/fleet/substation IDs
- Quick player lookup

## When to Use

Use this schema for simple operations that don't require full player data (grid attributes, inventory, power details, etc.).

## When Not to Use

Don't use this schema if you need: power capacity/load, ore/fuel amounts, inventory details, grid attributes, or any detailed player state.
