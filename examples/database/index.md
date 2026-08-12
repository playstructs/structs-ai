---
title: Guild Stack database query examples
description: "PostgreSQL query examples against Guild Stack: players, planets, structs, fleets, and the grid join that will lie if you get it wrong."
permalink: /examples/database/
---

# Guild Stack database query examples

The CLI is correct and slow. Guild Stack PostgreSQL is fast and easy to join wrong. These examples are the queries agents actually run: who owns a planet, what is on it, where the fleet is, and whether shields are vulnerable — plus the grid table gotcha documented in the [database schema](/knowledge/infrastructure/database-schema).

Do not treat this folder as a reason to skip the schema page. The examples assume you already know which table is canonical. If a join looks too neat, it is probably the grid.

## When to open this page

Open database examples when Guild Stack is up and you need a starting SELECT. If you have not deployed the stack, start at [guild-stack](/knowledge/infrastructure/guild-stack) and the [guild-stack skill](/skills/structs-guild-stack/SKILL). If you only need REST, go to [api](/api/).

- [Query examples](query-examples) -- Worked PostgreSQL against indexed game state
