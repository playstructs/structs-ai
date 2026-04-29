# Permission Checking Workflow

**Version**: 2.0.0
**Category**: Authentication

---

## Description

Workflow for checking permissions in the 25-bit permission system (bits 0-24, `PermAll` = 33554431). Permissions use HasAll semantics — all required bits must be present. The check flow resolves in order: address → ownership → object permission → guild rank permission. UGC name/pfp updates on player, planet, and substation objects use a slightly different flow that falls back from `PermUpdate` (4) on the target to `PermGuildUGCUpdate` (16777216) on the target owner's guild — see `knowledge/mechanics/ugc-moderation.md`.

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
    "value": "33554431",
    "objectType": "guild",
    "objectIndex": "1",
    "objectId": "0-1",
    "playerId": "1-11"
  },
  {
    "permissionId": "0-1@1-22",
    "value": "1048575",
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
  "value": "33554431"
}
```

### 3. Check Hash Permissions (HasAll)

Check if permission value includes the required hash permission bits. Use HasAll semantics: `(value & required) == required`.

**Check all hash permissions**:

```javascript
const value = parseInt(permission.value);
(value & 15728640) === 15728640  // HasAll hash bits
```

**Check specific hash permission**:

```javascript
(value & 2097152) === 2097152  // HasAll for PermHashMine
```

**Example**:

| Permission Value | Check | Result | Explanation |
|------------------|-------|--------|-------------|
| `33554431` | `& 15728640 === 15728640` | Yes | PermAll includes all hash bits |
| `2097152` | `& 15728640 === 15728640` | No | Only PermHashMine, missing Build/Refine/Raid |
| `2097152` | `& 2097152 === 2097152` | Yes | Has PermHashMine specifically |

### 4. Check Guild Rank Permissions

After object-level permissions are resolved, guild rank permissions provide an additional layer. If the player is in a guild, their rank's permissions are also checked.

**Query guild rank permissions**:

```
GET /structs/permission/guild-rank/{guildId}/{rank}
```

**Check guild rank includes required bits**:

```javascript
const rankValue = parseInt(guildRankPermission.value);
const required = 2097152; // PermHashMine
(rankValue & required) === required  // HasAll check
```

**Set guild rank permissions** (if missing):

```bash
structsd tx structs permission-guild-rank-set \
  --from keyname --gas auto -y -- 0-1 1 33554431
```

**Revoke guild rank permissions**:

```bash
structsd tx structs permission-guild-rank-revoke \
  --from keyname --gas auto -y -- 0-1 1
```

### 5. Check Other Permissions

Check for other permission bits if needed.

| Permission Value | Description |
|------------------|-------------|
| 33554431 | PermAll — has all 25 permission bits including UGC moderation |
| 16777216 | PermGuildUGCUpdate only — guild moderation flag (bit 24) |
| 15728640 | PermHashAll — has all four hash permission bits only |
| 1048576 | PermHashBuild only |
| 2097152 | PermHashMine only |
| 4194304 | PermHashRefine only |
| 8388608 | PermHashRaid only |

## Permission Check Flow

The full permission resolution flow, in order:

1. **Address check** — Is the signing address registered to the player?
2. **Ownership check** — Does the player own the object?
3. **Object permission check** — Does the player have the required permission bits on the object? (HasAll semantics)
4. **Guild rank permission check** — Does the player's guild rank include the required permission bits? (HasAll semantics)

A failure at any step blocks the action. When troubleshooting, check each step in order.

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
    "value": "33554431",
    "objectId": "0-1",
    "playerId": "1-11"
  },
  {
    "permissionId": "2-1@1-11",
    "value": "2097152",
    "objectId": "2-1",
    "playerId": "1-11"
  }
]
```

### 2. Filter Permissions with Hash

Find all permissions that include all hash permission bits (HasAll).

**Filter**:

```javascript
permissions.filter(p => {
  const value = parseInt(p.value);
  return (value & 15728640) === 15728640;
})
```

**Result**:

```json
[
  {
    "permissionId": "0-1@1-11",
    "value": "33554431",
    "hasAllHashPermissions": true
  }
]
```

Only the first permission (33554431) has all hash bits. The second (2097152) only has PermHashMine and would not pass the PermHashAll check.

## Use Cases

| Use Case | Description | Workflow |
|----------|-------------|----------|
| Before transaction signing | Check specific hash permission before signing | Verify the player has the required hash bit (e.g., PermHashMine for mining) on the relevant object |
| Access control | Control access to objects based on hash permissions | Verify hash permission bits using HasAll before allowing access |
| Permission audit | Audit all hash permissions for a player or object | Query and filter permissions checking specific hash bits |
| Guild rank setup | Ensure guild members have correct permissions | Set guild rank permissions with `permission-guild-rank-set` |
