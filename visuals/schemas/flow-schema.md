# Flow Schema

**Version**: 1.0.0
**Category**: visual

Schema for process flows and workflows.

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique flow identifier |
| type | string | Yes | Type of flow. One of: `process`, `workflow`, `conversion`, `state-machine` |
| title | string | Yes | Human-readable flow title |
| description | string | No | Description of what the flow represents |
| category | string | No | Category. One of: `gameplay`, `economics`, `technical`, `system` |
| steps | array of [Step](#step) | Yes | Steps in the flow |
| transitions | array of [Transition](#transition) | Yes | Transitions between steps |
| relatedSchemas | array of string | No | References to related schemas |
| relatedEndpoints | array of string | No | References to related API endpoints |
| relatedDiagrams | array of string | No | References to related diagrams |

---

## Step

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique step identifier |
| label | string | Yes | Human-readable step label |
| type | string | Yes | Step type. One of: `action`, `state`, `decision`, `process`, `conversion` |
| action | string | No | Action ID if step is an action (e.g., `mine`, `refine`) |
| actionReference | string | No | Reference to action schema |
| input | object | No | Input resources or state |
| output | object | No | Output resources or state |
| requirements | array of string | No | Requirements for this step |
| metadata | object | No | Additional step metadata |

---

## Transition

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique transition identifier |
| from | string | Yes | Source step ID |
| to | string | Yes | Target step ID |
| label | string | No | Transition label |
| condition | string | No | Condition for transition (if applicable) |
| metadata | object | No | Additional transition metadata |

---

## Related Documentation

- [Diagram Schema](diagram-schema.md)
- [Decision Tree Schema](decision-tree.md)
- [Pattern Schema](pattern-schema.md)
