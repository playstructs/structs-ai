# Minimal Schemas

**Purpose**: Lightweight schemas containing only essential information for simple operations.

**Use Case**: Load these schemas when you only need basic information (ID format, existence checks, simple lookups) and don't need complete entity data.

---

## Available Minimal Schemas

### Core Entities

- `player-essential.md` - Essential player information (~30 lines)
- `planet-essential.md` - Essential planet information (~30 lines)
- `struct-essential.md` - Essential struct information (~30 lines)

### When to Use Minimal Schemas

✅ **Use minimal schemas for**:
- ID format verification
- Existence checks
- Basic status queries
- Quick lookups
- Simple relationship checks (owner, location)

❌ **Don't use minimal schemas for**:
- Complete entity data
- Detailed state information
- Complex operations
- Power/resource calculations
- Full workflow operations

---

## Schema Structure

All minimal schemas include:

1. **Essential Properties Only**: ID, basic relationships, key status fields
2. **Reference to Complete Schema**: `structs:completeSchema` field points to full schema
3. **Use Case Documentation**: `structs:useCases` and `structs:whenToUse` fields
4. **Size Optimization**: Typically 30-50 lines vs. 200+ lines for complete schemas

---

## Loading Strategy

### Example: Simple Player Lookup

**Minimal Load** (30 lines):
```json
{
  "file": "schemas/minimal/player-essential.md",
  "purpose": "Check if player exists, get basic info"
}
```

**Complete Load** (200+ lines):
```json
{
  "file": "schemas/entities/player.md",
  "purpose": "Get complete player data with all fields"
}
```

**Savings**: 85% reduction in context window usage for simple operations.

---

## Migration Path

If you start with a minimal schema and need more information:

1. **Check `structs:completeSchema` field** - Points to full schema
2. **Load complete schema** - When you need detailed information
3. **Keep minimal in cache** - Don't reload if already loaded

---

## Best Practices

1. ✅ **Start with minimal** - Load minimal schemas first
2. ✅ **Upgrade when needed** - Load complete schema only when you need detailed data
3. ✅ **Cache minimal** - Minimal schemas rarely change, safe to cache
4. ✅ **Use for lookups** - Perfect for existence checks and ID verification

---

*Last Updated: January 2025*

