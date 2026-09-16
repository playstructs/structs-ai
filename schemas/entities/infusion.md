---
title: Infusion entity schema
description: "The Infusion record: Alpha committed to a reactor or generator, with fuel, power, commission, and defusing."
sitemap: false
robots: noindex
---

# Infusion Entity Schema

**Category**: economic
**Entity**: Infusion (type code `7`)
**Endpoint**: `/structs/infusion/{destinationId}/{address}`
**Source**: `proto/structs/structs/infusion.proto`

---

## Description

Keyed on **(destination, address)**. Infusing a reactor adds ~96% (at 4% commission) to **your** `capacity`; it does not raise a substation. Mechanics: [energy.md — Infusion](../../knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964).

## Properties

| Field | Type | Description |
|-------|------|-------------|
| destinationType | objectType | Destination kind (reactor or generator struct) |
| destinationId | string | Reactor `3-n` or generator struct id |
| fuel | uint64 (JSON string) | Alpha committed (ualpha) |
| power | uint64 (JSON string) | Power produced from fuel |
| commission | string | Decimal commission (reactor cut) |
| playerId | string | Infusing player |
| address | string | Infusing address |
| ratio | uint64 (JSON string) | Live energy ratio (0 if validator jailed) |
| defusing | uint64 (JSON string) | Amount in unbonding / defusion |

## Query Patterns

| Pattern | Endpoint | CLI |
|---------|----------|-----|
| byDestinationAndAddress | `/structs/infusion/{destinationId}/{address}` | `infusion` |
| all | `/structs/infusion` | `infusion-all` |
| byDestination | `/structs/infusion_by_destination/{destinationId}` | `infusion-all-by-destination` |

See [api/queries/infusion.md](../../api/queries/infusion.md). Webapp lists: [api/webapp/infusion.md](../../api/webapp/infusion.md).
