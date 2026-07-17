# API Response Schemas

**Version**: 1.0.0
**Category**: api
**Schema**: JSON Schema Draft-07
**Description**: Complete catalog of all API response formats for AI agents. See `schemas/formats.md` for format specifications.

---

## General Responses

### ApiResponseContentDto (webapp envelope)

Every `structs-webapp` JSON response — success or failure, bespoke or catalog — uses this single envelope (PHP `App\Dto\ApiResponseContentDto`). Clients must check `success`, then read `errors` or unwrap `data`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| success | boolean | Yes | `true` on success, `false` on failure |
| errors | object | Yes | Keyed map of `error_key` → message (e.g. `{"signature_validation_failed":"Invalid signature"}`). Empty `{}` on success. Never a string array. |
| data | object \| array \| null | Yes | Payload. Single-row reads → object; list/catalog reads → flat array; `null` on error or empty single lookup. |

Examples:

```json
{ "success": true, "errors": {}, "data": { "id": "1-11" } }
```

```json
{ "success": true, "errors": {}, "data": [ { "id": "3-1" }, { "id": "3-2" } ] }
```

```json
{ "success": false, "errors": { "player_address_does_not_exists": "Player address does not exist" }, "data": null }
```

> The consensus network (chain REST) API does NOT use this envelope — it returns Cosmos-SDK shapes with top-level `code`/`message` on error. See `protocols/error-handling.md`.

### Catalog pagination

Catalog list reads put rows **directly in `data` as a flat JSON array** — there is no `rows`/`page`/`page_size` wrapper. Page size is fixed at 100 and the page number is a 1-indexed path segment (`/page/{n}`). To detect more pages: if `data.length === 100`, fetch the next page; if fewer than 100 (or empty), stop. See `protocols/webapp-api-protocol.md`.

### Consensus PaginationResponse

Key-based pagination used only by the consensus network API (`/structs/...`).

| Field | Type | Description |
|-------|------|-------------|
| pagination.next_key | string | Key for next page |
| pagination.total | string | Total count |

---

## Authentication Responses

### AuthResponse

Webapp login response. Login uses Cosmos signature verification and returns a **session cookie** (`PHPSESSID`); there is no JWT/bearer token. See `examples/auth/webapp-login.md`.

| Field | Type | Description |
|-------|------|-------------|
| success | boolean | `true` on successful login (HTTP 200) |
| errors | object | Keyed errors on failure (HTTP 401), e.g. `signature_validation_failed`, `player_address_does_not_exists` |
| data | null | Login carries no body payload; identity is established via the `Set-Cookie: PHPSESSID` header |

### PlayerData

Player data structure, reused across multiple responses.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| username | string | | Player username |
| address | string | blockchain-address | Player blockchain address |

---

## Player Responses

> Webapp note: all webapp response bodies below are carried inside the `data` field of the `ApiResponseContentDto` envelope (`{ "success": true, "errors": {}, "data": ... }`). Bespoke endpoints return SQL column names (snake_case) from their backing query unless otherwise noted. Always unwrap `data` after checking `success`.

### WebappPlayerResponse

Web application player response (`data` payload of `GET /api/player/{player_id}`). `data` is a **single flat object** whose keys are the SQL columns from `PlayerManager::getPlayer` (snake_case) — not nested `{player, guild, stats}`.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Player identifier (e.g. `1-11`) |
| primary_address | string | Player's primary signing address |
| guild_id | string | Guild identifier (e.g. `0-1`) |
| guild_name | string | Guild name |
| substation_id | string | Connected substation |
| planet_id | string | Current planet |
| fleet_id | string | Fleet identifier |
| fleet | object | `row_to_json` of the fleet row |
| username | string | Player UGC username |
| pfp | string | Player UGC profile picture |
| pfp_client_render_attributes | string | Client-side PFP render hints |

The column set may grow across releases; treat unknown keys as forward-compatible. For ore/planet/raid figures, call the dedicated `/api/player/{player_id}/*` endpoints.

### PlayerIdResponse

Player ID response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| player_id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| address | string | blockchain-address | Player blockchain address |
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |

### ActivationCodeResponse

Activation code information response.

| Field | Type | Description |
|-------|------|-------------|
| code | string | Activation code |
| valid | boolean | Whether code is valid |
| player_id | string (entity-id) | Associated player ID if applicable. Format: `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |

---

## Planet Responses

### ShieldHealthResponse

Planetary shield health response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| planet_id | string | entity-id | Planet identifier in format `type-index` (e.g., `2-1`). Pattern: `^2-[0-9]+$`. Type 2 = Planet. |
| health | integer | | Shield health value |
| max_health | integer | | Maximum shield health |

### ShieldResponse

Planetary shield information response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| planet_id | string | entity-id | Planet identifier in format `type-index` (e.g., `2-1`). Pattern: `^2-[0-9]+$`. Type 2 = Planet. |
| shield | object | | Shield details |

---

## Guild Responses

### GuildNameResponse

Guild name response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| name | string | | Guild name |

### GuildNameListResponse

List of guild names. Response is an array of objects:

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| name | string | | Guild name |

### GuildRosterResponse

Guild roster response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| members | array of PlayerData | | List of guild members |
| member_count | integer | | Number of members |

### PowerStatsResponse

Power statistics response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |
| total_power | integer | | Total power |
| power_by_type | object | | Power breakdown by type |

---

## Ore and Stats Responses

### OreStatsResponse

Ore statistics response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| player_id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| total_ore | integer | | Total ore mined |
| ore_by_type | object | | Ore counts by type |

### BlockHeightResponse

Player last-action block height response. `data` is a single row; the value is an LCD numeric string.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| last_action_block_height | string | Yes | Block height of the player's last action (LCD numeric string) |

### CountResponse

Count response.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| count | integer | Yes | Count value |

### TimestampResponse

Unix timestamp response. The webapp returns this inside `data` as `{ "unix_timestamp": <int> }` (no `iso` field). The fields below describe the `data` payload.

| Field | Type | Required | Format | Description |
|-------|------|----------|--------|-------------|
| unix_timestamp | integer | Yes | | Current server time in unix seconds |

---

## Transaction Responses

### TransactionResponse

Transaction submission response (Cosmos SDK format).

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| tx_response | object | Yes | Transaction response envelope |

The `tx_response` object:

| Field | Type | Description |
|-------|------|-------------|
| code | integer | Transaction result code (0 = success) |
| txhash | string | Transaction hash |
| height | integer | Block height |
| raw_log | string | Raw log output |

### RPCStatusResponse

RPC node status response.

| Field | Type | Description |
|-------|------|-------------|
| result.node_info | object | Node information |
| result.sync_info | object | Sync information |

