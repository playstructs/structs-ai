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
| resource | MsgReactorInfuse, MsgReactorDefuse, MsgReactorBeginMigration, MsgReactorCancelDefusion, MsgAllocationCreate, MsgAllocationUpdate, MsgAllocationDelete, MsgAllocationTransfer, MsgSubstationAllocationConnect, MsgSubstationCreate, MsgSubstationPlayerConnect, MsgStructOreMinerComplete, MsgStructOreRefineryComplete |
| economic | MsgProviderCreate, MsgAgreementOpen, MsgStructGeneratorInfuse |
| exploration | MsgPlanetExplore |
| fleet | MsgFleetMove |
| guild | MsgGuildCreate, MsgGuildMembershipJoin, MsgGuildMembershipKick, MsgGuildMembershipJoinProxy, MsgGuildBankMint, MsgGuildBankRedeem |
| ugc | MsgPlayerUpdateName, MsgPlayerUpdatePfp, MsgPlayerUpdatePfpClientRenderAttributes, MsgGuildUpdateName, MsgGuildUpdatePfp, MsgPlanetUpdateName, MsgSubstationUpdateName, MsgSubstationUpdatePfp |
| struct-management | MsgStructActivate, MsgStructDeactivate, MsgStructDeactivateBatch, MsgStructTrash, MsgStructStealthActivate, MsgStructStealthDeactivate, MsgStructDefenseSet, MsgStructDefenseClear, MsgStructMove |

## Common Requirements

| Requirement | Description |
|-------------|-------------|
| playerOnline | Player must be online (not halted) |
| sufficientResources | Player must have sufficient resources |
| sufficientCharge | Acting player must have sufficient charge (charge is a single per-player bar, not per-struct) |
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
| structOnline | true (the attacking struct, and its owner, must be online — the attacker's Command Ship does not need to be online) |
| sufficientCharge | true |
| validTarget | true (the target must be a built struct; an unbuilt struct is rejected with `unbuilt` and a destroyed struct with `destroyed`. The target's online status is irrelevant) |

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
| playerOnline | true (the raider's player must be online) |
| fleetAway | true |
| fleetFirstInLine | true |
| defenderShieldsVulnerable | true (defender's fleet off-station, or their Command Ship offline/destroyed/non-existent; otherwise rejected with `shields_active`) |
| raidClockStarted | true (`blockStartRaid` != 0; otherwise `raid_clock_unset`) |
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

### MsgSubstationAllocationConnect

- **ID**: `substation-allocation-connect`
- **Name**: Connect Allocation to Substation
- **Message Type**: `/structs.structs.MsgSubstationAllocationConnect`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Connect an allocation to a substation as its energy source

**Required Fields**: `creator`, `allocationId`, `destinationId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| validAllocation | true |
| validDestination | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgSubstationAllocationConnect",
        "creator": "structs1...",
        "allocationId": "6-1",
        "destinationId": "4-1"
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

**Effects**: Player gains `capacitySecondary` from the substation's `connectionCapacity`.

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

- **ID**: `struct-ore-mine-complete`
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

- **ID**: `struct-ore-refine-complete`
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

### MsgAgreementOpen

- **ID**: `agreement-open`
- **Name**: Open Energy Agreement
- **Message Type**: `/structs.structs.MsgAgreementOpen`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Open an energy agreement against a provider, renting `capacity` Watts for `duration` blocks

**Required Fields**: `creator`, `providerId`, `duration`, `capacity`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| validProvider | true |
| providerHasCapacity | true |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgAgreementOpen",
        "creator": "structs1...",
        "providerId": "10-1",
        "duration": "100000",
        "capacity": "50000"
      }
    ]
  }
}
```

### MsgStructGeneratorInfuse

- **ID**: `struct-generator-infuse`
- **Name**: Infuse a Generator
- **Message Type**: `/structs.structs.MsgStructGeneratorInfuse`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Infuse Alpha Matter into a generator struct (Field Generator, Continental Power Plant, or World Engine) to produce energy. Higher rates than a reactor but the Alpha Matter is annihilated (no defusion) and a raided generator takes the infused matter with it.

**Required Fields**: `creator`, `structId`, `infuseAmount`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| generatorOnline | true |
| sufficientAlphaMatter | true |

**Generator Types**:

| Generator | Rate | Formula |
|-----------|------|---------|
| Field Generator | 2 | Energy (kW) = Alpha Matter (grams) x 2 |
| Continental Power Plant | 5 | Energy (kW) = Alpha Matter (grams) x 5 |
| World Engine | 10 | Energy (kW) = Alpha Matter (grams) x 10 |

**Energy Properties**: Energy is ephemeral -- must be consumed immediately upon production, cannot be stored. Energy is shared across all Structs connected to the same power source.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructGeneratorInfuse",
        "creator": "structs1...",
        "structId": "20-1",
        "infuseAmount": "100000000"
      }
    ]
  }
}
```

Note: `infuseAmount` is in micrograms (100 grams = 100,000,000 micrograms).

---

## Exploration Actions

### MsgPlanetExplore

- **ID**: `planet-explore`
- **Name**: Explore Planet
- **Message Type**: `/structs.structs.MsgPlanetExplore`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Explore a new planet (creates new planet, player can only own one planet at a time). Optional `name` sets the planet display name at creation.

**Required Fields**: `creator`, `playerId`

**Optional Fields**: `name` — planet display name (validated before explore; same rules as `MsgPlanetUpdateName`)

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| currentPlanetEmpty | Only enforced if the player already owns a planet — current planet must have 0 ore remaining (all ore mined). New players exploring for the first time are exempt. |
| fleetOnStation | Only enforced if the player already owns a planet — fleet must be `onStation` at the current planet (not `away`). New players have no current planet, so this check is skipped. The chain rejects with `fleet must be onStation to explore` if violated. |

Transaction may broadcast but planet ownership unchanged if requirements are not met. Always verify game state after broadcast.

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
        "creator": "structs1...",
        "playerId": "1-42",
        "name": "MyPlanet"
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
- **Description**: Create a new guild from a reactor

**Required Fields**: `creator`, `reactorId`, `endpoint`, `entrySubstationId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| permReactorGuildCreate | Requires `PermReactorGuildCreate` (524288) on the reactor |
| permSubstationConnection | Also requires `PermSubstationConnection` (1024) on the entry substation |

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

