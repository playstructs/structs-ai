# Relationship Graph Schema

**Version**: 1.0.0
**Category**: visual

Schema for relationship graphs showing entity connections and dependencies.

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique graph identifier |
| type | string | Yes | Type of relationship graph. One of: `relationship`, `dependency`, `hierarchy`, `network` |
| title | string | Yes | Human-readable graph title |
| description | string | No | Description of what the graph represents |
| category | string | No | Category. One of: `gameplay`, `economics`, `technical`, `system` |
| entities | array of [Entity](#entity) | Yes | Entities in the graph |
| relationships | array of [Relationship](#relationship) | Yes | Relationships between entities |
| relatedSchemas | array of string | No | References to related schemas |
| relatedEndpoints | array of string | No | References to related API endpoints |
| relatedDiagrams | array of string | No | References to related diagrams |

---

## Entity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique entity identifier |
| label | string | Yes | Human-readable entity label |
| entityType | string | Yes | Entity type (e.g., `Player`, `Planet`, `Struct`) |
| schemaReference | string | No | Reference to schema definition |
| metadata | object | No | Additional entity metadata |

---

## Relationship

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique relationship identifier |
| from | string | Yes | Source entity ID |
| to | string | Yes | Target entity ID |
| type | string | Yes | Relationship type. One of: `owns`, `contains`, `dependsOn`, `requires`, `produces`, `consumes`, `memberOf`, `locatedOn`, `typeOf` |
| label | string | No | Human-readable relationship label |
| direction | string | No | Relationship direction. One of: `directed` (default), `undirected`, `bidirectional` |
| cardinality | string | No | Relationship cardinality. One of: `one-to-one`, `one-to-many`, `many-to-one`, `many-to-many` |
| metadata | object | No | Additional relationship metadata |

---

## Related Documentation

- [Diagram Schema](diagram-schema.md)
- [Pattern Schema](pattern-schema.md)
