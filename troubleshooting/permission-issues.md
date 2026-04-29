# Permission Troubleshooting

**Version**: 2.0.0  
**Category**: Troubleshooting  
**Status**: Stable  
**Last Updated**: March 26, 2026

## Overview

This guide helps troubleshoot issues with permissions and permission bit manipulation. Permission values are 25-bit flags (bits 0-24) combined using bitwise OR. The maximum value (PermAll) is `33554431`.

Bit 24 (`PermGuildUGCUpdate`, value `16777216`) was added in v0.16.0 for guild-moderated UGC (name/pfp) updates on player, planet, and substation objects. See `knowledge/mechanics/ugc-moderation.md`.

The permission system uses **HasAll** semantics: all required bits must be present in the permission value. A check like `(value & required) == required` must match every bit — a single matching bit is not sufficient.

### Hash Permission Split

The old single Hash permission has been replaced by four granular hash permissions:

| Permission | Bit | Value | Description |
|------------|-----|-------|-------------|
| PermHashBuild | 20 | 1048576 | Hash permission for building |
| PermHashMine | 21 | 2097152 | Hash permission for mining |
| PermHashRefine | 22 | 4194304 | Hash permission for refining |
| PermHashRaid | 23 | 8388608 | Hash permission for raiding |
| **PermHashAll** | 20-23 | **15728640** | All hash permissions combined |

---

## Common Issues

### Issue 1: Permission Check Fails — Hash Permission Not Set

**Symptom**: Permission check fails even though permission should be granted

**Cause**: Required hash permission bits not included in permission value. With the split hash permissions, you may have some hash bits but not the specific one required for the operation.

**Diagnosis**:
1. Query permission: `GET /structs/permission/{permissionId}`
2. Check `permission.value` (numeric string)
3. Identify which hash bit is needed (e.g., PermHashMine = 2097152 for mining)
4. Check: `(value & 2097152) == 2097152`
5. If false, that specific hash permission is not set

**Solution**:
1. Grant the specific hash permission bit needed for the operation
2. Or grant PermHashAll (15728640) for all hash operations
3. Combine with existing permissions: `newValue = oldValue | 15728640`
4. Verify: `(newValue & 15728640) == 15728640`

**Example**:
```json
{
  "permissionId": "0-1@1-11",
  "oldValue": "1048575",
  "newValue": "16777215",
  "calculation": "1048575 | 15728640 = 16777215",
  "hashAllCheck": "(16777215 & 15728640) == 15728640 ✓",
  "hashMineCheck": "(16777215 & 2097152) == 2097152 ✓"
}
```

To grant `PermAll` (every bit including the new `PermGuildUGCUpdate` bit 24), use `33554431` instead of `16777215`.

**Reference**: `schemas/game-state.md#/definitions/Permission`, `api/queries/permission.md`

---

### Issue 2: Permission Value Incorrect — Bit Manipulation Error

**Symptom**: Permission value doesn't match expected combination

**Cause**: Incorrect bitwise OR operation or using old 8-bit values

**Diagnosis**:
1. Query permission: `GET /structs/permission/{permissionId}`
2. Check `permission.value`
3. Verify bit combination logic
4. Common values:
   - `33554431` — PermAll (all 25-bit permissions)
   - `16777216` — PermGuildUGCUpdate only (guild moderation flag, bit 24)
   - `16777215` — Pre-v0.16.0 PermAll (all 24 lower bits without `PermGuildUGCUpdate`)
   - `15728640` — PermHashAll only (all four hash bits)
   - `1048576` — PermHashBuild only
   - `2097152` — PermHashMine only
   - `4194304` — PermHashRefine only
   - `8388608` — PermHashRaid only

**Solution**:
1. Use bitwise OR to combine permissions: `value = permission1 | permission2`
2. Use HasAll to check permissions: `(value & required) == required`
3. Remember: there is no single "non-hash" composite value — use specific flags for the bits you need

**Reference**: `schemas/game-state.md#/definitions/Permission`, `schemas/entities.md#/definitions/Permission`

---

### Issue 3: Permission Query Returns Wrong Object

**Symptom**: Permission query returns permission for different object

**Cause**: Incorrect permission ID format or object ID

**Diagnosis**:
1. Check permission ID format: `{objectId}@{playerId}`
2. Verify object ID format: `type-index` (e.g., `0-1` for guild, `2-1` for planet)
3. Verify player ID format: `1-{index}`
4. Check `permission.objectId` matches expected object

