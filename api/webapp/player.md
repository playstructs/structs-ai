---
description: "Read player identity, exact vault and eligible retained Alpha, source metadata, activity statistics and player catalog rows."
---

# Webapp Player API Endpoints

Player routes require [session or bearer authentication](auth.md). Public guild
profiles/rosters have their own explicit access policy; it does not make these
player routes public. Use the configured guild webapp base URL.

## Endpoint Summary

| Method | Path | Description | Auth Required |
|--------|------|-------------|---------------|
| GET | `/api/player/{player_id}` | Get player information from web application | Yes |
| GET | `/api/player/{player_id}/action/last/block/height` | Get last action block height for player | Yes |
| GET | `/api/player/raid/search` | Search player raids | Yes |
| GET | `/api/player/transfer/search` | Search player transfers | Yes |
| GET | `/api/player/{player_id}/ore/stats` | Get player ore statistics | Yes |
| GET | `/api/player/{player_id}/planet/completed` | Get completed planets for player | Yes |
| GET | `/api/player/{player_id}/raid/launched` | Count of raids this player initiated | Yes |
| GET | `/api/player/list/all/page/{page}` | Catalog list of all players, paginated | Yes |
| GET | `/api/player/list/guild/{guild_id}/page/{page}` | Catalog list of players in a guild | Yes |
| GET | `/api/player/list/substation/{substation_id}/page/{page}` | Catalog list of players connected to a substation | Yes |
| GET | `/api/player/count` | Player census | Yes |
| GET | `/api/player/active/count` | Players with `lastAction` inside `?window_blocks=` (default 16363) | Yes |
| GET | `/api/player/{player_id}/power` | Capacity, load, margin from `view.player` | Yes |
| GET | `/api/player/power/at-risk` | Lowest power-margin players (`?limit=`, default 25) | Yes |

Census, power-margin, and leaderboards for dashboards: [`analytics.md`](analytics.md). Per-player combat feed: [`planet-activity.md`](planet-activity.md).

---

## Player detail

`GET /api/player/{player_id}` returns one flat object or null inside the application
envelope. It is not nested `{player, guild, stats}`. Identity fields include `id`,
`primary_address`, `guild_id`, `substation_id`, `planet_id`, `fleet_id`, `username`,
`pfp`, `pfp_client_render_attributes`, resolved `guild_name`/`tag` and a nested `fleet`
row. A primary signing address and an economic vault are different identities.

### Exact funds and raw values

| Fields | Meaning |
|---|---|
| `vault_address` | Canonical player vault address when verified |
| `spendable_alpha_p` | Exact ualpha available in that vault, or null when unknown |
| `available_alpha_p` | Vault funds plus the verified retained funding window, in exact ualpha |
| `retained_alpha_p`, `retained_sources` | Exact retained total or null; verified `{address, spendable_alpha_p}` rows |
| `retained_funds_meta` | Ready/height/reason plus source limit, candidate count and completeness |
| `alpha` | Floored available Alpha display; 1 Alpha = 1,000,000 ualpha |
| `funds_meta.height`, `ready`, `source`, `provisioned`, `reason` | Evidence specific to spendable funds |
| `ore`, `load`, `structs_load`, `capacity`, `connection_capacity` | Exact SQL grid values, before browser display conversion |
| envelope `meta` | Indexed inventory snapshot, chain/protocol and readiness |

The API uses an indexed balance directly only for a known newly-created BaseAccount
vault. Otherwise the individual-player route can verify canonical vault identity and
native spendable balance at the same indexed height. Sources are
`indexed_base_account` or `chain_spendable`. A failed/pruned/mismatched native read
leaves `spendable_alpha_p` and post-activation `alpha` null and disables transaction
readiness. A proved zero is `"0"`; unknown is not zero.

An unprovisioned vault can already receive coins. Conversely, an existing account's
bank balance alone need not prove spendability. Retained signing-address balances,
reactor stake and pending refunds are not included as spendable vault Alpha. The
[reactor aggregate](infusion.md) supplies those positions separately.

