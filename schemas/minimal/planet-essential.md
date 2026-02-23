# Planet Essential Schema

**Version**: 1.0.0
**Category**: core
**Minimal**: Yes
**Complete Schema**: [schemas/entities/planet.md](../entities/planet.md)

---

## Description

Minimal planet schema for simple lookups and basic operations. Use this for ID format checks, existence verification, and basic ownership queries. For complete planet data, use the full [Planet entity schema](../entities/planet.md).

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^2-[0-9]+$` | Yes | Planet identifier in format `type-index` (e.g., `2-1` for planet type 2, index 1). |
| owner | string | entity-id | `^1-[0-9]+$` | No | Player ID who owns this planet, empty string if unowned. |
| maxOre | string | -- | -- | Yes | Maximum ore capacity (string representation of integer, typically `5`). |
| spaceSlots | string | -- | -- | No | Number of space slots (string representation of integer, typically `4`). |
| airSlots | string | -- | -- | No | Number of air slots (string representation of integer, typically `4`). |
| landSlots | string | -- | -- | No | Number of land slots (string representation of integer, typically `4`). |
| waterSlots | string | -- | -- | No | Number of water slots (string representation of integer, typically `4`). |

## Use Cases

- Check if planet exists
- Verify planet ID format
- Check planet ownership
- Get basic planet properties (slots, max ore)
- Quick planet lookup

## When to Use

Use this schema for simple operations that don't require full planet data (slot contents, attributes, structs, etc.).

## When Not to Use

Don't use this schema if you need: slot contents (space/air/land/water arrays), planet attributes, structs on planet, or any detailed planet state.
