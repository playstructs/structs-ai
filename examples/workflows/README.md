# Workflow Examples Index

**Version**: 1.0.0  
**Purpose**: Quick reference index of all workflow examples for AI agents

---

## Overview

This directory contains complete, runnable workflow examples demonstrating multi-step API operations. Each workflow shows how to chain API calls, handle dependencies, and manage state across multiple steps.

**All workflows follow the workflow patterns documented in**: `patterns/workflow-patterns.md`

---

## Workflow Categories

### Query Workflows

Workflows focused on retrieving and querying game state data.

#### `get-player-and-planets.md`
**Pattern**: Linear Chain  
**Purpose**: Get player information and their planets

**Steps**:
1. Get player by ID
2. Get player's planets
3. Return combined data

**Use When**:
- Need player and planet data together
- Building player dashboard
- Initial data loading

**Dependencies**: None (takes player ID as input)

---

#### `query-guild-stats.md`
**Pattern**: Parallel with Dependency  
**Purpose**: Query comprehensive guild statistics

**Steps**:
1. Get guild information
2. Get guild member count (parallel)
3. Get guild power stats (parallel)
4. Combine results

**Use When**:
- Displaying guild dashboard
- Analyzing guild performance
- Building guild reports

**Dependencies**: Guild ID

---

#### `query-and-monitor-planet.md`
**Pattern**: Hybrid (Query + Streaming)  
**Purpose**: Query planet data and monitor for updates

**Steps**:
1. Get planet information (query)
2. Subscribe to planet events (streaming)
3. Monitor for updates
4. Handle events

**Use When**:
- Need initial planet data
- Want real-time updates
- Monitoring planet state changes

**Dependencies**: Planet ID

---

### Authentication Workflows

Workflows demonstrating authentication and authenticated operations.

#### `authenticated-guild-query.md`
**Pattern**: Linear Chain with Authentication  
**Purpose**: Authenticate and query guild information

**Steps**:
1. Login to webapp API
2. Store session cookie
3. Make authenticated request to get guild
4. Return guild data

**Use When**:
- Need to access authenticated endpoints
- Querying guild information
- Demonstrating authentication flow

**Dependencies**: Username and password

**Related**: See `examples/auth/` for authentication examples

---

### Monitoring Workflows

Workflows for monitoring game state in real-time.

#### `monitor-planet-shield.md`
**Pattern**: Streaming  
**Purpose**: Monitor planet shield health in real-time

**Steps**:
1. Connect to GRASS/NATS
2. Subscribe to planet shield events
3. Process shield updates
4. Handle shield status changes

**Use When**:
- Monitoring planet during raid
- Tracking shield health
- Real-time shield status updates

**Dependencies**: Planet ID, NATS connection

**Related**: See `patterns/polling-vs-streaming.md` for streaming patterns

---

### Modding Workflows

Workflows for cosmetic mod management.

#### `install-and-use-cosmetic-mod.md`
**Pattern**: Linear Chain  
**Purpose**: Install and use a cosmetic mod

**Steps**:
1. Validate mod file
2. Install mod
3. Activate mod
4. Verify installation
5. Query struct type with cosmetics
6. Use cosmetic data

**Use When**:
- Installing cosmetic mods
- Managing mod lifecycle
- Testing mod integration

**Dependencies**: Mod file, Guild ID

**Related**: See `api/cosmetic-mods.md` for mod API endpoints

---

## Workflow Patterns Used

### Linear Chain
- `get-player-and-planets.md`
- `install-and-use-cosmetic-mod.md`
- `authenticated-guild-query.md`

**Use When**: Steps depend on previous results

### Parallel with Dependency
- `query-guild-stats.md`

**Use When**: Some steps can run in parallel after initial dependency

### Hybrid (Query + Streaming)
- `query-and-monitor-planet.md`

**Use When**: Need initial data and real-time updates

### Streaming
- `monitor-planet-shield.md`

**Use When**: Only need real-time updates

---

## Quick Reference

### By Use Case

**Player Operations**:
- `get-player-and-planets.md` - Get player and planets

**Guild Operations**:
- `query-guild-stats.md` - Get guild statistics
- `authenticated-guild-query.md` - Authenticated guild query

**Planet Operations**:
- `query-and-monitor-planet.md` - Query and monitor planet
- `monitor-planet-shield.md` - Monitor shield health

**Modding Operations**:
- `install-and-use-cosmetic-mod.md` - Install and use mod

### By Pattern

**Linear Chain**:
- `get-player-and-planets.md`
- `install-and-use-cosmetic-mod.md`
- `authenticated-guild-query.md`

**Parallel**:
- `query-guild-stats.md`

**Hybrid**:
- `query-and-monitor-planet.md`

**Streaming**:
- `monitor-planet-shield.md`

---

## Workflow Structure

All workflows follow this structure:

```json
{
  "workflow": {
    "id": "workflow-identifier",
    "name": "Human-readable name",
    "description": "What this workflow does",
    "pattern": "workflow-pattern-name",
    "steps": [
      {
        "step": 1,
        "name": "Step name",
        "action": "What this step does",
        "endpoint": "API endpoint",
        "method": "HTTP method",
        "dependsOn": ["previous-step-output"],
        "output": "step-output-key"
      }
    ],
    "inputs": {
      "required": ["input1", "input2"],
      "optional": ["input3"]
    },
    "outputs": {
      "data": "output-data-key"
    },
    "errorHandling": {
      "strategy": "fail-fast|continue-on-error|retry-with-fallback"
    }
  }
}
```

---

## Using Workflows

### 1. Find the Right Workflow

Use this index to find workflows by:
- **Use case**: What you want to accomplish
- **Pattern**: What workflow pattern you need
- **Category**: Type of operation

### 2. Review the Workflow

Read the workflow file to understand:
- Required inputs
- Step-by-step process
- Expected outputs
- Error handling strategy

### 3. Adapt to Your Needs

Customize the workflow for your specific requirements:
- Modify endpoints
- Add additional steps
- Change error handling
- Add validation

### 4. Implement

Use the workflow as a template for your implementation:
- Follow the step sequence
- Handle dependencies correctly
- Implement error handling
- Test with real API

---

## Related Documentation

- **Workflow Patterns**: `patterns/workflow-patterns.md` - Complete workflow pattern guide
- **Retry Strategies**: `patterns/retry-strategies.md` - Retry patterns for failed steps
- **Error Handling**: `protocols/error-handling.md` - Error handling protocol
- **Authentication**: `protocols/authentication.md` - Authentication protocol
- **Streaming**: `protocols/streaming.md` - GRASS/NATS streaming protocol

---

## Contributing Workflows

When adding new workflows:

1. **Follow the structure** - Use the standard workflow structure
2. **Document clearly** - Include description, inputs, outputs
3. **Use patterns** - Follow workflow patterns from `patterns/workflow-patterns.md`
4. **Add to index** - Update this README with the new workflow
5. **Test thoroughly** - Ensure workflow works with real API

---

*Last Updated: December 7, 2025*

