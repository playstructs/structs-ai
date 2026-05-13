# Webapp Defusion API Endpoints

**Category**: webapp (catalog read)
**Entity**: Defusion (`structs.defusion`)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: May 13, 2026

---

## Overview

In-flight reactor defusion records — Alpha Matter being unbonded from a reactor. Each row tracks `(validator_address, delegator_address, defusion_type, amount, denom)` plus timestamps. The chain transactions are `MsgReactorDefuse` and `MsgReactorCancelDefusion`; this endpoint is the catalog read interface. Old rows are reaped by the database's `structs.CLEAN_DEFUSION()` cron.

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/defusion/all/page/{page}` | List every active defusion | No |
| GET | `/api/defusion/validator/{validator_address}/page/{page}` | List defusions against a validator | No |
| GET | `/api/defusion/delegator/{delegator_address}/page/{page}` | List defusions initiated by a delegator | No |

---

## Endpoint Details

### GET `/api/defusion/all/page/{page}`

- **ID**: `webapp-defusion-all`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/defusion/validator/{validator_address}/page/{page}`

- **ID**: `webapp-defusion-by-validator`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `validator_address` | string | Yes | bech32 valoper | Validator operator address (e.g. `structsvaloper1...`) |
| `page` | integer | Yes | `\d+` | Page number |

---

### GET `/api/defusion/delegator/{delegator_address}/page/{page}`

- **ID**: `webapp-defusion-by-delegator`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `delegator_address` | string | Yes | bech32 | Delegator account address |
| `page` | integer | Yes | `\d+` | Page number |

---

Responses use the standard catalog envelope (see `protocols/webapp-api-protocol.md`).
