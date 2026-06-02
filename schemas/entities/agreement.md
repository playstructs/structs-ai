# Agreement Entity Schema

**Version**: 1.0.0
**Category**: economic
**Entity**: Agreement
**Endpoint**: `/structs/agreement/{id}`

---

## Description

Agreement entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties (consensus / chain shape)

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^11-[0-9]+$` | Yes | Unique agreement identifier in format `type-index` (e.g., `11-1` for agreement type 11, index 1). Type 11 = Agreement. |
| providerId | string | entity-id | `^10-[0-9]+$` | Yes | Provider ID for this agreement. Format: `type-index` (e.g., `10-1` for provider type 10, index 1). Type 10 = Provider. |
| consumerId | string | entity-id | `^1-[0-9]+$` | Yes | Consumer (player) ID. **Chain-only** — does not appear in the webapp catalog row. Format: `type-index`. Type 1 = Player. |
| gridAttributes | object | -- | -- | No | Grid position and attributes. Accepts additional properties. |

## Webapp catalog columns (`structs.agreement`)

The webapp HTTP API (`TableReadManager`) returns these raw snake_case columns directly in the response `data`. Note there is **no `consumer_id` and no `guild_id`** on the webapp row — do not filter agreements by guild at this layer (see `api/webapp/agreement.md` for guild scoping via substation → provider).

| Column | Description |
|--------|-------------|
| `id` | Agreement identifier |
| `provider_id` | Supplying provider |
| `allocation_id` | Backing allocation |
| `capacity` | Contracted capacity |
| `start_block` / `end_block` | Active block window |
| `creator` | Creating player |
| `owner` | Owning player |
| `created_at` / `updated_at` | Timestamps |

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
