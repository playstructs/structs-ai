# Reactor Entity Schema

**Version**: 1.1.0
**Category**: resource
**Entity**: Reactor
**Endpoint**: `/structs/reactor/{id}`

---

## Description

Reactor entity definition -- extracted from game-state.json for context window optimization. See `schemas/formats.md` for format specifications.

## Properties

| Field | Type | Format | Pattern | Required | Description |
|-------|------|--------|---------|----------|-------------|
| id | string | entity-id | `^3-[0-9]+$` | Yes | Unique reactor identifier in format `type-index` (e.g., `3-1` for reactor type 3, index 1). Type 3 = Reactor. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Yes | Player who owns this reactor. Format: `type-index` (e.g., `1-11` for player type 1, index 11). Type 1 = Player. |
| gridAttributes | object | -- | -- | No | Grid position and attributes. Accepts additional properties. |
| validator | string | blockchain-address | -- | No | Validator address for validation delegation (if staked). |
| guildId | string | entity-id | `^0-[0-9]+$` | No | Guild ID associated with this reactor (if applicable). Format: `type-index` (e.g., `0-1` for guild type 0, index 1). Type 0 = Guild. |
| defaultCommission | string | -- | -- | No | Default commission rate for this reactor (string representation). |

### Staking

Reactor staking information, represented as a nested object.

| Field | Type | Values | Description |
|-------|------|--------|-------------|
| staked | boolean | -- | Whether this reactor has staked delegation. |
| delegationAmount | string | -- | Amount of delegation staked (string representation). |
| delegationStatus | string | `active`, `undelegating`, `migrating` | Current delegation status. `active` = actively delegated, `undelegating` = in undelegation period, `migrating` = in migration/redelegation process. |

## Relationships

| Relationship | Entity | Schema |
|-------------|--------|--------|
| owner | Player | [schemas/entities/player.md](player.md) |
| guild | Guild | [schemas/entities/guild.md](guild.md) |

## Verification

| Attribute | Value |
|-----------|-------|
| Verified | Yes |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Version | 1.1.0 |

**Verified Fields**: `id`, `ownerId`, `validator`, `guildId`, `defaultCommission`, `staking`

**Code Reference**: `x/structs/types/reactor.pb.go`, `x/structs/keeper/reactor_cache.go`

**Database Reference**: `structs.reactor` table (columns: `id`, `validator`, `guild_id`, `default_commission`)

**Note**: API response schema. Reactor staking is managed at player level. Validation delegation is abstracted via Reactor Infuse/Defuse actions. For code-based field definitions, see `schemas/entities.md#reactor`.
