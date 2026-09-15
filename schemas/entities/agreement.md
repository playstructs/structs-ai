---
description: "The Agreement entity schema: chain proto fields (id, provider, allocation, capacity, blocks, owner) and matching webapp columns."
---

# Agreement Entity Schema

**Version**: 1.0.0
**Category**: economic
**Entity**: Agreement
**Endpoint**: `/structs/agreement/{id}`

---

## Description

Agreement entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties (consensus / chain shape)

Proto `Agreement` (`agreement.proto`): `id`, `providerId`, `allocationId`, `capacity`, `startBlock`, `endBlock`, `creator`, `owner`. There is **no** `consumerId` on chain.

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^11-[0-9]+$` | Yes | Unique agreement identifier. Type 11 = Agreement. |
| providerId | string | entity-id | `^10-[0-9]+$` | Yes | Provider ID. Type 10 = Provider. |
| allocationId | string | entity-id | `^6-[0-9]+$` | Yes | Backing allocation. Type 6 = Allocation. |
| capacity | string | integer-string | `^[0-9]+$` | Yes | Contracted capacity (milliwatts as a string). |
| startBlock | string | integer-string | | Yes | Start block |
| endBlock | string | integer-string | | Yes | End block |
| creator | string | player-id | `^1-[0-9]+$` | Yes | Creating player |
| owner | string | player-id | `^1-[0-9]+$` | Yes | Owning player |

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
| owner / creator | Player | [schemas/entities/player.md](player.md) |
| allocation | Allocation | [schemas/entities/allocation.md](allocation.md) |

## Verification

| Attribute | Value |
|-----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-01 |
| Method | code-analysis |
| Confidence | high |

**Verified Fields**: `id`, `providerId`, `allocationId`, `capacity`, `startBlock`, `endBlock`, `creator`, `owner`

**Code Reference**: `x/structs/types/agreement.pb.go`, `x/structs/keeper/agreement_cache.go`

**Database Reference**: `structs.agreement` table (columns: `id`, `provider_id`, `allocation_id`, `capacity`, `start_block`, `end_block`, `creator`, `owner`)

**Note**: Chain and webapp share the same fields (camelCase vs snake_case). For code-based field definitions, see `schemas/entities.md#agreement`.
