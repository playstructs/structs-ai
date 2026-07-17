# Webapp Work API Endpoints

**Category**: webapp (catalog read)
**Entity**: Work (`view.work`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: July 17, 2026

---

## Overview

Lists outstanding proof-of-work jobs (mining, refining, building, and other PoW-anchored actions) tracked in the Guild-Stack `view.work` view. Each row anchors a job to its object, player, target, category, start block, and difficulty target so a client (or a hashing agent) can pick up and complete the work. These endpoints are read-only surfaces over the view; the work itself is completed by submitting the corresponding `*-compute` transaction to the chain.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/work/all/page/{page}` | List every work item, paginated | Yes |
| GET | `/api/work/guild/{guild_id}/page/{page}` | List work items for a guild, paginated | Yes |
| GET | `/api/work/player/{player_id}` | List a player's work items | Yes |

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

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
