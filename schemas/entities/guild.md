# Guild Entity Schema

**Version**: 1.0.0
**Category**: social
**Entity**: Guild
**Endpoint**: `/structs/guild/{id}`

---

## Guild Core Data

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^0-[0-9]+$` | Yes | Unique guild identifier in format `type-index` (e.g., `0-1` for guild type 0, index 1). Type 0 = Guild. |
| creator | string | blockchain-address | | Yes | Blockchain address that created this guild |
| entrySubstationId | string | entity-id | `^4-[0-9]+$` | No | Entry substation ID for guild. Format: `type-index` (e.g., `4-3` for substation type 4, index 3). Type 4 = Substation. |
| joinInfusionMinimum | string | | | No | Minimum infusion required to join (string representation of integer) |
| entryInfusion | string | | | No | Entry infusion amount (string representation of integer) |

## Members

The `members` field is an array of player IDs who belong to this guild. Each entry is an entity-id string matching pattern `^1-[0-9]+$` (e.g., `1-11` for player type 1, index 11).

## Relationships

| Relation | Entity | Schema |
|----------|--------|--------|
| members | Player | [player.md](player.md) |
| entrySubstation | Substation | substation schema |

## Known Missing Fields

The following fields exist in the proto definition but are not yet captured in this schema. They may appear in gridAttributes or require separate queries:

- index
- endpoint
- owner
- primaryReactorId
- joinInfusionMinimumBypassByRequest
- joinInfusionMinimumBypassByInvite

## Verification

| Property | Value |
|----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Code Reference | `proto/structs/structs/guild.proto`, `x/structs/keeper/guild_cache.go` |
| Database Reference | `structs.guild` table |
| Verified Fields | id, creator, entrySubstationId, joinInfusionMinimum |

API response schema. Missing some fields from proto (see Known Missing Fields above). For code-based field definitions, see `schemas/entities.md#guild`.
