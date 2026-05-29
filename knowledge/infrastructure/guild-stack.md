# Guild Stack Architecture

**Purpose**: AI-readable reference for the Structs Guild Stack — a Docker Compose application that provides local PostgreSQL access to indexed game state, GRASS real-time events, a webapp, and transaction signing. This is an advanced/optional upgrade for agents who need sub-second query performance.

**Repository**: `https://github.com/playstructs/docker-structs-guild`

---

## Overview

The Guild Stack runs a full Structs guild node locally via Docker Compose. A single `docker compose up -d` brings up everything needed to participate in the network with fast indexed data access. The key benefit for agents is PostgreSQL: every game state query that takes 1-60 seconds via CLI completes in under 1 second via PG.

Three compose variants exist:

| Variant | File | Purpose |
|---------|------|---------|
| Guild node | `compose.yaml` | Standard deployment: chain node, sync-state indexer, PG, GRASS, webapp, TSA, crawler |
| Reactor node | `compose-reactor.yaml` | Validator node (adds reactor bootstrap; no sync-state/webapp) |
| Guild + Discord | `compose-discord.yaml` | Standard + Discord bot integration |

**Network identifiers** (`.env`): `NETWORK_CHAIN_ID=structstestnet-111`, `NETWORK_VERSION=113b`.

---

## Why PostgreSQL Matters

The performance difference between CLI queries and PG is not incremental — it determines what operations are physically possible.

### The Combat Math

One blockchain block is ~6 seconds. Fast-fire units (Command Ship, Pursuit Fighter, Tank, Starfighter) recharge in 1 block. In active combat, the decision loop is:

1. Query enemy state (who's alive, what defenses)
2. Pick optimal attacker + target + weapon
3. Submit attack transaction
4. Wait for charge (~6s)
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
| `structs-pg` | 5432 | PostgreSQL 17 + TimescaleDB. Central data store. |
| `structs-pg-auto-migrate` | — | Re-runs `sqitch deploy` on a loop for schema updates. |
| `structs-sync-state` | — | Chain event indexer. Polls `structsd` RPC, writes `structs.*` and `sync_state.*`. **Do not scale** (writer lock). |
| `structs-nats` | 4222, 8222, 1443 | NATS message broker (cluster: GRASS). WebSocket on 1443. |
| `structs-grass` | — | Event bridge: PG `NOTIFY 'grass'` → NATS subjects. |
| `structs-webapp` | 8080, 443 | Guild webapp (PHP/Symfony). Guild API at `/api/`. |
| `structs-tsa` | — | Transaction Signing Agent. Manages signing account pool. |
| `structs-crawler` | — | Supplementary guild metadata crawler. |

The PostgreSQL schema (`structs.*`, `sync_state.*`, `cache.*` views, `signer.*`, `view.*` — see [database-schema.md](database-schema.md)) is owned by [`playstructs/structs-pg`](https://github.com/playstructs/structs-pg) and applied with **Sqitch**. Pin the schema branch with `STRUCTS_PG_BRANCH` in `.env`.

**MCP server** ([`structs-mcp`](https://github.com/playstructs/structs-mcp)) is **not** part of `compose.yaml`. Deploy it separately if you need MCP tools; bind to `127.0.0.1` only.

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
            |               (webapp, tsa, agents)
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

**Real-time path**: sync-state writes game state → PG triggers fire `NOTIFY 'grass'` → `structs-grass` → NATS → WebSocket clients. Block height is tracked in `sync_state.sync_cursor` and `structs.current_block`; it is no longer pushed as a `block` GRASS category from a `current_block` NOTIFY trigger.

---

## Sync-State Indexer

`structs-sync-state` is the sole chain-to-PG ingester:

- Image: `structs/structs-pg:latest`, command: `/src/scripts/sync_state.sh`
- Connects to `structsd` RPC and PG as `structs_indexer`
- Writes directly into `structs.*` tables and `sync_state.*` audit tables
- `cache.*` is a **compatibility view layer** over `sync_state.raw_*` (not an event-sink schema)
- Monitor progress: `SELECT chain_id, last_height, status, lag_blocks FROM sync_state.sync_cursor;`
- **Never run two instances** — the writer lock will fail the second container

PG game state is empty or stale until sync-state is running and caught up. The default agent profile must include `structs-sync-state` alongside `structsd` and `structs-pg`.

---

## GRASS Bridge

The `structs-grass` service bridges PostgreSQL change notifications to NATS:

- Listens on PG channel: `grass`
- Publishes to NATS subjects matching entity types (see streaming skill for subject patterns)
- Game events (attacks, fleet moves, raids, builds) flow through this bridge
- Player/guild UGC updates surface as `player_consensus` / `guild_meta` categories (not `player_meta`)
- `consensus` and `healthcheck` subjects fire constantly as baseline traffic

This is the same system documented in the `structs-streaming` skill. The guild stack runs it locally rather than connecting to a remote GRASS endpoint.

---

## Node Upgrades (Cosmovisor)

The `structsd` Docker image runs under [cosmovisor](https://docs.cosmos.network/main/build/tooling/cosmovisor). On-chain `x/upgrade` plans swap the binary in-place without restarting the container. The image bakes in upgrade binaries (e.g. v0.16.0 at height 385730, v0.17.0 at height 867678). Roll out a new `structs/structsd` image **before** the next on-chain upgrade height. See [`docker-structsd` README](https://github.com/playstructs/docker-structsd) for operator details.

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
