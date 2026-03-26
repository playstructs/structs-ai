# Permission System

**Purpose**: AI-readable reference for the Structs permission system. Covers address permissions, object permissions, guild rank permissions, and the message handler permission reference.

---

## Overview

The permission system controls what actions players and their addresses can perform on game objects. It operates at three layers:

1. **Address Permissions** -- What permission flags an address is allowed to exercise on behalf of its player
2. **Object Permissions** -- What permission flags a specific player holds on a specific object
3. **Guild Rank Permissions** -- What permission flags are granted to guild members based on their rank

All three layers are checked during `PermissionCheck`, the central authorization gate for every state-changing transaction.

---

## Permission Flags

Permissions are bitwise flags stored as `uint64` values. There are 24 individual permission bits (bits 0--23):

| Bit | Value | Name | Description |
|-----|-------|------|-------------|
| 0 | 1 | `PermPlay` | All struct, fleet, and planetary actions |
| 1 | 2 | `PermAdmin` | Owner-level administrative access |
| 2 | 4 | `PermUpdate` | Update object properties |
| 3 | 8 | `PermDelete` | Delete objects |
| 4 | 16 | `PermTokenTransfer` | Transfer tokens |
| 5 | 32 | `PermTokenInfuse` | Infuse tokens into reactors |
| 6 | 64 | `PermTokenMigrate` | Migrate tokens between validators |
| 7 | 128 | `PermTokenDefuse` | Defuse tokens from reactors |
| 8 | 256 | `PermSourceAllocation` | Create, update, delete allocations |
| 9 | 512 | `PermGuildMembership` | Manage guild membership |
| 10 | 1024 | `PermSubstationConnection` | Connect to substations |
| 11 | 2048 | `PermAllocationConnection` | Connect allocations |
| 12 | 4096 | `PermGuildTokenBurn` | Burn and confiscate guild tokens |
| 13 | 8192 | `PermGuildTokenMint` | Mint guild tokens |
| 14 | 16384 | `PermGuildEndpointUpdate` | Update guild endpoint URL |
| 15 | 32768 | `PermGuildJoinConstraintsUpdate` | Update join infusion minimum and bypass settings |
| 16 | 65536 | `PermGuildSubstationUpdate` | Update guild entry substation |
| 17 | 131072 | `PermProviderWithdraw` | Withdraw provider balance |
| 18 | 262144 | `PermProviderOpen` | Manage agreement restrictions |
| 19 | 524288 | `PermReactorGuildCreate` | Create a guild from a reactor |
| 20 | 1048576 | `PermHashBuild` | Submit struct build proof-of-work |
| 21 | 2097152 | `PermHashMine` | Submit ore mining proof-of-work |
| 22 | 4194304 | `PermHashRefine` | Submit ore refinery proof-of-work |
| 23 | 8388608 | `PermHashRaid` | Submit planet raid proof-of-work |

### Composite Permission Masks

Multiple flags can be combined with bitwise OR. The system defines several useful composites:

| Name | Value | Flags Included |
|------|-------|----------------|
| `Permissionless` | 0 | No permissions |
| `PermAssetsAll` | 240 | TokenTransfer, TokenInfuse, TokenMigrate, TokenDefuse |
| `PermHashAll` | 15728640 | HashBuild, HashMine, HashRefine, HashRaid |
| `PermAgreementAll` | 14 | Admin, Update, Delete |
| `PermProviderAll` | 393230 | Admin, Update, Delete, ProviderWithdraw, ProviderOpen |
| `PermGuildAll` | 315910 | Admin, Update, Delete, GuildMembership, GuildEndpointUpdate, GuildJoinConstraintsUpdate, GuildSubstationUpdate, GuildTokenBurn, GuildTokenMint, ProviderOpen |
| `PermSubstationAll` | 1294 | Admin, Update, Delete, SubstationConnection, SourceAllocation |
| `PermReactorAll` | 524558 | Admin, Update, Delete, SourceAllocation, ReactorGuildCreate |
| `PermAllocationAll` | 2062 | Admin, Update, Delete, AllocationConnection |
| `PermAll` | 16777215 | All 24 bits set (2^24 - 1) |
| `PermPlayerAll` | 16777215 | Same as PermAll |

---

## Permission Storage

