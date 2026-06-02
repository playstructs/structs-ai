# Webapp Guild API Endpoints

**Category**: webapp
**Entity**: Guild
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/guild/this` | Get the host/infrastructure guild for this deployment | No (public) |
| GET | `/api/guild/name` | Get guild name | Yes |
| GET | `/api/guild/{guild_id}/name` | Get guild name by ID | Yes |
| GET | `/api/guild/{guild_id}/members/count` | Get guild member count | Yes |
| GET | `/api/guild/count` | Get total guild count | Yes |
| GET | `/api/guild/directory` | Get guild directory | Yes |
| GET | `/api/guild/{guild_id}` | Get guild by ID | Yes |
| GET | `/api/guild/{guild_id}/power/stats` | Get guild power statistics | Yes |
| GET | `/api/guild/{guild_id}/roster` | Get guild roster | Yes |
| GET | `/api/guild/{guild_id}/planet/complete/count` | Get completed planet count for guild | Yes |
| GET | `/api/guild/list/all/page/{page}` | Catalog list of every guild | Yes |
| GET | `/api/guild/list/primary-reactor/{primary_reactor_id}/page/{page}` | List guilds by primary reactor | Yes |
| GET | `/api/guild/list/entry-substation/{entry_substation_id}/page/{page}` | List guilds by entry substation | Yes |
| GET | `/api/guild/list/owner/{owner}/page/{page}` | List guilds by owning player | Yes |

Guild membership applications live in [`guild-membership-application.md`](guild-membership-application.md).

---

## Endpoint Details

### GET `/api/guild/this`

Return the **host / infrastructure guild for this webapp deployment** — the guild where `guild_meta.this_infrastructure = TRUE` (`GuildManager::getThisGuild`, joins `guild` + `reactor` + `guild_meta`, `LIMIT 1`). This is **not** the logged-in player's guild and it does **not** read the session.

Use it pre-login to discover which guild a given webapp instance serves. The operator's own guild comes from the login context (`session.guild_id`, set at login) or from the player record — not from this endpoint.

- **ID**: `webapp-guild-this`
- **Authentication**: None (public route, no session required)

**Response** (envelope; `data` is the single host-guild row, guild IDs are type 0):

```json
{
  "success": true,
  "errors": {},
  "data": { "id": "0-1", "name": "GuildName" }
}
```

---

### GET `/api/guild/name`

Get guild name.

- **ID**: `webapp-guild-name`

---

### GET `/api/guild/{guild_id}/name`

Get guild name by ID.

- **ID**: `webapp-guild-by-id-name`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |

---

### GET `/api/guild/{guild_id}/members/count`

Get guild member count.

- **ID**: `webapp-guild-members-count`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |

---

### GET `/api/guild/count`

Get total guild count.

- **ID**: `webapp-guild-count`
- **Response Schema**: `schemas/responses.md#CountResponse`
- **Content Type**: `application/json`

#### Example

**Request**: `GET http://localhost:8080/api/guild/count`

**Response** (envelope):

```json
{
  "success": true,
  "errors": {},
  "data": { "count": 42 }
}
```

---

### GET `/api/guild/directory`

Get guild directory.

- **ID**: `webapp-guild-directory`

---

### GET `/api/guild/{guild_id}`

Get guild by ID.

- **ID**: `webapp-guild-by-id`
- **Response Schema**: `schemas/entities.md#Guild`
- **Content Type**: `application/json`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |

#### Example

**Request**: `GET http://localhost:8080/api/guild/0-1` (guild IDs are type `0`, `^0-[0-9]+$`)

**Response** (envelope; bespoke `data` carries the SQL columns from `GuildManager`):

```json
{
  "success": true,
  "errors": {},
  "data": {
    "id": "0-1",
    "name": "GuildName",
    "member_count": 10
  }
}
```

---

### GET `/api/guild/{guild_id}/power/stats`

Get guild power statistics.

- **ID**: `webapp-guild-power-stats`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |

---

### GET `/api/guild/{guild_id}/roster`

Get guild roster.

- **ID**: `webapp-guild-roster`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |

---

### GET `/api/guild/{guild_id}/planet/complete/count`

Get completed planet count for guild.

- **ID**: `webapp-guild-planet-complete-count`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |

---

### GET `/api/guild/list/all/page/{page}`

Catalog list of every guild on the chain, paginated.

- **ID**: `webapp-guild-list-all`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number, 1-indexed |

---

### GET `/api/guild/list/primary-reactor/{primary_reactor_id}/page/{page}`

List guilds whose primary reactor matches the given reactor.

- **ID**: `webapp-guild-list-by-primary-reactor`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `primary_reactor_id` | string | Yes | reactor-id | Reactor identifier (e.g. `3-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/guild/list/entry-substation/{entry_substation_id}/page/{page}`

List guilds that route new members through the given entry substation.

- **ID**: `webapp-guild-list-by-entry-substation`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `entry_substation_id` | string | Yes | substation-id | Substation identifier (e.g. `4-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/guild/list/owner/{owner}/page/{page}`

List guilds by owning player.

- **ID**: `webapp-guild-list-by-owner`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier (e.g. `1-11`) |
| `page` | integer | Yes | `\d+` | Page number |

---

The `/api/guild/list/...` endpoints return the shared envelope with rows **directly in `data` as a flat array** (fixed page size 100 — if `data.length === 100`, fetch the next page). Bespoke guild endpoints also use the `{ "success", "errors", "data" }` envelope. All guild routes require a session **except** `/api/guild/this` (public). See `protocols/webapp-api-protocol.md`.

> There is no HTTP endpoint to read a guild's bank/token balance. `MsgGuildBankMint`/`MsgGuildBankRedeem` are chain transactions; read balances via chain queries (bank module) or the ledger, not the webapp.
