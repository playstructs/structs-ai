# Hash Permission Examples

**Version**: 1.0.0
**Category**: Authentication
**Purpose**: Hash permission bit manipulation, checking, combination, and validation (v0.8.0-beta)

---

## Overview

The Hash permission (bit value 64) was introduced in v0.8.0-beta to control transaction signing with Hash permission level. This document covers bit manipulation patterns, permission checking workflows, combination operations, and validation logic with code examples in JavaScript, Python, and Go.

## Permission Bit Values

| Permission | Value | Binary | Description |
|------------|-------|--------|-------------|
| All permissions (including Hash) | 127 | `1111111` | Full permission set: 1+2+4+8+16+32+64 |
| Hash only | 64 | `1000000` | Hash permission only |
| Standard (without Hash) | 63 | `0111111` | Standard permissions: 1+2+4+8+16+32 |

## Bit Manipulation

### Check Hash Permission

Determine whether a permission value includes the Hash permission bit.

JavaScript:

```javascript
const hasHashPermission = (permissionValue) => (parseInt(permissionValue) & 64) !== 0;
```

Python:

```python
def has_hash_permission(permission_value):
    return (int(permission_value) & 64) != 0
```

Go:

```go
func hasHashPermission(permissionValue int) bool {
    return (permissionValue & 64) != 0
}
```

Examples:

| Permission Value | Has Hash? | Explanation |
|-----------------|-----------|-------------|
| `127` | Yes | 127 includes bit 64 |
| `64` | Yes | 64 is exactly the Hash bit |
| `63` | No | 63 does not include bit 64 |

### Add Hash Permission

Add the Hash permission bit to an existing permission value using bitwise OR.

JavaScript:

```javascript
const addHashPermission = (permissionValue) => parseInt(permissionValue) | 64;
```

Python:

```python
def add_hash_permission(permission_value):
    return int(permission_value) | 64
```

Go:

```go
func addHashPermission(permissionValue int) int {
    return permissionValue | 64
}
```

Examples:

| Before | After | Explanation |
|--------|-------|-------------|
| `63` | `127` | Adds Hash to standard permissions |
| `0` | `64` | Adds Hash to no permissions |
| `127` | `127` | Already has Hash, no change |

### Remove Hash Permission

Remove the Hash permission bit from an existing permission value using bitwise AND with complement.

JavaScript:

```javascript
const removeHashPermission = (permissionValue) => parseInt(permissionValue) & ~64;
```

Python:

```python
def remove_hash_permission(permission_value):
    return int(permission_value) & ~64
```

Go:

```go
func removeHashPermission(permissionValue int) int {
    return permissionValue & ^64
}
```

Examples:

| Before | After | Explanation |
|--------|-------|-------------|
| `127` | `63` | Removes Hash from all permissions |
| `64` | `0` | Removes Hash, leaves no permissions |
| `63` | `63` | No Hash to remove, no change |

### Toggle Hash Permission

Toggle the Hash permission bit (add if missing, remove if present) using bitwise XOR.

JavaScript:

```javascript
const toggleHashPermission = (permissionValue) => parseInt(permissionValue) ^ 64;
```

Python:

```python
def toggle_hash_permission(permission_value):
    return int(permission_value) ^ 64
```

Go:

```go
func toggleHashPermission(permissionValue int) int {
    return permissionValue ^ 64
}
```

Examples:

