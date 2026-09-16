---
title: Address entity schema
description: "The Address association: a Cosmos key bound to a player, with registration status and permission bits."
sitemap: false
robots: noindex
---

# Address Entity Schema

**Category**: core
**Entity**: Address
**Endpoint**: `/structs/address/{address}`
**Source**: `proto/structs/structs/address.proto`, `QueryAddressResponse`

---

## Description

A Cosmos `structs1…` key associated with a player. LCD returns a **flat** object (no `Address` wrapper): `address`, `playerId`, `permissions`.

## Properties (LCD)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| address | string | Yes | Blockchain address |
| playerId | string | Yes | Owning player ID (`1-n`) |
| permissions | string | Yes | `uint64` permission bitmask as a JSON string |

Typed chain events use `AddressAssociation` (`address`, `playerIndex`, `registrationStatus`) — see [chain-events.md](../../api/chain-events.md).

## Query Patterns

| Pattern | Endpoint | CLI |
|---------|----------|-----|
| byAddress | `/structs/address/{address}` | `structsd query structs address [addr]` |
| all | `/structs/address` | `address-all` |
| byPlayer | `/structs/address_by_player/{playerId}` | `address-all-by-player` |

See [api/queries/address.md](../../api/queries/address.md) and [permissions.md](../../knowledge/mechanics/permissions.md).
