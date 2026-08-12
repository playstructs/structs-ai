---
title: Building a Structs client
description: "How a real Structs client is assembled: REST for bulk reads, GRASS for live deltas, RPC for writes, and what surprises people."
permalink: /develop/client/
---

# Building a Structs client

**Purpose**: How a real Structs client is put together — the three channels it talks
over, and what each one is responsible for.

These pages describe [structs-webapp](../repos.md), the flagship client, as a **reference
implementation**. It is not the only valid architecture, but it is the one the game is
actually played through, and every mechanic here is verified against its source rather
than inferred from the chain's API surface.

If you are building a UI rather than a client, start at [develop/ui/](../ui/index.md).

---

## Three channels, three jobs

A Structs client is not a single API client. It talks to the game over three separate
channels, and getting the division of labour right is most of the architecture.

| Channel | Carries | Latency | Authority |
|---|---|---|---|
| **REST** — Guild API over PostgreSQL | Bulk reads, search, history, bootstrap | ~100ms | Authoritative but a moment stale |
| **NATS/WebSocket** — [GRASS](realtime-grass.md) | Live deltas: block height, ore, power, combat | Sub-second | Fastest, but no replay |
| **Cosmos RPC** — [signing](actions-and-signing.md) | Writes only | ~6s per block | The only way to change anything |

The rule that falls out of this: **read from REST on load, keep current with GRASS, write
over RPC, and never assume a write you sent is a write that landed.**

GRASS has no replay buffer. Messages that arrive while you are disconnected are gone. Any
client that treats the event stream as its source of truth will silently drift; the
webapp re-fetches authoritative state from REST at login and after significant events,
using GRASS only to stay current in between.

---

## The subsystems

| Page | Covers |
|---|---|
| [state-and-data.md](state-and-data.md) | GameState, factories, the string-number trap, the REST client, the event bus |
| [actions-and-signing.md](actions-and-signing.md) | Wallet, protobuf registry, the dual-lane signing queue, charge gating |
| [work-and-pow.md](work-and-pow.md) | Proof-of-work: hash format, difficulty decay, workers, completion |
| [realtime-grass.md](realtime-grass.md) | NATS connection, the listener contract, all 26 listeners |
| [rendering-entities.md](rendering-entities.md) | PFP layer compositing, struct art, Lottie lifecycle, the animation queue |
| [map.md](map.md) | The ambit stack, tiles, fog of war, picture-in-picture |
| [desktop-extensions.md](desktop-extensions.md) | Extending Structs Desktop: MCP tools, board pages, serving SUI over HTTP |

For the framework the webapp wraps around all of this — its MVVM layer, router, and view
model conventions — see [develop/frontend-architecture.md](../frontend-architecture.md).

---

## Four things that surprise people

**Charge is a rate limit, not a resource.** It accrues as blocks elapse since your last
charged action, and it gates *when* you can act rather than what you can afford. The
client computes it locally as `currentBlock - (lastActionBlock + 1)` and holds
transactions until the projected charge covers the action's cost. Get this wrong and your
transactions fail on-chain rather than queueing politely.

**One transaction per block per account.** Not a chain rule but a practical one: the
webapp serialises broadcasts behind an in-flight mutex and a per-block governor
specifically to avoid `account sequence mismatch`. It never tracks sequence numbers
manually — it just never has two in flight.

**Proof-of-work gets cheaper if you wait.** Difficulty decays logarithmically with the
age of the on-chain anchor. Initiating early and completing later is strictly better than
hashing hard immediately. The webapp's worker will sit idle for hours rather than burn
CPU at high difficulty.

**Numbers arrive as strings, and the reference client is inconsistent about converting
them.** This is the single most likely source of a subtle bug in a new client. See
[state-and-data.md](state-and-data.md#numbers-arrive-as-strings).

---

*Verified against structs-webapp `6eec7f7` (2026-07-21).*
