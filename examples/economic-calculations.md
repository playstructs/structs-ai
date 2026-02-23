# Economic Calculation Examples

**Version**: 1.0.0
**Category**: Economic
**Purpose**: Complete examples of economic calculations for AI agents

---

## Overview

This document provides worked examples for all economic calculations in Structs: energy production across generator types, resource conversion, blockchain unit conversion, cost-per-kilowatt analysis, trading profit calculations, and guild token economics.

## Energy Production

All energy produced is ephemeral and must be consumed immediately.

### Reactor (Rate: 1x)

Formula: Energy (kW) = Alpha Matter (grams) x 1

| Input (grams) | Calculation | Output (kW) |
|----------------|-------------|--------------|
| 100 | 100 x 1 | 100 |
| 50 | 50 x 1 | 50 |

### Field Generator (Rate: 2x)

Formula: Energy (kW) = Alpha Matter (grams) x 2

| Input (grams) | Calculation | Output (kW) | Efficiency vs Reactor |
|----------------|-------------|--------------|----------------------|
| 100 | 100 x 2 | 200 | 200% |
| 50 | 50 x 2 | 100 | 200% |

Risk: high (design intent; current code is deterministic).

### Continental Power Plant (Rate: 5x)

Formula: Energy (kW) = Alpha Matter (grams) x 5

| Input (grams) | Calculation | Output (kW) | Efficiency vs Reactor |
|----------------|-------------|--------------|----------------------|
| 100 | 100 x 5 | 500 | 500% |

Risk: high (design intent; current code is deterministic).

### World Engine (Rate: 10x)

Formula: Energy (kW) = Alpha Matter (grams) x 10

| Input (grams) | Calculation | Output (kW) | Efficiency vs Reactor |
|----------------|-------------|--------------|----------------------|
| 100 | 100 x 10 | 1000 | 1000% |

Risk: high (design intent; current code is deterministic).

## Resource Conversion

### Ore to Matter

Formula: Alpha Matter (grams) = Alpha Ore (grams) x 1

| Input Ore (grams) | Output Matter (grams) | Security Change |
|--------------------|----------------------|-----------------|
| 100 | 100 | Stealable -> Secure |
| 50 | 50 | Stealable -> Secure |

Alpha Ore is stealable by raiders. Alpha Matter is non-stealable. Refine ore immediately after mining.

### Blockchain Unit Conversion

The blockchain uses micrograms for precision. The conversion factor is 1,000,000.

**Grams to micrograms:**

Formula: micrograms (uAlpha) = Alpha (grams) x 1,000,000

| Input (grams) | Output (uAlpha) |
|----------------|----------------|
| 100 | 100,000,000 |

**Micrograms to grams:**

Formula: Alpha (grams) = uAlpha / 1,000,000

| Input (uAlpha) | Output (grams) |
|----------------|----------------|
| 100,000,000 | 100 |

## Cost-per-Kilowatt Calculations

Given an Alpha Matter cost of 0.01 per gram:

| Generator | Formula | Cost per kW | Relative Cost |
|-----------|---------|-------------|---------------|
| Reactor (1x) | 0.01 / 1 | 0.01 | 100% (baseline) |
| Field Generator (2x) | 0.01 / 2 | 0.005 | 50% |
| Continental Power Plant (5x) | 0.01 / 5 | 0.002 | 20% |
| World Engine (10x) | 0.01 / 10 | 0.001 | 10% |

Higher-rate generators produce energy at lower cost per kW but carry higher risk (by design intent).

## Trading Calculations

### Trading Profit

Formula: Profit = (Sell Price - Buy Price) x Quantity

| Buy Price | Sell Price | Quantity | Profit | Result |
|-----------|-----------|----------|--------|--------|
| 0.001 | 0.002 | 100 | 0.1 | Profitable |
| 0.002 | 0.001 | 100 | -0.1 | Loss |

### Profit Margin

Formula: Profit Margin = ((Sell Price - Buy Price) / Buy Price) x 100%

| Buy Price | Sell Price | Margin |
|-----------|-----------|--------|
| 0.001 | 0.002 | 100% |
| 0.001 | 0.0015 | 50% |

## Guild Token Calculations

### Collateral Ratio

Formula: Collateral Ratio = (Locked Alpha Matter / Total Tokens Issued) x 100%

| Locked Alpha Matter | Tokens Issued | Ratio | Status |
|---------------------|---------------|-------|--------|
| 1,000 | 1,000 | 100% | Healthy -- 100% collateral backing |
| 500 | 1,000 | 50% | Low -- may reduce token value |
| 2,000 | 1,000 | 200% | Excellent -- high trust |

### Token Value

Formula: Token Value = Locked Alpha Matter / Tokens in Circulation

| Locked Alpha Matter | Tokens in Circulation | Token Value (grams per token) | Status |
|---------------------|----------------------|-------------------------------|--------|
| 1,000 | 1,000 | 1.0 | 1:1 backing |

### Market Cap

Formula: Market Cap = Tokens in Circulation x Current Price

| Tokens | Price (Alpha Matter per token) | Market Cap |
|--------|-------------------------------|------------|
| 1,000 | 0.01 | 10 Alpha Matter |

## Efficiency Comparisons

### Reactor vs Field Generator

Given 100 grams of Alpha Matter:

| Generator | Output (kW) | Rate | Risk |
|-----------|-------------|------|------|
| Reactor | 100 | 1x | Low |
| Field Generator | 200 | 2x | High (design intent) |

The Field Generator produces 100 kW more, at 200% efficiency. The tradeoff is safety vs efficiency.

### All Generator Types Compared

Given 100 grams of Alpha Matter:

| Generator | Output (kW) | Rate | Risk | Efficiency |
|-----------|-------------|------|------|------------|
| Reactor | 100 | 1x | Low | Baseline |
| Field Generator | 200 | 2x | High (design intent) | 200% |
| Continental Power Plant | 500 | 5x | High (design intent) | 500% |
| World Engine | 1,000 | 10x | High (design intent) | 1000% |

Choose based on risk tolerance: Reactor for safety, Field Generator for balanced efficiency, World Engine for maximum output.

## Formula Verification Status

| Category | Verified | Source |
|----------|----------|--------|
| Energy Production (all types) | Yes | `genesis_struct_type.go` -- GeneratingRate field |
| Ore to Matter conversion | Yes | 1:1 conversion verified against code |
| Cost calculations | No | Theoretical, needs code verification |
| Trading calculations | Yes | Standard mathematical formulas |
| Guild token calculations | No | Theoretical, needs code verification |

## Best Practices

- Always verify input values are positive numbers
- Ensure units match (grams, kW, etc.) before performing calculations
- Validate that calculation results are reasonable
- Remember energy is ephemeral and must be consumed immediately
- Remember ore is stealable, but matter is not -- refine ore promptly

## Cross-References

- Economic bot: [examples/economic-bot.md](economic-bot.md)
- Formulas schema: [schemas/formulas.md](../schemas/formulas.md)
- Economics schema: [schemas/economics.md](../schemas/economics.md)
- Trading schema: [schemas/trading.md](../schemas/trading.md)
- Guild economics tasks: [tasks/guild-economics.md](../tasks/guild-economics.md)
