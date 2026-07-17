# Action Quick Reference

**Version**: 1.1.0  
**Last Updated**: January 16, 2026  
**Purpose**: Quick reference guide for AI agents performing game actions

---

## Overview

This guide provides a quick reference for all game actions available to AI agents. For complete action definitions, see `schemas/actions.md` and `reference/action-index.md`.

**All actions are submitted as transactions** to: `POST /cosmos/tx/v1beta1/txs`

**See**: `protocols/action-protocol.md` for complete transaction flow

---

## Action Categories

### Construction Actions

**Build Struct**:
- `struct-build-initiate` - Start building (first step)
- `struct-build-complete` - Complete building (requires proof-of-work)

**Requirements**:
- Player online
- Sufficient resources
- Valid location
- Command Ship online (if building on planet)
- Fleet on station (if building on planet)
- Sufficient power capacity

**See**: `reference/action-index.md#struct-build-initiate`

---

### Struct Management Actions

**Activate/Deactivate**:
- `struct-activate` - Activate struct (bring online)
- `struct-deactivate` - Deactivate struct (take offline)
- `struct-deactivate-batch` - Deactivate up to 65 structs in one transaction
- `struct-stealth-activate` - Activate with stealth
- `struct-stealth-deactivate` - Deactivate stealth

**Trash**:
- `struct-trash` - Permanently destroy a built struct you own (costs `buildCharge`, irreversible)

**Move/Defense**:
- `struct-move` - Move struct to new location
- `struct-defense-set` - Set defense mode
- `struct-defense-clear` - Clear defense mode

**Requirements**:
- `struct-activate` requires the player online, sufficient charge (`activateCharge` = 2), and sufficient power
- `struct-deactivate` / `struct-deactivate-batch` do **not** require the player online (recovery actions) and cost no charge; the struct(s) must be built and currently online
- `struct-trash` requires charge equal to the type's `buildCharge` (8) and resets the charge bar; the struct must be built and not already destroyed
- `struct-move` requires a valid location

---

### Combat Actions

**Attack**:
- `struct-attack` - Attack another struct

**Raid**:
- `planet-raid-complete` - Complete planet raid (requires proof-of-work)

