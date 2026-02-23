# Skills Audit

**Date**: 2026-02-22
**Resolved**: 2026-02-22
**Source of truth**: `structsd query structs --help` and `structsd tx structs --help`
**Original finding**: Skills covered roughly 20% of the game's actual command surface.
**Resolution**: All 10 skills rewritten against CLI commands. Missing subsystems added. Broken references fixed. MCP tool names replaced with `structsd` commands.

---

## CLI Command Count

| Category | Query Commands | Transaction Commands |
|----------|---------------|---------------------|
| Address | 3 | 2 |
| Agreement | 3 | 5 |
| Allocation | 4 | 4 |
| Fleet | 3 | 1 |
| Grid | 2 | 0 |
| Guild | 6 | 20 |
| Infusion | 3 | 0 |
| Permission | 4 | 6 |
| Planet | 5 | 3 |
| Player | 3 | 2 |
| Provider | 6 | 10 |
| Reactor | 2 | 4 |
| Struct | 6 | 17 |
| Substation | 2 | 7 |
| Other | 3 | 0 |
| **Total** | **55** | **81** |

---

## Skill Coverage Map

### structs-onboarding
**Covers**: player creation, planet-explore, struct-build-initiate/compute/complete, struct-activate
**Missing**:
- No `player-create` in CLI -- how is a player actually created? Via address-register? Needs investigation.
- Substation setup (new players need power infrastructure)
- Guild joining (most new players should join a guild early)

**Broken references**: Points to deleted `tasks/onboarding.md` and `lifecycles/player-lifecycle.md`

### structs-mining
**Covers**: struct-ore-mine-compute, struct-ore-mine-complete, struct-ore-refine-compute, struct-ore-refine-complete
**Missing**: Nothing critical for mining itself. Reasonably accurate.
**Note**: CLI uses separate compute/complete steps (not workflow). Skill references MCP workflow tool which may not exist in non-MCP context.

### structs-building
**Covers**: struct-build-initiate, struct-build-compute, struct-build-complete, struct-activate
**Missing**:
- `struct-build-cancel` -- canceling unfinished builds
- `struct-deactivate` -- taking structs offline
- `struct-move` -- moving structs between ambits/slots/locations
- `struct-defense-set` / `struct-defense-clear` -- defensive positioning
- `struct-stealth-activate` / `struct-stealth-deactivate` -- stealth operations
- `struct-generator-infuse` -- infusing Alpha into generators (irreversible!)

### structs-combat
**Covers**: struct-attack, planet-raid (conceptually)
**Missing**:
- Raid is actually TWO commands: `planet-raid-compute` then `planet-raid-complete` (proof-of-work pattern)
- `struct-defense-set` / `struct-defense-clear` -- setting up defensive relationships
- Stealth operations for pre-combat positioning
- Fleet movement (`fleet-move`) as part of raid preparation

### structs-exploration
**Covers**: planet-explore
**Missing**:
- `fleet-move` -- moving fleet between planets (core to exploration)
- Grid queries (`grid`, `grid-all`) -- grid attributes are part of exploration

### structs-economy
**Covers**: Reactor infusion conceptually, energy agreements conceptually
**MASSIVELY INCOMPLETE**:
- **Provider lifecycle**: provider-create, provider-delete, provider-update-* (6 update commands), provider-withdraw-balance, provider-guild-grant, provider-guild-revoke
- **Agreement lifecycle**: agreement-open, agreement-close, agreement-capacity-increase/decrease, agreement-duration-increase
- **Allocation lifecycle**: allocation-create, allocation-delete, allocation-update, allocation-transfer
- **Reactor staking**: reactor-infuse, reactor-defuse, reactor-begin-migration, reactor-cancel-defusion
- **Generator infusion**: struct-generator-infuse (irreversible!)
- **Token operations**: player-send
- **Guild banking**: guild-bank-mint, guild-bank-redeem, guild-bank-confiscate-and-burn

### structs-guild
**Covers**: Guild operations at a very high level
**MASSIVELY INCOMPLETE**:
- **Guild creation**: guild-create
- **Membership**: 11 commands for invite/join/request/kick/approve/deny/revoke workflows
- **Guild settings**: 7 update commands (endpoint, entry-substation, join-infusion-minimum, etc.)
- **Banking**: guild-bank-mint, guild-bank-redeem, guild-bank-confiscate-and-burn
- **Owner transfer**: guild-update-owner-id

### structs-power
**Covers**: Power monitoring
**MISSING ENTIRELY**:
- **Substation lifecycle**: substation-create, substation-delete
- **Substation connections**: substation-allocation-connect/disconnect, substation-player-connect/disconnect/migrate
- **Allocation management**: allocation-create/delete/update/transfer

### structs-diplomacy
**Covers**: Alliance negotiation conceptually
**MISSING ENTIRELY**:
- **Permission system**: permission-grant/revoke/set on both address and object (6 commands)
- **Address management**: address-register, address-revoke

### structs-reconnaissance
**Covers**: Querying game state
**Reasonably accurate** for what it does. Could add: grid queries, infusion queries, permission queries.

---

## Entirely Uncovered Subsystems

| Subsystem | Commands | Impact |
|-----------|----------|--------|
| **Substation management** | 7 tx commands | Cannot manage power distribution without this |
| **Permission system** | 6 tx + 4 query | Cannot delegate authority or manage multi-address players |
| **Reactor staking** | 4 tx commands | Cannot stake/unstake Alpha Matter |
| **Provider lifecycle** | 10 tx commands | Cannot create or manage energy providers |
| **Stealth** | 2 tx commands | Cannot use stealth operations |
| **Struct defense** | 2 tx commands | Cannot set defensive relationships |
| **Struct movement** | 1 tx command | Cannot reposition structs |
| **Address management** | 2 tx commands | Cannot manage multi-address accounts |
| **Grid system** | 2 query commands | Cannot read grid attributes |

---

## Broken References (from deletions)

All skills should be audited for references to deleted files:
- `tasks/` -- deleted
- `lifecycles/` -- deleted
- `systems/` -- deleted
- `guides/` -- deleted
- `patterns/decision-tree-*` -- may still exist in patterns/ but should verify

---

## Recommendations (ALL RESOLVED)

1. ~~Rewrite all skills against CLI commands~~ -- DONE. All 10 skills use `structsd tx structs` / `structsd query structs`.
2. ~~Add missing subsystems~~ -- DONE. Substations in `structs-power`. Permissions in `structs-diplomacy`. Reactor staking, providers, allocations in `structs-economy`.
3. ~~Fix broken references~~ -- DONE. All `See Also` sections point to `knowledge/` and `awareness/` docs.
4. ~~Add error handling~~ -- DONE. Every skill has an Error Handling section.
5. ~~Investigate player creation~~ -- Noted in `structs-onboarding`: player creation likely via `address-register` or webapp. No CLI `player-create` exists.
