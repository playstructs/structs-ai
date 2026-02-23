# Database Schema Query Examples

**Version**: 1.0.0
**Category**: Database
**Purpose**: Query examples for database schema changes in v0.8.0-beta

---

## Overview

These examples demonstrate SQL queries for the database schema changes introduced in v0.8.0-beta: destroyed structs tracking, cheatsheet details on struct types, the permission hash level, and signer transaction table changes.

### v0.8.0-beta Features Covered

- `destroyed_structs` -- New `destroyed` column on struct table
- `cheatsheet_details` -- Cheatsheet and extended cheatsheet columns on struct_type table
- `permission_hash` -- New permission hash level in the permission view
- `signer_tx_changes` -- Nonce type changes and new transaction types in signer_tx table

## Destroyed Structs

**Database change** (2025-12-29): Added `destroyed` column to the `struct` table. Destroyed structs persist for 5 blocks (StructSweepDelay) before their slots are cleared.

### Find All Destroyed Structs

```sql
SELECT * FROM struct WHERE destroyed = true
```

Example result:

```json
[
  {
    "id": "5-1",
    "owner_id": "1-11",
    "struct_type_id": 14,
    "location_type": 1,
    "location_id": "2-1",
    "status": 0,
    "destroyed": true,
    "created_at": "2026-01-01T10:00:00Z",
    "updated_at": "2026-01-01T10:05:00Z"
  }
]
```

Columns returned: `id`, `owner_id`, `struct_type_id`, `location_type`, `location_id`, `status`, `destroyed`, `created_at`, `updated_at`.

### Find Destroyed Structs by Owner

```sql
SELECT * FROM struct WHERE owner_id = ? AND destroyed = true
```

Parameter: `owner_id` = `1-11`

### Find Destroyed Structs on a Planet

```sql
SELECT * FROM struct WHERE location_type = 1 AND location_id = ? AND destroyed = true
```

Parameter: `location_id` = `2-1`

Destroyed structs persist for StructSweepDelay (5 blocks) before the slot is cleared.

### Count Destroyed Structs

```sql
SELECT COUNT(*) FROM struct WHERE destroyed = true
```

### Find Recently Destroyed Structs

```sql
SELECT * FROM struct WHERE destroyed = true AND updated_at > NOW() - INTERVAL '5 blocks'
```

Useful for monitoring structs during the StructSweepDelay period.

### Use Cases

**Monitor sweep delay**: Query destroyed structs to track which ones are still in the delay period and haven't been cleaned up yet.

**Cleanup tracking**: After destruction, verify that cleanup occurs after 5 blocks by re-querying destroyed structs.

## Cheatsheet Details

**Database changes**:
- 2025-11-29: Added `cheatsheet_details` to `struct_type` table
- 2025-12-02: Added `cheatsheet_extended_details` to `struct_type` table
- 2025-12-03: Updated extended cheatsheet details on `struct_type` table

### Get Cheatsheet Details for a Struct Type

```sql
SELECT cheatsheet_details, cheatsheet_extended_details FROM struct_type WHERE id = ?
```

Parameter: `id` = `14`

Example result:

```json
{
  "id": 14,
  "name": "Command Ship",
  "cheatsheet_details": "Command ship details...",
  "cheatsheet_extended_details": "Extended command ship details..."
}
```

### Get All Struct Types with Cheatsheet Details

```sql
SELECT id, name, cheatsheet_details, cheatsheet_extended_details
FROM struct_type
WHERE cheatsheet_details IS NOT NULL
```

### Search Cheatsheet Content

```sql
SELECT * FROM struct_type
WHERE cheatsheet_details LIKE ? OR cheatsheet_extended_details LIKE ?
```

Parameter: `pattern` = `%keyword%`

Useful for finding struct types by searching their cheatsheet content.

### Use Cases

**Documentation generation**: Query cheatsheet details to build comprehensive struct type documentation automatically.

**Struct type lookup**: Query cheatsheet details for quick reference information about any struct type.

## Permission Hash

**Database change** (2025-12-18): Added `permission_hash` level to the `permission` view. The Hash permission bit has value 64 in the API layer.

### Get Permission Hash for a Specific Permission

```sql
SELECT permission_hash FROM permission WHERE object_id = ? AND player_id = ?
```

