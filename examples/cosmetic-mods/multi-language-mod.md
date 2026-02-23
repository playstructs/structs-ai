# Multi-Language Example Mod

**Schema**: `schemas/cosmetic-mod.md`

---

An example mod demonstrating multi-language support with fallback mechanisms. This mod provides localized names, lore, and UI strings in English, Spanish, French, and German.

## Manifest

```json
{
  "modId": "multi-language-example-v1",
  "name": {
    "en": "Multi-Language Example Mod",
    "es": "Mod de Ejemplo Multiidioma",
    "fr": "Mod d'Exemple Multilingue",
    "de": "Mehrsprachiges Beispiel-Mod"
  },
  "version": "1.0.0",
  "author": "International Modder",
  "description": {
    "en": "An example mod demonstrating multi-language support with fallback mechanisms",
    "es": "Un mod de ejemplo que demuestra soporte multiidioma con mecanismos de respaldo",
    "fr": "Un mod d'exemple démontrant le support multilingue avec des mécanismes de repli",
    "de": "Ein Beispiel-Mod, das mehrsprachige Unterstützung mit Fallback-Mechanismen demonstriert"
  },
  "compatibleGameVersion": "1.0.0",
  "createdAt": "2025-01-15T10:00:00Z",
  "updatedAt": "2025-01-15T10:00:00Z"
}
```

## Struct Types

### Miner -- Universal Extractor

- **Struct Type ID**: `miner`

| Language | Name | Lore |
|---|---|---|
| en | Universal Extractor | A versatile mining unit designed for international operations. The Universal Extractor adapts to local conditions and naming conventions while maintaining consistent performance. |
| es | Extractor Universal | Una unidad de mineria versatil disenada para operaciones internacionales. El Extractor Universal se adapta a las condiciones locales y convenciones de nomenclatura mientras mantiene un rendimiento consistente. |
| fr | Extracteur Universel | Une unite d'extraction polyvalente concue pour les operations internationales. L'Extracteur Universel s'adapte aux conditions locales et aux conventions de denomination tout en maintenant des performances constantes. |
| de | Universeller Extraktor | Eine vielseitige Bergbaueinheit fur internationale Operationen. Der Universelle Extraktor passt sich lokalen Bedingungen und Namenskonventionen an, wahrend er eine konsistente Leistung beibehalt. |

#### Primary Weapon: Adaptive Drill

| Language | Name | Description |
|---|---|---|
| en | Adaptive Drill | An intelligent drilling system that adapts to different geological formations |
| es | Taladro Adaptativo | Un sistema de perforacion inteligente que se adapta a diferentes formaciones geologicas |
| fr | Foreuse Adaptative | Un systeme de forage intelligent qui s'adapte a differentes formations geologiques |
| de | Adaptiver Bohrer | Ein intelligentes Bohrungssystem, das sich an verschiedene geologische Formationen anpasst |

### Reactor -- Global Power Unit

- **Struct Type ID**: `reactor`

| Language | Name | Lore |
|---|---|---|
| en | Global Power Unit | A standardized power generation system used across all international operations. The Global Power Unit ensures consistent energy supply regardless of location. |
| es | Unidad de Energia Global | Un sistema estandarizado de generacion de energia utilizado en todas las operaciones internacionales. La Unidad de Energia Global garantiza un suministro de energia consistente independientemente de la ubicacion. |
| fr | Unite d'Energie Globale | Un systeme de production d'energie standardise utilise dans toutes les operations internationales. L'Unite d'Energie Globale assure un approvisionnement energetique constant, quel que soit l'emplacement. |
| de | Globale Energieeinheit | Ein standardisiertes Energieerzeugungssystem, das in allen internationalen Operationen verwendet wird. Die Globale Energieeinheit gewahrleistet eine konsistente Energieversorgung unabhangig vom Standort. |

## Localizations

Localization strings for UI elements across all supported languages.

```json
{
  "en": {
    "mod_title": "Multi-Language Example Mod",
    "fallback_message": "Using English as fallback language",
    "struct_miner": "Miner",
    "struct_reactor": "Reactor"
  },
  "es": {
    "mod_title": "Mod de Ejemplo Multiidioma",
    "fallback_message": "Usando español como idioma de respaldo",
    "struct_miner": "Minero",
    "struct_reactor": "Reactor"
  },
  "fr": {
    "mod_title": "Mod d'Exemple Multilingue",
    "fallback_message": "Utilisation du français comme langue de repli",
    "struct_miner": "Mineur",
    "struct_reactor": "Réacteur"
  },
  "de": {
    "mod_title": "Mehrsprachiges Beispiel-Mod",
    "fallback_message": "Verwenden von Deutsch als Fallback-Sprache",
    "struct_miner": "Bergmann",
    "struct_reactor": "Reaktor"
  }
}
```

---

## Related Documentation

- [Cosmetic Mod Schema](../../schemas/cosmetic-mod.md)
- [Simple Miner Mod Example](simple-miner-mod.md)
- [Guild Alpha Complete Mod Example](guild-alpha-complete-mod.md)
