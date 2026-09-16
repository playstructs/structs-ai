---
title: Struct attribute query endpoints
description: "Query struct attributes on the consensus network: health, status, ambit, and other per-struct scalars."
sitemap: false
robots: noindex
---

# Struct Attribute Query Endpoints

**Category**: Query
**Entity**: StructAttribute
**Base URL**: local `http://localhost:1317`; public testnet `https://public.testnet.structs.network`
**Base Path**: `/structs`

HP and numeric status live here, not on the base struct row. See [integration-notes — Where struct HP and status live](../integration-notes.md#where-struct-hp-and-status-live). Webapp: [struct-attribute.md](../webapp/struct-attribute.md).

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/struct_attribute/{structId}/{attributeType}` | Get one attribute | No | No |
| GET | `/structs/struct_attribute` | List all struct attributes | No | Yes |

**CLI**: `struct-attribute` · `struct-attribute-all`

## Endpoint Details

### Get Struct Attribute

`GET /structs/struct_attribute/{structId}/{attributeType}`

| Name | Type | Required | Description |
|-------|------|----------|-------------|
| structId | string | Yes | Struct id (`5-n`) |
| attributeType | string | Yes | Attribute name (e.g. health, status) |

A missing row means no value stored (often treat as 0), not a 404 for “zero HP.”

### List All Struct Attributes

`GET /structs/struct_attribute`
