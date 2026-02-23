---
name: structs-onboarding
description: Onboards a new player into Structs. Registers an address, explores a planet, builds initial infrastructure. Use when starting fresh or setting up a new agent.
---

# Structs Onboarding

## Procedure

1. **Register address** — If not already registered, run `structsd tx structs address-register [player-id] [address] [proof-pubkey] [proof-signature] [permissions] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Player creation may occur via webapp or automatically on first address-register.
2. **Get player ID** — Run `structsd query structs player-me` to resolve own player ID.
3. **Explore planet** — Run `structsd tx structs planet-explore [player-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. New planets start with 5 ore, 4 slots per ambit.
4. **Build Command Ship** — Fleet must exist. Run `structsd tx structs struct-build-initiate [player-id] 14 space [slot] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Type 14 = Command Ship; must be in fleet (space ambit), not on planet.
5. **Proof-of-work** — Query struct ID from build, then `structsd tx structs struct-build-compute [struct-id] -D [difficulty] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
6. **Complete build** — `structsd tx structs struct-build-complete [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`.
7. **Activate Command Ship** — `structsd tx structs struct-activate [struct-id] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Requires 50,000 W capacity.
8. **Build Ore Extractor** — Fleet on station. Run `structsd tx structs struct-build-initiate [player-id] [ore-extractor-type-id] [ambit] [slot] --from [key-name] --gas auto --gas-adjustment 1.5 -y`. Repeat compute → complete → activate.
9. **Verify** — Query player, planet, fleet, and structs. Confirm all online.

## Commands Reference

| Action | CLI Command |
|--------|-------------|
| Register address | `structsd tx structs address-register [player-id] [address] [proof-pubkey] [proof-signature] [permissions]` |
| Explore planet | `structsd tx structs planet-explore [player-id]` |
| Initiate build | `structsd tx structs struct-build-initiate [player-id] [struct-type-id] [operating-ambit] [slot]` |
| Build compute (PoW) | `structsd tx structs struct-build-compute [struct-id] -D [difficulty]` |
| Build complete | `structsd tx structs struct-build-complete [struct-id]` |
| Activate struct | `structsd tx structs struct-activate [struct-id]` |
| Query player | `structsd query structs player [id]` |
| Query self | `structsd query structs player-me` |
| Query planet | `structsd query structs planet [id]` |
| Query fleet | `structsd query structs fleet [id]` |
| Query struct | `structsd query structs struct [id]` |

Build order: Command Ship (type 14, fleet) → Ore Extractor (planet). Common tx flags: `--from [key-name] --gas auto --gas-adjustment 1.5 -y`.

## Verification

- `structsd query structs player [id]` — player exists, online
- `structsd query structs planet [id]` — planet claimed, ore present
- `structsd query structs fleet [id]` — fleet on station
- `structsd query structs struct [id]` — struct status = Online

## Error Handling

- **"player not found"** — Register address or create via webapp first.
- **"insufficient resources"** — Check player Alpha Matter; Command Ship may be gifted.
- **"fleet not on station"** — Wait for fleet or move fleet before planet builds.
- **"invalid slot"** — Use slot 0–3 per ambit; check planet structs for occupancy.

## See Also

- `knowledge/mechanics/building.md`
- `knowledge/mechanics/planet.md`
- `knowledge/mechanics/fleet.md`
- `knowledge/entities/struct-types.md`
