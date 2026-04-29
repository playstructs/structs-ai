# Permission Examples

**Version**: 2.0.0
**Category**: Authentication
**Purpose**: Permission bit manipulation, checking, combination, and validation for the 25-bit permission system

---

## Overview

Permissions are 25-bit flags (bits 0-24, PermAll = 33554431). Bit 24 (`PermGuildUGCUpdate` = 16777216) was added in v0.16.0 to gate guild-moderated name/pfp updates on player, planet, and substation objects. Permission checks use **HasAll** semantics — all required bits must be present, not just any one.

## Permission Bit Values

| Permission | Bit(s) | Value | Description |
|------------|--------|-------|-------------|
| PermAll | 0-24 | 33554431 | Full permission set (all 25 bits) |
| PermHashBuild | 20 | 1048576 | Hash permission for building |
| PermHashMine | 21 | 2097152 | Hash permission for mining |
| PermHashRefine | 22 | 4194304 | Hash permission for refining |
| PermHashRaid | 23 | 8388608 | Hash permission for raiding |
| PermHashAll | 20-23 | 15728640 | All hash permissions combined |
| PermGuildUGCUpdate | 24 | 16777216 | Guild moderation of UGC name/pfp on player/planet/substation |
| Standard (bits 0-19) | 0-19 | varies | Use specific flags for the permissions you need |

## Bit Manipulation

### Check Hash Permission (HasAll)

Determine whether a permission value includes all hash permission bits. Uses HasAll: `(value & required) == required`.

JavaScript:

```javascript
const PERM_HASH_ALL = 15728640;
const PERM_HASH_BUILD = 1048576;
const PERM_HASH_MINE = 2097152;
const PERM_HASH_REFINE = 4194304;
const PERM_HASH_RAID = 8388608;

const hasAllHashPermissions = (permissionValue) => {
  const value = parseInt(permissionValue);
  return (value & PERM_HASH_ALL) === PERM_HASH_ALL;
};

const hasHashMine = (permissionValue) => {
  const value = parseInt(permissionValue);
  return (value & PERM_HASH_MINE) === PERM_HASH_MINE;
};
```

Python:

```python
PERM_HASH_ALL = 15728640
PERM_HASH_BUILD = 1048576
PERM_HASH_MINE = 2097152
PERM_HASH_REFINE = 4194304
PERM_HASH_RAID = 8388608

def has_all_hash_permissions(permission_value):
    return (int(permission_value) & PERM_HASH_ALL) == PERM_HASH_ALL

def has_hash_mine(permission_value):
    return (int(permission_value) & PERM_HASH_MINE) == PERM_HASH_MINE
```

Go:

```go
const (
    PermHashBuild      = 1048576
    PermHashMine       = 2097152
    PermHashRefine     = 4194304
    PermHashRaid       = 8388608
    PermHashAll        = 15728640
    PermGuildUGCUpdate = 16777216
    PermAll            = 33554431
)

func hasAllHashPermissions(permissionValue int) bool {
    return (permissionValue & PermHashAll) == PermHashAll
}

func hasHashMine(permissionValue int) bool {
    return (permissionValue & PermHashMine) == PermHashMine
}
```

Examples:

| Permission Value | Has All Hash? | Has Hash Mine? | Explanation |
|-----------------|---------------|----------------|-------------|
| `33554431` | Yes | Yes | PermAll includes all hash bits |
| `16777215` | Yes | Yes | Pre-v0.16.0 PermAll (no UGC bit) — still has all hash bits |
| `15728640` | Yes | Yes | PermHashAll is exactly all hash bits |
| `2097152` | No | Yes | Only PermHashMine set |
| `1048575` | No | No | Bits 0-19 only, no hash bits |

### Add Hash Permissions

Add hash permission bits to an existing permission value using bitwise OR.

JavaScript:

```javascript
const addAllHashPermissions = (permissionValue) => parseInt(permissionValue) | PERM_HASH_ALL;
const addHashMine = (permissionValue) => parseInt(permissionValue) | PERM_HASH_MINE;
```

Python:

```python
def add_all_hash_permissions(permission_value):
    return int(permission_value) | PERM_HASH_ALL

def add_hash_mine(permission_value):
    return int(permission_value) | PERM_HASH_MINE
```

Go:

```go
func addAllHashPermissions(permissionValue int) int {
    return permissionValue | PermHashAll
}

func addHashMine(permissionValue int) int {
    return permissionValue | PermHashMine
}
```

Examples:

| Before | Operation | After | Explanation |
|--------|-----------|-------|-------------|
| `1048575` | `\| 15728640` | `16777215` | Add PermHashAll to standard perms → bits 0-23 set |
| `0` | `\| 2097152` | `2097152` | Add PermHashMine to no permissions |
| `33554431` | `\| 15728640` | `33554431` | Already has all bits, no change |
| `16777215` | `\| 16777216` | `33554431` | Add PermGuildUGCUpdate to bits 0-23 → PermAll |

### Remove Hash Permissions

Remove hash permission bits from an existing permission value using bitwise AND with complement.

