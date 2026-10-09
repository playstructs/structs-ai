---
description: "Read proof-of-work records from the web application: outstanding jobs, their difficulty, and their completion state."
---

# Webapp Work API Endpoints

**Category**: webapp (catalog read)
**Entity**: Work (`view.work`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: September 30, 2026

---

## Overview

Lists outstanding proof-of-work jobs (`BUILD`, `MINE`, `REFINE`, `RAID`) tracked in the Guild-Stack `view.work` view. The underlying view anchors a job to its object, player, target, category, start block, difficulty target, and location. The player endpoint returns that full row; the paginated all/guild endpoints intentionally project only the six core work columns. These endpoints are read-only; the work itself is completed by submitting the corresponding `*-compute` transaction to the chain.

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

List all work items for a single player. Not paginated; returns the full `view.work` row set (`vw.*`) for that player.

- **ID**: `webapp-work-by-player`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | `\d+-\d+` | Player identifier (e.g. `1-11`) |

---

## Row semantics

- `object_id`: struct ID for build/mine/refine; the visiting fleet at `planet.location_list_start` for raid.
- `target_id`: struct ID for build/mine/refine; target planet ID for raid.
- `block_start`: struct `blockStartBuild`, planet `blockStartOreMine` / `blockStartOreRefine`, or planet `blockStartRaid`; missing attributes read as `0`.
- `difficulty_target`: struct-type difficulty for build/mine/refine; current `planetaryShield` for raid.
- `location_type`, `location_id`, `planet_id`: physical context. `planet_id` is populated for planet-hosted struct work and raids.

Mine/refine clocks are shared planet clocks, not per-struct clocks. Destroyed structs are excluded using authoritative `struct.is_destroyed` in addition to status bits.

Operators can check freshness and drift with `structs.api_refresh_state WHERE model = 'work'` and `structs.api_work_reconcile(false)`. The hourly full refresh repairs and logs `missing` / `extra` / `stale` rows in `structs.api_work_drift`; a recurring drift row indicates a missed dirty-key dependency or refresh ordering problem.

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.

---

*Verified against structs-webapp `08e13e2` (2026-09-30),
`src/src/Manager/WorkManager.php`, and structs-pg `f66fd81` `view.work`.*
