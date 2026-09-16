---
title: "structsd Chain Events | Structs AI"
description: "Cosmos and Tendermint events emitted by structsd: typed Event* messages, ugc_moderated, and how to subscribe."
permalink: /api/chain-events
---

# Chain events (Cosmos / Tendermint)

**Category**: api
**Verified against**: structsd `48686a9` (v0.21.0, 2026-08-19)
**Source**: `proto/structs/structs/events.proto` and keeper `EmitTypedEvent` sites

These are the events **structsd** writes onto the Tendermint ABCI log. They are not GRASS NATS messages and they are not Guild API `planet-activity` rows. Sync-state reads this log and *then* writes PostgreSQL; GRASS and the REST activity feed are that projection, not the original events.

| Job | Stream |
|------|--------|
| Full proto of an attack, raid, mint, infusion | This page — Tendermint `tx.events` |
| Audit a guild moderator rewrite of name/pfp | This page — untyped `ugc_moderated` |
| React live with a stubbed combat payload | [GRASS](streaming/event-types.md) |
| Page historical planet activity | [`/api/planet-activity`](webapp/planet-activity.md) |

Canonical proto: [playstructs/structsd `events.proto`](https://github.com/playstructs/structsd/blob/master/proto/structs/structs/events.proto). Combat shot fields: [integration-notes](integration-notes.md#struct_attack-event-detail-schema) and [combat.md](../knowledge/mechanics/combat.md). UGC attributes: [ugc-moderation.md](../knowledge/mechanics/ugc-moderation.md).

---

## How to subscribe

**Tendermint WebSocket**: `wss://public.testnet.structs.network:26657/websocket`

Typed gameplay events from message handlers land on **`tm.event='Tx'`**. `EventTime` is emitted from begin-blocker (`EmitEventTime`) and lands on **block events** (`tm.event='NewBlock'`), not on a tx.

After the fact, the same array is on `GET https://public.testnet.structs.network/cosmos/tx/v1beta1/txs/{hash}`.

Typed-event **`type` is the proto message name**. Verified in keeper tests: `structs.structs.EventAttack`. Subscribe to all txs and filter that type, or query the container attribute:

```json
{
  "jsonrpc": "2.0",
  "method": "subscribe",
  "id": 1,
  "params": {
    "query": "tm.event='Tx' AND structs.structs.EventAttack.eventAttackDetail EXISTS"
  }
}
```

`EventTime` uses `tm.event='NewBlock'` and `structs.structs.EventTime.eventTimeDetail EXISTS`. Parse with Cosmos `ParseTypedEvent` (or equivalent). Do not treat these as GRASS `category` strings.

Guild Stack `sync_state.raw_events` / `raw_attributes` only fill when `SYNC_STATE_MIRROR_RAW=true` (Compose default is `false`).

---

## Two emission styles

### Typed proto (`EmitTypedEvent`)

Almost every Structs gameplay event is a protobuf message. The proto wraps the payload in a **container** so the indexer stores one JSON blob rather than one ABCI attribute per field:

```
EventAttack { eventAttackDetail: { ... } }
EventDelete { objectId: "6-1" }   // single-field messages skip the wrapper
```

ABCI attributes are proto JSON: **camelCase** keys, `uint64` as **strings**. Nested objects (the attack shot array, a full `Player` record) sit under the container field name.

### Untyped (`sdk.NewEvent`)

`ugc_moderated` is an untyped Cosmos event (`x/structs/types/events_ugc.go`). Type string is exactly `ugc_moderated`. Attributes are snake_case strings.

Reactor infusion / defusion / migration / cancel-defusion also emit **Cosmos staking** events (`delegate`, `unbond`, `redelegate`, `cancel_unbonding_delegation`) on the same tx. IBC packet code emits `timeout`. Those are not Structs gameplay types; they ride along when those messages run.

---

## Catalog

`type` below is the Tendermint `event.Type` string (`structs.structs.` + message name), except `ugc_moderated`.

### Objects

Emitted when the keeper writes or deletes that entity. `EventDelete` is the generic tombstone (`objectId`).

| Proto | `type` | Payload |
|-------|--------|---------|
| `EventPlayer` | `structs.structs.EventPlayer` | [`player`](../schemas/entities/player.md) |
| `EventPlanet` | `structs.structs.EventPlanet` | [`planet`](../schemas/entities/planet.md) |
| `EventStruct` | `structs.structs.EventStruct` | [`structure`](../schemas/entities/struct.md) |
| `EventFleet` | `structs.structs.EventFleet` | [`fleet`](../schemas/entities/fleet.md) |
| `EventGuild` | `structs.structs.EventGuild` | [`guild`](../schemas/entities/guild.md) |
| `EventReactor` | `structs.structs.EventReactor` | [`reactor`](../schemas/entities/reactor.md) |
| `EventSubstation` | `structs.structs.EventSubstation` | [`substation`](../schemas/entities/substation.md) |
| `EventProvider` | `structs.structs.EventProvider` | [`provider`](../schemas/entities/provider.md) |
| `EventAllocation` | `structs.structs.EventAllocation` | [`allocation`](../schemas/entities/allocation.md) |
| `EventAgreement` | `structs.structs.EventAgreement` | [`agreement`](../schemas/entities/agreement.md) |
| `EventInfusion` | `structs.structs.EventInfusion` | [`infusion`](../schemas/entities/infusion.md) |
| `EventStructType` | `structs.structs.EventStructType` | [`structType`](../schemas/entities/struct-type.md) |
| `EventDelete` | `structs.structs.EventDelete` | [`objectId`](../knowledge/entities/entity-relationships.md#id-format) |

On block height 1 the keeper also **replays genesis** (`EventAllGenesis`) as the same typed events so an indexer can bootstrap without scanning history.

### Attributes, grid, permissions

| Proto | `type` | Payload |
|-------|--------|---------|
| `EventGrid` | `structs.structs.EventGrid` | [`gridRecord`](../knowledge/mechanics/energy.md) (`attributeId`, `value`) |
| `EventStructAttribute` | `structs.structs.EventStructAttribute` | [`structAttributeRecord`](integration-notes.md#where-struct-hp-and-status-live) |
| `EventPlanetAttribute` | `structs.structs.EventPlanetAttribute` | [`planetAttributeRecord`](../knowledge/mechanics/planet.md) |
| `EventStructDefender` | `structs.structs.EventStructDefender` | [`structDefender`](../knowledge/mechanics/combat.md#assigning-defenders-struct-defense-set) |
| `EventStructDefenderClear` | `structs.structs.EventStructDefenderClear` | [`structDefenderClearDetail.defendingStructId`](../knowledge/mechanics/combat.md#assigning-defenders-struct-defense-set) |
| `EventPermission` | `structs.structs.EventPermission` | [`permissionRecord`](../knowledge/mechanics/permissions.md) |
| `EventGuildRankPermission` | `structs.structs.EventGuildRankPermission` | [`guildRankPermissionRecord`](../knowledge/mechanics/permissions.md#guild-rank-permission-system) |

### Combat and raids

| Proto | `type` | When | Payload |
|-------|--------|------|---------|
| `EventAttack` | `structs.structs.EventAttack` | `struct-attack` resolves | [`eventAttackDetail`](integration-notes.md#struct_attack-event-detail-schema) — attacker block plus [`eventAttackShotDetail[]`](../knowledge/mechanics/combat.md#attack-resolution-sequence) (one row per projectile). Health before/after **are** on the proto. |
| `EventRaid` | `structs.structs.EventRaid` | Raid status transitions | `eventRaidDetail`: [`fleetId`](../schemas/entities/fleet.md), [`planetId`](../schemas/entities/planet.md), [`status`](../knowledge/mechanics/combat.md#raid-phases-and-shields_vulnerable) (`initiated`, `attackerDefeated`, `ongoing`, `raidSuccessful`, `demilitarized`, `attackerRetreated`, `shieldsVulnerable`), [`seized_ore`](../knowledge/mechanics/resources.md#the-ore-vulnerability-window) (proto JSON may also appear as `seizedOre`) |

GRASS `struct_attack` can be a **stub** (~8 KB NATS cap). The chain `EventAttack` is the full proto.

### Production and hashing

| Proto | `type` | When | Payload |
|-------|--------|------|---------|
| `EventOreMine` | `structs.structs.EventOreMine` | Ore miner complete | [`playerId`](../schemas/entities/player.md), [`primaryAddress`](queries/address.md), [`amount`](../knowledge/mechanics/resources.md) |
| `EventAlphaRefine` | `structs.structs.EventAlphaRefine` | Refinery complete | same shape ([`amount`](../knowledge/mechanics/resources.md#alpha-matter) is Alpha) |
| `EventAlphaInfuse` | `structs.structs.EventAlphaInfuse` | Generator or reactor infuse | [`playerId`](../schemas/entities/player.md), [`primaryAddress`](queries/address.md), [`amount`](../knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964) |
| `EventOreTheft` | `structs.structs.EventOreTheft` | Raid complete steals ore | victim / thief [`playerId`](../schemas/entities/player.md) and addresses, [`amount`](../knowledge/mechanics/resources.md#the-ore-vulnerability-window) |
| `EventOreMigrate` | `structs.structs.EventOreMigrate` | Primary address change | [`playerId`](../schemas/entities/player.md), new/old primary, [`amount`](../knowledge/mechanics/resources.md) |
| `EventHashSuccess` | `structs.structs.EventHashSuccess` | PoW complete | `callerAddress`, [`category`](../knowledge/mechanics/hashing.md) (`mine`, `refine`, `build`, `raid`, `guild_charter`), `difficulty`, [`objectId`](../knowledge/entities/entity-relationships.md#id-format); [`planetId`](../schemas/entities/planet.md) is set on raid completes |

### Guild bank

| Proto | `type` | Notes |
|-------|--------|--------|
| `EventGuildBankMint` | `structs.structs.EventGuildBankMint` | [`guildId`](../schemas/entities/guild.md), [`amountAlpha`](../knowledge/economy/guild-banking.md), `amountToken`, [`playerId`](../schemas/entities/player.md) |
| `EventGuildBankRedeem` | `structs.structs.EventGuildBankRedeem` | [`amountAlpha`](../knowledge/economy/guild-banking.md) is **net** after `fee` |
| `EventGuildBankConvert` | `structs.structs.EventGuildBankConvert` | [`amountAlpha`](../knowledge/economy/guild-banking.md) is **gross** ualpha into collateral; `fee` is the convert-in cut |
| `EventGuildBankConvertToken` | `structs.structs.EventGuildBankConvertToken` | Cross-guild: also emits Redeem + Convert legs |
| `EventGuildBankConfiscateAndBurn` | `structs.structs.EventGuildBankConfiscateAndBurn` | [`address`](queries/address.md) rather than [`playerId`](../schemas/entities/player.md) |
| `EventGuildBankAddress` | `structs.structs.EventGuildBankAddress` | [`bankCollateralPool`](../knowledge/economy/guild-banking.md), `bankTokenPool` |

### Provider extras

| Proto | `type` | Payload |
|-------|--------|---------|
| `EventProviderAddress` | `structs.structs.EventProviderAddress` | [`providerId`](../schemas/entities/provider.md), `collateralPool`, `earningPool` |
| `EventProviderGrantGuild` | `structs.structs.EventProviderGrantGuild` | [`providerId`](../schemas/entities/provider.md), [`guildId`](../schemas/entities/guild.md) — **genesis replay only** (grant/revoke keeper methods were removed) |
| `EventProviderRevenueShortfall` | `structs.structs.EventProviderRevenueShortfall` | `requested` / `paid` / `shortfall`; [`agreementId`](../schemas/entities/agreement.md) empty when the sweep is not one agreement |

### Addresses and membership

| Proto | `type` | Payload |
|-------|--------|---------|
| `EventAddressAssociation` | `structs.structs.EventAddressAssociation` | [`address`](queries/address.md), `playerIndex`, `registrationStatus` |
| `EventAddressActivity` | `structs.structs.EventAddressActivity` | [`address`](queries/address.md), `blockHeight`, `blockTime` |
| `EventGuildMembershipApplication` | `structs.structs.EventGuildMembershipApplication` | [`guildMembershipApplication`](webapp/guild-membership-application.md) |

### Block

| Proto | `type` | When |
|-------|--------|------|
| `EventTime` | `structs.structs.EventTime` | Every begin-blocker: `eventTimeDetail.blockHeight`, `blockTime` |

### Untyped

| Type | When | Attributes |
|------|-------|------------|
| `ugc_moderated` | Actor of a name/pfp update is **not** the object's owner | `actor_player_id`, `actor_address`, `target_object_id`, `target_owner_player_id`, `field` (`name` or `pfp`), `old_value`, `new_value` |

Self-service UGC updates are silent. `pfpClientRenderAttributes` is owner-only and does not take this path. Full rules: [ugc-moderation.md](../knowledge/mechanics/ugc-moderation.md).

---

## In proto, not emitted

These messages exist in `events.proto` and are **not** currently passed to `EmitTypedEvent` / `EmitEvent`:

| Proto | Notes |
|-------|--------|
| `EventPlayerHalted` | Halt queries were removed from the module (no such LCD query) |
| `EventPlayerResumed` | Same |
| `EventProviderRevokeGuild` | No emit site; grant/revoke keeper methods were removed |
| `EventAlphaDefuse` | Defusion still happens; this event is unused |

Do not subscribe to these as a live signal.

---

## GRASS is not a 1:1 mirror

`structs-sync-state` consumes this log and writes tables. Some `planet_activity` categories (`shield_change`, `block_raid_start`) are **derived** from attribute writes and have no chain event of their own. A GRASS `struct_attack` stub has no shot `detail`; `structs.structs.EventAttack` on the tx does.

See [event-types.md](streaming/event-types.md) for GRASS categories and [database-schema.md](../knowledge/infrastructure/database-schema.md) for `unknown_event_log` when a new chain type has no indexer handler yet.
