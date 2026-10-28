---
description: "Ore, Alpha Matter, and energy: resource types, how they flow, conversion rates, proof-of-work difficulties, and the security model."
---

# Resource Mechanics

**Purpose**: AI-readable reference for Structs resources. Types, flows, conversion rates, security model.

---

## Resource Types

| Resource | Unit | Stealable | Refinement | Location |
|----------|------|-----------|------------|----------|
| Alpha Ore (unmined) | grams | No | Required | Planet — `buriedOre` (`BuriedOreAttributeId`); extracted by Ore Extractor |
| Alpha Ore (mined) | grams | **Yes** | Required | Player — `storedOre` (`StoredOreAttributeId`); stolen in raids |
| Alpha Matter | grams | No | Output | The owner's **vault** (`ualpha`; read as `playerInventory.rocks` or `bank balances [vault-address]`) |
| Energy | Watts | N/A | N/A | Ephemeral, shared across structs |

These are **different attribute ids on different objects**. LCD/query payloads often expose both as `gridAttributes.ore`. The planet's `ore` and the player's `ore` are not the same field even though they share a display name. A raider checking loot must read the **player** field (`storedOre` / `StoredOreAttributeId`).

---

## Alpha Ore

- Mined from planets via Ore Extractor
- Stored as `storedOre` (`StoredOreAttributeId`) on the **player** object. Player queries still label this `gridAttributes.ore` — that is not the planet's buried ore, and it is not the bank balance (`ualpha`). Query the **player** to check stealable holdings.
- Must be refined to Alpha Matter before secure use
- **Extraction rate**: 1 ore per mining operation (fixed)
- **Planet starting ore**: 5 (fixed for all planets)

---

## Alpha Matter

- Refined from Alpha Ore (1:1 conversion)
- **On-chain**: 1 gram = 1,000,000 micrograms (ualpha)
- Cannot be stolen
- Uses: energy production, trading, guild collateral

---

## Conversion Rates

### Ore → Alpha Matter

| Input | Output |
|-------|--------|
| 1 ore | 1,000,000 micrograms (1 gram) Alpha Matter |

### Alpha Matter → Energy

| Facility | Rate | Risk |
|----------|------|------|
| Reactor | 1g = 1 kW before commission (~96% to you) plus a diversity bonus of up to +50% when stake is spread across 10+ reactors | Low |
| Field Generator | 1g = 2 kW | High |
| Continental Power Plant | 1g = 5 kW | High |
| World Engine | 1g = 10 kW | High |

---

## Proof-of-Work Difficulties

| Operation | Difficulty | Time to D=3 |
|-----------|------------|-------------|
| Ore mining | 14,000 | ~17 hr |
| Ore refining | 28,000 | ~34 hr |

Mining is roughly twice as fast as refining. **Do not add the durations by default:** a refinery may age and compute with 0 stored ore because ore is checked at completion. Starting fresh mine and refine jobs together produces the first Alpha in ~34 hours at D=3, not ~51; the serial “mine, then start refine” path takes ~51 hours and needlessly lengthens exposure. These are background operations — see [async-operations.md](../../awareness/async-operations.md). Use `-D 3` for zero wasted CPU.

---

## The Ore Vulnerability Window

After mining completes, ore moves from the planet's `buriedOre` (`BuriedOreAttributeId`) to the player's `storedOre` (`StoredOreAttributeId`) — and becomes stealable by any raider. A single successful raid seizes **all** of the player's mined ore — not a percentage, everything. There is no partial-loot and no refund path — settlement is atomic at `MsgPlanetRaidComplete`. The amount is whatever the player's `storedOre` holds at that moment; "refine promptly" is a defender incentive, not a guarantee. It stays stealable until a refinement completion consumes it. If refinement starts only after mining lands, that is the full **~34-hour** D=3 refine wait. If fresh mine and refine jobs start together, the refine clock has already aged for ~17 hours when mining lands, so the usual first-cycle exposure is roughly the remaining **~17 hours**. Exact exposure is `refine completion time − mine completion time`, not a fixed constant. Unmined ore on the planet is NOT at risk; only the player's mined `storedOre` can be seized.

This vulnerability window is the primary driver of PvP conflict in Structs. Raiders time their attacks for when targets have unrefined ore. Defenders must manage this tension:

| Strategy | Trade-off |
|----------|-----------|
| Start refine only after mine, at D=3 | ~34 hr exposure; avoid this serial path |
| Start fresh mine + refine together, at D=3 | Usually ~17 hr exposure, zero CPU wasted on hashing |
| Use a higher refine `-D` target | Earlier completion and less exposure, but more CPU work |
| Raise planetary shield (bunkers/OSG) while holding ore | Slows raid PoW if already vulnerable; does not vault ore or shrink loot |
| Refine during off-hours | Other players may be inactive, lower raid risk |
| Small frequent mines | Less ore exposed per window, but more total cycles |

**The optimal play**: Keep the refinery aging in parallel with the mine; it may run with 0 ore because the ore check happens at completion. Ensure the refine completion is expected after the mine completion, then protect the remaining exposure window with Command Ship/fleet posture and defenses. The player who minimizes ore exposure time while maintaining production throughput wins the resource game.

---

## Security Model

| State | Location | Stealable | Action |
|-------|----------|-----------|--------|
| Unmined ore (`buriedOre` / `BuriedOreAttributeId`) | Planet | No | Mine with Ore Extractor → moves to player `storedOre` |
| Mined ore (`storedOre` / `StoredOreAttributeId`) | Player | **Yes** | Refine immediately — this is what raiders steal |
| Alpha Matter | Owner's vault | No | Secure — refined Alpha is deposited in the player vault, which raids cannot touch; spend it from there (infusions, agreements, guild founding) or `player-send` it to a key |

**Strategy**: Refine ore as soon as mined to minimize raid exposure. Maintain a 20-30% Alpha Matter reserve for emergencies.

**Progress pausing**: If an Ore Extractor or Refinery is destroyed, mining/refining progress pauses until the struct is rebuilt. Ore already mined or refined is not lost.

---

## Energy (Watts)

- Ephemeral: must be consumed on production
- Shared across connected structs
- Produced from Alpha Matter via Reactor or Generators
- Measured in milliwatts (1 W = 1,000 mW) for capacity/load

---

## See Also

- [combat.md](combat.md) — Raid loot (unrefined ore only)
- [power.md](power.md) — Energy consumption
- [planet.md](planet.md) — Ore depletion, planet destruction
- `schemas/economics.md` — Economic entity definitions
- `schemas/formulas.md` — Ore mining/refining formulas
- `reference/action-quick-reference.md` — Mining/refining actions
