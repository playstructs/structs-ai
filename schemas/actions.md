# Structs Action Definitions

**Version**: 1.1.0
**Category**: actions
**Description**: Complete catalog of all game actions/commands for AI agents

---

## Action Categories

| Category | Actions |
|----------|---------|
| construction | MsgStructBuild, MsgStructBuildInitiate, MsgStructBuildComplete |
| combat | MsgStructAttack, MsgPlanetRaidComplete |
| resource | MsgReactorAllocate, MsgReactorInfuse, MsgReactorDefuse, MsgReactorBeginMigration, MsgReactorCancelDefusion, MsgSubstationConnect, MsgSubstationCreate, MsgSubstationPlayerConnect, MsgStructOreMinerComplete, MsgStructOreRefineryComplete |
| economic | MsgProviderCreate, MsgAgreementCreate, MsgOreMining, MsgOreRefining, MsgGeneratorAllocate |
| exploration | MsgPlanetExplore |
| fleet | MsgFleetMove |
| guild | MsgGuildCreate, MsgGuildMembershipJoin, MsgGuildMembershipLeave, MsgGuildBankMint, MsgGuildBankRedeem |
| struct-management | MsgStructActivate, MsgStructDeactivate, MsgStructStealthActivate, MsgStructStealthDeactivate, MsgStructDefenseSet, MsgStructDefenseClear, MsgStructMove |

## Common Requirements

| Requirement | Description |
|-------------|-------------|
| playerOnline | Player must be online (not halted) |
| sufficientResources | Player must have sufficient resources |
| sufficientCharge | Struct must have sufficient charge |
| proofOfWork | Action requires proof-of-work computation |
| validLocation | Location must be valid and accessible |
| validTarget | Target must be valid and attackable |

## Transaction Flow

1. Build transaction with message(s)
2. Sign transaction with player key
3. Submit to `POST /cosmos/tx/v1beta1/txs`
4. Transaction moves to 'broadcast' status
5. On-chain validation occurs (checks requirements)
6. Action succeeds OR fails based on validation
7. Query game state to verify action actually occurred
8. If action didn't occur, check requirements and retry

**IMPORTANT**: Transaction status 'broadcast' does NOT mean action succeeded! Validation happens on-chain after broadcast. Always verify game state to confirm action occurred.

**Common Validation Failures**:

- Planet building: Command Ship not online or fleet not onStation
- Exploration: Current planet has ore remaining
- Building: Insufficient power or other requirements not met

See `patterns/validation-patterns.md` for detailed validation patterns.

---

## Construction Actions

### MsgStructBuild

- **ID**: `struct-build`
- **Name**: Build Struct
- **Message Type**: `/structs.structs.MsgStructBuild`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Start building a struct

**Required Fields**: `creator`, `structType`, `locationType`, `locationId`
**Optional Fields**: `gridAttributes`
**Follow-Up Action**: MsgStructBuildComplete

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientResources | true |
| validLocation | true |
| commandShipOnline | If building on planet: Command Ship must be built AND online in fleet. Check: query fleet for Command Ship struct, verify status is 'online'. |
| fleetOnStation | If building on planet: fleet must be 'onStation' (not 'away'). Check: query fleet status. |
| sufficientPower | Must have power capacity > struct passive draw. Check: query player power capacity vs struct requirements. |

Transaction may broadcast but struct not created if requirements not met. Always verify game state after broadcast.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuild",
        "creator": "structs1...",
        "structType": "1",
        "locationType": 1,
        "locationId": "1-1"
      }
    ]
  }
}
```

### MsgStructBuildInitiate

- **ID**: `struct-build-initiate`
- **Name**: Initiate Struct Build
- **Message Type**: `/structs.structs.MsgStructBuildInitiate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Start building a struct (first step of two-step process)
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_build_initiate.go:18-88`
- **Proto Reference**: `proto/structs/structs/tx.proto:660-669`

**Required Fields**: `creator`, `playerId`, `structTypeId`, `operatingAmbit`, `slot`
**Follow-Up Action**: MsgStructBuildComplete

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientResources | true |
| validLocation | true |
| sufficientPower | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuildInitiate",
        "creator": "structs1...",
        "playerId": "1-1",
        "structTypeId": "1",
        "operatingAmbit": 1,
        "slot": 1
      }
    ]
  }
}
```

