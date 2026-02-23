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

- Fleet moves with player between planets
- Exploration: new planet created, fleet moves to new planet, old planet released
- One planet ownership at a time
- **Planet completion**: When a planet's ore depletes, all fleets are automatically sent away (peace deal)

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
