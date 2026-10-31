---
title: Client state, data, and precision
description: "Exact values, coherent API snapshots, vault spendability, scoped refresh, catalogs, and session state in the reference client."
---

# Client state, data, and precision

The reference client retains exact values and source metadata alongside its existing
display models. Readiness is evidence about the response used by an action, not a
property that can be borrowed from a newer `/api/block` response. This page describes
webapp integration `581fcd0f` with structs-pg `400e1c1`.

## Numbers arrive as strings

Keep uint64/int64 values, coin amounts, masks, nonces and work inputs as canonical
decimal strings at JSON boundaries. Use BigInt or exact decimal arithmetic internally,
then stringify before queue/localStorage JSON. Reject an already-rounded Number;
converting it to a string cannot recover the original integer.

| Value | Representation/use |
|---|---|
| Chain uint64/int64 and generated Structs protobuf fields | Exact decimal strings with signed/unsigned range validation |
| Bank coins | Exact SDK integer strings; do not limit every coin to uint64 |
| Generator funding/work/catalog uint64 inputs | Enforce the specific uint64 domain |
| Permission masks | Exact strings; preserve bits outside the existing controls |
| LegacyDec | Decimal text in LCD JSON; scaled 18-place integer text in protobuf wire fields |
| Energy | Raw milliwatts; divide by 1000 only for a watts display |
| Alpha | Raw `ualpha`; 1 Alpha = 1,000,000 ualpha |
| Installed CosmJS query/account inputs | Safe integers only where the library requires Number; refuse unsupported larger values |

`PlayerFactory` retains `load_p`, `structs_load_p`, `capacity_p`,
`connection_capacity_p` and `ore_p` before legacy display conversions. It also keeps
`snapshot_meta`. Its display fields still divide/truncate into Number and are not
suitable signing or accounting inputs. `InfusionFactory` preserves exact fields and
metadata. `WorkFactory` validates identity/category and uint64 strings for the start
anchor and difficulty. Generated request-schema validation rejects unknown fields
that `fromPartial` alone would silently discard.

The migration does not make every unrelated display setter an exact accounting
system. Use the preserved raw fields and validated snapshots for decisions, and
format only at the rendering boundary.

## The REST client

`GuildAPI` wraps the guild's PHP/PostgreSQL API. The stock browser uses its same-origin
session cookie; the API also offers [bearer login](../../api/webapp/auth.md) for other
clients. Public guild discovery/statistics require no credentials. Private entity
and device reads retain authentication and owner checks.

The application envelope is:

```json
{"success":true,"errors":[],"data":null}
```

`GuildAPIResponseFactory` validates the required fields and retains optional `meta`
and `total`, including false/null/zero values. Errors are usually keyed maps; do not
require them always to be objects. `JsonAjaxer` defaults to a 15-second abortable
request, treats 5xx/non-JSON as transport errors, and handles 401/403 through a shared
wallet-backed reauthentication attempt before retrying once. Login itself disables
that recursive recovery. An aborted observer must not keep waiting on shared login.

A read retry does not authorize replaying a chain transaction. Confirm the specific
write's identity/idempotency contract before reissuing an HTTP operation.

## Snapshot metadata and readiness

Converted responses obtain their data and `meta` in one SQL snapshot. Metadata carries:

- `chain_id`, `protocol`, `observed_protocol`, `activation_height`
- `api_contract: "structs-api-v022-1"` and matching `cache_epoch`
- exact/null `height`, `indexed_height`, `observed_tip`
- `required_models`, with each model's height, source time and ready flag
- `data_ready`, `transaction_ready`, and current inventory authority

`validateReadSnapshot` checks the response's actual chain, protocol, epoch, heights
and required models. `validateSigningSnapshot` also requires transaction readiness.
A complete read can be useful while the writer catches up; it is not necessarily
ready for signing. Spendable-funds display currently uses the stricter signing-ready
inventory check. API tip evidence is cached; native preflight still reads the chain.

For this deployment the chain is `structstestnet-111`, activation height `3353000`.
The post-activation inventory authority is `current-claims-v1`. Each required model
must be explicitly named and ready at the response height. Missing model state is
not zero and cannot be replaced by the general indexed cursor. The backend also
requires contiguous v0.22 source coverage; an old writer merely advancing height
cannot establish readiness.

Keep metadata attached through factories, empty lists and caches. Never assign a
fresh native height to an older SQL row. Native device/position reads deliberately
carry their independent source identity.

## Vault funds and reactor positions

`GET /api/player/{id}` adds `vault_address`, exact `spendable_alpha_p` in ualpha,
and `funds_meta` (`height`, `ready`, `source`, `provisioned`, `reason`). Unavailable
funds are null; proved zero is `"0"`. `spendable_alpha_p` remains vault-only. The existing `alpha` display floors `available_alpha_p`, which adds verified liquid retained funds from a bounded funding window. This is not total wealth or bonded stake. An unprovisioned
vault can already hold transferred coins; provisioning alone does not determine zero.

