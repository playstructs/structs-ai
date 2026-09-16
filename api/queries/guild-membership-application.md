---
title: Guild membership application queries
description: "Query guild membership applications on the consensus network: invite and request rows by guild and player."
sitemap: false
robots: noindex
---

# Guild Membership Application Query Endpoints

**Category**: Query
**Entity**: GuildMembershipApplication
**Base URL**: local `http://localhost:1317`; public testnet `https://public.testnet.structs.network`
**Base Path**: `/structs`

Created by invite/request msgs (`MsgGuildMembershipInvite`, `MsgGuildMembershipRequest`, …). Webapp catalog: [guild-membership-application.md](../webapp/guild-membership-application.md). Chain event: [EventGuildMembershipApplication](../chain-events.md).

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/guild_membership_application/{guildId}/{playerId}` | Get one application | No | No |
| GET | `/structs/guild_membership_application` | List all applications | No | Yes |

**CLI**: `guild-membership-application` · `guild-membership-application-all`

## Endpoint Details

### Get Application

`GET /structs/guild_membership_application/{guildId}/{playerId}`

| Name | Type | Required | Description |
|-------|------|----------|-------------|
| guildId | string | Yes | Guild id (`0-n`) |
| playerId | string | Yes | Player id (`1-n`) |

### List All Applications

`GET /structs/guild_membership_application`
