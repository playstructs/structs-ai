# Spatial Schema

**Version**: 1.0.0
**Category**: visual

Schema for spatial/geometric data (coordinates, positions, layouts).

---

## Top-Level Properties

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Unique spatial data identifier |
| type | string | Yes | Type of spatial data. One of: `coordinate-system`, `position`, `layout`, `region` |
| title | string | Yes | Human-readable title |
| description | string | No | Description of spatial data |
| coordinateSystem | object | No | Coordinate system definition. See [Coordinate System](#coordinate-system) |
| positions | array of [Position](#position) | No | List of positions |
| regions | array of [Region](#region) | No | List of regions or areas |
| relatedSchemas | array of string | No | References to related schemas |

---

## Coordinate System

| Field | Type | Description |
|-------|------|-------------|
| type | string | Coordinate system type. One of: `cartesian`, `polar`, `grid` |
| origin | object | Origin point with `x`, `y`, `z` (all numbers) |
| units | string | Unit of measurement |
| bounds | object | Coordinate system bounds. Contains `min` and `max` objects, each with `x`, `y`, `z` (all numbers) |

---

## Position

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Entity or object identifier |
| entityType | string | No | Type of entity (e.g., `Planet`, `Fleet`) |
| coordinates | object | Yes | Position coordinates with `x`, `y`, `z` (all numbers) |
| metadata | object | No | Additional position metadata |

---

## Region

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | string | Yes | Region identifier |
| type | string | Yes | Region type |
| bounds | object | Yes | Region bounds. Contains `min` and `max` objects, each with `x`, `y`, `z` (all numbers) |
| metadata | object | No | Additional region metadata |

---

## Related Documentation

- [Diagram Schema](diagram-schema.md)
- [Pattern Schema](pattern-schema.md)
