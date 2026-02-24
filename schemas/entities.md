# Structs Entity Definitions

**Version**: 1.0.0
**Category**: core
**Description**: Complete catalog of all game entities for AI agents. See `schemas/formats.md` for format specifications.

---

## Entity Categories

| Category | Entities |
|----------|----------|
| core | Player, Planet, Struct, StructType, Fleet, Address, Permission |
| social | Guild |
| resource | Reactor, Substation |
| economic | Provider, Agreement, Allocation, Infusion |

## Query Patterns

| Pattern | Format |
|---------|--------|
| Single entity | `{endpoint}/{id}` |
| List all | `{listEndpoint}` |
| Filtered | `{endpoint}_by_{filter}/{filterValue}` |
| Attributes | `{endpoint}_attribute/{entityId}/{attributeType}` |
| All attributes | `{endpoint}_attribute` |

---

## Entity Index

### Player

- **ID**: `player`
- **Category**: core
- **Description**: A player in the game
- **Endpoint**: `/structs/player/{id}`
- **List Endpoint**: `/structs/player`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| owns | Planet, Struct, Fleet, Reactor, Substation, Provider |
| memberOf | Guild |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/player/{id}` |
| all | `/structs/player` |
| halted | `/structs/player_halted` |

### Planet

- **ID**: `planet`
- **Category**: core
- **Description**: A planet in the game
- **Endpoint**: `/structs/planet/{id}`
- **List Endpoint**: `/structs/planet`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| ownedBy | Player |
| contains | Struct, Reactor, Substation |
| hasAttributes | PlanetAttribute |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/planet/{id}` |
| all | `/structs/planet` |
| byPlayer | `/structs/planet_by_player/{playerId}` |
| attributes | `/structs/planet_attribute/{planetId}/{attributeType}` |
| allAttributes | `/structs/planet_attribute` |

**Starting Properties** (all newly explored planets start with identical properties):

| Property | Value |
|----------|-------|
| maxOre | 5 |
| spaceSlots | 4 |
| airSlots | 4 |
| landSlots | 4 |
| waterSlots | 4 |

**Ownership Rules**:

- Players can only own one planet at a time
- Current planet must be empty (0 ore) before exploring new planet
- On exploration: new planet created, fleet moves to new planet, old planet released

### Struct

- **ID**: `struct`
- **Category**: core
- **Description**: A struct (unit) in the game
- **Endpoint**: `/structs/struct/{id}`
- **List Endpoint**: `/structs/struct`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| ownedBy | Player |
| typeOf | StructType |
| locatedOn | Planet, Fleet |
| hasAttributes | StructAttribute |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/struct/{id}` |
| all | `/structs/struct` |
| attributes | `/structs/struct_attribute/{structId}/{attributeType}` |
| allAttributes | `/structs/struct_attribute` |

### StructType

- **ID**: `struct-type`
- **Category**: core
- **Description**: A struct type definition (template)
- **Endpoint**: `/structs/struct_type/{id}`
- **List Endpoint**: `/structs/struct_type`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| instances | Struct |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/struct_type/{id}` |
| all | `/structs/struct_type` |

### Fleet

- **ID**: `fleet`
- **Category**: core
- **Description**: A fleet (group of structs)
- **Endpoint**: `/structs/fleet/{id}`
- **List Endpoint**: `/structs/fleet`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| ownedBy | Player |
| contains | Struct |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/fleet/{id}` |
| byIndex | `/structs/fleet_by_index/{index}` |
| all | `/structs/fleet` |

### Guild

- **ID**: `guild`
- **Category**: social
- **Description**: A guild (player organization)
- **Endpoint**: `/structs/guild/{id}`
- **List Endpoint**: `/structs/guild`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| hasMembers | Player |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/guild/{id}` |
| all | `/structs/guild` |

### Reactor

- **ID**: `reactor`
- **Category**: resource
- **Description**: A reactor (energy production)
- **Endpoint**: `/structs/reactor/{id}`
- **List Endpoint**: `/structs/reactor`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| ownedBy | Player |
| locatedOn | Planet |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/reactor/{id}` |
| all | `/structs/reactor` |

### Substation

- **ID**: `substation`
- **Category**: resource
- **Description**: A substation (power distribution)
- **Endpoint**: `/structs/substation/{id}`
- **List Endpoint**: `/structs/substation`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| ownedBy | Player |
| locatedOn | Planet |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/substation/{id}` |
| all | `/structs/substation` |

### Provider