Data and indexed `meta` come from one consistent SQL snapshot. Native fallback runs
after that snapshot closes and must prove its original height. Before spending,
validate the response and funds metadata, then independently prepare/simulate against
current native state. See [snapshot metadata](../../protocols/webapp-api-protocol.md#snapshot-metadata).

## Retained liquid funding

The individual-player read chooses up to 16 approved, non-vault addresses with positive indexed ualpha, ordered by indexed balance descending and bytewise address ties. Native current ownership and SpendableBalanceByDenom are checked at the indexed height. Locked vesting funds, bonded/unbonding stake and reassigned addresses are excluded. The vault fallback and retained verification share a 15-second deadline.

`retained_funds_meta` contains `ready`, `height`, `source_limit:16`, exact-string `candidate_count`, `complete` and `reason`. Ready describes the inspected funding window; `complete:false` explicitly reports more indexed candidates. Its returned amount is not total many-address wallet wealth. Later refreshes can include other addresses as funds are spent. On unavailable retained evidence, the total is null, sources are empty, and `available_alpha_p` includes only the independently verified vault amount.

The existing transfer/infusion flows prefer the vault. With fresh native ownership and the signing key's TokenTransfer bit, they can prepend bounded MsgPlayerSend collection messages for only the shortfall, followed by the requested spend, in one simulated signed transaction. Nothing runs automatically when a refund matures. An infusion-only key can use existing vault funds but cannot collect retained funds. Generator funding remains vault-only. See [actions and signing](../../develop/client/actions-and-signing.md).

## Search and recipient selection

`/api/player/transfer/search` is a bounded indexed search, not an RPC fan-out per
result. It supplies vault/funds fields when indexed evidence permits; unresolved
spendability stays unknown until an individual-player read. Selecting a player for
a transfer resolves the recipient's vault. An explicitly entered non-player address
receives at that literal address. Never substitute a primary address merely because
it appears in a search result.

`/api/player/raid/search` is a separate search interface; use its documented filters
and returned row fields rather than assuming a nested `raids` payload or a generic
`status` query. Both searches use the normal envelope.

## Activity and display reads

| Endpoint suffix after `/api/player/{player_id}` | Data |
|---|---|
| `/action/last/block/height` | `last_action_block_height` as an exact SQL numeric string; null if no row |
| `/ore/stats` | `player_id`, `forfeited`, `mined`, `seized` historical ore totals, or null |
| `/planet/completed` | Object with `count` |
| `/raid/launched` | Object with `count` of `raid_status: initiated` activity attributed through fleet ownership |
| `/power` | Stored capacity/load/margin read; not a current native admission check |

Ore totals use the ledger's ore action categories and indexed address attribution;
there are no iron/copper/silver subtypes in this response. These historical display
queries are separate from exact spendable funds and do not share every readiness
field. Never promote a bare last-action or statistic row to a complete economy snapshot.

## Profile updates

`username` and `pfp` are chain UGC, set through signup or the appropriate native
player-update messages. `pfp_client_render_attributes` contains rendering hints.
There is no HTTP username mutation endpoint. Native permission/validation still
applies; reading identity fields does not grant authority to change them.

## Catalog lists

The `/api/player/list/...` routes return flat arrays of stored player rows. They are
not enriched detail responses and do not guarantee `funds_meta`. Pages start at 1,
default to 100 rows and accept the catalog's optional limit/filter/metadata controls.
See [catalog conventions](../../protocols/webapp-api-protocol.md#pattern-7-catalog-read).
Keep response metadata attached; paged requests are separate snapshots.

*Player detail/funds, transfer search and the listed activity shapes verified against
webapp `581fcd0f` PlayerManager, PlayerController, VaultFundsManager and RetainedFundsManager, with
structs-pg `400e1c1` ownership/readiness. Analytics-specific tunables retain their
separate reference and validation scope.*
