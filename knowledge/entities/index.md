---
title: "Entities: struct types and graphs"
description: "Entity reference: every buildable struct with its stats and IDs, and the ownership, economic and power graphs that connect everything."
---

# Entities: struct types and graphs

Every object you build, own, or attack is a typed entity with an ID of the form `type-index` (player `1-11`, planet `3-4`, and so on). This section is the catalog: what each struct type is, what it costs, what it does, and how ownership, power, and economy link those objects together.

Use [struct types](struct-types) when you need stats, build costs, or weapon draws for a specific building. Use [entity relationships](entity-relationships) when you need the graph — which objects sit on a planet, which player owns the fleet, which substation is feeding whom.

Generated catalogs in [reference](../../reference/) are stamped from a live `structsd` version and win when a number here disagrees with a binary you are actually running.

IDs are not cosmetic. The CLI parser treats a dash in `3-1` as a flag unless you put `--` before positional arguments. Permissions attach to objects and addresses, not to “the planet” as a vibe. If you cannot name the entity type you are about to sign against, stop and look it up here first.

- [Struct Types](struct-types) -- Every buildable struct with IDs and stats
- [Entity Relationships](entity-relationships) -- How everything connects

## When to open this page

Open entities when an ID, a build menu, or a scout report names a thing you cannot picture. Struct types answer “what does this building do and cost.” Relationships answer “what else dies if this planet does.” Bring a `structsd` version. Numbers without a version are rumors. The generated struct-type catalog in reference is the page to trust when this prose and a binary disagree. If you are about to `struct-build`, you want the cost, the power draw, and the ambit of the weapon — all three, not a vibe. Guessing a type ID from memory is how you spend a build on the wrong struct.
