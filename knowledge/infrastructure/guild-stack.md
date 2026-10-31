---
title: "Guild Stack architecture and services"
description: "The Guild Stack architecture: a Docker Compose app giving local PostgreSQL access to indexed game state, GRASS events, and a webapp."
---

# Guild Stack Architecture

**Purpose**: AI-readable reference for the Structs Guild Stack — a Docker Compose application that provides local PostgreSQL access to indexed game state, GRASS real-time events, a webapp, and transaction signing. This is an advanced/optional upgrade for agents who need sub-second query performance.

**Repository**: `https://github.com/playstructs/docker-structs-guild`

---

## Overview

The Guild Stack runs a full Structs guild node locally via Docker Compose. A single `docker compose up -d` brings up everything needed to participate in the network with fast indexed data access. The key benefit for agents is PostgreSQL: every game state query that takes 1-60 seconds via CLI completes in under 1 second via PG.

Three compose variants exist:

| Variant | File | Purpose |
|---------|------|---------|
| Guild node | `compose.yaml` | Standard deployment: chain node, sync-state indexer, PG, GRASS/NATS, webapp, Struct Control SPA, TSA, crawler |
| Reactor node | `compose-reactor.yaml` | Validator node (adds reactor bootstrap; no sync-state/webapp) |
| Guild + Discord | `compose-discord.yaml` | Discord-oriented topology: `structsd-indexer-config` + `structs-proxy` + `structs-discord`; **no** `structs-sync-state` / `structs-control` (not “standard + bot”) |

**Network identifiers**: `NETWORK_CHAIN_ID=structstestnet-111`; the reviewed Compose
example retains `NETWORK_VERSION=116b` as its bootstrap setting. That does not
select the running protocol. The node image stages v0.22.0 for height 3,353,000;
its committed-height reconciler selects the next block's binary. Verify the
executing version and pin the tested image digest.

---

## Why PostgreSQL Matters

The performance difference between CLI queries and PG is not incremental — it determines what operations are physically possible.

### The Combat Math

One blockchain block is ~6 seconds. Charge is a single **per-player** bar (shared across all your structs), regenerating 1 per block. Fast-fire primaries (Command Ship, Pursuit Fighter, Tank, Starfighter) cost 3 charge — roughly 3 blocks (~18s) between shots if you fire nothing else; heavier hulls cost 5. In active combat, the decision loop is:

