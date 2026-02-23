# Action Index

**Version**: 1.1.0
**Last Updated**: 2026-01-01
**Description**: Complete index of all game actions for AI agents
**Verified**: Yes (by GameCodeAnalyst, 2026-01-01, method: code-analysis, confidence: high)

---

## Summary

| Metric | Count |
|--------|-------|
| Total Actions | 36 |
| Verified | 26 |
| Deprecated | 7 |
| Requires Proof-of-Work | 3 |
| Requires Charge | 5 |
| Requires Power | 1 |

### Actions by Category

| Category | Count |
|----------|-------|
| construction | 2 |
| combat | 2 |
| resource | 9 |
| economic | 5 |
| exploration | 1 |
| fleet | 1 |
| guild | 5 |
| struct-management | 7 |

---

## Construction Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| struct-build-initiate | Initiate Struct Build | `/structs.structs.MsgStructBuildInitiate` | Yes | Start building a struct (first step of two-step process) |
| struct-build-complete | Complete Struct Build | `/structs.structs.MsgStructBuildComplete` | Yes | Complete building a struct (requires proof-of-work) |

**Details**:

- **struct-build-initiate**: Code: `x/structs/keeper/msg_server_struct_build_initiate.go:18-88` | Proto: `proto/structs/structs/tx.proto:660-669` | Follow-up: struct-build-complete
- **struct-build-complete**: Code: `x/structs/keeper/msg_server_struct_build_complete.go:11-85` | Proto: `proto/structs/structs/tx.proto:672-679` | Requires proof-of-work

All construction actions use endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Struct Management Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| struct-activate | Activate Struct | `/structs.structs.MsgStructActivate` | Yes | Activate a struct (bring online) |
| struct-deactivate | Deactivate Struct | `/structs.structs.MsgStructDeactivate` | Yes | Deactivate a struct (take offline) |
| struct-stealth-activate | Activate Stealth | `/structs.structs.MsgStructStealthActivate` | Yes | Activate stealth mode for a struct |
| struct-stealth-deactivate | Deactivate Stealth | `/structs.structs.MsgStructStealthDeactivate` | Yes | Deactivate stealth mode for a struct |
| struct-defense-set | Set Defender | `/structs.structs.MsgStructDefenseSet` | Yes | Assign a defender struct to protect another struct |
| struct-defense-clear | Clear Defender | `/structs.structs.MsgStructDefenseClear` | Yes | Remove defender assignment |
| struct-move | Move Struct | `/structs.structs.MsgStructMove` | Yes | Move a struct to a new location |

**Details**:

- **struct-activate**: Code: `x/structs/keeper/msg_server_struct_activate.go` | Proto: `proto/structs/structs/tx.proto:644-649` | Requires charge, requires power
- **struct-deactivate**: Code: `x/structs/keeper/msg_server_struct_deactivate.go` | Proto: `proto/structs/structs/tx.proto:651-656`
- **struct-stealth-activate**: Code: `x/structs/keeper/msg_server_struct_stealth_activate.go` | Proto: `proto/structs/structs/tx.proto:117` | Requires charge
- **struct-stealth-deactivate**: Code: `x/structs/keeper/msg_server_struct_stealth_deactivate.go` | Proto: `proto/structs/structs/tx.proto:118`
- **struct-defense-set**: Code: `x/structs/keeper/msg_server_struct_defense_set.go` | Proto: `proto/structs/structs/tx.proto:702-708`
- **struct-defense-clear**: Code: `x/structs/keeper/msg_server_struct_defense_clear.go` | Proto: `proto/structs/structs/tx.proto:710-715`
- **struct-move**: Code: `x/structs/keeper/msg_server_struct_move.go` | Proto: `proto/structs/structs/tx.proto:717-725`

All struct management actions use endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Combat Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| struct-attack | Attack with Struct | `/structs.structs.MsgStructAttack` | Yes | Attack another struct |
| planet-raid-complete | Complete Planet Raid | `/structs.structs.MsgPlanetRaidComplete` | Yes | Complete a raid on a planet (requires proof-of-work) |

**Details**:

- **struct-attack**: Code: `x/structs/keeper/msg_server_struct_attack.go:13-184` | Proto: `proto/structs/structs/tx.proto:727-734` | Requires charge
- **planet-raid-complete**: Code: `x/structs/keeper/msg_server_planet_raid_complete.go:29-94` | Proto: `proto/structs/structs/tx.proto:515-522` | Requires proof-of-work

