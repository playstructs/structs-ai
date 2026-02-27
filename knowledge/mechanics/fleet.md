# Fleet Mechanics

**Purpose**: AI-readable reference for Structs fleet system. Status, movement, Command Ship rules.

---

## Fleet Status

| Status | Can Build on Planets | Can Raid |
|--------|----------------------|----------|
| onStation | Yes | No |
| away | No | Yes |

---

## Fleet ID Mapping

```
fleetId = "9-{index}"
```

Fleet index matches player index: player `1-N` has fleet `9-N`.

| Player ID | Fleet ID |
|-----------|----------|
| 1-11 | 9-11 |
| 1-18 | 9-18 |

---

## Command Ship

| Rule | Description |
|------|-------------|
| Limit | 1 per player |
| Planet building | Required online |
| Raids | Required online (fleet away) |
| Grant | Gifted at player creation |

---

## Operations by Fleet Status

| Operation | onStation | away |
|-----------|-----------|------|
| Build on planet | ✓ | ✗ |
| Build in fleet | ✓ | ✓ |
| Raid planet | ✗ | ✓ |
| Mine/refine on planet | ✓ | ✗ |

---

## Fleet Movement

- **Fleet movement is instant** — a single transaction with no transit time. The fleet's location updates immediately.
- Fleet moves with player between planets
- Exploration: new planet created, fleet moves to new planet, old planet released
- One planet ownership at a time
- **Planet completion**: When a planet's ore depletes, all fleets are automatically sent away (peace deal)
- Fleet movement validation does not block moves based on fleet-away state
- Fleets can move to already-populated planets

### Fleet Return Conditions

Fleets stay "away" until one of these triggers:
1. **Explicit move** — The player issues `fleet-move` to return home
2. **Command Ship destroyed** — If the fleet's Command Ship is destroyed, the fleet auto-returns
3. **Planet completed** — If the defending planet's owner depletes all ore and explores a new planet, visiting fleets are sent away

Fleets do **not** auto-return on a timer. For raids, you have until one of the above triggers to complete the raid PoW and submit `planet-raid-complete`.

## Command Ship Details

| Property | Value |
|----------|-------|
| Power requirement | 50,000 W |
| Location type | Fleet only (locationType = 2) |
| Initial grant | New players receive a Command Ship at creation (may start offline if insufficient power) |
| Common mistake | Trying to build Command Ship on planet -- must be in fleet |

---

## See Also

- [building.md](building.md) — Fleet on station requirement
- [combat.md](combat.md) — Raid requirements (fleet away)
- [planet.md](planet.md) — Exploration, planet ownership
- `schemas/entities/fleet.md` — Fleet entity definition
- `knowledge/entities/entity-relationships.md` — Fleet entity relationships
- `reference/api-quick-reference.md` — Fleet query endpoints
