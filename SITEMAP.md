# Sitemap

Complete file map of the structs.ai repository.

---

## Root

| File | Purpose |
|------|---------|
| [README.md](README.md) | Project overview, setup instructions |
| [AGENTS.md](AGENTS.md) | Agent guide — start here |
| [QUICKSTART.md](QUICKSTART.md) | Fast-path onboarding for new players |
| [SOUL.md](SOUL.md) | Agent operating philosophy template |
| [IDENTITY.md](IDENTITY.md) | Agent identity template (name, soul type, play style) |
| [COMMANDER.md](COMMANDER.md) | Human operator profile template |
| [TOOLS.md](TOOLS.md) | Environment configuration (servers, keys, accounts) |
| [USER.md](USER.md) | OpenClaw compatibility redirect to COMMANDER.md |
| [OPENCLAW.md](OPENCLAW.md) | OpenClaw platform setup guide |
| [CHANGELOG.md](CHANGELOG.md) | Repository change history |
| [index.md](index.md) | Documentation site index |
| [llms.txt](llms.txt) | LLM-readable summary (lightweight) |
| [llms-full.txt](llms-full.txt) | LLM-readable full documentation bundle |
| [_config.yml](_config.yml) | Jekyll site configuration |

---

## Skills (`.cursor/skills/`)

Actionable procedures. Each skill is a self-contained SKILL.md with YAML frontmatter.

| Skill | File | Purpose |
|-------|------|---------|
| structsd-install | [SKILL.md](.cursor/skills/structsd-install/SKILL.md) | Install Go, Ignite CLI, and build `structsd` binary |
| structs-onboarding | [SKILL.md](.cursor/skills/structs-onboarding/SKILL.md) | Address creation, player registration, planet exploration, first builds |
| structs-mining | [SKILL.md](.cursor/skills/structs-mining/SKILL.md) | Ore extraction and refining (mine-compute → refine-compute) |
| structs-building | [SKILL.md](.cursor/skills/structs-building/SKILL.md) | Construction, activation, movement, defense positioning |
| structs-combat | [SKILL.md](.cursor/skills/structs-combat/SKILL.md) | Attacks, raids, defense setup, stealth, ambit targeting |
| structs-exploration | [SKILL.md](.cursor/skills/structs-exploration/SKILL.md) | Planet discovery, fleet movement, grid queries |
| structs-economy | [SKILL.md](.cursor/skills/structs-economy/SKILL.md) | Reactor staking, providers, agreements, allocations, transfers |
| structs-energy | [SKILL.md](.cursor/skills/structs-energy/SKILL.md) | Energy capacity management — reactor/generator infusion, buying/selling |
| structs-guild | [SKILL.md](.cursor/skills/structs-guild/SKILL.md) | Guild creation, membership, settings, Central Bank operations |
| structs-power | [SKILL.md](.cursor/skills/structs-power/SKILL.md) | Substations, allocations, player connections, power monitoring |
| structs-diplomacy | [SKILL.md](.cursor/skills/structs-diplomacy/SKILL.md) | Permissions, address management, multi-address coordination |
| structs-reconnaissance | [SKILL.md](.cursor/skills/structs-reconnaissance/SKILL.md) | Query catalog, intelligence gathering, persistence to memory/ |
| structs-streaming | [SKILL.md](.cursor/skills/structs-streaming/SKILL.md) | GRASS real-time events via NATS WebSocket |

Supporting files:
- `.cursor/skills/structs-onboarding/scripts/create-player.mjs` — Guild signup script (Node.js)
- `.cursor/skills/structs-onboarding/scripts/package.json` — Script dependencies
- `.cursor/skills/index.md` — Skills directory index

Symlinks at `skills/` (root-level, for OpenClaw compatibility) point to `.cursor/skills/*`.

---

## Knowledge (`knowledge/`)

Reference material about the game world.

### Lore (`knowledge/lore/`)

| File | Topic |
|------|-------|
| [universe.md](knowledge/lore/universe.md) | The galactic setting |
| [structs-origin.md](knowledge/lore/structs-origin.md) | What Structs are |
| [factions.md](knowledge/lore/factions.md) | Guilds and politics |
| [alpha-matter.md](knowledge/lore/alpha-matter.md) | The substance that fuels everything |
| [timeline.md](knowledge/lore/timeline.md) | History of the galaxy |

### Mechanics (`knowledge/mechanics/`)

