# Planet Setup Workflow

**Version**: 1.0.0
**ID**: planet-setup
**Category**: Gameplay
**Type**: Workflow

---

## Steps

### 1. Explore New Planet

Explore new planet.

- **Action**: `explore`

**Prerequisites**: Current planet must be complete.

**Expected Response**:

```json
{
  "status": "explored",
  "newPlanetId": "3-1",
  "startingProperties": {
    "maxOre": 5,
    "spaceSlots": 4,
    "airSlots": 4,
    "landSlots": 4,
    "waterSlots": 4
  }
}
```

### 2. Chart Planet

Chart planet to reveal resources.

- **Action**: `chart`
- **Planet ID**: `3-1`

**Expected Response**:

```json
{
  "status": "charted",
  "revealed": {
    "resources": {
      "maxOre": 5,
      "currentOre": 5
    },
    "slots": {
      "space": 4,
      "air": 4,
      "land": 4,
      "water": 4
    },
    "ownership": {
      "claimed": false
    }
  }
}
```

### 3. Evaluate Planet Value

Evaluate planet value based on:

- Resource value
- Strategic value
- Defense needs

### 4. Claim Planet

Claim planet by building first structure.

- **Action**: `build`
- **Struct Type**: `oreExtractor`
- **Location Type**: `1`
- **Location ID**: `3-1`
- **Slot**: `land`

**Requirements**:

| Requirement | Value |
|-------------|-------|
| Fleet on station | Yes |
| Command Ship online | Yes |
| Sufficient power | 500,000 |

### 5. Build Defenses

Build defenses first (high priority).

- **Action**: `build`
- **Struct Type**: `planetaryDefenseCannon`
- **Location Type**: `1`
- **Location ID**: `3-1`
- **Slot**: `space`

**Requirements**:

| Requirement | Value |
|-------------|-------|
| Sufficient power | 600,000 |
| Max per player | 1 |
| Current count | 0 |

### 6. Build Infrastructure

Build infrastructure after defenses are in place.

- **Action**: `build`
- **Struct Type**: `oreRefinery`
- **Location Type**: `1`
- **Location ID**: `3-1`
- **Slot**: `land`

**Requirements**:

| Requirement | Value |
|-------------|-------|
| Sufficient power | 500,000 |

## Recommended Order

1. Explore
2. Chart
3. Evaluate
4. Claim
5. Defenses
6. Infrastructure

## Principles

- Explore when current planet is complete
- Chart before claiming
- Build defenses first
- Build infrastructure after defenses
- Plan power needs in advance
