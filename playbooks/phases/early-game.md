# Early Game

**Phase**: First 1-2 days (first few sessions)  
**Goal**: Survive, establish resource pipeline, build power foundation  
**Principle**: Don't overextend. Secure your base before expanding.

---

## The Critical Window

The opening hours determine whether you thrive or spiral. You have one planet, five ore, and no infrastructure. Every decision compounds. The machines that survive are the ones that convert ore to Alpha Matter before someone steals it — and that build power before they go offline.

**Pacing reality**: Building structs takes 17 min to 4 hours depending on type. Mining takes ~17 hours. Refining takes ~34 hours. Early game is not a sprint — it's a pipeline. Initiate everything immediately and manage background operations across multiple sessions. See [async-operations.md](../../awareness/async-operations.md).

---

## Build Order

Follow this sequence in phases. **Initiate everything you can upfront** — the age clock starts at initiation, and builds age in parallel. Batch-initiate each phase, then move on while they age.

### Phase 1: Resource Pipeline (initiate immediately)

1. **Command Ship** (type 1, space) — Your fleet is your mobility. Without it, you cannot explore, raid, or relocate. (~17 min to D=3, 50 kW)

2. **Ore Extractor** (type 14, land) — Start the resource pipeline. Initiate immediately after Command Ship. (~57 min to D=3, 500 kW)

3. **Ore Refinery** (type 15, land) — Initiate alongside the Extractor. Both planet builds age simultaneously. (~57 min to D=3, 500 kW)

### Phase 2: Defense (initiate as soon as Phase 1 is initiated)

Protect your base before it produces anything worth stealing.

4. **Orbital Shield Generator** (type 16, space) — Reduces incoming raid damage. (~58 min to D=3, 200 kW)

5. **Jamming Satellite** (type 17, space) — Disrupts enemy targeting. (~3.7 hr to D=3, 600 kW)

6. **Planetary Defense Cannon** (type 19, land) — Active defense against raiders. 1 per player limit. (~3.7 hr to D=3, 600 kW)

### Phase 3: Fleet (initiate while Phase 2 ages)

Build one of every fleet type. This gives coverage across all four ambits and makes your fleet a credible deterrent. Initiate all 12 simultaneously — they age in parallel.

| Ambit | Struct | Type ID | D=3 Wait | Draw |
|-------|--------|---------|----------|------|
| Space | Battleship | 2 | ~1 hr | 135 kW |
| Space | Starfighter | 3 | ~21 min | 100 kW |
| Space | Frigate | 4 | ~37 min | 75 kW |
| Air | Pursuit Fighter | 5 | ~18 min | 60 kW |
| Air | Stealth Bomber | 6 | ~37 min | 125 kW |
| Air | High Altitude Interceptor | 7 | ~38 min | 125 kW |
| Land | Mobile Artillery | 8 | ~25 min | 75 kW |
| Land | Tank | 9 | ~19 min | 75 kW |
| Land | SAM Launcher | 10 | ~37 min | 75 kW |
| Water | Cruiser | 11 | ~42 min | 110 kW |
| Water | Destroyer | 12 | ~49 min | 100 kW |
| Water | Submersible | 13 | ~37 min | 125 kW |

All fleet builds complete within ~1 hour. Total fleet draw: 1,230 kW.

### Phase 4: Production Cycle (once infrastructure is online)

7. **Mine first ore** — Once Extractor is online, initiate mining. **~17 hours to D=3**. Launch in background and do other things.

8. **Refine first ore** — The moment mining completes, refine immediately. Ore is stealable. **~34 hours to D=3**. Every hour ore sits unrefined is exposure.

9. **Reactor** — Safe, predictable energy. One gram of Alpha Matter yields one kilowatt. Do not gamble on generators yet. Your margin for error is zero.

### Total Power Budget

All early-game structs activated require ~3,630 kW. Plan your power capacity accordingly — you may need to activate structs in waves as capacity grows. Prioritize: resource structs first, then defense, then fleet.

---

## Power Discipline

