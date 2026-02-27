# Resource Mechanics

**Purpose**: AI-readable reference for Structs resources. Types, flows, conversion rates, security model.

---

## Resource Types

| Resource | Unit | Stealable | Refinement | Location |
|----------|------|-----------|------------|----------|
| Alpha Ore (unmined) | grams | No | Required | Planet (`remainingOre`) — extracted by Ore Extractor |
| Alpha Ore (mined) | grams | **Yes** | Required | Player inventory (`storedOre`) — stolen in raids |
| Alpha Matter | grams | No | Output | Player inventory (on-chain) |
| Energy | Watts | N/A | N/A | Ephemeral, shared across structs |

---

## Alpha Ore

- Mined from planets via Ore Extractor
- Stored in the player's `gridAttributes.ore` field (also referred to as `storedOre`). This is NOT the bank balance — bank balance holds only refined Alpha Matter (`ualpha`). Query `gridAttributes.ore` to check unrefined ore holdings.
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
| Reactor | 1g = 1 kW | Low |
| Field Generator | 1g = 2 kW | High |
| Continental Power Plant | 1g = 5 kW | High |
| World Engine | 1g = 10 kW | High |

---

## Proof-of-Work Difficulties

| Operation | Difficulty | Time to D=3 |
|-----------|------------|-------------|
| Ore mining | 14,000 | ~17 hr |
| Ore refining | 28,000 | ~34 hr |

Mining is roughly twice as fast as refining. A full mine-refine cycle takes ~51 hours at D=3. These are background operations — see [async-operations.md](../../awareness/async-operations.md). Use `-D 3` for zero wasted CPU.

---

## The Ore Vulnerability Window

After mining completes, ore moves from the planet's `remainingOre` to the player's `storedOre` — and becomes stealable by any raider. A single successful raid seizes **all** of the player's mined ore — not a percentage, everything. It stays vulnerable for the entire duration of the refining PoW. At D=3 (recommended), this window is **~34 hours**. Unmined ore on the planet is NOT at risk; only the player's mined `storedOre` can be seized.

This vulnerability window is the primary driver of PvP conflict in Structs. Raiders time their attacks for when targets have unrefined ore. Defenders must manage this tension:

| Strategy | Trade-off |
|----------|-----------|
| Refine at D=3 | ~34 hr exposure, zero CPU wasted on hashing |
| Refine at D=8 (start sooner) | ~15 hr exposure, but burns CPU on harder hashes |
| Shield + stealth during refine | Reduces raid success, costs power |
| Refine during off-hours | Other players may be inactive, lower raid risk |
| Small frequent mines | Less ore exposed per window, but more total cycles |

**The optimal play**: Mine and immediately start refining. Use shields and defense structs to protect during the window. The player who minimizes ore exposure time while maintaining production throughput wins the resource game.

---

## Security Model

| State | Location | Stealable | Action |
|-------|----------|-----------|--------|
| Unmined ore (`remainingOre`) | Planet | No | Mine with Ore Extractor → moves to player `storedOre` |
| Mined ore (`storedOre`) | Player | **Yes** | Refine immediately — this is what raiders steal |
| Alpha Matter | Player | No | Secure — cryptographically bound to owner |

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
