# Structs Database Schema

**Version**: 1.1.0
**Category**: database
**Source**: https://github.com/playstructs/structs-pg
**Last Updated**: 2026-01-01

PostgreSQL database schema for Structs guild infrastructure. Managed by structs-pg repository using Sqitch.

---

## Database Info

| Property | Value |
|----------|-------|
| Name | structs |
| Type | PostgreSQL |
| Management | Sqitch |
| Repository | https://github.com/playstructs/structs-pg |

---

## v0.8.0-beta Changelog

| Date | Change | Description | Impact |
|------|--------|-------------|--------|
| 2025-11-22 | function-signer-tx-player | Latest messages for testnet 103 | -- |
| 2025-11-29 | table-struct-type-cheatsheet-details | Added cheatsheet details to `struct_type` table | New columns for cheatsheet information in `struct_type` |
| 2025-12-02 | table-struct-type-extended-cheatsheet | Added extended cheatsheet details to `struct_type` | Additional cheatsheet columns added |
| 2025-12-03 | table-struct-type-update-cheatsheet | Updated extended cheatsheet details to `struct_type` | Cheatsheet columns refined |
| 2025-12-08 | remove-deprecated-charge-columns | Removed deprecated Charge Bar columns for mine and refine | Deprecated charge columns removed from `struct_type`, views, and cache triggers. Tables: `struct_type`, `view.struct`, `view.work`. Trigger: `cache-trigger-add-queue` |
| 2025-12-13 | view-work-fixed-raid-logic | Fixed raid logic in `view.work` | Improved raid task filtering in work view |
| 2025-12-15 | table-signer-tx-complete-input-changes | Hash Complete nonces were INTEGER instead of CHARACTER VARYING | Fixed nonce data type for hash complete transactions |
| 2025-12-18 | view-permission-add-permission-hash | Added new `permission_hash` level | New permission level added to permission view. Related: Hash permission bit (value 64) in API layer |
| 2025-12-18 | table-signer-tx-permission-update | Updated tx signing permission levels | Transaction signing now supports Hash permission level |
| 2025-12-18 | table-signer-tx-add-tx-types | Updated tx types | Additional transaction types added |
| 2025-12-18 | cache-trigger-struct-type-fix | Fix to Struct Type cache commit | Cache trigger improvements for `struct_type` |
| 2025-12-19 | trigger-grass-grid-p-values | Fixed grass grid p values | GRASS grid trigger improvements |
| 2025-12-27 | view-work-exclusion-logic | Improved `view.work` logic to exclude impossible tasks | Better filtering of impossible tasks in work view |
| 2025-12-29 | table-struct-add-destroyed | New `destroyed` column on struct table | Struct table now tracks destroyed status. Related: StructSweepDelay (5 blocks) -- destroyed structs persist for 5 blocks |
| 2025-12-29 | function-signer-account-bug-fix | Resolved bug in the signer | Signer function bug fix |
| 2025-12-29 | table-player-address-pending-permissions | `permissions` column was missing for device adding | Added `permissions` column to `player_address_pending` table |
| 2026-01-01 | table-planet-activity-struct-health | Added `struct_health` as a detail field in `planet_activity` table | `planet_activity` table now includes `struct_health` in details JSONB field. This field is also emitted by GRASS in planet activity events. |

---

## Tables

### struct_type

Struct type definitions with all properties.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `cheatsheet_details`, `cheatsheet_extended_details` |
| Removed | Deprecated charge columns for mine and refine |

Cheatsheet details added for better struct type documentation. Deprecated charge columns removed.

### struct

Struct instances.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `destroyed` |

`destroyed` column tracks struct destruction status. Related to StructSweepDelay (5 blocks).

### signer_tx

Transaction signing information.

**v0.8.0-beta changes**:

- Hash Complete nonces changed from INTEGER to CHARACTER VARYING
- Updated permission levels to support Hash permission
- Added new transaction types

### player_address_pending

Pending player address additions.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `permissions` |

`permissions` column added for device adding functionality.

### planet_activity

Planet activity log tracking various planet-related events.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `struct_health` in details JSONB field |

`struct_health` is now logged in the details JSONB field of `planet_activity` table. This field tracks struct health information and is emitted by GRASS in planet activity events.

---

## Views

### permission

Permission view.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Added | `permission_hash` level |

New `permission_hash` level added. Maps to Hash permission bit (value 64) in API layer.

### work

Work/task view.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Improved | Fixed raid logic; improved exclusion logic to exclude impossible tasks |
| Removed | Deprecated charge columns |

### struct

Struct view.

**v0.8.0-beta changes**:

| Action | Details |
|--------|---------|
| Removed | Deprecated charge columns |

---

## Functions

### signer_tx_player

Transaction signing for player.

**v0.8.0-beta**: Updated 2025-11-22 -- Latest messages for testnet 103.

### signer_account

Account signing function.

**v0.8.0-beta**: Bug fix 2025-12-29 -- Resolved bug in the signer.

---

## Triggers

### cache_trigger_add_queue

Cache trigger for queue management.

**v0.8.0-beta changes**:

- Removed deprecated charge columns
- Fixed struct type cache commit

### grass_grid

GRASS grid trigger.

**v0.8.0-beta**: Fix 2025-12-19 -- Fixed grass grid p values.

---

## Verification

| Property | Value |
|----------|-------|
| Verified | No |
| Note | Database schema changes tracked from structs-pg repository Sqitch deployment plan |
| Source | https://github.com/playstructs/structs-pg |
