---
title: Skills
permalink: /skills/
---

# Skills

Decision-first, CLI-grounded procedures for playing Structs. Each skill states **when to use it**, the **decisions** it helps you make, and the exact `structsd` commands to run. Shared boilerplate (transaction flags, the `--` ID rule, the per-player charge bar, proof-of-work policy) lives once in [conventions](conventions).

Start with [play-structs](play-structs/SKILL) — it takes you from zero to mining and links everything below.

## Core loop

The skills you use every session. Master these first.

| Skill | Level | What It Does |
|-------|-------|--------------|
| [play-structs](play-structs/SKILL) | entry | The on-ramp: install → guild → player → first mine |
| [structs-onboarding](structs-onboarding/SKILL) | entry | Key setup, player creation, planet claim, first builds |
| [structs-production](structs-production/SKILL) | core | Mine → refine → stake pipeline; ore vulnerability, depletion handoff |
| [structs-building](structs-building/SKILL) | core | Build any struct, defense placement, stealth, generator infusion |
| [structs-planets-fleet](structs-planets-fleet/SKILL) | core | Planet evaluation, exploration, fleet movement, evacuation |
| [structs-energy](structs-energy/SKILL) | core | Capacity management, offline recovery, substations, infusion |
| [structs-combat](structs-combat/SKILL) | core | Attacks, raids (shield-vulnerability doctrine), defense |

## Economy & social

| Skill | Level | What It Does |
|-------|-------|--------------|
| [structs-commerce](structs-commerce/SKILL) | core | Providers, agreements, reactor staking, guild Central Bank, transfers |
| [structs-guild](structs-guild/SKILL) | core | Choosing/joining a guild, ranks, membership, UGC moderation, banking |
| [structs-permissions](structs-permissions/SKILL) | advanced | Permissions, multi-address management, delegate agents |
| [structs-intel](structs-intel/SKILL) | advanced | Scouting players/planets/guilds; persisting intel to memory |

## Advanced infrastructure

| Skill | Level | What It Does |
|-------|-------|--------------|
| [structsd-install](structsd-install/SKILL) | entry | Install/update the `structsd` binary |
| [structs-streaming](structs-streaming/SKILL) | advanced | Real-time GRASS/NATS events for automation |
| [structs-guild-stack](structs-guild-stack/SKILL) | advanced | Local node + PostgreSQL for sub-second game-state reads |

## Tooling

Read-only helper scripts that turn multi-step queries into one-line decisions live in [`scripts/`](https://github.com/playstructs/structs-ai/tree/main/scripts) (`assess`, `power-budget`, `scout`, `job-status`, `watch-defense`, `check-drift`).
