---
title: Webapp analytics and charting API
description: "Charting endpoints on the guild webapp: leaderboards, inventory, bank history, time-series aggregates, market snapshots, and census counts."
---

# Webapp analytics and charting API

**Category**: webapp
**Verified against**: structs-webapp `fdf120d8` (PR #121, 2026-09-02)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)

These routes exist to **draw the board**, not to look up one entity. Leaderboards, inventory, bank history, time-series aggregates, market snapshots, and census counts all return chart-ready rows: amounts as **strings**, optional `meta.height` for the indexer tip, and (where noted) `?bucket=1h|1d` windows over the last 30 days.

They still sit behind a session cookie. Public prefixes remain `/api/auth/*`, `/api/guild/this`, `/api/timestamp`, `/api/setting`. `/api/block` needs auth.

Envelope: `{ "success", "errors", "data" }` plus optional `meta.height` and `total`. Unwrap `data` after `success`. Protocol: [webapp-api-protocol](../../protocols/webapp-api-protocol.md). Per-entity lookup routes stay on their entity pages; this file is the charting map.

## What to call for a dashboard

| Job | Call |
|-----|------|
| Format any amount | `GET /api/denom` once, cache; never hardcode exponents |
| Resolve a name, id, or address | `GET /api/resolve?q=` or `GET /api/objects?ids=` |
| Rank players / guilds / reactors / substations / providers | `GET /api/leaderboard/{kind}` |
| Who holds a denom | `GET /api/inventory/denom/{denom}/page/{page}` |
| One owner's balances | `GET /api/inventory/owner/{owner_type}/{owner_id}` |
| Every guild bank, live | `GET /api/guild-bank` |
| One guild's mint/burn/infuse volume | `GET /api/guild-bank/{guild_id}/history?bucket=` |
| Energy storefront | `GET /api/provider/market` |
| One buyer's open agreements + escrow remaining | `GET /api/agreement/owner/{owner}/market` |
| One object's metric over time | `GET /api/stat/{metric}/object/{key}/range/page/{n}` |
| Galaxy-wide metric (LOCF average/sum) | `GET /api/stat/{metric}/aggregate/range` |
| Activity volume by category | `GET /api/planet-activity/stats` |
| Ledger volume by action/denom | `GET /api/ledger/stats` |
| Power-margin census | `GET /api/player/power/at-risk`, `GET /api/player/{id}/power` |
| Raid board | `GET /api/planet-raid/all/page/{n}` or `.../status/{status}/page/{n}` |
| Census tiles | `/api/{player,planet,struct,fleet,work}/count` plus `/api/player/active/count`, `/api/struct/status/counts` |
| Indexer tip vs chain tip | `GET /api/block` (auth) or `meta.height` on stamped responses |

`_p` fields are base-precision strings (ualpha, milliwatt, …). Unsuffixed twins are truncated display values. Read `/api/denom` for `precision_suffix`, unit scales, and `.infused` / `.defusing` state suffixes.

## Units and lookup

### GET `/api/denom`

- **ID**: `webapp-denom`

Unit registry: `ualpha` and `ore`, plus every `uguild.{guild_id}` (optional `guild_meta.denom` JSON scale). Also `state_suffixes`, `unknown_denom`, energy base (`milliwatt` / watt, exponent 3), and `precision_suffix: "_p"`. `data.amounts` is `"string"`; counts and ratios are numbers.

### GET `/api/resolve?q=`

- **ID**: `webapp-resolve`

Required `q`. Object key (`N-M`) returns one typed row. Bech32 ≥32 chars looks up `player_address`. Anything else is ILIKE on player username, guild name/tag, substation name. Cap `PaginationLimits::BATCH_IDS_MAX` (25). `address` (`8-N`) and `infusion` (`7-N`) are not addressable by object key — `object` is `null`.

### GET `/api/objects?ids=`

- **ID**: `webapp-objects`

Comma-separated ids, same typed fetch as resolve. Projections are explicit column lists, not `SELECT *`.

Resolvable types: guild, player, planet, reactor, substation, struct, allocation, fleet, provider, agreement.

## Leaderboards

### GET `/api/leaderboard/{kind}`

- **ID**: `webapp-leaderboard`

`kind` ∈ `player|guild|reactor|substation|provider`. Query: `order` (allowlisted per kind or `400 order_invalid`), `limit` (default 50, clamp 1–1000).

| kind | Default order | Amount columns (strings, `_p`) |
|------|---------------|--------------------------------|
| player | `alpha_value DESC` | `alpha_balance_p`, `alpha_value_p` |
| guild | `collateral DESC` | `collateral_p`, `supply_p`, `member_capacity_p`, `member_load_p`, `shared_connection_capacity_p` |
| reactor | `fuel DESC` | `fuel_p`, `power_p` |
| substation | `load DESC` | `load_p`, `member_capacity_p`, `shared_connection_capacity_p` |
| provider | `agreement_count DESC` | `rate_amount_p` |

Player also has `username`, `guild_id`. Height stamped from `api_refresh_state` for that leaderboard model.

## Inventory and guild banks

There **is** an HTTP bank read. Mint/redeem/convert remain chain txs; balances and ratios come from these catalog tables.

### GET `/api/inventory/denom/{denom}/page/{page}`

- **ID**: `webapp-inventory-by-denom`

Optional `?limit=`. Rows from `structs.api_inventory`: `owner_type`, `owner_id`, `denom`, `balance` (text), order balance DESC.

### GET `/api/inventory/owner/{owner_type}/{owner_id}`

- **ID**: `webapp-inventory-by-owner`

Same table, one owner. `owner_type` is a `structs.object_type` enum value (`player`, `guild`, …).

### GET `/api/guild-bank`

- **ID**: `webapp-guild-bank`

Every row in `structs.api_guild_bank`: `guild_id`, `denom`, `collateral`, `supply` (text), `ratio`. This is the live collateral picture that used to require a bank-module query.

### GET `/api/guild-bank/{guild_id}/history`

- **ID**: `webapp-guild-bank-history`

Optional `?bucket=1h` (else day). Last 30 days. Ledger actions `minted|burned|infused|defusion_completed` on `uguild.{id}` and `uguild.{id}.%`. Rows: `bucket`, `action`, `denom`, `volume` (signed text; debits negative).

## Markets

### GET `/api/provider/market`

- **ID**: `webapp-provider-market`

Every provider with substation owner, inferred `guild_id`, `alpha_equivalent_rate_p` (guild-token rates converted via `api_guild_bank.ratio`; ualpha/alpha pass through), and `committed_capacity` of still-open agreements. Height stamped from the `guild_bank` refresh model.

### GET `/api/agreement/owner/{owner}/market`

- **ID**: `webapp-agreement-owner-market`

That owner's agreements plus `blocks_remaining` and `escrow_remaining` (capacity × rate × remaining blocks, text). `owner` is a player id.

## Time series

Raw per-object range still lives on [stat.md](stat.md). Charting additions:

- Optional `?bucket=1h|1d` on the per-object range: `date_trunc` + `AVG(value)`. With a bucket the max window is **30 days** (`2592000` s); without it the max stays **7 days**.
- Optional `?limit=` on that range (default 100, max 1000).

### GET `/api/stat/{metric}/aggregate/range`

- **ID**: `webapp-stat-aggregate-range`

Required query: `object_type`, `start_time`, `end_time` (unix seconds). Optional `bucket` (`1h` default, or `1d`). Max window 30 days. `400 object_type_start_time_end_time_required` if any of the three is missing.

Samples are change-triggered. A naïve `AVG` per bucket would describe only objects that moved. This endpoint **last-observation-carries-forward** every object's last-known value to each bucket close, then returns `bucket`, `sum`, `avg`, `population`, `samples`. Objects with no sample yet contribute nothing (not zero).

Family-two metrics still require their entity `object_type` (`structs_load` → player, `connection_*` → substation, `struct_health`/`struct_status` → struct).

### GET `/api/planet-activity/stats`

- **ID**: `webapp-planet-activity-stats`

Optional `category`, `bucket` (`1h` or day). Last 30 days. Rows: `bucket`, `category`, `count`.

### GET `/api/ledger/stats`

- **ID**: `webapp-ledger-stats`

Optional `bucket`, `denom`. Last 30 days. Rows: `bucket`, `action`, `denom`, `volume` (text), `count`.

## Power, raids, census

| Method | Path | Notes |
|--------|------|--------|
| GET | `/api/player/{player_id}/power` | `view.player` capacity/load including `_p` and `margin` / `margin_p` |
| GET | `/api/player/power/at-risk` | Same columns, `ORDER BY margin ASC`, `?limit=` default 25 |
| GET | `/api/player/count` | `count(*)` on `player` |
| GET | `/api/player/active/count` | `lastAction` within `?window_blocks=` (default **16363**) |
| GET | `/api/planet/count` | Planet census |
| GET | `/api/planet-raid/all/page/{page}` | `planet_id`, `fleet_id`, `status`, `updated_at`, `seized_ore`; `?limit=` |
| GET | `/api/planet-raid/status/{status}/page/{page}` | Same, filtered |
| GET | `/api/struct/status/counts` | `view.struct_status`: materialized, built, online, stored, hidden, destroyed, locked, total |
| GET | `/api/struct/count` | Optional `?is_destroyed=0\|1` |
| GET | `/api/fleet/count` | Fleet census |
| GET | `/api/work/count` | Outstanding `view.work` rows |
| GET | `/api/block` | `height`, `tip_height`, `lag_blocks`, `status`, `updated_at` from `current_block` |
| GET | `/api/grid/attribute-type/{attribute_type}/object-type/{object_type}/page/{page}` | Grid slice by attribute **and** object type; `?order=` allowlisted |

Entity pages that own the non-charting routes: [player](player.md), [planet](planet.md), [struct](struct.md), [fleet](fleet.md), [ledger](ledger.md), [work](work.md), [system](system.md), [grid](grid.md), [agreement](agreement.md), [provider](provider.md), [planet-activity](planet-activity.md), [stat](stat.md).

Guild banking economics: [guild-banking.md](../../knowledge/economy/guild-banking.md).
