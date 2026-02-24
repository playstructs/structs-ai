# Common Issues

**Version**: 1.0.0  
**Category**: Troubleshooting  
**Status**: Stable

## Overview

This document describes common issues AI agents encounter and how to resolve them. All issues are based on actual playtesting and validation failures.

---

## Issue Categories

### Building Issues
- [Building fails - Command Ship not online](#building-fails-command-ship-not-online)
- [Building fails - Fleet not onStation](#building-fails-fleet-not-onstation)
- [Building fails - Insufficient power](#building-fails-insufficient-power)
- [Building fails - No available slots](#building-fails-no-available-slots)

### Exploration Issues
- [Exploration fails - Current planet has ore](#exploration-fails-current-planet-has-ore)
- [Exploration fails - Player not online](#exploration-fails-player-not-online)

### Transaction Issues
- [Transaction broadcasts but action doesn't happen](#transaction-broadcasts-but-action-doesnt-happen)
- [Transaction status unclear](#transaction-status-unclear)

### Resource Issues
- [Insufficient power capacity](#insufficient-power-capacity)
- [Resource balances unavailable](#resource-balances-unavailable)

---

## Building Issues

### Building fails - Command Ship not online

**Symptom**: Transaction broadcasts but struct not created

**Cause**: Command Ship not built or not online

**Diagnosis**:
1. Query fleet for Command Ship struct
2. Check Command Ship status
3. If status != 'online', Command Ship not ready

**Solution**:
1. Build Command Ship in fleet (if not built)
2. Complete Command Ship build (proof-of-work)
3. Activate Command Ship
4. Verify Command Ship status = 'online'
5. Retry building

**Reference**: `dependencies/command-ship.md`

---

### Building fails - Fleet not onStation

**Symptom**: Transaction broadcasts but struct not created

**Cause**: Fleet is away (not onStation)

**Diagnosis**:
1. Query fleet status
2. Check if fleet.status == 'onStation'
3. If not, fleet is away

**Solution**:
1. Move fleet back to planet
2. Verify fleet.status == 'onStation'
3. Retry building

**Reference**: `dependencies/building.md`

---

### Building fails - Insufficient power

**Symptom**: Transaction broadcasts but struct not created

**Cause**: Insufficient power capacity

**Diagnosis**:
1. Query player power capacity
2. Calculate available power: `(capacity + capacitySecondary) - (load + structsLoad)`
3. Check struct power requirements: `buildPower + passivePower`
4. If available < required, insufficient power

**Solution**:
1. Increase power capacity (build power structs)
2. Reduce current load (deactivate structs)
3. Verify available power >= required
4. Retry building

**Reference**: `dependencies/building.md`

---

### Building fails - No available slots

**Symptom**: Transaction broadcasts but struct not created

**Cause**: No available slots on planet for struct type

**Diagnosis**:
1. Query planet slot counts
2. Query existing structs on planet
3. Calculate available slots: `planetSlots[slotType] - existingStructsInAmbit`
4. If available <= 0, no slots

**Solution**:
1. Choose different planet
2. Remove existing struct (if possible)
3. Verify available slots > 0
4. Retry building

**Reference**: `dependencies/building.md`

---

## Exploration Issues

### Exploration fails - Current planet has ore

**Symptom**: Transaction broadcasts but planet ownership unchanged

**Cause**: Current planet still has ore remaining

**Diagnosis**:
1. Query current planet attributes for ore amount
2. Check if currentOre > 0
3. If ore > 0, planet not complete

**Solution**:
1. Mine all ore from current planet
2. Verify ore amount = 0
3. Retry exploration

**Reference**: `dependencies/exploration.md`

---

### Exploration fails - Player not online

**Symptom**: Transaction broadcasts but planet ownership unchanged

**Cause**: Player is halted (offline)

**Diagnosis**:
1. Query player status
2. Check if player.online == true
3. If not, player is halted

**Solution**:
1. Wait for player to come online
2. Verify player.online == true
3. Retry exploration

**Reference**: `dependencies/exploration.md`

---

## Transaction Issues

### Transaction broadcasts but action doesn't happen

**Symptom**: Transaction status = 'broadcast' but action didn't occur

**Cause**: Validation failed on-chain (requirements not met)

**Diagnosis**:
1. Query game state after broadcast
2. Compare expected vs actual
3. Identify missing requirement
4. Check requirements list

**Solution**:
1. Identify missing requirement
2. Fix requirement
3. Retry action
4. Verify success

**Reference**: `validation/transaction-flow.md`

---

### Transaction status unclear

**Symptom**: Not sure if transaction succeeded

**Cause**: Not verifying game state after broadcast

**Diagnosis**:
1. Check transaction status
2. If 'broadcast', validation may have failed
3. Need to verify game state

**Solution**:
1. Always verify game state after broadcast
2. Query relevant entities
3. Compare expected vs actual
4. If mismatch, check requirements

**Reference**: `validation/verification.md`

---

## Resource Issues

### Insufficient power capacity

**Symptom**: Cannot build or operate structs

**Cause**: Power consumption exceeds capacity

**Diagnosis**:
1. Query player power attributes
2. Calculate: `availablePower = (capacity + capacitySecondary) - (load + structsLoad)`
3. If available < 0, insufficient capacity

**Solution**:
1. Build power generation structs
2. Reduce struct load (deactivate structs)
3. Increase power capacity
4. Verify available power > 0

**Reference**: `tasks/resource-management.md`

---

### Resource balances unavailable

**Symptom**: Cannot query resource balances

**Cause**: Resource data not accessible or player account issue

**Diagnosis**:
1. Check resource system status
2. Verify player account exists
3. Check query endpoint

**Solution**:
1. Verify player account exists
2. Check resource system status
3. Try alternative query methods
4. Contact support if persistent

**Reference**: `schemas/entities.md#/entities/Player`

---

## Resolved Issues

The following bugs have been resolved:

### GetInfusionByID Array Split Bug

**Status**: ✅ Resolved

**Description**: Bug in GetInfusionByID array split logic has been fixed.

**Impact**: Infusion queries now work correctly.

---

### EventGuildBankAddress Format Bug

**Status**: ✅ Resolved

**Description**: Bug in EventGuildBankAddress format has been fixed.

**Impact**: Guild bank address events now have correct format.

---

### BankAddress Format Logging Bug

**Status**: ✅ Resolved

**Description**: Bug in BankAddress format logging has been fixed.

**Impact**: Bank address logging now uses correct format.

---

### Fleet Movement Logic

**Status**: ✅ Resolved

**Description**: Fleet movement bug fixes and improvements have been applied.

**Impact**: Fleet movement is now more reliable with better validation and error handling.

---

## General Troubleshooting Steps

### Step 1: Identify the Issue

1. What action were you trying to perform?
2. What was the expected result?
3. What actually happened?
4. What's different?

### Step 2: Check Requirements

1. Review action requirements
2. Check dependency chains
3. Verify all requirements met
4. Identify missing requirements

### Step 3: Fix and Retry

1. Fix missing requirements
2. Verify fixes
3. Retry action
4. Verify success

### Step 4: If Still Failing

1. Review validation patterns
2. Check common failures
3. Review dependency chains
4. Consult error codes

---

## Related Documentation

- **Dependencies**: `../dependencies/` - Dependency chains
- **Validation**: `../validation/` - Validation patterns
- **Tasks**: `../tasks/` - Task workflows
- **Error Codes**: `../schemas/errors.md` - Error code definitions

---

*Last Updated: January 1, 2026*

