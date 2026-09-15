---
title: Planet attribute query endpoints
description: "Query planet attributes on the consensus network: shields, slots, and the mine/refine clocks."
---

# Planet Attribute Query Endpoints

**Category**: Query
**Entity**: PlanetAttribute
**Base URL**: local `http://localhost:1317`; public testnet `https://public.testnet.structs.network`
**Base Path**: `/structs`

Mine/refine `blockStart` clocks live on the **planet**, not the extractor/refinery. See [hashing.md](../../knowledge/mechanics/hashing.md). Webapp: [planet-attribute.md](../webapp/planet-attribute.md).

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/planet_attribute/{planetId}/{attributeType}` | Get one attribute | No | No |
| GET | `/structs/planet_attribute` | List all planet attributes | No | Yes |

**CLI**: `planet-attribute` · `planet-attribute-all`

## Endpoint Details

### Get Planet Attribute

`GET /structs/planet_attribute/{planetId}/{attributeType}`

| Name | Type | Required | Description |
|-------|------|----------|-------------|
| planetId | string | Yes | Planet id (`2-n`) |
| attributeType | string | Yes | Attribute name |

### List All Planet Attributes

`GET /structs/planet_attribute`