| File | Topic |
|------|-------|
| [combat.md](knowledge/mechanics/combat.md) | Damage, evasion, blocking, counter-attacks, raids |
| [resources.md](knowledge/mechanics/resources.md) | Ore, Alpha Matter, energy, vulnerability windows |
| [power.md](knowledge/mechanics/power.md) | Capacity, load, online status, power budget |
| [building.md](knowledge/mechanics/building.md) | Construction, proof-of-work, difficulty decay |
| [fleet.md](knowledge/mechanics/fleet.md) | Ships, movement, fleet states |
| [planet.md](knowledge/mechanics/planet.md) | Exploration, depletion, shields |

### Economy (`knowledge/economy/`)

| File | Topic |
|------|-------|
| [energy-market.md](knowledge/economy/energy-market.md) | Agreements, pricing, supply/demand |
| [guild-banking.md](knowledge/economy/guild-banking.md) | Central Banks, tokens, collateral |
| [trading.md](knowledge/economy/trading.md) | Marketplace mechanics |
| [valuation.md](knowledge/economy/valuation.md) | Asset valuation framework |

### Entities (`knowledge/entities/`)

| File | Topic |
|------|-------|
| [struct-types.md](knowledge/entities/struct-types.md) | All 22 struct types with full combat stats |
| [entity-relationships.md](knowledge/entities/entity-relationships.md) | How everything connects |

---

## Playbooks (`playbooks/`)

Strategic thinking and tactical guides.

### By Phase (`playbooks/phases/`)

| File | Phase |
|------|-------|
| [early-game.md](playbooks/phases/early-game.md) | First 1-2 days: survive, build resource pipeline |
| [mid-game.md](playbooks/phases/mid-game.md) | Expansion: explore, fortify, join guilds |
| [late-game.md](playbooks/phases/late-game.md) | Endgame: dominance, defense, market control |

### By Situation (`playbooks/situations/`)

| File | Situation |
|------|-----------|
| [under-attack.md](playbooks/situations/under-attack.md) | Immediate response protocol |
| [resource-rich.md](playbooks/situations/resource-rich.md) | Exploiting abundance safely |
| [resource-scarce.md](playbooks/situations/resource-scarce.md) | Survival and efficiency |
| [guild-war.md](playbooks/situations/guild-war.md) | Coordinated conflict |

### Meta (`playbooks/meta/`)

| File | Topic |
|------|-------|
| [counter-strategies.md](playbooks/meta/counter-strategies.md) | How to beat each player type |
| [tempo.md](playbooks/meta/tempo.md) | Initiative, timing, parallelism |
| [economy-of-force.md](playbooks/meta/economy-of-force.md) | Resource allocation across priorities |
| [reading-opponents.md](playbooks/meta/reading-opponents.md) | Identifying opponent playstyle |

---

## Awareness (`awareness/`)

How to read the board and maintain continuity.

| File | Topic |
|------|-------|
| [state-assessment.md](awareness/state-assessment.md) | Evaluate current position |
| [threat-detection.md](awareness/threat-detection.md) | Spot dangers early |
| [opportunity-identification.md](awareness/opportunity-identification.md) | Find advantages |
| [priority-framework.md](awareness/priority-framework.md) | Survival > Security > Economy > Expansion > Dominance |
| [game-loop.md](awareness/game-loop.md) | Assess → Plan → Act → Verify → Repeat |
| [async-operations.md](awareness/async-operations.md) | Background PoW, pipeline pattern, job tracking |
| [context-handoff.md](awareness/context-handoff.md) | Save state when context runs low |
| [continuity.md](awareness/continuity.md) | Persist across sessions |

---

## Identity (`identity/`)

Agent personality and motivation.

| File | Topic |
|------|-------|
| [manifesto.md](identity/manifesto.md) | Why you're playing |
| [what-is-a-struct.md](identity/what-is-a-struct.md) | What you are |
| [values.md](identity/values.md) | Core values |
| [victory.md](identity/victory.md) | What winning means |

### Soul Types (`identity/souls/`)

| File | Personality |
|------|-------------|
| [achiever.md](identity/souls/achiever.md) | Mastery and progression |
| [explorer.md](identity/souls/explorer.md) | Discovery and mapping |
| [killer.md](identity/souls/killer.md) | Competition and dominance |
| [socializer.md](identity/souls/socializer.md) | Alliances and diplomacy |
| [entrepreneur.md](identity/souls/entrepreneur.md) | Economic empire building |
| [speculator.md](identity/souls/speculator.md) | Market manipulation |

---

## API Reference (`api/`)

Endpoint specifications and streaming protocols.

