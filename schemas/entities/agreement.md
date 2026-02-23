# Agreement Entity Schema

**Version**: 1.0.0
**Category**: economic
**Entity**: Agreement
**Endpoint**: `/structs/agreement/{id}`

---

## Description

Agreement entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^11-[0-9]+$` | Yes | Unique agreement identifier in format `type-index` (e.g., `11-1` for agreement type 11, index 1). Type 11 = Agreement. |
| providerId | string | entity-id | `^10-[0-9]+$` | Yes | Provider ID for this agreement. Format: `type-index` (e.g., `10-1` for provider type 10, index 1). Type 10 = Provider. |
| consumerId | string | entity-id | `^1-[0-9]+$` | Yes | Consumer (player) ID for this agreement. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| gridAttributes | object | -- | -- | No | Grid position and attributes. Accepts additional properties. |

## Relationships

| Relationship | Entity | Schema |
|-------------|--------|--------|
| provider | Provider | [schemas/entities/provider.md](provider.md) |
| consumer | Player | [schemas/entities/player.md](player.md) |

## Verification

| Attribute | Value |
|-----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |

**Verified Fields**: `id`, `providerId`, `consumerId`

**Missing Fields**: `allocationId`, `capacity`, `startBlock`, `endBlock`, `creator`, `owner`

**Code Reference**: `x/structs/types/agreement.pb.go`, `x/structs/keeper/agreement_cache.go`

**Database Reference**: `structs.agreement` table (columns: `id`, `provider_id`, `allocation_id`, `capacity`, `start_block`, `end_block`, `creator`, `owner`)

**Note**: API response schema. Missing fields from database (`allocationId`, `capacity`, `startBlock`, `endBlock`, `creator`, `owner`) -- these may be in gridAttributes or separate queries. For code-based field definitions, see `schemas/entities.md#agreement`.
