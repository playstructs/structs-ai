# Webapp Guild Membership Application API Endpoints

**Category**: webapp (catalog read)
**Entity**: GuildMembershipApplication
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Pending and historical applications for guild membership. Created on chain by `MsgGuildMembershipApply`; resolved by `MsgGuildMembershipApprove` / `MsgGuildMembershipDeny`. See `knowledge/economy/guild-banking.md` for guild lifecycle.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/guild-membership-application/all/page/{page}` | List every application | No |
| GET | `/api/guild-membership-application/guild/{guild_id}/page/{page}` | List applications targeting a guild | No |
| GET | `/api/guild-membership-application/player/{player_id}/page/{page}` | List applications submitted by a player | No |

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

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