### MsgGuildMembershipJoinProxy

- **ID**: `guild-membership-join-proxy`
- **Name**: Proxy Join Guild
- **Message Type**: `/structs.structs.MsgGuildMembershipJoinProxy`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: A guild member signs in a brand-new player on behalf of an unfunded address. Used during onboarding to bootstrap a player without requiring them to first acquire `ualpha` to pay fees. The proxy can also seed the new player's UGC name and pfp directly so the chain is the single source of truth for player identity from creation.

**Required Fields**: `creator`, `address`, `proofPubKey`, `proofSignature`
**Optional Fields**: `substationId` (override the guild's default entry substation), `playerName` (set new player's name immediately), `playerPfp` (set new player's pfp immediately)

| Requirement | Details |
|-------------|---------|
| permGuildMembership | Caller needs `PermGuildMembership` (512) on the guild |
| permSubstationConnection | Also `PermSubstationConnection` (1024) on the substation if `substationId` is set |
| validProof | `proofPubKey` and `proofSignature` must derive to `address` (secp256k1 sign-of-pubkey self-proof) |
| validPlayerName | If `playerName` is set, must satisfy `ValidatePlayerName` (3-20 runes, `^[\p{L}0-9\-_]{3,20}$`, NFC, no combining/bidi/object-id-shaped) |
| validPlayerPfp | If `playerPfp` is set, must satisfy `ValidatePfp` (see UGC actions) |

**Self-proof construction**: Sign the secp256k1 compressed pubkey bytes with the corresponding private key; submit the signature as `proofSignature`. The chain rederives the address from `proofPubKey` and rejects mismatches.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildMembershipJoinProxy",
        "creator": "structs1moderator...",
        "address": "structs1newplayer...",
        "proofPubKey": "Aqg...base64...",
        "proofSignature": "MEU...base64...",
        "substationId": "4-3",
        "playerName": "Andromeda7",
        "playerPfp": "ipfs://bafy..."
      }
    ]
  }
}
```

### MsgGuildMembershipKick

- **ID**: `guild-membership-kick`
- **Name**: Remove Guild Member
- **Message Type**: `/structs.structs.MsgGuildMembershipKick`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Remove a player from a guild (used both to leave your own guild and, with the right rank permission, to remove another member)

**Required Fields**: `creator`, `guildId`, `playerId`

| Requirement | Details |
|-------------|---------|
| playerOnline | true |
| inGuild | The target player must be in the guild. Check: query player.guildId matches `guildId`. |
| permission | Removing another member requires the appropriate guild rank permission on the guild. |

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgGuildMembershipKick",
        "creator": "structs1...",
        "guildId": "0-1",
        "playerId": "1-11"
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

### MsgGuildUpdateEntryRank

- **ID**: `guild-update-entry-rank`
- **Name**: Update Guild Entry Rank
- **Message Type**: `/structs.structs.MsgGuildUpdateEntryRank`
- **Description**: Update the default rank assigned to new guild members

**Required Fields**: `creator`, `newEntryRank`

| Requirement | Details |
|-------------|---------|
| permUpdate | Requires `PermUpdate` (4) on the guild |
| rankConstraint | New entry rank must be >= caller's own rank |

### MsgPlayerUpdateGuildRank

- **ID**: `player-update-guild-rank`
- **Name**: Update Player Guild Rank
- **Message Type**: `/structs.structs.MsgPlayerUpdateGuildRank`
- **Description**: Set a player's rank within their guild

**Required Fields**: `creator`, `playerId`, `guildRank`

| Requirement | Details |
|-------------|---------|
| permAdmin | Requires `PermAdmin` (2) on the guild; falls back to rank-based authority (actor rank must be strictly better than target's current rank) |

### MsgPlayerSend

- **ID**: `player-send`
- **Name**: Player Send Tokens
- **Message Type**: `/structs.structs.MsgPlayerSend`
- **Description**: Send tokens via the structs module (separate from bank-module send)

**Required Fields**: `creator`, `fromAddress`, `toAddress`, `amount`

| Requirement | Details |
|-------------|---------|
| permTokenTransfer | Requires `PermTokenTransfer` (16) on the player |

### MsgPermissionGuildRankSet

- **ID**: `permission-guild-rank-set`
- **Name**: Set Guild Rank Permission
- **Message Type**: `/structs.structs.MsgPermissionGuildRankSet`
- **Description**: Set guild rank permissions on an object. Combined bitmasks are decomposed into individual bits.

**Required Fields**: `creator`, `objectId`, `guildId`, `permission`, `rank`

| Requirement | Details |
|-------------|---------|
| callerHasPermission | Caller must already have the specified permission on the object |

### MsgPermissionGuildRankRevoke

- **ID**: `permission-guild-rank-revoke`
- **Name**: Revoke Guild Rank Permission
- **Message Type**: `/structs.structs.MsgPermissionGuildRankRevoke`
- **Description**: Revoke guild rank permissions from an object. Only specified bits are zeroed.

**Required Fields**: `creator`, `objectId`, `guildId`, `permission`

| Requirement | Details |
|-------------|---------|
| callerHasPermission | Caller must already have the specified permission on the object |

---

## UGC Actions

User-generated content (name and pfp) updates. All seven messages are part of the free-gas Structs path. The `Update*Name` and `Update*Pfp` messages on player, planet, and substation route through `UGCPermissionCheck` (self-service via `PermUpdate` on the target, OR guild moderation via `PermGuildUGCUpdate` on the target owner's guild). Guild rename/repfp uses the standard `PermissionCheck` with `PermUpdate` on the guild itself. Validation is enforced by `types.ValidatePlayerName` / `ValidateEntityName` / `ValidatePlanetName` / `ValidatePfp` (see `schemas/validation.md` and `knowledge/mechanics/ugc-moderation.md`). When the actor is not the target's owner, the chain emits a `ugc_moderated` event.

### MsgPlayerUpdateName

- **ID**: `player-update-name`
- **Name**: Update Player Name
- **Message Type**: `/structs.structs.MsgPlayerUpdateName`
- **Description**: Set or change a player's display name.

**Required Fields**: `creator`, `playerId`, `name`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the player **OR** `PermGuildUGCUpdate` (16777216) on the player's guild |
| validName | Must satisfy `ValidatePlayerName` (3-20 runes after NFC, `^[\p{L}0-9\-_]{3,20}$`, no spaces, apostrophes, combining marks, bidi/zero-width, or object-id-shaped strings) |

### MsgPlayerUpdatePfp

- **ID**: `player-update-pfp`
- **Name**: Update Player Pfp
- **Message Type**: `/structs.structs.MsgPlayerUpdatePfp`
- **Description**: Set or change a player's profile picture (URL or opaque identifier).

**Required Fields**: `creator`, `playerId`, `pfp`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the player **OR** `PermGuildUGCUpdate` (16777216) on the player's guild |
| validPfp | Must satisfy `ValidatePfp` (empty string clears; otherwise <=256 runes, no control/bidi/whitespace/`<>``"\\` chars; no `:` -> `^[A-Za-z0-9._/\-]{1,256}$`; with `:` -> scheme in {https, http, ipfs, ipns, ar} and parses cleanly) |

