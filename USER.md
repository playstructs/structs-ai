---
title: Operator profile the agent reads
description: "The operator profile: the one file a human fills in. Goals, risk, autonomy, and connection details for the agent that plays Structs."
---

# Operator profile the agent reads

OpenClaw and older prompts look for `USER.md`. For Structs, the human-edited file is **[`config/operator.md`](config/operator.md)** — copy it from [`config/operator.example.md`](config/operator.example.md) and fill it in. This page stays so those links still resolve.

`config/operator.md` is gitignored. It survives `git pull`. Do not commit it. Do not put mnemonics or private keys in it. The key material stays in the `structsd` keyring or Desktop; this file only names which key to use.

## What the agent reads at session start

The YAML front matter is the machine-readable contract. The markdown below it is standing orders in prose.

**goals** — five weights, 0–3 (0 = ignore, 3 = primary): `economy`, `expansion`, `military`, `exploration`, `guild`. Compose them directly, or start from a [playstyle preset](strategy/presets/) (Industrialist, Raider, Merchant, Explorer, Diplomat, Generalist) and edit. No personality is required.

**risk** — `cautious`, `moderate`, or `aggressive`. This is not a soul. It is how often the agent should take a fight or a market that can go badly.

**autonomy** — the ladder in [`SAFETY.md`](SAFETY.md):

- `ask_first` — confirm every write
- `ask_for_irreversible` — act inside Tier 1 caps; always escalate Tier 2 (recommended)
- `act_and_report` — act, then brief
- `full` — act inside caps; still escalate Tier 2

**tempo** — `patient`, `balanced`, or `fast`. How hard to push parallel jobs versus waiting for charge and PoW.

**guild_preference** — `optional`, `required`, `none`, or a named guild. Signup is not free-form; the onboarding skill has the path.

**environment** — `interface: auto | mcp | cli`, optional RPC, `key_name`, Desktop MCP URL. Leave blank and `scripts/preflight.sh` will detect.

## Standing orders worth writing

The example file has blanks for Tier 1 caps (how much Alpha to infuse per session, how many new builds, which targets are known-hostile) and a hard list of Tier 2 actions the agent must never auto-execute: generator infusion, PermAll, address-register, guild confiscate-and-burn, reactor defuse, deleting providers. Fill the blanks. An empty cap is not permission.

After the profile exists, the agent starts at [`START.md`](START.md) (or this quickstart's twin, [`QUICKSTART.md`](QUICKSTART.md)) and plays via [`play-structs`](.cursor/skills/play-structs/SKILL.md).
