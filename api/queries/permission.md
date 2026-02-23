# Permission Query Endpoints

**Version**: 1.1.0
**Category**: Query
**Entity**: Permission
**Base URL**: `http://localhost:1317`
**Base Path**: `/structs`

---

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/permission/{permissionId}` | Get permission by ID | No | No |
| GET | `/structs/permission` | List all permissions | No | Yes |
| GET | `/structs/permission/object/{objectId}` | Get permissions by object | No | No |
| GET | `/structs/permission/player/{playerId}` | Get permissions by player | No | No |

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
