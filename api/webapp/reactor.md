# Webapp Reactor API Endpoints

**Category**: webapp (catalog read)
**Entity**: Reactor (`structs.reactor`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

Reactors are the chain's energy source — Alpha Matter staked into a validator. Each reactor row carries a validator address, an owning guild, and an owning player. See `knowledge/mechanics/power.md` and `knowledge/economy/energy-market.md`.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/reactor/all/page/{page}` | List every reactor | No |
| GET | `/api/reactor/validator/{validator_address}/page/{page}` | List reactors backed by a validator | No |
| GET | `/api/reactor/guild/{guild_id}/page/{page}` | List reactors owned by a guild | No |
| GET | `/api/reactor/owner/{owner}/page/{page}` | List reactors owned by a player | No |

---

## Endpoint Details

### GET `/api/reactor/all/page/{page}`

- **ID**: `webapp-reactor-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/reactor/validator/{validator_address}/page/{page}`

- **ID**: `webapp-reactor-by-validator`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `validator_address` | string | Yes | bech32 valoper | Validator operator address (e.g. `structsvaloper1...`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/reactor/guild/{guild_id}/page/{page}`

- **ID**: `webapp-reactor-by-guild`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `guild_id` | string | Yes | guild-id | Guild identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/reactor/owner/{owner}/page/{page}`

- **ID**: `webapp-reactor-by-owner`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `owner` | string | Yes | player-id | Owning player identifier |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
