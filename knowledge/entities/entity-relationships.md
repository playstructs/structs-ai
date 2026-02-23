# Entity Relationships

**Purpose**: AI-readable reference for how all Structs entity types relate. Ownership graph, economic graph, and ID format system.

---

## ID Format

All entities use `type-index` format (e.g., `1-11`, `2-1`). Exception: **StructType** uses integer IDs only (e.g., `1`, `2`).

| Type Code | Entity | Example |
|-----------|--------|---------|
| 0 | Guild | `0-1` |
| 1 | Player | `1-11` |
| 2 | Planet | `2-1` |
| 3 | Reactor | `3-1` |
| 4 | Substation | `4-3` |
| 5 | Struct | `5-42` |
| 6 | Allocation | `6-1` |
| 7 | Infusion | `7-1` |
| 8 | Address | `8-1` |
| 9 | Fleet | `9-11` |
| 10 | Provider | `10-1` |
| 11 | Agreement | `11-1` |

---

## Ownership Graph

```
Guild
  └── hasMembers → Player

Player
  ├── owns → Planet (one at a time)
  ├── owns → Struct (many)
  ├── owns → Fleet (one)
  ├── owns → Reactor (many)
  ├── owns → Substation (many)
  ├── owns → Provider (many)
  └── memberOf → Guild

Planet
  ├── ownedBy → Player
  ├── contains → Struct
  ├── contains → Reactor
  └── contains → Substation

Fleet
  ├── ownedBy → Player
  ├── contains → Struct (slots)
  └── status: station | away

Struct
  ├── ownedBy → Player
  ├── typeOf → StructType (integer ID)
  └── locatedOn → Planet | Fleet
```

---

## Economic Graph

```
Provider (10-x)
  ├── ownedBy → Player
  ├── linkedTo → Substation (per DB schema)
  └── hasAgreements → Agreement

Agreement (11-x)
  ├── providedBy → Provider
  └── consumerId → Player

Allocation (6-x)
  ├── sourceId → Reactor | Provider
  └── destinationId → Player | Struct
```

**Flow**: Provider offers capacity → Consumer opens Agreement → Allocation records energy flow from source to destination.

---

## Power Flow

```
Reactor (3-x) → infuse Alpha Matter → produces kW
     ↓
Substation (4-x) → distributes to connected players
     ↓
Player.capacity, Player.capacitySecondary
     ↓
Struct.passiveDraw (when online)
```

**Allocatable capacity**: Primary substation capacity only (`capacity - load`) can be allocated to reactors/generators. See [power.md](../mechanics/power.md).

---

## Entity Categories

| Category | Entities |
|----------|----------|
| core | Player, Planet, Struct, StructType, Fleet, Address, Permission |
| social | Guild |
| resource | Reactor, Substation |
| economic | Provider, Agreement, Allocation, Infusion |

---

## Key Constraints

| Constraint | Entities |
|------------|----------|
| One planet per player | Player, Planet |
| Planet must be empty (0 ore) to explore new | Planet |
| Command Ship required for building/raiding | Fleet, Struct |
| 1 Planetary Defense Cannon per player | Struct |
| 1 Command Ship per player | Struct |
| Agreements bind Provider → Player | Provider, Agreement |

---

## Query Patterns by Relationship

| Relationship | Query |
|--------------|-------|
| Player's planets | `GET /structs/planet_by_player/{playerId}` |
| Planet's structs | Filter structs by `locationId` = planetId |
| Player's fleet | `GET /structs/fleet` → filter by ownerId |
| Agreements by provider | `GET /structs/agreement_by_provider/{providerId}` |
| Allocations by source/dest | `GET /structs/allocation_by_source/{id}`, `_by_destination/{id}` |

---

## See Also

- [struct-types.md](struct-types.md) — Struct definitions, categories
- [energy-market.md](../economy/energy-market.md) — Provider/Agreement/Allocation flow
- [schemas/entities.md](../../schemas/entities.md) — Full entity definitions
- [schemas/formats.md](../../schemas/formats.md) — ID format specification
- [power.md](../mechanics/power.md) — Capacity, load, substation connection
