---
name: structs-onboarding
description: Onboards a new player into Structs. Registers an address, explores a planet, builds initial infrastructure. Use when starting fresh or setting up a new agent.
---

# Structs Onboarding

## Procedure

1. **Discover player** — Run `structsd query structs address [your-address]` to check if a player exists. If the result shows player ID `1-0`, no player exists for this address yet. Player creation occurs via the webapp or guild-join-proxy.
2. **Explore planet** — Run `structsd tx structs planet-explore [player-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. New planets start with 5 ore, 4 slots per ambit.
3. **Check Command Ship** — New players receive a Command Ship (type 1) at creation. It may start offline if insufficient power. Run `structsd query structs fleet [fleet-id]` and check for existing structs. Fleet ID matches player index: player `1-18` has fleet `9-18`.
4. **Activate Command Ship** — If Command Ship exists but is offline: `structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Requires 50,000 W capacity.
5. **Build Command Ship** (only if not gifted) — `structsd tx structs struct-build-initiate [player-id] 1 space 0 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Type 1 = Command Ship; must be in fleet, not on planet. Then run compute: `structsd tx structs struct-build-compute [struct-id] -D 5 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. The `-D 5` flag waits until difficulty drops to 5 before hashing. Build difficulty 200, expect ~2-5 minutes. Compute auto-submits the complete transaction.
6. **Build Ore Extractor** — Fleet must be on station, Command Ship online. `structsd tx structs struct-build-initiate [player-id] 14 land 0 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Type 14 = Ore Extractor; ambits: land or water. Then compute: `structsd tx structs struct-build-compute [struct-id] -D 5 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Build difficulty 700, expect ~10-20 minutes with `-D 5`.
7. **Activate Ore Extractor** — `structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Requires 500,000 W capacity.
8. **Build Ore Refinery** — `structsd tx structs struct-build-initiate [player-id] 15 land 1 --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Type 15 = Ore Refinery; ambits: land or water. Compute and activate same as above. Build difficulty 700.
9. **Verify** — Query player, planet, fleet, and structs. Confirm all online.

## Proof-of-Work Notes

The `struct-build-compute` command is a helper that calculates the hash AND automatically submits `struct-build-complete` with the results. You do not need to run `struct-build-complete` separately after compute.

The `-D` flag (range 1-64) tells compute to wait until the difficulty drops to that level before starting. Lower values = longer wait but faster hash. Higher values = starts sooner but slower hash. Recommended: `-D 5` for most builds.

| Struct | Type ID | Build Difficulty | `-D 5` Wait | Approx Total |
|--------|---------|------------------|-------------|--------------|
| Command Ship | 1 | 200 | ~2 min | ~2-5 min |
| Ore Extractor | 14 | 700 | ~10 min | ~10-20 min |
| Ore Refinery | 15 | 700 | ~10 min | ~10-20 min |
| Ore Bunker | 18 | 3600 | ~30 min | ~30-45 min |

## Ambit Encoding

Struct types have a `possibleAmbit` bit-flag field:

| Ambit | Bit Value |
|-------|-----------|
| Space | 16 |
| Air | 8 |
| Land | 4 |
| Water | 2 |

Values are combined: 6 = land + water, 30 = all ambits. Check `possibleAmbit` before choosing an operating ambit.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Discover player | `structsd query structs address [address]` |
| Query player | `structsd query structs player [id]` |
| Explore planet | `structsd tx structs planet-explore [player-id]` |
| Initiate build | `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot]` |
| Build compute (PoW + auto-complete) | `structsd tx structs struct-build-compute [struct-id] -D [difficulty]` |
| Activate struct | `structsd tx structs struct-activate [struct-id]` |
| Query planet | `structsd query structs planet [id]` |
| Query fleet | `structsd query structs fleet [id]` |
| Query struct | `structsd query structs struct [id]` |

Build order: Command Ship (type 1, fleet) → Ore Extractor (type 14, planet) → Ore Refinery (type 15, planet). Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Verification

- `structsd query structs address [address]` — player exists (ID is not `1-0`)
- `structsd query structs player [id]` — player online
- `structsd query structs planet [id]` — planet claimed, ore present
- `structsd query structs fleet [id]` — fleet on station
- `structsd query structs struct [id]` — struct status = Online

## Error Handling

- **"player not found"** / player ID is `1-0` — Player doesn't exist. Create via webapp or guild-join-proxy.
- **"insufficient resources"** — Check player Alpha Matter balance.
- **"fleet not on station"** — Wait for fleet or move fleet before planet builds.
- **"invalid slot"** — Use slot 0-3 per ambit; check planet structs for occupancy.
- **"power overload"** — Not enough capacity to activate. Add power sources or connect to a substation with more capacity.

## See Also

- `knowledge/mechanics/building.md`
- `knowledge/mechanics/planet.md`
- `knowledge/mechanics/fleet.md`
- `knowledge/entities/struct-types.md`
- `knowledge/mechanics/power.md`
