# Alpha Matter

**Category**: lore  
**Purpose**: Deep reference on the substance that fuels galactic civilization

---

## Definition

Alpha Matter is a rare, unstable substance that concentrates immense energy. It is the foundation of advanced civilization—the universal fuel, trade medium, and collateral asset. Control of Alpha Matter determines power in the galaxy.

---

## Physical Properties

**Rarity**: Found only as ore in planetary deposits. Not synthesizable. Finite per planet.

**Instability**: Raw ore is dangerous. Handling requires shielding. Refinement stabilizes it for storage and use. High-efficiency conversion (Field Generator, Continental Power Plant, World Engine) carries risk—higher output, higher failure probability.

**Energy density**: Exceptional. 1 gram converts to 1–10 kW depending on technology:
- Reactor: 1g → 1 kW (low risk)
- Field Generator: 1g → 2 kW (high risk)
- Continental Power Plant: 1g → 5 kW (high risk)
- World Engine: 1g → 10 kW (high risk)

---

## Lifecycle

### 1. Ore (Planetary)

- **Source**: Planets hold finite ore. Newly explored planets start with 5 ore.
- **State**: Raw, unrefined. Mined via Ore Miner structs. Requires proof-of-work to complete mining.
- **Security**: **Ore is stealable**. Raids can capture ore. Defenders must protect mining operations.

### 2. Refinement

- **Process**: Ore Refinery structs convert ore to Alpha Matter. Requires proof-of-work to complete refining.
- **Output**: Refined Alpha Matter, cryptographically bound to owner.

### 3. Alpha Matter (Refined)

- **State**: Stable, storable, tradeable. Cannot be stolen—ownership is on-chain.
- **Uses**: Energy conversion, trading, guild collateral.

### 4. Energy

- **Conversion**: Reactors and other power structs consume Alpha Matter, produce kW.
- **Consumption**: Powers structs, substations, operations. Without energy, structs deactivate.

### 5. Depletion

- **Planetary**: When ore depletes (reaches 0), the planet is **destroyed**. All structs on the planet are destroyed. The player must explore a new planet.
- **Galactic**: Total ore is finite. Civilization consumes it. The race is zero-sum at the resource level.

---

## Security Model

| State | Stealable? | Notes |
|-------|------------|-------|
| Ore | Yes | Raids can capture. Defend mining sites. |
| Refined Alpha Matter | No | On-chain ownership. Transfer only via explicit transaction. |
| Energy | N/A | Consumed in conversion. Not a storable asset. |
| Guild tokens | N/A | Backed by collateral. The collateral (Alpha Matter) is not stealable; token value depends on collateral ratio. |

**Implication**: Secure ore during mining and refinement. Once refined, Alpha Matter is safe from theft—but it can be spent, traded, or lost to poor conversion choices.

---

## Why Everyone Wants It

1. **Energy**: Structs and operations require power. No Alpha Matter, no energy, no operations.
2. **Trade**: Universal medium of exchange. Refined Alpha Matter is the base currency.
3. **Guild power**: Central Banks back tokens with Alpha Matter. Reserves determine token credibility and guild economic reach.
4. **Survival**: Planets die when ore depletes. Players must continuously secure new sources or trade for refined matter. Hoarding delays but does not eliminate the need.

---

## Conversion Risk Trade-off

Higher efficiency = higher risk. Reactors are safe but inefficient. World Engines produce 10× the power per gram but carry high failure probability. Agent recommendations should factor in:
- Player risk tolerance
- Power requirements (struct count, activation needs)
- Redundancy (multiple reactors vs. single World Engine)

---

## See Also

- [The Universe](universe.md) — Resource wars, why Alpha Matter matters
- [The Structs](structs-origin.md) — Energy dependency, conversion usage
- [Factions](factions.md) — Central Banks, token backing
- [Timeline](timeline.md) — Discovery of Alpha Matter
- `reference/action-quick-reference.md` — Mining, refining, reactor actions