JavaScript:

```javascript
const removeAllHashPermissions = (permissionValue) => parseInt(permissionValue) & ~PERM_HASH_ALL;
const removeHashMine = (permissionValue) => parseInt(permissionValue) & ~PERM_HASH_MINE;
```

Python:

```python
def remove_all_hash_permissions(permission_value):
    return int(permission_value) & ~PERM_HASH_ALL

def remove_hash_mine(permission_value):
    return int(permission_value) & ~PERM_HASH_MINE
```

Go:

```go
func removeAllHashPermissions(permissionValue int) int {
    return permissionValue & ^PermHashAll
}

func removeHashMine(permissionValue int) int {
    return permissionValue & ^PermHashMine
}
```

Examples:

| Before | Operation | After | Explanation |
|--------|-----------|-------|-------------|
| `33554431` | `& ~15728640` | `17825791` | Remove all hash from PermAll, retains UGC bit |
| `33554431` | `& ~16777216` | `16777215` | Remove only PermGuildUGCUpdate from PermAll |
| `15728640` | `& ~15728640` | `0` | Remove all hash, leaves nothing |
| `2097152` | `& ~2097152` | `0` | Remove PermHashMine, leaves nothing |
| `15728640` | `& ~2097152` | `13631488` | Remove PermHashMine, keep other hash bits |

### Toggle Hash Permission

Toggle a hash permission bit (add if missing, remove if present) using bitwise XOR.

JavaScript:

```javascript
const toggleHashMine = (permissionValue) => parseInt(permissionValue) ^ PERM_HASH_MINE;
```

Python:

```python
def toggle_hash_mine(permission_value):
    return int(permission_value) ^ PERM_HASH_MINE
```

Go:

```go
func toggleHashMine(permissionValue int) int {
    return permissionValue ^ PermHashMine
}
```

Examples:

| Before | After | Explanation |
|--------|-------|-------------|
| `1048575` | `3145727` | Adds PermHashMine (was missing) |
| `3145727` | `1048575` | Removes PermHashMine (was present) |

## Permission Checking Workflows

### Check Permission on a Specific Object

**Step 1**: Query permissions for the object.

```
GET /structs/permission/object/{objectId}
```

Example response for `objectId` = `0-1`:

```json
[
  {
    "permissionId": "0-1@1-11",
    "value": "33554431",
    "objectId": "0-1",
    "playerId": "1-11"
  }
]
```

**Step 2**: Filter for the target player.

```
filter: permission.playerId === "1-11"
```

**Step 3**: Check hash permissions using HasAll.

```javascript
const value = parseInt("33554431");
(value & 15728640) === 15728640  // true — has all hash permissions
(value & 2097152) === 2097152    // true — has PermHashMine specifically
(value & 16777216) === 16777216  // true — has PermGuildUGCUpdate
```

### Check All Permissions for a Player

**Step 1**: Query all permissions for the player.

```
GET /structs/permission/player/{playerId}
```

Example response for `playerId` = `1-11`:

```json
[
  { "permissionId": "0-1@1-11", "value": "33554431", "objectId": "0-1", "playerId": "1-11" },
  { "permissionId": "2-1@1-11", "value": "2097152", "objectId": "2-1", "playerId": "1-11" }
]
```

**Step 2**: Filter permissions that include a specific hash bit (HasAll check).

```javascript
permissions.filter(p => {
  const value = parseInt(p.value);
  return (value & 15728640) === 15728640;
})
```

Only the first permission (33554431) includes all hash bits. The second (2097152) only has PermHashMine.

## Permission Combination

### Combine Multiple Permission Bits

Use bitwise OR to combine multiple permission bits into a single value.

JavaScript:

```javascript
const combinePermissions = (...bits) => bits.reduce((acc, bit) => acc | bit, 0);
```

Python:

```python
def combine_permissions(*bits):
    return reduce(lambda acc, bit: acc | bit, bits, 0)
```

Go:

```go
func combinePermissions(bits ...int) int {
    result := 0
    for _, bit := range bits {
        result |= bit
    }
    return result
}
```

Examples:

| Input Bits | Combined | Explanation |
|-----------|----------|-------------|
| 1048576, 2097152 | 3145728 | PermHashBuild + PermHashMine |
| 1048576, 2097152, 4194304, 8388608 | 15728640 | All four hash bits = PermHashAll |
| 1, 2, 4, 1048576 | 1048583 | Selected standard bits + PermHashBuild |

### Check Multiple Permission Bits (HasAll)

Verify that a permission value includes **all** required bits. This is the correct HasAll pattern.

JavaScript:

```javascript
const hasAllPermissions = (permissionValue, requiredMask) => {
  const value = parseInt(permissionValue);
  return (value & requiredMask) === requiredMask;
};
```

Python:

```python
def has_all_permissions(permission_value, required_mask):
    value = int(permission_value)
    return (value & required_mask) == required_mask
```

Go:

```go
func hasAllPermissions(permissionValue int, requiredMask int) bool {
    return (permissionValue & requiredMask) == requiredMask
}
```