**Solution**:
1. Use correct permission ID format: `{objectId}@{playerId}`
2. Verify object ID is correct entity type
3. Query by object: `GET /structs/permission/object/{objectId}`
4. Query by player: `GET /structs/permission/player/{playerId}`

**Reference**: `api/queries/permission.md`, `schemas/formats.md`

---

### Issue 4: HasAll vs HasOneOf Semantics Mismatch

**Symptom**: Permission check passes when it should fail, or fails when it should pass

**Cause**: Using old HasOneOf check (`(value & required) != 0`) instead of new HasAll check (`(value & required) == required`)

**Diagnosis**:
1. Identify the check pattern in your code
2. Old pattern (wrong): `(value & required) != 0` — passes if *any* required bit is set
3. New pattern (correct): `(value & required) == required` — passes only if *all* required bits are set

**Example**:
```json
{
  "value": 1048576,
  "required": 15728640,
  "hasOneOf_WRONG": "(1048576 & 15728640) != 0 → true (only PermHashBuild set)",
  "hasAll_CORRECT": "(1048576 & 15728640) == 15728640 → false (missing Mine, Refine, Raid)"
}
```

**Solution**:
1. Replace all `!= 0` permission checks with `== required` checks
2. If you only need to check a single bit, both patterns are equivalent
3. For composite checks (e.g., PermHashAll), HasAll ensures all bits are present

**Reference**: `schemas/game-state.md#/definitions/Permission`

---

### Issue 5: Database Permission Hash Not Found

**Symptom**: Database query for hash permission returns no results

**Cause**: Hash permission levels not set or query references old schema

**Diagnosis**:
1. Check database schema: `structs.permission` table
2. Verify hash permission columns exist (permission_hash_build, permission_hash_mine, permission_hash_refine, permission_hash_raid)
3. Check permission view: `view.permission`
4. Verify the relevant hash permission bits are set in the API value

**Solution**:
1. Verify hash permission columns exist in database
2. Check permission value includes the relevant hash bits (e.g., `& 2097152` for mine)
3. Query permission view for hash permissions
4. Verify API permission value matches database state

**Reference**: `schemas/database-schema.md`, `api/queries/permission.md`

---

### Issue 6: Transaction Signing Fails — Hash Permission Required

**Symptom**: Transaction signing fails with permission error

**Cause**: Specific hash permission not granted for the operation type

**Diagnosis**:
1. Identify which operation is being attempted (build, mine, refine, raid)
2. Check if the corresponding hash permission bit is set:
   - Build operations: `(value & 1048576) == 1048576`
   - Mine operations: `(value & 2097152) == 2097152`
   - Refine operations: `(value & 4194304) == 4194304`
   - Raid operations: `(value & 8388608) == 8388608`
3. Check signer_tx permission levels

**Solution**:
1. Grant the specific hash permission for the operation type
2. Or grant PermHashAll (15728640) for all hash operations
3. Verify permission value includes the correct hash bit
4. Retry transaction signing

**Reference**: `schemas/database-schema.md#/tables/signer_tx`, `schemas/entities.md#/definitions/Permission`

---

### Issue 7: Permission Combination Produces Unexpected Value

**Symptom**: Combining permissions produces wrong value

**Cause**: Incorrect bitwise operation, using old values, or value overflow

**Diagnosis**:
1. Check permission values being combined
2. Verify bitwise OR operation: `value1 | value2`
3. Verify permission bits are valid (0-24)
4. Maximum valid value: 33554431 (PermAll)

**Solution**:
1. Use correct bitwise operations:
   - Combine: `value = value1 | value2`
   - Check (HasAll): `(value & required) == required`
   - Remove: `value = value & ~bits`
2. Verify values are within valid range (0 to 33554431)
3. Test bit combinations before applying

**Example**:
```json
{
  "permission1": 1048575,
  "permission2": 15728640,
  "combined": "1048575 | 15728640 = 16777215",
  "checkHashAll": "(16777215 & 15728640) == 15728640 ✓",
  "removeHashAll": "16777215 & ~15728640 = 1048575"
}
```

**Reference**: `schemas/game-state.md#/definitions/Permission`

---

### Issue 8: Guild Rank Permission Not Applied

**Symptom**: Player cannot perform action despite having object-level permission

**Cause**: Guild rank permissions override or supplement object-level permissions. The permission check flow is: address → ownership → object permission → guild rank permission. A missing guild rank permission can block an action even if the object permission is set.