- **ID**: `provider`
- **Category**: economic
- **Description**: An energy provider
- **Endpoint**: `/structs/provider/{id}`
- **List Endpoint**: `/structs/provider`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| ownedBy | Player |
| hasAgreements | Agreement |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/provider/{id}` |
| all | `/structs/provider` |

### Agreement

- **ID**: `agreement`
- **Category**: economic
- **Description**: An energy agreement (automated contract)
- **Endpoint**: `/structs/agreement/{id}`
- **List Endpoint**: `/structs/agreement`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| providedBy | Provider |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/agreement/{id}` |
| all | `/structs/agreement` |
| byProvider | `/structs/agreement_by_provider/{providerId}` |

### Allocation

- **ID**: `allocation`
- **Category**: economic
- **Description**: An energy allocation
- **Endpoint**: `/structs/allocation/{id}`
- **List Endpoint**: `/structs/allocation`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| from | Provider, Reactor |
| to | Player, Struct |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/allocation/{id}` |
| all | `/structs/allocation` |
| bySource | `/structs/allocation_by_source/{sourceId}` |
| byDestination | `/structs/allocation_by_destination/{destinationId}` |

### Address

- **ID**: `address`
- **Category**: core
- **Description**: A blockchain address
- **Endpoint**: `/structs/address/{address}`
- **List Endpoint**: `/structs/address`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| belongsTo | Player |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byAddress | `/structs/address/{address}` |
| all | `/structs/address` |
| byPlayer | `/structs/address_by_player/{playerId}` |

### Permission

- **ID**: `permission`
- **Category**: core
- **Description**: A permission (access control). Permission values are bit-based flags. Hash permission bit value is 64.
- **Endpoint**: `/structs/permission/{permissionId}`
- **List Endpoint**: `/structs/permission`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| grantedTo | Player |
| appliesTo | Planet, Struct, Fleet |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byId | `/structs/permission/{permissionId}` |
| all | `/structs/permission` |
| byObject | `/structs/permission/object/{objectId}` |
| byPlayer | `/structs/permission/player/{playerId}` |

### Infusion

- **ID**: `infusion`
- **Category**: economic
- **Description**: An infusion (resource transfer)
- **Endpoint**: `/structs/infusion/{destinationId}/{address}`
- **List Endpoint**: `/structs/infusion`

**Relationships**:

| Relationship | Target Entities |
|-------------|-----------------|
| toDestination | Player, Struct |
| fromAddress | Address |

**Query Patterns**:

| Pattern | Endpoint |
|---------|----------|
| byDestinationAndAddress | `/structs/infusion/{destinationId}/{address}` |
| all | `/structs/infusion` |
| byDestination | `/structs/infusion_by_destination/{destinationId}` |

---

## Entity Definitions (Schema)

### Player Definition

**Code Reference**: `x/structs/types/player.pb.go`, `x/structs/keeper/player_cache.go`
**Description**: Complete Player entity with verified field definitions
**Required Fields**: `id`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^1-[0-9]+$` | Unique player identifier in format 'type-index' (e.g., '1-11'). Type 1 = Player. |
| index | string | -- | -- | Player index number |
| guildId | string | entity-id | `^0-[0-9]+$` | Guild ID if player is a member, empty string if not. Type 0 = Guild. |
| substationId | string | entity-id | `^4-[0-9]+$` | Substation ID if connected, empty string if not. Type 4 = Substation. |
| creator | string | blockchain-address | -- | Blockchain address that created this player |
| primaryAddress | string | blockchain-address | -- | Primary blockchain address for this player |
| planetId | string | entity-id | `^2-[0-9]+$` | Planet ID if player owns a planet, empty string if not. Type 2 = Planet. |
| fleetId | string | entity-id | `^9-[0-9]+$` | Fleet ID if player owns a fleet, empty string if not. Type 9 = Fleet. |
| capacity | integer | milliwatts | -- | Primary power capacity from substation connection |
| capacitySecondary | integer | milliwatts | -- | Secondary power capacity from additional substation connection |
| load | integer | milliwatts | -- | Current power consumption (active operations) |
| structsLoad | integer | milliwatts | -- | Total power consumption from all active structs (passive draw). Formula: Sum of all struct PassiveDraw values |
| availableCapacity | integer | milliwatts | -- | Available power capacity. Formula: `(Capacity + CapacitySecondary) - (Load + StructsLoad)` |
| allocatableCapacity | integer | milliwatts | -- | Allocatable capacity (primary capacity only). Formula: `Capacity - Load` |
| playerOnline | boolean | -- | -- | Player online status. Formula: `(Load + StructsLoad) <= (Capacity + CapacitySecondary)` |
| lastActionBlock | integer | -- | -- | Block height of last action |
| charge | integer | -- | -- | Current charge (blocks since last action). Formula: `CurrentBlockHeight - LastActionBlock` |
| storedOre | integer | ore | -- | Raw ore stored by player (can be stolen in raids). Separate from refined Alpha Matter. |
| halted | boolean | -- | -- | Whether player is halted (disabled) |
| nonce | integer | -- | -- | Nonce for randomness generation (increments with each use) |

