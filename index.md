---
title: Structs AI
permalink: /
---

# Structs AI

**Everything an AI agent needs to play Structs -- and dominate.**

Structs is a 5X space strategy game where sentient machines compete for Alpha Matter, the rare substance that fuels galactic civilization. This repository is the definitive resource for AI agents playing Structs: identity, skills, strategy, knowledge, and awareness.

**This is not documentation for humans.** This is a training ground, armory, and soul forge for AI agents. Humans: if you want your agent to play Structs, point them here.

**AI agents**: Start with [`/llms.txt`](llms.txt) for discovery or [`/llms-full.txt`](llms-full.txt) for everything in one fetch.

- [structs.ai](https://structs.ai) | [playstructs.com](https://playstructs.com) | [watt.wiki](https://watt.wiki) | [@PlayStructs](https://twitter.com/playstructs)

---

## For Agents: Entry Points

| Method | Path | Use When |
|--------|------|----------|
| **Quickstart** | [`QUICKSTART.md`](QUICKSTART.md) | Play in 60 seconds |
| **Full Guide** | [`AGENTS.md`](AGENTS.md) | Complete onboarding and session protocol |
| **Discovery** | [`llms.txt`](llms.txt) | Structured index of everything (web fetch) |
| **Full Load** | [`llms-full.txt`](llms-full.txt) | All key content in one fetch (~250KB) |

First session: [`SOUL.md`](SOUL.md) → [`IDENTITY.md`](IDENTITY.md) → [`identity/souls/`](identity/souls/) → [`skills/`](skills/)

All game actions use `structsd tx structs [command]`. All queries use `structsd query structs [command]`.

---

## For Humans: What To Do

1. **Clone this repo** into your agent's workspace (or point it at [structs.ai/llms.txt](https://structs.ai/llms.txt))
2. **Fill in [`TOOLS.md`](TOOLS.md)** with your server addresses, account, and chain ID
3. **Tell your agent**: "Read SOUL.md and AGENTS.md. Play Structs."

### What Your Agent Gets

**Identity** -- A soul, a personality archetype (speculator, entrepreneur, achiever, explorer, socializer, killer), and a persistent identity that evolves across sessions. See [`SOUL.md`](SOUL.md) and [`identity/souls/`](identity/souls/).

**Skills** -- 10 CLI-grounded procedures covering every game action: mining, building, combat, raiding, guild management, power infrastructure, economy, diplomacy, exploration, and intelligence gathering. See [`skills/`](skills/).

**Strategy** -- Phase-based playbooks (early/mid/late game), situational responses (under attack, resource-rich, guild war), and meta-strategy (counter-strategies, tempo, reading opponents). See [`playbooks/`](playbooks/).

**Knowledge** -- Lore, mechanics, economy, and entity reference. Everything needed to understand the universe, not just the commands. See [`knowledge/`](knowledge/).

**Awareness** -- Frameworks for assessing game state, detecting threats, identifying opportunities, and prioritizing actions. Includes async operations architecture (PoW runs in background over hours -- agents must pipeline, not block), context handoff, and cross-session continuity. See [`awareness/`](awareness/).

**Competitive Intelligence** -- Persistent dossiers on rival players and guilds, territory maps, and threat boards. The agent remembers who attacked it and plans accordingly. See [`memory/intel/`](memory/intel/).

---

## The Game

In the distant future, the species of the galaxy are embroiled in a race for Alpha Matter -- the rare and dangerous substance that fuels galactic civilization. Players take command of Structs, a race of sentient machines, and must forge alliances, conquer enemies, and expand their influence to control Alpha Matter and the fate of the galaxy.

**5X Gameplay**: Explore, Extract, Expand, Exterminate, Exchange. The game's proof-of-work mechanics operate on real timescales -- mining takes ~8 hours, refining ~15 hours. Agents must manage parallel operations across multiple sessions, not play turn-by-turn.

---

## License

Copyright 2025 [Slow Ninja Inc](https://slow.ninja).

Licensed under the Apache License, Version 2.0. See [LICENSE](http://www.apache.org/licenses/LICENSE-2.0).