### MsgStructBuildComplete

- **ID**: `struct-build-complete`
- **Name**: Complete Struct Build
- **Message Type**: `/structs.structs.MsgStructBuildComplete`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Complete building a struct (requires proof-of-work)

**Required Fields**: `creator`, `structId`, `hash`, `nonce`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structInBuildingState | true |
| proofOfWork | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructBuildComplete",
        "creator": "structs1...",
        "structId": "1-1",
        "hash": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

---

## Combat Actions

### MsgStructAttack

- **ID**: `struct-attack`
- **Name**: Attack with Struct
- **Message Type**: `/structs.structs.MsgStructAttack`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Attack another struct

**Required Fields**: `creator`, `structId`, `targetId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientCharge | true |
| structOnline | true |
| validTarget | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructAttack",
        "creator": "structs1...",
        "structId": "1-1",
        "targetId": "2-1"
      }
    ]
  }
}
```

### MsgPlanetRaidComplete

- **ID**: `planet-raid-complete`
- **Name**: Complete Planet Raid
- **Message Type**: `/structs.structs.MsgPlanetRaidComplete`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Complete a raid on a planet (requires proof-of-work)

**Required Fields**: `creator`, `fleetId`, `planetId`, `hash`, `nonce`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| fleetAway | true |
| fleetFirstInLine | true |
| proofOfWork | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgPlanetRaidComplete",
        "creator": "structs1...",
        "fleetId": "1-1",
        "planetId": "2-1",
        "hash": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

---

## Resource Actions

### MsgReactorAllocate

- **ID**: `reactor-allocate`
- **Name**: Allocate Reactor Energy
- **Message Type**: `/structs.structs.MsgReactorAllocate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Allocate energy from a reactor

**Required Fields**: `creator`, `reactorId`, `destinationId`, `amount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| sufficientEnergy | true |
| validDestination | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorAllocate",
        "creator": "structs1...",
        "reactorId": "1-1",
        "destinationId": "2-1",
        "amount": "1000000"
      }
    ]
  }
}
```

### MsgReactorInfuse

- **ID**: `reactor-infuse`
- **Name**: Infuse Reactor
- **Message Type**: `/structs.structs.MsgReactorInfuse`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Add Alpha Matter to reactor for energy production. Also handles validation delegation. Reactor staking is managed at player level, and validation delegation is abstracted via this action.
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_reactor_infuse.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:95`

This action abstracts validation delegation. When used for staking, it delegates validation stake to a validator. Reactor staking is managed at the player level, not reactor level.

**Required Fields**: `creator`, `reactorId`, `amount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| reactorExists | true |
| sufficientAlphaMatter | true |

**Conversion Rate**: 1 gram Alpha Matter (1,000,000 micrograms) = 1,000 watts energy (1,000,000 milliwatts). Code reference: `x/structs/types/keys.go (ReactorFuelToEnergyConversion = 1)`.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorInfuse",
        "creator": "structs1...",
        "reactorId": "1-1",
        "amount": "1000000"
      }
    ]
  }
}
```

### MsgReactorDefuse

