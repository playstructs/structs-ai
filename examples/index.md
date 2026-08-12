---
title: Examples for bots, workflows, and errors
description: "Worked examples for Structs agents: workflows, auth, error handling, database queries, golden transcripts, and sample bots."
permalink: /examples/
---

# Examples for bots, workflows, and errors

Examples are runnable or near-runnable illustrations, not the canonical procedure. Skills own the commands. These pages show how those commands chain, how auth looks on the wire, and what a 404 or a 429 actually returns.

Workflows are the bulk of this section: mine-refine, planet setup, reactor staking, raids, guild tokens. Auth covers webapp login, NATS, and consensus signing. Errors are response shapes. Transcripts are graded sessions — reasoning, commands, verification, memory writes — not scripts to replay with the IDs left in.

Bots (`simple-bot`, mining, combat, economic) are sketches of an agent loop. They will be wrong the day the chain moves. Copy the structure, not the endpoints, and check [integration notes](/api/integration-notes) before you parse.

## When to open this page

Open examples when you know the skill and want to see it composed. If you do not yet know whether to mine or raid, go to [play](/play/). If you need a single endpoint, go to [api](/api/).

- [Workflows](workflows/) -- Multi-step API operations with state and dependencies
- [Auth](auth/) -- Webapp login, NATS, consensus signing, permissions
- [Errors](errors/) -- 404, 429, and 500 response shapes
- [Database](database/) -- PostgreSQL query examples against Guild Stack
- [Transcripts](transcripts/) -- Golden sessions graded against the scorecard
- [Simple bot](simple-bot) -- Minimal agent loop
- [Mining bot](gameplay-mining-bot) -- Mine and refine loop
- [Combat bot](gameplay-combat-bot) -- Attack and raid sketch
- [Economic bot](economic-bot) -- Market and agreement sketch
- [Working API examples](working-api-examples) -- Copy-paste request shapes
- [Economic calculations](economic-calculations) -- Worked numbers