### Permission IDs

Each permission entry is keyed by a **permission ID** string stored under the `Permission/value/` KV prefix.

**Object permissions** use the format:
```
{objectId}@{playerId}
```
For example, `4-1@1-2` means "player `1-2`'s permissions on guild `4-1`".

**Address permissions** use the format:
```
{objectTypeNumber}-{address}@0
```
For example, `8-cosmos1abc...@0` represents the permissions for address `cosmos1abc...`. The `@0` suffix distinguishes address permission keys from object permission keys.

### Permission Values

The stored value is a single `uint64` representing the bitwise OR of all granted permission flags. For example, if a player has `PermUpdate | PermDelete` on an object, the stored value is `12`.

### Bitwise Operations

- **Grant** (`PermissionAdd`): `current | newFlags` -- adds flags without removing existing ones
- **Revoke** (`PermissionRemove`): `current &^ revokedFlags` -- removes only the specified flags
- **Set** (`SetPermissions`): Replaces the entire value -- overwrites all flags to exactly the provided value
- **Clear** (`ClearPermissions`): Deletes the permission entry entirely (equivalent to setting to 0)

---

## Permission Check Flow

`PermissionCheck(object, activePlayer, requiredPermission)` evaluates access in the following order, returning success on the first match:

1. **Null check** -- If the object or player is nil, deny immediately.
2. **Permissionless check** -- A check for `Permissionless` (0) always denies.
3. **Player account check** -- The active player must have a valid player account on chain.
4. **Address permissions** -- The calling address must have the required permission flags set on its address permission record. Even if a player owns an object, the specific address being used must be authorized to exercise those permissions.
5. **Ownership** -- If the player is the owner of the object, access is granted (all permissions are implicitly held by the owner).
6. **Explicit object permissions** -- Check if the player has the required flags in their `{objectId}@{playerId}` permission record. Uses `HasAll` semantics: all requested bits must be present.
7. **Guild rank permissions** -- If the player belongs to a guild, check the guild rank register for the `(objectId, guildId)` pair. All requested permission bits must have a rank record, and the player's guild rank must be numerically <= the most restrictive (lowest) rank across those bits.

If none of the above grant access, the request is denied with a permission error.

---

## Object Types

Objects are identified by a string in the format `{typeNumber}-{sequenceId}`. The type number determines what kind of entity the object is:

| Type Number | Object Type |
|-------------|-------------|
| 0 | Guild |
| 1 | Player |
| 2 | Planet |
| 3 | Reactor |
| 4 | Substation |
| 5 | Struct |
| 6 | Allocation |
| 7 | Infusion |
| 8 | Address |
| 9 | Fleet |
| 10 | Provider |
| 11 | Agreement |

---

## Guild Rank Permission System

The guild rank permission system allows guild administrators to grant permissions on objects based on a player's **rank** within the guild, rather than granting permissions to individual players. This enables scalable access control: instead of explicitly permissioning every guild member, an admin sets a rank threshold for a permission on an object, and any guild member at or above that rank automatically receives the permission.

### Rank Concepts

**Rank** is a numeric value stored on each player's profile (`Player.GuildRank`). Lower numbers represent higher privilege:

- Rank `1` is the most powerful (guild creator default)
- Rank `101` is the default assigned on join
- Rank `0` means "no rank assigned"

Guild administrators set player ranks via `player-update-guild-rank`.

### Packed Rank Register

Guild rank permissions are stored as a **packed rank register** per `(objectId, guildId)` pair. Each register is a fixed-size array of 24 `uint64` slots (192 bytes total), where slot `i` holds the worst-allowed rank (highest numeric rank that still grants access) for permission bit `i`. A slot value of `0` means no guild rank permission is set for that bit.

**KV Store key:** `Permission/guildRank/{objectId}/{guildId}` -> 192-byte register

**Example register state** (after setting `PermUpdate | PermGuildEndpointUpdate` at rank 3):

| Slot | Permission | Rank Value |
|------|-----------|------------|
| 0 | PermPlay | 0 (unset) |
| 1 | PermAdmin | 0 (unset) |
| 2 | PermUpdate | 3 |
| ... | ... | 0 (unset) |
| 14 | PermGuildEndpointUpdate | 3 |
| ... | ... | 0 (unset) |

