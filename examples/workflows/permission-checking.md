# Permission Checking Workflow

**Version**: 1.0.0
**Category**: Authentication

---

## Description

Workflow for checking permissions including Hash permission (v0.8.0-beta).

## Primary Workflow: Check Player Permissions

### 1. Query Object Permissions

Get all permissions for a specific object.

- **Method**: `GET`
- **Endpoint**: `/structs/permission/object/{objectId}`

**Request Example** (`objectId`: `0-1`):

**Expected Response**:

```json
[
  {
    "permissionId": "0-1@1-11",
    "value": "127",
    "objectType": "guild",
    "objectIndex": "1",
    "objectId": "0-1",
    "playerId": "1-11"
  },
  {
    "permissionId": "0-1@1-22",
    "value": "63",
    "objectType": "guild",
    "objectIndex": "1",
    "objectId": "0-1",
    "playerId": "1-22"
  }
]
```

### 2. Filter for Specific Player

Find permission for a specific player.

**Filter**: `playerId` = `1-11`

**Matching Permission**:

```json
{
  "permissionId": "0-1@1-11",
  "value": "127"
}
```

### 3. Check Hash Permission

Check if permission value includes Hash permission bit (64).

**Check**:

```javascript
(parseInt(permission.value) & 64) !== 0
```

**Example**:

| Permission Value | Has Hash Permission | Explanation |
|------------------|---------------------|-------------|
| `127` | Yes | `127 & 64 = 64` (non-zero, has Hash permission) |

### 4. Check Other Permissions

Check for other permission bits if needed.

| Permission Value | Description |
|------------------|-------------|
| 127 | Has all permissions including Hash |
| 63 | Has standard permissions but not Hash |
| 64 | Has Hash permission only |

## Alternative Workflow: Query Player Permissions

### 1. Query Player Permissions

Get all permissions for a player.

- **Method**: `GET`
- **Endpoint**: `/structs/permission/player/{playerId}`

**Request Example** (`playerId`: `1-11`):

**Expected Response**:

```json
[
  {
    "permissionId": "0-1@1-11",
    "value": "127",
    "objectId": "0-1",
    "playerId": "1-11"
  },
  {
    "permissionId": "2-1@1-11",
    "value": "64",
    "objectId": "2-1",
    "playerId": "1-11"
  }
]
```

### 2. Filter Permissions with Hash

Find all permissions that include Hash permission bit.

**Filter**:

```javascript
permissions.filter(p => (parseInt(p.value) & 64) !== 0)
```

**Result**:

```json
[
  {
    "permissionId": "0-1@1-11",
    "value": "127",
    "hasHashPermission": true
  },
  {
    "permissionId": "2-1@1-11",
    "value": "64",
    "hasHashPermission": true
  }
]
```

## Use Cases

| Use Case | Description | Workflow |
|----------|-------------|----------|
| Before transaction signing | Check Hash permission before signing transaction | Check if player has Hash permission on relevant object before allowing transaction signing |
| Access control | Control access to objects based on Hash permission | Verify Hash permission before allowing access to protected resources |
| Permission audit | Audit all Hash permissions for a player or object | Query and filter permissions to find all Hash permission grants |
