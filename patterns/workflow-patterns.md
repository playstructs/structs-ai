# Workflow Patterns

**Version**: 1.0.0  
**Category**: API Patterns  
**Purpose**: Guide for AI agents on implementing multi-step API workflows and parallel request patterns

---

## Overview

This pattern provides strategies for implementing complex workflows that involve multiple API calls, parallel requests, and state management. It helps AI agents coordinate multiple operations efficiently and handle dependencies between API calls.

**Key Principles**:
1. **Chain operations sequentially** when dependencies exist
2. **Execute operations in parallel** when independent
3. **Manage state** across workflow steps
4. **Handle errors** at each step
5. **Track progress** for long-running workflows

---

## Sequential Workflow Patterns

### Pattern 1: Linear Chain

**Use Case**: Operations that depend on previous results

**Structure**:
```
Step 1 → Step 2 → Step 3 → Step 4
```

**Implementation**:
```json
{
  "pattern": "linear-chain",
  "steps": [
    {
      "step": 1,
      "action": "Get player",
      "endpoint": "GET /api/player/{id}",
      "output": "player"
    },
    {
      "step": 2,
      "action": "Get player planets",
      "endpoint": "GET /api/player/{id}/planets",
      "dependsOn": ["player.id"],
      "output": "planets"
    },
    {
      "step": 3,
      "action": "Get planet structs",
      "endpoint": "GET /api/planet/{planetId}/structs",
      "dependsOn": ["planets[0].id"],
      "output": "structs"
    }
  ]
}
```

**Code Example**:
```javascript
async function linearChainWorkflow(playerId) {
  // Step 1: Get player
  const player = await getPlayer(playerId);
  
  // Step 2: Get player planets (depends on player)
  const planets = await getPlayerPlanets(player.id);
  
  // Step 3: Get planet structs (depends on planets)
  const structs = await getPlanetStructs(planets[0].id);
  
  return { player, planets, structs };
}
```

### Pattern 2: Conditional Chain

**Use Case**: Operations with conditional branching

**Structure**:
```
Step 1 → Condition Check → Branch A or Branch B
```

**Implementation**:
```json
{
  "pattern": "conditional-chain",
  "steps": [
    {
      "step": 1,
      "action": "Get player",
      "output": "player"
    },
    {
      "step": 2,
      "action": "Check condition",
      "condition": "player.guildId !== null",
      "ifTrue": "step3a",
      "ifFalse": "step3b"
    },
    {
      "step": "3a",
      "action": "Get guild info",
      "endpoint": "GET /api/guild/{guildId}",
      "dependsOn": ["player.guildId"]
    },
    {
      "step": "3b",
      "action": "Create guild or skip"
    }
  ]
}
```

**Code Example**:
```javascript
async function conditionalChainWorkflow(playerId) {
  const player = await getPlayer(playerId);
  
  if (player.guildId) {
    const guild = await getGuild(player.guildId);
    return { player, guild };
  } else {
    // No guild, skip guild step
    return { player };
  }
}
```

### Pattern 3: Retry Chain

**Use Case**: Operations that may need retries

**Structure**:
```
Step 1 → (Retry if needed) → Step 2 → (Retry if needed) → Step 3
```

**Implementation**:
```json
{
  "pattern": "retry-chain",
  "steps": [
    {
      "step": 1,
      "action": "Get player",
      "retry": {
        "enabled": true,
        "maxRetries": 3,
        "strategy": "exponential-backoff"
      }
    },
    {
      "step": 2,
      "action": "Get planets",
      "retry": {
        "enabled": true,
        "maxRetries": 3
      }
    }
  ]
}
```

**Code Example**:
```javascript
async function retryChainWorkflow(playerId) {
  const player = await retryWithBackoff(
    () => getPlayer(playerId),
    3
  );
  
  const planets = await retryWithBackoff(
    () => getPlayerPlanets(player.id),
    3
  );
  
  return { player, planets };
}
```

---

## Parallel Workflow Patterns

### Pattern 1: Independent Parallel

**Use Case**: Multiple independent operations

**Structure**:
```
Step 1 ─┐
Step 2 ─┼→ Combine Results
Step 3 ─┘
```

**Implementation**:
```json
{
  "pattern": "independent-parallel",
  "steps": [
    {
      "step": 1,
      "action": "Get player",
      "endpoint": "GET /api/player/{id}",
      "parallel": true
    },
    {
      "step": 2,
      "action": "Get guild",
      "endpoint": "GET /api/guild/{id}",
      "parallel": true,
      "independent": true
    },
    {
      "step": 3,
      "action": "Get planet",
      "endpoint": "GET /api/planet/{id}",
      "parallel": true,
      "independent": true
    }
  ],
  "combine": "After all parallel steps complete"
}
```

**Code Example**:
```javascript
async function independentParallelWorkflow(playerId, guildId, planetId) {
  // Execute all requests in parallel
  const [player, guild, planet] = await Promise.all([
    getPlayer(playerId),
    getGuild(guildId),
    getPlanet(planetId)
  ]);
  
  return { player, guild, planet };
}
```

### Pattern 2: Parallel with Dependency