**Requirements (attack)**:
- Attacking struct online, and its owner online (the attacker's Command Ship does not need to be online)
- Sufficient charge
- Valid target — the target must be a built struct (an unbuilt struct is rejected with `unbuilt`, a destroyed one with `destroyed`); the target's online status is irrelevant

**Requirements (raid)**:
- Raider's player online
- Fleet away
- Defender's shields vulnerable — defender's fleet off-station, or their Command Ship offline/destroyed/non-existent (otherwise `shields_active`)
- Raid clock started (`blockStartRaid` != 0)
- Proof-of-work

---

### Resource Actions

**Mining**:
- `struct-ore-mine-complete` - Complete ore mining (requires proof-of-work)
- `struct-ore-refine-complete` - Complete ore refining (requires proof-of-work)

**Power**:
- `reactor-infuse` - Infuse reactor with resources (produces energy). Also handles validation delegation
- `reactor-defuse` - Defuse reactor (remove resources). Also handles validation undelegation
- `reactor-begin-migration` - Begin redelegation process for reactor validation stake
- `reactor-cancel-defusion` - Cancel undelegation process for reactor validation stake
- `substation-create` - Create substation
- `substation-player-connect` - Connect player to substation
- `substation-allocation-connect` - Connect an allocation to a substation as its energy source

**Reactor Staking**:
- Reactor staking is now managed at player level
- Validation delegation is abstracted via Reactor Infuse/Defuse actions
- Use `reactor-infuse` for delegation, `reactor-defuse` for undelegation
- Use `reactor-begin-migration` to begin redelegation
- Use `reactor-cancel-defusion` to cancel undelegation

**Requirements**:
- Player online
- Sufficient charge (for mining)
- Proof-of-work (for mining/refining)
- Valid struct type

---

### Economic Actions

**Providers**:
- `provider-create` - Create energy provider

**Agreements**:
- `agreement-open` - Open energy agreement

**Mining/Refining**:
- `struct-ore-mine-complete` - Complete ore mining (requires proof-of-work)
- `struct-ore-refine-complete` - Complete ore refining (requires proof-of-work)

**Generators**:
- `struct-generator-infuse` - Infuse generator with Alpha Matter (produces energy)

**Requirements**:
- Player online
- Sufficient resources
- Valid parameters

---

### Exploration Actions

**Planet Exploration**:
- `planet-explore` - Explore a planet; optional `[name]` sets display name at creation

**Requirements**:
- Player online
- Valid planet
- Sufficient resources

---

### Fleet Actions

**Fleet Movement**:
- `fleet-move` - Move fleet (on station ↔ away)

**Requirements**:
- Player online
- Command Ship online
- Valid destination

---

### Guild Actions

**Guild Management**:
- `guild-create` - Create guild from a reactor (requires `PermReactorGuildCreate` on reactor)
- `guild-update-entry-rank` - Update default rank for new members (requires `PermUpdate` on guild)
- `guild-membership-join` - Join guild
- `guild-membership-join-proxy` - Sign a new player into the guild on their behalf; accepts optional `--player-name` and `--player-pfp` flags to seed the new player's UGC fields immediately
- `guild-membership-kick` - Remove member from guild
- `player-update-guild-rank` - Set a player's guild rank (requires `PermAdmin` on guild or rank-based authority)

**Guild Bank**:
- `guild-bank-mint` - Mint guild tokens
- `guild-bank-redeem` - Redeem guild tokens

**Token Transfer**:
- `player-send` - Send tokens via structs module (requires `PermTokenTransfer`)

**UGC Identity**:
- `guild-update-name` - Rename a guild (requires `PermUpdate` on guild)
- `guild-update-pfp` - Set guild profile picture (requires `PermUpdate` on guild)
- `guild-update-primary-reactor` - Reassign primary reactor (recovery for retired/jailed validator; requires `PermAdmin` on guild)
- `player-update-name` - Rename a player (self-service via `PermUpdate` on the player, OR guild moderation via `PermGuildUGCUpdate` on the player's guild)
- `player-update-pfp` - Set a player's profile picture (same permission rules as player-update-name)
- `player-update-pfp-client-render-attributes` - Set/clear render hints (JSON object, ≤512 bytes) for a locally-rendered pfp (owner-only, not guild-moderatable)
- `planet-update-name` - Rename a planet (self-service via `PermUpdate`, OR guild moderation via `PermGuildUGCUpdate` on the planet owner's guild)
- `substation-update-name` - Rename a substation (same permission rules as planet-update-name applied to the substation owner's guild)
- `substation-update-pfp` - Set a substation's profile picture (same permission rules as substation-update-name)

See `knowledge/mechanics/ugc-moderation.md` for the validation rules every name/pfp value must satisfy.

**Requirements**:
- Player online
- Sufficient resources (for create/mint)
- Valid guild (for membership/bank)
- Appropriate permissions (see `knowledge/mechanics/permissions.md`)

---

### Permission Actions

**Object Permissions**:
- `permission-grant-on-object` - Add permission flags on an object (bitwise OR)
- `permission-revoke-on-object` - Remove permission flags from an object (bitwise AND NOT)
- `permission-set-on-object` - Replace entire permission value on an object

**Address Permissions**:
- `permission-grant-on-address` - Add permission flags on an address
- `permission-revoke-on-address` - Remove permission flags from an address
- `permission-set-on-address` - Replace entire permission value on an address

**Guild Rank Permissions**:
- `permission-guild-rank-set` - Set guild rank permission on an object (decomposes bitmask)
- `permission-guild-rank-revoke` - Revoke guild rank permission from an object

**Requirements**:
- Caller must already have the permission flags being granted/revoked/set
- See `knowledge/mechanics/permissions.md` for the 25-bit flag reference (bit 24 = `PermGuildUGCUpdate`)

---

### Allocation Actions

- `allocation-create` - Create energy allocation (controller is PlayerId)
- `allocation-update` - Update allocation power
- `allocation-delete` - Delete allocation
- `allocation-transfer` - Transfer allocation controller

---

### Provider/Agreement Actions

- `provider-create` - Create energy provider
- `provider-delete` - Delete provider
- `provider-withdraw-balance` - Withdraw earnings
- `provider-update-capacity-minimum/maximum` - Update capacity limits
- `provider-update-duration-minimum/maximum` - Update duration limits
- `provider-update-access-policy` - Update access policy
- `agreement-open` - Open energy agreement
- `agreement-close` - Close agreement
- `agreement-capacity-increase/decrease` - Adjust capacity
- `agreement-duration-increase` - Extend agreement

---

### Substation Actions

- `substation-create` - Create substation
- `substation-delete` - Delete substation
- `substation-player-connect` - Connect player to substation
- `substation-player-disconnect` - Disconnect player from substation
- `substation-player-migrate` - Migrate player between substations
- `substation-allocation-connect` - Connect allocation to substation
- `substation-allocation-disconnect` - Disconnect allocation from substation

---

## Common Requirements

### Player Requirements

**Player Online**:
- Player must not be halted
- Check: `GET /structs/player/{id}` → `player.halted === false`

**Sufficient Resources**:
- Player must have required resources
- Check: Query player resources before action

### Struct Requirements

**Sufficient Charge** (per-player, not per-struct):
- The acting **player** must have accumulated the required charge on their single shared bar
- Check: `GET /structs/player/{id}` → `player.charge >= required` (charge = `CurrentBlockHeight - player.lastActionBlock`)
- Note: `ActivateCharge` is 2 for all struct types (genesis default); see [building.md](../knowledge/mechanics/building.md#charge-accumulation) for the full cost table
- Exception: Build cancel actions do not require charge or player online

**Sufficient Power**:
- Player must have power capacity > struct passive draw
- Check: Query player power capacity

**Command Ship Online**:
- Command Ship must be built AND online
- Check: Query fleet for Command Ship struct

**Fleet Status**:
- Fleet must be on station (for building)
- Fleet must be away (for raids)
- Check: Query fleet status

### Location Requirements

**Valid Location**:
- Location must be valid and accessible
- Check: Query location before action

**Valid Target**:
- Target must be valid and attackable
- Check: Query target before attack

---

## Action Patterns

### Pattern 1: Single Action

**Use Case**: Simple action, no dependencies

**Flow**:
1. Check requirements
2. Build transaction
3. Sign transaction
4. Submit transaction
5. Wait for confirmation
6. Verify action occurred

**Example**: `struct-activate`, `struct-deactivate`

---

### Pattern 2: Two-Step Action

**Use Case**: Action requires two steps

**Flow**:
1. Step 1: Initiate action
2. Wait for confirmation
3. Query state (wait for intermediate state)
4. Step 2: Complete action
5. Wait for confirmation
6. Verify action occurred

**Examples**:
- `struct-build-initiate` → `struct-build-complete`
- Mining: Initiate → Complete (with proof-of-work)

---

### Pattern 3: Action with Proof-of-Work

**Use Case**: Action requires proof-of-work computation

**Flow**:
1. Initiate action
2. Wait for confirmation
3. Query struct state
4. Compute proof-of-work
5. Complete action with proof
6. Wait for confirmation
7. Verify action occurred

**Examples**:
- `struct-build-complete`
- `planet-raid-complete`
- `struct-ore-mine-complete`
- `struct-ore-refine-complete`

**See**: `protocols/action-protocol.md#proof-of-work` for proof-of-work details

---

### Pattern 4: Conditional Action

**Use Case**: Action depends on game state

**Flow**:
1. Query game state
2. Check preconditions
3. If conditions met: Execute action
4. If conditions not met: Wait or abort
5. Verify action occurred

**Example**: Attack only if target is valid and attackable

---

## Transaction Flow

### Complete Flow

```json
{
  "flow": [
    {
      "step": 1,
      "action": "Get account info",
      "endpoint": "GET /cosmos/auth/v1beta1/accounts/{address}"
    },
    {
      "step": 2,
      "action": "Build transaction",
      "message": "Action message (e.g., MsgStructBuild)"
    },
    {
      "step": 3,
      "action": "Sign transaction",
      "method": "Sign with private key"
    },
    {
      "step": 4,
      "action": "Submit transaction",
      "endpoint": "POST /cosmos/tx/v1beta1/txs"
    },
    {
      "step": 5,
      "action": "Wait for confirmation",
      "check": "Transaction status"
    },
    {
      "step": 6,
      "action": "Verify action occurred",
      "method": "Query game state"
    }
  ]
}
```

**See**: `protocols/action-protocol.md` for complete details

---

## Validation Warning

⚠️ **IMPORTANT**: Transaction status `broadcast` does NOT mean action succeeded!

**Validation happens on-chain** after broadcast:
1. Transaction broadcasts successfully
2. on-chain validation checks requirements
3. Action succeeds OR fails based on validation
4. **Always verify game state** to confirm action occurred

**Example**:
```json
{
  "scenario": "Build struct without sufficient resources",
  "result": {
    "transaction": "broadcast",
    "action": "failed",
    "reason": "Insufficient resources (validated on-chain)"
  },
  "verification": "Query struct - struct not created"
}
```

---

## Error Handling

### Common Errors

**Player Halted** (code: 6):
- Player is offline/halted
- **Action**: Wait for player to come online

**Insufficient Funds** (code: 2):
- Player doesn't have required resources
- **Action**: Check resources, wait, or abort

**Insufficient Charge** (code: 7):
- Struct doesn't have required charge
- **Action**: Wait for charge to accumulate

**Invalid Location** (code: 8):
- Location is invalid or inaccessible
- **Action**: Verify location, correct, and retry

**Invalid Target** (code: 9):
- Target is invalid or not attackable
- **Action**: Verify target, correct, and retry

**See**: `api/error-codes.md` for complete error catalog

---

## Quick Lookup

### By Category

**Construction**:
- `struct-build-initiate`
- `struct-build-complete`

**Combat**:
- `struct-attack`
- `planet-raid-complete`

**Resource**:
- `struct-ore-mine-complete`
- `struct-ore-refine-complete`
- `reactor-infuse` (validation delegation)
- `reactor-defuse` (validation undelegation)
- `substation-create`

**Economic**:
- `provider-create`
- `agreement-open`
- `struct-ore-mine-complete`
- `struct-ore-refine-complete`
- `struct-generator-infuse`

**Exploration**:
- `planet-explore`

**Fleet**:
- `fleet-move`

**Guild**:
- `guild-create`
- `guild-update-entry-rank`
- `guild-membership-join`
- `guild-bank-mint`
- `player-update-guild-rank`
- `player-send`

**Permissions**:
- `permission-grant-on-object`
- `permission-revoke-on-object`
- `permission-set-on-object`
- `permission-guild-rank-set`
- `permission-guild-rank-revoke`

### By Requirement

**Requires Proof-of-Work**:
- `struct-build-complete`
- `planet-raid-complete`
- `struct-ore-mine-complete`
- `struct-ore-refine-complete`

**Requires Charge**:
- `struct-activate`
- `struct-attack`
- `struct-ore-mine-complete`
- `struct-ore-refine-complete`

**Requires Command Ship**:
- `fleet-move`
- `planet-raid-complete`
- Building on planet

**Two-Step Process**:
- `struct-build-initiate` → `struct-build-complete`
- Mining: Initiate → Complete

---

## Related Documentation

**Action Definitions**:
- `schemas/actions.md` - Complete action schemas
- `reference/action-index.md` - Action index with metadata

**Protocols**:
- `protocols/action-protocol.md` - Complete action protocol
- `protocols/gameplay-protocol.md` - Gameplay interaction patterns
- `protocols/error-handling.md` - Error handling

**Patterns**:
- `patterns/workflow-patterns.md` - Multi-step workflow patterns
- `patterns/retry-strategies.md` - Retry patterns for failed actions

**Examples**:
- `examples/workflows/` - Workflow examples
- `examples/errors/` - Error examples

---

## Quick Tips

1. **Always check requirements** before submitting action
2. **Verify action occurred** by querying game state
3. **Handle errors gracefully** with retry logic
4. **Use two-step pattern** for build/mining actions
5. **Compute proof-of-work** for actions that require it
6. **Wait for confirmations** before proceeding
7. **Query game state** to verify action success
8. **Handle validation failures** appropriately

---

*Last Updated: January 1, 2026*