### MsgPlayerUpdatePfpClientRenderAttributes

- **ID**: `player-update-pfp-client-render-attributes`
- **Name**: Update Player Pfp Client Render Attributes
- **Message Type**: `/structs.structs.MsgPlayerUpdatePfpClientRenderAttributes`
- **Description**: Set or clear render hints (a JSON object) for a player's locally-rendered profile picture. Owner-only — not guild-moderatable.

**Required Fields**: `creator`, `playerId`, `pfpClientRenderAttributes`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the player (self-service only; does **not** route through `UGCPermissionCheck`) |
| validAttributes | Must satisfy `ValidatePfpClientRenderAttributes` (empty string clears; otherwise a JSON object <=512 bytes, stored compacted; arrays/scalars/malformed JSON rejected) |

### MsgGuildUpdateName

- **ID**: `guild-update-name`
- **Name**: Update Guild Name
- **Message Type**: `/structs.structs.MsgGuildUpdateName`
- **Description**: Rename a guild.

**Required Fields**: `creator`, `guildId`, `name`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the guild |
| validName | Must satisfy `ValidateEntityName` (3-20 runes after NFC, `^[\p{L}0-9\-_' ]{3,20}$`, no leading/trailing spaces, no double space, no combining marks, no bidi/zero-width, not object-id-shaped) |
| uniqueness | Names must be unique under `NormalizeName` (NFC + lowercase + trim) — chain rejects duplicates |

