---
title: Infusion query endpoints
description: "Query infusions on the consensus network: Alpha committed to a reactor or generator, keyed by destination and address."
---

# Infusion Query Endpoints

**Category**: Query
**Entity**: Infusion
**Base URL**: local `http://localhost:1317`; public testnet `https://public.testnet.structs.network`
**Base Path**: `/structs`

Keyed on `(destinationId, address)`. Do not treat the first list row as “the reactor’s infusion.” Schema: [infusion.md](../../schemas/entities/infusion.md). Mechanics: [energy.md](../../knowledge/mechanics/energy.md#creating-capacity-infusion-splits-964).

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/infusion/{destinationId}/{address}` | Get one infusion | No | No |
| GET | `/structs/infusion` | List all infusions | No | Yes |
| GET | `/structs/infusion_by_destination/{destinationId}` | List infusions to a destination | No | Yes |

**CLI**: `infusion` · `infusion-all` · `infusion-all-by-destination`

## Endpoint Details

### Get Infusion

`GET /structs/infusion/{destinationId}/{address}`

| Name | Type | Required | Description |
|-------|------|----------|-------------|
| destinationId | string | Yes | Reactor `3-n` or generator struct id |
| address | string | Yes | Infusing Cosmos address |

- **Schema**: [infusion](../../schemas/entities/infusion.md)

### List All Infusions

`GET /structs/infusion`

### List Infusions by Destination

`GET /structs/infusion_by_destination/{destinationId}`

Returns **one row per infusing address**. Aggregate across pages (limit 100) for a destination total.
