# Struct Entity Schema

**Version**: 1.1.0
**Category**: core
**Entity**: Struct
**Endpoint**: `/structs/struct/{id}`
**Last Updated**: 2026-01-01

---

## Struct Core Data

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^5-[0-9]+$` | Yes | Unique struct identifier in format `type-index` (e.g., `5-42` for struct type 5, index 42). Type 5 = Struct. |
| owner | string | entity-id | `^1-[0-9]+$` | Yes | Player ID who owns this struct. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| structType | string | struct-type-id | | Yes | Struct type ID (references a StructType definition) |
| locationType | integer | | `1` or `2` | Yes | Location type: `1` = planet, `2` = fleet |
| locationId | string | | | Yes | Location ID (planet ID or fleet ID depending on locationType) |
| destroyed | boolean | | | No | Whether the struct has been destroyed (v0.8.0-beta). Destroyed structs persist for StructSweepDelay (5 blocks) before being fully removed. |

### Destroyed Field (v0.8.0-beta)

- Database column `struct.destroyed` added 2025-12-29
- Related: StructSweepDelay (5 blocks) -- destroyed structs persist for 5 blocks before slot clearing

## Grid Attributes

Grid position and resource attributes. Accepts additional properties of any structure.

## Status Values

| Value | Meaning |
|-------|---------|
| 1 | materialized |
| 2 | built |
| 3 | online |

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| owner | Player | [player.md](player.md) |
| structType | StructType | [struct-type.md](struct-type.md) |
| location (planet) | Planet | [planet.md](planet.md) |
| location (fleet) | Fleet | [fleet.md](fleet.md) |

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2026-01-01 |
| Method | code-analysis |
| Confidence | high |
| Code Reference | `x/structs/types/struct.pb.go`, `x/structs/keeper/struct_cache.go` |
| Verified Fields | id, owner, structType, locationType, status |

API response schema. For code-based field definitions with power draw, charge costs, and formulas, see `schemas/entities.md#struct`.
