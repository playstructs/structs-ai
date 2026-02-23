# Visual Pattern Schema

**Version**: 1.0.0
**Category**: visual

Schema for visual patterns and UI patterns.

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique pattern identifier |
| type | string | Yes | Type of visual pattern. One of: `ui-pattern`, `layout-pattern`, `interaction-pattern`, `visual-pattern` |
| title | string | Yes | Human-readable pattern title |
| description | string | No | Description of the pattern |
| category | string | No | Category. One of: `gameplay`, `economics`, `technical`, `ui`, `navigation` |
| components | array of [Component](#component) | Yes | Components in the pattern |
| relationships | array of [Relationship](#relationship) | No | Relationships between components |
| usage | object | No | Usage information. See [Usage](#usage) |
| relatedSchemas | array of string | No | References to related schemas |
| relatedEndpoints | array of string | No | References to related API endpoints |
| relatedDiagrams | array of string | No | References to related diagrams |

---

## Component

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique component identifier |
| label | string | Yes | Human-readable component label |
| type | string | Yes | Component type. One of: `element`, `container`, `layout`, `interaction` |
| uiElement | string | No | UI element type (e.g., `button`, `panel`, `list`) |
| location | object | No | Component location. See [Location](#location) |
| metadata | object | No | Additional component metadata |

### Location

| Field | Type | Description |
|-------|------|-------------|
| area | string | One of: `top`, `bottom`, `left`, `right`, `center`, `sidebar`, `header`, `footer` |
| coordinates | object | Position with `x`, `y`, `width`, `height` (all numbers) |

---

## Relationship

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique relationship identifier |
| from | string | Yes | Source component ID |
| to | string | Yes | Target component ID |
| type | string | Yes | Relationship type. One of: `contains`, `triggers`, `navigatesTo`, `displays`, `dependsOn` |
| label | string | No | Relationship label |
| metadata | object | No | Additional relationship metadata |

---

## Usage

| Field | Type | Description |
|-------|------|-------------|
| context | string | Context where pattern is used |
| examples | array of string | Example use cases |

---

## Related Documentation

- [UI Schema](ui-schema.md)
- [Diagram Schema](diagram-schema.md)
- [Flow Schema](flow-schema.md)
