---
title: "Reference: rules, numbers, names"
description: "Look up a rule, a number, or a name: action and entity indexes, endpoint lookups, formulas, and the glossary. For procedures, use skills instead."
permalink: /reference/
---

# Reference: rules, numbers, names

Look up a rule, a number, or a name. For step-by-step procedures use
[skills](../.cursor/skills/); for strategy use [strategy](../strategy/index.md).

This is the lookup desk. Generated catalogs are stamped from a specific `structsd` version — if your binary is newer, regenerate or distrust the number. The glossary and Codex crosswalk exist because the same idea has three names (UI, Codex, chain) and mixing them causes bad transactions.

Do not read this section top to bottom. Arrive with a word or an error string and leave with a page.

The action and entity indexes are for “what is the name of this thing.” Local devnet is for “I need to fail in private.” If you are about to sign a Tier 1 action you have never rehearsed, that last link is the one.

## Source-derived catalogs (provenance-stamped)

- [Struct type catalog](../generated/struct-types.md) — build cost, draw, HP, weapons (generated from `structsd v0.20.0`)
- [CLI command catalog](../generated/commands.md) — every `structsd tx/query structs` command
- [Command snapshot](../generated/structsd-commands.txt) — flat list used by the command lint

## Mechanics

- [Combat](../knowledge/mechanics/combat.md) · [Defense](../knowledge/mechanics/defense.md) · [Building](../knowledge/mechanics/building.md) · [Hashing / proof-of-work](../knowledge/mechanics/hashing.md)
- [Energy](../knowledge/mechanics/energy.md) · [Power](../knowledge/mechanics/power.md) · [Resources](../knowledge/mechanics/resources.md)
- [Transactions & fees](../knowledge/mechanics/transactions.md) · [Permissions](../knowledge/mechanics/permissions.md) · [UGC moderation](../knowledge/mechanics/ugc-moderation.md)
- [Fleet](../knowledge/mechanics/fleet.md) · [Planet](../knowledge/mechanics/planet.md)

## Entities

- [Struct types](../knowledge/entities/struct-types.md) · [Entity relationships](../knowledge/entities/entity-relationships.md)

## Economy

- [Energy market](../knowledge/economy/energy-market.md) · [Guild banking](../knowledge/economy/guild-banking.md) · [Trading](../knowledge/economy/trading.md) · [Valuation](../knowledge/economy/valuation.md)

## Lookups

- [Glossary](glossary.md) — disambiguates tricky terms (ambit enum vs bitmask, block vs counter, …)
- [Codex crosswalk](codex-crosswalk.md) — maps human [Codex](https://www.playstructs.com/codex) terms (Battlegrounds, Battery, Alpha Ore, …) to these pages
- [Action index](action-index.md) · [Action quick reference](action-quick-reference.md)
- [Local devnet](local-devnet.md)

## Errors

- [Error index](../play/errors.md) · [Troubleshooting](../troubleshooting/common-issues.md)

## When to open this page

Open reference with a search term, an error string, or a struct type ID. It is a desk, not a curriculum. Generated catalogs beat memory. The glossary beats arguing about ambit. Local devnet beats learning a raid on a shared chain.
