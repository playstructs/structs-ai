# Guild Alpha Complete Pack

**Schema**: `schemas/cosmetic-mod.md`

---

A comprehensive cosmetic customization pack for Guild Alpha, featuring custom names, lore, weapons, abilities, animations, and icons for multiple struct types. This example demonstrates the full range of cosmetic mod capabilities.

## Manifest

```json
{
  "modId": "guild-alpha-complete-v1",
  "name": {
    "en": "Guild Alpha Complete Pack",
    "es": "Paquete Completo de Guild Alpha"
  },
  "version": "1.0.0",
  "author": "Guild Alpha",
  "guildId": "0-1",
  "description": {
    "en": "Complete cosmetic customization pack for Guild Alpha, featuring custom names, lore, weapons, and abilities for multiple struct types",
    "es": "Paquete completo de personalización cosmética para Guild Alpha, con nombres personalizados, lore, armas y habilidades para múltiples tipos de estructuras"
  },
  "compatibleGameVersion": "1.0.0",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

## Struct Types

### Miner -- Alpha Ore Harvester

- **Struct Type ID**: `miner`
- **Icon**: `miner-alpha-icon.png`

| Language | Name | Lore |
|---|---|---|
| en | Alpha Ore Harvester | Guild Alpha's signature mining unit. The Ore Harvester has been refined over generations of mining operations, representing the guild's commitment to resource extraction excellence. |
| es | Cosechador de Minerales Alpha | Unidad de mineria distintiva de Guild Alpha. El Cosechador de Minerales ha sido refinado a lo largo de generaciones de operaciones mineras, representando el compromiso del gremio con la excelencia en la extraccion de recursos. |

#### Weapons

**Primary: Plasma Drill**

| Language | Name | Description |
|---|---|---|
| en | Plasma Drill | A high-energy plasma drill capable of cutting through the toughest planetary crust |
| es | Taladro de Plasma | Un taladro de plasma de alta energia capaz de cortar a traves de la corteza planetaria mas dura |

- **Animation**: `miner-plasma-drill.json`
- **Icon**: `plasma-drill-icon.png`

#### Abilities

**Deep Scan**

| Language | Name | Description |
|---|---|---|
| en | Deep Scan | Scans deep beneath the surface to locate high-value ore deposits |
| es | Escaneo Profundo | Escanea profundamente bajo la superficie para localizar depositos de minerales de alto valor |

- **Animation**: `miner-deep-scan.json`
- **Icon**: `deep-scan-icon.png`

#### Animations

| State | File |
|---|---|
| Idle | `miner-idle-alpha.json` |
| Active | `miner-mining-alpha.json` |
| Building | `miner-building-alpha.json` |

---

### Reactor -- Alpha Power Core

- **Struct Type ID**: `reactor`
- **Icon**: `reactor-alpha-icon.png`

| Language | Name | Lore |
|---|---|---|
| en | Alpha Power Core | Guild Alpha's advanced power generation system. The Power Core represents decades of energy research and innovation, providing reliable power for all guild operations. |
| es | Nucleo de Energia Alpha | Sistema avanzado de generacion de energia de Guild Alpha. El Nucleo de Energia representa decadas de investigacion e innovacion energetica, proporcionando energia confiable para todas las operaciones del gremio. |

#### Animations

| State | File |
|---|---|
| Idle | `reactor-idle-alpha.json` |
| Active | `reactor-active-alpha.json` |

---

## Localizations

```json
{
  "en": {
    "guild_name": "Guild Alpha",
    "guild_motto": "Excellence Through Innovation",
    "miner_description_short": "Advanced mining unit",
    "reactor_description_short": "High-efficiency power generator"
  },
  "es": {
    "guild_name": "Guild Alpha",
    "guild_motto": "Excelencia a través de la Innovación",
    "miner_description_short": "Unidad de minería avanzada",
    "reactor_description_short": "Generador de energía de alta eficiencia"
  }
}
```

---

## Related Documentation

- [Cosmetic Mod Schema](../../schemas/cosmetic-mod.md)
- [Simple Miner Mod Example](simple-miner-mod.md)
- [Multi-Language Mod Example](multi-language-mod.md)
