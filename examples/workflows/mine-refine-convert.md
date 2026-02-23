# Mine, Refine, Convert Workflow

**Version**: 1.0.0
**ID**: mine-refine-convert
**Category**: Gameplay
**Type**: Workflow

---

## Resource Flow

| Stage | Resource | Security |
|-------|----------|----------|
| Mining | oreStored | Stealable |
| Refinement | alphaMatter | Secure |
| Conversion | watts | Secure |

## Steps

### 1. Monitor Mining Operation

Monitor mining operation status.

- **Action**: `queryMining`
- **Planet ID**: `2-1`
- **Extractor ID**: `extractor-1`

**Expected Response**:

```json
{
  "status": "mining",
  "currentOre": 4,
  "oreExtracted": 1,
  "oreStored": 1,
  "security": {
    "needsRefinement": true,
    "warning": "Ore can be stolen - refine immediately"
  }
}
```

### 2. Refine Ore to Alpha Matter (SECURE)

Refine ore to Alpha Matter immediately to secure resources.

- **Action**: `refine`
- **Planet ID**: `2-1`
- **Ore Amount**: `1`
- **Priority**: Immediate

**Condition**: `oreStored > 0`

**Expected Response**:

```json
{
  "status": "refined",
  "oreRefined": 1,
  "alphaMatterGained": 1,
  "security": {
    "alphaMatterSecure": true,
    "cannotBeStolen": true
  }
}
```

### 3. Evaluate Conversion Needs

Evaluate whether conversion is needed based on:

- Current Watts available
- Power consumption needs
- Reserve requirements (20-30%)

### 4. Convert Alpha Matter to Watts

Convert Alpha Matter to Watts using reactor.

- **Action**: `convertPower`
- **Method**: `reactor`
- **Alpha Matter Amount**: `1`
- **Maintain Reserve**: `true`

**Condition**: `wattsNeeded > 0`

**Expected Response**:

```json
{
  "status": "converted",
  "method": "reactor",
  "alphaMatterUsed": 1,
  "wattsGained": 1,
  "rate": "1g:1kW"
}
```

### 5. Continue Mining Loop

Return to Step 1 and continue the mining cycle.

## Principles

- Refine ore immediately to secure resources
- Maintain 20-30% Alpha Matter reserve
- Convert when needed, not all at once
- Monitor resource flow continuously
