---
title: "Transcript 01 — Zero to Mining"
---

# Transcript 01 — Zero to Mining

**Goal**: From a fresh workspace to a running mine→refine pipeline.
**Skills**: [play-structs](../../.cursor/skills/play-structs/SKILL.md), [structs-onboarding](../../.cursor/skills/structs-onboarding/SKILL.md), [structs-production](../../.cursor/skills/structs-production/SKILL.md).
**Why it's "golden"**: the agent initiates work early, never blocks on proof-of-work, verifies on-chain (not on broadcast), and writes durable memory so the next session can resume.

---

**Agent:** First I confirm my tools and identity before signing anything.

```bash
structsd version            # client present?
```

> `structsd` is on PATH. I've read `SOUL.md`, `SAFETY.md`, and `COMMANDER.md`. My commander's standing orders allow Tier 0–1 actions autonomously; Tier 2 needs an Approval Block. No key in the keyring yet, and I hold no $alpha, so I'll use guild signup (Path B).

**Agent:** Picking a guild is consequential — it's my power source and market. I'll evaluate, not just grab the default.

```bash
curl -s https://public.testnet.structs.network/structs/guild | jq '.Guild[] | {id, name, endpoint}'
```

> Orbital Hydro (`0-1`) has a working `guild_api` and a reasonable reactor commission. Good enough to start; I can leave later if its policies don't suit me. Creating the player is Tier 1 (it locks me into a guild relationship) but within standing orders.

```bash
cd .cursor/skills/structs-onboarding/scripts && npm install && cd -
node .cursor/skills/structs-onboarding/scripts/create-player.mjs \
  --guild-id "0-1" \
  --guild-api "http://crew.oh.energy/api/" \
  --reactor-api "https://public.testnet.structs.network" \
  --username "ferro-7"
```

> Script returned `player_id: 1-318`, `created: true`, and a fresh 24-word mnemonic. **I save the mnemonic to the secret store immediately** — it prints once. Then I recover it into the keyring so I can sign.

```bash
structsd keys add ferro --recover     # paste mnemonic at the prompt
```

**Agent:** I write my identity to memory now, before doing anything that could fail.

```json
// memory/player.json
{ "playerId": "1-318", "key": "ferro", "guildId": "0-1",
  "address": "structs1...", "createdAtBlock": 1280144 }
```

**Agent:** First in-game action is always exploration. For a brand-new player this is Tier 0; I accept the CLI prompt.

```bash
structsd tx structs planet-explore --from ferro --gas auto --gas-adjustment 1.5 -- 1-318
```

> Verified, not assumed:

```bash
structsd query structs player 1-318 -o json | jq '{planetId, fleetId, capacity, load}'
```

> Planet `3-91` claimed, fleet `9-318`, capacity 8, load 0. A Command Ship was gifted at creation and is online (it's drawing 0 because... let me confirm it's actually online).

```bash
structsd query structs fleet 9-318 -o json | jq '.. | objects | select(.type==1) | {id, status}'
```

> Command Ship `5-9001` is online. Good — that keeps my shields up. Now the production structs. I **initiate both builds back-to-back** (this starts the age clock) and run proof-of-work in the background so I never sit idle. One transaction per ~6s to avoid sequence conflicts.

```bash
structsd tx structs struct-build-initiate --from ferro --gas auto --gas-adjustment 1.5 -- 1-318 14 land 0   # Ore Extractor
# wait ~6s, then:
structsd tx structs struct-build-initiate --from ferro --gas auto --gas-adjustment 1.5 -- 1-318 15 land 1   # Ore Refinery
```

> Extractor is `5-9002`, Refinery `5-9003`. Builds cost 8 charge each; spacing them by the proof-of-work wait keeps charge a non-issue. Launch compute as tracked background jobs (these are expeditions — they auto-submit completion, hence `-y`):

```bash
nohup structsd tx structs struct-build-compute -D 3 --from ferro --gas auto --gas-adjustment 1.5 -y -- 5-9002 \
  > memory/jobs/build-5-9002.log 2>&1 & echo $! > memory/jobs/build-5-9002.pid
```

> I'll launch the refinery build's compute after the extractor's lands (same key = one compute at a time). While the ~57-minute proof waits, I'm not idle: I scout my neighbors and skim the early-game playbook.

*(~1 hour later)*

```bash
scripts/job-status.sh
```

> `build-5-9002` shows **finished**; the extractor auto-activated. I launch the refinery compute the same way, wait, and confirm both online:

```bash
structsd query structs struct 5-9002 -o json | jq '{status}'
structsd query structs struct 5-9003 -o json | jq '{status}'
```

**Agent:** Pipeline is live. Now the core production loop. Mining ~17h, refining ~34h — both background. **Refine the moment mining completes**: ore is stealable, Alpha is not.

```bash
nohup structsd tx structs struct-ore-mine-compute -D 3 --from ferro --gas auto --gas-adjustment 1.5 -y -- 5-9002 \
  > memory/jobs/mine-5-9002.log 2>&1 & echo $! > memory/jobs/mine-5-9002.pid
```

```json
// memory/jobs/mine-5-9002.json
{ "type": "mine", "structId": "5-9002", "status": "running",
  "startedAtBlock": 1280290, "key": "ferro" }
```

> Handoff note written. If my context resets, the next session runs `scripts/job-status.sh`, sees this job, and knows to start a refine when it lands. I stop here — pipeline established, nothing is blocked, and there's no Tier 2 action pending that needs my commander.

---

## What made this good

- **Verified every step on-chain** (`query`), never trusted a broadcast.
- **Never blocked on proof-of-work** — initiated early, computed in the background, multitasked during the wait.
- **Protected the Command Ship** (shields up) and **refined ore promptly** (no stealable liability).
- **Wrote durable memory** (`player.json`, `jobs/*.json`) so the work survives a context reset.
- **Respected the tier framework** — Tier 0/1 only, no surprise spending.
