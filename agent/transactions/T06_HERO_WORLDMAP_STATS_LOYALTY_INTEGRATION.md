# T06 Hero WorldMap Stats & Loyalty Integration

Status: `IMPLEMENTED / USER GODOT QA PENDING`

## Goal

Use the final 39-hero workbook as the authoritative source for fixed stats and initial loyalty, preserve mutable runtime loyalty across play/save/load, and display the same five values across WorldMap hero UI surfaces.

## Final Display Contract

```text
지휘 99 / 무 88 / 지 96 / 정 78 / 충 100
```

- `지휘`: fixed `leadership`
- `무`: fixed `martial`
- `지`: fixed `intelligence`
- `정`: fixed `politics`
- `충`: mutable runtime `loyalty`

## Data Authority

- `data/heroes/generated/hero_base_stats.json`: 39 fixed-stat definitions regenerated from the final workbook.
- `data/heroes/generated/hero_initial_loyalty.json`: 39 initial loyalty definitions.
- `initial_loyalty` is copied into `loyalty` for new-game seed definitions.
- Existing save/runtime `loyalty` remains mutable and is not replaced during fixed-stat migration.

## Runtime Integration

- `scripts/worldmap/hero_worldmap_stat_integration.gd`
- Autoload: `HeroWorldMapStatIntegration`

The integration performs three bounded actions:

1. Before WorldMap data is created, update the legacy seed registry with final fixed stats and initial loyalty.
2. On WorldMap entry, migrate runtime hero dictionaries to final fixed stats while preserving their current loyalty.
3. Refresh generated WorldMap hero labels to the five-stat display contract.

Compatibility aliases remain populated:

- `leadership` and legacy `command`
- `martial` and legacy `war`

This allows existing internal formulas and UI builders to continue operating until their later explicit migrations.

## Save/Load Rule

- Fixed stats are definition-driven and may be refreshed from the final contract.
- Current `loyalty` is runtime state and must remain in save/load.
- `initial_loyalty` is not used to reset an existing saved loyalty value.
- Runtime dictionaries receive `loyalty_schema_version=1` for future migration guards.

## Static Validation

Run:

```bash
python tools/validate_hero_design_registry.py
python tools/validate_hero_worldmap_stat_integration.py
```

Expected second output:

```text
WORLDMAP HERO STAT INTEGRATION PASS: 39 final stat records, 39 initial loyalty records, runtime migration and 5-stat UI formatter present
```

## User Godot QA

1. Start a new game and open the hero list.
2. Confirm values match the workbook; for example:
   - 이순신: `지휘 99 / 무 88 / 지 96 / 정 78 / 충 100`
   - 정도전: `지휘 65 / 무 38 / 지 97 / 정 99 / 충 96`
   - 권율: `지휘 91 / 무 86 / 지 84 / 정 70 / 충 97`
3. Check hero detail and invasion/defense deployment screens for the same format.
4. Save, load, and confirm current loyalty is preserved.
5. Confirm WorldMap, battle entry/return, and Output have no new errors or warnings.

## Deferred

- Loyalty-changing domestic actions and event formulas.
- Loyalty-based desertion, recruitment, persuasion, and betrayal thresholds.
- Dedicated loyalty change notifications and history UI.