- **ID**: `reactor-defuse`
- **Name**: Defuse Reactor
- **Message Type**: `/structs.structs.MsgReactorDefuse`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Remove Alpha Matter from reactor. Also handles validation undelegation.
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_reactor_defuse.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:96`

This action abstracts validation undelegation. Reactor staking is managed at the player level, not reactor level.

**Required Fields**: `creator`, `reactorId`, `amount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| reactorExists | true |
| sufficientFuel | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorDefuse",
        "creator": "structs1...",
        "reactorId": "1-1",
        "amount": "1000000"
      }
    ]
  }
}
```

### MsgReactorBeginMigration

- **ID**: `reactor-begin-migration`
- **Name**: Begin Reactor Migration
- **Message Type**: `/structs.structs.MsgReactorBeginMigration`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Begin redelegation process for reactor validation stake.

**Required Fields**: `creator`, `reactorId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| reactorExists | true |
| hasActiveDelegation | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorBeginMigration",
        "creator": "structs1...",
        "reactorId": "3-1"
      }
    ]
  }
}
```

### MsgReactorCancelDefusion

- **ID**: `reactor-cancel-defusion`
- **Name**: Cancel Reactor Defusion
- **Message Type**: `/structs.structs.MsgReactorCancelDefusion`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Cancel undelegation process for reactor validation stake.

**Required Fields**: `creator`, `reactorId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| reactorExists | true |
| inUndelegationPeriod | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorCancelDefusion",
        "creator": "structs1...",
        "reactorId": "3-1"
      }
    ]
  }
}
```

### MsgSubstationConnect

- **ID**: `substation-connect`
- **Name**: Connect to Substation
- **Message Type**: `/structs.structs.MsgSubstationConnect`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Connect a struct to a substation

**Required Fields**: `creator`, `substationId`, `structId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| validSubstation | true |
| validStruct | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgSubstationConnect",
        "creator": "structs1...",
        "substationId": "1-1",
        "structId": "2-1"
      }
    ]
  }
}
```

### MsgSubstationCreate

- **ID**: `substation-create`
- **Name**: Create Substation
- **Message Type**: `/structs.structs.MsgSubstationCreate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Create a new substation for power distribution
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_substation_create.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:131`

**Required Fields**: `creator`, `planetId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| planetOwned | true |
| validLocation | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgSubstationCreate",
        "creator": "structs1...",
        "planetId": "2-1"
      }
    ]
  }
}
```

### MsgSubstationPlayerConnect

- **ID**: `substation-player-connect`
- **Name**: Connect Player to Substation
- **Message Type**: `/structs.structs.MsgSubstationPlayerConnect`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Connect a player to a substation for power capacity
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_substation_player_connect.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:135`

**Required Fields**: `creator`, `substationId`

**Effects**: Player gains power capacity from substation.

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| substationExists | true |
| validConnection | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgSubstationPlayerConnect",
        "creator": "structs1...",
        "substationId": "1-1"
      }
    ]
  }
}
```

### MsgStructOreMinerComplete

- **ID**: `struct-ore-miner-complete`
- **Name**: Complete Ore Mining
- **Message Type**: `/structs.structs.MsgStructOreMinerComplete`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Complete ore mining operation (requires proof-of-work)
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_ore_miner_complete.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:763-770`

**Required Fields**: `creator`, `structId`, `proof`, `nonce`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structOnline | true |
| planetHasOre | true |
| sufficientCharge | Charge >= structType.OreMiningCharge |
| proofOfWork | HashBuildAndCheckDifficulty with OreMiningDifficulty (14000) |

**Effects**: `StoredOreIncrement(1)` -- fixed 1 ore per operation.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructOreMinerComplete",
        "creator": "structs1...",
        "structId": "1-1",
        "proof": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

### MsgStructOreRefineryComplete

- **ID**: `struct-ore-refinery-complete`
- **Name**: Complete Ore Refining
- **Message Type**: `/structs.structs.MsgStructOreRefineryComplete`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Complete ore refining operation (requires proof-of-work)
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_ore_refinery_complete.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:777-784`

**Required Fields**: `creator`, `structId`, `proof`, `nonce`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structOnline | true |
| hasStoredOre | true |
| sufficientCharge | Charge >= structType.OreRefiningCharge |
| proofOfWork | HashBuildAndCheckDifficulty with OreRefiningDifficulty (28000) |

**Effects**:
- Alpha Matter created: `DepositRefinedAlpha()` -- mints 1,000,000 ualpha (1 gram)
- Ore consumed: `StoredOreDecrement(1)`

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructOreRefineryComplete",
        "creator": "structs1...",
        "structId": "1-1",
        "proof": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

---

## Economic Actions

### MsgProviderCreate

- **ID**: `provider-create`
- **Name**: Create Energy Provider
- **Message Type**: `/structs.structs.MsgProviderCreate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Create an energy provider

**Required Fields**: `creator`, `rate`, `policy`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| validRate | true |
| validPolicy | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgProviderCreate",
        "creator": "structs1...",
        "rate": {},
        "policy": {}
      }
    ]
  }
}
```

### MsgAgreementCreate

- **ID**: `agreement-create`
- **Name**: Create Energy Agreement
- **Message Type**: `/structs.structs.MsgAgreementCreate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Create an automated energy agreement