All combat actions use endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Resource Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| struct-ore-miner-complete | Complete Ore Mining | `/structs.structs.MsgStructOreMinerComplete` | Yes | Complete ore mining operation (requires proof-of-work) |
| struct-ore-refinery-complete | Complete Ore Refining | `/structs.structs.MsgStructOreRefineryComplete` | Yes | Complete ore refining operation (requires proof-of-work) |
| struct-generator-infuse | Infuse Generator with Alpha Matter | `/structs.structs.MsgStructGeneratorInfuse` | Yes | Infuse a generator struct with Alpha Matter to produce energy |
| reactor-infuse | Infuse Reactor | `/structs.structs.MsgReactorInfuse` | Yes | Add Alpha Matter to reactor for energy production |
| reactor-defuse | Defuse Reactor | `/structs.structs.MsgReactorDefuse` | Yes | Remove Alpha Matter from reactor |
| reactor-begin-migration | Begin Reactor Migration | `/structs.structs.MsgReactorBeginMigration` | No | Begin redelegation process for reactor validation stake (v0.8.0-beta) |
| reactor-cancel-defusion | Cancel Reactor Defusion | `/structs.structs.MsgReactorCancelDefusion` | No | Cancel undelegation process for reactor validation stake (v0.8.0-beta) |
| reactor-allocate | Allocate Reactor Energy | `/structs.structs.MsgReactorAllocate` | No | **DEPRECATED** -- Allocate energy from a reactor |
| substation-create | Create Substation | `/structs.structs.MsgSubstationCreate` | Yes | Create a new substation for power distribution |
| substation-player-connect | Connect Player to Substation | `/structs.structs.MsgSubstationPlayerConnect` | Yes | Connect a player to a substation for power capacity |
| substation-connect | Connect to Substation | `/structs.structs.MsgSubstationConnect` | No | **DEPRECATED** -- Connect a struct to a substation |
| substation-allocation-connect | Connect Allocation to Substation | `/structs.structs.MsgSubstationAllocationConnect` | Yes | Connect an allocation to a substation for power distribution |

**Details**:

- **struct-ore-miner-complete**: Code: `x/structs/keeper/msg_server_struct_ore_miner_complete.go` | Proto: `proto/structs/structs/tx.proto:763-770` | Requires proof-of-work (difficulty: 14000), requires charge
- **struct-ore-refinery-complete**: Code: `x/structs/keeper/msg_server_struct_ore_refinery_complete.go` | Proto: `proto/structs/structs/tx.proto:777-784` | Requires proof-of-work (difficulty: 28000), requires charge
- **struct-generator-infuse**: Code: `x/structs/keeper/msg_server_struct_generator_infuse.go` | Proto: `proto/structs/structs/tx.proto:120` | Generator rates: Field Generator 2 kW/g, Continental Power Plant 5 kW/g, World Engine 10 kW/g
- **reactor-infuse**: Code: `x/structs/keeper/msg_server_reactor_infuse.go` | Proto: `proto/structs/structs/tx.proto:95` | v0.8.0-beta: Abstracts validation delegation; reactor staking managed at player level
- **reactor-defuse**: Code: `x/structs/keeper/msg_server_reactor_defuse.go` | Proto: `proto/structs/structs/tx.proto:96` | v0.8.0-beta: Abstracts validation undelegation; reactor staking managed at player level
- **reactor-begin-migration**: v0.8.0-beta: Begins redelegation process for validation stake; reactor staking managed at player level
- **reactor-cancel-defusion**: v0.8.0-beta: Cancels ongoing undelegation process; reactor staking managed at player level
- **reactor-allocate**: **DEPRECATED** -- Message type does not exist. Energy allocation is handled via allocations and substations, not direct reactor allocation. See MsgAllocationCreate for creating allocations.
- **substation-create**: Code: `x/structs/keeper/msg_server_substation_create.go` | Proto: `proto/structs/structs/tx.proto:131`
- **substation-player-connect**: Code: `x/structs/keeper/msg_server_substation_player_connect.go` | Proto: `proto/structs/structs/tx.proto:135`
- **substation-connect**: **DEPRECATED** -- Message type does not exist. Use `substation-allocation-connect` (`MsgSubstationAllocationConnect`) instead. Replacement code: `x/structs/keeper/msg_server_substation_allocation_connect.go` | Proto: `proto/structs/structs/tx.proto:133`
- **substation-allocation-connect**: Code: `x/structs/keeper/msg_server_substation_allocation_connect.go` | Proto: `proto/structs/structs/tx.proto:133`

All resource actions use endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Economic Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| provider-create | Create Energy Provider | `/structs.structs.MsgProviderCreate` | Yes | Create an energy provider |
| agreement-open | Open Energy Agreement | `/structs.structs.MsgAgreementOpen` | Yes | Open an energy agreement with a provider |
| agreement-create | Create Energy Agreement | `/structs.structs.MsgAgreementCreate` | No | **DEPRECATED** -- Create an automated energy agreement |
| ore-mining | Mine Alpha Ore | `/structs.structs.MsgOreMining` | No | **DEPRECATED** -- Mine Alpha Ore from a planet |
| ore-refining | Refine Alpha Ore to Alpha Matter | `/structs.structs.MsgOreRefining` | No | **DEPRECATED** -- Refine Alpha Ore to Alpha Matter |
| generator-allocate | Allocate Energy from Generator | `/structs.structs.MsgGeneratorAllocate` | No | **DEPRECATED** -- Allocate energy from a generator |