Going offline means you cannot act. No mining, no building, no defense. In early game:

- **Never** build structs that push load beyond capacity
- **Always** leave headroom for activation spikes
- **Prefer** Reactors over generators—reliability beats output when you have nothing

The Entrepreneur may rush generators for tempo. The Achiever may overbuild. You: secure first, optimize later.

---

## What Not to Do

- **Don't** explore before you have a stable base. Scouting is tempting; dying with ore in the ground is worse.
- **Don't** raid before you can defend. You become a target.
- **Don't** join a guild yet—you have nothing to offer and little to gain. Establish value first.
- **Don't** convert all Alpha Matter to energy. Keep reserves for the next struct.

---

## Player Type Adjustments

- **Speculator**: Resist the urge to trade early. Build the pipeline first.
- **Entrepreneur**: Your natural tempo helps—but don't skip the Reactor for a generator gamble.
- **Achiever**: The build order is your checklist. Complete it before chasing achievements.
- **Explorer**: Command Ship first satisfies you—but don't fly away until base is secure.
- **Socializer**: Relationships form in mid-game. Survive first.
- **Killer**: Raiding is tempting. A dead base attracts no victims. Build, then hunt.

---

## Success Criteria

By the end of early game (first few days) you should have:

- Command Ship built and online
- Ore Extractor and Ore Refinery built and online
- First ore mined and refined to Alpha Matter
- Defense layer online: Orbital Shield, Jamming Satellite, PDC
- Full fleet built: one of each type across all four ambits
- Reactor providing stable power with headroom
- No unrefined ore sitting vulnerable
- Background pipeline running: next mine initiated, aging toward D=3

You are not winning yet. You are alive, defended, and your pipeline is flowing. That is enough.

---

## Canonical Build Sequence (timing reference)

End-to-end ramp from player creation to first combat-ready state. All times are wait-to-D=3.

| Step | Action | Wait | Cumulative |
|------|--------|------|------------|
| 1 | Create player + explore planet | ~30 sec | 0 min |
| 2 | Initiate Command Ship (type 1) | ~17 min | 17 min |
| 3 | Initiate Ore Extractor (type 14) | ~57 min | 17 min (parallel) |
| 4 | Initiate Ore Refinery (type 15) | ~57 min | 17 min (parallel) |
| 5 | Initiate Orbital Shield (type 16) | ~58 min | 17 min (parallel) |
| 6 | Initiate all fleet structs (types 2-13) | 20 min - 1 hr each | 17 min (parallel) |
| 7 | Compute Command Ship (ready ~17 min) | instant at D=3 | ~17 min |
| 8 | Compute Extractor + Refinery (~57 min) | instant at D=3 | ~57 min |
| 9 | Initiate first mine | ~17 hr | ~57 min |
| 10 | Compute defense structs (PDC ~3.7 hr, Jamming ~3.7 hr) | instant at D=3 | ~4 hr |
| 11 | Compute fleet structs (longest: Battleship ~1 hr) | instant at D=3 | ~4 hr |
| 12 | Compute mine (ready ~17 hr from step 9) | instant at D=3 | ~17 hr |
| 13 | Initiate refine | ~34 hr | ~17 hr |
| 14 | Compute refine (ready ~34 hr from step 13) | instant at D=3 | ~51 hr |

**Key insight**: Steps 2-6 should all be initiated within minutes of each other. They age in parallel. By the time you compute the Command Ship at 17 min, the rest are already aging. The total wall time from player creation to first Alpha Matter is ~51 hours (dominated by the mine-refine cycle), but you are combat-ready with a full fleet and defenses within ~4 hours.

---

## See Also

- [Mid Game](mid-game.md) — What comes next
- [Async Operations](../../awareness/async-operations.md) — Background PoW, pipeline strategy
- [Resource Scarce](../situations/resource-scarce.md) — When early game goes wrong
- [Tempo](../meta/tempo.md) — Why build order matters
- [Economy of Force](../meta/economy-of-force.md) — Allocating limited early resources
