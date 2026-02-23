# Troubleshooting

**Version**: 1.0.0  
**Category**: Troubleshooting  
**Status**: Stable

## Overview

This directory contains troubleshooting guides for common issues AI agents encounter. All guides are based on actual playtesting and validation failures.

---

## Quick Start

1. **Identify Issue**: What action failed?
2. **Check Common Issues**: `common-issues.md` - Find your issue
3. **Check Error Codes**: `error-codes.md` - Understand error codes
4. **Follow Solution**: Apply recommended solution
5. **Verify Fix**: Confirm issue resolved

---

## Files in This Directory

### Core Guides

- **`common-issues.md`** - Common issues and solutions
- **`error-codes.md`** - Error code reference

### Feature-Specific Troubleshooting (v0.8.0-beta)

- **`reactor-staking-issues.md`** - Reactor staking and validation delegation troubleshooting
- **`permission-issues.md`** - Hash permission and permission bit manipulation troubleshooting
- **`edge-cases.md`** - Edge cases and gotchas for v0.8.0-beta features

---

## Common Issue Categories

### Building Issues
- Command Ship not online
- Fleet not onStation
- Insufficient power
- No available slots

### Exploration Issues
- Current planet has ore
- Player not online

### Transaction Issues
- Transaction broadcasts but action doesn't happen
- Transaction status unclear

### Resource Issues
- Insufficient power capacity
- Resource balances unavailable

---

## Troubleshooting Process

### Step 1: Identify Issue

1. What action were you trying?
2. What was expected?
3. What actually happened?
4. What's different?

### Step 2: Check Documentation

1. Review `common-issues.md` for your issue
2. Check `error-codes.md` for error meanings
3. Check feature-specific guides: `reactor-staking-issues.md`, `permission-issues.md`
4. Review `edge-cases.md` for non-obvious behaviors
5. Review relevant dependency chains
6. Check validation patterns

### Step 3: Apply Solution

1. Follow recommended solution
2. Fix missing requirements
3. Verify fixes
4. Retry action

### Step 4: Verify Success

1. Query game state
2. Compare expected vs actual
3. Confirm issue resolved

---

## Related Documentation

- **Dependencies**: `../dependencies/` - Dependency chains
- **Validation**: `../validation/` - Validation patterns
- **Tasks**: `../tasks/` - Task workflows
- **Schemas**: `../schemas/errors.md` - Error definitions

---

*Last Updated: January 1, 2026*  
*v0.8.0-beta: Added reactor staking, permission, and edge cases guides*

