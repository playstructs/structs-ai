---
name: structs-mining
description: Executes resource extraction in Structs. Mines ore and refines immediately to prevent theft. Use when extracting resources from planets.
---

# Structs Mining

## Procedure

1. **Check planet ore** — `structsd query structs planet [id]`. If `currentOre == 0`, explore new planet first.
2. **Mine ore** — `structsd tx structs struct-ore-mine-compute [struct-id] -D 5 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Mining difficulty is 14,000; with `-D 5` expect ~15-30 minutes. Compute auto-submits the complete transaction.
3. **Refine immediately** — Ore is stealable. `structsd tx structs struct-ore-refine-compute [struct-id] -D 5 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Refining difficulty is 28,000; with `-D 5` expect ~30-45 minutes. Compute auto-submits the complete transaction.
4. **Store or convert** — Alpha Matter is not stealable. Use reactor (1g = 1 kW) or generator infusion as needed.
5. **Verify** — Query planet (ore decreased), struct (ore/Alpha state), player (resources).

**CRITICAL**: Ore is stealable. Alpha Matter is not. Always refine immediately after mining.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Mine compute (PoW + auto-complete) | `structsd tx structs struct-ore-mine-compute [struct-id] -D 5` |
| Mine complete (manual, rarely needed) | `structsd tx structs struct-ore-mine-complete [struct-id]` |
| Refine compute (PoW + auto-complete) | `structsd tx structs struct-ore-refine-compute [struct-id] -D 5` |
| Refine complete (manual, rarely needed) | `structsd tx structs struct-ore-refine-complete [struct-id]` |
| Query planet | `structsd query structs planet [id]` |
| Query struct | `structsd query structs struct [id]` |
| Query player | `structsd query structs player [id]` |

Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Verification

- Planet `currentOre` decreases after mine-complete
- Struct ore inventory clears after refine-complete
- Player Alpha Matter increases after refine-complete

## Error Handling

- **"struct offline"** — Activate struct before mining.
- **"insufficient ore"** — Planet depleted or struct has no ore; check planet `currentOre`.
- **"proof invalid"** — Re-run compute with correct difficulty; ensure no interruption.
- **Ore stolen** — Refine immediately after every mine. Never leave ore unrefined.

## Timing

Compute commands use the `-D` flag (range 1-64) to wait until difficulty drops to the target level. Lower `-D` = longer wait but faster hash. Compute auto-submits the complete transaction.

| Operation | Difficulty | `-D 5` Approx Time |
|-----------|------------|---------------------|
| Mine | 14,000 | ~15-30 min |
| Refine | 28,000 | ~30-45 min |
| Full cycle (mine + refine) | -- | ~45-75 min |

## See Also

- `knowledge/mechanics/resources.md`
- `knowledge/mechanics/planet.md`
- `knowledge/lore/alpha-matter.md`
