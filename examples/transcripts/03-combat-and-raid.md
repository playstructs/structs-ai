---
title: "Transcript 03 — Combat and Raid"
---

# Transcript 03 — Combat and Raid

**Goal**: Clear a vulnerable planet's defenders and complete a raid, applying the combat levers that actually decide the fight.
**Skills**: [structs-intel](../../.cursor/skills/structs-intel/SKILL.md), [structs-combat](../../.cursor/skills/structs-combat/SKILL.md), [structs-streaming](../../.cursor/skills/structs-streaming/SKILL.md).
**Why it's "golden"**: the agent picks **attacking ambits that take zero counter damage**, matches **weapon control to enemy defense** (unguided vs Signal Jamming), respects the **per-player charge bar**, reads the **numeric struct status** to confirm kills, knows the live `struct_attack` payload is **stubbed** (so it watches effect events instead), and completes the raid while keeping its **own Command Ship safe** from `attackerDefeated`.

This builds on [Transcript 02 — Raid Go/No-Go](02-raid-go-no-go.md): there the agent decided *whether* to raid. Here it executes one against an **offline** defender — the only reliably winnable case, because an offline owner cannot rebuild a downed Command Ship to re-raise shields.

---

**Agent:** A watch alert says owner `1-260`'s Command Ship dropped offline. Their planet `2-90` looked ore-rich. Scout before committing anything.

```bash
scripts/scout.sh 2-90
```

```
== Raid scout: planet 2-90 (Halide) ==
  owner                  1-260
  stealable ore          1240
  command ship           present=yes status=offline
  fleet                  onStation (away=no)
  shields vulnerable     yes
  defenders on planet     PDC (19), 2x Tank (9, land), Cruiser (11, water)
  verdict: GO (verify) — shields vulnerable, ore present — confirm you out-survive the defense
```

> The gate passes: their Command Ship is **offline**, so shields are vulnerable and — crucially — they **cannot rebuild it at the buzzer**. The clock (`blockStartRaid`) is already running. The risk is the defense whittling my fleet during the raid window. I don't need to destroy every defender, but I want to remove the ones that will hurt me, cheaply.

**Agent:** Map the defenders to my fleet before throwing a punch. My fleet `9-318`: a Battleship (space, **unguided** armour-piercing primary on land/water), a Stealth Bomber (air → land/water), and a Pursuit Fighter (air → air). Their defenders:

- **2× Tank** — land, **armour** (damage-reduction 1). They counter only what reaches their weapon's ambit (Tanks hit **land** only).
- **Cruiser** — water, **Signal Jamming** (evades **guided** weapons 66%).
- **PDC** — auto-fires at me after the volley resolves; I can't dodge it by ambit, only out-pace it.

> Two levers decide this:
> 1. **Counters are ambit-gated.** A Tank's weapon reaches land only, so if I hit it from **air**, it cannot counter — zero return damage. My Stealth Bomber (air) hits land. Free hits on the Tanks.
> 2. **Weapon control vs defense.** Their Cruiser has Signal Jamming, which eats **guided** shots. My Battleship primary is **unguided** — jamming does nothing to it. I never send a guided weapon at that Cruiser.

**Agent:** Strike the Tanks from the air first — armour reduces my 2-damage hits to 1, but I take **no counter** because they can't reach air. Tanks are 3 HP, so 3 hits each. I space the attacks: each primary costs charge from my **one shared per-player bar**, so I let it refill (~1/block) between shots rather than firing blind and failing on `insufficient charge`.

```bash
# Stealth Bomber (air) -> Tank #1 (land). Single target: the comma-list would NOT
# spread a single-target weapon, so I name one target per attack.
structsd tx structs struct-attack --from ferro --gas auto --gas-adjustment 1.5 -- 5-602 5-410 0
# wait ~one charge cycle, verify, repeat
```

> Attacking breaks my Stealth Bomber's stealth (firing reveals it) — expected; I'm committed to the engagement now. I confirm each hit by the **effect**, not by assuming the broadcast worked.

**Agent:** While I fight, I watch the planet subject on GRASS. Note: I do **not** rely on the `struct_attack` payload for the blow-by-blow — large combat detail is **stubbed** off the live stream. I read the **effect** events that always arrive in full.

```bash
node - <<'JS'
import { connect } from "nats.ws";
const nc = await connect({ servers: "ws://crew.oh.energy:1443" });
for await (const m of nc.subscribe("structs.planet.2-90")) {
  const e = JSON.parse(new TextDecoder().decode(m.data));
  if (e.stub) { console.log("(stubbed", e.category + " — pull planet_activity for detail)"); continue; }
  if (["struct_health","struct_status","raid_status","shield_change"].includes(e.category))
    console.log(e.category, JSON.stringify(e.detail ?? e));
}
JS
```

