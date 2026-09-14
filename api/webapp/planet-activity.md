---
description: "Read the planet activity log from the web application: the event history of what happened on a planet and when, plus per-player feeds and 30-day stats."
---

# Webapp Planet Activity API Endpoints

**Category**: webapp (catalog read)
**Entity**: PlanetActivity (`structs.planet_activity`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: September 14, 2026

---

## Overview

Per-planet activity log — raids, attacks, builds, defender changes, struct health updates, etc. Categories include `raid_status`, `block_raid_start`, `shield_change`, `struct_attack`, `struct_health`, `fleet_arrive`, `fleet_depart`, and others; see `.cursor/skills/structs-streaming/SKILL.md` for the GRASS-side category names. `block_raid_start` records the block height at which a raid began, and `shield_change` records planet shield adjustments. Use this REST surface for historical browsing; use GRASS for real-time reaction.

The **per-player** routes read `structs.planet_activity_player` (attribution written at insert time, ownership as-of-event). `seq` is a per-planet counter and is **not** a cursor across planets — use `?since_height=` (`block_height > :since_height`) as the incremental high-water mark. `since_seq` is `400 since_seq_unsupported` on the player feed.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/planet-activity/all/page/{page}` | List every planet activity row | Yes |
| GET | `/api/planet-activity/planet/{planet_id}/page/{page}` | List activity for a planet | Yes |
| GET | `/api/planet-activity/category/{category}/page/{page}` | List activity by category | Yes |
| GET | `/api/planet-activity/player/{player_id}/page/{page}` | Activity attributed to a player (`?category=`, `?role=`, `?since_height=`, `?order=`) | Yes |
| GET | `/api/planet-activity/stats` | 30-day counts by category (`?category=`, `?bucket=1h\|1d`) | Yes |
| GET | `/api/planet-activity/player/{player_id}/stats` | Per-player daily counts by category and role | Yes |

Bucketed stats for charts: [`analytics.md`](analytics.md).

---

## Endpoint Details

### GET `/api/planet-activity/all/page/{page}`

- **ID**: `webapp-planet-activity-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

`?since_height=` is **not** supported here (`400 since_height_unsupported`). Track one `seq` per planet, or scan globally on `block_height`.

---

### GET `/api/planet-activity/planet/{planet_id}/page/{page}`

- **ID**: `webapp-planet-activity-by-planet`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `planet_id` | string | Yes | planet-id | Planet identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/planet-activity/category/{category}/page/{page}`

- **ID**: `webapp-planet-activity-by-category`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `category` | string | Yes | -- | Activity category (e.g. `raid_status`, `block_raid_start`, `shield_change`, `struct_attack`, `struct_health`, `fleet_arrive`, `fleet_depart`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/planet-activity/player/{player_id}/page/{page}`

- **ID**: `webapp-planet-activity-by-player`

Per-player feed via `structs.planet_activity_player` joined back to the parent `planet_activity` row. Dual-role rows on the same parent are collapsed with `DISTINCT ON (block_height, time, planet_id, seq)` unless `role` is set.

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Player identifier |
| `page` | integer | Yes | `\d+` | Page number |
| `category` | string | No | allowlisted | Restrict to one category |
| `role` | string | No | allowlisted | `attacker`, `target`, `owner`, `planet_owner`, `defender`, `protected`, `fleet_owner` |
| `since_height` | integer | No | int | Filter `block_height > since_height`. Filter, not a keyset — `OFFSET` still applies |
| `order` | string | No | `asc` \| `desc` | Default `desc` (`block_height`, then `time`, `planet_id`, `seq`) |
| `include_total` | `0` \| `1` | No | -- | When `role` is omitted, `total` is `count(DISTINCT (time, planet_id, seq))` |

Allowlisted categories: `struct_attack`, `raid_status`, `fleet_arrive`, `fleet_depart`, `struct_status`, `struct_health`, `struct_move`, `struct_block_build_start`, `struct_block_ore_mine_start`, `struct_block_ore_refine_start`, `struct_defense_add`, `struct_defense_remove`, `shield_change`, `block_raid_start`. Anything else is `400 category_invalid`. Unknown `role` is `400 role_invalid`. `?order=` other than `asc`/`desc` is `400 order_invalid`.

Rows: `time`, `seq`, `planet_id`, `block_height`, `category`, `detail` (JSON string) plus **`detail_json`** (parsed object, or `null` if `detail` is not JSON).

---

### GET `/api/planet-activity/stats`

- **ID**: `webapp-planet-activity-stats`

Optional `category`, `bucket` (`1h` or `1d`; omit = daily). Last 30 days from the `planet_activity_hourly` / `planet_activity_daily` continuous aggregates. Rows: `bucket`, `category`, `count`.

---

### GET `/api/planet-activity/player/{player_id}/stats`

- **ID**: `webapp-planet-activity-player-stats`

Daily counts from `structs.planet_activity_player_daily`. Optional `category`, `role` (same allowlist as the feed). Last 30 days. Rows: `bucket`, `category`, `role`, `count`.

`?bucket=1h` is `400 bucket_invalid` — this endpoint is daily only.

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a default page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
