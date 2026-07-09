# Scripts Folder Structure Map

## 1. Baseline

- v0.71-03 baseline commit: `39dd2e666c059d553c95b33d33ec75140311ef12` (`v0.71-02 Test Name Cleanup`).
- Task-start local HEAD: `39dd2e666c059d553c95b33d33ec75140311ef12`.
- Task-start working tree status: tracked files clean.

## 2. Purpose

- v0.71-03 creates the destination skeleton for future helper extraction.
- This is not helper extraction.
- Existing runtime script paths are preserved.
- `scripts/worldmap_test.gd` remains in place and active.
- Existing `.tscn` script references are unchanged.

## 3. Created Folder Structure

| Folder | Future Domain | First Safe Extraction Type | Do Not Move Yet |
| ------ | ------------- | -------------------------- | --------------- |
| `scripts/worldmap/domestic_tech/` | Domestic Tech | Completed lookup, safe-set lookup, summary formatter | Research lifecycle, active payload, actual charge, presentation queue mutation |
| `scripts/worldmap/economy_city/` | Economy / City | Resource display formatter, income summary helper, read-only modifier helper | Turn income mutation, city state schema, resource mutation |
| `scripts/worldmap/defense_battle/` | Defense / Battle | Defense summary, battle modifier lookup, command-limit labels | BattleContext creation, battle formula, pending invasion payload |
| `scripts/worldmap/diplomacy_spy/` | Diplomacy / Spy | Diplomacy/spy labels, visibility summaries, guarded chance wrappers | Relation mutation, spy payload mutation, diplomacy/spy formulas |
| `scripts/worldmap/naval_siege/` | Naval / Siege | Ship/siege unlock lookup and summaries | Persistent ship/siege storage, production system |
| `scripts/worldmap/ui_formatter/` | UI Formatter / Summary | Pure text formatter, bullet builder, tooltip/summary builder | UI node mutation, scene path changes, layout behavior |
| `scripts/worldmap/save_load/` | Save / Load | Later schema-protected normalization helpers only | Save/load functions, schema changes, migration/default behavior |
| `scripts/worldmap/selection_panel/` | Selection Panel / World UI | Selected-city display formatter, panel summary helper | Selection state mutation, panel signal callbacks, drag state |
| `scripts/worldmap/debug_qa/` | Debug / QA / Dev Tools | QA summary helper, debug-only read helper | Runtime gameplay-path mutation |
| `scripts/worldmap/orchestration/` | Scene / Runtime Orchestration | Late-stage orchestration wrappers only | `_ready`, turn advance, signal wiring, input flow |
| `scripts/worldmap/enemy_baseline/` | Enemy Baseline / AI-lite | Enemy baseline/resistance/capability read-only helper | Enemy research, enemy completed tech storage, PLAYER tech leakage |
| `scripts/worldmap/shared/` | Shared | Constants-like lookup, pure utility, tiny safe helper | Catch-all ownership, schema-sensitive functions |

## 4. Current Runtime Scripts Preserved

Existing runtime `.gd` files remain in their original locations, including:

- `scripts/battle_facing_arrow_tile_button.gd`
- `scripts/battle_grid_controller.gd`
- `scripts/battle_range_overlay_tile.gd`
- `scripts/battle_singijeon_test.gd`
- `scripts/battle_unit_state.gd`
- `scripts/battle_web_import_test.gd`
- `scripts/player_attack_deployment_panel.gd`
- `scripts/unit_visual_slot.gd`
- `scripts/video_theora_test.gd`
- `scripts/worldmap_city_info_panel.gd`
- `scripts/worldmap_city_marker.gd`
- `scripts/worldmap_city_name_label.gd`
- `scripts/worldmap_hero_portrait_helper.gd`
- `scripts/worldmap_route_flow_fx.gd`
- `scripts/worldmap_route_path.gd`
- `scripts/worldmap_test.gd`

`scripts/worldmap_test.gd` remains in place.

No existing `.gd` file was moved.

No existing `.tscn` script reference was changed.

## 5. Extraction Boundary

- v0.71-03 performs no `.gd` move.
- Actual helper extraction should begin no earlier than `v0.71-05 Domestic Tech Helper Extraction`.
- `v0.71-04 WorldMap God File Function Group Map` should refine function-to-folder mapping before extraction.
- Scene rename is a separate future task and is not part of this folder skeleton step.

## 6. Verification Notes

- Project headless load must pass.
- `WorldMap_Test.tscn` headless load must pass.
- `Battle_Fullscreen_Test.tscn` headless load must pass.
- README-only folder skeletons must not affect runtime behavior.

## v0.71-05 Domestic Tech Helper Status

- `scripts/worldmap/domestic_tech/` now contains `domestic_tech_helpers.gd`.
- The first extracted helper batch is limited to pure duration, percent/source normalization, and icon path lookup helpers.
- No existing runtime `.gd` file was moved, and no `.tscn` script reference was changed.

## v0.71-06 Economy / City Helper Status

- `scripts/worldmap/economy_city/` now contains `economy_city_helpers.gd`.
- The first extracted helper batch is limited to pure resource/trade/supply/storage formatter and lookup helpers.
- City state mutation, turn income mutation, storage/resource mutation, save/load, and scene-node-heavy UI remain outside the helper file.
