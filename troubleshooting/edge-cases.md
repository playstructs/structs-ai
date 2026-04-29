# Edge Cases and Gotchas

**Version**: 1.0.0  
**Category**: Troubleshooting  
**Status**: Stable  
**Last Updated**: March 26, 2026

## Overview

This document documents edge cases and gotchas that AI agents should be aware of when working with Structs. These are non-obvious behaviors that can cause unexpected issues if not handled correctly.

---

## Reactor Staking Edge Cases

### Edge Case 1: Player-Level Staking Management

**Issue**: Staking is managed at player level, but individual reactors may show different statuses

**Details**:
- Reactor staking is managed at the player level, not per reactor
- Individual reactors may show different `delegationStatus` values
- `delegationAmount` may vary per reactor
- Staking operations affect player-level state

**Implications**:
- Don't assume all reactors have same staking status
- Query each reactor individually to check status
- Account for player-level state changes affecting all reactors

**Reference**: `schemas/entities/reactor.md`, `protocols/economic-protocol.md#/reactor-staking`

---

### Edge Case 2: Undelegation Period During Migration

**Issue**: Cannot begin migration while in undelegation period

**Details**:
- If delegation status is `"undelegating"`, migration may be restricted
- Must wait for undelegation to complete or cancel defusion first
- Migration requires `"active"` status in most cases

**Implications**:
- Check delegation status before attempting migration
- Use `reactor-cancel-defusion` if migration needed during undelegation
- Plan migration timing around undelegation periods

**Reference**: `schemas/actions.md#/reactor-begin-migration`, `protocols/economic-protocol.md`

---

### Edge Case 3: Multiple Reactors with Different Validators

**Issue**: Player may have reactors delegated to different validators

**Details**:
- Each reactor can have different `validator` address
- Staking is player-level, but validators can differ
- Migration affects specific reactor's validator

**Implications**:
- Track validator per reactor, not per player
- Account for different validators when planning operations
- Migration affects specific reactor, not all reactors

**Reference**: `schemas/entities/reactor.md#/properties/validator`

---

## Permission Combination Edge Cases

### Edge Case 4: Permission Value Overflow

**Issue**: Combining permissions may produce unexpected values

**Details**:
- Permission values are 25-bit flags (0-33554431 range, PermAll = 33554431)
- Combining permissions uses bitwise OR: `value1 | value2`
- Values outside valid range may cause issues
- Hash permissions (bits 20-23) are four separate bits: PermHashBuild (1048576), PermHashMine (2097152), PermHashRefine (4194304), PermHashRaid (8388608), composite PermHashAll = 15728640
- Bit 24 is `PermGuildUGCUpdate` (16777216), the moderation flag for name/pfp updates on guild-owned objects
- Permission checks use HasAll semantics: `(value & required) == required` — all required bits must be present

**Implications**:
- Always verify permission values are within valid range (0-33554431)
- Test permission combinations before applying
- Use HasAll checks: `(value & required) == required`, not `(value & required) != 0`
- Grant only the specific hash bits needed for the operation

**Reference**: `schemas/game-state.md#/definitions/Permission`

---

### Edge Case 5: Permission Hash Database Level

**Issue**: Permission hash exists in database but not in API response

**Details**:
- Hash permission levels exist in database as granular columns (permission_hash_build, permission_hash_mine, permission_hash_refine, permission_hash_raid)
- Maps to hash permission bits 20-23 in API layer (PermHashBuild=1048576, PermHashMine=2097152, PermHashRefine=4194304, PermHashRaid=8388608)
- Database view may show hash columns as true but API value may not include all hash bits

**Implications**:
- Check both database and API for permission state
- Account for granular hash permission columns in database queries
- Verify API permission value includes the required hash bits (e.g., `(value & 15728640) == 15728640` for all hash permissions)

**Reference**: `schemas/database-schema.md`, `api/queries/permission.md`

---

### Edge Case 6: Permission Object ID Format

**Issue**: Permission object ID must match entity type

**Details**:
- Permission `objectId` format: `type-index`
- Object type must match entity type (guild=0, planet=2, struct=5, fleet=9)
- Permission ID format: `{objectId}@{playerId}`
- Incorrect format causes permission not found

**Implications**:
- Verify object ID format matches entity type
- Use correct permission ID format: `{objectId}@{playerId}`
- Check `permission.objectType` matches expected type

**Reference**: `schemas/formats.md`, `api/queries/permission.md`

---

## StructSweepDelay Edge Cases

### Edge Case 7: Slot Appears Occupied After Destruction

**Issue**: Slot may appear occupied for 5 blocks after struct destruction

**Details**:
- `StructSweepDelay = 5` blocks
- Destroyed structs persist for 5 blocks before slot clearing
- Planet/fleet slot arrays may still reference destroyed struct ID
- Slot not available for new structs during delay period

**Implications**:
- Don't assume slot is immediately available after destruction
- Wait 5 blocks before attempting to build in same slot
- Query struct to verify destruction: `struct.destroyed == true`
- Check slot availability after delay period

**Reference**: `lifecycles/struct-lifecycle.md#/structsweepdelay`, `schemas/gameplay.md`

---

### Edge Case 8: Destroyed Struct Still in Query Results

**Issue**: Destroyed structs may appear in query results for 5 blocks

**Details**:
- Destroyed structs have `destroyed = true` but still exist
- Struct persists in game state for `StructSweepDelay` (5 blocks)
- Query results may include destroyed structs
- Struct attributes cleared but struct ID still exists

