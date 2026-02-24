# Reactor Staking Troubleshooting

**Version**: 1.0.0  
**Category**: Troubleshooting  
**Status**: Stable  
**Last Updated**: January 1, 2026

## Overview

This guide helps troubleshoot issues with reactor staking and validation delegation. Reactor staking is managed at the player level, and validation delegation is abstracted via Reactor Infuse/Defuse actions.

---

## Common Issues

### Issue 1: Infuse Fails - Player Not Online

**Symptom**: `reactor-infuse` transaction broadcasts but delegation doesn't occur

**Cause**: Player is halted (offline)

**Diagnosis**:
1. Query player status: `GET /structs/player/{playerId}`
2. Check `player.online == true`
3. If `false`, player is halted

**Solution**:
1. Wait for player to come online
2. Verify `player.online == true`
3. Retry `reactor-infuse` action

**Reference**: `dependencies/energy-production.md`, `schemas/errors.md#/PLAYER_HALTED`

---

### Issue 2: Infuse Fails - Insufficient Alpha Matter

**Symptom**: `reactor-infuse` transaction fails with insufficient funds error

**Cause**: Player doesn't have enough Alpha Matter

**Diagnosis**:
1. Query player resources: `GET /structs/player/{playerId}`
2. Check `player.alphaMatter` amount
3. Compare to required amount for infuse
4. If insufficient, cannot infuse

**Solution**:
1. Acquire more Alpha Matter
2. Verify sufficient amount available
3. Retry `reactor-infuse` action

**Reference**: `schemas/errors.md#/INSUFFICIENT_FUNDS`, `protocols/economic-protocol.md`

---

### Issue 3: Delegation Status Unclear

**Symptom**: Not sure if delegation is active after infuse

**Cause**: Not checking reactor staking status

**Diagnosis**:
1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Check `reactor.staking.delegationStatus`
3. Expected values: `"active"`, `"undelegating"`, `"migrating"`

**Solution**:
1. Always query reactor after infuse/defuse
2. Verify `reactor.staking.delegationStatus` matches expected state
3. Check `reactor.staking.staked == true` for active delegation
4. Verify `reactor.staking.delegationAmount` matches expected amount

**Reference**: `schemas/entities/reactor.md`, `protocols/economic-protocol.md`

---

### Issue 4: Defuse Fails - Already Undelegating

**Symptom**: `reactor-defuse` fails when trying to undelegate

**Cause**: Delegation already in undelegation period

**Diagnosis**:
1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Check `reactor.staking.delegationStatus == "undelegating"`
3. If true, already in undelegation period

**Solution**:
1. Wait for undelegation period to complete
2. Or use `reactor-cancel-defusion` to cancel undelegation
3. Then retry defuse if needed

**Reference**: `schemas/actions.md#/reactor-cancel-defusion`, `protocols/economic-protocol.md`

---

### Issue 5: Migration Fails - Not in Correct State

**Symptom**: `reactor-begin-migration` fails

**Cause**: Delegation not in correct state for migration

**Diagnosis**:
1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Check `reactor.staking.delegationStatus`
3. Migration requires `"active"` or `"undelegating"` status

**Solution**:
1. Verify delegation status is `"active"` or `"undelegating"`
2. If `"migrating"`, migration already in progress
3. Wait for current migration to complete
4. Retry `reactor-begin-migration`

**Reference**: `schemas/actions.md#/reactor-begin-migration`, `protocols/economic-protocol.md`

---

### Issue 6: Cancel Defusion Fails - Not Undelegating

**Symptom**: `reactor-cancel-defusion` fails

**Cause**: Delegation not in undelegation state

**Diagnosis**:
1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Check `reactor.staking.delegationStatus != "undelegating"`
3. Cancel defusion only works when status is `"undelegating"`

**Solution**:
1. Verify delegation status is `"undelegating"`
2. If `"active"`, use `reactor-defuse` first
3. If `"migrating"`, cannot cancel
4. Retry `reactor-cancel-defusion` when status is `"undelegating"`

**Reference**: `schemas/actions.md#/reactor-cancel-defusion`, `protocols/economic-protocol.md`

---

### Issue 7: Staking Status Inconsistent Across Reactors

**Symptom**: Different reactors show different staking statuses

**Cause**: Staking is managed at player level, not reactor level

**Diagnosis**:
1. Query all player reactors: `GET /structs/reactor?ownerId={playerId}`
2. Check staking status across reactors
3. Note: Staking is player-level, but status may vary per reactor

**Solution**:
1. Understand that staking is player-level management
2. Individual reactors may show different delegation statuses
3. Check player-level staking information if available
4. Verify reactor-specific delegation amounts

**Reference**: `schemas/entities/reactor.md`, `protocols/economic-protocol.md#/reactor-staking`

---

## Verification Steps

### After Infuse

1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Verify `reactor.staking.staked == true`
3. Verify `reactor.staking.delegationStatus == "active"`
4. Verify `reactor.staking.delegationAmount` matches expected amount
5. Verify `reactor.validator` is set (if applicable)

### After Defuse

1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Verify `reactor.staking.delegationStatus == "undelegating"`
3. Wait for undelegation period
4. Verify `reactor.staking.staked == false` after period completes

### After Begin Migration

1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Verify `reactor.staking.delegationStatus == "migrating"`
3. Complete migration process
4. Verify new delegation status

### After Cancel Defusion

1. Query reactor: `GET /structs/reactor/{reactorId}`
2. Verify `reactor.staking.delegationStatus == "active"`
3. Verify `reactor.staking.staked == true`

---

## Error Codes

### Common Error Codes

- **Code 2**: `INSUFFICIENT_FUNDS` - Not enough Alpha Matter
- **Code 6**: `PLAYER_HALTED` - Player is offline
- **Code 7**: `INSUFFICIENT_CHARGE` - Not enough charge (if applicable)
- **Code 1**: `GENERAL_ERROR` - General error (retryable)

**See**: `schemas/errors.md` for complete error definitions

---

## Best Practices

### 1. Always Verify State

After any staking action, always query reactor to verify state changed as expected.

### 2. Check Player Status

Before attempting staking actions, verify player is online.

### 3. Monitor Delegation Status

Track delegation status changes to understand current state.

### 4. Handle Undelegation Periods

Account for undelegation periods when planning operations.

### 5. Use Migration for Redelegation

Use `reactor-begin-migration` for redelegation instead of defuse + infuse.

---

## Related Documentation

- **Economic Protocol**: `../protocols/economic-protocol.md` - Reactor staking workflows
- **Actions**: `../schemas/actions.md` - Reactor staking actions
- **Entities**: `../schemas/entities/reactor.md` - Reactor entity schema
- **Examples**: `../examples/economic-bot.md` - Reactor staking examples
- **Error Codes**: `../schemas/errors.md` - Error definitions

---

*Last Updated: January 1, 2026*

