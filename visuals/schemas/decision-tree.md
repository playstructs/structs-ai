# Decision Tree Schema

**Version**: 1.0.0
**Category**: visual

Schema for decision trees and decision-making flows.

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique decision tree identifier |
| type | string | Yes | Type of decision structure. One of: `decision-tree`, `flowchart`, `logic-tree` |
| title | string | Yes | Human-readable decision tree title |
| description | string | No | Description of what the decision tree represents |
| category | string | No | Category. One of: `gameplay`, `economics`, `technical`, `system` |
| nodes | array of [Node](#node) | Yes | Nodes in the decision tree |
| edges | array of [Edge](#edge) | Yes | Edges (branches) in the decision tree |
| rootNode | string | Yes | ID of the root/start node |
| relatedSchemas | array of string | No | References to related schemas |
| relatedEndpoints | array of string | No | References to related API endpoints |
| relatedDiagrams | array of string | No | References to related diagrams |

---

## Node

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique node identifier |
| label | string | Yes | Human-readable node label |
| type | string | Yes | Node type. One of: `decision`, `condition`, `action`, `outcome`, `start`, `end` |
| question | string | No | Question or condition (for `decision`/`condition` nodes) |
| action | string | No | Action ID if node is an action |
| actionReference | string | No | Reference to action schema |
| outcome | string | No | Outcome description (for `outcome` nodes) |
| metadata | object | No | Additional node metadata |

---

## Edge

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique edge identifier |
| from | string | Yes | Source node ID |
| to | string | Yes | Target node ID |
| label | string | No | Edge label (e.g., `Yes`, `No`, `If true`) |
| condition | string | No | Condition for this branch |
| metadata | object | No | Additional edge metadata |

---

## Related Documentation

- [Diagram Schema](diagram-schema.md)
- [Flow Schema](flow-schema.md)
