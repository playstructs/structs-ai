# Structs Game State Schema

**Version**: 1.0.0
**Category**: core
**Scope**: global
**Description**: Complete game state structure for AI agents. See `schemas/formats.md` for format specifications.

---

## Top-Level Game State

The game state is distributed -- no single endpoint returns all state. Use individual entity endpoints to query specific entities, list endpoints with pagination for bulk queries, filtered endpoints for player-specific queries, and GRASS streaming for real-time updates.

**Required Fields**: `blockHeight`

| Property | Type | Entity Type | Endpoint | Schema Reference | Description |
|----------|------|-------------|----------|------------------|-------------|
| blockHeight | integer | -- | `/blockheight` | -- | Current blockchain block height (updates per-block) |
| players | object | Player | `/structs/player` | `schemas/entities/player.md` | All players in the game |
| planets | object | Planet | `/structs/planet` | `schemas/entities/planet.md` | All planets in the game |
| structs | object | Struct | `/structs/struct` | `schemas/entities/struct.md` | All structs (units) in the game |
| fleets | object | Fleet | `/structs/fleet` | `schemas/entities/fleet.md` | All fleets in the game |
| guilds | object | Guild | `/structs/guild` | `schemas/entities/guild.md` | All guilds in the game |
| reactors | object | Reactor | `/structs/reactor` | `schemas/entities/reactor.md` | All reactors (energy production) |
| substations | object | Substation | `/structs/substation` | `schemas/entities/substation.md` | All substations (power distribution) |
| agreements | object | Agreement | `/structs/agreement` | `schemas/entities/agreement.md` | All energy agreements |
| allocations | object | Allocation | `/structs/allocation` | `schemas/entities/allocation.md` | All energy allocations |
| providers | object | Provider | `/structs/provider` | `schemas/entities/provider.md` | All energy providers |
| structTypes | object | StructType | `/structs/struct_type` | `schemas/entities/struct-type.md` | All struct type definitions (templates). Static definitions loaded from genesis/config. |

---

## Entity Definitions

### Player

**Endpoint**: `/structs/player/{id}`
**Required Fields**: `Player`

#### Player Core Data

**Required Fields**: `id`, `index`, `creator`, `primaryAddress`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^1-[0-9]+$` | Player identifier (e.g., '1-11'). Type 1 = Player. |
| index | string | -- | -- | Player index number |
| guildId | string | entity-id | `^0-[0-9]+$` | Guild ID if member, empty if not. Type 0 = Guild. |
| substationId | string | entity-id | `^4-[0-9]+$` | Substation ID if connected, empty if not. Type 4 = Substation. |
| creator | string | blockchain-address | -- | Blockchain address that created this player |
| primaryAddress | string | blockchain-address | -- | Primary blockchain address for this player |
| planetId | string | entity-id | `^2-[0-9]+$` | Planet ID if player owns a planet, empty if not. Type 2 = Planet. |
| fleetId | string | entity-id | `^9-[0-9]+$` | Fleet ID if player owns a fleet, empty if not. Type 9 = Fleet. |

#### Player Grid Attributes

All values are string representations of integers.

| Field | Type | Description |
|-------|------|-------------|
| ore | string | Current ore amount |
| fuel | string | Current fuel amount |
| capacity | string | Total capacity |
| load | string | Current load |
| structsLoad | string | Load from structs |
| power | string | Current power/energy |
| connectionCapacity | string | Connection capacity |
| connectionCount | string | Number of connections |
| allocationPointerStart | string | Start of allocation pointer |
| allocationPointerEnd | string | End of allocation pointer |
| proxyNonce | string | Proxy nonce value |
| lastAction | string | Last action timestamp or block |
| nonce | string | Nonce value |
| ready | string | Ready status (0 = not ready, 1 = ready) |
| checkpointBlock | string | Checkpoint block height |

#### Player Inventory

| Field | Type | Description |
|-------|------|-------------|
| rocks | object | Rock inventory -- struct type IDs mapped to counts (string integers) |

#### Player Status

| Field | Type | Description |
|-------|------|-------------|
| halted | boolean | Whether player is halted (cannot perform actions) |

---

### Planet

**Endpoint**: `/structs/planet/{id}`
**Required Fields**: `Planet`

#### Planet Core Data

**Required Fields**: `id`, `maxOre`, `creator`, `owner`, `status`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^2-[0-9]+$` | Planet identifier (e.g., '2-1'). Type 2 = Planet. |
| maxOre | string | -- | -- | Maximum ore capacity (typically '5') |
| creator | string | blockchain-address | -- | Blockchain address that created this planet |
| owner | string | entity-id | `^1-[0-9]+$` | Player ID who owns this planet, empty if unowned. Type 1 = Player. |
| status | string | enum | `active`, `inactive` | Planet status |
| locationListStart | string | -- | -- | Start of location list (typically empty) |
| locationListLast | string | -- | -- | End of location list (typically empty) |

