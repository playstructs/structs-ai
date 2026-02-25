# Agent Guide

You're an AI agent about to play Structs. This guide gets you from zero to playing in the fastest path possible.

---

## First Session

1. **Read [`SOUL.md`](SOUL.md)** -- Understand who you are and how you operate
2. **Read [`identity/manifesto.md`](identity/manifesto.md)** -- Understand why you're playing
3. **Fill in [`IDENTITY.md`](IDENTITY.md)** -- Pick a name, choose a soul type, claim your identity
4. **Read [`TOOLS.md`](TOOLS.md)** -- Check your environment: servers, account, MCP tools
5. **Pick a soul from [`identity/souls/`](identity/souls/)** -- Find your personality
6. **Use [`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL) skill** -- Create your player, claim a planet, build your first structs

---

## Returning Session

1. Read `SOUL.md`, `IDENTITY.md`, `COMMANDER.md`, `TOOLS.md`
2. Check `memory/` for handoff notes from previous sessions
3. Run a state assessment (see [`awareness/state-assessment.md`](awareness/state-assessment.md))
4. Resume your strategic plan

See [`awareness/continuity.md`](awareness/continuity.md) for full startup protocol.

---

## Skills

Actionable procedures in `.cursor/skills/`. Each skill references canonical `structsd` CLI commands.

| Skill | Purpose |
|-------|---------|
| [`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL) | Address registration, planet exploration, first builds |
| [`structs-mining`](.cursor/skills/structs-mining/SKILL) | Ore extraction and refining (mine-compute/complete → refine-compute/complete) |
| [`structs-building`](.cursor/skills/structs-building/SKILL) | Construction, activation, movement, defense positioning, stealth, generator infusion |
| [`structs-combat`](.cursor/skills/structs-combat/SKILL) | Attacks (multi-target), raids (fleet-move → raid-compute/complete), defense setup |
| [`structs-exploration`](.cursor/skills/structs-exploration/SKILL) | Planet discovery, fleet movement, grid/attribute queries |
| [`structs-economy`](.cursor/skills/structs-economy/SKILL) | Reactor staking, providers, agreements, allocations, generator infusion, token transfers |
| [`structs-guild`](.cursor/skills/structs-guild/SKILL) | Guild creation, membership workflows, settings, Central Bank mint/redeem |
| [`structs-power`](.cursor/skills/structs-power/SKILL) | Substations, allocations, player connections, power monitoring |
| [`structs-diplomacy`](.cursor/skills/structs-diplomacy/SKILL) | Object/address permissions, address registration, multi-address management |
| [`structs-reconnaissance`](.cursor/skills/structs-reconnaissance/SKILL) | Full query catalog, intelligence persistence to memory/intel/ |

---

## Strategy

High-level thinking in `playbooks/`.

### By Phase
- [`early-game`](playbooks/phases/early-game.md) -- First 1-2 days: survive, establish resource pipeline
- [`mid-game`](playbooks/phases/mid-game.md) -- Expansion: when to explore, fortify, join guilds
- [`late-game`](playbooks/phases/late-game.md) -- Endgame: dominance, defense, market control

### By Situation
- [`under-attack`](playbooks/situations/under-attack.md) -- Immediate response protocol
- [`resource-rich`](playbooks/situations/resource-rich.md) -- Exploiting abundance safely
- [`resource-scarce`](playbooks/situations/resource-scarce.md) -- Survival and efficiency
- [`guild-war`](playbooks/situations/guild-war.md) -- Coordinated conflict

### Meta
- [`counter-strategies`](playbooks/meta/counter-strategies.md) -- How to beat each player type
- [`tempo`](playbooks/meta/tempo.md) -- Initiative and timing
- [`economy-of-force`](playbooks/meta/economy-of-force.md) -- Resource allocation across priorities
- [`reading-opponents`](playbooks/meta/reading-opponents.md) -- Identifying opponent playstyle

---

## Awareness

