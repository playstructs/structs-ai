# Gameplay Strategy Patterns

**Version**: 1.0.0  
**Category**: Gameplay Patterns  
**Status**: Stable

## Overview

This document defines common gameplay strategy patterns for AI agents. These patterns represent proven approaches to resource management, combat, expansion, and overall gameplay optimization.

## Strategy Patterns

### Resource Security Pattern

**Purpose**: Secure resources by refining ore immediately.

**Pattern**:
```json
{
  "pattern": "resourceSecurity",
  "workflow": [
    {
      "action": "mine",
      "result": "oreStored"
    },
    {
      "action": "refine",
      "immediately": true,
      "reason": "Ore can be stolen, Alpha Matter cannot"
    },
    {
      "action": "convert",
      "when": "needed",
      "reserve": 0.2
    }
  ],
  "principle": "Always refine ore to Alpha Matter immediately to prevent theft"
}
```

**Implementation**:
- Monitor ore stored
- Refine as soon as ore is available
- Never leave ore unrefined
- Maintain Alpha Matter reserves

### Power Management Pattern

**Purpose**: Maintain online status and sufficient power capacity.

**Pattern**:
```json
{
  "pattern": "powerManagement",
  "workflow": [
    {
      "action": "queryPower",
      "frequency": "continuous"
    },
    {
      "action": "calculateCapacity",
      "formula": "(capacity + capacitySecondary) - (load + structsLoad)"
    },
    {
      "action": "maintainOnline",
      "condition": "availableCapacity > 0",
      "fallback": "reduceConsumption"
    }
  ],
  "principle": "Stay online by maintaining power capacity above consumption"
}
```

**Implementation**:
- Monitor power capacity continuously
- Calculate available capacity
- Reduce consumption if going offline
- Increase capacity if needed
- Convert Alpha Matter to Watts when needed

### Build Requirements Pattern

**Purpose**: Verify all requirements before building.

**Pattern**:
```json
{
  "pattern": "buildRequirements",
  "checklist": [
    {
      "requirement": "playerOnline",
      "check": "powerStatus.playerOnline == true"
    },
    {
      "requirement": "fleetOnStation",
      "check": "fleetStatus == 'onStation'",
      "note": "Required for planet building"
    },
    {
      "requirement": "commandShipOnline",
      "check": "commandShip.status == 'online'"
    },
    {
      "requirement": "sufficientPower",
      "check": "availableCapacity >= (buildPower + passivePower)"
    },
    {
      "requirement": "availableSlot",
      "check": "planetSlots[slotType] > 0"
    },
    {
      "requirement": "buildLimit",
      "check": "currentCount < maxPerPlayer"
    }
  ],
  "principle": "Verify all requirements before attempting to build"
}
```

**Implementation**:
- Check all requirements in order
- Fail fast if requirement not met
- Provide clear error messages
- Wait for requirements to be met

### Mining Optimization Pattern

**Purpose**: Optimize mining operations for maximum efficiency.

**Pattern**:
```json
{
  "pattern": "miningOptimization",
  "workflow": [
    {
      "action": "chart",
      "target": "resourceRichPlanets"
    },
    {
      "action": "buildExtractor",
      "priority": "highOrePlanets"
    },
    {
      "action": "monitorMining",
      "frequency": "continuous"
    },
    {
      "action": "refineImmediately",
      "priority": "high"
    },
    {
      "action": "convertWhenNeeded",
      "reserve": 0.2
    }
  ],
  "principle": "Mine efficiently, refine immediately, convert strategically"
}
```

**Implementation**:
- Prioritize high-ore planets
- Build extractors on best planets
- Monitor mining continuously
- Refine ore immediately
- Convert Alpha Matter when needed
- Maintain reserves

### Combat Preparation Pattern

**Purpose**: Prepare for combat operations.

**Pattern**:
```json
{
  "pattern": "combatPreparation",
  "workflow": [
    {
      "action": "scout",
      "target": "enemyPlanets"
    },
    {
      "action": "assess",
      "evaluate": [
        "enemyDefenses",
        "enemyForces",
        "requiredForces",
        "risk"
      ]
    },
    {
      "action": "prepare",
      "ensure": [
        "sufficientPower",
        "forcesReady",
        "playerOnline"
      ]
    },
    {
      "action": "execute",
      "type": "attack|raid|defend"
    }
  ],
  "principle": "Scout, assess, prepare, then execute"
}
```