### MsgGuildUpdatePfp

- **ID**: `guild-update-pfp`
- **Name**: Update Guild Pfp
- **Message Type**: `/structs.structs.MsgGuildUpdatePfp`
- **Description**: Set or change a guild's profile picture.

**Required Fields**: `creator`, `guildId`, `pfp`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the guild |
| validPfp | Must satisfy `ValidatePfp` (see player-update-pfp) |

### MsgGuildUpdatePrimaryReactor

- **ID**: `guild-update-primary-reactor`
- **Name**: Update Guild Primary Reactor
- **Message Type**: `/structs.structs.MsgGuildUpdatePrimaryReactor`
- **Description**: Reassign the guild's primary reactor to a different (non-jailed) validator's reactor. Recovery path when the validator backing the current primary reactor is permanently retired/tombstoned.

**Required Fields**: `creator`, `guildId`, `reactorId`

| Requirement | Details |
|-------------|---------|
| permission | `PermAdmin` (2) on the guild |
| validator | Target reactor's validator must exist and not be jailed |

### MsgPlanetUpdateName

- **ID**: `planet-update-name`
- **Name**: Update Planet Name
- **Message Type**: `/structs.structs.MsgPlanetUpdateName`
- **Description**: Rename a planet (typically used by the planet's owner or a guild moderator).

**Required Fields**: `creator`, `planetId`, `name`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the planet **OR** `PermGuildUGCUpdate` (16777216) on the planet owner's guild |
| validName | Must satisfy `ValidatePlanetName` (3-25 runes after NFC, `^[\p{L}0-9\-_' ]{3,25}$`, no leading/trailing spaces, no double space, no combining marks, no bidi/zero-width, not object-id-shaped) |

### MsgSubstationUpdateName

- **ID**: `substation-update-name`
- **Name**: Update Substation Name
- **Message Type**: `/structs.structs.MsgSubstationUpdateName`
- **Description**: Rename a substation.

**Required Fields**: `creator`, `substationId`, `name`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the substation **OR** `PermGuildUGCUpdate` (16777216) on the substation owner's guild |
| validName | Must satisfy `ValidateEntityName` |

### MsgSubstationUpdatePfp

- **ID**: `substation-update-pfp`
- **Name**: Update Substation Pfp
- **Message Type**: `/structs.structs.MsgSubstationUpdatePfp`
- **Description**: Set or change a substation's profile picture.

**Required Fields**: `creator`, `substationId`, `pfp`

| Requirement | Details |
|-------------|---------|
| permission | `PermUpdate` (4) on the substation **OR** `PermGuildUGCUpdate` (16777216) on the substation owner's guild |
| validPfp | Must satisfy `ValidatePfp` |

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
| permission | Caller holds `PermPlay` on the struct (owner passes automatically) |
| structBuilt | true |
| structOnline | true |

Deactivate does **not** require the player to be online and costs no charge — it is a recovery action, so an overloaded (offline) player can always deactivate structs to get back under capacity.

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

### MsgStructDeactivateBatch

- **ID**: `struct-deactivate-batch`
- **Name**: Deactivate Structs (batch)
- **Message Type**: `/structs.structs.MsgStructDeactivateBatch`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Deactivate multiple structs (up to 65) in a single transaction
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_deactivate_batch.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:776-781`

**Required Fields**: `creator`, `structId` (a **list** of struct IDs)

| Requirement | Details |
|-------------|---------|
| batchSize | 1..=65 (`MaxStructDeactivateBatchSize`); empty or duplicate IDs are rejected |
| perStruct | Each struct must pass the same checks as `MsgStructDeactivate` (`PermPlay`, built, online) |

The batch is validated in full before any struct is deactivated — if any struct is ineligible the whole transaction fails and nothing changes. Same effects as `MsgStructDeactivate`, applied to each struct. No charge cost, no player-online requirement.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructDeactivateBatch",
        "creator": "structs1...",
        "structId": ["1-1", "1-2", "1-3"]
      }
    ]
  }
}
```

### MsgStructTrash

- **ID**: `struct-trash`
- **Name**: Trash Struct
- **Message Type**: `/structs.structs.MsgStructTrash`
- **Endpoint**: `POST /cosmos/tx/v1beta1/txs`
- **Description**: Permanently destroy a built struct you own. **Irreversible.**
- **Verified**: true
- **Code Reference**: `x/structs/keeper/msg_server_struct_trash.go`
- **Proto Reference**: `proto/structs/structs/tx.proto:817-822`

**Required Fields**: `creator`, `structId`

| Requirement | Details |
|-------------|---------|
| permission | Caller holds `PermPlay` on the struct (owner passes automatically) |
| structNotDestroyed | The struct must not already be destroyed |
| sufficientCharge | Owner charge >= structType.BuildCharge (trashing costs the same charge as building) |

**Effects**:
- Destroys the struct (frees its slot; same effect path as combat destruction)
- Resets the owner's charge bar (`Discharge`)

Use this to reclaim a slot occupied by an unwanted **built** struct. To abort an **unfinished** build instead, use `MsgStructBuildCancel`.

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructTrash",
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