Each bit stores its rank independently. A subsequent call to set `PermUpdate` at rank `5` only changes slot 2 -- slot 14 remains at 3.

### Bitmask Decomposition

When a combined bitmask is passed to `Set` or `Revoke`, the system **decomposes** it into individual bits and operates on each slot independently:

- **Set** `permission=16388, rank=3`: Writes rank `3` into slot 2 (PermUpdate) and slot 14 (PermGuildEndpointUpdate). All other slots untouched.
- **Revoke** `permission=16384`: Zeros slot 14 only. Slot 2 untouched.
- **Revoke** `permission=16388`: Zeros both slot 2 and slot 14 atomically.

### Guild Rank Permission Check

When a player attempts an action requiring a permission, and the check reaches the guild rank layer:

1. Load the register for `(objectId, playerGuildId)`
2. For each bit in the requested permission mask, check the corresponding slot
3. If **any** requested bit has no record (slot = 0), the guild rank check **fails**
4. If **all** requested bits have records, take the **minimum** (most restrictive) rank across those slots
5. If the player's guild rank is numerically `<=` that minimum rank, access is **granted**

**Example:** If `PermUpdate` is set at rank 5 and `PermDelete` is set at rank 3, a check for `PermUpdate | PermDelete` requires the player's rank to be <= 3 (the more restrictive threshold).

---

## Transactions

### Object Permission Transactions

These manage per-player permission flags on specific objects. The caller must already have the permission flags they are granting/revoking/setting.

#### `permission-grant-on-object`

Adds permission flags to a player's existing permissions on an object (bitwise OR).

