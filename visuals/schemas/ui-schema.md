# UI Schema

**Version**: 1.0.0
**Category**: visual

Schema for UI elements and screens.

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique UI element identifier |
| type | string | Yes | Type of UI item. One of: `screen`, `element`, `component`, `pattern` |
| title | string | Yes | Human-readable title |
| description | string | No | Description of UI element |
| category | string | No | UI category. One of: `gameplay`, `economics`, `technical`, `navigation` |
| path | string | No | Path to image or visual representation |
| location | object | No | UI element location. See [Location](#location) |
| elements | array of [Element](#element) | No | Child UI elements (for screens/components) |
| annotations | array of [Annotation](#annotation) | No | Annotations or highlights |
| relatedSchemas | array of string | No | References to related schemas |
| relatedEndpoints | array of string | No | References to related API endpoints |

---

## Location

| Field | Type | Description |
|-------|------|-------------|
| screen | string | Screen identifier |
| area | string | Area within screen. One of: `top`, `bottom`, `left`, `right`, `center`, `sidebar`, `header`, `footer` |
| coordinates | object | Pixel coordinates with `x`, `y`, `width`, `height` (all numbers) |

---

## Element

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Element identifier |
| type | string | Yes | Element type. One of: `button`, `panel`, `list`, `input`, `display`, `icon`, `text` |
| label | string | No | Element label |
| action | string | No | Action triggered by element (if applicable) |
| relatedEndpoint | string | No | Related API endpoint (if applicable) |
| relatedSchema | string | No | Related schema reference (if applicable) |

---

## Annotation

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Annotation identifier |
| type | string | Yes | Annotation type. One of: `highlight`, `note`, `label`, `arrow` |
| area | object | No | Area with `x`, `y`, `width`, `height` (all numbers) |
| text | string | No | Annotation text |

---

## Related Documentation

- [Pattern Schema](pattern-schema.md)
- [Diagram Schema](diagram-schema.md)