**Implementation**:
- Always scout before attacking
- Assess enemy strength
- Prepare sufficient forces
- Ensure online status
- Execute with advantage

### Defense Pattern

**Purpose**: Build and maintain defenses.

**Pattern**:
```json
{
  "pattern": "defense",
  "workflow": [
    {
      "action": "buildDefenseCannon",
      "priority": "high",
      "limit": 1
    },
    {
      "action": "buildBunkers",
      "where": "oreStoragePlanets"
    },
    {
      "action": "deployCombatStructs",
      "where": "valuablePlanets"
    },
    {
      "action": "monitor",
      "frequency": "continuous"
    }
  ],
  "principle": "Build defenses before expanding, maintain defenses continuously"
}
```

**Implementation**:
- Build Defense Cannon first (1 per player)
- Build bunkers on storage planets
- Deploy combat structs on valuable planets
- Monitor for attacks
- Respond automatically

### Expansion Pattern

**Purpose**: Expand territory strategically.

**Pattern**:
```json
{
  "pattern": "expansion",
  "workflow": [
    {
      "action": "explore",
      "when": "currentPlanetComplete"
    },
    {
      "action": "chart",
      "target": "newPlanets"
    },
    {
      "action": "assess",
      "evaluate": [
        "resourceValue",
        "strategicValue",
        "defenseNeeds"
      ]
    },
    {
      "action": "claim",
      "priority": "highValuePlanets"
    },
    {
      "action": "buildDefenses",
      "immediately": true
    },
    {
      "action": "buildInfrastructure",
      "after": "defenses"
    }
  ],
  "principle": "Explore, assess, claim, defend, then build"
}
```

**Implementation**:
- Explore when planet complete
- Chart new planets
- Assess value
- Claim high-value planets
- Build defenses first
- Build infrastructure after

### 5X Framework Pattern

**Purpose**: Execute complete gameplay loop.

**Pattern**:
```json
{
  "pattern": "5XFramework",
  "phases": [
    {
      "phase": "explore",
      "actions": [
        "chartPlanets",
        "identifyResources",
        "locateEnemies"
      ],
      "next": "extract"
    },
    {
      "phase": "extract",
      "actions": [
        "mineOre",
        "refineToAlphaMatter",
        "convertToWatts"
      ],
      "next": "expand"
    },
    {
      "phase": "expand",
      "actions": [
        "claimPlanets",
        "buildInfrastructure",
        "growInfluence"
      ],
      "next": "exterminate"
    },
    {
      "phase": "exterminate",
      "actions": [
        "defendAssets",
        "attackEnemies",
        "gainResources"
      ],
      "next": "exchange"
    },
    {
      "phase": "exchange",
      "actions": [
        "tradeResources",
        "buyEquipment",
        "sellExcess"
      ],
      "next": "explore"
    }
  ],
  "principle": "Follow 5X Framework for complete gameplay loop"
}
```

**Implementation**:
- Execute phases in order
- Complete phase actions
- Transition to next phase
- Loop continuously
- Adapt based on situation

## Best Practices

### Resource Management
- Refine ore immediately
- Maintain reserves (20-30%)
- Convert strategically
- Monitor power continuously

### Combat
- Scout before attacking
- Prepare sufficient forces
- Ensure online status
- Secure after victory

### Building
- Verify all requirements
- Build defenses first
- Plan power needs
- Check build limits

### Expansion
- Explore strategically
- Assess value
- Defend before expanding
- Build infrastructure after

## Error Handling

### Common Errors
- **Insufficient Power**: Convert Alpha Matter or reduce consumption
- **Build Requirements Not Met**: Verify and wait for requirements
- **Ore Not Refined**: Refine immediately
- **Fleet Not Away**: Move fleet before raiding
- **Command Ship Offline**: Activate Command Ship

### Recovery Strategies
- Monitor for errors
- Provide clear error messages
- Suggest solutions
- Wait for conditions to be met
- Retry after requirements met

## Optimization

### Performance
- Batch operations when possible
- Monitor continuously
- Cache state information
- Reduce unnecessary queries

### Resource Efficiency
- Optimize conversion rates
- Minimize waste
- Balance reserves
- Plan ahead

### Strategic Efficiency
- Prioritize high-value actions
- Plan operations in advance
- Coordinate with guild
- Adapt to situations

