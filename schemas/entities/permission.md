---
title: Permission entity schema
description: "Permission records: a permissionId plus a 25-bit value, and guild-rank rows (object, guild, bit, rank)."
---

# Permission Entity Schema

**Category**: core
**Entity**: Permission
**Endpoint**: `/structs/permission/{permissionId}`
**Source**: `proto/structs/structs/permission.proto`

---

## Description

Object/address grants are `PermissionRecord`. Guild rank gates are `GuildRankPermissionRecord` (one bit per row). Flag table: [permissions.md](../../knowledge/mechanics/permissions.md).

## PermissionRecord

| Field | Type | Description |
|-------|------|-------------|
| permissionId | string | Composite id for the grant |
| value | uint64 (JSON string) | Bitmask. `PermAll` = 33554431. Bit 24 is `PermGuildUGCUpdate`. |

## GuildRankPermissionRecord

| Field | Type | Description |
|-------|------|-------------|
| objectId | string | Object the rank gate is on |
| guildId | string | Guild whose ranks apply |
| permissions | uint64 (JSON string) | **Single bit** in query responses |
| rank | uint64 (JSON string) | Worst-allowed rank for that bit |

## Query Patterns

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/permission/{permissionId}` |
| all | `/structs/permission` |
| byObject | `/structs/permission/object/{objectId}` |
| byPlayer | `/structs/permission/player/{playerId}` |
| guildRankByObject | `/structs/guild_rank_permission/object/{object_id}` |
| guildRankByObjectAndGuild | `/structs/guild_rank_permission/object/{object_id}/guild/{guild_id}` |

See [api/queries/permission.md](../../api/queries/permission.md).