```
structsd tx structs permission-grant-on-object {objectId} {playerId} {permissions} --from {signer} --gas auto -y
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `objectId` | string | The target object (e.g., `4-1` for a guild) |
| `playerId` | string | The player receiving the permissions (e.g., `1-2`) |
| `permissions` | uint64 | Permission bitmask to add |

**Behavior:** `stored = stored | permissions`. Existing flags are preserved; new flags are added.

#### `permission-revoke-on-object`

Removes permission flags from a player's permissions on an object (bitwise AND NOT).

```
structsd tx structs permission-revoke-on-object {objectId} {playerId} {permissions} --from {signer} --gas auto -y
```

**Behavior:** `stored = stored &^ permissions`. Only the specified flags are removed.

#### `permission-set-on-object`

Replaces a player's permission value on an object entirely.

```
structsd tx structs permission-set-on-object {objectId} {playerId} {permissions} --from {signer} --gas auto -y
```

**Behavior:** `stored = permissions`. This overwrites the entire value. Use with care -- any flags not included in the new value will be lost.

### Address Permission Transactions

These manage what permissions an address is allowed to exercise. A player may have multiple addresses; each can be independently restricted.

#### `permission-grant-on-address`

```
structsd tx structs permission-grant-on-address {address} {permissions} --from {signer} --gas auto -y
```

#### `permission-revoke-on-address`

```
structsd tx structs permission-revoke-on-address {address} {permissions} --from {signer} --gas auto -y
```

#### `permission-set-on-address`

```
structsd tx structs permission-set-on-address {address} {permissions} --from {signer} --gas auto -y
```

### Guild Rank Permission Transactions

#### `permission-guild-rank-set`

Sets guild rank permissions on an object. Combined bitmasks are decomposed into individual bits before storage.

```
structsd tx structs permission-guild-rank-set {objectId} {guildId} {permission} {rank} --from {signer} --gas auto -y
```

| Parameter | Type | Description |
|-----------|------|-------------|
| `objectId` | string | The object to set permissions on (guild, substation, etc.) |
| `guildId` | string | The guild whose members will receive the permission |
| `permission` | uint64 | Permission bitmask (single or combined flags) |
| `rank` | uint64 | Worst-allowed rank (must be >= 1; lower = more privileged) |

The caller must already have the specified permission on the object.

#### `permission-guild-rank-revoke`

Revokes guild rank permissions from an object. Only the specified bits are zeroed.

```
structsd tx structs permission-guild-rank-revoke {objectId} {guildId} {permission} --from {signer} --gas auto -y
```

### Player Rank Management

#### `player-update-guild-rank`

Sets a player's guild rank. The caller must have `PermAdmin` (2) on the guild, or have rank-based authority (actor rank must be strictly better than target's current rank).

```
structsd tx structs player-update-guild-rank -- {playerId} {guildRank} --from {signer} --gas auto -y
```

---

## Queries

### `permission`

Returns the permission record for a specific permission ID.

```
structsd query structs permission {permissionId}
```

**Response:**
```json
{
  "permissionRecord": {
    "permissionId": "4-1@1-2",
    "value": "12"
  }
}
```

The `value` field is the `uint64` bitmask. Decompose with bitwise AND (e.g., `value & 4 != 0` means `PermUpdate` is granted).

### `permission-by-object`

Returns all permission records for a given object. Supports pagination.

```
structsd query structs permission-by-object {objectId}
```

### `permission-by-player`

Returns all permission records for a given player. Supports pagination.

```
structsd query structs permission-by-player {playerId}
```

### `permission-all`

Returns all permission records. Supports pagination.

```
structsd query structs permission-all
```

### `guild-rank-permission-by-object`

Returns all guild rank permission records for a given object across all guilds. Supports pagination.

```
structsd query structs guild-rank-permission-by-object {objectId}
```

### `guild-rank-permission-by-object-and-guild`

Returns guild rank permission records for a specific `(objectId, guildId)` pair. Returns at most 24 records. No pagination needed.

```
structsd query structs guild-rank-permission-by-object-and-guild {objectId} {guildId}
```

**Response format** (both guild rank queries):
```json
{
  "guild_rank_permission_records": [
    {
      "objectId": "6-1",
      "guildId": "4-1",
      "permissions": "4",
      "rank": "3"
    },
    {
      "objectId": "6-1",
      "guildId": "4-1",
      "permissions": "16384",
      "rank": "3"
    }
  ]
}
```

Each record represents a **single permission bit**. Combined bitmasks are always decomposed in query responses.

---

## Events

### EventPermission

Emitted every time a permission value changes:

```json
{
  "permissionRecord": {
    "permissionId": "4-1@1-2",
    "value": 12
  }
}
```

Events are emitted for every write, even if the value didn't change.

### EventGuildRankPermission

Emitted for each guild rank permission bit that changes:

```json
{
  "guildRankPermissionRecord": {
    "objectId": "6-1",
    "guildId": "4-1",
    "permissions": 4,
    "rank": 3
  }
}
```

- On **set**: one event per changed bit, with the new rank value
- On **revoke**: one event per zeroed bit, with rank = 0
- Events are only emitted for bits that **actually changed**

---

## Permission Lifecycle

### Player Creation

When a player is created (via staking delegation), their primary address is automatically granted `PermPlayerAll` (all 24 bits) on the address permission record. The primary address can exercise any permission the player holds.

### Object Creation

When an object is created, the creating player is typically set as the owner. Owners implicitly pass all permission checks on their objects without needing explicit permission records.

### Delegation Pattern

Object owners can delegate specific capabilities to other players:

```bash
# Guild owner grants Player 2 membership management and token minting
structsd tx structs permission-grant-on-object -- $GUILD_ID $PLAYER_2_ID 8704 --from owner --gas auto -y
# 8704 = PermGuildMembership (512) | PermGuildTokenMint (8192)
```

### Address Restriction Pattern

A player can register secondary addresses and restrict each one:

```bash
# Grant a secondary address only play and hash permissions
structsd tx structs permission-set-on-address cosmos1secondary... 15728641 --from primary --gas auto -y
# 15728641 = PermPlay (1) | PermHashAll (15728640)
```

### Accumulative Grants vs Absolute Sets

- **Grant** is additive -- only adds flags, never removes them
- **Set** is absolute -- replaces the entire value (dangerous if you forget to include existing flags)
- **Revoke** is subtractive -- only removes specified flags

### Object Deletion Cleanup

When an object is deleted, all permission records for that object (both direct `{objectId}@{playerId}` records and guild rank registers) are cleared. Revocation events are emitted for each cleared entry.

---

## Guild Rank Permission Examples

### Guild officer rank grants management access

```bash
# Admin sets: guild members rank 3 or better can update endpoint and manage membership
structsd tx structs permission-guild-rank-set -- $GUILD_ID $GUILD_ID 16896 3 --from admin --gas auto -y
# 16896 = PermGuildMembership (512) | PermGuildEndpointUpdate (16384)

