# Simple Miner Mod

**Schema**: `schemas/cosmetic-mod.md`

---

A minimal cosmetic mod example that renames a single struct type. This is the simplest possible mod, demonstrating the bare minimum manifest and struct type override.

## Manifest

```json
{
  "modId": "simple-miner-mod-v1",
  "name": {
    "en": "Simple Miner Mod"
  },
  "version": "1.0.0",
  "author": "Example Modder",
  "description": {
    "en": "A simple example mod that renames the miner struct type"
  },
  "compatibleGameVersion": "1.0.0",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

## Struct Types

### Miner

- **Struct Type ID**: `miner`
- **Custom Name (en)**: Deep Core Extractor
- **Lore (en)**: A specialized mining unit designed to extract valuable resources from planetary cores. The Deep Core Extractor represents the pinnacle of mining technology, capable of operating in the most extreme conditions.

```json
{
  "structTypeId": "miner",
  "names": {
    "en": "Deep Core Extractor"
  },
  "lore": {
    "en": "A specialized mining unit designed to extract valuable resources from planetary cores. The Deep Core Extractor represents the pinnacle of mining technology, capable of operating in the most extreme conditions."
  }
}
```

---

## Related Documentation

- [Cosmetic Mod Schema](../../schemas/cosmetic-mod.md)
- [Multi-Language Mod Example](multi-language-mod.md)
- [Guild Alpha Complete Mod Example](guild-alpha-complete-mod.md)
