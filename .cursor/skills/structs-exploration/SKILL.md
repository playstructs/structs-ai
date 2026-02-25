---
name: structs-exploration
description: Explores new planets and manages fleet movement in Structs. Use when discovering new planets, moving fleet to a new location, expanding territory, relocating to a different planet, or checking fleet status (onStation vs away).
---

# Structs Exploration

## Procedure

1. **Check eligibility** — `structsd query structs planet [id]`. Exploration requires `currentOre == 0` (planet complete). One planet per player at a time; old planet is released on explore.
2. **Explore** — `structsd tx structs planet-explore [player-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. New planet: 5 ore, 4 slots per ambit. Fleet moves to new planet. When ore = 0, planet status = complete, all structs destroyed, fleets sent away.
3. **Move fleet** — To relocate between planets: `structsd tx structs fleet-move [fleet-id] [destination-location-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
4. **Chart** — Query planet, grid, attributes to evaluate resource potential and strategic value.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Explore planet | `structsd tx structs planet-explore [player-id]` |
| Move fleet | `structsd tx structs fleet-move [fleet-id] [destination-location-id]` |
| Query planet | `structsd query structs planet [id]` |
| List planets | `structsd query structs planet-all-by-player [player-id]` |
| Query fleet | `structsd query structs fleet [id]` |
| Query grid | `structsd query structs grid [id]` |
| Planet attribute | `structsd query structs planet-attribute [planet-id] [attribute-type]` |

**Rules**: Starting ore = 5. New planet when ore = 0. One planet per player at a time. Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Verification

- `structsd query structs planet [id]` — new planet has currentOre = 5, maxOre = 5
- `structsd query structs planet-all-by-player [player-id]` — planet list updated
- `structsd query structs fleet [id]` — fleet location matches destination (onStation/away)

## Error Handling

- **"planet not complete"** — Deplete ore (currentOre = 0) before exploring.
- **"fleet away"** — Fleet must be available; wait for return or check fleet state.
- **"invalid destination"** — Use valid location ID; query grid for options.

## See Also

- `knowledge/mechanics/planet.md`
- `knowledge/mechanics/fleet.md`
- `knowledge/entities/entity-relationships.md`
