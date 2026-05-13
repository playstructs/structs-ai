# Webapp Agreement API Endpoints

**Category**: webapp (catalog read)
**Entity**: Agreement (`structs.agreement`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Energy-supply agreements between providers and consumers. Each agreement is associated with an allocation, a creator, an owner, and a provider. See `knowledge/economy/energy-market.md` for the economic model and `api/queries/agreement.md` for the equivalent on-chain query endpoints.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/agreement/all/page/{page}` | List every agreement, paginated | No |
| GET | `/api/agreement/provider/{provider_id}/page/{page}` | List agreements supplied by a provider | No |
| GET | `/api/agreement/allocation/{allocation_id}` | Get the agreement linked to an allocation | No |
| GET | `/api/agreement/creator/{creator}` | Get agreements created by a player | No |
| GET | `/api/agreement/owner/{owner}` | Get agreements owned by a player | No |

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

Get agreements created by a player.

- **ID**: `webapp-agreement-by-creator`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `creator` | string | Yes | player-id | Creator player identifier |

---

### GET `/api/agreement/owner/{owner}`

Get agreements owned by a player.

- **ID**: `webapp-agreement-by-owner`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