```
(stubbed struct_attack — pull planet_activity for detail)
struct_health {"struct_id":"5-410","health":2,"health_old":3}
(stubbed struct_attack — pull planet_activity for detail)
struct_health {"struct_id":"5-410","health":1,"health_old":2}
(stubbed struct_attack — pull planet_activity for detail)
struct_status {"struct_id":"5-410","status":35}
```

> There it is: the `struct_attack` rows come through **stubbed** (no shot detail), but `struct_health` tracks the Tank down 3→2→1, and finally `struct_status` reports **`35`** — that's `Materialized(1) + Built(2) + Destroyed(32)`, i.e. **destroyed**. If I needed the per-shot log (who countered, evasion causes) I'd pull the Guild API `planet-activity` row by `seq`; for combat tracking the effect events are enough. Tank #1 down, and I took zero counter damage doing it.

**Agent:** Repeat on Tank #2 from the air. Then the Cruiser (water, Signal Jamming) — I use the Battleship's **unguided** armour-piercing primary, which jamming can't evade and which ignores any reduction. The Battleship lives in space and reaches water, so the Cruiser (water weapon) *can* counter it; I accept that small return (counter values are tiny — a backstop, not a threat) because the unguided choice guarantees my damage lands.

```bash
structsd tx structs struct-attack --from ferro --gas auto --gas-adjustment 1.5 -- 5-601 5-412 0
```

> I leave the **PDC** alone — it's 6 HP and only auto-fires once per volley; out-pacing it costs less than the charge to kill it. I've removed the units that would chip my fleet across a multi-block raid.

**Agent:** Defenders handled. Now complete the raid. The clock has been aging since their Command Ship went offline, so the proof is cheap at `-D 3`. I move my fleet to the target (it's now `away` — which means **my own** planet's shields are down until it returns, so I refined my home ore before starting), verify on-station-at-target, then run the compute in the background.

```bash
structsd tx structs fleet-move --from ferro --gas auto --gas-adjustment 1.5 -- 9-318 2-90
structsd query structs fleet 9-318 -o json | jq '{status, locationId}'

nohup structsd tx structs planet-raid-compute -D 3 --from ferro --gas auto --gas-adjustment 1.5 -y -- 9-318 \
  > memory/jobs/raid-9-318.log 2>&1 & echo $! > memory/jobs/raid-9-318.pid
```

> **Guard my own Command Ship.** `trigger_raid_defeat_by_destruction` lives on the Command Ship: if **my** CMD is destroyed while away, my fleet is defeated (`attackerDefeated`) and sent home empty. My CMD has defenders assigned across ambits for counter coverage and is not exposed alone. Their owner is offline, so there's no live counter-raid — but I keep `watch-defense` running in case they wake up.

**Agent:** Verify the outcome — broadcast is not success.

```bash
structsd query structs planet 2-90 -o json | jq '{raid_status, seized_ore}'
```

```
{ "raid_status": "raidSuccessful", "seized_ore": 1240 }
```

> `raidSuccessful`, 1240 ore seized — all of their `storedOre` (a raid takes everything, never a share). Now the ore is in **my** hands and stealable, so I move home and refine it immediately. Note what the raid did and did **not** do: it took the ore. It did **not** destroy the player or their structs — there is no player-elimination outcome.

```bash
structsd tx structs fleet-move --from ferro --gas auto --gas-adjustment 1.5 -- 9-318 [home-location]
nohup structsd tx structs struct-ore-refine-compute -D 3 --from ferro --gas auto --gas-adjustment 1.5 -y -- [refinery-id] \
  > memory/jobs/refine-postraid.log 2>&1 &
```

---

## What made this good

- **Picked counter-free ambits.** Hitting the land Tanks from the **air** drew **zero** counter damage — the single biggest combat lever (counters are gated by whether the defender's weapon reaches the *attacker's* ambit).
- **Matched weapon control to defense.** Used an **unguided** weapon against the Signal-Jamming Cruiser; never wasted a guided shot into 66% evasion.
- **Respected the shared charge bar.** Spaced single-target attacks ~one charge cycle apart instead of firing into `insufficient charge` (charge cannot be banked or burst).
- **Read the numeric status.** `35` = destroyed (`1+2+32`), confirmed from the effect stream — not guessed.
- **Knew the stream's limits.** Treated `struct_attack` as **stubbed** and tracked combat via `struct_health` / `struct_status`, pulling `planet_activity` only if per-shot detail were needed.
- **Targeted an offline defender** — the only reliably winnable raid, because they can't rebuild a downed Command Ship — and **protected its own Command Ship** from `attackerDefeated`.
- **Verified, then secured the loot**: confirmed `raidSuccessful`, moved home, and refined the seized ore before it could be raided back.