| Before | After | Explanation |
|--------|-------|-------------|
| `63` | `127` | Adds Hash (was missing) |
| `127` | `63` | Removes Hash (was present) |

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
    "value": "127",
    "objectId": "0-1",
    "playerId": "1-11"
  }
]
```

**Step 2**: Filter for the target player.

```
filter: permission.playerId === "1-11"
```

**Step 3**: Check the Hash permission bit.

```
(parseInt("127") & 64) !== 0  // true
```

### Check All Permissions for a Player

**Step 1**: Query all permissions for the player.

```
GET /structs/permission/player/{playerId}
```

Example response for `playerId` = `1-11`:

```json
[
  { "permissionId": "0-1@1-11", "value": "127", "objectId": "0-1", "playerId": "1-11" },
  { "permissionId": "2-1@1-11", "value": "64", "objectId": "2-1", "playerId": "1-11" }
]
```

**Step 2**: Filter permissions that include the Hash bit.

```javascript
permissions.filter(p => (parseInt(p.value) & 64) !== 0)
```

Both permissions above include the Hash bit (127 and 64 both have bit 64 set).

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
| 63, 64 | 127 | Standard permissions + Hash |
| 1, 2, 4, 64 | 71 | Selected bits combined |

### Check Multiple Permission Bits

Verify that a permission value includes all required bits.

JavaScript:

```javascript
const hasAllPermissions = (permissionValue, ...requiredBits) => {
  const value = parseInt(permissionValue);
  return requiredBits.every(bit => (value & bit) !== 0);
};
```

Python:

```python
def has_all_permissions(permission_value, *required_bits):
    value = int(permission_value)
    return all((value & bit) != 0 for bit in required_bits)
```

Go:

```go
func hasAllPermissions(permissionValue int, requiredBits ...int) bool {
    for _, bit := range requiredBits {
        if (permissionValue & bit) == 0 {
            return false
        }
    }
    return true
}
```

Examples:

| Permission Value | Required Bits | Result | Explanation |
|-----------------|---------------|--------|-------------|
| `127` | 63, 64 | true | Has both standard and Hash |
| `63` | 63, 64 | false | Has standard but missing Hash |

## Permission Validation

### Validate Permission Value Range

Permission values must be integers between 0 and 127 inclusive.

JavaScript:

```javascript
const isValidPermissionValue = (value) => {
  const num = parseInt(value);
  return num >= 0 && num <= 127 && Number.isInteger(num);
};
```

Python:

```python
def is_valid_permission_value(value):
    try:
        num = int(value)
        return 0 <= num <= 127
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
    return num >= 0 && num <= 127
}
```

Examples:

| Value | Valid? | Reason |
|-------|--------|--------|
| `127` | Yes | Maximum valid value |
| `64` | Yes | Hash only |
| `128` | No | Exceeds maximum (127) |
| `-1` | No | Negative values not allowed |
| `abc` | No | Not a valid number |

### Validate Hash Permission in Database

Query the database to verify Hash permission format:

```sql
SELECT permission_hash FROM permission WHERE object_id = ? AND player_id = ?
```

Expected values:
- Has Hash permission: `permission_hash = true` or `permission_hash = 1`
- No Hash permission: `permission_hash = false` or `permission_hash = 0`

Database to API mapping:

| Database | API Equivalent |
|----------|---------------|
| `permission_hash = true` | `permission.value & 64 !== 0` |
| `permission_hash = false` | `permission.value & 64 === 0` |

## Example Workflows

### Grant Hash Permission

1. Check current permission: `GET /structs/permission/object/{objectId}`, filter by `playerId`
2. Calculate new value: `newValue = currentValue | 64` (e.g., 63 becomes 127)
3. Update permission via the appropriate transaction

### Revoke Hash Permission

1. Check current permission: `GET /structs/permission/object/{objectId}`, filter by `playerId`
2. Calculate new value: `newValue = currentValue & ~64` (e.g., 127 becomes 63)
3. Update permission via the appropriate transaction

### Check Before Transaction

1. Query player permissions: `GET /structs/permission/player/{playerId}`
2. Check if the player has Hash permission on the relevant object: `(parseInt(permission.value) & 64) !== 0`
3. Proceed with the transaction only if `hasHashPermission === true`

## Cross-References

- Database query examples: [examples/database/query-examples.md](../database/query-examples.md)
- Authentication protocol: [protocols/authentication.md](../../protocols/authentication.md)
- Transaction signing: [examples/auth/consensus-transaction-signing.md](consensus-transaction-signing.md)
- Validation schema: [schemas/validation.md](../../schemas/validation.md)
