---
title: Query endpoints by entity
description: Query endpoints split into one file per entity, so an agent can load only the reference it needs instead of the whole API surface.
permalink: /api/queries/
redirect_from:
  - /api/queries/README
  - /api/queries/README.html
---

# Query endpoints by entity

**Version**: 1.0.0  
**Purpose**: Query endpoints split from `endpoints.md` for context window efficiency

---

## Overview

This directory contains query endpoints organized by entity type. This allows AI agents to load only the endpoints they need, reducing context window usage.

**Use Case**: Load specific entity query endpoints when working with that entity, instead of loading the entire `endpoints.md` (1153 lines).

Queries are reads. They do not spend charge the way transactions do, but they still hit the node and they still return string numerics — see [integration notes](../integration-notes.md) before you parse amounts as JSON numbers. If you need a live, sub-second view of the same entities, that is Guild Stack / PostgreSQL, not these REST routes.

---

## Available Query Files

### Core Entity Queries

- **[player.md](player.md)** - Player query endpoints (~50 lines)
- **[planet.md](planet.md)** - Planet query endpoints (~60 lines)
- **[struct.md](struct.md)** - Struct query endpoints (~40 lines)
- **[fleet.md](fleet.md)** - Fleet query endpoints (~50 lines)
- **[guild.md](guild.md)** - Guild query endpoints (~40 lines)

### Resource Entity Queries

- **[reactor.md](reactor.md)** - Reactor query endpoints (~40 lines)
- **[substation.md](substation.md)** - Substation query endpoints (~40 lines)

### Economic Entity Queries

- **[provider.md](provider.md)** - Provider query endpoints
- **[agreement.md](agreement.md)** - Agreement query endpoints
- **[allocation.md](allocation.md)** - Allocation query endpoints
- **[infusion.md](infusion.md)** - Infusion query endpoints (reactor/generator)

### Attributes and grid

- **[grid.md](grid.md)** - Grid attribute queries (capacity, load, ore)
- **[struct-type.md](struct-type.md)** - Struct type catalog
- **[struct-attribute.md](struct-attribute.md)** - Per-struct health/status/ambit
- **[planet-attribute.md](planet-attribute.md)** - Per-planet clocks, shields, slots
- **[guild-membership-application.md](guild-membership-application.md)** - Invite/request rows

### System Queries

- **[system.md](system.md)** - Block height, params, guild charter, validate-signature

### Other Queries

- **[address.md](address.md)** - Address query endpoints (~50 lines)
- **[permission.md](permission.md)** - Permission query endpoints (~70 lines)

---

## Context Window Savings

### Before (Loading endpoints.md)

**To get Player endpoints**:
- Load: `api/endpoints.md` (1153 lines)
- Contains: All query, transaction, and webapp endpoints
- **Waste**: ~1100 lines of unused endpoints

### After (Loading entity query file)

**To get Player endpoints**:
- Load: `api/queries/player.md` (~50 lines)
- Contains: Only Player query endpoints
- **Savings**: 96% reduction (1100 lines saved)

---

## Usage

### Loading Entity Queries

```json
{
  "load": "api/queries/player.md"
}
```

### Loading Multiple Entities

```json
{
  "load": [
    "api/queries/player.md",
    "api/queries/planet.md"
  ]
}
```

---

## Related Documentation

- **Main Endpoints**: [endpoints.md](../endpoints.md) - Endpoint index
- **Transactions**: [messages.md](../transactions/messages.md) — live Msg list
- **Webapp**: [webapp/](../webapp/) - Webapp API endpoints
- **CLI catalog**: [generated/commands.md](https://github.com/playstructs/structs-ai/blob/main/generated/commands.md)

---

*Last Updated: January 2025*