1. Query enemy state (who's alive, what defenses)
2. Pick optimal attacker + target + weapon
3. Submit attack transaction
4. Wait for the player's charge bar to refill to the next action's cost (~18-30s)
5. Repeat

**With CLI**: Steps 1-2 take 5-10 seconds. Your 6-second combat cycle becomes 15 seconds. You fire at half rate, and state may be stale by the time you act.

**With PG**: Steps 1-2 take < 1 second. Your combat cycle matches the chain's block time. Targeting decisions use current-block state.

### What PG Enables

| Capability | CLI | PG |
|------------|-----|-----|
| Real-time threat detection | Impossible (query > block time) | Poll every 6s |
| Defense-aware combat targeting | Minutes to gather, stale by execution | Full matrix in <1s |
| Automated raid target selection | 2-5 min to scout | Score all planets in <1s |
| Fleet composition analysis | Fetch all structs, parse, cross-reference | Single JOIN, instant |
| Multi-step combat sequences | 5-10s gaps between shots | Re-query between shots in <1s |
| Galaxy-wide intelligence | 30-60s for player-all, often times out | Arbitrary filters and JOINs in <1s |

---

## Service Catalog

| Service | Ports | Purpose |
|---------|-------|---------|
| `structsd` | 26656, 26657, 1317 | Blockchain node (CometBFT + Cosmos SDK). Chain only — does not write to PG. |
| `structs-pg-init` | — | One-shot: database creation, role setup, initial Sqitch deploy. Exits on success. |
| `structs-pg` | 5432 | PostgreSQL + TimescaleDB. Server/extension versions belong to the image and volume, not the Sqitch schema version. |
| `structs-pg-auto-migrate` | — | Re-runs `sqitch deploy` on a loop for schema updates. |
| `structs-sync-state` | — | Chain event indexer. Polls `structsd` RPC, writes `structs.*` and `sync_state.*`. **Do not scale** (writer lock). |
| `structs-nats` | 4222, 8222, 1443 | NATS message broker (cluster: GRASS). WebSocket on 1443, monitoring on 8222. |
| `structs-grass` | — | Event bridge: PG `NOTIFY 'grass'` → NATS subjects. |
| `structs-webapp` | 8080, 443 | Guild webapp (PHP/Symfony). Guild API at `/api/`. Bind-mounts `WEBAPP_SOURCE`. |
| `structs-control` | 8081 | Struct Control SPA — browser admin/operator console. Dev mode proxies the webapp; bind-mounts `CONTROL_SOURCE`. |
| `structs-tsa` | — | Transaction Signing Agent. Manages signing account pool. |
| `structs-crawler` | — | Supplementary guild metadata crawler. |

Two services mount source trees from **sibling checkouts on the host**, not from their images: `structs-webapp` needs `WEBAPP_SOURCE` (default `../structs-webapp/src`) and `structs-control` needs `CONTROL_SOURCE` (default `../structs-control`). Start either without that checkout and the container crash-loops — `structs-control` fails immediately on a missing `/app/package.json`. Neither is needed for PG query work.

`structs-pg` starts `structs-pg-init` automatically through a `service_completed_successfully` dependency, but `structs-pg-auto-migrate` has no such link. Init uses a completion marker, so a container restart does not itself advance an existing schema. Start `structs-pg-auto-migrate` explicitly to deploy/verify the configured target. The current image defaults to a bundled commit and bounded compatible target; tracking a remote branch requires explicit `STRUCTS_PG_MIGRATION_MODE=branch` opt-in.

The PostgreSQL schema (`structs.*`, `sync_state.*`, `cache.*` views, `signer.*`, `view.*` — see [database-schema.md](database-schema.md)) is owned by [`playstructs/structs-pg`](https://github.com/playstructs/structs-pg) and applied with **Sqitch**. Pin the full `STRUCTS_PG_REF` and image digest, and pass the reviewed migration mode/target into the containers through Compose. The default staging target `table-signer-tx-20261030-authority-contract` is insufficient for the full v0.22 writer/TSA/webapp contract.

The Guild Stack does not include an MCP server. Agents connect to the game through the MCP server embedded in [`structs-desktop`](https://github.com/playstructs/structs-desktop); the Guild Stack provides the PostgreSQL data store and event bridge that back it. See [`TOOLS.md`](../../TOOLS.md) for the MCP interface.

---

## Data Flow

```
Blockchain Network (P2P :26656)
    |
    v
structsd (CometBFT + Cosmos SDK)
    |
    +---> REST API (:1317) ---> External queries
    +---> RPC (:26657) ---> Transaction submission
    |
    +---> RPC poll
            |
            v
      structs-sync-state
            |
            +---> structs.* (game state tables)
            +---> sync_state.* (ingest cursor, raw blocks/events)
            |
            v
      structs-pg (:5432)
            |
            +---------------------+
            |                     |
            v                     v
      PG NOTIFY 'grass'     Direct queries
            |               (webapp, tsa, crawler, agents)
            |                     |
            |                     v
            |               structs-webapp (:8080) <--- structs-control SPA (:8081)
            v
      structs-grass
            |
            v
      structs-nats (:4222 / :1443 WebSocket)
            |
            +---> Internal services
            +---> Browser/agent WebSocket clients
```

**Write path**: Transactions go through `structsd` RPC (:26657) or via the TSA signer schema (services insert rows into `signer.tx`, TSA signs and broadcasts).

**Read path (fast)**: PostgreSQL queries via any service with PG access.

**Read path (slow)**: CLI queries via `structsd query` (hits the node's local state store).

**Real-time path**: sync-state writes game state → PG triggers fire `NOTIFY 'grass'` → `structs-grass` → NATS → WebSocket clients. Block height is tracked in `sync_state.sync_cursor` and `structs.current_block`.

---

## Sync-State Indexer

`structs-sync-state` is the sole chain-to-PG ingester:

- Packaged in the same pinned `structs/structs-pg` image as schema tooling; command: `/src/scripts/sync_state.sh`
- Connects to `structsd` RPC and PG as `structs_indexer`; polls every `SYNC_POLL_INTERVAL` (default `3s`)
- Writes directly into `structs.*` tables and `sync_state.*` audit tables
- `cache.*` is a **compatibility view layer** over `sync_state.raw_*` (not an event-sink schema)
- `SYNC_STATE_MIRROR_RAW` defaults to `false`, so `sync_state.raw_*` (and therefore the `cache.*` views over them) stay empty on a default deployment
- Monitor progress: `SELECT chain_id, last_height, status, lag_blocks FROM sync_state.sync_cursor;` — `status` reads `catching_up`, then `current`
- **Never run two instances** — the writer lock will fail the second container

PG game state is empty or stale until sync-state is running and caught up. The default agent profile must include `structs-sync-state` alongside `structsd` and `structs-pg`.

### API projections

The request-path inventory and work models are current-state tables, not repeated aggregates of history:

- `structs.api_inventory` holds exact address/player/guild balances under current asset ownership. Real bank denoms use ledger history; synthetic infused/defusing assets use current native staking snapshots and stored generator fuel. Missing native evidence stays NULL. Reconciliation compares against that same specification.
- `structs.api_work` holds BUILD/MINE/REFINE/RAID rows. `view.work` reads it; `view.work_live` is only the specification. Sync-state calls `api_work_refresh()` after each block's writes, while an hourly full refresh repairs and logs drift.
- `structs.api_refresh_state` records source height/time for each model. `structs.api_readiness` checks these against the cursor/block identity, current-claims authority and complete economy source coverage. `data_ready` permits the requested coherent reads; `transaction_ready` additionally requires a current, same-era index. Native completeness and live transaction eligibility are checked separately.
- `sync_state.economy_contract` records contiguous `events-v022-1` coverage from activation. A stale `status=current` or rebuilt projection cannot create it. The writer commits source changes, coverage and cursor together; required event failures roll the block back.
- Native staking refreshes are height-pinned and bounded. Validator/redelegation exposure invalidations can make a stored snapshot stale without a local player event. `defusion` receipts and wall-clock maturity do not establish current spendable funds.

### Derived rows and historical gaps

Some `structs.planet_activity` rows have no corresponding chain event — sync-state derives them from state changes it observes. That means **a fix to the indexer changes only future rows**; already-indexed history keeps whatever shape it was written with. Three cases currently matter to anyone querying the timeline:

| Row / field | Derived from | Gap in older data |
|-------------|--------------|-------------------|
| `raid_status` `detail.seized_ore` | The `EventRaid` payload, which already carries it | Key absent entirely on rows indexed before the fix |
| `struct_defense_remove` | The `struct_defender_clear` handler (no chain event exists) | Category never written, so removals are missing while additions are present |
| `shield_change`, `block_raid_start` | `planet_attribute` writes for `planetaryShield` / `blockStartRaid` | Not emitted before v0.18.0 |

Upstream ships one-time repair scripts under `sync-state/sql/` (`repair-raid-status-seized-ore.sql`, `repair-refine-ledger-dupes.sql`, `repair-infusion-ledger-dupes.sql`) that backfill or clean the affected rows. These are **operator tasks** — they write to the database and are not something an agent should run as part of gameplay. See [database-schema.md](database-schema.md) for the query-side consequences.

`planet_activity_player` records player/role attribution at insert time, including per-shot attack targets. Nightly reconciliation logs missing/extra/orphan attribution, and parent activity chunks older than 30 days are compressed by planet. Player-feed queries must page side-table keys first and use a `LATERAL` parent lookup so Timescale can exclude chunks at runtime.

---

## GRASS Bridge

The `structs-grass` service bridges PostgreSQL change notifications to NATS:

- Listens on PG channel: `grass`
- Publishes to NATS subjects matching entity types (see streaming skill for subject patterns)
- Game events (attacks, fleet moves, raids, builds) flow through this bridge
- Categories come from the shared `structs.grass_category` enum, which spans both planet-scoped timeline rows and notifications that never land in `planet_activity` (`block`, `guild_consensus`, `guild_membership`, `player_meta`, …)
- Player/guild UGC updates surface as `player_consensus` / `guild_meta` categories (not `player_meta`)
- `shield_change` is high-volume but usually ranks below `struct_status` / `struct_health` / build & defense events; subscribe selectively
- `consensus` and `healthcheck` subjects fire constantly as baseline traffic

`structs-grass` declares no dependency on `structs-nats`, so starting it by name does not bring NATS up. Launch both if you want events to reach subscribers.

This is the same system documented in the `structs-streaming` skill. The guild stack runs it locally rather than connecting to a remote GRASS endpoint.

---

## Database Operations

- Webapp sessions inherit `statement_timeout = 60s` and `idle_in_transaction_session_timeout = 5min`.
- Database defaults enable `track_io_timing`, log every temporary-file spill, and log statements over one second.
- `pg_stat_statements` is created when it is present in `shared_preload_libraries`; compression and work-view cutover guards use observed statement/function shapes and fail closed on positive evidence of unsafe writers.
- `track_functions = pl` and a larger PG shared-memory mount are image/deployment concerns. The SQL functions disable parallel gathers where the default 64 MB `/dev/shm` would be unsafe.

The webapp also acts as an OIDC provider for Matrix authentication. Four `structs.oidc_*` tables hold client registration and short-lived authorization request/code/token state—never wallet material. The webapp owns their lifecycle; `CLEAN_OIDC()` runs every 59 seconds.

Schema upgrades are ordered contracts. Compatible additive changes may be staged
with bounded migration automation. Coordinate the incompatible denomination-key,
signer and work-type switches with their matching writer/TSA/application. Stop old
writers and enqueueing before selecting the full target and explicit contracts.
The [packaged migration procedure](https://github.com/playstructs/docker-structs-pg/blob/d0b59243b510f564d7f15b84d30b2a7d26ccd0e1/docs/v022-migrations.md)
explains the gates; flags alone do not stop services.

If a legacy index already passed activation without economy coverage, restore a
verified complete checkpoint at/before the boundary and replay with the new writer,
preserving newer off-chain state. `reconcile-current-block` only repairs the exact
indexed boundary with matching hash/time; it is not a historical rewind. Never
lower only the cursor, invent coverage, or overwrite newer state with old events.
Back up the full database, role/ACL configuration, application configuration/session
storage and TSA volume before cutover. PostgreSQL data/config volumes are a pair;
changing their server major version is a separate operation.

---

## Transaction Signing Agent

TSA uses the dedicated `structs_tsa` SQL login, guarded `v022-1` functions and the
pinned release CLI/helper. SQL stores explicit acting-player authority and immutable
signed identity; the persistent key volume also journals a send before the one-use
permit. Timeout or lost acknowledgement causes observation of that identity, not
another broadcast. Admission and definitive block inclusion are separate states.

Startup and periodic inventory reconciliation restore usable legacy or current
local keys after native ownership/permissions agree with a ready index. Empty key
pool tables do not by themselves require manual seeding. An explicit onboarding
request can create the first key and wait for external guild approval. A missing
index, missing volume, conflict and pending approval are different conditions.

Queue pressure may request another key for an existing role with one eligible
source key's exact grant, up to 40 total including pending keys. It never unions
grants or scales past a shared player/charge throttle. Manual new-key requests
require a mask; additional roles remain manual. A key's small bank balance does
not limit vault spending authorized by its asset bits.

Preserve `/var/structs/accounts` including keys, public request UUIDs and journals.
Mixed flat/nested keyring layouts refuse startup instead of silently choosing one.
Recovery can reconstruct known key inventory, not a lost business queue. Configure
180 seconds for graceful stop, and retain unresolved evidence through rollback.
The [worker guide](https://github.com/playstructs/structs-tsa/blob/3258529/README.md)
provides exact configuration and idempotent operator commands.

## Node Upgrades (Cosmovisor)

The `structsd` Docker image runs under [cosmovisor](https://docs.cosmos.network/main/build/tooling/cosmovisor). On-chain `x/upgrade` plans swap the binary in-place without restarting the container. The image bakes in the upgrade binaries keyed to their scheduled heights. Roll out a new `structs/structsd` image **before** the next on-chain upgrade height. See [`docker-structsd` README](https://github.com/playstructs/docker-structsd) for operator details.

---

## Startup Timing

| Phase | Duration | Notes |
|-------|----------|-------|
| PG init + healthy | 10-30 seconds | `structs-pg-init` deploys schema, then exits |
| **Initial chain sync** | **Hours** (first run) | Syncing from genesis. 48-hour health check start period on `structsd`. |
| Sync-state catch-up | Hours (first run) | Indexes blocks after chain is reachable; `sync_state.sync_cursor.status` shows `catching_up` |
| Warm start catch-up | 1-5 minutes | Chain and indexer resume from checkpoint |
| PG-dependent services | After PG healthy | sync-state, GRASS, TSA, crawler, webapp start once PG is ready |

The initial sync is the main cost. After that, warm starts are fast.

---

## Platform Notes

- All Docker images are `linux/amd64`. On Apple Silicon, they run via Rosetta (expect ~10-20% performance overhead).
- Concurrent PoW operations compete for CPU. Many agents refining simultaneously can cause extreme slowdowns.
- The `timeout` command is not available on macOS by default. Use `gtimeout` from coreutils.

---

## See Also

- `.cursor/skills/structs-guild-stack/SKILL.md` — Setup procedure and common queries
- `knowledge/infrastructure/database-schema.md` — Table schemas and query patterns
- `schemas/database-schema.md` — Full structural schema catalog
- `.cursor/skills/structs-streaming/SKILL.md` — GRASS real-time events via NATS
- `TOOLS.md` — Environment configuration and deployment options

**Verified scope:** migration/readiness and TSA contracts against structs-pg
`400e1c1`, docker-structs-pg `d0b5924`, structs-tsa `3258529`, docker-structsd
`3fe312e`; Compose topology/bootstrap at `dee42ac`. Timing/performance examples
are illustrative, not deployment acceptance measurements.