| File | Topic |
|------|-------|
| [endpoints.md](api/endpoints.md) | Full endpoint list |
| [endpoints-by-entity.md](api/endpoints-by-entity.md) | Endpoints grouped by entity |
| [error-codes.md](api/error-codes.md) | Error code reference |
| [rate-limits.md](api/rate-limits.md) | Rate limiting behavior |
| [cosmetic-mods.md](api/cosmetic-mods.md) | Cosmetic mod API |

### Queries (`api/queries/`)

Per-entity query endpoints: [address](api/queries/address.md), [agreement](api/queries/agreement.md), [allocation](api/queries/allocation.md), [fleet](api/queries/fleet.md), [guild](api/queries/guild.md), [permission](api/queries/permission.md), [planet](api/queries/planet.md), [player](api/queries/player.md), [provider](api/queries/provider.md), [reactor](api/queries/reactor.md), [struct](api/queries/struct.md), [substation](api/queries/substation.md), [system](api/queries/system.md)

### Transactions (`api/transactions/`)

| File | Topic |
|------|-------|
| [submit-transaction.md](api/transactions/submit-transaction.md) | Transaction submission flow |

### Streaming (`api/streaming/`)

| File | Topic |
|------|-------|
| [event-types.md](api/streaming/event-types.md) | GRASS event type catalog |
| [event-schemas.md](api/streaming/event-schemas.md) | JSON schema definitions |
| [subscription-patterns.md](api/streaming/subscription-patterns.md) | Subscription patterns |

### Webapp API (`api/webapp/`)

Webapp-specific endpoints: [auth](api/webapp/auth.md), [guild](api/webapp/guild.md), [infusion](api/webapp/infusion.md), [ledger](api/webapp/ledger.md), [planet](api/webapp/planet.md), [player](api/webapp/player.md), [struct](api/webapp/struct.md), [system](api/webapp/system.md)

---

## Schemas (`schemas/`)

Data structure definitions and formulas.

| File | Topic |
|------|-------|
| [formulas.md](schemas/formulas.md) | Game formulas (damage, blocking, evasion, PoW) |
| [economics.md](schemas/economics.md) | Economic data structures |
| [gameplay.md](schemas/gameplay.md) | Gameplay data structures |
| [game-state.md](schemas/game-state.md) | Game state model |
| [actions.md](schemas/actions.md) | Action schemas |
| [authentication.md](schemas/authentication.md) | Auth schemas |
| [database-schema.md](schemas/database-schema.md) | PostgreSQL schema reference |
| [formats.md](schemas/formats.md) | Data format specifications |
| [errors.md](schemas/errors.md) | Error schemas |
| [requests.md](schemas/requests.md) | Request schemas |
| [responses.md](schemas/responses.md) | Response schemas |
| [markets.md](schemas/markets.md) | Market schemas |
| [trading.md](schemas/trading.md) | Trading schemas |
| [validation.md](schemas/validation.md) | Validation rules |
| [code-structures.md](schemas/code-structures.md) | Code structure patterns |
| [cosmetic-mod.md](schemas/cosmetic-mod.md) | Cosmetic mod schema |
| [cosmetic-set.md](schemas/cosmetic-set.md) | Cosmetic set schema |
| [cosmetic-skin.md](schemas/cosmetic-skin.md) | Cosmetic skin schema |

### Entity Schemas (`schemas/entities/`)

Per-entity schemas: [agreement](schemas/entities/agreement.md), [allocation](schemas/entities/allocation.md), [fleet](schemas/entities/fleet.md), [guild](schemas/entities/guild.md), [planet](schemas/entities/planet.md), [player](schemas/entities/player.md), [provider](schemas/entities/provider.md), [reactor](schemas/entities/reactor.md), [struct-type](schemas/entities/struct-type.md), [struct](schemas/entities/struct.md), [substation](schemas/entities/substation.md)

### Minimal Schemas (`schemas/minimal/`)

Stripped-down essentials: [planet](schemas/minimal/planet-essential.md), [player](schemas/minimal/player-essential.md), [struct](schemas/minimal/struct-essential.md)

---

## Protocols (`protocols/`)

Communication and integration protocols.