# Promote player to rank 2 (officer)
structsd tx structs player-update-guild-rank -- $PLAYER_ID 2 --from admin --gas auto -y

# Player can now update the guild endpoint (rank 2 <= 3)
structsd tx structs guild-update-endpoint -- $GUILD_ID "new.endpoint" --from officer --gas auto -y

# Demote player to rank 5 (grunt)
structsd tx structs player-update-guild-rank -- $PLAYER_ID 5 --from admin --gas auto -y
# Player can no longer update the endpoint (rank 5 > 3) -- transaction fails
```

### Different ranks for different permissions

```bash
# Rank 3+ can connect allocations
structsd tx structs permission-guild-rank-set -- $SUB_ID $GUILD_ID 2048 3 --from admin --gas auto -y

# Rank 5+ can connect to the substation
structsd tx structs permission-guild-rank-set -- $SUB_ID $GUILD_ID 1024 5 --from admin --gas auto -y

# Query shows 2 records with independent ranks
structsd query structs guild-rank-permission-by-object-and-guild $SUB_ID $GUILD_ID
```

### Partial revoke

```bash
# Set combined PermUpdate | PermDelete at rank 3
structsd tx structs permission-guild-rank-set -- $GUILD_ID $GUILD_ID 12 3 --from admin --gas auto -y

