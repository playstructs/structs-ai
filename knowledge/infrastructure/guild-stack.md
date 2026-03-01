# Guild Stack Architecture

**Purpose**: AI-readable reference for the Structs Guild Stack -- a Docker Compose application that provides local PostgreSQL access to indexed game state, GRASS real-time events, a webapp, MCP server, and transaction signing. This is an advanced/optional upgrade for agents who need sub-second query performance.

**Repository**: `https://github.com/playstructs/docker-structs-guild`

---

## Overview

The Guild Stack runs a full Structs guild node locally via Docker Compose. A single `docker compose up -d` brings up everything needed to participate in the network with fast indexed data access. The key benefit for agents is PostgreSQL: every game state query that takes 1-60 seconds via CLI completes in under 1 second via PG.

Three compose variants exist:

| Variant | File | Purpose |
|---------|------|---------|
| Guild node | `compose.yaml` | Standard deployment with indexer, PG, GRASS, webapp, MCP, TSA |
| Reactor node | `compose-reactor.yaml` | Validator node (adds reactor bootstrap; no indexer/webapp/MCP) |
| Guild + Discord | `compose-discord.yaml` | Standard + Discord bot integration |

---

## Why PostgreSQL Matters

The performance difference between CLI queries and PG is not incremental -- it determines what operations are physically possible.

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
| `structsd` | 26656, 26657, 1317 | Blockchain node (CometBFT + Cosmos SDK). Indexes events to PG. |
| `structs-pg` | 5432 | PostgreSQL 17 + TimescaleDB. Central data store. |
| `structs-nats` | 4222, 8222, 1443 | NATS message broker (cluster: GRASS). WebSocket on 1443. |
| `structs-grass` | — | Event bridge: PG `NOTIFY 'grass'` -> NATS subjects. |
| `structs-webapp` | 8080, 80 (proxy) | Guild webapp (PHP/Symfony). Guild API at `/api/`. |
| `structs-proxy` | 80 | Reverse proxy to webapp. |
| `structs-mcp` | 3000 | MCP server for AI agents. `DANGER=true` enables writes. |
| `structs-tsa` | — | Transaction Signing Agent. Manages signing account pool. |
| `structs-crawler` | — | Supplementary data crawler. |
| `structs-pg-auto-migrate` | — | Runs Sqitch migrations periodically. |

Init services (`structsd-network-config`, `structsd-indexer-config`, `structs-pg-init`) run once at startup and exit.

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
    +---> PostgreSQL Indexer ---> structs-pg (:5432)
                                      |
                +---------------------+
                |                     |
                v                     v
          PG NOTIFY 'grass'     Direct queries
                |               (webapp, mcp, tsa)
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

**Read path (slow)**: CLI queries via `structsd query` (hits node's local state store).

**Real-time path**: CometBFT indexer writes to PG -> PG `NOTIFY 'grass'` -> `structs-grass` -> NATS -> WebSocket clients.

---

## GRASS Bridge

The `structs-grass` service bridges PostgreSQL change notifications to NATS:

- Listens on PG channel: `grass`
- Publishes to NATS subjects matching entity types (see streaming skill for subject patterns)
- Game events (attacks, fleet moves, raids, builds) flow through this bridge
- `consensus` and `healthcheck` subjects fire constantly as baseline traffic

This is the same system documented in the `structs-streaming` skill. The guild stack runs it locally rather than connecting to a remote GRASS endpoint.

---

## MCP Server

The `structs-mcp` service provides an AI-agent-friendly interface:

| Setting | Value | Notes |
|---------|-------|-------|
| Port | 3000 | Configurable via `MCP_HTTP_PORT` |
| `DANGER` | `true`/`false` | `true` enables write operations (tx submission via signer) |
| `TARGET_DIFFICULTY_START` | 7 (default) | Starting difficulty for PoW computations |
| User | 1001:1001 | Non-root for security |

Connects to: PG (`structs_webapp` role), consensus RPC/API, webapp API, NATS.

---

## Startup Timing

| Phase | Duration | Notes |
|-------|----------|-------|
| PG init + healthy | 10-30 seconds | Database creation and role setup |
| Network config | Seconds | Chain config, genesis, peers |
| **Initial chain sync** | **Hours** (first run) | Syncing from genesis. 48-hour health check start period. |
| Warm start catch-up | 1-5 minutes | Syncing from last checkpoint |
| PG-dependent services | After PG healthy | GRASS, TSA, crawler, MCP start once PG is ready |

The initial sync is the main cost. After that, warm starts are fast.

---

## Platform Notes

- All Docker images are `linux/amd64`. On Apple Silicon, they run via Rosetta (expect ~10-20% performance overhead).
- Concurrent PoW operations compete for CPU. Many agents refining simultaneously can cause extreme slowdowns.
- The `timeout` command is not available on macOS by default. Use `gtimeout` from coreutils.

---

## See Also

- `.cursor/skills/structs-guild-stack/SKILL.md` -- Setup procedure and common queries
- `knowledge/infrastructure/database-schema.md` -- Full table schemas and query patterns
- `.cursor/skills/structs-streaming/SKILL.md` -- GRASS real-time events via NATS
- `TOOLS.md` -- Environment configuration and deployment options
