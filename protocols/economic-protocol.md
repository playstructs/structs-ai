# Economic Protocol

**Version**: 1.1.0  
**Category**: Economic  
**Status**: Stable  
**Last Updated**: January 1, 2026

## Overview

The Economic Protocol defines how AI agents should interact with economic systems in Structs, including resource extraction, refinement, energy production, and trading.

## Economic Resource Flow

### Complete Flow

```json
{
  "flow": [
    {
      "step": 1,
      "action": "Mine Alpha Ore",
      "entity": "AlphaOre",
      "security": "stealable",
      "actionType": "MsgStructOreMinerComplete",
      "structs:deprecated": "MsgOreMining (deprecated - use MsgStructOreMinerComplete)",
      "requirements": ["Ore Extractor struct", "Planet with ore", "Proof-of-work"]
    },
    {
      "step": 2,
      "action": "Refine to Alpha Matter",
      "entity": "AlphaMatter",
      "security": "non-stealable",
      "actionType": "MsgStructOreRefineryComplete",
      "structs:deprecated": "MsgOreRefining (deprecated - use MsgStructOreRefineryComplete)",
      "requirements": ["Ore Refinery struct", "Alpha Ore", "Proof-of-work"],
      "conversion": "1 gram Ore = 1 gram Matter"
    },
    {
      "step": 3,
      "action": "Convert to Energy",
      "entity": "Energy",
      "security": "ephemeral",
      "actionType": "MsgReactorInfuse or MsgStructGeneratorInfuse",
      "structs:deprecated": "MsgReactorAllocate and MsgGeneratorAllocate (deprecated - use MsgReactorInfuse or MsgStructGeneratorInfuse)",
      "options": {
        "reactor": {
          "rate": 1,
          "formula": "Energy (kW) = Alpha Matter (grams) × 1",
          "risk": "low",
          "note": "Current implementation is deterministic - conversion is guaranteed at specified rate"
        },
        "fieldGenerator": {
          "rate": 2,
          "formula": "Energy (kW) = Alpha Matter (grams) × 2",
          "risk": "high",
          "note": "Design intent mentions risk, but current code implementation is deterministic. Risk may refer to strategic uncertainty or future implementation."
        },
        "continentalPowerPlant": {
          "rate": 5,
          "formula": "Energy (kW) = Alpha Matter (grams) × 5",
          "risk": "high",
          "note": "Design intent mentions risk, but current code implementation is deterministic. Risk may refer to strategic uncertainty or future implementation."
        },
        "worldEngine": {
          "rate": 10,
          "formula": "Energy (kW) = Alpha Matter (grams) × 10",
          "risk": "high",
          "note": "Design intent mentions risk, but current code implementation is deterministic. Risk may refer to strategic uncertainty or future implementation."
        }
      },
      "implementationNote": "Code verification (December 7, 2025): Generator conversion is deterministic. Alpha Matter is burned and converted to energy at the specified rate. No risk calculation or probability of loss is implemented in current code. The 'risk' mentioned in design intent may refer to strategic uncertainty (market conditions, player behavior) or future implementation."
    },
    {
      "step": 4,
      "action": "Consume Energy",
      "entity": "Energy",
      "note": "Energy must be consumed immediately. Cannot be stored."
    }
  ]
}
```

## Resource Security

### Alpha Ore (Stealable)

```json
{
  "resource": "AlphaOre",
  "security": {
    "stealable": true,
    "warning": "Alpha Ore can be stolen by other players through gameplay",
    "protection": "Refine to Alpha Matter immediately"
  },
  "properties": {
    "state": "raw",
    "refinementRequired": true
  }
}
```

### Alpha Matter (Non-Stealable)

```json
{
  "resource": "AlphaMatter",
  "security": {
    "stealable": false,
    "warning": "Alpha Matter cannot be stolen once refined",
    "protection": "Automatic - refinement secures resources"
  },
  "properties": {
    "state": "refined",
    "readyForUse": true
  }
}
```

### Energy (Ephemeral)

```json
{
  "resource": "Energy",
  "properties": {
    "ephemeral": true,
    "mustConsumeImmediately": true,
    "cannotBeStored": true,
    "shared": true,
    "sharedWith": "All Structs connected to same power source"
  }
}
```

## Energy Production

### Reactor Production

