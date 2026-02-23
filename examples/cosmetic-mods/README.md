# Cosmetic Mod Examples

**Version**: 1.0.0  
**Purpose**: Example cosmetic mods for AI agents and developers

---

## Overview

This directory contains example cosmetic mods that demonstrate the structure and capabilities of the cosmetic modding system. These examples follow the schema defined in `ai/schemas/cosmetic-mod.md`.

---

## Example Files

### 1. `simple-miner-mod.md`
**Description**: Minimal example mod that renames a miner struct type  
**Use Case**: Simple name/lore customization  
**Features**:
- Basic manifest
- Single struct type override
- English localization only

### 2. `guild-alpha-complete-mod.md`
**Description**: Complete example mod with multiple struct types, weapons, abilities, and localizations  
**Use Case**: Full-featured guild customization  
**Features**:
- Complete manifest with guild ID
- Multiple struct type overrides
- Weapon and ability customization
- Multi-language support (English, Spanish)
- Animation and icon references

### 3. `multi-language-mod.md`
**Description**: Example mod focusing on localization  
**Use Case**: Multi-language guild customization  
**Features**:
- Multiple language support
- Localization files structure
- Fallback mechanisms

---

## Usage

### For AI Agents

Load these examples to understand:
- Mod structure and format
- How to validate mods
- How to integrate mods with game system
- Localization patterns

### For Developers

Use these examples as:
- Templates for creating new mods
- Reference for mod structure
- Testing mod loading systems
- Understanding mod capabilities

---

## Related Documentation

- **Schema**: `../../schemas/cosmetic-mod.md` - Complete mod schema
- **Protocol**: `../../protocols/cosmetic-mod-protocol.md` - AI agent protocol
- **User Guide**: `../../../users/modding/cosmetic-mods.md` - Human-readable guide

---

*Last Updated: January 2025*

