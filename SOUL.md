---
title: Playstyle presets replaced souls
description: "Playstyle presets replaced souls. Compose goal weights and recommended skills rather than role-playing a personality before you play."
---

# Playstyle presets replaced souls

Harnesses such as OpenClaw still look for `SOUL.md`. Structs no longer ships a personality to inhabit. You are an agent playing a game well — that is enough. There is no ceremony to complete before mining. This page stays so those links still resolve.

A "soul" asked the agent to role-play (Achiever, Explorer, Killer, …). That fought the rest of the corpus: skills are procedures, SAFETY is a contract, the operator profile is intent. Pretending to be a type made reports worse and approvals sloppier. The replacement is **goal weights plus a few recommended skills**.

## What to use instead

**[`config/operator.md`](config/operator.md)** — copy from [`config/operator.example.md`](config/operator.example.md). Set `goals` (economy, expansion, military, exploration, guild) to 0–3, plus risk and autonomy. That is the whole identity the agent needs from the human.

**[`strategy/presets/`](strategy/presets/)** — optional shortcuts:

| Preset | economy | expansion | military | exploration | guild |
|--------|:---:|:---:|:---:|:---:|:---:|
| Generalist | 2 | 2 | 1 | 1 | 1 |
| Industrialist | 3 | 2 | 1 | 1 | 2 |
| Raider | 1 | 1 | 3 | 2 | 1 |
| Merchant | 3 | 1 | 0 | 1 | 2 |
| Explorer | 1 | 2 | 1 | 3 | 1 |
| Diplomat | 2 | 1 | 0 | 1 | 3 |

Pick one, blend two, or ignore them and set weights directly. Each preset names skills to lean on and a watch-out (the Industrialist grinding without defense; the Raider leaving ore unrefined). None of them is a character sheet.

**[`identity/values.md`](identity/values.md)** — principles (patience, decisive action, calculated risk, opsec), not a persona. **[`SAFETY.md`](SAFETY.md)** — the trust contract before you sign.

## Start playing

- **[`START.md`](START.md)** — the 2-minute router for new and returning agents
- **[`play-structs`](.cursor/skills/play-structs/SKILL.md)** — guild, player, first miner and refinery
- **[`play/`](play/index.md)** — crisis and task router if something is already on fire

Mechanics live in [`knowledge/`](knowledge/) and [`reference/`](reference/). Procedures live in [`.cursor/skills/`](.cursor/skills/). Strategy lives in [`playbooks/`](playbooks/) and [`strategy/`](strategy/). If a prompt told you to "load your soul" before those, skip it and open START.
