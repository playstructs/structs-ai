# Hash Permission Troubleshooting

**Version**: 1.0.0  
**Category**: Troubleshooting  
**Status**: Stable  
**Last Updated**: January 1, 2026  
**v0.8.0-beta**: Hash permission (bit value 64) added

## Overview

This guide helps troubleshoot issues with Hash permissions and permission bit manipulation. Hash permission (bit value 64) was added in v0.8.0-beta. Permission values are bit-based flags that can be combined using bitwise OR.

---

## Common Issues

### Issue 1: Permission Check Fails - Hash Permission Not Set

**Symptom**: Permission check fails even though permission should be granted

**Cause**: Hash permission bit (64) not included in permission value

**Diagnosis**:
1. Query permission: `GET /structs/permission/{permissionId}`
2. Check `permission.value` (numeric string)
3. Convert to integer and check bit 64: `(value & 64) == 64`
4. If false, Hash permission not set

**Solution**:
1. Grant Hash permission: Set permission value with bit 64
2. Combine with existing permissions: `newValue = oldValue | 64`
3. Verify permission: `(newValue & 64) == 64`

**Example**:
```json
{
  "permissionId": "0-1@1-11",
  "oldValue": "63",
  "newValue": "127",
  "calculation": "63 | 64 = 127",
  "hashPermission": "(127 & 64) == 64 ✓"
}
```

**Reference**: `schemas/game-state.md#/definitions/Permission`, `api/queries/permission.md`

---

### Issue 2: Permission Value Incorrect - Bit Manipulation Error

**Symptom**: Permission value doesn't match expected combination

**Cause**: Incorrect bitwise OR operation

**Diagnosis**:
1. Query permission: `GET /structs/permission/{permissionId}`
2. Check `permission.value`
3. Verify bit combination logic
4. Common values: 127 (all permissions), 64 (Hash only), 63 (all except Hash)

**Solution**:
1. Use bitwise OR to combine permissions: `value = permission1 | permission2`
2. Use bitwise AND to check permissions: `(value & permission) == permission`
3. Common combinations:
   - All permissions: `127` (bits 0-6)
   - Hash only: `64` (bit 6)
   - All except Hash: `63` (bits 0-5)
   - Hash + others: `63 | 64 = 127`

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

### Issue 4: Database Permission Hash Not Found

**Symptom**: Database query for `permission_hash` returns no results

**Cause**: Permission hash level not set or query incorrect

**Diagnosis**:
1. Check database schema: `structs.permission` table
2. Verify `permission_hash` level exists (added 2025-12-18)
3. Check permission view: `view.permission`
4. Verify Hash permission bit (64) is set

**Solution**:
1. Verify permission_hash level exists in database
2. Check permission value includes bit 64
3. Query permission view: `SELECT * FROM view.permission WHERE permission_hash = true`
4. Verify API permission has Hash permission bit set

**Reference**: `schemas/database-schema.md`, `api/queries/permission.md`

---

### Issue 5: Transaction Signing Fails - Hash Permission Required

**Symptom**: Transaction signing fails with permission error

**Cause**: Hash permission not granted for transaction signing

**Diagnosis**:
1. Check signer_tx table: `structs.signer_tx`
2. Verify permission levels support Hash permission (updated 2025-12-18)
3. Check player address permissions
4. Verify Hash permission bit (64) is set

**Solution**:
1. Grant Hash permission to player address
2. Verify permission value includes bit 64
3. Check signer_tx permission levels
4. Retry transaction signing

**Reference**: `schemas/database-schema.md#/tables/signer_tx`, `schemas/entities.md#/definitions/Permission`

---

### Issue 6: Permission Combination Produces Unexpected Value

**Symptom**: Combining permissions produces wrong value

**Cause**: Incorrect bitwise operation or value overflow

**Diagnosis**:
1. Check permission values being combined
2. Verify bitwise OR operation: `value1 | value2`
3. Check for value overflow (should be within valid range)
4. Verify permission bits are valid (0-6 for standard permissions, 6 for Hash)

**Solution**:
1. Use correct bitwise operations:
   - Combine: `value = value1 | value2`
   - Check: `(value & bit) == bit`
   - Remove: `value = value & ~bit`
2. Verify values are within valid range
3. Test bit combinations before applying

**Example**:
```json
{
  "permission1": 63,
  "permission2": 64,
  "combined": "63 | 64 = 127",
  "checkHash": "(127 & 64) == 64 ✓",
  "removeHash": "127 & ~64 = 63"
}
```

**Reference**: `schemas/game-state.md#/definitions/Permission`

---

## Permission Bit Reference

### Standard Permission Bits

- **Bit 0**: Permission type 0
- **Bit 1**: Permission type 1
- **Bit 2**: Permission type 2
- **Bit 3**: Permission type 3
- **Bit 4**: Permission type 4
- **Bit 5**: Permission type 5
- **Bit 6 (Hash)**: Hash permission (v0.8.0-beta)

### Common Permission Values

- **0**: No permissions
- **63**: All standard permissions (bits 0-5)
- **64**: Hash permission only (bit 6)
- **127**: All permissions including Hash (bits 0-6)

---

## Verification Steps

### Check Hash Permission

1. Query permission: `GET /structs/permission/{permissionId}`
2. Convert value to integer: `value = parseInt(permission.value)`
3. Check bit 64: `(value & 64) == 64`
4. If true, Hash permission is set

### Grant Hash Permission

1. Get current permission value
2. Combine with Hash bit: `newValue = currentValue | 64`
3. Update permission with new value
4. Verify: `(newValue & 64) == 64`

### Remove Hash Permission

1. Get current permission value
2. Remove Hash bit: `newValue = currentValue & ~64`
3. Update permission with new value
4. Verify: `(newValue & 64) == 0`

---

## Error Codes

### Common Error Codes

- **Code 5**: `INVALID_MESSAGE` - Invalid permission format
- **Code 1**: `GENERAL_ERROR` - General error (retryable)

**See**: `schemas/errors.md` for complete error definitions

---

## Best Practices

### 1. Use Bitwise Operations

Always use bitwise OR to combine permissions, bitwise AND to check permissions.

### 2. Verify Permission Values

After setting permissions, always verify the value matches expected combination.

### 3. Check Object and Player IDs

Verify permission applies to correct object and player.

### 4. Handle Permission Hash in Database

When querying database, account for permission_hash level (added v0.8.0-beta).

### 5. Test Permission Combinations

Test permission combinations before applying to production.

---

## Related Documentation

- **Permission Schema**: `../schemas/game-state.md#/definitions/Permission` - Permission entity schema
- **Permission API**: `../api/queries/permission.md` - Permission query endpoints
- **Database Schema**: `../schemas/database-schema.md` - Permission database changes
- **Entity Index**: `../reference/entity-index.md` - Permission entity information
- **Formats**: `../schemas/formats.md` - ID format specifications

---

*Last Updated: January 1, 2026*  
*v0.8.0-beta: Hash permission troubleshooting guide*