```json
{
  "action": "MsgReactorInfuse",
  "structs:deprecated": "MsgReactorAllocate (deprecated - use MsgReactorInfuse for reactor energy production)",
  "production": {
    "input": "Alpha Matter (grams)",
    "output": "Energy (kW)",
    "rate": 1,
    "formula": "Energy (kW) = Alpha Matter (grams) × 1",
    "risk": "low",
    "designIntent": "network-stability"
  },
  "request": {
    "body": {
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
  },
  "response": {
    "energyProduced": 100,
    "unit": "kW",
    "ephemeral": true,
    "mustConsumeImmediately": true
  }
}
```

### Generator Production

```json
{
  "action": "MsgStructGeneratorInfuse",
  "structs:deprecated": "MsgGeneratorAllocate (deprecated - use MsgStructGeneratorInfuse)",
  "generatorTypes": {
    "fieldGenerator": {
      "rate": 2,
      "formula": "Energy (kW) = Alpha Matter (grams) × 2",
      "risk": "high",
      "efficiency": "200% of Reactor"
    },
    "continentalPowerPlant": {
      "rate": 5,
      "formula": "Energy (kW) = Alpha Matter (grams) × 5",
      "risk": "high",
      "efficiency": "500% of Reactor"
    },
    "worldEngine": {
      "rate": 10,
      "formula": "Energy (kW) = Alpha Matter (grams) × 10",
      "risk": "high",
      "efficiency": "1000% of Reactor"
    }
  },
  "request": {
    "body": {
      "body": {
        "messages": [
          {
            "@type": "/structs.structs.MsgStructGeneratorInfuse",
            "creator": "structs1...",
            "generatorId": "1-1",
            "destinationType": 1,
            "destinationId": "2-1",
            "alphaMatterAmount": "100000000",
            "note": "100 grams = 100,000,000 micrograms"
          }
        ]
      }
    }
  },
  "response": {
    "energyProduced": 200,
    "unit": "kW",
    "generatorType": "fieldGenerator",
    "ephemeral": true,
    "mustConsumeImmediately": true
  }
}
```

## Reactor Staking and Validation Delegation (v0.8.0-beta)

### Overview

Reactor staking functionality allows players to delegate validation stake through reactor operations. Staking is now managed at the player level, and validation delegation is abstracted via Reactor Infuse/Defuse actions.

### Key Concepts

**Player-Level Management**: Reactor staking is managed at the player level, not at the individual reactor level. This allows for centralized staking management across all of a player's reactors.

**Validation Delegation**: Validation delegation is abstracted through reactor operations:
- **Reactor Infuse**: Handles both energy production and validation delegation
- **Reactor Defuse**: Handles both energy removal and validation undelegation
- **Reactor Begin Migration**: Begins redelegation process
- **Reactor Cancel Defusion**: Cancels undelegation process

### Delegation Statuses

```json
{
  "delegationStatuses": {
    "active": {
      "description": "Actively delegated to validator",
      "canPerform": ["defuse", "beginMigration"]
    },
    "undelegating": {
      "description": "In undelegation period",
      "canPerform": ["cancelDefusion"]
    },
    "migrating": {
      "description": "In migration/redelegation process",
      "canPerform": ["completeMigration"]
    }
  }
}
```

### Delegation Workflow

**1. Delegate Validation Stake (Infuse)**

```json
{
  "action": "MsgReactorInfuse",
  "purpose": "validation_delegation",
  "description": "Use Reactor Infuse to delegate validation stake to a validator",
  "request": {
    "body": {
      "body": {
        "messages": [
          {
            "@type": "/structs.structs.MsgReactorInfuse",
            "creator": "structs1...",
            "reactorId": "3-1",
            "amount": "1000000000",
            "note": "When used for staking, this delegates validation stake"
          }
        ]
      }
    }
  },
  "response": {
    "delegationStatus": "active",
    "validator": "validator_address",
    "delegationAmount": "1000000000"
  }
}
```

**2. Undelegate Validation Stake (Defuse)**

```json
{
  "action": "MsgReactorDefuse",
  "purpose": "validation_undelegation",
  "description": "Use Reactor Defuse to undelegate validation stake",
  "request": {
    "body": {
      "body": {
        "messages": [
          {
            "@type": "/structs.structs.MsgReactorDefuse",
            "creator": "structs1...",
            "reactorId": "3-1",
            "amount": "1000000000",
            "note": "When used for unstaking, this undelegates validation stake"
          }
        ]
      }
    }
  },
  "response": {
    "delegationStatus": "undelegating",
    "undelegationPeriod": "blocks_remaining"
  }
}
```

**3. Begin Redelegation (Begin Migration)**

