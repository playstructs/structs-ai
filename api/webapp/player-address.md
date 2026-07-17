# Webapp Player Address API Endpoints

**Category**: webapp
**Entity**: PlayerAddress (`structs.player_address`, plus pending/meta/activation-code companions)
**Base URL**: `${webappBaseUrl}` (default: `http://localhost:8080`, public guild webapp: `http://crew.oh.energy`)
**Last Updated**: July 17, 2026

---

## Overview

Manages the additional signing addresses attached to a player. A player has one primary address (set at signup) and may register further addresses — each with its own permission set — so multiple keys or delegate agents can act for the same player. Adding an address is a two-step, signature-validated flow: a **pending** address is proposed, an **activation code** is issued, and the address is confirmed. See `knowledge/mechanics/permissions.md` for the permission model and `.cursor/skills/structs-permissions/SKILL.md` for delegation recipes.

Two routes live under the public `/api/auth/*` prefix (no session required — they are part of onboarding/login); the rest require an authenticated session (`PHPSESSID` cookie from `/api/auth/login`).

---

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/auth/player-address/{address}/guild/{guild_id}/player-id` | Resolve a player ID from an address + guild | No (public prefix) |
| POST | `/api/auth/player-address` | Propose a pending address (signature-validated) | No (public prefix) |
| POST | `/api/player-address/meta` | Attach metadata to an address | Yes |
| POST | `/api/player-address/activation-code` | Create an activation code for a pending address | Yes |
| DELETE | `/api/player-address/activation-code/{code}` | Delete an activation code | Yes |
| GET | `/api/player-address/code/{code}` | Get the pending address for an activation code | Yes |
| GET | `/api/player-address/count/player/{player_id}` | Count a player's registered addresses | Yes |
| GET | `/api/player-address/player/{player_id}` | List a player's registered addresses | Yes |
| PUT | `/api/player-address/pending/permissions` | Set permissions on a pending address | Yes |
| PUT | `/api/player-address/permissions` | Set permissions on a confirmed address | Yes |
| GET | `/api/player-address/{address}` | Get details for a single address | Yes |

---

## Endpoint Details

### GET `/api/auth/player-address/{address}/guild/{guild_id}/player-id`

Resolve which player a given signing address belongs to within a guild. Used during login before a session exists.

- **ID**: `webapp-player-address-player-id`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `address` | string | Yes | cosmos-address | Signing address (e.g. `structs1...`) |
| `guild_id` | string | Yes | guild-id | Guild identifier (e.g. `0-1`) |

---

### POST `/api/auth/player-address`

Propose a new pending address for a player. The request body carries the address, a signature, and a pubkey; the signature is checked by `SignatureValidationManager` before the pending row is persisted.

- **ID**: `webapp-player-address-add-pending`

---

### POST `/api/player-address/meta`

Attach metadata (label/render attributes) to an address.

- **ID**: `webapp-player-address-add-meta`

---

### POST `/api/player-address/activation-code`

Create an activation code for a pending address so it can be confirmed.

- **ID**: `webapp-player-address-create-activation-code`

---

### DELETE `/api/player-address/activation-code/{code}`

Delete (revoke) an outstanding activation code.

- **ID**: `webapp-player-address-delete-activation-code`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `code` | string | Yes | string | Activation code |

---

### GET `/api/player-address/code/{code}`

Look up the pending address associated with an activation code.

- **ID**: `webapp-player-address-by-code`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `code` | string | Yes | string | Activation code |

---

### GET `/api/player-address/count/player/{player_id}`

Count the addresses registered to a player.

- **ID**: `webapp-player-address-count`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | `\d+-\d+` | Player identifier (e.g. `1-11`) |

---

### GET `/api/player-address/player/{player_id}`

List the addresses registered to a player.

- **ID**: `webapp-player-address-list`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `player_id` | string | Yes | `\d+-\d+` | Player identifier (e.g. `1-11`) |

---

### PUT `/api/player-address/pending/permissions`

Set the permission bitmask on a **pending** address before it is confirmed.

- **ID**: `webapp-player-address-set-pending-permissions`

---

### PUT `/api/player-address/permissions`

Set the permission bitmask on a **confirmed** address. Session-scoped to the acting player.

- **ID**: `webapp-player-address-set-permissions`

---

### GET `/api/player-address/{address}`

Get details for a single address.

- **ID**: `webapp-player-address-details`

| Name | Type | Required | Format | Description |
|------|------|----------|--------|-------------|
| `address` | string | Yes | cosmos-address | Signing address (e.g. `structs1...`) |

---

Responses use the shared envelope (`{ "success": true, "errors": {}, "data": ... }`). Write routes return `{ "success", "errors", "data": null }` on success or keyed errors on failure. See `protocols/webapp-api-protocol.md`.
