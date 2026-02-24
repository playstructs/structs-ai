# Struct Lifecycle - Sweep Delay Workflow

**Version**: 1.0.0
**Category**: lifecycle
**Description**: Detailed workflow for StructSweepDelay behavior after struct destruction

---

## Workflow: Struct Destruction and Sweep Delay

### Step 1: Check Struct Before Destruction

Query struct to verify it exists and get slot information.

**Endpoint**: `GET /structs/struct/{structId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `struct.id` | `5-1` |
| `struct.locationType` | `1` |
| `struct.locationId` | `2-1` |
| `struct.status` | `online` |
| `struct.destroyed` | `false` |

**Slot Info** -- `GET /structs/planet/{planetId}`:

```json
{
  "planet.slots": {
    "space": ["5-1", null, null, null]
  }
}
```

Struct occupies slot 0 in space ambit.

### Step 2: Destroy Struct

Destroy struct (via combat, planet completion, or explicit action).

**Triggers**:

1. Combat destruction
2. Planet completion
3. Explicit destruction action

**Expected Result**:

| Field | Value |
|-------|-------|
| `struct.destroyed` | `true` |
| `struct.status` | `0` |

> **Note**: Struct is marked as destroyed but persists for StructSweepDelay period.

### Step 3: Verify Struct Destroyed

Query struct to confirm destroyed status.

**Endpoint**: `GET /structs/struct/{structId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `struct.destroyed` | `true` |
| `struct.status` | `0` |

**Database Query**:

```sql
SELECT * FROM struct WHERE id = ? AND destroyed = true
```

Destroyed structs are queryable during delay period.

### Step 4: Check Slot During Delay Period

Query planet/fleet slots during StructSweepDelay period (blocks 0-4).

During blocks 0 through 4, the slot still references the destroyed struct ID.

**Endpoint**: `GET /structs/planet/{planetId}`

| Block | `planet.slots.space[0]` | Note |
|-------|--------------------------|------|
| 0 | `5-1` | Slot still references destroyed struct ID |
| 1 | `5-1` | Slot still references destroyed struct ID |
| 2 | `5-1` | Slot still references destroyed struct ID |
| 3 | `5-1` | Slot still references destroyed struct ID |
| 4 | `5-1` | Last block of delay |

### Step 5: Wait for Sweep Delay to Complete

Wait for StructSweepDelay (5 blocks) to complete.

**Monitoring**:

| Parameter | Value |
|-----------|-------|
| Method | Poll planet/fleet slots |
| Interval | Every block |
| Max Blocks | 5 |
| Check Field | `planet.slots.space[0]` |

### Step 6: Verify Slot Cleared After Delay

Query planet/fleet after StructSweepDelay to confirm slot is cleared.

**Endpoint**: `GET /structs/planet/{planetId}`

**Expected Fields**:

| Field | Expected Value |
|-------|----------------|
| `planet.slots.space[0]` | `null` |

Slot is cleared after 5 blocks, available for new structs.

**Database Query**:

```sql
SELECT slots FROM planet WHERE id = ?
```

**Expected Result**:

```json
{
  "slots": {
    "space": [null, null, null, null]
  }
}
```

Slot 0 is now null (cleared).

### Step 7: Verify Struct No Longer Queryable

Confirm destroyed struct is no longer queryable after delay.

**Endpoint**: `GET /structs/struct/{structId}`

**Expected Response**:

```json
{
  "code": 404,
  "error": "ENTITY_NOT_FOUND"
}
```

Struct is fully removed after sweep delay.

**Database Query**:

```sql
SELECT * FROM struct WHERE id = ?
```

Returns 0 rows. Struct removed from database after sweep delay.

---

## Struct Destruction Timeline

| Block | Event | `struct.destroyed` | Slot Status | Struct Queryable |
|-------|-------|--------------------|-------------|------------------|
| 0 | Struct destroyed | `true` | occupied (references destroyed struct) | Yes |
| 1 | Delay period continues | `true` | occupied (references destroyed struct) | Yes |
| 2 | Delay period continues | `true` | occupied (references destroyed struct) | Yes |
| 3 | Delay period continues | `true` | occupied (references destroyed struct) | Yes |
| 4 | Last block of delay | `true` | occupied (references destroyed struct) | Yes |
| 5 | Sweep delay complete | `true` | cleared (null) | No |

> **Note**: At block 5, struct is fully removed and slot is available for new structs.

---

## Slot Clearing Behavior

### During Delay (Blocks 0-4)

| Property | Value |
|----------|-------|
| Slot Status | occupied |
| Slot Value | destroyed struct ID |
| Available for New Struct | No |

Slot back reference persists during delay.

### After Delay (Block 5+)

| Property | Value |
|----------|-------|
| Slot Status | cleared |
| Slot Value | `null` |
| Available for New Struct | Yes |

Slot is fully cleared and available.

### Planet Slots Example

**Before Destruction**:

```json
{
  "space": ["5-1", "5-2", null, null],
  "air": [null, null, null, null],
  "land": [null, null, null, null],
  "water": [null, null, null, null]
}
```

**During Delay**: Slot 0 still references destroyed struct `5-1`:

```json
{
  "space": ["5-1", "5-2", null, null]
}
```

**After Delay**: Slot 0 is cleared, slot 1 still has struct `5-2`:

```json
{
  "space": [null, "5-2", null, null]
}
```

### Fleet Slots Example

**Before Destruction**:

```json
{
  "space": ["5-3", null, null, null]
}
```

**During Delay**: Slot still references destroyed struct:

```json
{
  "space": ["5-3", null, null, null]
}
```

**After Delay**: Slot is cleared:

```json
{
  "space": [null, null, null, null]
}
```

---

## Query Patterns

### During Delay

**Query Destroyed Struct** -- `GET /structs/struct/{structId}`:

| Field | Value |
|-------|-------|
| `struct.destroyed` | `true` |
| `struct.status` | `0` |

Struct is queryable but destroyed.

**Query Planet Slots** -- `GET /structs/planet/{planetId}`:

| Field | Value |
|-------|-------|
| `planet.slots.space[0]` | destroyed struct ID |

Slot still references destroyed struct.

**Query All Destroyed Structs** (database):

```sql
SELECT * FROM struct WHERE destroyed = true
```

Returns all destroyed structs including those in delay period.

### After Delay

**Query Destroyed Struct** -- `GET /structs/struct/{structId}`:

Returns `404 ENTITY_NOT_FOUND`. Struct no longer exists.

**Query Planet Slots** -- `GET /structs/planet/{planetId}`:

| Field | Value |
|-------|-------|
| `planet.slots.space[0]` | `null` |

Slot is cleared and available.

**Query All Destroyed Structs** (database):

```sql
SELECT * FROM struct WHERE destroyed = true
```

Returns only structs still in delay period, not fully swept ones.

---

## State Transitions

### Struct States

| State | Status | Destroyed | Queryable | Slot Occupied | Note |
|-------|--------|-----------|-----------|---------------|------|
| Before Destruction | `online` | `false` | Yes | Yes | -- |
| After Destruction | `0` | `true` | Yes | Yes | In StructSweepDelay period |
| After Sweep Delay | removed | `true` | No | No | Fully removed after delay |

### Slot States

| State | Status | Value | Available |
|-------|--------|-------|-----------|
| Before Destruction | occupied | struct ID | No |
| During Delay | occupied | destroyed struct ID | No |
| After Delay | cleared | `null` | Yes |

---

## Examples

### Combat Destruction

1. Struct attacked and destroyed
2. Struct marked as destroyed
3. Slot remains occupied for 5 blocks
4. After 5 blocks, slot cleared

### Planet Completion

1. Planet completion triggers struct destruction
2. All structs marked as destroyed
3. Slots remain occupied for 5 blocks each
4. After 5 blocks, all slots cleared

### Explicit Destruction

1. Player destroys struct
2. Struct marked as destroyed
3. Slot remains occupied for 5 blocks
4. After 5 blocks, slot cleared

### Building After Delay

1. Struct destroyed
2. Wait 5 blocks for sweep delay
3. Slot cleared
4. Build new struct in cleared slot

---

## Monitoring

### Track Sweep Delay

- **Description**: Monitor structs during sweep delay period
- **Query**: `SELECT * FROM struct WHERE destroyed = true`
- **Polling**: Check every block
- **Action**: Track which structs are in delay period

### Wait for Slot Clear

- **Description**: Wait for slot to clear before building
- **Query**: `GET /structs/planet/{planetId}`
- **Check**: `planet.slots.space[slotIndex] === null`
- **Action**: Only build when slot is cleared
