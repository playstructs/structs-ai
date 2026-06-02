# Webapp Agreement API Endpoints

**Category**: webapp (catalog read)
**Entity**: Agreement (`structs.agreement`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Energy-supply agreements between providers and consumers. Each agreement is associated with an allocation, a creator, an owner, and a provider. See `knowledge/economy/energy-market.md` for the economic model and `api/queries/agreement.md` for the equivalent on-chain query endpoints.

### Webapp catalog columns (`structs.agreement`)

The webapp returns the raw `structs.agreement` row (snake_case). There is **no `guild_id` and no `consumer_id`** on the row — those are chain-only concepts (`consumerId` exists in the protobuf/consensus shape, not here).

| Column | Description |
|--------|-------------|
| `id` | Agreement identifier |
| `provider_id` | Provider supplying the energy |
| `allocation_id` | Allocation the agreement draws against |
| `capacity` | Contracted capacity |
| `start_block` / `end_block` | Active block window |
| `creator` | Player who created the agreement |
| `owner` | Player who owns the agreement |
| `created_at` / `updated_at` | Timestamps |

### Scoping agreements to a guild

Because there is no `guild_id` on agreements, "agreements for a guild" must be resolved through the substation → provider chain:

1. Resolve the guild's `entry_substation_id` (from the guild row / `GuildManager`).
2. List that substation's providers: `GET /api/provider/substation/{entry_substation_id}/page/{n}` (provider rows carry `substation_id`, not `guild_id`).
3. For each provider, list its agreements: `GET /api/agreement/provider/{provider_id}/page/{n}`.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/agreement/all/page/{page}` | List every agreement, paginated (flat array) | Yes |
| GET | `/api/agreement/provider/{provider_id}/page/{page}` | List agreements supplied by a provider (flat array) | Yes |
| GET | `/api/agreement/allocation/{allocation_id}` | Get the single agreement linked to an allocation (one row) | Yes |
| GET | `/api/agreement/creator/{creator}` | Get the single agreement created by a player (one row, `LIMIT 1`) | Yes |
| GET | `/api/agreement/owner/{owner}` | Get the single agreement owned by a player (one row, `LIMIT 1`) | Yes |

---

## Endpoint Details

### GET `/api/agreement/all/page/{page}`

List every agreement.

- **ID**: `webapp-agreement-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/agreement/provider/{provider_id}/page/{page}`

List agreements supplied by a provider.

- **ID**: `webapp-agreement-by-provider`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `provider_id` | string | Yes | provider-id | Provider identifier (e.g. `10-1`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/agreement/allocation/{allocation_id}`

Get the single agreement attached to an allocation.

- **ID**: `webapp-agreement-by-allocation`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `allocation_id` | string | Yes | allocation-id | Allocation identifier (e.g. `6-1`) |

---

### GET `/api/agreement/creator/{creator}`

Get **the** agreement created by a player. This is a `queryOne` lookup (`LIMIT 1`) — `data` is a single object (or `null`), **not** a paginated list, despite the plural wording elsewhere.

- **ID**: `webapp-agreement-by-creator`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `creator` | string | Yes | player-id | Creator player identifier |

---

### GET `/api/agreement/owner/{owner}`

Get **the** agreement owned by a player. Also a `queryOne` lookup (`LIMIT 1`) — `data` is a single object (or `null`), not a list.

- **ID**: `webapp-agreement-by-owner`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier |

---

Responses use the shared envelope. The `/all` and `/provider/{id}` routes return a **flat array** in `data` (page size 100); `/allocation/{id}`, `/creator/{creator}`, and `/owner/{owner}` are single-row `queryOne` lookups (`data` is one object or `null`). See `protocols/webapp-api-protocol.md`.
