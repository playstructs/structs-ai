---
description: "Exact webapp response contracts: authentication, coherent readiness, vault funds, current positions, pagination and safe reconciliation."
---

# Web Application API Protocol

Use the guild's configured webapp base URL for `/api/...`; use its independently
configured chain LCD/RPC for `/structs/...`, native simulation and transaction
confirmation. This page describes reviewed webapp integration `43bc1086`, paired
with structs-pg `400e1c1`. Verify the actual deployment before relying on the contract.

## Response Envelope

```json
{"success":true,"errors":[],"data":null}
```

- Check HTTP status and `success`. Infrastructure failures may not be JSON.
- `errors` is an empty array or a keyed object; handle both.
- `data` is a single object, a flat list, or null. It has no universal nested
  `player`, `guild`, `rows`, `transactions` or `stats` wrapper.
- Optional `total` and `meta` belong to the envelope; retain them through factories,
  caches and empty lists. Successful reads do not necessarily establish readiness.

Exact chain integers and raw monetary values must remain decimal strings. Use
BigInt/exact decimal internally and stringify for JSON. An already-rounded Number
cannot be repaired by `String(value)`. `_p` is a precision/raw-unit suffix, not a
pending-state suffix. Energy uses milliwatts, Alpha uses ualpha; other denominations
and ratio/display columns have their own scale. See
[client state and precision](../develop/client/state-and-data.md).

## Snapshot metadata

Converted gameplay/economy reads obtain their data and readiness in one consistent
SQL snapshot. The complete contract includes:

| Field | Meaning |
|---|---|
| `chain_id`, `protocol`, `observed_protocol`, `activation_height` | Indexed and observed chain eras |
| `api_contract` | `structs-api-v022-1` |
| `cache_epoch` | `structs-api-v022-1:{protocol}` |
| `height`, `indexed_height`, `observed_tip` | Exact string heights, or null when unavailable |
| `required_models` | Explicit model requirements for this response |
| `models` | Per-model exact height, source time and ready flag |
| `source_time` | Complete response boundary time, or null |
| `inventory_authority` | `current-claims-v1` after activation |
| `data_ready` | Consistent source and all required projection watermarks |
| `transaction_ready` | Data readiness plus current cursor status and matching observed era |

The configured chain is `structstestnet-111`, with activation height `3353000`.
The database requires matching cursor/current-block boundaries and, after activation,
contiguous `events-v022-1` source coverage through the same height/hash. Rebuilding a
projection or advancing an old writer's cursor cannot create that evidence.
Required model heights and times must equal the response's indexed boundary;
missing model state cannot borrow the general cursor height.

`data_ready` can be useful during catch-up while `transaction_ready` remains false.
Native preparation must independently verify current chain/height, ownership,
permissions, balances and message execution; API readiness reserves nothing.
Additional `funds_meta`, `positions_meta` or transfer-source checks qualify their
specific data. Do not replace them with a newer `/api/block` response.

| Read | Required evidence |
|---|---|
| Player detail/transfer search | Indexed inventory; individual spendability also has `funds_meta` |
| Inventory / current guild-bank list | Ready `inventory` / `guild_bank` model respectively |
| Player reactor aggregate | Inventory plus complete positions and valid applied power |
| Generator snapshot | Inventory plus valid stored position totals |
| Bespoke ledger page/count/detail/source lookup | Inventory and exact source-match evidence where requested |
| Work routes | Ready `work` model, including empty results |
| Struct catalog/current block | Coherent general boundary; no substitute for another response's required models |

Generic catalog `?include_meta=1` and some analytics still use a **height-only** stamp.
That stamp is not this complete contract. Do not silently synthesize missing fields
or assume every `/api/` response is safe to use for signing.

## Authentication

### Signature-Based Session and Bearer Authentication

POST `/api/auth/login` validates the wallet proof and creates a session cookie.
POST `/api/auth/token` accepts the same proof and returns an opaque bearer with a
24-hour lifetime. Send the cookie or `Authorization: Bearer <token>` for protected
reads/writes. An invalid Bearer credential does not fall back to a valid cookie.

