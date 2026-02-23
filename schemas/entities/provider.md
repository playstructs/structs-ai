# Provider Entity Schema

**Version**: 1.0.0
**Category**: economic
**Entity**: Provider
**Endpoint**: `/structs/provider/{id}`

---

## Description

Provider entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^10-[0-9]+$` | Yes | Unique provider identifier in format `type-index` (e.g., `10-1` for provider type 10, index 1). Type 10 = Provider. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Yes | Player who owns this provider. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
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

**Missing Fields**: `substationId`, `rateAmount`, `rateDenom`, `accessPolicy`, `capacityMinimum`, `capacityMaximum`, `durationMinimum`, `durationMaximum`, `providerCancellationPenalty`, `consumerCancellationPenalty`

**Code Reference**: `x/structs/types/provider.pb.go`, `x/structs/keeper/provider_cache.go`

**Database Reference**: `structs.provider` table (columns: `id`, `substation_id`, `rate_amount`, `rate_denom`, `access_policy`, `capacity_minimum`, `capacity_maximum`, `duration_minimum`, `duration_maximum`, `provider_cancellation_penalty`, `consumer_cancellation_penalty`)

**Note**: API response schema. Missing many fields from database (`substationId`, `rateAmount`, `rateDenom`, `accessPolicy`, `capacityMinimum`, `capacityMaximum`, `durationMinimum`, `durationMaximum`, `cancellationPenalties`) -- these may be in gridAttributes or separate queries. For code-based field definitions, see `schemas/entities.md#provider`.