**Use Case**: Some operations independent, some dependent

**Structure**:
```
Step 1 → Step 2 ─┐
                 ├→ Step 4
Step 3 ──────────┘
```

**Implementation**:
```json
{
  "pattern": "parallel-with-dependency",
  "steps": [
    {
      "step": 1,
      "action": "Get player",
      "output": "player"
    },
    {
      "step": 2,
      "action": "Get player planets",
      "dependsOn": ["player.id"],
      "output": "planets"
    },
    {
      "step": 3,
      "action": "Get guild",
      "dependsOn": ["player.guildId"],
      "parallel": true
    },
    {
      "step": 4,
      "action": "Combine results",
      "dependsOn": ["planets", "guild"]
    }
  ]
}
```

**Code Example**:
```javascript
async function parallelWithDependencyWorkflow(playerId) {
  // Step 1: Sequential
  const player = await getPlayer(playerId);
  
  // Steps 2 and 3: Parallel (both depend on player)
  const [planets, guild] = await Promise.all([
    getPlayerPlanets(player.id),
    player.guildId ? getGuild(player.guildId) : null
  ]);
  
  return { player, planets, guild };
}
```

### Pattern 3: Batch Parallel

**Use Case**: Multiple similar operations

**Structure**:
```
Batch: [Item1, Item2, Item3, ...] → Parallel Requests → Combine Results
```

**Implementation**:
```json
{
  "pattern": "batch-parallel",
  "steps": [
    {
      "step": 1,
      "action": "Get list of IDs",
      "output": "ids"
    },
    {
      "step": 2,
      "action": "Fetch each item in parallel",
      "batch": true,
      "items": "ids",
      "operation": "GET /api/player/{id}",
      "parallel": true
    }
  ]
}
```

**Code Example**:
```javascript
async function batchParallelWorkflow(playerIds) {
  // Fetch all players in parallel
  const players = await Promise.all(
    playerIds.map(id => getPlayer(id))
  );
  
  return players;
}
```

---

## State Management Patterns

### Pattern 1: Workflow State

**Use Case**: Track state across workflow steps

**Implementation**:
```json
{
  "pattern": "workflow-state",
  "state": {
    "workflowId": "unique-workflow-id",
    "step": 1,
    "completed": [],
    "pending": [2, 3, 4],
    "failed": [],
    "data": {}
  }
}
```

**Code Example**:
```javascript
class WorkflowState {
  constructor(workflowId) {
    this.workflowId = workflowId;
    this.step = 1;
    this.completed = [];
    this.pending = [];
    this.failed = [];
    this.data = {};
  }
  
  markComplete(step, result) {
    this.completed.push(step);
    this.data[step] = result;
    this.step++;
  }
  
  markFailed(step, error) {
    this.failed.push({ step, error });
  }
}
```

### Pattern 2: Checkpoint Pattern

**Use Case**: Resume workflow from checkpoint

**Implementation**:
```json
{
  "pattern": "checkpoint",
  "checkpoints": [
    {
      "step": 1,
      "checkpoint": "player-loaded",
      "data": "player"
    },
    {
      "step": 2,
      "checkpoint": "planets-loaded",
      "data": "planets"
    }
  ],
  "resume": "From last checkpoint"
}
```

**Code Example**:
```javascript
async function resumeFromCheckpoint(checkpoint) {
  if (checkpoint === 'player-loaded') {
    // Resume from step 2
    const planets = await getPlayerPlanets(checkpoint.data.player.id);
    return { player: checkpoint.data.player, planets };
  }
  // ... other checkpoints
}
```

---

## Error Handling in Workflows

### Pattern 1: Fail Fast

**Strategy**: Stop workflow on first error

**Implementation**:
```json
{
  "errorHandling": "fail-fast",
  "behavior": "Stop workflow on first error",
  "useWhen": "Critical workflow, errors are fatal"
}
```

**Code Example**:
```javascript
async function failFastWorkflow() {
  try {
    const player = await getPlayer(playerId);
    const planets = await getPlayerPlanets(player.id);
    return { player, planets };
  } catch (error) {
    // Stop immediately on error
    throw error;
  }
}
```

### Pattern 2: Continue on Error

**Strategy**: Continue workflow, collect errors

**Implementation**:
```json
{
  "errorHandling": "continue-on-error",
  "behavior": "Continue workflow, collect errors",
  "useWhen": "Non-critical steps, partial results acceptable"
}
```

**Code Example**:
```javascript
async function continueOnErrorWorkflow() {
  const errors = [];
  const results = {};
  
  try {
    results.player = await getPlayer(playerId);
  } catch (error) {
    errors.push({ step: 'player', error });
  }
  
  try {
    results.planets = await getPlayerPlanets(results.player?.id);
  } catch (error) {
    errors.push({ step: 'planets', error });
  }
  
  return { results, errors };
}
```

### Pattern 3: Retry with Fallback

**Strategy**: Retry failed steps, use fallback if retry fails

**Implementation**:
```json
{
  "errorHandling": "retry-with-fallback",
  "behavior": "Retry failed steps, use fallback",
  "fallback": "Use cached data or default values"
}
```