```json
{
  "action": "MsgReactorBeginMigration",
  "purpose": "validation_redelegation",
  "description": "Begin redelegation process to move stake to a different validator",
  "request": {
    "body": {
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
  },
  "response": {
    "delegationStatus": "migrating",
    "migrationInProgress": true
  }
}
```

**4. Cancel Undelegation (Cancel Defusion)**

```json
{
  "action": "MsgReactorCancelDefusion",
  "purpose": "cancel_undelegation",
  "description": "Cancel an ongoing undelegation process",
  "request": {
    "body": {
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
  },
  "response": {
    "delegationStatus": "active",
    "undelegationCancelled": true
  }
}
```

### Membership Join Process (v0.8.0-beta)

The membership join process has been improved to streamline redelegation of staked assets during migration:

```json
{
  "workflow": {
    "step": 1,
    "action": "MsgGuildMembershipJoin",
    "description": "Join a guild",
    "note": "Staked assets are automatically redelegated during the migration process"
  },
  "improvements": {
    "v0.8.0-beta": {
      "streamlinedRedelegation": "Redelegation of staked assets is now streamlined during membership migration",
      "automaticProcessing": "Staking redelegation happens automatically as part of the join process"
    }
  }
}
```

### Best Practices

1. **Monitor Delegation Status**: Always check the reactor's delegation status before performing staking operations
2. **Undelegation Period**: Be aware of the undelegation period when undelegating stake
3. **Migration Timing**: Plan redelegations carefully to avoid downtime
4. **Player-Level Management**: Remember that staking is managed at the player level, not reactor level

## Economic Structs

### Ore Extractor

```json
{
  "structType": "OreExtractor",
  "purpose": "Mine Alpha Ore from planets",
  "costs": {
    "buildDraw": 500000,
    "passiveDraw": 500000,
    "miningCharge": 20,
    "miningDifficulty": 14000
  },
  "action": "MsgStructOreMinerComplete",
  "structs:deprecated": "MsgOreMining (deprecated - use MsgStructOreMinerComplete)",
  "output": {
    "resource": "AlphaOre",
    "security": "stealable"
  }
}
```

### Ore Refinery

```json
{
  "structType": "OreRefinery",
  "purpose": "Refine Alpha Ore to Alpha Matter",
  "costs": {
    "buildDraw": 500000,
    "passiveDraw": 500000,
    "refiningCharge": 20,
    "refiningDifficulty": 28000
  },
  "action": "MsgStructOreRefineryComplete",
  "structs:deprecated": "MsgOreRefining (deprecated - use MsgStructOreRefineryComplete)",
  "conversion": {
    "input": "AlphaOre",
    "output": "AlphaMatter",
    "rate": 1
  },
  "security": {
    "inputStealable": true,
    "outputStealable": false
  }
}
```

### Field Generator

```json
{
  "structType": "FieldGenerator",
  "purpose": "High-yield energy production",
  "costs": {
    "buildDraw": 500000,
    "passiveDraw": 500000
  },
  "action": "MsgStructGeneratorInfuse",
  "structs:deprecated": "MsgGeneratorAllocate (deprecated - use MsgStructGeneratorInfuse)",
  "production": {
    "input": "AlphaMatter",
    "output": "Energy",
    "rate": 2,
    "formula": "Energy (kW) = Alpha Matter (grams) × 2",
    "risk": "high"
  }
}
```

## Economic Formulas

### Energy Production Formulas

```json
{
  "formulas": {
    "reactor": {
      "formula": "Energy (kW) = Alpha Matter (grams) × 1",
      "rate": 1,
      "risk": "low"
    },
    "fieldGenerator": {
      "formula": "Energy (kW) = Alpha Matter (grams) × 2",
      "rate": 2,
      "risk": "high"
    },
    "continentalPowerPlant": {
      "formula": "Energy (kW) = Alpha Matter (grams) × 5",
      "rate": 5,
      "risk": "high"
    },
    "worldEngine": {
      "formula": "Energy (kW) = Alpha Matter (grams) × 10",
      "rate": 10,
      "risk": "high"
    }
  }
}
```

### Cost Calculations

```json
{
  "costFormulas": {
    "reactorCostPerKW": {
      "formula": "Cost per kW = Alpha Matter Cost / 1",
      "description": "Cost per kilowatt for Reactor"
    },
    "fieldGeneratorCostPerKW": {
      "formula": "Cost per kW = Alpha Matter Cost / 2",
      "description": "Cost per kilowatt for Field Generator"
    },
    "continentalPowerPlantCostPerKW": {
      "formula": "Cost per kW = Alpha Matter Cost / 5",
      "description": "Cost per kilowatt for Continental Power Plant"
    },
    "worldEngineCostPerKW": {
      "formula": "Cost per kW = Alpha Matter Cost / 10",
      "description": "Cost per kilowatt for World Engine"
    }
  }
}
```