# Revoke only PermUpdate (4), PermDelete (8) stays
structsd tx structs permission-guild-rank-revoke -- $GUILD_ID $GUILD_ID 4 --from admin --gas auto -y
```

### Provider access via guild rank

```bash
# Grant guild members rank 5+ the ability to open agreements on a provider
structsd tx structs permission-guild-rank-set -- $PROVIDER_ID $GUILD_ID 262144 5 --from admin --gas auto -y
# 262144 = PermProviderOpen
```

---

## Message Handler Permission Reference

Every `msg_server_*` handler that performs a permission check is listed below.

### Permission Transactions

| Message | Object Checked | Permission Flag(s) |
|---------|---------------|-------------------|
| `PermissionGrantOnObject` | Target object (`msg.ObjectId`) | `Permission(msg.Permissions)` (caller-specified) |
| `PermissionRevokeOnObject` | Target object (`msg.ObjectId`) | `Permission(msg.Permissions)` (caller-specified) |
| `PermissionSetOnObject` | Target object (`msg.ObjectId`) | `Permission(msg.Permissions)` (caller-specified) |
| `PermissionGrantOnAddress` | Target player (owner of `msg.Address`) | `Permission(msg.Permissions)` (caller-specified) |
| `PermissionRevokeOnAddress` | Target player (owner of `msg.Address`) | `Permission(msg.Permissions)` (caller-specified) |
| `PermissionSetOnAddress` | Target player (owner of `msg.Address`) | `Permission(msg.Permissions)` (caller-specified) |
| `PermissionGuildRankSet` | Target object (`msg.ObjectId`) | `Permission(msg.Permission)` (caller-specified) |
| `PermissionGuildRankRevoke` | Target object (`msg.ObjectId`) | `Permission(msg.Permission)` (caller-specified) |

For all permission transactions, the caller must already possess the permission flags they are granting, revoking, or setting.

### Player Transactions

| Message | Object Checked | Permission Flag(s) |
|---------|---------------|-------------------|
| `PlayerUpdatePrimaryAddress` | Target player | `PermAdmin` (2) |
| `PlayerSend` | Target player | `PermTokenTransfer` (16) |
| `PlayerUpdateGuildRank` | Guild | `PermAdmin` (2); falls back to rank-based authority |

### Address Transactions

| Message | Object Checked | Permission Flag(s) |
|---------|---------------|-------------------|
| `AddressRegister` | Target player | `Permission(msg.Permissions)` (caller-specified) |
| `AddressRevoke` | Target player | `PermDelete` (8) |

### Reactor Transactions

| Message | Object Checked | Permission Flag(s) |
|---------|---------------|-------------------|
| `ReactorInfuse` | Target player | `PermTokenInfuse` (32) |
| `ReactorDefuse` | Target player | `PermTokenDefuse` (128) |
| `ReactorBeginMigration` | Target player | `PermTokenMigrate` (64) |
| `ReactorCancelDefusion` | Target player | `PermTokenInfuse` (32) |

### Guild Transactions

| Message | Object Checked | Permission Flag(s) | Notes |
|---------|---------------|-------------------|-------|
| `GuildCreate` | Reactor | `PermReactorGuildCreate` (524288) | Also checks `PermSubstationConnection` (1024) if substation specified |
| `GuildUpdateEndpoint` | Guild | `PermGuildEndpointUpdate` (16384) | |
| `GuildUpdateEntrySubstationId` | Guild | `PermGuildSubstationUpdate` (65536) | Also checks `PermSubstationConnection` (1024) on target substation |
| `GuildUpdateEntryRank` | Guild | `PermUpdate` (4) | New entry rank must be >= caller's own rank |
| `GuildUpdateJoinInfusionMinimum` | Guild | `PermGuildJoinConstraintsUpdate` (32768) | |
| `GuildUpdateJoinInfusionMinimumBypassByRequest` | Guild | `PermGuildJoinConstraintsUpdate` (32768) | |
| `GuildUpdateJoinInfusionMinimumBypassByInvite` | Guild | `PermGuildJoinConstraintsUpdate` (32768) | |
| `GuildUpdateOwnerId` | Guild | `PermAdmin` (2) | |
| `GuildBankMint` | Guild | `PermGuildTokenMint` (8192) | |
| `GuildBankConfiscateAndBurn` | Guild | `PermGuildTokenBurn` (4096) | |
| `GuildBankRedeem` | Calling player | `PermTokenTransfer` (16) | Self-check |

### Guild Membership Transactions

Permission checks are conditional based on guild join settings (`GuildJoinBypassLevel`).

| Message | Object Checked | Permission Flag(s) | Notes |
|---------|---------------|-------------------|-------|
| `GuildMembershipInvite` | Guild | `PermGuildMembership` (512) | Only when bypass level = `permissioned`. When `member`, requires guild membership only. When `closed`, always denied. |
| `GuildMembershipInviteApprove` | Target player | `PermGuildMembership` (512) | Caller must be the invited player |
| `GuildMembershipInviteDeny` | Target player | `PermGuildMembership` (512) | Caller must be the invited player |
| `GuildMembershipInviteRevoke` | Guild | `PermGuildMembership` (512) | Conditional on bypass level |
| `GuildMembershipRequest` | Target player | `PermGuildMembership` (512) | Guild must allow requests |
| `GuildMembershipRequestApprove` | Guild | `PermGuildMembership` (512) | Conditional on bypass level |
| `GuildMembershipRequestDeny` | Guild | `PermGuildMembership` (512) | Same conditions as approve |
| `GuildMembershipRequestRevoke` | Target player | `PermGuildMembership` (512) | Caller must be the requesting player |
| `GuildMembershipJoin` | Target player | `PermGuildMembership` (512) | Direct join (pre-approved) |
| `GuildMembershipJoinProxy` | Guild | `PermGuildMembership` (512) | Also checks `PermSubstationConnection` (1024) if substation override |
| `GuildMembershipKick` | Guild | `PermGuildMembership` (512) | Cannot kick the guild owner |

### Struct Transactions

| Message | Object Checked | Permission Flag(s) | Notes |
|---------|---------------|-------------------|-------|
| `StructBuildInitiate` | Owner (player) | `PermPlay` (1) | |
| `StructBuildCancel` | Owner (player) | `PermPlay` (1) | |
| `StructBuildComplete` | Struct | `PermHashAll` (15728640) | All 4 hash bits required |
| `StructActivate` | Owner (player) | `PermPlay` (1) | |
| `StructDeactivate` | Owner (player) | `PermPlay` (1) | |
| `StructStealthActivate` | Owner (player) | `PermPlay` (1) | |
| `StructStealthDeactivate` | Owner (player) | `PermPlay` (1) | |
| `StructMove` | Owner (player) | `PermPlay` (1) | |
| `StructAttack` | Owner (player) | `PermPlay` (1) | |
| `StructDefenseSet` | Owner (player) | `PermPlay` (1) | |
| `StructDefenseClear` | Owner (player) | `PermPlay` (1) | |
| `StructOreMinerComplete` | Struct | `PermHashAll` (15728640) | |
| `StructOreRefineryComplete` | Struct | `PermHashAll` (15728640) | |
| `StructGeneratorInfuse` | Calling player | `PermTokenInfuse` (32) | Self-check |

`CanBePlayedBy` checks `PermPlay` on the **struct's owner** (player object), not the struct itself. `CanBeHashedBy` checks `PermHashAll` on the **struct** (struct object).

### Fleet / Planet Transactions

| Message | Object Checked | Permission Flag(s) |
|---------|---------------|-------------------|
| `FleetMove` | Fleet owner (player) | `PermPlay` (1) |
| `PlanetExplore` | Player | `PermPlay` (1) |
| `PlanetRaidComplete` | Fleet owner (player) | `PermHashRaid` (8388608) |

### Substation Transactions

| Message | Object Checked | Permission Flag(s) | Notes |
|---------|---------------|-------------------|-------|
| `SubstationCreate` | Allocation | `PermAllocationConnection` (2048) | |
| `SubstationDelete` | Substation | `PermDelete` (8) | Also checks `PermSubstationConnection` (1024) on migration target if specified |
| `SubstationPlayerConnect` | Substation + Player | `PermSubstationConnection` (1024) on both | Both checks must pass |
| `SubstationPlayerDisconnect` | Player OR Substation | `PermSubstationConnection` (1024) | Either check sufficient |
| `SubstationPlayerMigrate` | Substation + Player | `PermSubstationConnection` (1024) on both | Player check conditional |
| `SubstationAllocationConnect` | Allocation | `PermAllocationConnection` (2048) | |
| `SubstationAllocationDisconnect` | Allocation OR Destination | `PermAllocationConnection` (2048) | Either sufficient |

### Allocation Transactions

| Message | Object Checked | Permission Flag(s) | Notes |
|---------|---------------|-------------------|-------|
| `AllocationCreate` | Source object (player/reactor) | `PermSourceAllocation` (256) | Only players and reactors are valid sources |
| `AllocationUpdate` | Source object | `PermSourceAllocation` (256) | |
| `AllocationDelete` | Source, then allocation | `PermSourceAllocation` (256) OR `PermDelete` (8) | Fallback: if source check fails, checks direct delete |
| `AllocationTransfer` | Allocation | `PermAdmin` (2) | |

### Provider Transactions

| Message | Object Checked | Permission Flag(s) |
|---------|---------------|-------------------|
| `ProviderCreate` | Substation | `PermSourceAllocation` (256) |
| `ProviderDelete` | Provider | `PermDelete` (8) |
| `ProviderUpdateCapacityMinimum` | Provider | `PermUpdate` (4) |
| `ProviderUpdateCapacityMaximum` | Provider | `PermUpdate` (4) |
| `ProviderUpdateDurationMinimum` | Provider | `PermUpdate` (4) |
| `ProviderUpdateDurationMaximum` | Provider | `PermUpdate` (4) |
| `ProviderUpdateAccessPolicy` | Provider | `PermUpdate` (4) |
| `ProviderWithdrawBalance` | Provider | `PermProviderWithdraw` (131072) |

### Agreement Transactions

| Message | Object Checked | Permission Flag(s) | Notes |
|---------|---------------|-------------------|-------|
| `AgreementOpen` | Provider | `PermProviderOpen` (262144) | Only for `guildMarket` policy. `openMarket` requires valid player only. `closedMarket` always denied. |
| `AgreementClose` | Agreement | `PermUpdate` (4) | |
| `AgreementCapacityIncrease` | Agreement | `PermUpdate` (4) | |
| `AgreementDurationIncrease` | Agreement | `PermUpdate` (4) | |

### Handlers With Multiple Permission Checks

Some handlers check permissions on multiple objects. All checks must pass unless noted as fallback.

| Message | Check 1 | Check 2 | Relationship |
|---------|---------|---------|-------------|
| `GuildCreate` | `PermReactorGuildCreate` on reactor | `PermSubstationConnection` on substation | Both required |
| `GuildUpdateEntrySubstationId` | `PermGuildSubstationUpdate` on guild | `PermSubstationConnection` on target substation | Both required |
| `SubstationPlayerConnect` | `PermSubstationConnection` on substation | `PermSubstationConnection` on player | Both required |
| `SubstationPlayerDisconnect` | `PermSubstationConnection` on player | `PermSubstationConnection` on substation | Either sufficient |
| `SubstationPlayerMigrate` | `PermSubstationConnection` on destination | `PermSubstationConnection` on player | Both required (player conditional) |
| `SubstationDelete` | `PermDelete` on substation | `PermSubstationConnection` on migration substation | Both required (migration only) |
| `AllocationDelete` | `PermSourceAllocation` on source | `PermDelete` on allocation | Either sufficient |
| `SubstationAllocationDisconnect` | `PermAllocationConnection` on allocation | `PermAllocationConnection` on destination | Either sufficient |
| `GuildMembershipJoinProxy` | `PermGuildMembership` on guild | `PermSubstationConnection` on substation | Both required (substation only if specified) |

### Permission Flag Usage Summary

| Permission | Value | Used By |
|------------|-------|---------|
| `PermPlay` | 1 | StructBuildInitiate, StructBuildCancel, StructActivate, StructDeactivate, StructStealthActivate, StructStealthDeactivate, StructMove, StructAttack, StructDefenseSet, StructDefenseClear, FleetMove, PlanetExplore |
| `PermAdmin` | 2 | GuildUpdateOwnerId, PlayerUpdateGuildRank, AllocationTransfer, Permission transactions (when caller-specified) |
| `PermUpdate` | 4 | GuildUpdateEntryRank, ProviderUpdate*, AgreementClose, AgreementCapacity/Duration* |
| `PermDelete` | 8 | AddressRevoke, ProviderDelete, SubstationDelete, AllocationDelete (fallback) |
| `PermTokenTransfer` | 16 | PlayerSend, GuildBankRedeem |
| `PermTokenInfuse` | 32 | ReactorInfuse, ReactorCancelDefusion, StructGeneratorInfuse |
| `PermTokenMigrate` | 64 | ReactorBeginMigration |
| `PermTokenDefuse` | 128 | ReactorDefuse |
| `PermSourceAllocation` | 256 | AllocationCreate, AllocationUpdate, AllocationDelete (primary), ProviderCreate |
| `PermGuildMembership` | 512 | All GuildMembership* transactions, GuildMembershipKick |
| `PermSubstationConnection` | 1024 | SubstationPlayerConnect/Disconnect/Migrate, GuildCreate, GuildUpdateEntrySubstationId, GuildMembershipJoinProxy, SubstationDelete (migration) |
| `PermAllocationConnection` | 2048 | SubstationCreate, SubstationAllocationConnect/Disconnect |
| `PermGuildTokenBurn` | 4096 | GuildBankConfiscateAndBurn |
| `PermGuildTokenMint` | 8192 | GuildBankMint |
| `PermGuildEndpointUpdate` | 16384 | GuildUpdateEndpoint |
| `PermGuildJoinConstraintsUpdate` | 32768 | GuildUpdateJoinInfusionMinimum, GuildUpdateJoinInfusionMinimumBypassBy* |
| `PermGuildSubstationUpdate` | 65536 | GuildUpdateEntrySubstationId |
| `PermProviderWithdraw` | 131072 | ProviderWithdrawBalance |
| `PermProviderOpen` | 262144 | AgreementOpen (guildMarket only) |
| `PermReactorGuildCreate` | 524288 | GuildCreate |
| `PermHashBuild` | 1048576 | Part of PermHashAll |
| `PermHashMine` | 2097152 | Part of PermHashAll |
| `PermHashRefine` | 4194304 | Part of PermHashAll |
| `PermHashRaid` | 8388608 | PlanetRaidComplete, part of PermHashAll |
| `PermHashAll` (composite) | 15728640 | StructBuildComplete, StructOreMinerComplete, StructOreRefineryComplete |

---

## See Also

- [combat.md](combat.md) -- Combat mechanics and attack resolution
- [power.md](power.md) -- Power requirements
- [resources.md](resources.md) -- Resource types
- `schemas/entities.md` -- Entity permission properties
- `schemas/actions.md` -- Transaction definitions
- `api/queries/permission.md` -- Permission query API
