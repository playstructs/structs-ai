# Gameplay Documentation Index

**Version**: 1.0.0
**Last Updated**: 2025-01-XX
**Description**: Complete index of gameplay documentation for AI agents

---

## Schemas

| ID | Name | File | Description |
|----|------|------|-------------|
| gameplay-schema | Gameplay Schema | [gameplay.md](../schemas/gameplay.md) | Complete gameplay mechanics schema (resources, combat, building, mining) |

**Definitions**: Resource, ResourceConversion, CombatAction, BuildingAction, MiningOperation, GameplayLoop, PowerManagement, PlanetCompletion, GameplayQuery

---

## Protocols

| ID | Name | File | Description |
|----|------|------|-------------|
| gameplay-protocol | Gameplay Protocol | [gameplay-protocol.md](../protocols/gameplay-protocol.md) | How to interact with gameplay mechanics |

**Sections**: Resource Management, Mining Protocol, Power Management Protocol, Building Protocol, Combat Protocol, Exploration Protocol, Fleet Management Protocol, Guild Operations Protocol, Planet Management Protocol, Gameplay State Queries Protocol, 5X Framework Protocol

---

## Strategy Patterns

| ID | Name | File | Description |
|----|------|------|-------------|
| gameplay-strategies | Gameplay Strategy Patterns | [gameplay-strategies.md](../patterns/gameplay-strategies.md) | Common gameplay strategy patterns |

**Patterns**: Resource Security, Power Management, Build Requirements, Mining Optimization, Combat Preparation, Defense, Expansion, 5X Framework

---

## Decision Trees

| ID | Name | File | Description |
|----|------|------|-------------|
| resource-security | Resource Security Decision Tree | [decision-tree-resource-security.md](../patterns/decision-tree-resource-security.md) | Decision tree for securing resources by refining ore immediately |
| power-management | Power Management Decision Tree | [decision-tree-power-management.md](../patterns/decision-tree-power-management.md) | Decision tree for managing power capacity and maintaining online status |
| build-requirements | Build Requirements Decision Tree | [decision-tree-build-requirements.md](../patterns/decision-tree-build-requirements.md) | Decision tree for verifying all requirements before building structures |
| combat | Combat Decision Tree | [decision-tree-combat.md](../patterns/decision-tree-combat.md) | Decision tree for scouting, assessing, preparing, and executing combat operations |
| 5x-framework | 5X Framework Decision Tree | [decision-tree-5x-framework.md](../patterns/decision-tree-5x-framework.md) | Decision tree for executing the 5X Framework gameplay loop |

---

## Tasks

| ID | Name | File | Description |
|----|------|------|-------------|
| onboarding | Player Onboarding Task | [onboarding.md](../tasks/onboarding.md) | Complete workflow for new player onboarding - first 1-2 days |
| building | Building Task | [building.md](../tasks/building.md) | Complete workflow for building structures on planets or in fleets |
| exploration | Exploration Task | [exploration.md](../tasks/exploration.md) | Complete workflow for exploring and charting planets |
| resource-management | Resource Management Task | [resource-management.md](../tasks/resource-management.md) | Complete workflow for managing resources (mining, refining, converting) |

---

## Workflows

| ID | Name | File | Description |
|----|------|------|-------------|
| get-player-and-planets | Get Player and Planets Workflow | [get-player-and-planets.md](../workflows/get-player-and-planets.md) | Multi-step workflow to get player information and all associated planets |
| mine-refine-convert | Mine, Refine, Convert Workflow | [mine-refine-convert.md](../workflows/mine-refine-convert.md) | Complete workflow for mining ore, refining to Alpha Matter, and converting to Watts |
| planet-setup | Planet Setup Workflow | [planet-setup.md](../workflows/planet-setup.md) | Complete workflow for setting up a new planet |

---

## Examples

| ID | Name | File | Workflow | Description |
|----|------|------|----------|-------------|
| mining-bot | Mining Bot Example | [gameplay-mining-bot.md](../examples/gameplay-mining-bot.md) | Resource Extraction Workflow | Example bot for mining Alpha Matter, refining ore, and converting to Watts |
| combat-bot | Combat Bot Example | [gameplay-combat-bot.md](../examples/gameplay-combat-bot.md) | Combat, Raid, Defense Workflows | Example bot for scouting, assembling forces, and executing attacks |

---

## Core Concepts

### Resources

