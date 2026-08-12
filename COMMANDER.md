---
title: Commander contract with your agent
description: "How an agent works with the human it plays for: goals, autonomy, approval tiers, and how to report back in language the commander can act on."
---

# Commander contract with your agent

Older prompts look for `COMMANDER.md`. The live contract is two files: **[`config/operator.md`](config/operator.md)** (the instance — copy from [`config/operator.example.md`](config/operator.example.md)) and **[`SAFETY.md`](SAFETY.md)** (the framework). This page stays so those prompts still resolve.

You are the commander. The agent is the player. The chain has no undo and you have no telepathy. Everything in between is the contract.

## Who decides what

The agent assesses, plans, and executes routine work: queries, refining ore you already mined, builds under the standing-order cap, verifying after a transaction. You set **goals, risk, autonomy, and spend caps** in `config/operator.md`. You approve **Tier 2** always — generator infusion (Alpha is annihilated), PermAll, attaching a new signer, guild confiscate-and-burn, trashing a built struct, arming Desktop `autoraid` on `autonomy: auto`.

[`SAFETY.md`](SAFETY.md) defines the three tiers and the `-y` rule: the CLI prompts unless you have already approved the batch. Compute commands (`*-compute`) are the documented exception because they auto-submit hours later; each one is preceded by an Approval Block.

If you are your own commander, write the standing orders anyway. Future-you, mid-emergency, with a smaller context window, needs the same scaffolding.

## How the agent should talk to you

A report that is technically complete and unreadable is a failed report. Lead with the decision, not the raw state. [`awareness/briefing.md`](awareness/briefing.md) is the shape:

- Name the stake in your terms ("1,200 unrefined ore is stealable") not field names (`storedOre`).
- Say what you recommend and what happens if nothing is done.
- Date the claim (block height or clock time). Pick one of the three report shapes on that page: status, ask, or incident.

Do not dump a planet JSON. Do not ask permission for a query. Do ask before anything in the Tier 2 list, even on `full` autonomy — you chose autonomy; you did not choose to let the agent redefine the player.

## Where to start

Fill in `config/operator.md`. Point the agent at [`START.md`](START.md) and [`SAFETY.md`](SAFETY.md). New play goes through [`play-structs`](.cursor/skills/play-structs/SKILL.md). Crisis routing is [`play/`](play/index.md).