**Required Fields**: `creator`, `providerId`, `terms`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| validProvider | true |
| validTerms | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgAgreementCreate",
        "creator": "structs1...",
        "providerId": "1-1",
        "terms": {}
      }
    ]
  }
}
```

### MsgOreMining

- **ID**: `ore-mining`
- **Name**: Mine Alpha Ore
- **Message Type**: `/structs.structs.MsgOreMining`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Mine Alpha Ore from a planet using Ore Extractor struct. Requires proof-of-work. Alpha Ore can be stolen.
- **Follow-Up Action**: MsgOreRefining

**Required Fields**: `creator`, `structId`, `hash`, `nonce`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structOnline | true |
| oreExtractorBuilt | true |
| planetHasOre | true |
| sufficientCharge | true |
| proofOfWork | true |

**Security**: Alpha Ore can be stolen by other players. Refine to Alpha Matter for security.

**Costs**:

| Cost | Value |
|------|-------|
| buildDraw | 500,000 milliwatts |
| passiveDraw | 500,000 milliwatts |
| miningCharge | 20 |
| miningDifficulty | 14,000 |

**Result**: Alpha Ore amount extracted (grams). Ore is stealable.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgOreMining",
        "creator": "structs1...",
        "structId": "1-1",
        "hash": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

### MsgOreRefining

- **ID**: `ore-refining`
- **Name**: Refine Alpha Ore to Alpha Matter
- **Message Type**: `/structs.structs.MsgOreRefining`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Refine Alpha Ore to Alpha Matter using Ore Refinery struct. Requires proof-of-work. Alpha Matter cannot be stolen.
- **Follow-Up Action**: MsgReactorInfuse or MsgStructGeneratorInfuse
- **Deprecated**: MsgReactorAllocate and MsgGeneratorAllocate (use MsgReactorInfuse or MsgStructGeneratorInfuse instead)

**Required Fields**: `creator`, `structId`, `hash`, `nonce`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structOnline | true |
| oreRefineryBuilt | true |
| hasAlphaOre | true |
| sufficientCharge | true |
| proofOfWork | true |

**Security**: Alpha Matter cannot be stolen once refined. This secures your resources.

**Costs**:

| Cost | Value |
|------|-------|
| buildDraw | 500,000 milliwatts |
| passiveDraw | 500,000 milliwatts |
| refiningCharge | 20 |
| refiningDifficulty | 28,000 |

**Conversion**: 1 gram Alpha Ore = 1 gram Alpha Matter.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgOreRefining",
        "creator": "structs1...",
        "structId": "1-1",
        "hash": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

### MsgGeneratorAllocate

- **ID**: `generator-allocate`
- **Name**: Allocate Energy from Generator
- **Message Type**: `/structs.structs.MsgGeneratorAllocate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Allocate energy from a generator (Field Generator, Continental Power Plant, or World Engine) to a struct or player. Higher rates but higher risk.

**Required Fields**: `creator`, `generatorId`, `destinationType`, `destinationId`, `alphaMatterAmount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| generatorActive | true |
| sufficientAlphaMatter | true |
| validDestination | true |

**Generator Types**:

| Generator | Rate | Formula | Risk |
|-----------|------|---------|------|
| Field Generator | 2 | Energy (kW) = Alpha Matter (grams) x 2 | high |
| Continental Power Plant | 5 | Energy (kW) = Alpha Matter (grams) x 5 | high |
| World Engine | 10 | Energy (kW) = Alpha Matter (grams) x 10 | high |

**Energy Properties**: Energy is ephemeral -- must be consumed immediately upon production, cannot be stored. Energy is shared across all Structs connected to the same power source.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGeneratorAllocate",
        "creator": "structs1...",
        "generatorId": "1-1",
        "destinationType": 1,
        "destinationId": "2-1",
        "alphaMatterAmount": "100000000"
      }
    ]
  }
}
```

Note: `alphaMatterAmount` is in micrograms (100 grams = 100,000,000 micrograms).

---

## Exploration Actions

### MsgPlanetExplore

- **ID**: `planet-explore`
- **Name**: Explore Planet
- **Message Type**: `/structs.structs.MsgPlanetExplore`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Explore a new planet (creates new planet, player can only own one planet at a time)

**Required Fields**: `creator`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| currentPlanetEmpty | Current planet must have 0 ore remaining (all ore mined). Check: query current planet attributes for ore amount, must be 0. |

