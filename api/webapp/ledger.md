---
description: "Read owner-aware Alpha history and exact ledger source coordinates, and reconcile indexed transfers after native confirmation."
---

# Webapp Ledger API Endpoints

All routes below require [authentication](auth.md) and use the shared application
envelope. A ledger row is an indexed movement, not native transaction finality.

## Endpoint Summary

| Method | Path | Result |
|---|---|---|
| GET | `/api/ledger/player/{player_id}/page/{page}` | Existing Alpha transfer history |
| GET | `/api/ledger/player/{player_id}/count` | Count with the same ownership/action filters |
| GET | `/api/ledger/{tx_id}` | One ledger row by its numeric row ID, or null |
| GET | `/api/ledger/player/{player_id}/transfer-source` | Exact sent leg matched to verified inclusion coordinates |
| GET | `/api/ledger/list/all/page/{page}` | All ledger actions/denominations |
| GET | `/api/ledger/list/player/{player_id}/page/{page}` | All movements at addresses currently owned by a player |
| GET | `/api/ledger/list/address/{address}/page/{page}` | All movements at one literal address |
| GET | `/api/ledger/stats` | 30-day action/denomination volume; see [analytics](analytics.md) |

## Player history and detail

The existing history page and count select positive `ualpha` `sent`/`received` rows.
They use `structs.asset_owner`: vault and currently approved retained addresses belong
to the player; guild vaults remain guild assets. Counts and pages share that policy.
This is current-owner attribution, not a historical ownership snapshot at each event.

Pages are flat arrays ordered by `time DESC, id DESC`, with 100 rows per page.
Count returns `data: {"count": ...}`. Despite the route parameter name `tx_id`,
`GET /api/ledger/{tx_id}` looks up **ledger.id**, not a chain hash. Detail resolves
`counterparty_player_id` and `counterparty_username` through current ownership,
including a recipient's vault.

Rows retain `address`, `counterparty`, `denom`, `action`, `direction`, `time`,
`chain_id`, `tx_index`, `msg_index`, `event_index`, and exact string `id`, `amount_p`
and `block_height`. `amount` is a display value; `amount_p` is the raw denomination
amount. Preserve complete denominations, including dotted synthetic or slash-bearing
names. Never tokenize them to recover an integer or assume every asset uses Alpha's
six decimal places.

The bespoke history/count/detail methods read data and inventory readiness metadata
inside one consistent SQL snapshot. Inspect `meta.data_ready` and the specific
response boundary; a later `/api/block` cannot certify earlier history.

## Exact transfer-source lookup

After verifying the original signed transaction's committed code-0 result, request:

```text
GET /api/ledger/player/{player_id}/transfer-source
```

Supply these URL-encoded query parameters; unknown parameters are rejected:

| Parameter | Contract |
|---|---|
| `chain_id` | `structstestnet-111` in this integration |
| `block_height` | Positive exact decimal, within PostgreSQL signed bigint |
| `tx_index` | Exact nonnegative transaction index |
| `block_time` | Verified UTC block timestamp, `...Z`, with up to 9 fractional digits |
| `address`, `counterparty` | Exact source/destination addresses from the committed message |
| `denom` | `ualpha` for this endpoint |
| `amount_p` | Positive exact raw coin amount |
| `msg_index`, `event_index` | Optional disambiguators; message index may be `-1` |

The timestamp is truncated to microseconds to match the writer's PostgreSQL encoding.
The query matches source time, chain, height/index, exact amount/denomination,
source/destination, `sent`/`debit` and current player ownership. It does not scan
history for a similar amount or guess a transaction hash.

The envelope may be successful while matching is incomplete. Check
`meta.transfer_source.ready` and `required_height`; reasons are
`indexed_state_unavailable`, `not_indexed`, `not_found` or `ambiguous`. Only exactly
one matching row is returned as ready. Missing/ambiguous history never authorizes a
replacement payment. Keep the original journal and reconcile it independently.

## Catalogs and statistics

`/list/` avoids collision with the single-row path. Catalogs include all actions and
denominations, default to 100 rows, accept a limit clamped to 1–10000 and order newest
first. Ledger catalogs do not support `updated_since`, `after_id` or `since_seq`.
Optional `include_total=1` / `include_meta=1` reads those values with the same page
snapshot, but its height-only stamp is not full transaction-readiness evidence.

Source-aware row idempotency uses `(time, chain_id, tx_index, msg_index, event_index,
denom)`. One native transaction can emit several rows and several denominations;
legacy rows can lack source coordinates. Display row IDs and source-event coordinates
serve different purposes.

Synthetic `ualpha.infused` / `ualpha.defusing` current balances come from complete
native/stored claims, not the sum of historical ledger movements. Slashing, retained
stake and held unbonding make a historical sum unsuitable as current spendability.
Statistics are volume summaries and do not authorize transfers.

*Verified against webapp `43bc1086` (LedgerManager, TransferSourceQuery and
TableReadManager), structs-pg `400e1c1` ownership/readiness/ledger identity, and the
recorded confirmed-transfer, ambiguity and exact-source integration fixtures.*