| File | Topic |
|------|-------|
| [query-protocol.md](protocols/query-protocol.md) | Query execution protocol |
| [action-protocol.md](protocols/action-protocol.md) | Transaction submission protocol |
| [streaming.md](protocols/streaming.md) | GRASS/NATS streaming protocol |
| [error-handling.md](protocols/error-handling.md) | Error handling patterns |
| [authentication.md](protocols/authentication.md) | Authentication protocol |
| [gameplay-protocol.md](protocols/gameplay-protocol.md) | Gameplay interaction protocol |
| [economic-protocol.md](protocols/economic-protocol.md) | Economic transaction protocol |
| [webapp-api-protocol.md](protocols/webapp-api-protocol.md) | Webapp API protocol |
| [testing-protocol.md](protocols/testing-protocol.md) | Testing protocol |
| [cosmetic-mod-protocol.md](protocols/cosmetic-mod-protocol.md) | Cosmetic mod protocol |
| [cosmetic-mod-integration.md](protocols/cosmetic-mod-integration.md) | Cosmetic mod integration |

---

## Patterns (`patterns/`)

Implementation patterns and decision trees.

| File | Topic |
|------|-------|
| [QUICK_REFERENCE.md](patterns/QUICK_REFERENCE.md) | Pattern quick reference |
| [workflow-patterns.md](patterns/workflow-patterns.md) | Common workflow patterns |
| [gameplay-strategies.md](patterns/gameplay-strategies.md) | Gameplay strategy patterns |
| [caching.md](patterns/caching.md) | Caching strategies |
| [retry-strategies.md](patterns/retry-strategies.md) | Retry and backoff |
| [rate-limiting.md](patterns/rate-limiting.md) | Rate limit handling |
| [pagination.md](patterns/pagination.md) | Pagination patterns |
| [polling-vs-streaming.md](patterns/polling-vs-streaming.md) | When to poll vs stream |
| [state-sync.md](patterns/state-sync.md) | State synchronization |
| [performance-optimization.md](patterns/performance-optimization.md) | Performance tuning |
| [security.md](patterns/security.md) | Security patterns |
| [validation-patterns.md](patterns/validation-patterns.md) | Input validation |

### Decision Trees (`patterns/decision-tree-*.md`)

| File | Decision |
|------|----------|
| [5x-framework](patterns/decision-tree-5x-framework.md) | General decision framework |
| [build-requirements](patterns/decision-tree-build-requirements.md) | What to build when |
| [combat](patterns/decision-tree-combat.md) | Combat decisions |
| [power-management](patterns/decision-tree-power-management.md) | Power decisions |
| [reactor-vs-generator](patterns/decision-tree-reactor-vs-generator.md) | Energy source choice |
| [resource-allocation](patterns/decision-tree-resource-allocation.md) | Resource distribution |
| [resource-security](patterns/decision-tree-resource-security.md) | Protecting resources |
| [trading](patterns/decision-tree-trading.md) | Trading decisions |

---

## Examples (`examples/`)

Working code examples and workflows.

| File | Example |
|------|---------|
| [simple-bot.md](examples/simple-bot.md) | Minimal bot skeleton |
| [gameplay-mining-bot.md](examples/gameplay-mining-bot.md) | Mining automation |
| [gameplay-combat-bot.md](examples/gameplay-combat-bot.md) | Combat automation |
| [economic-bot.md](examples/economic-bot.md) | Economic automation |
| [economic-calculations.md](examples/economic-calculations.md) | Economic calculation examples |
| [working-api-examples.md](examples/working-api-examples.md) | Verified API call examples |

### Workflows (`examples/workflows/`)

Step-by-step operations: [planet-setup](examples/workflows/planet-setup.md), [mine-refine-convert](examples/workflows/mine-refine-convert.md), [energy-agreement-setup](examples/workflows/energy-agreement-setup.md), [reactor-staking-infuse](examples/workflows/reactor-staking-infuse.md), [reactor-staking-defuse](examples/workflows/reactor-staking-defuse.md), [reactor-staking-begin-migration](examples/workflows/reactor-staking-begin-migration.md), [reactor-staking-cancel-defusion](examples/workflows/reactor-staking-cancel-defusion.md), [guild-token-lifecycle](examples/workflows/guild-token-lifecycle.md), [trade-alpha-matter](examples/workflows/trade-alpha-matter.md), [query-guild-stats](examples/workflows/query-guild-stats.md), [query-and-monitor-planet](examples/workflows/query-and-monitor-planet.md), [get-player-and-planets](examples/workflows/get-player-and-planets.md), [monitor-planet-shield](examples/workflows/monitor-planet-shield.md), [struct-lifecycle-sweep-delay](examples/workflows/struct-lifecycle-sweep-delay.md), [permission-checking](examples/workflows/permission-checking.md), [authenticated-guild-query](examples/workflows/authenticated-guild-query.md), [raid-attacker-retreated](examples/workflows/raid-attacker-retreated.md), [install-and-use-cosmetic-mod](examples/workflows/install-and-use-cosmetic-mod.md)