**Code Example**:
```javascript
async function retryWithFallbackWorkflow(playerId) {
  let player;
  
  try {
    player = await retryWithBackoff(() => getPlayer(playerId), 3);
  } catch (error) {
    // Fallback to cached data
    player = await getCachedPlayer(playerId);
  }
  
  return { player };
}
```

---

## Workflow Examples

### Example 1: Get Player and Planets

**Pattern**: Linear Chain

```json
{
  "workflow": "get-player-and-planets",
  "steps": [
    {
      "step": 1,
      "action": "GET /api/player/{id}",
      "output": "player"
    },
    {
      "step": 2,
      "action": "GET /api/player/{id}/planets",
      "dependsOn": ["player.id"],
      "output": "planets"
    }
  ]
}
```

### Example 2: Get Player, Guild, and Planet

**Pattern**: Parallel with Dependency

```json
{
  "workflow": "get-player-guild-planet",
  "steps": [
    {
      "step": 1,
      "action": "GET /api/player/{id}",
      "output": "player"
    },
    {
      "step": 2,
      "action": "GET /api/guild/{guildId}",
      "dependsOn": ["player.guildId"],
      "parallel": true
    },
    {
      "step": 3,
      "action": "GET /api/planet/{planetId}",
      "dependsOn": ["player.planetId"],
      "parallel": true
    }
  ]
}
```

### Example 3: Batch Fetch Players

**Pattern**: Batch Parallel

```json
{
  "workflow": "batch-fetch-players",
  "steps": [
    {
      "step": 1,
      "action": "GET /api/guild/{id}/members",
      "output": "memberIds"
    },
    {
      "step": 2,
      "action": "GET /api/player/{id}",
      "batch": true,
      "items": "memberIds",
      "parallel": true
    }
  ]
}
```

---

## Best Practices

### 1. Identify Dependencies

**Do**:
- Map dependencies between steps
- Execute dependent steps sequentially
- Execute independent steps in parallel

**Don't**:
- Execute dependent steps in parallel
- Block independent steps unnecessarily

### 2. Use Parallel Execution Wisely

**Do**:
- Use parallel execution for independent operations
- Limit concurrent requests (respect rate limits)
- Batch similar operations

**Don't**:
- Overwhelm the server with too many parallel requests
- Ignore rate limits
- Parallelize dependent operations

### 3. Handle Errors Appropriately

**Do**:
- Choose error handling strategy based on workflow criticality
- Retry transient errors
- Use fallbacks when appropriate

**Don't**:
- Ignore errors
- Retry non-retryable errors
- Fail silently

### 4. Track Workflow State

**Do**:
- Track workflow progress
- Save checkpoints for long-running workflows
- Log workflow execution

**Don't**:
- Lose state on errors
- Forget to update progress
- Skip error logging

### 5. Optimize for Performance

**Do**:
- Use parallel execution when possible
- Cache intermediate results
- Batch similar operations

**Don't**:
- Make unnecessary sequential calls
- Repeat identical requests
- Ignore caching opportunities

---

## Integration with Other Patterns

### Workflow + Retry

**Pattern**: Retry failed steps in workflow

```json
{
  "integration": {
    "workflow": "linear-chain",
    "retry": "exponential-backoff",
    "strategy": "Retry each step on failure"
  }
}
```

**Reference**: `patterns/retry-strategies.md`

### Workflow + Caching

**Pattern**: Cache workflow results

```json
{
  "integration": {
    "workflow": "get-player-and-planets",
    "cache": "Cache final result",
    "strategy": "Reuse cached result if available"
  }
}
```

**Reference**: `patterns/caching.md`

### Workflow + Rate Limiting

**Pattern**: Respect rate limits in parallel workflows

```json
{
  "integration": {
    "workflow": "batch-parallel",
    "rateLimit": "Throttle parallel requests",
    "strategy": "Limit concurrent requests to stay within rate limit"
  }
}
```

**Reference**: `patterns/rate-limiting.md`

---

## Related Documentation

- **Retry Strategies**: `patterns/retry-strategies.md` - Retry patterns for failed requests
- **Caching**: `patterns/caching.md` - Caching strategies
- **Rate Limiting**: `patterns/rate-limiting.md` - Rate limit handling
- **Error Handling**: `protocols/error-handling.md` - Error handling protocol
- **Workflow Examples**: `examples/workflows/` - Complete workflow examples

---

## Quick Reference

### Sequential Patterns
- **Linear Chain**: Step 1 → Step 2 → Step 3
- **Conditional Chain**: Step 1 → Condition → Branch
- **Retry Chain**: Step 1 → (Retry) → Step 2

### Parallel Patterns
- **Independent Parallel**: Step 1, Step 2, Step 3 (parallel)
- **Parallel with Dependency**: Step 1 → Step 2, Step 3 (parallel)
- **Batch Parallel**: Batch → Parallel Requests

### Error Handling
- **Fail Fast**: Stop on first error
- **Continue on Error**: Collect errors, continue
- **Retry with Fallback**: Retry, then use fallback

---

*Pattern Version: 1.0.0 - January 2025*

