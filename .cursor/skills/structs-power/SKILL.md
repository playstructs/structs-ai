---
name: structs-power
description: Manages power infrastructure in Structs. Covers substations, allocations, player connections, and power monitoring. Use when power is low, building infrastructure, or managing energy distribution.
---

# Structs Power

## Procedure

1. **Assess power state** — Query player: `structsd query structs player [id]`. Compute: `availablePower = (capacity + capacitySecondary) - (load + structsLoad)`. If `load + structsLoad > capacity + capacitySecondary`, player goes **OFFLINE** (cannot act). Player passive draw: 25,000 mW.
2. **Create substation** — First create allocation from reactor/generator: `allocation-create [source-id] [power] --allocation-type static|dynamic|automated|provider-agreement TX_FLAGS`. Then: `structsd tx structs substation-create [owner-id] [allocation-id] TX_FLAGS`.
3. **Connect power** — `substation-allocation-connect [substation-id] [allocation-id]` to add source. `substation-allocation-disconnect` to remove.
4. **Connect players** — `substation-player-connect [substation-id] [player-id]` to draw power. `substation-player-disconnect` to remove.
5. **Migrate players** — `substation-player-migrate [source-substation-id] [dest-substation-id] [player-id,player-id2,...] TX_FLAGS`.
6. **Manage allocations** — Update: `allocation-update [allocation-id] [new-power]`. Delete: `allocation-delete [allocation-id]`.
7. **Delete substation** — `substation-delete [substation-id]` (disconnect allocations/players first).

## Commands Reference

| Action | Command |
|--------|---------|
| Substation create | `structsd tx structs substation-create [owner-id] [allocation-id]` |
| Substation delete | `structsd tx structs substation-delete [substation-id]` |
| Allocation connect | `structsd tx structs substation-allocation-connect [substation-id] [allocation-id]` |
| Allocation disconnect | `structsd tx structs substation-allocation-disconnect [substation-id] [allocation-id]` |
| Player connect | `structsd tx structs substation-player-connect [substation-id] [player-id]` |
| Player disconnect | `structsd tx structs substation-player-disconnect [substation-id] [player-id]` |
| Player migrate | `structsd tx structs substation-player-migrate [src-substation-id] [dest-substation-id] [player-ids]` |
| Allocation create | `structsd tx structs allocation-create [source-id] [power] --allocation-type [type]` |
| Allocation update | `structsd tx structs allocation-update [allocation-id] [power]` |
| Allocation delete | `structsd tx structs allocation-delete [allocation-id]` |

**TX_FLAGS**: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`

## Verification

- **Player**: `structsd query structs player [id]` — `capacity`, `capacitySecondary`, `load`, `structsLoad`, online status.
- **Substation**: `structsd query structs substation [id]` — connected allocations, players.
- **Allocations**: `structsd query structs allocation-all-by-source [source-id]`, `allocation-all-by-destination [dest-id]` — power flow.

## Error Handling

- **Going offline**: Load exceeds capacity. Deactivate structs (`struct-deactivate`), add reactor/generator capacity, or reduce struct count before building more.
- **Allocation exceeds source**: Source (reactor/provider) has limited capacity. Query source; create smaller allocation or add capacity.
- **Substation delete failed**: Ensure no players or allocations connected. Disconnect first.
- **Automated allocation limit**: One automated allocation per source. Use static/dynamic for multiple.

## See Also

- `knowledge/mechanics/power.md` — Formulas, capacity, load, online status
- `knowledge/mechanics/building.md` — Build power requirements
- `knowledge/mechanics/resources.md` — Reactor vs generator conversion rates