| ID | Name | Security | Description | Schema |
|----|------|----------|-------------|--------|
| alphaMatter | Alpha Matter | Secure | Refined resource - cannot be stolen | [gameplay.md](../schemas/gameplay.md#resource) |
| ore | Alpha Ore | Stealable | Raw ore - can be stolen, must be refined | [gameplay.md](../schemas/gameplay.md#resource) |
| watts | Watts | Secure | Energy units - powers all operations | [gameplay.md](../schemas/gameplay.md#resource) |

### Resource Conversion

| Method | Rate | Risk | Description | Schema |
|--------|------|------|-------------|--------|
| reactor | 1g:1kW | Low | Safe, reliable conversion | [gameplay.md](../schemas/gameplay.md#resourceconversion) |
| planetaryGenerator | 1g:2kW | High | Efficient conversion, higher risk | [gameplay.md](../schemas/gameplay.md#resourceconversion) |

### Combat Mechanics

| Mechanic | Description | Schema |
|----------|-------------|--------|
| Evasion | Structs can evade attacks | [gameplay.md](../schemas/gameplay.md#evasion) |
| Blocking | Defenders can block attacks | [gameplay.md](../schemas/gameplay.md#blocking) |
| Counter Attack | Structs counter-attack automatically | [gameplay.md](../schemas/gameplay.md#counterattack) |

### Building

| Aspect | Description | Schema |
|--------|-------------|--------|
| Requirements | Building requirements checklist | [gameplay.md](../schemas/gameplay.md#buildingaction-requirements) |
| Limits | Per-player build limits | [gameplay.md](../schemas/gameplay.md#buildlimits) |

### 5X Framework

**Phases**: Explore, Extract, Expand, Exterminate, Exchange

Core gameplay loop. See: [gameplay.md](../schemas/gameplay.md#gameplayloop)

---

## Quick Reference

### Resource Security

- **Principle**: Always refine ore to Alpha Matter immediately
- **Reason**: Ore can be stolen, Alpha Matter cannot
- **Pattern**: [gameplay-strategies.md#resource-security-pattern](../patterns/gameplay-strategies.md#resource-security-pattern)
- **Decision Tree**: [decision-tree-resource-security.md](../patterns/decision-tree-resource-security.md)

### Power Management

- **Principle**: Stay online by maintaining power capacity above consumption
- **Formula**: `(capacity + capacitySecondary) - (load + structsLoad)`
- **Pattern**: [gameplay-strategies.md#power-management-pattern](../patterns/gameplay-strategies.md#power-management-pattern)
- **Decision Tree**: [decision-tree-power-management.md](../patterns/decision-tree-power-management.md)

### Build Requirements

- **Principle**: Verify all requirements before attempting to build
- **Checklist**: playerOnline, fleetOnStation, commandShipOnline, sufficientPower, availableSlot, buildLimit
- **Pattern**: [gameplay-strategies.md#build-requirements-pattern](../patterns/gameplay-strategies.md#build-requirements-pattern)
- **Decision Tree**: [decision-tree-build-requirements.md](../patterns/decision-tree-build-requirements.md)

### Combat Preparation

- **Principle**: Scout, assess, prepare, then execute
- **Workflow**: scout, assess, prepare, execute
- **Pattern**: [gameplay-strategies.md#combat-preparation-pattern](../patterns/gameplay-strategies.md#combat-preparation-pattern)
- **Decision Tree**: [decision-tree-combat.md](../patterns/decision-tree-combat.md)

### Gameplay State Queries

| Query | Schema | Protocol | Formula |
|-------|--------|----------|---------|
| playerOnline | [gameplay.md](../schemas/gameplay.md#playeronline) | [gameplay-protocol.md](../protocols/gameplay-protocol.md#gameplay-state-queries-protocol) | `(load + structsLoad) <= (capacity + capacitySecondary)` |
| canBuild | [gameplay.md](../schemas/gameplay.md#canbuild) | [gameplay-protocol.md](../protocols/gameplay-protocol.md#gameplay-state-queries-protocol) | -- |
| canRaid | [gameplay.md](../schemas/gameplay.md#canraid) | [gameplay-protocol.md](../protocols/gameplay-protocol.md#gameplay-state-queries-protocol) | -- |
| canMine | [gameplay.md](../schemas/gameplay.md#canmine) | [gameplay-protocol.md](../protocols/gameplay-protocol.md#gameplay-state-queries-protocol) | -- |
| canExplore | [gameplay.md](../schemas/gameplay.md#canexplore) | [gameplay-protocol.md](../protocols/gameplay-protocol.md#gameplay-state-queries-protocol) | -- |

### Key Actions

| Category | Actions | Schema |
|----------|---------|--------|
| Fleet Management | MsgFleetMove | [actions.md](../schemas/actions.md#msgfleetmove) |
| Guild Operations | MsgGuildCreate, MsgGuildMembershipJoin, MsgGuildMembershipLeave, MsgGuildBankMint, MsgGuildBankRedeem | [actions.md](../schemas/actions.md) |
