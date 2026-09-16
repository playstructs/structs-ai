---
title: Struct type query endpoints
description: "Query struct types on the consensus network: the catalog of buildable types, stats, and weapon fields."
sitemap: false
robots: noindex
---

# Struct Type Query Endpoints

**Category**: Query
**Entity**: StructType
**Base URL**: local `http://localhost:1317`; public testnet `https://public.testnet.structs.network`
**Base Path**: `/structs`

Integer IDs (not `type-index`). Schema: [struct-type.md](../../schemas/entities/struct-type.md). Gameplay catalog: [struct-types.md](../../knowledge/entities/struct-types.md). Generated stamp: [generated/struct-types.md](https://github.com/playstructs/structs-ai/blob/main/generated/struct-types.md).

## Endpoint Summary

| Method | Path | Description | Auth | Paginated |
|--------|------|-------------|------|-----------|
| GET | `/structs/struct_type/{id}` | Get struct type by integer id | No | No |
| GET | `/structs/struct_type` | List all struct types | No | Yes |

**CLI**: `struct-type` · `struct-type-all`

## Endpoint Details

### Get Struct Type

`GET /structs/struct_type/{id}`

| Name | Type | Required | Description |
|-------|------|----------|-------------|
| id | uint64 | Yes | Struct type id (`1` Command Ship, `14` Ore Extractor, …) |

- **Schema**: [struct-type](../../schemas/entities/struct-type.md)

### List All Struct Types

`GET /structs/struct_type`
