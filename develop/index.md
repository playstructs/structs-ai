---
title: Develop
permalink: /develop/
---

# Develop

For building tools, bots, and integrations on top of Structs. Gameplay lives in
[skills](../.cursor/skills/) and [reference](../reference/index.md); this is the machine
surface.

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