`retained_sources` and `retained_alpha_p` describe currently owned native spendable coins. `retained_funds_meta` distinguishes ready/unknown evidence and complete/partial candidate coverage. Up to 16 positive indexed candidates are verified at the same height; additional candidates are reported, not silently claimed as inspected. A retained read failure leaves known vault funds usable. See the [player API](../../api/webapp/player.md#retained-liquid-funding) for exact fields. Transfers and reactor infusions collect only their shortfall in the same transaction; generator funding remains vault-only. Player reads have a 16-second client timeout covering the shared 15-second native verification budget.

`GET /api/infusion/player/{id}` retains its aggregate display and supplies exact
positions plus completeness metadata. Positions distinguish the vault from retained
addresses and require current owner attribution. Withdrawal preparation consumes
vault stake first, then eligible retained positions in deterministic order, in one
atomic transaction. The snapshot and native query must agree at the selected height;
an incomplete native page or unknown position cannot be treated as absent.

The generator snapshot endpoint reads stored fuel/applied power plus the selected
source position. Preview changes only that selected position at the current rate;
untouched historical or disabled positions keep their stored output. The address
selector is a read filter, not permission to spend.

### Refresh from committed state

`AlphaRefreshManager` owns one cancellable stream per player/signing account. Inventory,
infusion and related notifications invalidate it; notification values are never
added to or subtracted from the balance. It coalesces bursts, fetches through the
requested event/inclusion height, and rejects stale or conflicting snapshots.

Successful committed transactions request refresh through their inclusion height.
Focus, online, pageshow, GRASS reconnect and a 30-second visible-page poll cover lost
notifications. Failed reads back off while preserving uncertainty. Account changes,
logout or replaced sessions cancel the old stream. Funds metadata remains separate
from the rest of a player row so a newer balance cannot certify stale unrelated data.

## Catalogs and work

`getStructTypes()` performs a fresh, consistent catalog read and shares only concurrent
requests. It does not trust the old metadata-free 24-hour cache. `GameState` validates
complete unique IDs and exact difficulty inputs, refuses older or conflicting
same-height catalogs, and keeps existing type-object references when updating data.

`getWorkByPlayerId()` requires a ready `work` projection, validates owner/object
identity, and retains metadata on every item and on the list, including an empty
list. Only a complete accepted snapshot may stop work that is no longer present.

`WorkRefreshManager` refreshes catalog and scoped outstanding work on reconnect,
resume, protocol boundary changes and a 60-second visible-page poll. Existing workers
must adopt the current rule/catalog epoch while retaining the chain's original start
anchor. See [work-and-pow.md](work-and-pow.md#restoring-after-a-reload).

## GameState

A mutable `GameState` remains shared by managers, listeners and view models.
Observation uses window CustomEvents. Exact snapshots coexist with the established
UI events and display models; no global state-management rewrite is required.

### What persists

`gameState` localStorage keeps wallet material, player ID, saved/last-action heights,
charge display, transfer amount and active map. Player/fleet/struct/planet/catalog
objects are refetched. Router position, some bounded display caches and scoped
pending device keys are separate. Transaction snapshots/journals preserve public
signed evidence independently of private session state.

`TransactionJournal.clearSession()` publishes a cross-tab boundary before clearing
private state. Late wallet derivation, GameState saves and device-key writes honor
that boundary. Tutorial sessions disable persistence, background authority/refresh
work and native signing; returning restores the saved real account.

### Session authority

`SessionAuthorityManager` checks current native address ownership at login/resume,
reconnect and on a visible-page poll. A revocation notification prompts that read;
it does not itself erase the key. Stale/malformed/unavailable responses cannot prove
revocation. A newer confirmed change of owner ends the session and stops workers.

## Bootstrap order

```text
restore local wallet/session and initial settings/guild identity
  → signed API login, guarded against account/navigation changes
  → register current-player GRASS listeners
  → restore signing evidence and connect the bounded RPC client
  → read player, confirmed action height, catalog, fleet and structs
  → install validated state and start funds/authority refresh
  → restore outstanding work and start catalog/work refresh
  → restore the existing route
```

The action lane remains gated until confirmed last-action state is loaded. API/RPC
outages follow bounded recovery; a rejected login is distinct from an outage, and
closing the session prevents late startup work from restoring it. The original
[signing journal](actions-and-signing.md#persistence) remains authoritative across
reload and account handoff.

*Verified against webapp integration `581fcd0f`: GameState, KeyPlayer, GuildAPI,
JsonAjaxer, Player/Infusion/Work/GuildAPIResponse factories, AuthManager,
AlphaRefreshManager, WorkRefreshManager, SessionAuthorityManager, PlayerFunds and
ChainProtocol. Matching database/API evidence is required at deployment.*