**Implications**:
- Filter query results by `destroyed == false` for active structs
- Don't rely on struct existence alone - check `destroyed` field
- Account for 5-block delay when checking struct availability
- Wait for delay period before considering struct fully removed

**Reference**: `schemas/entities/struct.md#/properties/destroyed`, `lifecycles/struct-lifecycle.md`

---

### Edge Case 9: Slot Reference Persistence During Delay

**Issue**: Planet/fleet slot arrays reference destroyed struct during delay

**Details**:
- Planet/fleet back references for slots not cleared until delay met
- Slot arrays may still contain destroyed struct ID
- Slot appears occupied but struct is destroyed
- After 5 blocks, slot reference cleared

**Implications**:
- Don't rely on slot array contents alone
- Check `struct.destroyed` field to verify struct state
- Account for delay when checking slot availability
- Wait for delay period before using slot

**Reference**: `lifecycles/struct-lifecycle.md#/structsweepdelay`, `schemas/entities/struct.md`

---

## Database Query Edge Cases

### Edge Case 10: Destroyed Structs in Database Queries

**Issue**: Database queries may return destroyed structs

**Details**:
- `struct.destroyed` column added (2025-12-29)
- Destroyed structs persist for 5 blocks
- Database queries may include destroyed structs
- Must filter by `destroyed = false` for active structs

**Implications**:
- Always filter database queries by `destroyed = false`
- Account for 5-block delay when querying structs
- Don't assume struct doesn't exist if query returns no results
- Check `destroyed` field in query results

**Reference**: `schemas/database-schema.md#/tables/struct`, `schemas/entities/struct.md`

---

### Edge Case 11: Permission Hash in Database vs API

**Issue**: Database hash permission columns may not match API permission value

**Details**:
- Database has granular hash permission columns (permission_hash_build, permission_hash_mine, permission_hash_refine, permission_hash_raid)
- API uses permission value with bits 20-23 for hash permissions (PermHashAll = 15728640)
- Database view may show individual hash columns as true but API value may differ
- Must check both database and API for complete picture

**Implications**:
- Check both database and API for permission state
- Account for granular hash columns in database queries
- Verify API permission value includes required hash bits: `(value & 15728640) == 15728640`
- Don't rely on single source for permission information

**Reference**: `schemas/database-schema.md`, `api/queries/permission.md`

---

### Edge Case 12: Signer TX Permission Levels

**Issue**: Transaction signing requires specific hash permission but permission not set

**Details**:
- Signer_tx table supports granular hash permissions (bits 20-23)
- Transaction signing requires the specific hash permission for the operation type:
  - Build operations: PermHashBuild (1048576)
  - Mine operations: PermHashMine (2097152)
  - Refine operations: PermHashRefine (4194304)
  - Raid operations: PermHashRaid (8388608)
- Missing the specific hash bit causes signing to fail
- Must grant the correct hash permission before signing

**Implications**:
- Verify the specific hash permission is granted before transaction signing
- Check signer_tx permission levels
- Grant the required hash permission bit (or PermHashAll = 15728640 for all operations) if signing fails
- Account for granular hash permission columns in database

**Reference**: `schemas/database-schema.md#/tables/signer_tx`, `schemas/entities.md#/definitions/Permission`

---

## General Edge Cases

### Edge Case 13: Transaction Broadcast vs Action Success

**Issue**: Transaction status `broadcast` does not mean action succeeded

**Details**:
- Transaction may broadcast successfully but action fails validation
- Must verify game state after broadcast
- Query relevant entities to confirm action occurred
- Status `broadcast` ≠ action success

**Implications**:
- Always verify game state after transaction broadcast
- Query relevant entities to confirm action
- Don't assume broadcast means success
- Check requirements if action didn't occur

**Reference**: `protocols/action-protocol.md#/validation-warning`, `troubleshooting/common-issues.md`

---

### Edge Case 14: Player Online Status Changes

**Issue**: Player online status may change between checks

**Details**:
- Player status can change from online to offline (halted)
- Status check may pass but action fails due to status change
- Must verify status immediately before action
- Status may change during action execution

**Implications**:
- Check player status immediately before actions
- Handle `PLAYER_HALTED` errors gracefully
- Retry actions after player comes online
- Don't cache player status for critical operations

**Reference**: `schemas/errors.md#/PLAYER_HALTED`, `troubleshooting/common-issues.md`

---

## Best Practices for Edge Cases

### 1. Always Verify State

After any action, verify game state matches expected result.

### 2. Account for Delays

Account for `StructSweepDelay` (5 blocks) when checking struct availability.

### 3. Check Multiple Sources

For permissions, check both database and API for complete picture.

### 4. Filter Destroyed Entities

Always filter queries by `destroyed = false` for active entities.

### 5. Handle Status Changes

Account for status changes between checks and actions.

### 6. Test Permission Combinations

Test permission combinations before applying to production.

### 7. Verify Transaction Results

Always verify game state after transaction broadcast.

---

## Related Documentation

- **Reactor Staking**: `reactor-staking-issues.md` - Reactor staking troubleshooting
- **Permissions**: `permission-issues.md` - Permission troubleshooting
- **Common Issues**: `common-issues.md` - Common issues and solutions
- **Struct Lifecycle**: `../lifecycles/struct-lifecycle.md` - Struct lifecycle details
- **Database Schema**: `../schemas/database-schema.md` - Database changes

---

*Last Updated: January 1, 2026*

