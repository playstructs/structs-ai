# Allocation Entity Schema

**Version**: 1.0.0
**Category**: economic
**Entity**: Allocation
**Endpoint**: `/structs/allocation/{id}`

---

## Description

Allocation entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^6-[0-9]+$` | Yes | Unique allocation identifier in format `type-index` (e.g., `6-1` for allocation type 6, index 1). Type 6 = Allocation. |
| sourceId | string | -- | -- | Yes | Source ID (reactor, provider, etc.). |
| destinationId | string | -- | -- | Yes | Destination ID (player, struct, etc.). |
| amount | string | -- | -- | Yes | Allocation amount (string representation of integer). |
| gridAttributes | object | -- | -- | No | Grid position and attributes. Accepts additional properties. |

## Relationships

Allocations link a source entity to a destination entity. Both source and destination can be different entity types.

### Source

| Entity | Schema |
|--------|--------|
| Reactor | [schemas/entities/reactor.md](reactor.md) |
| Provider | [schemas/entities/provider.md](provider.md) |

### Destination

| Entity | Schema |
|--------|--------|
| Player | [schemas/entities/player.md](player.md) |
| Struct | [schemas/entities/struct.md](struct.md) |

## Verification

| Attribute | Value |
|-----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |

**Verified Fields**: `id`, `sourceId`, `destinationId`, `amount`

**Missing Fields**: `allocationType`, `controller`, `locked`

**Code Reference**: `x/structs/types/allocation.pb.go`, `x/structs/keeper/allocation_cache.go`

**Database Reference**: `structs.allocation` table (columns: `id`, `allocation_type`, `source_id`, `destination_id`, `controller`, `locked`)

**Note**: API response schema. Missing fields from database (`allocationType`, `controller`, `locked`) -- these may be in gridAttributes or separate queries. For code-based field definitions, see `schemas/entities.md#allocation`.
