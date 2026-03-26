# Permission Query Endpoints

**Version**: 1.2.0
**Category**: Query
**Entity**: Permission
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Permission Flags

Permissions use 24-bit flags stored as `uint64`. There are 24 individual permission bits (bits 0–23). `PermAll` = 16777215 (all 24 bits set, 2^24 − 1).

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/permission/{permissionId}` | Get permission by ID | No | No |
| GET | `/structs/permission` | List all permissions | No | Yes |
| GET | `/structs/permission/object/{objectId}` | Get permissions by object | No | No |
| GET | `/structs/permission/player/{playerId}` | Get permissions by player | No | No |
| GET | `/structs/guild_rank_permission_by_object/{objectId}` | Get guild rank permissions by object | No | Yes |
| GET | `/structs/guild_rank_permission_by_object_and_guild/{objectId}/{guildId}` | Get guild rank permissions by object and guild | No | No |

---

## Endpoint Details

### Get Permission by ID

`GET /structs/permission/{permissionId}`

Returns a single permission by its ID.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `permissionId` | string | Yes | permission-id | Permission identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Permission`

---

### List All Permissions

`GET /structs/permission`

Returns a paginated list of all permissions.

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Permission` (array)

---

### Get Permissions by Object

`GET /structs/permission/object/{objectId}`

Returns all permissions associated with a specific object.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `objectId` | string | Yes | - | Object identifier |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Permission` (array)

---

### Get Permissions by Player

`GET /structs/permission/player/{playerId}`

Returns all permissions granted to a specific player.

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `playerId` | string | Yes | entity-id (`^1-[0-9]+$`) | Player identifier in format 'type-index' (e.g., '1-11' for player type 1, index 11). Type 1 = Player. |

#### Response

- **Content-Type**: `application/json`
- **Schema**: `schemas/entities.md#Permission` (array)

---

### Get Guild Rank Permissions by Object

`GET /structs/guild_rank_permission_by_object/{objectId}`

Returns all guild rank permission records for a given object. Each record represents a single permission bit with its worst-allowed rank for a specific guild.

**CLI**: `structsd query structs guild-rank-permission-by-object {objectId}`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `objectId` | string | Yes | - | Object identifier |
| `pagination.key` | string | No | - | Pagination key |
| `pagination.limit` | integer | No | - | Page size |

#### Response

- **Content-Type**: `application/json`

```json
{
  "guild_rank_permission_records": [
    {"objectId": "6-1", "guildId": "4-1", "permissions": "4", "rank": "3"}
  ]
}
```

Each record contains a single permission bit. Combined bitmasks are always decomposed in query responses.

---

### Get Guild Rank Permissions by Object and Guild

`GET /structs/guild_rank_permission_by_object_and_guild/{objectId}/{guildId}`

Returns guild rank permission records for a specific (objectId, guildId) pair. Returns at most 24 records (one per permission bit).

**CLI**: `structsd query structs guild-rank-permission-by-object-and-guild {objectId} {guildId}`

#### Parameters

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `objectId` | string | Yes | - | Object identifier |
| `guildId` | string | Yes | entity-id | Guild identifier |

#### Response

- **Content-Type**: `application/json`

```json
{
  "guild_rank_permission_records": [
    {"objectId": "6-1", "guildId": "4-1", "permissions": "4", "rank": "3"}
  ]
}
```

No pagination needed — at most 24 records (one per permission bit).