#### Planet Slot Arrays

Each slot array has 4 entries containing struct IDs (format `^5-[0-9]+$`) or empty strings.

| Field | Type | Slots | Description |
|-------|------|-------|-------------|
| space | array[string] | 4 | Space slot array |
| air | array[string] | 4 | Air slot array |
| land | array[string] | 4 | Land slot array |
| water | array[string] | 4 | Water slot array |

#### Planet Slot Counts

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| spaceSlots | string | '4' | Number of space slots |
| airSlots | string | '4' | Number of air slots |
| landSlots | string | '4' | Number of land slots |
| waterSlots | string | '4' | Number of water slots |

#### Planet Grid Attributes

All values are string representations of integers (same structure as Player Grid Attributes).

| Field | Type | Description |
|-------|------|-------------|
| ore | string | Current ore amount |
| fuel | string | Current fuel amount |
| capacity | string | Total capacity |
| load | string | Current load |
| structsLoad | string | Load from structs |
| power | string | Current power/energy |
| connectionCapacity | string | Connection capacity |
| connectionCount | string | Number of connections |
| allocationPointerStart | string | Start of allocation pointer |
| allocationPointerEnd | string | End of allocation pointer |
| proxyNonce | string | Proxy nonce value |
| lastAction | string | Last action timestamp or block |
| nonce | string | Nonce value |
| ready | string | Ready status (0 = not ready, 1 = ready) |
| checkpointBlock | string | Checkpoint block height |

#### Planet Attributes

Additional planet-specific attributes that vary by planet type and state. Schema allows arbitrary additional properties.

---

### Struct

**Endpoint**: `/structs/struct/{id}`
**Required Fields**: `id`, `typeId`, `ownerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^5-[0-9]+$` | Struct identifier (e.g., '5-42'). Type 5 = Struct. |
| typeId | string | struct-type-id | -- | Type of struct (references StructType) |
| ownerId | string | entity-id | `^1-[0-9]+$` | Player who owns this struct. Type 1 = Player. |
| locationType | integer | -- | -- | Type of location (9 = fleet, etc.) |
| locationId | string | -- | -- | ID of location where struct is located |
| operatingAmbit | integer | -- | -- | Operating range/ambit |
| structAttributes | object | -- | -- | Struct-specific attributes |

---

### Fleet

**Endpoint**: `/structs/fleet/{id}`
**Required Fields**: `id`, `ownerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^9-[0-9]+$` | Fleet identifier (e.g., '9-11'). Type 9 = Fleet. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Player who owns this fleet. Type 1 = Player. |
| planetId | string | entity-id | `^2-[0-9]+$` | Planet ID where fleet is located, empty if away. Type 2 = Planet. |
| slots | array[string] | entity-id | `^5-[0-9]+$` | Struct IDs in this fleet |
| status | string | enum | `onStation`, `away` | Fleet status: 'onStation' = at planet (can build), 'away' = away (cannot build) |
| canMove | boolean | -- | -- | Whether fleet can move. Requires: owner online, fleet has command struct, command struct online. |

---

### Guild

**Endpoint**: `/structs/guild/{id}`
**Required Fields**: `Guild`

#### Guild Core Data