**Diagnosis**:
1. Verify the player's guild membership
2. Query guild rank permissions for the player
3. Check that guild rank includes the required permission bits
4. Remember HasAll semantics — all required bits must be present in the guild rank

**Solution**:
1. Use `permission-guild-rank-set` to grant the required permissions at the guild rank level
2. Verify the guild rank permission value includes all required bits
3. If the player's guild rank was recently changed, re-query to confirm the new rank's permissions

**CLI Example**:
```bash
# Set guild rank permissions (grant PermAll to rank)
structsd tx structs permission-guild-rank-set \
  --from keyname --gas auto -y -- 0-1 1 33554431

# Revoke guild rank permissions
structsd tx structs permission-guild-rank-revoke \
  --from keyname --gas auto -y -- 0-1 1
```

**Reference**: `schemas/actions.md`, `api/queries/permission.md`

---

## Permission Bit Reference

### 25-Bit Permission Flags

| Bits | Name | Value | Description |
|------|------|-------|-------------|
| 0-19 | Standard permissions | 1 - 524288 | Various gameplay permissions |
| 20 | PermHashBuild | 1048576 | Hash permission for building |
| 21 | PermHashMine | 2097152 | Hash permission for mining |
| 22 | PermHashRefine | 4194304 | Hash permission for refining |
| 23 | PermHashRaid | 8388608 | Hash permission for raiding |
| 24 | PermGuildUGCUpdate | 16777216 | Guild moderation of name/pfp on player, planet, substation |

### Common Permission Values

- **0**: No permissions
- **1048576**: PermHashBuild only
- **2097152**: PermHashMine only
- **4194304**: PermHashRefine only
- **8388608**: PermHashRaid only
- **15728640**: PermHashAll (all four hash bits, bits 20-23)
- **16777215**: Pre-v0.16.0 PermAll (bits 0-23, no UGC moderation)
- **16777216**: PermGuildUGCUpdate only (bit 24)
- **33554431**: PermAll (all permissions, bits 0-24)

---

## Verification Steps

### Check Hash Permission (All Hash Bits)

1. Query permission: `GET /structs/permission/{permissionId}`
2. Convert value to integer: `value = parseInt(permission.value)`
3. Check PermHashAll: `(value & 15728640) == 15728640`
4. If true, all hash permissions are set

### Check Specific Hash Permission

1. Query permission: `GET /structs/permission/{permissionId}`
2. Convert value to integer: `value = parseInt(permission.value)`
3. Check specific bit (e.g., PermHashMine): `(value & 2097152) == 2097152`
4. If true, that specific hash permission is set

### Grant Hash Permissions

1. Get current permission value
2. Combine with hash bits: `newValue = currentValue | 15728640`
3. Update permission with new value
4. Verify: `(newValue & 15728640) == 15728640`

### Remove Hash Permissions

1. Get current permission value
2. Remove hash bits: `newValue = currentValue & ~15728640`
3. Update permission with new value
4. Verify: `(newValue & 15728640) == 0`

---

## Error Codes

### Common Error Codes

- **Code 5**: `INVALID_MESSAGE` - Invalid permission format
- **Code 1**: `GENERAL_ERROR` - General error (retryable)

**See**: `schemas/errors.md` for complete error definitions

---

## Best Practices

### 1. Use HasAll Semantics

Always check permissions with `(value & required) == required`. Do not use `!= 0` which only verifies any single bit.

### 2. Grant Specific Hash Bits

Grant only the hash permissions needed. Use PermHashBuild for builders, PermHashMine for miners, etc. Use PermHashAll only when all hash operations are needed.

### 3. Verify Permission Values

After setting permissions, always verify the value matches expected combination.

### 4. Check the Full Permission Flow

Permissions are resolved in order: address → ownership → object → guild rank. A failure at any step blocks the action. Check all levels when troubleshooting.

### 5. Check Object and Player IDs

Verify permission applies to correct object and player.

### 6. Handle Permission Hash in Database

When querying database, account for granular hash permission columns.

### 7. Test Permission Combinations

Test permission combinations before applying to production.

---

## Related Documentation

- **Permission Schema**: `../schemas/game-state.md#/definitions/Permission` - Permission entity schema
- **Permission API**: `../api/queries/permission.md` - Permission query endpoints
- **Database Schema**: `../schemas/database-schema.md` - Permission database changes
- **Entity Index**: `../reference/entity-index.md` - Permission entity information
- **Formats**: `../schemas/formats.md` - ID format specifications

---

*Last Updated: March 26, 2026*