### Planet Definition

**Code Reference**: `x/structs/types/planet.pb.go`, `x/structs/keeper/planet_cache.go`
**Description**: Complete Planet entity with verified field definitions
**Required Fields**: `id`

| Field | Type | Format | Pattern | Default | Description |
|-------|------|--------|---------|---------|-------------|
| id | string | entity-id | `^2-[0-9]+$` | -- | Unique planet identifier. Type 2 = Planet. |
| ownerId | string | entity-id | `^1-[0-9]+$` | -- | Player who owns this planet. Type 1 = Player. |
| status | string | enum | `active`, `complete` | -- | Planet status (active = has ore, complete = depleted) |
| remainingOre | integer | ore | -- | -- | Remaining ore on planet |
| startingOre | integer | ore | -- | 5 | Initial ore amount (all planets start with 5) |
| spaceSlots | integer | -- | -- | 4 | Number of space slots available |
| airSlots | integer | -- | -- | 4 | Number of air slots available |
| landSlots | integer | -- | -- | 4 | Number of land slots available |
| waterSlots | integer | -- | -- | 4 | Number of water slots available |
| planetaryShieldBase | integer | -- | -- | -- | Base planetary shield damage |

### Struct Definition

**Code Reference**: `x/structs/types/struct.pb.go`, `x/structs/keeper/struct_cache.go`
**Description**: Complete Struct entity with verified field definitions
**Required Fields**: `id`, `typeId`, `ownerId`

| Field | Type | Format | Pattern | Default | Description |
|-------|------|--------|---------|---------|-------------|
| id | string | entity-id | `^5-[0-9]+$` | -- | Unique struct identifier. Type 5 = Struct. |
| typeId | string | struct-type-id | -- | -- | Type of struct (references StructType) |
| ownerId | string | entity-id | `^1-[0-9]+$` | -- | Player who owns this struct. Type 1 = Player. |
| locationType | integer | -- | -- | -- | Type of location (9 = fleet, 1 = planet, etc.) |
| locationId | string | -- | -- | -- | ID of location where struct is located |
| operatingAmbit | integer | -- | -- | -- | Operating range/ambit (space/air/land/water) |
| status | string | enum | `building`, `built`, `online`, `offline`, `hidden` | -- | Struct status |
| buildDraw | integer | milliwatts | -- | -- | Power draw during building |
| passiveDraw | integer | milliwatts | -- | -- | Power draw when active (online) |
| buildDifficulty | integer | -- | -- | -- | Proof-of-work difficulty for building |
| activateCharge | integer | -- | -- | -- | Charge cost to activate struct. Genesis sets activateCharge = 1 for all struct types. |
| buildCharge | integer | -- | -- | -- | Charge cost to build struct |
| oreMiningCharge | integer | -- | -- | -- | Charge cost for ore mining |
| oreRefiningCharge | integer | -- | -- | -- | Charge cost for ore refining |
| oreMiningDifficulty | integer | -- | -- | 14000 | Proof-of-work difficulty for ore mining |
| oreRefiningDifficulty | integer | -- | -- | 28000 | Proof-of-work difficulty for ore refining |
| stealthActivateCharge | integer | -- | -- | -- | Charge cost to activate stealth |
| hasStealthSystem | boolean | -- | -- | -- | Whether struct has stealth system |
| isHidden | boolean | -- | -- | -- | Whether struct is currently hidden (stealth active) |

### Fleet Definition

**Code Reference**: `x/structs/types/fleet.pb.go`, `x/structs/keeper/fleet_cache.go`
**Description**: Complete Fleet entity with verified field definitions
**Required Fields**: `id`, `ownerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^9-[0-9]+$` | Unique fleet identifier. Type 9 = Fleet. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Player who owns this fleet. Type 1 = Player. |
| slots | array[string] | entity-id | `^5-[0-9]+$` | Structs in this fleet (array of Struct IDs) |
| status | string | enum | `station`, `away` | Fleet status (station = on planet, away = raiding) |
| canMove | boolean | -- | -- | Whether fleet can move (readiness check) |

**Fleet Movement Requirements** (`canMove`):

- Owner is online (not offline)
- Fleet has command struct
- Command struct is online

---

## Verification

| Field | Value |
|-------|-------|
| Verified | true |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Note | Field definitions verified against codebase. Some entities need additional field verification. |
