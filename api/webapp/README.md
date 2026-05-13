# Webapp API Endpoints

**Purpose**: Webapp endpoints split per entity for context-window efficiency
**Last Updated**: May 13, 2026

---

## Overview

This directory contains the structs-webapp HTTP API split per entity. Agents should load only the entity files they need rather than reading the full endpoint catalog.

**Implementation**: PHP Symfony app at [`playstructs/structs-webapp`](https://github.com/playstructs/structs-webapp). Authentication is handled by the webapp itself (see `auth.md`); the catalog read endpoints below are unauthenticated.

**Base URLs**:

- Local Docker Compose: `http://localhost:8080`
- Public guild webapp (Orbital Hydro): `http://crew.oh.energy`

---

## Files

### Entity-specific endpoints (legacy bespoke endpoints)

These existed before the catalog read layer was added. They tend to return enriched objects (joined data, stats summaries) rather than the raw catalog row.

- [`auth.md`](auth.md) — `/api/auth/*`
- [`player.md`](player.md) — `/api/player/{player_id}/*` plus `/api/player/list/*`
- [`planet.md`](planet.md) — `/api/planet/{planet_id}/*` (shield, raid) plus `/api/planet/list/*`
- [`guild.md`](guild.md) — `/api/guild/*` (directory, roster, power-stats, etc.) plus `/api/guild/list/*`
- [`struct.md`](struct.md) — `/api/struct/*` (player, planet, type, single struct) plus `/api/struct/list/*`
- [`ledger.md`](ledger.md) — `/api/ledger/{tx_id}` and `/api/ledger/player/*` plus `/api/ledger/list/*`
- [`infusion.md`](infusion.md) — `/api/infusion/player/*` plus `/api/infusion/list/*`
- [`system.md`](system.md) — `/api/timestamp` and other system endpoints

### Catalog read endpoints (one entity per file)

Uniform paginated reads under `/api/{entity}[/{filter}]/page/{page}`. See `protocols/webapp-api-protocol.md` for the catalog conventions.

- [`address-tag.md`](address-tag.md) — `/api/address-tag/*`
- [`agreement.md`](agreement.md) — `/api/agreement/*`
- [`allocation.md`](allocation.md) — `/api/allocation/*`
- [`banned-word.md`](banned-word.md) — `/api/banned-word/all/page/{page}`
- [`defusion.md`](defusion.md) — `/api/defusion/*`
- [`fleet.md`](fleet.md) — `/api/fleet/list/*`
- [`grid.md`](grid.md) — `/api/grid/*`
- [`guild-membership-application.md`](guild-membership-application.md) — `/api/guild-membership-application/*`
- [`permission.md`](permission.md) — `/api/permission/*`
- [`permission-guild-rank.md`](permission-guild-rank.md) — `/api/permission-guild-rank/*`
- [`planet-activity.md`](planet-activity.md) — `/api/planet-activity/*`
- [`planet-attribute.md`](planet-attribute.md) — `/api/planet-attribute/*`
- [`provider.md`](provider.md) — `/api/provider/*`
- [`reactor.md`](reactor.md) — `/api/reactor/*`
- [`substation.md`](substation.md) — `/api/substation/*`
- [`struct-attribute.md`](struct-attribute.md) — `/api/struct-attribute/*`
- [`struct-defender.md`](struct-defender.md) — `/api/struct-defender/*`

### Other

- [`setting.md`](setting.md) — `/api/setting` (one-shot snapshot of live tunables)
- [`stat.md`](stat.md) — `/api/stat/{metric}/object/{object_key}/range/page/{page}` with `?start_time=&end_time=`

---

## Loading Strategy

Load just the file matching the entity you are working with. Example: when monitoring raids, load [`planet.md`](planet.md) and [`planet-activity.md`](planet-activity.md), not the entire catalog.

---

## Related Documentation

- `../endpoints.md` — Master endpoint catalog (chain queries, transactions, webapp)
- `../queries/` — Chain query endpoints
- `../transactions/` — Chain transaction endpoints
- `../../protocols/webapp-api-protocol.md` — Catalog conventions, error envelope, pagination
- `../../knowledge/infrastructure/database-schema.md` — Backing PostgreSQL tables
