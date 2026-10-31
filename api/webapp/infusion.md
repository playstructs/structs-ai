---
description: "Read exact reactor balances, retained and vault positions, stored infusion power, and completeness evidence from the webapp."
---

# Webapp Infusion API Endpoints

These authenticated reads use the [application envelope](../../protocols/webapp-api-protocol.md).
Use the guild's configured webapp base URL, independently of its chain LCD URL.

## Endpoint Summary

| Method | Path | Result |
|---|---|---|
| GET | `/api/infusion/player/{player_id}` | One aggregate for the player's current guild reactor, with exact positions |
| GET | `/api/infusion/list/all/page/{page}` | Stored infusion rows |
| GET | `/api/infusion/list/destination/{destination_id}/page/{page}` | Stored rows at one reactor or generator |
| GET | `/api/infusion/list/address/{address}/page/{page}` | Stored rows for an address |
| GET | `/api/infusion/list/player/{player_id}/page/{page}` | Stored rows whose recorded owner resolves to the player |

## Reactor aggregate

`GET /api/infusion/player/{player_id}` returns one object or null in `data`.
It is scoped to `guild.primary_reactor_id`, not every reactor a player has used.
The top-level `address` is null: an aggregate over multiple addresses has no single
signing/delegator address. Preserve the envelope's `meta` alongside this object.

| Fields | Meaning |
|---|---|
| `player_id`, `owner_id`, `destination_id`, `validator`, `vault_address` | Player, current guild reactor and canonical vault identity |
| `fuel_p`, `defusing_p` | Exact current native bonded and unbonding totals, in ualpha; null if incomplete |
| `fuel`, `defusing` | Floored Alpha display strings; never signing inputs |
| `power_p`, `owner_power_p` | Stored applied gross power and owner share, in milliwatts |
| `power`, `owner_power` | Floored watts display strings |
| `preview_commission`, `commission` | Current reactor default as exact decimal and percentage display |
| `join_infusion_minimum_p`, `join_infusion_minimum` | Raw ualpha and floored Alpha display |
| `positions` | Per-address evidence, ordered vault first then address |
| `positions_meta` | Completeness, power validity and independent native-source evidence |

The compatibility `ratio`/`ratio_p` fields are display inputs, not evidence that all
historic positions were created at today's rate. Owner power subtracts each position's
commission with the chain's ties-to-even rounding before summing. Do not recalculate
stored applied output from aggregate fuel and today's commission/cap.

### Position rows

Each row includes `address`, `is_vault`, current `owner_id`, `recorded_owner_id`,
`validator`, `native_ready`, `source_height`, `fuel_p`, `defusing_p`,
`unbonding_entries`, `power_p`, `owner_power_p`, `power_ready`, `stored_fuel_p`,
`stored_defusing_p`, `ratio_p` and `commission`.

The native amounts describe current delegation/unbonding claims; stored fuel and
cooldown fields are separate game-state evidence. Retained addresses may hold stake
or refunds outside the vault. Held or past-time unbonding entries remain pending
until staking actually removes them; elapsed wall time is not proof of a refund.

### Completeness and eligibility

`positions_meta` includes `height`, `complete`, `power_ready`,
`minimum_source_height`, `eligibility_checked: false`, `address_limit: 1024` and
`reason`. Exceeding the address bound produces unavailable totals, not truncated
wealth. Reasons include `snapshot_unavailable`, `address_limit`, `reactor_unavailable`,
`vault_unindexed`, `native_unavailable` and `power_unavailable`.

For a canonical vault that is not yet provisioned/indexed, the HTTP route can obtain
bounded native evidence at the original indexed height and recheck stored power at
that same boundary. A completed fallback records `vault_provisioned: false` and
`vault_source: "chain_snapshot"`; it does not insert a vault or signing address.
Failed, pruned, mismatched or incomplete native reads produce
`vault_evidence_unavailable`, unavailable totals and `transaction_ready: false`.

The endpoint requires complete balances and valid power before retaining transaction
readiness. Even then, it does not certify live withdrawal eligibility. Prepare against
current native ownership, permission, staking entries and simulation. The reference
client withdraws from vault stake first, then eligible retained addresses deterministically,
in one atomic transaction of at most 16 positions. See
[actions and signing](../../develop/client/actions-and-signing.md).

## Catalog rows

The `/list/` routes return a flat array, one row per `(destination_id, address)`.
Default page size is 100; `?limit=` is clamped to 1–10000. They support
`updated_since`, optional total/height metadata, and deterministic ordering. They
have no single-ID cursor. Pages can observe different database snapshots.

Raw columns include `destination_id`, `address`, `destination_type`, `player_id`,
`owner_id`, `generator_disabled`, `fuel_p`, `defusing_p`, `power_p`, `ratio_p`,
`commission`, their generated display columns and timestamps. **`_p` means precise,
not pending.** Token raw values use ualpha, power uses milliwatts; use exact strings
and consult each field's scale. `generator_disabled` preserves a disabled position's
stored fuel while its applied output is zero.

The player filter uses `COALESCE(NULLIF(owner_id, ''), player_id)`. These are recorded
infusion owners, not a replacement for current address ownership or native eligibility.
Do not take `data[0]` as a destination's total. Scanning every page may support analytics,
but cannot establish one coherent signing snapshot. Optional catalog `meta.height`
is not the complete reactor/readiness contract above.

There is no `/api/infusion/reactor/{id}` route. Generator funding uses the dedicated
[generator snapshot](struct.md#generator-snapshot), rather than this reactor aggregate.

*Verified against webapp integration `43bc1086` (InfusionController,
InfusionManager, ReactorVaultManager and TableReadManager) and structs-pg `400e1c1`
(api_player_reactor and native position snapshots). Native fallback includes real
Symfony request/service-resolution coverage and restricted-role database fixtures;
this does not certify a particular public deployment.*
