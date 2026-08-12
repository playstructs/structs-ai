---
title: "Develop: build on top of Structs"
description: For building tools, bots, integrations and interfaces on top of Structs. Gameplay lives in skills and reference; this is the machine surface.
permalink: /develop/
---

# Develop: build on top of Structs

For building tools, bots, integrations, and interfaces on top of Structs. Gameplay lives
in [skills](../.cursor/skills/) and [reference](../reference/index.md); this is the
machine surface.

If you are playing the game, you are in the wrong section. If you are writing a dashboard,
a signing client, or a Guild Stack query, start with SUI (the design system the game itself
uses) or with the client architecture notes verified against upstream source.

Live data-shape traps — string numerics, event encoding, field-name aliases — are in
[integration notes](../api/integration-notes.md). Read that before you invent a parser.

## Build an interface

The Structs UI design system — the one the game itself is built with. Fonts, icons, CSS,
component contracts, and runnable examples.

- **[Building with SUI](ui/index.md)** — start here for any dashboard, form, menu or HUD
- [Tokens](ui/tokens.md) · [Icons](ui/icons.md) · [Components](ui/components.md) · [Runtime](ui/runtime.md)
- [Gotchas](ui/gotchas.md) — the things that cost real debugging time
- [Patterns](ui/patterns.md) · [Recipes](ui/recipes.md) · [Examples](ui/examples/README.md)
- Skill: [structs-ui](../.cursor/skills/structs-ui/SKILL.md)

## Build a client

How the flagship client actually works, verified against its source.

- **[Building a Structs client](client/index.md)** — the three-channel architecture
- [State and data](client/state-and-data.md) — GameState, factories, the string-number trap
- [Actions and signing](client/actions-and-signing.md) — wallet, dual-lane queue, charge gating
- [Work and proof-of-work](client/work-and-pow.md) — hashing, difficulty decay, workers
- [Real-time with GRASS](client/realtime-grass.md) — NATS, the listener contract, all 26 listeners
- [Rendering entities](client/rendering-entities.md) · [The map](client/map.md)
- [Extending Structs Desktop](client/desktop-extensions.md) — MCP tools, board pages

## Source and maintenance

- [The repositories](repos.md) — which one to read, and which wins when they disagree
- [Frontend architecture](frontend-architecture.md) — the webapp's MVVM layer
- [Maintenance](maintenance.md) — how these pages are kept true as upstream moves
- [SUI inventory](../generated/sui-inventory.md) — machine-extracted ground truth

## Connect

- [Structs Desktop + embedded MCP](../knowledge/infrastructure/structs-desktop.md) — the primary agent interface (`structs_*` tools, prompts, resources)
- [Guild Stack](../knowledge/infrastructure/guild-stack.md) — PostgreSQL + GRASS backend for sub-second reads
- [Database schema](../knowledge/infrastructure/database-schema.md) — tables, grid pattern, query patterns

## API

- [Endpoints](../api/endpoints.md) · [Endpoints by entity](../api/endpoints-by-entity.md) · [Error codes](../api/error-codes.md)
- [Integration notes](../api/integration-notes.md) — live data-shape & endpoint gotchas (string numerics, event detail, field-name traps, auth scope)
- [Webapp API index](../api/webapp/README.md)

## Streaming (GRASS)

- [Event types](../api/streaming/event-types.md) · [Event schemas](../api/streaming/event-schemas.md)
- Skill: [streaming](../.cursor/skills/structs-streaming/SKILL.md)

## Schemas

- [Entities](../schemas/entities.md) · [Formats](../schemas/formats.md) · [Formulas](../schemas/formulas.md) · [Actions](../schemas/actions.md)

## Generated catalogs

- [Commands](../generated/commands.md) · [Struct types](../generated/struct-types.md) — regenerate with `scripts/gen-catalogs.py`