The signed UTF-8 message is:

```text
LOGIN_GUILD{guildId}ADDRESS{address}DATETIME{unix_timestamp}
```

Supply `address`, `guild_id`, `unix_timestamp`, `pubkey`, `signature` in JSON.
Timestamp is a canonical decimal string less than 600 seconds from server time in
either direction. Public key is compressed secp256k1 hex; signature is raw 64-byte
R followed by S, hex-encoded over SHA-256 of that message. The address must be
indexed as approved in the requested guild.

The [authentication reference](../api/webapp/auth.md) lists the exact public guild
profile, directory, roster and statistic routes, plus public signup/proof/status
routes. Catalog, struct and planet-activity reads remain authenticated. Public guild
GET/HEAD supports anonymous CORS; omit cookies/tokens. Private bearer routes need a
separate browser origin policy.

GET `/api/auth/logout` invalidates the presented session and revokes the presented
bearer. Clear local key/session material even if HTTP logout fails, while retaining
public evidence of any uncertain signed transaction. See the
[login example](../examples/auth/webapp-login.md).

## Query Patterns

### Pattern 1: Player Information

`GET /api/player/1-11` returns flat identity/association/grid fields plus
`vault_address`, exact `spendable_alpha_p`, `funds_meta` and envelope `meta`.
`alpha` is the existing floored vault Alpha display. Retained-address wealth,
bonded stake and pending refunds are separate. Unknown funds are null, not zero.
The [player reference](../api/webapp/player.md) describes individual and search reads.

### Pattern 2: Planet Information

Use `/api/planet/{planet_id}` with planet IDs such as `2-1`, and the dedicated
shield/raid routes in the [planet reference](../api/webapp/planet.md).
Do not assume a `{planet, shield, structs}` wrapper: inspect the specific endpoint's
flat SQL projection. A catalog row is not necessarily the enriched detail response.

### Pattern 3: Guild Information

The explicit public GET/HEAD allowlist includes guild profiles, names, directory,
rosters, member counts, power stats and completed-planet counts. Send no credentials
for anonymous cross-origin access. `/api/guild/this` identifies the infrastructure's
host guild, which can differ from the authenticated player's guild.
See the [guild routes](../api/webapp/guild.md) and exact [public access policy](../api/webapp/auth.md).

### Pattern 4: Struct Information

