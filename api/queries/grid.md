---
title: Grid query endpoints
description: "Query grid attributes on the consensus network: the per-object key-value store for capacity, load, ore, and charge."
---

# Grid Query Endpoints

**Category**: Query
**Entity**: Grid (`GridRecord`)
**Base URL**: local `http://localhost:1317`; public testnet `https://public.testnet.structs.network`
**Base Path**: `/structs`

The grid is the scalar store behind player/planet/struct power and ore. Mechanics: [energy.md](../../knowledge/mechanics/energy.md). Webapp: [grid.md](../webapp/grid.md).

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/grid/{attributeId}` | Get one grid attribute | No | No |
| GET | `/structs/grid` | List all grid attributes | No | Yes |

**CLI**: `structsd query structs grid [attributeId]` · `grid-all`

## Endpoint Details

### Get Grid Attribute

`GET /structs/grid/{attributeId}`

| Name | Type | Required | Description |
|-------|------|----------|-------------|
| attributeId | string | Yes | Grid attribute id |

- **Schema**: grid attribute rows (`attributeId`, `value` as a JSON string). Mechanics: [energy.md](../../knowledge/mechanics/energy.md).

### List All Grid Attributes

`GET /structs/grid`

Paginated `GridRecord` list. `uint64` values are JSON strings.
