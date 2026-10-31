---
description: "Read proof-of-work records from the web application: outstanding jobs, their difficulty, and their completion state."
---

# Webapp Work API Endpoints

**Category**: webapp (catalog read)
**Entity**: Work (`view.work`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Source contract**: webapp `43bc1086`, structs-pg `400e1c1`

---

## Overview

Lists outstanding proof-of-work jobs (`BUILD`, `MINE`, `REFINE`, `RAID`) tracked in the Guild-Stack `view.work` view. The underlying view anchors a job to its object, player, target, category, start block, difficulty target, and location. The player endpoint returns that full row; the paginated all/guild endpoints intentionally project only the six core work columns. These endpoints are read-only; the browser submits the corresponding completion message after computing a proof. CLI `*-compute` commands perform that computation and then submit completion.

`view.work` is the stable read surface, but it now selects from the per-block current-state table `structs.api_work`. `view.work_live` is the authoritative recomputation used for refresh/reconciliation and must not be used on request paths. Sync-state calls `structs.api_work_refresh(height, block_time)` after each block's authoritative writes; `api_refresh_state` records the last refreshed height/time. The refresh is incremental through `api_work_dirty`, falls back to a full pass above 2,000 keys, and an empty queue returns before temporary-table setup.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/work/all/page/{page}` | List every work item, paginated | Yes |
| GET | `/api/work/guild/{guild_id}/page/{page}` | List work items for a guild, paginated | Yes |
| GET | `/api/work/player/{player_id}` | List a player's work items | Yes |
| GET | `/api/work/count` | Outstanding `view.work` row count | Yes |

---

## Endpoint Details

### GET `/api/work/all/page/{page}`

List every outstanding work item, paginated.

- **ID**: `webapp-work-list-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

Row columns: `object_id`, `player_id`, `target_id`, `category`, `block_start`, `difficulty_target`.

---

### GET `/api/work/guild/{guild_id}/page/{page}`

List work items belonging to a guild's members, paginated.

- **ID**: `webapp-work-list-by-guild`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier (e.g. `0-1`) |
| `page` | integer | Yes | `\d+` | Page number |

Row columns: `object_id`, `player_id`, `target_id`, `category`, `block_start`, `difficulty_target`.

---

### GET `/api/work/player/{player_id}`

List all work items for a single player. Not paginated; returns the nine named work/context fields for that player, ordered by `block_start`.

- **ID**: `webapp-work-by-player`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | `\d+-\d+` | Player identifier (e.g. `1-11`) |

---

## Row semantics

- `object_id`: struct ID for build/mine/refine; the visiting fleet at `planet.location_list_start` for raid.
- `target_id`: struct ID for build/mine/refine; target planet ID for raid.
- `block_start`: struct `blockStartBuild`, planet `blockStartOreMine` / `blockStartOreRefine`, or planet `blockStartRaid`; missing attributes can read as `"0"`; zero is not an eligible proof anchor.
- `difficulty_target`: struct-type difficulty for build/mine/refine; current `planetaryShield` for raid.
- `location_type`, `location_id`, `planet_id`: physical context. `planet_id` is populated for planet-hosted struct work and raids.

Mine/refine clocks are shared planet clocks, not per-struct clocks. Destroyed structs are excluded using authoritative `struct.is_destroyed` in addition to status bits.

Operators can check freshness and drift with `structs.api_refresh_state WHERE model = 'work'` and `structs.api_work_reconcile(false)`. The hourly full refresh repairs and logs `missing` / `extra` / `stale` rows in `structs.api_work_drift`; a recurring drift row indicates a missed dirty-key dependency or refresh ordering problem.

All four endpoints read data and required `work` readiness metadata in one SQL snapshot.
`block_start` and `difficulty_target` are exact decimal strings, including values
above Number.MAX_SAFE_INTEGER; do not parse them as JavaScript Number. The count
route returns an object with `count`. List responses carry flat arrays, including
an empty complete list. All/guild pages use a fixed 100 rows; they do not supply a
stable multi-request snapshot or keyset ordering.

Require the actual response's chain/protocol/cache epoch, `data_ready` and ready
`work` model at that height before reconciling tasks. Preserve `meta` even when
`data` is empty. Incomplete reads cannot remove work. Keep original anchors across
the activation boundary; use the current catalog and observed-height difficulty
rule. A queued/unknown completion is reconciled from its original journal rather
than submitted again. See [client work lifecycle](../../develop/client/work-and-pow.md)
and [snapshot metadata](../../protocols/webapp-api-protocol.md#snapshot-metadata).

---

*Read contract verified against webapp `43bc1086` WorkManager and structs-pg
`400e1c1` exact work/readiness projections. Earlier refresh/reconciliation mechanics
remain in the same schema lineage; source review does not certify a live deployment.*
