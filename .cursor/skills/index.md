---
title: "Skills: procedures for playing"
description: Decision-first, CLI-grounded procedures for playing Structs. Each skill states when to use it, what it decides, and the exact commands to run.
permalink: /skills/
redirect_from:
  - /.cursor/skills
  - /.cursor/skills/
---

# Skills: procedures for playing

Decision-first, CLI-grounded procedures for playing Structs. Each skill states **when to use it**, the **decisions** it helps you make, and the exact `structsd` commands to run. Shared boilerplate (transaction flags, the `--` ID rule, the per-player charge bar, proof-of-work policy) lives once in [conventions](/skills/conventions.html).

Start with [play-structs](/skills/play-structs/SKILL.html) — it takes you from zero to mining and links everything below.

Skills are the doing layer. They assume you have already decided *that* you should mine, raid, or infuse; they will not argue you out of a bad war. For that argument see [play](../play/) and [playbooks](../playbooks/). Canonical numbers live in [knowledge](../knowledge/) and [reference](../reference/).

Edit the copies under `.cursor/skills/` — [`skills/`](/skills/) is a generated mirror for GitHub Pages and OpenClaw discovery.

## Core loop

The skills you use every session. Master these first.

| Skill | Level | What It Does |
|-------|-------|--------------|
| [play-structs](/skills/play-structs/SKILL.html) | entry | The on-ramp: install → guild → player → first mine |
| [structs-onboarding](/skills/structs-onboarding/SKILL.html) | entry | Key setup, player creation, planet claim, first builds |
| [structs-production](/skills/structs-production/SKILL.html) | core | Mine → refine → stake pipeline; ore vulnerability, depletion handoff |
| [structs-building](/skills/structs-building/SKILL.html) | core | Build any struct, defense placement, stealth, generator infusion |
| [structs-planets-fleet](/skills/structs-planets-fleet/SKILL.html) | core | Planet evaluation, exploration, fleet movement, evacuation |
| [structs-energy](/skills/structs-energy/SKILL.html) | core | Capacity management, offline recovery, substations, infusion |
| [structs-combat](/skills/structs-combat/SKILL.html) | core | Attacks, raids (shield-vulnerability doctrine), defense |

## Economy & social

| Skill | Level | What It Does |
|-------|-------|--------------|
| [structs-commerce](/skills/structs-commerce/SKILL.html) | core | Providers, agreements, reactor staking, guild Central Bank, transfers |
| [structs-guild](/skills/structs-guild/SKILL.html) | core | Choosing/joining a guild, ranks, membership, UGC moderation, banking |
| [structs-permissions](/skills/structs-permissions/SKILL.html) | advanced | Permissions, multi-address management, delegate agents |
| [structs-intel](/skills/structs-intel/SKILL.html) | advanced | Scouting players/planets/guilds; persisting intel to memory |

## Advanced infrastructure

| Skill | Level | What It Does |
|-------|-------|--------------|
| [structsd-install](/skills/structsd-install/SKILL.html) | entry | Install/update the `structsd` binary |
| [structs-streaming](/skills/structs-streaming/SKILL.html) | advanced | Real-time GRASS/NATS events for automation |
| [structs-ui](/skills/structs-ui/SKILL.html) | advanced | Building interfaces and clients: SUI design system, signing, proof-of-work, GRASS |
| [structs-guild-stack](/skills/structs-guild-stack/SKILL.html) | advanced | Local node + PostgreSQL for sub-second game-state reads |

## Tooling

Read-only helper scripts that turn multi-step queries into one-line decisions live in [`scripts/`](https://github.com/playstructs/structs-ai/tree/main/scripts) (`assess`, `power-budget`, `scout`, `job-status`, `watch-defense`, `check-drift`).