**Details**:

- **provider-create**: Code: `x/structs/keeper/msg_server_provider_create.go` | Proto: `proto/structs/structs/tx.proto:83`
- **agreement-open**: Code: `x/structs/keeper/msg_server_agreement_open.go` | Proto: `proto/structs/structs/tx.proto:32`
- **agreement-create**: **DEPRECATED** -- Message type does not exist. Use `agreement-open` (`MsgAgreementOpen`) instead. Replacement code: `x/structs/keeper/msg_server_agreement_open.go` | Proto: `proto/structs/structs/tx.proto:32`
- **ore-mining**: **DEPRECATED** -- Message type does not exist. Use `struct-ore-miner-complete` (`MsgStructOreMinerComplete`) instead. Replacement code: `x/structs/keeper/msg_server_struct_ore_miner_complete.go` | Proto: `proto/structs/structs/tx.proto:122`
- **ore-refining**: **DEPRECATED** -- Message type does not exist. Use `struct-ore-refinery-complete` (`MsgStructOreRefineryComplete`) instead. Replacement code: `x/structs/keeper/msg_server_struct_ore_refinery_complete.go` | Proto: `proto/structs/structs/tx.proto:124`
- **generator-allocate**: **DEPRECATED** -- Message type does not exist. Use `struct-generator-infuse` (`MsgStructGeneratorInfuse`) instead. Replacement code: `x/structs/keeper/msg_server_struct_generator_infuse.go` | Proto: `proto/structs/structs/tx.proto:120`

All economic actions use endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Exploration Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| planet-explore | Explore Planet | `/structs.structs.MsgPlanetExplore` | Yes | Explore a new planet (creates new planet) |

**Details**:

- **planet-explore**: Code: `x/structs/keeper/msg_server_planet_explore.go` | Proto: `proto/structs/structs/tx.proto:77` | Requires empty planet

Endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Fleet Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| fleet-move | Move Fleet | `/structs.structs.MsgFleetMove` | Yes | Move fleet to a different location |

**Details**:

- **fleet-move**: Code: `x/structs/keeper/msg_server_fleet_move.go` | Proto: `proto/structs/structs/tx.proto:236-242` | Requires Command Ship

Endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Guild Actions

| ID | Name | Message Type | Verified | Description |
|----|------|-------------|----------|-------------|
| guild-create | Create Guild | `/structs.structs.MsgGuildCreate` | Yes | Create a new guild |
| guild-membership-join | Join Guild | `/structs.structs.MsgGuildMembershipJoin` | Yes | Join an existing guild |
| guild-membership-kick | Kick Guild Member | `/structs.structs.MsgGuildMembershipKick` | Yes | Remove a member from a guild |
| guild-bank-mint | Mint Guild Tokens | `/structs.structs.MsgGuildBankMint` | Yes | Mint guild tokens |
| guild-bank-redeem | Redeem Guild Tokens | `/structs.structs.MsgGuildBankRedeem` | Yes | Redeem guild tokens for resources |
| guild-membership-leave | Leave Guild | `/structs.structs.MsgGuildMembershipLeave` | No | **DEPRECATED** -- Leave current guild |

**Details**:

- **guild-create**: Code: `x/structs/keeper/msg_server_guild_create.go` | Proto: `proto/structs/structs/tx.proto:45`
- **guild-membership-join**: Code: `x/structs/keeper/msg_server_guild_membership_join.go` | Proto: `proto/structs/structs/tx.proto:60`
- **guild-membership-kick**: Code: `x/structs/keeper/msg_server_guild_membership_kick.go` | Proto: `proto/structs/structs/tx.proto:62`
- **guild-bank-mint**: Code: `x/structs/keeper/msg_server_guild_bank_mint.go` | Proto: `proto/structs/structs/tx.proto:46`
- **guild-bank-redeem**: Code: `x/structs/keeper/msg_server_guild_bank_redeem.go` | Proto: `proto/structs/structs/tx.proto:47`
- **guild-membership-leave**: **DEPRECATED** -- Message type does not exist. Use `guild-membership-kick` (`MsgGuildMembershipKick`) instead. Replacement code: `x/structs/keeper/msg_server_guild_membership_kick.go` | Proto: `proto/structs/structs/tx.proto:62`

All guild actions use endpoint: `POST /cosmos/tx/v1beta1/txs`

---

## Verification Notes

26 actions fully verified with code references. 7 actions are deprecated (marked with replacement actions). 1 action (reactor-allocate) is deprecated with no direct replacement (use allocation system). 4 replacement actions added: substation-allocation-connect, agreement-open, guild-membership-kick, struct-generator-infuse. v0.8.0-beta: Added reactor-begin-migration and reactor-cancel-defusion actions. Updated reactor-infuse and reactor-defuse with validation delegation functionality.
