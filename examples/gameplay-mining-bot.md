# Mining Bot Example

**Version**: 1.0.0
**Category**: Gameplay
**Purpose**: Mine Alpha Ore, refine to Alpha Matter, and convert to Watts

---

## Overview

This bot automates the full resource extraction pipeline in Structs: charting a planet to reveal resources, building an Ore Extractor, mining ore, refining it into Alpha Matter, and converting that matter into energy (Watts). The workflow loops continuously once the extractor is built.

## Resource Extraction Workflow

### Step 1: Chart Planet

Chart the target planet to reveal its resource deposits and ownership status.

Request:

```json
{
  "action": "chart",
  "planetId": "2-1"
}
```

Expected response:

```json
{
  "status": "charted",
  "revealed": {
    "resources": {
      "maxOre": 5,
      "currentOre": 5
    },
    "ownership": {
      "claimed": false
    }
  }
}
```

### Step 2: Build Ore Extractor

Build an Ore Extractor on the planet. Several preconditions must be verified before building.

Request:

```json
{
  "action": "build",
  "structType": "oreExtractor",
  "locationType": 1,
  "locationId": "2-1",
  "slot": "land",
  "verify": {
    "playerOnline": true,
    "fleetOnStation": true,
    "commandShipOnline": true,
    "sufficientPower": true,
    "availableSlot": true
  }
}
```

Expected response:

```json
{
  "status": "building",
  "structId": "extractor-1",
  "buildTime": 3600,
  "costs": {
    "buildPower": 500000,
    "passivePower": 500000
  }
}
```

### Step 3: Wait for Build

Wait for the extractor to finish building (approximately 3600 seconds).

### Step 4: Monitor Mining Operation

Once built, monitor the extractor's mining progress.

Request:

```json
{
  "action": "queryMining",
  "planetId": "2-1",
  "extractorId": "extractor-1"
}
```

Expected response:

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

Alpha Ore is vulnerable to theft. Refine it as soon as possible.

### Step 5: Refine Ore to Alpha Matter

Refine extracted ore into Alpha Matter, which cannot be stolen.

Request:

```json
{
  "action": "refine",
  "planetId": "2-1",
  "oreAmount": 1
}
```

Expected response:

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

### Step 6: Convert Alpha Matter to Watts

Convert Alpha Matter into energy using a Reactor.

Request:

```json
{
  "action": "convertPower",
  "method": "reactor",
  "alphaMatterAmount": 1
}
```

Expected response:

```json
{
  "status": "converted",
  "method": "reactor",
  "alphaMatterUsed": 1,
  "wattsGained": 1,
  "rate": "1g:1kW"
}
```

### Step 7: Loop

Return to Step 4 and continue the mining loop.

## Error Handling

**Insufficient power**: Convert Alpha Matter to Watts. If no Alpha Matter is available, wait for mining to produce more.

**Ore not refined**: Refine stored ore immediately to prevent theft. This is a security-critical recovery -- ore left unrefined is vulnerable to raids.

**Player offline**: Query power status to confirm the player is online. If offline, reduce consumption or increase capacity to bring the player back online.

## Optimization Strategy

- **Refine immediately**: Always refine ore as soon as it is extracted to protect against theft.
- **Convert when needed**: Only convert Alpha Matter to Watts when energy is required, rather than converting everything upfront.
- **Maintain reserves**: Keep 20% of Alpha Matter and 20% of Watts in reserve for unexpected needs.

## Cross-References

- Resource management tasks: [tasks/resource-management.md](../tasks/resource-management.md)
- Mining and refining guide: [guides/mining-and-refining-guide.md](../guides/mining-and-refining-guide.md)
- Economic calculations: [examples/economic-calculations.md](economic-calculations.md)
- Formulas reference: [schemas/formulas.md](../schemas/formulas.md)
