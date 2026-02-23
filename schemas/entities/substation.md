# Substation Entity Schema

**Version**: 1.0.0
**Category**: resource
**Entity**: Substation
**Endpoint**: `/structs/substation/{id}`

---

## Description

Substation entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^4-[0-9]+$` | Yes | Unique substation identifier in format `type-index` (e.g., `4-3` for substation type 4, index 3). Type 4 = Substation. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Yes | Player who owns this substation. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| gridAttributes | object | -- | -- | No | Grid position and attributes. Accepts additional properties. |

## Relationships

| Relationship | Entity | Schema |
|-------------|--------|--------|
| owner | Player | [schemas/entities/player.md](player.md) |

## Verification

| Attribute | Value |
|-----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |

**Verified Fields**: `id`, `ownerId`

**Missing Fields**: `creator`

**Code Reference**: `x/structs/types/substation.pb.go`, `x/structs/keeper/substation_cache.go`

**Database Reference**: `structs.substation` table (columns: `id`, `owner`, `creator`)

**Note**: API response schema. Missing field from database (`creator`) -- may be in gridAttributes or separate queries. For code-based field definitions, see `schemas/entities.md#substation`.