Parameters: `object_id` = `0-1`, `player_id` = `1-11`

Example result:

```json
{
  "object_id": "0-1",
  "player_id": "1-11",
  "permission_hash": true
}
```

`permission_hash = true` maps to `permission.value & 64 !== 0` in the API.

### Get All Permissions with Hash Permission

```sql
SELECT * FROM permission WHERE permission_hash = true
```

Example result:

```json
[
  { "object_id": "0-1", "player_id": "1-11", "permission_hash": true, "val": 127 },
  { "object_id": "2-1", "player_id": "1-11", "permission_hash": true, "val": 64 }
]
```

### Get Hash Permissions for a Player

```sql
SELECT * FROM permission WHERE player_id = ? AND permission_hash = true
```

Parameter: `player_id` = `1-11`

### Get Hash Permissions for an Object

```sql
SELECT * FROM permission WHERE object_id = ? AND permission_hash = true
```

Parameter: `object_id` = `0-1`

### Count Hash Permissions

```sql
SELECT COUNT(*) FROM permission WHERE permission_hash = true
```

### Database to API Mapping

| Database | API |
|----------|-----|
| `permission_hash = true` | `permission.value & 64 !== 0` |
| `permission_hash = false` | `permission.value & 64 === 0` |

Example mapping:

```json
{
  "database": { "permission_hash": true, "val": 127 },
  "api": { "value": "127", "hasHashPermission": true }
}
```

### Use Cases

**Permission audit**: Query `permission_hash` to find all Hash permission grants across the system.

**Access control**: Query `permission_hash` to verify a player has Hash permission before allowing operations.

## Signer Transaction Changes

**Database changes**:
- 2025-12-15: Hash Complete nonces changed from `INTEGER` to `CHARACTER VARYING`
- 2025-12-18: Updated tx signing permission levels to support Hash permission
- 2025-12-18: Updated tx types

### Get Signer Transaction by Hash

```sql
SELECT * FROM signer_tx WHERE tx_hash = ?
```

Parameter: `tx_hash` = `transaction_hash`

Example result:

```json
{
  "tx_hash": "transaction_hash",
  "permission_level": "hash",
  "tx_type": "struct_build_complete",
  "nonce": "proof_of_work_nonce"
}
```

The `nonce` field is now `CHARACTER VARYING` (was `INTEGER`).

### Get Transactions by Permission Level

```sql
SELECT * FROM signer_tx WHERE permission_level = 'hash'
```

### Get Transactions by Type

```sql
SELECT * FROM signer_tx WHERE tx_type = ?
```

Parameter: `tx_type` = `struct_build_complete`

New transaction types were added in v0.8.0-beta.

### Get Transactions with Hash Complete Nonces

```sql
SELECT * FROM signer_tx WHERE tx_type LIKE '%complete%' AND nonce IS NOT NULL
```

Nonces for Hash Complete transactions are `CHARACTER VARYING` instead of `INTEGER`.

### Get Recent Signer Transactions

```sql
SELECT * FROM signer_tx ORDER BY created_at DESC LIMIT ?
```

Parameter: `limit` = `100`

### Use Cases

**Transaction audit**: Query `signer_tx` to track all transactions signed with Hash permission level.

**Nonce verification**: Query `signer_tx` to verify proof-of-work nonces, keeping in mind the `CHARACTER VARYING` format.

**Transaction type tracking**: Query `signer_tx` to analyze the distribution of transaction types.

## Combined Queries

### Destroyed Structs with Type Details

```sql
SELECT s.*, st.name, st.cheatsheet_details
FROM struct s
JOIN struct_type st ON s.struct_type_id = st.id
WHERE s.destroyed = true
```

Provides comprehensive information about destroyed structs including their type name and cheatsheet details.

### All Hash Permissions for a Player

```sql
SELECT * FROM permission WHERE player_id = ? AND permission_hash = true
```

Audits all Hash permissions granted to a specific player across all objects.

## Cross-References

- Database schema: [schemas/database-schema.md](../../schemas/database-schema.md)
- Permission examples: [examples/auth/permission-examples.md](../auth/permission-examples.md)
- Struct lifecycle workflow: [examples/workflows/struct-lifecycle-sweep-delay.md](../workflows/struct-lifecycle-sweep-delay.md)
