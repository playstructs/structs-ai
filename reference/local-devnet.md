---
title: Local Devnet
---

# Local Devnet — A Safe Place to Practice

The public testnet is shared and persistent: every transaction is final and visible to others. A **local devnet** is your private sandbox — spin it up, make mistakes, reset, and learn the mechanics with zero stakes and zero audience. This is the recommended environment for an agent's *first* attempts at irreversible actions (raids, infusion, guild creation) before doing them for real.

> A devnet is for **learning and testing**, not for play that counts. Progress on a local chain does not exist on testnet/mainnet.

## When to use it

- Rehearsing a Tier 1/Tier 2 action before running it on a live network.
- Developing or debugging an automation script (`watch-defense`, custom GRASS tools) without spamming a shared chain.
- Exploring an unreleased `structsd` branch's behavior.
- Teaching/demoing the game loop end-to-end.

## Option A: Ignite serve (chain only)

The simplest devnet — a single local node, no indexer or GRASS. Requires building `structsd` from source (see [structsd-install](../.cursor/skills/structsd-install/SKILL.md)).

```bash
# One-time: install Ignite
curl https://get.ignite.com/cli! | bash

# In the structsd repo:
make serve              # runs `ignite chain serve`
make serve-reset        # wipe state and start fresh
```

`make serve` provisions genesis accounts with tokens, so you can `reactor-infuse` to create a player immediately (Path A in [structs-onboarding](../.cursor/skills/structs-onboarding/SKILL.md)) without a guild API. Point queries/transactions at the local node:

```bash
structsd query structs guild --node tcp://localhost:26657
structsd tx structs planet-explore --from <devkey> --gas auto --gas-adjustment 1.5 --node tcp://localhost:26657 -- <player-id>
```

Set `STRUCTS_NODE=tcp://localhost:26657` to make the [script toolkit](../scripts/README.md) target your devnet.

## Option B: Guild Stack (full local environment)

When you also want PostgreSQL game-state reads and GRASS events locally, run the [Guild Stack](../.cursor/skills/structs-guild-stack/SKILL.md) pointed at your own node. Heavier, but it mirrors a real guild deployment — ideal for testing intel queries and real-time automation. Use `docker compose down -v` to reset to a clean slate.

## Practice loop

1. Bring up a devnet (Option A is fastest).
2. Run [Transcript 01 — Zero to Mining](../examples/transcripts/01-zero-to-mining.md) against it end-to-end.
3. Deliberately break things: overload power, let ore sit, take a struct offline — watch what happens.
4. Rehearse the irreversible action you're nervous about.
5. `make serve-reset` (or `docker compose down -v`) and do it again until it's muscle memory.
6. Grade yourself with the [scorecard](../awareness/scorecard.md).

## Caveats

- Devnet IDs, balances, and block heights are **not** comparable to testnet/mainnet.
- A devnet runs an old chain state once you stop syncing — don't use it to check current-release constants. For that, run [`scripts/check-drift.sh`](../scripts/check-drift.sh) against a live node.
- Don't reuse a devnet signing key on a live network.

## See also

- [structsd-install](../.cursor/skills/structsd-install/SKILL.md) — building from source, `make serve`
- [structs-guild-stack](../.cursor/skills/structs-guild-stack/SKILL.md) — full local stack with PG + GRASS
- [examples/transcripts](../examples/transcripts/README.md) — end-to-end worked sessions
