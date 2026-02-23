# GRASS/NATS Streaming API Documentation

**Purpose**: Complete documentation for GRASS (Game Real-time Application Streaming Service) via NATS messaging

---

## Overview

GRASS provides real-time game state updates through NATS messaging. This directory contains all documentation needed for AI agents to connect to and consume GRASS events.

---

## Files in This Directory

### `event-schemas.md`
Complete JSON Schema definitions for all GRASS event payloads.

**Contains**:
- Base event structure
- Event type schemas (Player, Guild, Planet, Struct, Fleet, Block)
- Event category definitions

**Usage**: Validate event payloads against these schemas

### `event-types.yaml`
Complete catalog of all GRASS event types and categories.

**Contains**:
- Event categories (consensus, guild, planet, struct, player)
- Subject patterns
- Schema references for each event type

**Usage**: Discover available event types and their subject patterns

### `subscription-patterns.yaml`
Subscription patterns and best practices for connecting to GRASS.

**Contains**:
- Connection patterns (NATS protocol, NATS WebSocket)
- Subscription examples
- Best practices
- Error handling

**Usage**: Learn how to subscribe to GRASS events

---

## Quick Start

### 1. Read the Protocol

Start with: `../../protocols/streaming.md`

This provides complete protocol documentation including:
- Architecture overview
- Connection configuration
- Subscription patterns
- Code examples

### 2. Understand Event Types

Review: `event-types.yaml`

This catalog shows all available event types and their subject patterns.

### 3. Validate Events

Use: `event-schemas.md`

Validate received events against these JSON Schemas.

### 4. Follow Patterns

Reference: `subscription-patterns.yaml`

Follow these patterns for reliable event subscriptions.

---

## Connection Details

**NATS Protocol**: `nats://localhost:4222`  
**NATS WebSocket**: `ws://localhost:1443`

**See**: `../../protocols/streaming.md` for complete connection documentation

---

## Subject Patterns

**Player Events**: `structs.player.*`  
**Guild Events**: `structs.guild.*`  
**Planet Events**: `structs.planet.*`  
**Struct Events**: `structs.struct.*`  
**Fleet Events**: `structs.fleet.*`  
**Global Events**: `structs.global`

**See**: `event-types.yaml` for complete subject pattern catalog

---

## Related Documentation

- **Protocol**: `../../protocols/streaming.md`
- **API Reference**: `../../../technical/api-reference.md#grass-api`
- **Examples**: `../../examples/` (check for streaming examples)

---

*API Documentation Specialist - January 2025*