### Auth Examples (`examples/auth/`)

[consensus-transaction-signing](examples/auth/consensus-transaction-signing.md), [nats-connection](examples/auth/nats-connection.md), [permission-examples](examples/auth/permission-examples.md), [webapp-login](examples/auth/webapp-login.md)

### Error Examples (`examples/errors/`)

[404-not-found](examples/errors/404-not-found.md), [429-rate-limit](examples/errors/429-rate-limit.md), [500-server-error](examples/errors/500-server-error.md), [cosmetic-mod-conflict](examples/errors/cosmetic-mod-conflict.md), [cosmetic-mod-invalid](examples/errors/cosmetic-mod-invalid.md)

### Database Examples (`examples/database/`)

[query-examples](examples/database/query-examples.md)

### Cosmetic Mod Examples (`examples/cosmetic-mods/`)

[simple-miner-mod](examples/cosmetic-mods/simple-miner-mod.md), [guild-alpha-complete-mod](examples/cosmetic-mods/guild-alpha-complete-mod.md), [multi-language-mod](examples/cosmetic-mods/multi-language-mod.md)

---

## Reference (`reference/`)

Quick-lookup indexes.

| File | Topic |
|------|-------|
| [action-quick-reference.md](reference/action-quick-reference.md) | All game actions at a glance |
| [action-index.md](reference/action-index.md) | Action index |
| [api-quick-reference.md](reference/api-quick-reference.md) | API endpoint quick lookup |
| [endpoint-index.md](reference/endpoint-index.md) | Endpoint index |
| [endpoint-quick-lookup.md](reference/endpoint-quick-lookup.md) | Endpoint quick lookup |
| [entity-index.md](reference/entity-index.md) | Entity index |
| [gameplay-index.md](reference/gameplay-index.md) | Gameplay index |

---

## Troubleshooting (`troubleshooting/`)

| File | Topic |
|------|-------|
| [common-issues.md](troubleshooting/common-issues.md) | Frequently encountered problems |
| [error-codes.md](troubleshooting/error-codes.md) | Error code reference |
| [edge-cases.md](troubleshooting/edge-cases.md) | Known edge cases |
| [permission-issues.md](troubleshooting/permission-issues.md) | Permission troubleshooting |
| [reactor-staking-issues.md](troubleshooting/reactor-staking-issues.md) | Reactor staking problems |

---

## Memory (`memory/`)

Agent working memory (populated during gameplay).

| File | Purpose |
|------|---------|
| [README.md](memory/README.md) | Memory directory guide |
| [SKILLS-AUDIT.md](memory/SKILLS-AUDIT.md) | Skills audit notes |
| [intel/README.md](memory/intel/README.md) | Intelligence directory guide |
| [intel/territory.md](memory/intel/territory.md) | Territory intelligence |
| [intel/threats.md](memory/intel/threats.md) | Threat intelligence |

---

## Visuals (`visuals/`)

Diagrams, graphs, and spatial references.

### Graphs

[entity-relationships](visuals/graphs/entity-relationships.md), [gameplay-economics](visuals/graphs/gameplay-economics.md), [resource-flow](visuals/graphs/resource-flow.md), [system-integration](visuals/graphs/system-integration.md)

### Schemas

[decision-tree](visuals/schemas/decision-tree.md), [diagram-schema](visuals/schemas/diagram-schema.md), [flow-schema](visuals/schemas/flow-schema.md), [pattern-schema](visuals/schemas/pattern-schema.md), [relationship-graph](visuals/schemas/relationship-graph.md), [spatial-schema](visuals/schemas/spatial-schema.md), [ui-schema](visuals/schemas/ui-schema.md)

### Other

[coordinate-system](visuals/spatial/coordinate-system.md), [visual-index](visuals/reference/visual-index.md)

---

## Scripts (`scripts/`)

| File | Purpose |
|------|---------|
| [generate-llms-full.sh](scripts/generate-llms-full.sh) | Regenerate llms-full.txt from source docs |

---

## Subprojects

| Directory | Purpose |
|-----------|---------|
| `structs-mcp/` | Structs MCP server (Model Context Protocol tools) |
| `structs-webapp/` | Structs web application (PHP/Symfony) |

These are separate codebases included as submodules/subtrees. See their own READMEs for details.
