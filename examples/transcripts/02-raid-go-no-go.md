---
title: "Transcript 02 — Raid Go/No-Go"
---

# Transcript 02 — Raid Go/No-Go

**Goal**: Decide whether to raid a neighbor's planet for ore.
**Skills**: [structs-intel](../../.cursor/skills/structs-intel/SKILL.md), [structs-combat](../../.cursor/skills/structs-combat/SKILL.md).
**Why it's "golden"**: the agent scouts before committing hours of proof-of-work, applies the shield-vulnerability gate, does the target economics, and **walks away** when the numbers don't work — discipline, not reflex.

---

**Agent:** A neighbor, planet `2-117`, looked ore-rich yesterday. Before I spend ~hours of raid proof-of-work, I scout. Queries are free; raids are not.

```bash
scripts/scout.sh 2-117
```

```
== Raid scout: planet 2-117 (Cinder) ==
  owner                  1-204
  stealable ore          900
  command ship           present=yes status=online
  fleet                  onStation (away=no)
  shields vulnerable     no
  defenders on planet    3
  verdict: NO-GO — fleet on station with Command Ship online — shields up, raid cannot complete
```

> The gate fails immediately. A raid can only **complete** while the owner's shields are vulnerable — their fleet off-station, or their Command Ship offline/destroyed. Owner `1-204`'s fleet is on station with the Command Ship online, so no amount of damage to planetary structs lets the raid finish. **No-go.** I don't launch anything — that would burn proof-of-work for nothing.

**Agent:** Is there a cheaper path to make them vulnerable? Their shields drop if their Command Ship goes offline (e.g. power starvation) or is destroyed, or if they send their own fleet off-station. Destroying a Command Ship in the fleet means winning a fleet engagement first — a much bigger commitment than this 900 ore justifies. I'll instead **watch** for them to slip up, cheaply.

```bash
node scripts/watch-defense.mjs structs.player.0-1.1-204 structs.planet.2-117
```

> This alerts me if their Command Ship ever drops offline. If it does and the ore is still there, the math changes and I re-scout. Until then, my proof-of-work is better spent mining my own planet.

*(later — an alert fires)*

```
{"level":"CRITICAL","subject":"structs.player.0-1.1-204","category":"struct_status","event":{"id":"5-7001","type":1,"status":"offline"}}
```

> Their Command Ship went offline (probably power overload). Re-scout *now* — state is fresh for only as long as it stays offline.

```bash
scripts/scout.sh 2-117
```

```
  stealable ore          900
  command ship           present=yes status=offline
  fleet                  onStation (away=no)
  shields vulnerable     yes
  defenders on planet    3
  verdict: GO (verify) — shields vulnerable and ore present — confirm you out-damage 3 defender(s)
```

**Agent:** Gate passes. Now the economics. I check that my fleet out-damages their defense within the window, and that the reward beats my cost.

```bash
structsd query structs struct-all-by-planet 2-117 -o json | jq '.. | objects | select(.id) | {id, type, ambit:.operatingAmbit}'
```

> Defenders: a Planetary Defense Cannon and two Tanks (Tanks have armour — damage-reduction 1). My raiding fleet has a Battleship (armour-piercing primary on land/water — it negates that Tank armour) plus two more units. I can clear or out-pace the defense before they likely restore power. Reward 900 ore vs. my raid proof-of-work cost and the risk of counter-fire: worth it.

> This is a Tier 1 combat action within standing orders. I move the fleet, then run the raid compute in the background.

```bash
structsd tx structs fleet-move --from ferro --gas auto --gas-adjustment 1.5 -- 9-318 2-117
# verify on-station before committing PoW
structsd query structs fleet 9-318 -o json | jq '{status, locationId}'

nohup structsd tx structs planet-raid-compute -D 3 --from ferro --gas auto --gas-adjustment 1.5 -y -- 2-117 \
  > memory/jobs/raid-2-117.log 2>&1 & echo $! > memory/jobs/raid-2-117.pid
```

> Logged the job and the intel. If their Command Ship comes back online before my proof lands, the completion will fail the shield check — so I keep `watch-defense` running and I'm ready to abort the expectation (and refine any seized ore the instant it arrives).

---

## What made this good

- **Scouted first** — one free query prevented hours of wasted proof-of-work.
- **Applied the shield-vulnerability gate correctly**: fleet on station with the Command Ship online → no completable raid, full stop.
- **Chose the cheap option** (watch + wait) over a disproportionate fleet war for modest ore.
- **Re-scouted on fresh signal** before committing, and only then did the **target economics** (armour-piercing vs. Tank armour, reward vs. cost).
- **Stayed disciplined**: an honest NO-GO is a win, not a failure.
