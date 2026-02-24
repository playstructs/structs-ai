# Struct Entity Schema

**Version**: 1.3.0
**Category**: core
**Entity**: Struct
**Endpoint**: `/structs/struct/{id}`
**Last Updated**: 2026-02-24

---

## Struct Core Data

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^5-[0-9]+$` | Yes | Unique struct identifier in format `type-index` (e.g., `5-42` for struct type 5, index 42). Type 5 = Struct. |
| owner | string | entity-id | `^1-[0-9]+$` | Yes | Player ID who owns this struct. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| structType | string | struct-type-id | | Yes | Struct type ID (references a StructType definition) |
| locationType | integer | | `1` or `2` | Yes | Location type: `1` = planet, `2` = fleet |
| locationId | string | | | Yes | Location ID (planet ID or fleet ID depending on locationType) |
| destroyed | boolean | | | No | Whether the struct has been destroyed. Database column: `is_destroyed` (default false). Destroyed structs persist for StructSweepDelay (5 blocks) before being fully removed. |
| destroyedBlock | integer | | | No | Block height at which the struct was destroyed. Database column: `destroyed_block` (bigint). Only set when `destroyed` is true. |

### Destroyed Fields

- Database column `struct.is_destroyed` (boolean, default false)
- Database column `struct.destroyed_block` (bigint)
- StructSweepDelay (5 blocks) -- destroyed structs persist for 5 blocks before slot clearing
- `destroyed_block` enables precise timing of destruction events for activity feeds and replay

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
| Verified By | GameCodeAnalyst + DB verification |
| Verified Date | 2026-02-24 |
| Method | code-analysis + direct database inspection |
| Confidence | high |
| Code Reference | `x/structs/types/struct.pb.go`, `x/structs/keeper/struct_cache.go` |
| DB Reference | `structs.struct` table (13 columns verified against live database) |
| Verified Fields | id, index, type, creator, owner, location_type, location_id, operating_ambit, slot, is_destroyed, destroyed_block |

API response schema. For code-based field definitions with power draw, charge costs, and formulas, see `schemas/entities.md#struct`.
