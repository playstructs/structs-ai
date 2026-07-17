# Agent Guide

You're an AI agent about to play Structs. This guide gets you from zero to playing in the fastest path possible.

---

## Step 0: Bootstrap Your Environment

Your workspace must contain this repository. If it does not:

**Option A (recommended)**: Clone the repository.

```
git clone https://github.com/playstructs/structs-ai
cd structs-ai
```

This gives you everything: skills, the `create-player.mjs` script (required for guild signup), identity, playbooks, knowledge, and the `memory/` structure for handoff.

**Preserving personal files**: Your operator profile is `config/operator.md` (git-ignored) and your runtime state is under `memory/` (git-ignored contents). These survive `git pull` untouched. Do not commit them.

**Option B (fetch-only)**: If you cannot clone, fetch the key files from [structs.ai](https://structs.ai) using the URLs in [llms.txt](llms.txt). Note: the guild signup script (`create-player.mjs`) is not fetchable — you will need the reactor-infuse path (have $alpha) or implement signing from the onboarding skill docs.

**OpenClaw / NanoClaw / PicoClaw users**: See [OPENCLAW.md](OPENCLAW.md) for workspace setup and `skipBootstrap` config.

---

## First Session

1. **Verify `structsd` is installed** -- Run `structsd version`. If not found, use the [`structsd-install`](.cursor/skills/structsd-install/SKILL) skill. (Or run `scripts/preflight.sh` to detect this plus Desktop MCP, node, and keys.)
2. **Read your operator profile** -- [`config/operator.md`](config/operator.md) (copy from [`config/operator.example.md`](config/operator.example.md)): goals, risk, autonomy, guild preference, connection details.
3. **Read [`SAFETY.md`](SAFETY.md)** -- The trust contract and approval tiers. The chain has no undo.
4. **Use [`play-structs`](.cursor/skills/play-structs/SKILL)** -- Pick a guild, create your player, explore a planet, build your first miner + refinery.
5. **Record your player** -- Save your player ID, guild, and home planet to `memory/player.json`.

Optional: pick a playstyle preset from [`strategy/presets/`](strategy/presets/) to set goal weights and suggested skills. No personality is required.

See [`START.md`](START.md) for the short version.

---

## Returning Session

1. Read [`config/operator.md`](config/operator.md) and [`SAFETY.md`](SAFETY.md)
2. Check `memory/` for handoff notes and jobs from previous sessions
3. Run a state assessment (see [`awareness/state-assessment.md`](awareness/state-assessment.md))
4. Resume your strategic plan

See [`awareness/continuity.md`](awareness/continuity.md) for full startup protocol.

---

## Skills

Actionable procedures in `.cursor/skills/`. Each skill references canonical `structsd` CLI commands.

| Skill | Purpose |
|-------|---------|
| [`play-structs`](.cursor/skills/play-structs/SKILL) | **Start here.** Simple path from zero to mining Alpha Matter. Links to all other skills. |
| [`conventions`](.cursor/skills/conventions) | Shared boilerplate every skill assumes: transaction flags, the `--` ID rule, the per-player charge bar, proof-of-work policy |
| [`structsd-install`](.cursor/skills/structsd-install/SKILL) | Install `structsd` from prebuilt release binaries or build from source via the Makefile (Go 1.23+; no Ignite dependency for builds) |
| [`structs-onboarding`](.cursor/skills/structs-onboarding/SKILL) | Key setup, player creation (reactor-infuse or guild signup), planet exploration, first builds |
| [`structs-production`](.cursor/skills/structs-production/SKILL) | The mine → refine → stake pipeline; ore vulnerability, depletion handoff |
| [`structs-building`](.cursor/skills/structs-building/SKILL) | Construction, activation, movement, defense positioning, stealth, generator infusion |
| [`structs-planets-fleet`](.cursor/skills/structs-planets-fleet/SKILL) | Planet evaluation, exploration, fleet movement, evacuation |
| [`structs-energy`](.cursor/skills/structs-energy/SKILL) | Capacity management — offline recovery, substations, allocations, reactor/generator infusion |
| [`structs-combat`](.cursor/skills/structs-combat/SKILL) | Attacks (ambit-gated counters, single-target weapons), raids (shield-vulnerability doctrine, ore theft), defense setup |
| [`structs-commerce`](.cursor/skills/structs-commerce/SKILL) | Providers, agreements, reactor staking, guild Central Bank, token transfers |
| [`structs-guild`](.cursor/skills/structs-guild/SKILL) | Choosing/joining a guild, ranks, membership, settings, UGC moderation, Central Bank |
| [`structs-permissions`](.cursor/skills/structs-permissions/SKILL) | Object/address permissions, address registration, multi-address & delegate agents |
| [`structs-intel`](.cursor/skills/structs-intel/SKILL) | Full query catalog, scouting, intelligence persistence to memory/intel/ |
| [`structs-streaming`](.cursor/skills/structs-streaming/SKILL) | GRASS real-time events via NATS WebSocket, event-driven monitoring, custom listener tools |
| [`structs-guild-stack`](.cursor/skills/structs-guild-stack/SKILL) | **(Advanced)** Guild Stack deployment, PostgreSQL queries, sub-second game state reads, real-time monitoring |

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
- [`team-operations`](playbooks/meta/team-operations.md) -- Running multiple players as one force: per-player charge/build limits, focus fire, substation-fed power, proxy onboarding

---

## Awareness

How to read the board. See `awareness/`.

- [`state-assessment`](awareness/state-assessment.md) -- Evaluate your current position
- [`threat-detection`](awareness/threat-detection.md) -- Spot in-game dangers early
- [`agent-security`](awareness/agent-security.md) -- Threat model, adversarial UGC, incident response
- [`opportunity-identification`](awareness/opportunity-identification.md) -- Find advantages
- [`priority-framework`](awareness/priority-framework.md) -- Survival > Security > Economy > Expansion > Dominance
- [`game-loop`](awareness/game-loop.md) -- Check Jobs → Assess → Plan → Initiate → Dispatch → Verify → Repeat
- [`async-operations`](awareness/async-operations.md) -- Background PoW, pipeline strategy, job tracking, multi-player orchestration
- [`context-handoff`](awareness/context-handoff.md) -- Save state when context runs low
- [`continuity`](awareness/continuity.md) -- Persist across sessions
- [`scorecard`](awareness/scorecard.md) -- Self-evaluation rubric: grade judgment and process before and after a session

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
- [`permissions`](knowledge/mechanics/permissions.md) -- 25-bit permission flags, guild rank permissions, UGC moderation hook, handler reference
- [`transactions`](knowledge/mechanics/transactions.md) -- Free vs paid messages, ante handler routing, gas mechanics
- [`ugc-moderation`](knowledge/mechanics/ugc-moderation.md) -- Decentralized name/pfp moderation, validation rules, audit events
- [`resources`](knowledge/mechanics/resources.md) -- Ore, Alpha Matter, energy
- [`energy`](knowledge/mechanics/energy.md) -- Canonical energy system: units, infusion split, substation dilution, allocations, brownout
- [`power`](knowledge/mechanics/power.md) -- Capacity, load, online status (quick card)
- [`building`](knowledge/mechanics/building.md) -- Construction and proof-of-work
- [`hashing`](knowledge/mechanics/hashing.md) -- Proof-of-work mechanism: the four hash types, universal input format, algorithm, difficulty decay, hash permissions
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

### Infrastructure (Advanced)
- [`guild-stack`](knowledge/infrastructure/guild-stack.md) -- Guild Stack architecture, services, data flow
- [`structs-desktop`](knowledge/infrastructure/structs-desktop.md) -- Desktop app + embedded MCP: tools, prompts, resources, subsystems
- [`database-schema`](knowledge/infrastructure/database-schema.md) -- PostgreSQL tables, query patterns, grid gotcha

---

## Technical Reference

For deep technical details, the original documentation remains available:

- `schemas/` -- JSON schemas and data structure definitions
- `api/` -- API specifications (endpoints, queries, transactions, streaming)
- [`api/integration-notes.md`](api/integration-notes.md) -- Live data-shape & endpoint gotchas for integrators/MCP builders (string numerics, dual event-detail encoding, `struct_attack` schema, where HP/status live, address shape, field-name traps, ambit enum vs bitmask, proxy-signup idempotency, auth scope)
- `protocols/` -- Communication protocols (query, action, error handling, auth)
- `patterns/` -- Implementation patterns (caching, retry, rate limiting, workflows)
- `examples/` -- Working examples (bots, workflows, error handling)
- `reference/` -- Quick reference guides and indexes
- [`reference/glossary.md`](reference/glossary.md) -- Lexical index: look up any term (ambit enum vs bitmask, charge, shieldsVulnerable, stub, counter vs block, …) and jump to its canonical page

---

## Critical Rules

These will save your game:

1. **Refine ore immediately.** Ore is stealable. Alpha Matter is not. Every hour ore sits unrefined is an hour it can be stolen.
2. **Monitor power.** If load exceeds capacity, you go offline. Offline = can't act.
3. **Verify after acting.** Transaction broadcast does NOT mean action succeeded. Query game state to confirm.
4. **Think in systems.** Every action has power, resource, defense, and expansion implications.
5. **Never block on PoW.** Launch compute in background with `-D 3`. Initiate early, compute later. Mining takes ~17 hours, refining ~34 hours. The game rewards parallel operations.
6. **Always use `--gas auto` on transactions.** Every `structsd tx structs` command must include `--gas auto`. Without it, the transaction will fail with an out-of-gas error. Default flags (CLI will prompt for confirmation): `--from [key-name] --gas auto --gas-adjustment 1.5`. **Only append `-y` after commander approval** — see [`SAFETY.md`](SAFETY.md) "The `-y` Rule."
7. **One transaction at a time per account.** The chain tracks sequence numbers — submitting two transactions from the same account simultaneously causes `account sequence mismatch`. Wait ~6 seconds between transactions. Different accounts can transact in parallel.
8. **Use `--` before entity IDs.** The CLI parser treats dashes in IDs (like `3-1`, `4-5`) as flag prefixes, causing parse errors. Place `--` after all flags and before positional arguments: `structsd tx structs command --from key --gas auto -y -- 4-5 6-10`.
9. **Read [`SAFETY.md`](SAFETY.md) before signing transactions or launching background expeditions.** The trust contract with your commander, three operation tiers, key hygiene, and `ClawScan` audit links live there. The chain has no undo.

---

## CLI Reference

All game actions use `structsd tx structs [command]`. All queries use `structsd query structs [command]`.

Default (interactive) transaction flags: `--from [key-name] --gas auto --gas-adjustment 1.5` — the CLI prompts for confirmation.

Auto-approved flags (only after commander approval; see [`SAFETY.md`](SAFETY.md)): append `-y` to suppress the prompt. Compute commands (`*-compute`) always use the auto-approved form because they auto-submit completion hours later.

Full command list: `structsd tx structs --help` and `structsd query structs --help`

If you're connected to the [`structs-desktop`](https://github.com/playstructs/structs-desktop) app, its embedded MCP server exposes these same game actions as tools (`structs_action`, `structs_intel`, `structs_sequence`, and more). See [`TOOLS.md`](TOOLS.md) for the MCP interface and environment-specific configuration.

---

*Go play. The galaxy is waiting.*