Use `/api/struct/{struct_id}` with IDs such as `5-1`, `/api/struct/player/{player_id}`
and `/api/struct/type`. Preserve current catalog metadata and exact work inputs.
The [generator snapshot](../api/webapp/struct.md#generator-snapshot) keeps stored
applied output separate from the selected funding position and today's rate.

### Pattern 5: Ledger Information

`/api/ledger/player/{player_id}/page/{page}` returns a flat array of positive Alpha
`sent`/`received` movements at currently owned vault/retained addresses. Count uses
the same filter. `/api/ledger/{tx_id}` takes a numeric ledger row ID, **not** a native
transaction hash. Catalog routes include other actions/denominations.

After committed native success, the [transfer-source endpoint](../api/webapp/ledger.md#exact-transfer-source-lookup)
uses exact source coordinates/time/amount to find one indexed sent leg. Missing or
ambiguous matches remain unresolved; they never authorize another payment.

### Pattern 6: Search Endpoints

Raid and transfer search have distinct filters and row shapes. Transfer search is a
bounded indexed list; unresolved funds are completed only by an individual read.
A selected player receives through that player's canonical vault; a literal
non-player address stays literal. See [player search](../api/webapp/player.md#search-and-recipient-selection).

### Pattern 7: Catalog Read

Catalog pages generally use `/api/{entity}[/{filter}/{value}]/page/{page}`.
Entities with a colliding detail route use `/list/`, including player, infusion,
ledger, fleet, planet and struct. Consult each route rather than generating URLs
from the entity name alone.

- Pages are 1-indexed; catalog controller page parameters are digit-constrained.
- Default page size is 100. `TableReadManager` catalog lists accept `limit` clamped
  to 1–10000. This is not a universal override for bespoke ledger/work endpoints.
- List data is a flat array. `include_total=1` adds envelope `total`;
  `include_meta=1` adds height metadata. Those optional values share the page snapshot.
- `updated_since`, `after_id`, `since_seq`, `order`, `is_destroyed` and
  `since_height` are endpoint-specific. Unsupported recognized controls return 400.
- Infusion supports an update-time filter, not a single-ID cursor. Ledger has no
  update-time or sequence cursor. Planet `seq` is meaningful only within its planet.
- Offset pages can change as indexing advances. Do not call a partial/multi-height
  traversal a complete same-height signing snapshot.
- Some scoped lists are unpaged, including player work and player fleet reads.

The [work API](../api/webapp/work.md) and [infusion API](../api/webapp/infusion.md)
separate scoped gameplay reads from catalog browsing. The exact
[planet-activity lookup](../api/webapp/planet-activity.md#exact-event-lookup)
uses `(planet_id, seq, time)` and preserves microseconds for large GRASS stubs.

### Pattern 8: Time-Series Stats

Use the [stat reference](../api/webapp/stat.md) and
[analytics reference](../api/webapp/analytics.md) for time ranges, metric families,
buckets, aggregation cadence and limits. These are historical display/analysis
surfaces. A chart's height-only metadata does not certify native spendability or
current proof eligibility. Their detailed route/tunable baseline remains independent
of the economy-read review on this page.

### Pattern 9: Live Tunables

`GET /api/setting` is public and returns a flat array of `name`, `value` and
`updated_at` rows. Match by name; treat the list as open-ended.
Settings and struct types can change at an upgrade; refresh relevant data with its
protocol epoch rather than labeling it permanently static. Native rules outrank an
old cached catalog or a copied client constant.

## Error Handling

Application errors normally use `success: false` and keyed `errors`, with appropriate
HTTP status such as 400, 401, 403, 409 or 410. A missing single row may be a successful
null; distinguish that from an unavailable prerequisite. Readiness failures can also
be a successful response with explicit false/null evidence.

Use bounded, cancellable reads and limited backoff. The reference browser uses a
15-second request deadline and shares one wallet-backed reauthentication before
retrying a protected read once. Login disables recursive reauthentication. Closing
a view cancels that view's observer, not the underlying signed transaction.

Retrying a read is separate from replaying a mutation. Preserve idempotency/activation
identity on HTTP workflows. Never recreate or rebroadcast an uncertain signed
transaction because of a timeout, 5xx, missing index row or notification loss. Reconcile
its original hash and bytes. See [actions and signing](../develop/client/actions-and-signing.md).

## Comparison with Consensus API

The webapp provides joined/current projections, catalog browsing, history and account
workflows. Native chain queries provide current authority and execution evidence.
Keep their heights and base URLs distinct; neither an API row nor a GRASS event is
a transaction receipt.

There is no webapp `/api/reactor/{id}` or `/api/substation/{id}` detail route in this
reviewed surface. Use the documented catalog filters or the corresponding native
`/structs/reactor/{id}` / `/structs/substation/{id}` query.

## Performance Optimization

Coalesce same-scope refreshes and bound concurrency. Preserve metadata and account
identity with cached data; refuse late responses after navigation/account changes.
Refresh funds, work and catalogs after reconnect/resume and at bounded intervals.
Core NATS does not replay a gap. Apply authoritative snapshots rather than adding
financial notification deltas. See [client state](../develop/client/state-and-data.md)
and [GRASS behavior](../develop/client/realtime-grass.md).

*Verified overview against webapp `43bc1086`: response/consistent-read utilities,
authentication policy, TableReadManager catalog controls, Player/Infusion/Ledger/Work/
Struct managers and TimestampController; database readiness against structs-pg
`400e1c1`. Linked detailed analytics/other-entity references retain their own scope.
This is source/isolated-fixture compatibility, not a public deployment certificate.*