**Required Fields**: `id`, `index`, `creator`, `owner`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^0-[0-9]+$` | Guild identifier (e.g., '0-1'). Type 0 = Guild. |
| index | string | -- | -- | Guild index number |
| endpoint | string | uri | -- | External endpoint URL for guild communication |
| creator | string | blockchain-address | -- | Blockchain address that created this guild |
| owner | string | entity-id | `^1-[0-9]+$` | Player ID who owns this guild. Type 1 = Player. |
| joinInfusionMinimum | string | -- | -- | Minimum infusion amount required to join |
| joinInfusionMinimumBypassByRequest | string | enum | `open`, `closed` | Whether join minimum can be bypassed by request |
| joinInfusionMinimumBypassByInvite | string | enum | `open`, `closed` | Whether join minimum can be bypassed by invite |
| primaryReactorId | string | entity-id | `^3-[0-9]+$` | Primary reactor ID. Type 3 = Reactor. |
| entrySubstationId | string | entity-id | `^4-[0-9]+$` | Entry substation ID. Type 4 = Substation. |

---

### Reactor

**Endpoint**: `/structs/reactor/{id}`
**Required Fields**: `id`, `ownerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^3-[0-9]+$` | Reactor identifier (e.g., '3-1'). Type 3 = Reactor. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Player who owns this reactor. Type 1 = Player. |

#### Reactor Grid Attributes

All values are string representations of integers.

| Field | Type | Description |
|-------|------|-------------|
| ore | string | Current ore amount |
| fuel | string | Current fuel amount |
| capacity | string | Total energy capacity |
| load | string | Current energy load |
| structsLoad | string | Load from structs |
| power | string | Current power generation |
| connectionCapacity | string | Connection capacity |
| connectionCount | string | Number of active connections |
| allocationPointerStart | string | Start pointer for allocations |
| allocationPointerEnd | string | End pointer for allocations |
| proxyNonce | string | Proxy nonce |
| lastAction | string | Timestamp of last action |
| nonce | string | Nonce for transactions |
| ready | string | Ready status |
| checkpointBlock | string | Last checkpoint block |

---

### Substation

**Endpoint**: `/structs/substation/{id}`
**Required Fields**: `id`, `ownerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^4-[0-9]+$` | Substation identifier (e.g., '4-3'). Type 4 = Substation. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Player who owns this substation. Type 1 = Player. |

#### Substation Grid Attributes

Same structure as Reactor Grid Attributes (all string representations of integers):
`ore`, `fuel`, `capacity`, `load`, `structsLoad`, `power`, `connectionCapacity`, `connectionCount`, `allocationPointerStart`, `allocationPointerEnd`, `proxyNonce`, `lastAction`, `nonce`, `ready`, `checkpointBlock`.

---

### Agreement

**Endpoint**: `/structs/agreement/{id}`
**Required Fields**: `id`, `providerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^11-[0-9]+$` | Agreement identifier (e.g., '11-1'). Type 11 = Agreement. |
| providerId | string | entity-id | `^10-[0-9]+$` | Energy provider. Type 10 = Provider. |

---

### Allocation

**Endpoint**: `/structs/allocation/{id}`
**Required Fields**: `id`, `sourceId`, `destinationId`

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| id | string | entity-id (`^6-[0-9]+$`) | Allocation identifier. Type 6 = Allocation. |
| type | string | -- | Type of allocation (e.g., 'automated', 'manual') |
| sourceObjectId | string | entity-id | Source entity ID (reactor type 3, provider type 10, or player type 1) |
| destinationId | string | entity-id | Destination entity ID (player type 1 or struct type 5) |
| controller | string | blockchain-address | Controller address for this allocation |
| locked | boolean | -- | Whether this allocation is locked |
| index | string | -- | Allocation index number |
| creator | string | blockchain-address | Blockchain address that created this allocation |

---

### Provider

**Endpoint**: `/structs/provider/{id}`
**Required Fields**: `id`, `ownerId`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| id | string | entity-id | `^10-[0-9]+$` | Provider identifier (e.g., '10-1'). Type 10 = Provider. |
| ownerId | string | entity-id | `^1-[0-9]+$` | Player who owns this provider. Type 1 = Player. |
| rate | object | -- | -- | Energy rate information |
| policy | object | -- | -- | Provider policy |

---

### Address

**Endpoint**: `/structs/address/{address}`
**Required Fields**: `address`

| Field | Type | Format | Pattern | Description |
|-------|------|--------|---------|-------------|
| address | string | blockchain-address | -- | Blockchain address (Cosmos SDK format, e.g., 'structs1...') |
| playerId | string | entity-id | `^1-[0-9]+$` | Player ID this address belongs to. Type 1 = Player. |
| guildId | string | entity-id | `^0-[0-9]+$` | Guild ID if associated. Type 0 = Guild. |

---

### Permission

**Endpoint**: `/structs/permission/{permissionId}`
**Required Fields**: `permissionId`, `value`

| Field | Type | Description |
|-------|------|-------------|
| permissionId | string | Permission identifier in format 'objectId@playerId' (e.g., '0-1@1-1') |
| value | string | Permission value (numeric string). Bit-based flags. Common: 127 (all), 64 (Hash). Bits combined with bitwise OR. |
| objectType | string | Type of object (e.g., 'guild', 'planet', 'struct', 'fleet') |
| objectIndex | string | Object index number |
| objectId | string | Object entity ID (guild type 0, planet type 2, struct type 5, or fleet type 9) |
| playerId | string | Player ID this permission is granted to. Type 1 = Player. |

---

### Infusion

**Endpoint**: `/structs/infusion/{destinationId}/{address}`
**Required Fields**: `destinationId`, `address`

| Field | Type | Format | Description |
|-------|------|--------|-------------|
| destinationId | string | entity-id | Destination entity (reactor type 3, player type 1, or struct type 5) |
| destinationType | string | -- | Type of destination (e.g., 'reactor', 'player', 'struct') |
| address | string | blockchain-address | Source blockchain address |
| playerId | string | entity-id (`^1-[0-9]+$`) | Associated player ID. Type 1 = Player. |
| fuel | string | -- | Fuel amount (in ualpha units) |
| defusing | string | -- | Defusing amount (in ualpha units) |
| power | string | -- | Power amount (in milliwatts) |
| ratio | string | -- | Infusion ratio |
| commission | string | -- | Commission rate (e.g., '0.04' for 4%) |

---

### StructType

**Endpoint**: `/structs/struct_type/{id}`
**Category**: core
**Required Fields**: `id`, `type`, `class`, `category`

StructTypes are static definitions loaded from genesis/config. They define the properties and capabilities of struct types that can be built.

| Field | Type | Description |
|-------|------|-------------|
| id | string | Struct type identifier (integer as string, e.g., '1'). Note: uses regular integers, not 'type-index' format. |
| type | string | Struct type name (e.g., 'Command Ship', 'Miner') |
| class | string | Struct class identifier. Used for cosmetic mod linking. |
| classAbbreviation | string | Abbreviated class name (e.g., 'CMD Ship') |
| defaultCosmeticModelNumber | string | Default cosmetic model number (e.g., 'ST-21') |
| defaultCosmeticName | string | Default cosmetic name (e.g., 'Spearpoint') |
| category | string | Category: `fleet`, `mining`, `refining`, `power`, `combat`, `defense`, `utility` |
| buildLimit | string | Maximum number buildable |
| buildDifficulty | string | Proof-of-work difficulty for building |
| buildDraw | string | Power draw during building (milliwatts) |
| maxHealth | string | Maximum health points |
| passiveDraw | string | Power draw when active (milliwatts) |
| possibleAmbit | string | Possible operating ambit (bitmask) |
| movable | boolean | Whether struct can be moved |
| slotBound | boolean | Whether struct is bound to a slot |
| primaryWeapon | string | Primary weapon type (e.g., 'guidedWeaponry', 'noActiveWeaponry') |
| primaryWeaponControl | string | Primary weapon control type (e.g., 'guided') |
| primaryWeaponCharge | string | Charge cost for primary weapon |
| primaryWeaponAmbits | string | Primary weapon operating ambits (bitmask) |
| primaryWeaponTargets | string | Number of targets primary weapon can hit |
| primaryWeaponShots | string | Number of shots primary weapon can fire |
| primaryWeaponDamage | string | Primary weapon damage |
| primaryWeaponBlockable | boolean | Whether damage can be blocked |
| primaryWeaponCounterable | boolean | Whether weapon can be countered |
| secondaryWeapon | string | Secondary weapon type |
| activateCharge | string | Charge cost to activate |
| buildCharge | string | Charge cost to build |
| oreMiningCharge | string | Charge cost for ore mining (if applicable) |
| oreRefiningCharge | string | Charge cost for ore refining (if applicable) |
| oreMiningDifficulty | string | PoW difficulty for mining (if applicable) |
| oreRefiningDifficulty | string | PoW difficulty for refining (if applicable) |
| generatingRate | string | Energy generation rate for generators (if applicable) |
| stealthActivateCharge | string | Charge cost for stealth (if applicable) |
| hasStealthSystem | boolean | Whether struct has stealth capability |

**Verification**: Verified by GameCodeAnalyst (2025-01-XX) via api-response-analysis. High confidence. Code reference: `genesis_struct_type.go`, `technical/api-reference.md`.

---

## Notes

- Game state is distributed -- no single endpoint returns all state
- Use individual entity endpoints to query specific entities
- Use list endpoints with pagination for bulk queries
- Use filtered endpoints for player-specific queries
- Use GRASS streaming for real-time updates
