# Fleet Entity Schema

**Version**: 1.0.0
**Category**: core
**Entity**: Fleet
**Endpoint**: `/structs/fleet/{id}`

---

## Fleet Core Data

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^9-[0-9]+$` | Yes | Unique fleet identifier in format `type-index` (e.g., `9-11` for fleet type 9, index 11). Type 9 = Fleet. |
| owner | string | entity-id | `^1-[0-9]+$` | Yes | Player ID who owns this fleet. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| planetId | string | entity-id | `^2-[0-9]+$` | No | Planet ID where fleet is located, empty string if away. Format: `type-index` (e.g., `2-1` for planet type 2, index 1). Type 2 = Planet. |
| status | string | | | No | Fleet status (see Status Values below) |

## Fleet Structs

The `structs` field is an array of struct IDs belonging to this fleet. Each entry is an entity-id string matching pattern `^5-[0-9]+$` (e.g., `5-42` for struct type 5, index 42).

## Status Values

| Status | Description |
|--------|-------------|
| onStation | Fleet at planet, can build on planets |
| away | Fleet away from planet, cannot build on planets |

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| owner | Player | [player.md](player.md) |
| planet | Planet | [planet.md](planet.md) |
| structs | Struct | [struct.md](struct.md) |

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Code Reference | `x/structs/types/fleet.pb.go`, `x/structs/keeper/fleet_cache.go` |
| Verified Fields | id, owner, status, canMove |

API response schema. Status values verified. For code-based field definitions with movement requirements, see `schemas/entities.md#fleet`.