Examples:

| Permission Value | Required Mask | Result | Explanation |
|-----------------|---------------|--------|-------------|
| `33554431` | `15728640` | true | PermAll has all hash bits |
| `33554431` | `16777216` | true | PermAll has PermGuildUGCUpdate |
| `2097152` | `15728640` | false | Only PermHashMine, missing other hash bits |
| `3145728` | `3145728` | true | Has both PermHashBuild and PermHashMine |

## Permission Validation

### Validate Permission Value Range

Permission values must be integers between 0 and 33554431 inclusive.

JavaScript:

```javascript
const isValidPermissionValue = (value) => {
  const num = parseInt(value);
  return num >= 0 && num <= 33554431 && Number.isInteger(num);
};
```

Python:

```python
def is_valid_permission_value(value):
    try:
        num = int(value)
        return 0 <= num <= 33554431
    except ValueError:
        return False
```

Go:

```go
func isValidPermissionValue(value string) bool {
    num, err := strconv.Atoi(value)
    if err != nil {
        return false
    }
    return num >= 0 && num <= 33554431
}
```

Examples:

| Value | Valid? | Reason |
|-------|--------|--------|
| `33554431` | Yes | PermAll, maximum valid value |
| `16777216` | Yes | PermGuildUGCUpdate alone (bit 24) |
| `16777215` | Yes | All bits 0-23 (pre-v0.16.0 PermAll, no UGC bit) |
| `15728640` | Yes | PermHashAll |
| `2097152` | Yes | PermHashMine only |
| `33554432` | No | Exceeds maximum (33554431) |
| `-1` | No | Negative values not allowed |
| `abc` | No | Not a valid number |

### Validate Hash Permission in Database

Query the database to verify hash permission state:

```sql
SELECT permission_hash_build, permission_hash_mine, permission_hash_refine, permission_hash_raid
FROM permission WHERE object_id = ? AND player_id = ?
```

Database to API mapping:

| Database Column | Bit | API Equivalent |
|----------------|-----|---------------|
| `permission_hash_build = true` | 20 | `(permission.value & 1048576) == 1048576` |
| `permission_hash_mine = true` | 21 | `(permission.value & 2097152) == 2097152` |
| `permission_hash_refine = true` | 22 | `(permission.value & 4194304) == 4194304` |
| `permission_hash_raid = true` | 23 | `(permission.value & 8388608) == 8388608` |

## Guild Rank Permissions

Guild rank permissions are an additional layer in the permission check flow. They are checked after object-level permissions (address → ownership → object → guild rank).

### Set Guild Rank Permissions

Grant permissions at a specific guild rank level:

```bash
structsd tx structs permission-guild-rank-set \
  --from keyname --gas auto -y -- 0-1 1 33554431
```

Arguments: `{guildId} {rank} {permissionValue}`

### Revoke Guild Rank Permissions

Remove all permissions from a specific guild rank:

```bash
structsd tx structs permission-guild-rank-revoke \
  --from keyname --gas auto -y -- 0-1 1
```

Arguments: `{guildId} {rank}`

### Check Guild Rank Permissions

Query a player's guild rank permissions to verify they have the required bits:

```javascript
const guildRankValue = parseInt(guildRankPermission.value);
const requiredForMining = 2097152; // PermHashMine
const canMine = (guildRankValue & requiredForMining) === requiredForMining;
```

### Grant PermAll at Guild Rank

To give a rank full permissions including all hash operations and guild UGC moderation:

```bash
structsd tx structs permission-guild-rank-set \
  --from keyname --gas auto -y -- 0-1 1 33554431
```

## Example Workflows

### Grant Hash Permissions

1. Check current permission: `GET /structs/permission/object/{objectId}`, filter by `playerId`
2. Calculate new value: `newValue = currentValue | 15728640` (adds all hash bits)
3. Update permission via the appropriate transaction

### Revoke Hash Permissions

1. Check current permission: `GET /structs/permission/object/{objectId}`, filter by `playerId`
2. Calculate new value: `newValue = currentValue & ~15728640` (removes all hash bits)
3. Update permission via the appropriate transaction

### Grant Only Mining Hash

1. Check current permission
2. Calculate new value: `newValue = currentValue | 2097152` (adds PermHashMine only)
3. Update permission via the appropriate transaction

### Check Before Transaction

1. Query player permissions: `GET /structs/permission/player/{playerId}`
2. Identify the required hash bit for the operation (e.g., PermHashMine = 2097152)
3. Check with HasAll: `(parseInt(permission.value) & 2097152) === 2097152`
4. Proceed with the transaction only if the check passes

## Cross-References

- Database query examples: [examples/database/query-examples.md](../database/query-examples.md)
- Authentication protocol: [protocols/authentication.md](../../protocols/authentication.md)
- Transaction signing: [examples/auth/consensus-transaction-signing.md](consensus-transaction-signing.md)
- Validation schema: [schemas/validation.md](../../schemas/validation.md)
- Permission checking workflow: [examples/workflows/permission-checking.md](../workflows/permission-checking.md)