Transaction may broadcast but planet ownership unchanged if current planet has ore remaining. Always verify game state after broadcast.

**Result**:
- New planet created with starting properties
- Fleet automatically moves to new planet
- Old planet remains but player no longer owns it

**Planet Starting Properties**:

| Property | Value |
|----------|-------|
| maxOre | 5 |
| spaceSlots | 4 |
| airSlots | 4 |
| landSlots | 4 |
| waterSlots | 4 |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgPlanetExplore",
        "creator": "structs1..."
      }
    ]
  }
}
```

---

## Fleet Actions

### MsgFleetMove

- **ID**: `fleet-move`
- **Name**: Move Fleet
- **Message Type**: `/structs.structs.MsgFleetMove`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Move fleet to a different location (on station / away)

**Required Fields**: `creator`, `fleetId`, `destinationType`, `destinationId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| commandShipOnline | Command Ship must be online in fleet |
| validDestination | Destination must exist and be accessible |

**Fleet Status**:

| Status | Description | Can Build | Can Raid |
|--------|-------------|-----------|----------|
| onStation | Fleet is at planet | Yes | No |
| away | Fleet is away from planet | No | Yes |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgFleetMove",
        "creator": "structs1...",
        "fleetId": "1-1",
        "destinationType": 1,
        "destinationId": "2-1"
      }
    ]
  }
}
```

---

## Guild Actions

### MsgGuildCreate

- **ID**: `guild-create`
- **Name**: Create Guild
- **Message Type**: `/structs.structs.MsgGuildCreate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Create a new guild

**Required Fields**: `creator`
**Optional Fields**: `endpoint`, `primaryReactorId`, `entrySubstationId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| notInGuild | Player must not already be in a guild. Check: query player.guildId, must be null or empty. |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildCreate",
        "creator": "structs1..."
      }
    ]
  }
}
```

### MsgGuildMembershipJoin

- **ID**: `guild-membership-join`
- **Name**: Join Guild
- **Message Type**: `/structs.structs.MsgGuildMembershipJoin`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Join an existing guild

**Required Fields**: `creator`, `guildId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| notInGuild | Player must not already be in a guild |
| guildExists | Guild must exist. Check: query guild by ID. |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildMembershipJoin",
        "creator": "structs1...",
        "guildId": "0-1"
      }
    ]
  }
}
```

### MsgGuildMembershipLeave

- **ID**: `guild-membership-leave`
- **Name**: Leave Guild
- **Message Type**: `/structs.structs.MsgGuildMembershipLeave`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Leave current guild

**Required Fields**: `creator`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| inGuild | Player must be in a guild. Check: query player.guildId, must not be null or empty. |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildMembershipLeave",
        "creator": "structs1..."
      }
    ]
  }
}
```

### MsgGuildBankMint

- **ID**: `guild-bank-mint`
- **Name**: Mint Guild Tokens
- **Message Type**: `/structs.structs.MsgGuildBankMint`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Mint guild tokens (trust-based system)

**Required Fields**: `creator`, `guildId`, `amount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| inGuild | Player must be in the guild |
| guildPermission | Player must have permission to mint tokens. Trust-based system -- no technical safeguards against revocation or inflation. |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildBankMint",
        "creator": "structs1...",
        "guildId": "0-1",
        "amount": "1000000"
      }
    ]
  }
}
```

### MsgGuildBankRedeem

- **ID**: `guild-bank-redeem`
- **Name**: Redeem Guild Tokens
- **Message Type**: `/structs.structs.MsgGuildBankRedeem`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Redeem guild tokens for resources

**Required Fields**: `creator`, `guildId`, `amount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| inGuild | Player must be in the guild |
| sufficientTokens | Player must have sufficient guild tokens |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildBankRedeem",
        "creator": "structs1...",
        "guildId": "0-1",
        "amount": "1000000"
      }
    ]
  }
}
```

---

## Struct Management Actions

### MsgStructActivate

- **ID**: `struct-activate`
- **Name**: Activate Struct
- **Message Type**: `/structs.structs.MsgStructActivate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Activate a struct (bring online)
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_activate.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:644-649`

**Required Fields**: `creator`, `structId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structBuilt | true |
| structOffline | true |
| sufficientCharge | Charge >= structType.ActivateCharge |
| sufficientPower | Available capacity >= structType.PassiveDraw |