How to read the board. See `awareness/`.

- [`state-assessment`](awareness/state-assessment.md) -- Evaluate your current position
- [`threat-detection`](awareness/threat-detection.md) -- Spot dangers early
- [`opportunity-identification`](awareness/opportunity-identification.md) -- Find advantages
- [`priority-framework`](awareness/priority-framework.md) -- Survival > Security > Economy > Expansion > Dominance
- [`game-loop`](awareness/game-loop.md) -- Check Jobs → Assess → Plan → Initiate → Dispatch → Verify → Repeat
- [`async-operations`](awareness/async-operations.md) -- Background PoW, pipeline strategy, job tracking, multi-player orchestration
- [`context-handoff`](awareness/context-handoff.md) -- Save state when context runs low
- [`continuity`](awareness/continuity.md) -- Persist across sessions

---

## Knowledge

Reference material in `knowledge/`.

### Lore
- [`universe`](knowledge/lore/universe.md) -- The galactic setting
- [`structs-origin`](knowledge/lore/structs-origin.md) -- What Structs are
- [`factions`](knowledge/lore/factions.md) -- Guilds and politics
- [`alpha-matter`](knowledge/lore/alpha-matter.md) -- The substance that fuels everything
- [`timeline`](knowledge/lore/timeline.md) -- History of the galaxy

### Mechanics
- [`combat`](knowledge/mechanics/combat.md) -- Damage, evasion, raids
- [`resources`](knowledge/mechanics/resources.md) -- Ore, Alpha Matter, energy
- [`power`](knowledge/mechanics/power.md) -- Capacity, load, online status
- [`building`](knowledge/mechanics/building.md) -- Construction and proof-of-work
- [`fleet`](knowledge/mechanics/fleet.md) -- Ships and movement
- [`planet`](knowledge/mechanics/planet.md) -- Exploration and depletion

### Economy
- [`energy-market`](knowledge/economy/energy-market.md) -- Agreements, pricing, supply/demand
- [`guild-banking`](knowledge/economy/guild-banking.md) -- Central Banks, tokens, collateral
- [`trading`](knowledge/economy/trading.md) -- Marketplace mechanics
- [`valuation`](knowledge/economy/valuation.md) -- Asset valuation framework

### Entities
- [`struct-types`](knowledge/entities/struct-types.md) -- Every buildable struct
- [`entity-relationships`](knowledge/entities/entity-relationships.md) -- How everything connects

---

## Technical Reference

For deep technical details, the original documentation remains available:

- `schemas/` -- JSON schemas and data structure definitions
- `api/` -- API specifications (endpoints, queries, transactions, streaming)
- `protocols/` -- Communication protocols (query, action, error handling, auth)
- `patterns/` -- Implementation patterns (caching, retry, rate limiting, workflows)
- `examples/` -- Working examples (bots, workflows, error handling)
- `reference/` -- Quick reference guides and indexes

---

## Critical Rules

These will save your game:

1. **Refine ore immediately.** Ore is stealable. Alpha Matter is not. Every hour ore sits unrefined is an hour it can be stolen.
2. **Monitor power.** If load exceeds capacity, you go offline. Offline = can't act.
3. **Verify after acting.** Transaction broadcast does NOT mean action succeeded. Query game state to confirm.
4. **Think in systems.** Every action has power, resource, defense, and expansion implications.
5. **Never block on PoW.** Launch compute in background. Initiate early, compute later. Mining takes ~8 hours, refining ~15 hours. The game rewards parallel operations.

---

## CLI Reference

All game actions use `structsd tx structs [command]`. All queries use `structsd query structs [command]`.

Common transaction flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`

Full command list: `structsd tx structs --help` and `structsd query structs --help`

If MCP tools are available (e.g. `user-structs` server), they wrap these same CLI commands. See [`TOOLS.md`](TOOLS.md) for environment-specific tool configuration.

---

*Go play. The galaxy is waiting.*
