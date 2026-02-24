# Entity Index

**Version**: 1.0.0
**Last Updated**: 2026-01-01
**Description**: Complete index of all game entities for AI agents
**Verified**: Yes (by GameCodeAnalyst, method: code-analysis, confidence: high)

---

## Summary

| Metric | Count |
|--------|-------|
| Total Entities | 14 |
| Verified | 14 |
| Fields Verified | 14 |
| Split Entity Files | 10 of 11 (91%) |

### Entities by Category

| Category | Count |
|----------|-------|
| core | 7 |
| social | 1 |
| resource | 2 |
| economic | 4 |

---

## Core Entities

| ID | Name | Endpoint | List Endpoint | Schema |
|----|------|----------|---------------|--------|
| player | Player | `/structs/player/{id}` | `/structs/player` | [player.md](../schemas/entities/player.md) |
| planet | Planet | `/structs/planet/{id}` | `/structs/planet` | [planet.md](../schemas/entities/planet.md) |
| struct | Struct | `/structs/struct/{id}` | `/structs/struct` | [struct.md](../schemas/entities/struct.md) |
| struct-type | Struct Type | `/structs/struct_type/{id}` | `/structs/struct_type` | [struct-type.md](../schemas/entities/struct-type.md) |
| fleet | Fleet | `/structs/fleet/{id}` | `/structs/fleet` | [fleet.md](../schemas/entities/fleet.md) |
| address | Address | `/structs/address/{address}` | `/structs/address` | [entities.md](../schemas/entities.md#address) |
| permission | Permission | `/structs/permission/{permissionId}` | `/structs/permission` | [entities.md](../schemas/entities.md#permission) |

### Player

- **Key Fields**: id, capacity, load, charge, storedOre, playerOnline
- **Relationships**: Owns Planet, Struct, Fleet, Reactor, Substation, Provider; Member of Guild
- **Query Patterns**: byId `/structs/player/{id}` | all `/structs/player` | halted `/structs/player_halted`
- **Code**: `x/structs/types/player.pb.go`, `x/structs/keeper/player_cache.go`
- **Split Schema**: [player.md](../schemas/entities/player.md) | **Minimal**: [player-essential.md](../schemas/minimal/player-essential.md)

### Planet

- **Key Fields**: id, ownerId, status, remainingOre, startingOre
- **Relationships**: Owned by Player; Contains Struct, Reactor, Substation; Has PlanetAttribute
- **Query Patterns**: byId `/structs/planet/{id}` | all `/structs/planet` | byPlayer `/structs/planet_by_player/{playerId}` | attributes `/structs/planet_attribute/{planetId}/{attributeType}` | allAttributes `/structs/planet_attribute`
- **Starting Properties**: maxOre 5, spaceSlots 4, airSlots 4, landSlots 4, waterSlots 4
- **Code**: `x/structs/types/planet.pb.go`, `x/structs/keeper/planet_cache.go`
- **Split Schema**: [planet.md](../schemas/entities/planet.md)

### Struct

- **Key Fields**: id, typeId, ownerId, status, buildDraw, passiveDraw, destroyed
- The `destroyed` field tracks struct destruction status (related to StructSweepDelay of 5 blocks).
- **Relationships**: Owned by Player; Type of StructType; Located on Planet or Fleet; Has StructAttribute
- **Query Patterns**: byId `/structs/struct/{id}` | all `/structs/struct` | attributes `/structs/struct_attribute/{structId}/{attributeType}` | allAttributes `/structs/struct_attribute`
- **Code**: `x/structs/types/struct.pb.go`, `x/structs/keeper/struct_cache.go`
- **Database**: `structs.struct` table (includes destroyed column added 2025-12-29)
- **Split Schema**: [struct.md](../schemas/entities/struct.md)

### Struct Type

- **Key Fields**: id, class, category, buildLimit, buildDifficulty, buildDraw, passiveDraw, maxHealth
- Database includes `cheatsheet_details` and `cheatsheet_extended_details` columns.
- **Relationships**: Has instances of Struct
- **Query Patterns**: byId `/structs/struct_type/{id}` | all `/structs/struct_type`
- **Code**: `proto/structs/structs/struct.proto:26`, `x/structs/types/struct.pb.go`
- **Database**: `structs.struct_type` table (80+ columns, includes cheatsheet_details and cheatsheet_extended_details)
- **Split Schema**: [struct-type.md](../schemas/entities/struct-type.md)

### Fleet

- **Key Fields**: id, ownerId, slots, status, canMove
- **Relationships**: Owned by Player; Contains Struct
- **Query Patterns**: byId `/structs/fleet/{id}` | byIndex `/structs/fleet_by_index/{index}` | all `/structs/fleet`
- **Code**: `x/structs/types/fleet.pb.go`, `x/structs/keeper/fleet_cache.go`
- **Split Schema**: [fleet.md](../schemas/entities/fleet.md)

### Address

- **Key Fields**: address, playerIndex
- **Relationships**: Belongs to Player
- **Query Patterns**: byAddress `/structs/address/{address}` | all `/structs/address` | byPlayer `/structs/address_by_player/{playerId}`
- **Code**: `proto/structs/structs/address.proto:14`, `x/structs/types/address.pb.go`
- **Database**: `structs.player_address` table

### Permission

- **Key Fields**: permissionId, value
- Hash permission bit (value 64) is part of the permission system. Permission values are bit-based flags that can be combined using bitwise OR.
- **Relationships**: Granted to Player; Applies to Planet, Struct, Fleet
- **Query Patterns**: byId `/structs/permission/{permissionId}` | all `/structs/permission` | byObject `/structs/permission/object/{objectId}` | byPlayer `/structs/permission/player/{playerId}`
- **Code**: `proto/structs/structs/permission.proto:11`, `x/structs/types/permission.pb.go`
- **Database**: `structs.permission` table (id, object_type, object_index, object_id, player_id, val)

---

## Social Entities

| ID | Name | Endpoint | List Endpoint | Schema |
|----|------|----------|---------------|--------|
| guild | Guild | `/structs/guild/{id}` | `/structs/guild` | [guild.md](../schemas/entities/guild.md) |

### Guild

- **Key Fields**: id, creator, entrySubstationId, joinInfusionMinimum
- **Relationships**: Has members (Player); Has entry Substation; Has primary Reactor
- **Query Patterns**: byId `/structs/guild/{id}` | all `/structs/guild`
- **Code**: `proto/structs/structs/guild.proto`, `x/structs/keeper/guild_cache.go`
- **Database**: `structs.guild` table
- **Split Schema**: [guild.md](../schemas/entities/guild.md)

---

## Resource Entities

| ID | Name | Endpoint | List Endpoint | Schema |
|----|------|----------|---------------|--------|
| reactor | Reactor | `/structs/reactor/{id}` | `/structs/reactor` | [reactor.md](../schemas/entities/reactor.md) |
| substation | Substation | `/structs/substation/{id}` | `/structs/substation` | [substation.md](../schemas/entities/substation.md) |

### Reactor

- **Key Fields**: id, ownerId, validator, guildId, defaultCommission, staking
- Reactor staking is managed at player level. Validation delegation is abstracted via Reactor Infuse/Defuse actions.
- **Relationships**: Owned by Player; Belongs to Guild; Located on Planet
- **Query Patterns**: byId `/structs/reactor/{id}` | all `/structs/reactor`
- **Code**: `x/structs/types/reactor.pb.go`, `x/structs/keeper/reactor_cache.go`
- **Database**: `structs.reactor` table
- **Split Schema**: [reactor.md](../schemas/entities/reactor.md)

### Substation

- **Key Fields**: id, ownerId, creator
- **Relationships**: Owned by Player; Located on Planet; Used by Guild
- **Query Patterns**: byId `/structs/substation/{id}` | all `/structs/substation`
- **Code**: `x/structs/types/substation.pb.go`, `x/structs/keeper/substation_cache.go`
- **Database**: `structs.substation` table
- **Split Schema**: [substation.md](../schemas/entities/substation.md)

---

## Economic Entities

| ID | Name | Endpoint | List Endpoint | Schema |
|----|------|----------|---------------|--------|
| provider | Provider | `/structs/provider/{id}` | `/structs/provider` | [provider.md](../schemas/entities/provider.md) |
| agreement | Agreement | `/structs/agreement/{id}` | `/structs/agreement` | [agreement.md](../schemas/entities/agreement.md) |
| allocation | Allocation | `/structs/allocation/{id}` | `/structs/allocation` | [allocation.md](../schemas/entities/allocation.md) |
| infusion | Infusion | `/structs/infusion/{destinationId}/{address}` | `/structs/infusion` | [entities.md](../schemas/entities.md#infusion) |

### Provider

- **Key Fields**: id, ownerId, substationId, rateAmount, capacityMinimum, capacityMaximum
- **Relationships**: Owned by Player; Part of Substation; Has Agreements
- **Query Patterns**: byId `/structs/provider/{id}` | all `/structs/provider`
- **Code**: `x/structs/types/provider.pb.go`, `x/structs/keeper/provider_cache.go`
- **Database**: `structs.provider` table
- **Split Schema**: [provider.md](../schemas/entities/provider.md)

### Agreement

- **Key Fields**: id, providerId, consumerId, allocationId, capacity, startBlock, endBlock
- **Relationships**: Provided by Provider; Has Allocation; Consumed by Player
- **Query Patterns**: byId `/structs/agreement/{id}` | all `/structs/agreement` | byProvider `/structs/agreement_by_provider/{providerId}`
- **Code**: `x/structs/types/agreement.pb.go`, `x/structs/keeper/agreement_cache.go`
- **Database**: `structs.agreement` table
- **Split Schema**: [agreement.md](../schemas/entities/agreement.md)

### Allocation

- **Key Fields**: id, sourceId, destinationId, amount, allocationType, controller, locked
- **Relationships**: From Provider or Reactor; To Player or Struct
- **Query Patterns**: byId `/structs/allocation/{id}` | all `/structs/allocation` | bySource `/structs/allocation_by_source/{sourceId}` | byDestination `/structs/allocation_by_destination/{destinationId}`
- **Code**: `x/structs/types/allocation.pb.go`, `x/structs/keeper/allocation_cache.go`
- **Database**: `structs.allocation` table
- **Split Schema**: [allocation.md](../schemas/entities/allocation.md)

### Infusion

- **Key Fields**: destinationType, destinationId, fuel, power, commission, playerId, address, ratio, defusing
- **Relationships**: To destination Player or Struct; From Address
- **Query Patterns**: byDestinationAndAddress `/structs/infusion/{destinationId}/{address}` | all `/structs/infusion` | byDestination `/structs/infusion_by_destination/{destinationId}`
- **Code**: `proto/structs/structs/infusion.proto:12`, `x/structs/types/infusion.pb.go`
- **Database**: `structs.infusion` table (composite PK: destination_id, address; fuel, power, ratio, commission generated columns)