## Energy Markets

### Automated Energy Agreements

```json
{
  "agreement": {
    "type": "AutomatedEnergyAgreement",
    "enforcement": {
      "type": "automatic",
      "onChain": true,
      "penaltyProtection": true,
      "selfEnforcing": true
    },
    "action": "MsgAgreementOpen",
    "structs:deprecated": "MsgAgreementCreate (deprecated - use MsgAgreementOpen)",
    "properties": {
      "persistent": true,
      "subscription": true,
      "automaticExecution": true,
      "penaltyProtection": true
    }
  }
}
```

## Guild Economics

### Guild Central Banks

```json
{
  "guildCentralBank": {
    "type": "GuildCentralBank",
    "security": {
      "trustBased": true,
      "technicalSafeguards": false,
      "minimumCollateral": false,
      "maxSupply": false,
      "guildControl": "full"
    },
    "operations": {
      "mint": {
        "description": "Mint new guild tokens",
        "requires": ["collateral"]
      },
      "revoke": {
        "description": "Revoke and burn tokens",
        "result": "tokens-burned"
      }
    },
    "warning": "Guild tokens are trust-based. Guilds have full control. No technical safeguards against inflation or revocation. Reliance on reputation."
  }
}
```

## Best Practices

### Resource Security

```json
{
  "bestPractices": {
    "oreSecurity": {
      "recommendation": "Refine Alpha Ore to Alpha Matter immediately",
      "reason": "Alpha Ore can be stolen, Alpha Matter cannot"
    },
    "energyManagement": {
      "recommendation": "Consume energy immediately upon production",
      "reason": "Energy is ephemeral and cannot be stored"
    },
    "generatorChoice": {
      "recommendation": "Choose Reactors for safety, Generators for efficiency",
      "reason": "Reactors are safer (1 kW/g), Generators are more efficient (2, 5, or 10 kW/g) but riskier"
    }
  }
}
```

## Error Cases

### Common Economic Errors

```json
{
  "errors": {
    "insufficientAlphaMatter": {
      "code": "INSUFFICIENT_ALPHA_MATTER",
      "description": "Not enough Alpha Matter for operation",
      "solution": "Check Alpha Matter balance, mine more ore, refine ore to matter"
    },
    "insufficientEnergy": {
      "code": "INSUFFICIENT_ENERGY",
      "description": "Not enough energy for operation",
      "solution": "Produce more energy from Alpha Matter, check energy production facilities"
    },
    "oreStolen": {
      "code": "ORE_STOLEN",
      "description": "Alpha Ore was stolen by another player",
      "solution": "Refine to Alpha Matter immediately to prevent theft"
    },
    "energyExpired": {
      "code": "ENERGY_EXPIRED",
      "description": "Energy was not consumed and expired (ephemeral)",
      "solution": "Consume energy immediately upon production"
    }
  }
}
```

## Examples

### Complete Economic Flow Example

```json
{
  "example": {
    "scenario": "Mine ore, refine to matter, produce energy",
    "steps": [
      {
        "step": 1,
        "action": "MsgStructOreMinerComplete",
        "structs:deprecated": "MsgOreMining (deprecated - use MsgStructOreMinerComplete)",
        "request": {
          "body": {
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
        },
        "result": {
          "oreExtracted": 100,
          "unit": "grams",
          "security": "stealable"
        }
      },
      {
        "step": 2,
        "action": "MsgStructOreRefineryComplete",
        "structs:deprecated": "MsgOreRefining (deprecated - use MsgStructOreRefineryComplete)",
        "request": {
          "body": {
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
        },
        "result": {
          "alphaMatterCreated": 100,
          "unit": "grams",
          "security": "non-stealable"
        }
      },
      {
        "step": 3,
        "action": "MsgReactorInfuse",
        "structs:deprecated": "MsgReactorAllocate (deprecated - use MsgReactorInfuse for reactor energy production)",
        "request": {
          "body": {
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
        },
        "result": {
          "energyProduced": 100,
          "unit": "kW",
          "ephemeral": true,
          "mustConsumeImmediately": true
        }
      }
    ]
  }
}
```

---

*Last Updated: January 1, 2026*

