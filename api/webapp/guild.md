# Webapp Guild API Endpoints

**Version**: 1.1.0
**Category**: webapp
**Entity**: Guild
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`)
**Last Updated**: January 1, 2026

---

## v0.8.0-beta Notes

**Hash Permission**: Guild endpoints may need to include Hash permission (bit 64) information in permission-related responses.

**See**: `reviews/webapp-v0.8.0-beta-review.md` for review status

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

*Last Updated: January 1, 2026*