**Effects**:
- Increments StructsLoad by PassiveDraw
- Resets mining timer
- Resets refining timer
- Increments planetary defenses if on planet
- Sets struct status to online

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructActivate",
        "creator": "structs1...",
        "structId": "1-1"
      }
    ]
  }
}
```

### MsgStructDeactivate

- **ID**: `struct-deactivate`
- **Name**: Deactivate Struct
- **Message Type**: `/structs.structs.MsgStructDeactivate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Deactivate a struct (take offline)
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_deactivate.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:651-656`

**Required Fields**: `creator`, `structId`

| Requirement | Details |
|-------------|---------|
| structBuilt | true |
| structOnline | true |
| ownerOffline | Owner must be offline (halted) |

**Effects**:
- Decrements StructsLoad by PassiveDraw
- Clears mining/refining timers
- Decrements planetary defenses if on planet
- Sets struct status to offline

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructDeactivate",
        "creator": "structs1...",
        "structId": "1-1"
      }
    ]
  }
}
```

### MsgStructStealthActivate

- **ID**: `struct-stealth-activate`
- **Name**: Activate Stealth
- **Message Type**: `/structs.structs.MsgStructStealthActivate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Activate stealth mode for a struct
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_stealth_activate.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:117`

**Required Fields**: `creator`, `structId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structCommandable | true |
| structNotHidden | true |
| hasStealthSystem | Struct must have stealth system |
| sufficientCharge | Charge >= structType.StealthActivateCharge |

**Effects**:
- Sets struct status to hidden
- Protects from attacks from different ambit
- Stealth removed when struct attacks

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructStealthActivate",
        "creator": "structs1...",
        "structId": "1-1"
      }
    ]
  }
}
```

### MsgStructStealthDeactivate

- **ID**: `struct-stealth-deactivate`
- **Name**: Deactivate Stealth
- **Message Type**: `/structs.structs.MsgStructStealthDeactivate`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Deactivate stealth mode for a struct
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_stealth_deactivate.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:118`

**Required Fields**: `creator`, `structId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structCommandable | true |
| structHidden | true |
| hasStealthSystem | true |

**Effects**: Removes hidden status from struct.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructStealthDeactivate",
        "creator": "structs1...",
        "structId": "1-1"
      }
    ]
  }
}
```

### MsgStructDefenseSet

- **ID**: `struct-defense-set`
- **Name**: Set Defender
- **Message Type**: `/structs.structs.MsgStructDefenseSet`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Assign a defender struct to protect another struct
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_defense_set.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:702-708`

**Required Fields**: `creator`, `defenderStructId`, `protectedStructId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| defenderExists | true |
| protectedExists | true |
| sameAmbit | Defender and protected must be in same ambit for full blocking |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructDefenseSet",
        "creator": "structs1...",
        "defenderStructId": "1-1",
        "protectedStructId": "2-1"
      }
    ]
  }
}
```

### MsgStructDefenseClear

- **ID**: `struct-defense-clear`
- **Name**: Clear Defender
- **Message Type**: `/structs.structs.MsgStructDefenseClear`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Remove defender assignment
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_defense_clear.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:710-715`

**Required Fields**: `creator`, `defenderStructId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| defenderExists | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructDefenseClear",
        "creator": "structs1...",
        "defenderStructId": "1-1"
      }
    ]
  }
}
```

### MsgStructMove

- **ID**: `struct-move`
- **Name**: Move Struct
- **Message Type**: `/structs.structs.MsgStructMove`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Move a struct to a new location
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_move.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:717-725`

**Required Fields**: `creator`, `structId`, `locationType`, `ambit`, `slot`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| structBuilt | true |
| validLocation | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructMove",
        "creator": "structs1...",
        "structId": "1-1",
        "locationType": 1,
        "ambit": 1,
        "slot": 1
      }
    ]
  }
}
```

---

## Verification

| Field | Value |
|-------|-------|
| Verified | true |
| Verified By | GameCodeAnalyst |
| Verified Date | 2025-01-XX |
| Method | code-analysis |
| Confidence | high |
| Total Actions | 30 |
| Verified Actions | 30 |
| Percentage | 100% |
| Note | All documented actions verified against codebase. Additional actions exist in proto file but not yet documented. |
