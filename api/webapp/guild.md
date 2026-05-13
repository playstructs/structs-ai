# Webapp Guild API Endpoints

**Category**: webapp
**Entity**: Guild
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/guild/this` | Get current user's guild | Yes |
| GET | `/api/guild/name` | Get guild name | No |
| GET | `/api/guild/{guild_id}/name` | Get guild name by ID | No |
| GET | `/api/guild/{guild_id}/members/count` | Get guild member count | No |
| GET | `/api/guild/count` | Get total guild count | No |
| GET | `/api/guild/directory` | Get guild directory | No |
| GET | `/api/guild/{guild_id}` | Get guild by ID | No |
| GET | `/api/guild/{guild_id}/power/stats` | Get guild power statistics | No |
| GET | `/api/guild/{guild_id}/roster` | Get guild roster | No |
| GET | `/api/guild/{guild_id}/planet/complete/count` | Get completed planet count for guild | No |
| GET | `/api/guild/list/all/page/{page}` | Catalog list of every guild | No |
| GET | `/api/guild/list/primary-reactor/{primary_reactor_id}/page/{page}` | List guilds by primary reactor | No |
| GET | `/api/guild/list/entry-substation/{entry_substation_id}/page/{page}` | List guilds by entry substation | No |
| GET | `/api/guild/list/owner/{owner}/page/{page}` | List guilds by owning player | No |

Guild membership applications live in [`guild-membership-application.md`](guild-membership-application.md).

---

## Endpoint Details

### GET `/api/guild/this`

Get current user's guild.

- **ID**: `webapp-guild-this`
- **Authentication**: Required

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

**Response**:

```json
{
  "count": 42
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

**Request**: `GET http://localhost:8080/api/guild/2-1`

**Response**:

```json
{
  "id": "2-1",
  "name": "GuildName",
  "member_count": 10
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

The `/api/guild/list/...` endpoints return the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
