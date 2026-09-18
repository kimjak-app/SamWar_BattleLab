# B-0C | Production ISO Promotion — Batch 1

Date: 2026-09-18
Branch: `refactor/engine-core-20260918`

## Scope

Promote only the four generic ISO presentation modules identified by B-0A from `tests/scripts/` into production ownership:

- `scripts/battle/presentation/iso/battle_iso_grid_projection.gd`
- `scripts/battle/presentation/iso/battle_iso_range_overlay_tile.gd`
- `scripts/battle/presentation/iso/battle_iso_facing_arrow_tile_button.gd`
- `scripts/battle/presentation/iso/battle_iso_facing_indicator_label.gd`

The old `tests/scripts/battle_iso_*.gd` paths remain as compatibility wrappers. The active Imjin ISO scenario consumes the production modules directly.

## Not promoted

These remain scenario/test presentation policy:

- enemy tactical-overlay suppression
- legacy READY-frame suppression
- active-ally pulse suppression
- idle-breathing suppression
- Imjin-specific primary-ally cache handling
- Imjin scenario/roster logic
- Test2 camera guard and empty-state legend

## Behavior lock

No logical-grid, Manhattan range/path, facing, movement, attack, skill, AI, turn, WorldMap entry, BattleContext, or BattleResult rule changes are authorized.

WorldMap remains on `res://Battle_Land.tscn` until parity gates are green.
