# Webapp Guild Membership Application API Endpoints

**Category**: webapp (catalog read)
**Entity**: GuildMembershipApplication
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Pending and historical applications for guild membership. Created on chain by `MsgGuildMembershipApply`; resolved by `MsgGuildMembershipApprove` / `MsgGuildMembershipDeny`. See `knowledge/economy/guild-banking.md` for guild lifecycle.

### Catalog row schema (`structs.guild_membership_application`)

All three endpoints return these raw snake_case columns directly in `data` as a flat array. The state field is **`status`** — **not** `registration_status` (don't infer the field name from chain/protobuf naming).

| Column | Description |
|--------|-------------|
| `guild_id` | Target guild (type 0, e.g. `0-1`) |
| `player_id` | Applicant player |
| `join_type` | How the player is joining (e.g. invite/request) |
| `status` | Application state (pending/approved/denied) |
| `proposer` | Player/entity that proposed the application |
| `substation_id` | Entry substation the membership routes through |
| `created_at` / `updated_at` | Timestamps |

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/guild-membership-application/all/page/{page}` | List every application | Yes |
| GET | `/api/guild-membership-application/guild/{guild_id}/page/{page}` | List applications targeting a guild | Yes |
| GET | `/api/guild-membership-application/player/{player_id}/page/{page}` | List applications submitted by a player | Yes |

---

## Endpoint Details

### GET `/api/guild-membership-application/all/page/{page}`

- **ID**: `webapp-guild-membership-application-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/guild-membership-application/guild/{guild_id}/page/{page}`

- **ID**: `webapp-guild-membership-application-by-guild`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/guild-membership-application/player/{player_id}/page/{page}`

- **ID**: `webapp-guild-membership-application-by-player`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | player-id | Applicant player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": [ ...rows ] }`); catalog rows are returned **directly in `data` as a flat array** with a fixed page size of 100 — if `data.length === 100`, request the next page. See `protocols/webapp-api-protocol.md`.
