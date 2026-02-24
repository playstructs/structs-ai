# Economic Bot Example

**Version**: 1.1.0
**Category**: Economic
**Purpose**: Automated resource extraction, refinement, and energy production

---

## Overview

The Economic Bot automates the core economic loop in Structs: mining Alpha Ore, refining it into Alpha Matter, and producing energy (Watts). It uses a primary resource-extraction strategy with secondary energy-production capability, operating at medium risk tolerance.

## Bot Configuration

```json
{
  "id": "economic-bot-001",
  "name": "Economic Bot",
  "purpose": "Automated resource extraction, refinement, and energy production",
  "strategy": {
    "primary": "resource-extraction",
    "secondary": "energy-production",
    "riskTolerance": "medium"
  }
}
```

## Capabilities

### Mining

Uses an Ore Extractor to mine Alpha Ore via `MsgStructOreMinerComplete`.

| Parameter | Value |
|-----------|-------|
| Struct Type | OreExtractor |
| Build Draw | 500,000 |
| Passive Draw | 500,000 |
| Mining Charge | 20 |
| Mining Difficulty | 14,000 |

*Deprecated: `MsgOreMining` -- use `MsgStructOreMinerComplete` instead.*

### Refining

Uses an Ore Refinery to refine ore into Alpha Matter via `MsgStructOreRefineryComplete`.

| Parameter | Value |
|-----------|-------|
| Struct Type | OreRefinery |
| Build Draw | 500,000 |
| Passive Draw | 500,000 |
| Refining Charge | 20 |
| Refining Difficulty | 28,000 |

*Deprecated: `MsgOreRefining` -- use `MsgStructOreRefineryComplete` instead.*

### Energy Production

Multiple options with varying rates and risk profiles:

| Generator | Action | Rate | Risk | Status |
|-----------|--------|------|------|--------|
| Reactor | `MsgReactorInfuse` | 1x | Low | Enabled |
| Field Generator | `MsgStructGeneratorInfuse` | 2x | High (design intent) | Enabled |
| Continental Power Plant | `MsgStructGeneratorInfuse` | 5x | High (design intent) | Disabled |
| World Engine | `MsgStructGeneratorInfuse` | 10x | High (design intent) | Disabled |

*Deprecated: `MsgReactorAllocate` -- use `MsgReactorInfuse`. `MsgGeneratorAllocate` -- use `MsgStructGeneratorInfuse`.*

Code verification (December 7, 2025): Generator conversion is deterministic. No risk calculation is implemented in the current code, despite the design intent mentioning risk for generators.

## Workflow

### Step 1: Mine Alpha Ore

Submit a mining completion transaction with proof-of-work:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructOreMinerComplete",
        "creator": "structs1...",
        "structId": "1-1",
        "hash": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

The extracted ore is stealable. Proceed to refining immediately.

### Step 2: Refine to Alpha Matter

Submit a refining completion transaction with proof-of-work:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgStructOreRefineryComplete",
        "creator": "structs1...",
        "structId": "1-1",
        "hash": "proof-of-work-hash",
        "nonce": "proof-of-work-nonce"
      }
    ]
  }
}
```

Alpha Matter is non-stealable once refined. Proceed to energy production.

### Step 3: Produce Energy

Choose a conversion method based on risk tolerance. For low risk, use the Reactor:

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorInfuse",
        "creator": "structs1...",
        "reactorId": "1-1",
        "destinationType": 1,
        "destinationId": "2-1",
        "alphaMatterAmount": "100000000"
      }
    ]
  }
}
```

Energy is ephemeral and must be consumed immediately. Have consumption ready before producing energy.

## Conversion Formulas

| Conversion | Formula | Rate |
|------------|---------|------|
| Ore to Matter | 1 gram Alpha Ore = 1 gram Alpha Matter | 1:1 |
| Matter to Energy (Reactor) | Energy (kW) = Alpha Matter (grams) x 1 | 1x |
| Matter to Energy (Field Generator) | Energy (kW) = Alpha Matter (grams) x 2 | 2x |
| Matter to Energy (Continental Power Plant) | Energy (kW) = Alpha Matter (grams) x 5 | 5x |
| Matter to Energy (World Engine) | Energy (kW) = Alpha Matter (grams) x 10 | 10x |

## Example Flows

### Complete Flow (Reactor)

1. Mine ore on planet: output is 100 grams Alpha Ore (stealable)
2. Refine ore (`MsgStructOreRefineryComplete`): output is 100 grams Alpha Matter (non-stealable)
3. Convert via Reactor (`MsgReactorInfuse`): output is 100 kW Energy (ephemeral, must consume immediately)

### Generator Flow (Field Generator)

1. Mine ore on planet: output is 100 grams Alpha Ore (stealable)
2. Refine ore (`MsgStructOreRefineryComplete`): output is 100 grams Alpha Matter (non-stealable)
3. Convert via Field Generator (`MsgStructGeneratorInfuse`): output is 200 kW Energy (2x efficiency, higher risk by design intent)

### Reactor Staking Flow

Reactor staking manages validation delegation at the player level through Reactor Infuse/Defuse actions.

**Delegate validation stake** (`MsgReactorInfuse`):

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorInfuse",
        "creator": "structs1...",
        "reactorId": "3-1",
        "destinationType": 1,
        "destinationId": "1-11",
        "alphaMatterAmount": "1000000000"
      }
    ]
  }
}
```

Before delegating, check permissions: `GET /structs/permission/object/{reactorId}` to confirm the player has permission on the reactor.

**Begin redelegation** (`MsgReactorBeginMigration`):

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

**Undelegate validation stake** (`MsgReactorDefuse`):

```json
{
  "body": {
    "messages": [
      {
        "@type": "/structs.structs.MsgReactorDefuse",
        "creator": "structs1...",
        "reactorId": "3-1",
        "destinationType": 1,
        "destinationId": "1-11",
        "alphaMatterAmount": "1000000000"
      }
    ]
  }
}
```

**Cancel undelegation** (`MsgReactorCancelDefusion`, optional):

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

For detailed staking workflows, see:
- [examples/workflows/reactor-staking-infuse.md](workflows/reactor-staking-infuse.md)
- [examples/workflows/reactor-staking-defuse.md](workflows/reactor-staking-defuse.md)
- [examples/workflows/reactor-staking-begin-migration.md](workflows/reactor-staking-begin-migration.md)
- [examples/workflows/reactor-staking-cancel-defusion.md](workflows/reactor-staking-cancel-defusion.md)

## Security Policies

**Ore security**: Refine immediately. Alpha Ore can be stolen; Alpha Matter cannot.

**Energy management**: Consume immediately. Energy is ephemeral and cannot be stored.

## Error Handling

| Error | Recovery |
|-------|----------|
| Insufficient Alpha Matter | Mine more ore, then refine to matter |
| Insufficient Energy | Produce more energy from Alpha Matter |
| Ore stolen | Refine immediately next time -- refine ore as soon as mined |
| Energy expired | Consume immediately next time -- have consumption ready before production |
| Player halted (staking) | Wait for player to come online |
| Invalid delegation status (staking) | Wait for migration to complete or cancel defusion |

## Cross-References

- Economic calculations: [examples/economic-calculations.md](economic-calculations.md)
- Energy production guide: [guides/energy-production-guide.md](../guides/energy-production-guide.md)
- Formulas: [schemas/formulas.md](../schemas/formulas.md)
- Economics schema: [schemas/economics.md](../schemas/economics.md)
