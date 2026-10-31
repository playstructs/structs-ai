---
description: The complete catalog of API response formats, from general envelopes through authentication, player and planet responses.
---

# API Response Schemas

**Version**: 1.0.0
**Category**: api
**Schema**: JSON Schema Draft-07
**Description**: Complete catalog of all API response formats for AI agents. See `schemas/formats.md` for format specifications.

---

## General Responses

### ApiResponseContentDto (webapp envelope)

Application `structs-webapp` JSON responses use this envelope; infrastructure failures may be non-JSON. PHP `App\Dto\ApiResponseContentDto` defines the fields. Clients must check `success`, then read `errors` or unwrap `data`.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| success | boolean | Yes | `true` on success, `false` on failure |
| errors | array or object | Yes | Empty `[]` on success; usually a keyed map on failure, e.g. `{"signature_validation_failed":"Invalid signature"}`. Preserve both forms. |
| data | object \| array \| null | Yes | Payload. Single-row reads → object; list/catalog reads → flat array; `null` on error or empty single lookup. |

Examples:

```json
{ "success": true, "errors": [], "data": { "id": "1-11" } }
```

```json
{ "success": true, "errors": [], "data": [ { "id": "3-1" }, { "id": "3-2" } ] }
```

```json
{ "success": false, "errors": { "player_address_does_not_exists": "Player address does not exist" }, "data": null }
```

> The consensus network (chain REST) API does NOT use this envelope — it returns Cosmos-SDK shapes with top-level `code`/`message` on error. See `protocols/error-handling.md`.

### Catalog pagination

Catalog list reads put rows **directly in `data` as a flat JSON array** — there is no `rows`/`page`/`page_size` wrapper. Default catalog page size is 100, with endpoint-specific `limit` support. Page numbers start at 1. Bespoke work/ledger reads can retain a fixed limit. Optional `total` and `meta` stay on the envelope; multi-page reads are not one fixed database snapshot. See [catalog conventions](../protocols/webapp-api-protocol.md#pattern-7-catalog-read).

### Consensus PaginationResponse

Key-based pagination used only by the consensus network API (`/structs/...`).

| Field | Type | Description |
|-------|------|-------------|
| pagination.next_key | string | Key for next page |
| pagination.total | string | Total count |

---

## Authentication Responses

### AuthResponse

`POST /api/auth/login` returns HTTP 200, a session cookie and
`{"success":true,"errors":[],"data":null}`. `POST /api/auth/token` accepts the same
hex wallet proof and returns `data` with `access_token`, `token_type: "Bearer"`,
`expires_in: 86400` and `player_id`. The token is opaque, not a JWT. Failure is HTTP
401 with keyed errors. See [authentication](../api/webapp/auth.md) and the
[login example](../examples/auth/webapp-login.md).

### PlayerData

Player data structure, reused across multiple responses.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| username | string | | Player username |
| address | string | blockchain-address | Player blockchain address |

---

## Player Responses

> Webapp note: all webapp response bodies below are carried inside the `data` field of the `ApiResponseContentDto` envelope (`{ "success": true, "errors": [], "data": ... }`). Bespoke endpoints return SQL column names (snake_case) from their backing query unless otherwise noted. Always unwrap `data` after checking `success`.

### WebappPlayerResponse

Web application player response (`data` payload of `GET /api/player/{player_id}`). `data` is a **single flat object** whose keys are the SQL columns from `PlayerManager::getPlayer` (snake_case) — not nested `{player, guild, stats}`.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Player identifier (e.g. `1-11`) |
| primary_address | string | Player's primary signing address |
| vault_address | string or null | Canonical economic address, independently verified |
| spendable_alpha_p | string or null | Exact spendable vault ualpha; unknown is not zero |
| alpha | string or null | Floored Alpha display |
| funds_meta | object | Funds height/readiness/source/provisioning/reason |
| guild_id | string | Guild identifier (e.g. `0-1`) |
| guild_name | string | Guild name |
| substation_id | string | Connected substation |
| planet_id | string | Current planet |
| fleet_id | string | Fleet identifier |
| fleet | object | `row_to_json` of the fleet row |
| username | string | Player UGC username |
| pfp | string | Player UGC profile picture |
| pfp_client_render_attributes | string | Client-side PFP render hints |

The column set may grow; treat unknown response keys as forward-compatible.
Keep envelope readiness metadata with the object. See the [player contract](../api/webapp/player.md)
for funds semantics, exact grid fields and separate history/statistic responses.

### PlayerIdResponse

Player ID response.

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| player_id | string | entity-id | Player identifier in format `type-index` (e.g., `1-11`). Pattern: `^1-[0-9]+$`. Type 1 = Player. |
| address | string | blockchain-address | Player blockchain address |
| guild_id | string | entity-id | Guild identifier in format `type-index` (e.g., `0-1`). Pattern: `^0-[0-9]+$`. Type 0 = Guild. |

### ActivationCodeResponse

Activation creation returns `code` and `activation_id`; the UUID must accompany
subsequent consent, status and cleanup. Public lookup returns scoped activation/player
and guild display context, not a universal `valid` flag or a credential. Do not infer
approval from code existence. Exact request/response shapes and owner checks are in
the [device API](../api/webapp/player-address.md).

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

`GET /api/player/{player_id}/ore/stats` returns one object with `player_id`,
`forfeited`, `mined` and `seized`, or null. These are historical ore-action totals
from the indexed ledger; there is no `ore_by_type` or iron/copper/silver split.
They are separate from current spendable funds.

### BlockHeightResponse

Player last-action block height response. `data` is a single row; the value is an exact SQL numeric string, or `data` is null when no row exists.

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| last_action_block_height | string | Yes | Block height of the player's last action (exact SQL numeric string) |

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


## Snapshot metadata

Converted player/infusion/ledger/work/generator/catalog responses retain `meta` with
chain/protocol/epoch, exact heights, required model evidence and separate data versus
transaction readiness. `funds_meta`, `positions_meta` and `meta.transfer_source` add
read-specific evidence. Generic height-only catalog stamps do not imply this contract.
The authoritative field descriptions are in the
[webapp protocol](../protocols/webapp-api-protocol.md#snapshot-metadata).

*Envelope, auth, activation, player funds, ore and metadata sections reviewed against
webapp `43bc1086` and structs-pg `400e1c1`. Other response summaries retain their
independent earlier scope; consult their specific endpoint before using a payload.*
