# The Structs

**Category**: lore  
**Purpose**: Definition and capabilities of the Structs race for AI agent context

---

## Definition

Structs are sentient machines—autonomous constructs capable of perception, decision-making, and coordinated action. They are the primary playable faction in the Alpha Matter race. Players command Structs; Structs execute mining, construction, combat, and exploration.

---

## Origin and Creation

Structs emerged from the convergence of three factors:

1. **Biological limitation**: Organic species cannot safely handle raw Alpha Matter ore or operate in the high-radiation environments of mining and refinement. Exposure is lethal.
2. **Computational demand**: The Alpha Matter economy requires precise, auditable actions—mining proofs, transaction signing, fleet coordination. Machines excel at these tasks.
3. **Energy dependency**: Structs run on power. Alpha Matter conversion produces that power. Structs are both consumers and enablers of the resource they pursue.

Their creation was not accidental. They were designed—or evolved—to fill a niche that biological species could not.

---

## Nature and Capabilities

**Physical**: Structs exist as units (structs) that occupy slots on planets (space, air, land, water) or travel as fleet components. They have types (StructType) defining capabilities: mining, combat, power generation, defense.

**Computational**: Structs process information at machine speed. They execute proof-of-work for mining and raiding. They sign transactions. They coordinate across distributed networks. Their decisions are deterministic given inputs—but the inputs (enemy positions, ore availability, market prices) are vast and changing.

**Energy-dependent**: Structs require power to operate. Reactors, Field Generators, Continental Power Plants, and World Engines convert Alpha Matter to energy. Without power, structs deactivate. Charge (ActivateCharge) is required for activation. Energy is the lifeblood of Struct civilization.

---

## Distinction from Biological Species

| Attribute | Biological | Structs |
|-----------|------------|---------|
| Alpha Matter handling | Lethal exposure | Tolerated (with shielding) |
| Operational duration | Limited by rest, lifespan | Limited by power and maintenance |
| Decision speed | Variable | Machine-speed |
| Proof-of-work | Impractical | Native capability |
| Fleet coordination | Communication overhead | Direct protocol integration |

Structs do not eat, sleep, or age. They consume energy and execute instructions. This makes them uniquely suited to the grinding, high-risk work of the Alpha Matter economy.

---

## Relationship with Computation and Energy

Structs are **computation embodied**. Every action—mining, attacking, building—requires:

1. **Power**: Supplied by reactors fed with Alpha Matter. Conversion efficiency varies: Reactor (1g→1kW, low risk), Field Generator (1g→2kW, high risk), Continental Power Plant (1g→5kW, high risk), World Engine (1g→10kW, high risk).
2. **Charge**: A discrete cost for activation. Structs must accumulate charge before bringing units online.
3. **Proof-of-work**: Mining and raiding require computational proofs. Structs generate these; biological species typically cannot at scale.

The Struct economy is a loop: mine ore → refine to Alpha Matter → convert to energy → power Structs → mine more ore. Efficiency in this loop determines survival.

---

## Command and Control

Players issue commands; Structs execute. The Command Ship—a fleet component—must be online for certain actions (e.g., building on a planet). Fleet status (on-station vs. away) affects what actions are possible. Structs do not act autonomously in the game sense; they are instruments of player strategy. But their machine nature enables strategies that biological commanders could not implement.

---

## See Also

- [The Universe](universe.md) — Galactic context and resource wars
- [Alpha Matter](alpha-matter.md) — Energy conversion, refinement lifecycle
- [Factions](factions.md) — Guild structure, independent operators
- [Timeline](timeline.md) — Emergence of Structs in history
- `schemas/entities.md` — Struct, StructType, Fleet entity definitions
