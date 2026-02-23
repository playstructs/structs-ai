# Diagram Schema

**Version**: 1.0.0
**Category**: visual

Schema for diagram structures (process flows, relationships, etc.).

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique diagram identifier |
| type | string | Yes | Type of diagram. One of: `flow`, `relationship`, `process`, `decision-tree`, `system` |
| title | string | Yes | Human-readable diagram title |
| description | string | No | Description of what the diagram represents |
| category | string | No | Category. One of: `gameplay`, `economics`, `technical`, `system` |
| nodes | array of [Node](#node) | Yes | Nodes in the diagram |
| edges | array of [Edge](#edge) | Yes | Edges (connections) in the diagram |
| relatedSchemas | array of string | No | References to related schemas |
| relatedEndpoints | array of string | No | References to related API endpoints |
| relatedDiagrams | array of string | No | References to related diagrams |

---

## Node

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique node identifier |
| label | string | Yes | Human-readable node label |
| type | string | Yes | Node type (entity, action, state, etc.) |
| entityType | string | No | Entity type if node represents an entity (e.g., `Player`, `Planet`) |
| schemaReference | string | No | Reference to schema definition (e.g., `schemas/entities.md#player`) |
| metadata | object | No | Additional node metadata |

---

## Edge

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique edge identifier |
| source | string | Yes | Source node ID |
| target | string | Yes | Target node ID |
| label | string | No | Edge label (relationship type, action, etc.) |
| type | string | Yes | Edge type. One of: `relationship`, `action`, `flow`, `dependency` |
| direction | string | No | Edge direction. One of: `directed`, `undirected`, `bidirectional` |
| metadata | object | No | Additional edge metadata |

---

## Related Documentation

- [Flow Schema](flow-schema.md)
- [Decision Tree Schema](decision-tree.md)
- [Relationship Graph Schema](relationship-graph.md)
- [Pattern Schema](pattern-schema.md)
