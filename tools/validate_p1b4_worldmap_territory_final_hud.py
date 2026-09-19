#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "WorldMap.tscn"
TERRITORY = ROOT / "scripts/worldmap/ui/worldmap_territory_controller.gd"
MAIN = ROOT / "scripts/worldmap/worldmap_main.gd"
HUD = ROOT / "scripts/worldmap/hud/worldmap_hud_controller.gd"
CITY = ROOT / "scripts/worldmap_city_info_panel_base.gd"
PRESENTATION = ROOT / "scripts/worldmap/ui/worldmap_hud_presentation_controller.gd"

for path in (SCENE, TERRITORY, MAIN, HUD, CITY, PRESENTATION):
    assert path.exists(), f"missing P-1B-4 path: {path.relative_to(ROOT)}"

scene = SCENE.read_text(encoding="utf-8")
territory = TERRITORY.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")
hud = HUD.read_text(encoding="utf-8")
city = CITY.read_text(encoding="utf-8")
presentation = PRESENTATION.read_text(encoding="utf-8")

# Territory overlay is production-owned.
assert 'class_name WorldMapTerritoryController' in territory
assert 'worldmap_land_sea_mask_v1_0_4096x2304.png' in territory
assert 'territory_shader.gdshader' in territory
assert 'world_root.move_child(_territory_layer, route_layer.get_index())' in territory
assert 'ProductionWorldMap' not in territory
assert 'Territory Test' not in territory
assert 'path="res://scripts/worldmap/ui/worldmap_territory_controller.gd" id="24_territory"' in scene
assert '[node name="WorldMapTerritoryController" type="Node" parent="."]' in scene

# Ownership/load paths refresh the production overlay.
assert 'func _refresh_territory_overlay_if_present()' in main
assert 'get_node_or_null("WorldMapTerritoryController")' in main
owner_body = main.split('func _set_city_runtime_owner', 1)[1].split('\n\nfunc ', 1)[0]
load_body = main.split('func _refresh_city_marker_owner_states_from_runtime', 1)[1].split('\n\nfunc ', 1)[0]
assert '_refresh_territory_overlay_if_present()' in owner_body
assert '_refresh_territory_overlay_if_present()' in load_body

# Left HUD refresh source honors compact mode instead of requiring visibility guards.
assert 'var _compact_presentation_enabled := false' in hud
assert 'func set_compact_presentation_enabled' in hud
assert '_set_label("calendar", "", false)' in hud
assert '_set_label("nation", "", false)' in hud
assert '_set_label("save_management_title", "저장 관리", not _compact_presentation_enabled)' in hud
assert 'func _apply_compact_visibility()' in hud

# Right city panel also owns compact visibility across all refresh paths.
assert 'var _compact_presentation_enabled := false' in city
assert 'func set_compact_presentation_enabled' in city
for legacy_name in (
    'MilitaryInfoLabel',
    'MilitaryStateLabel',
    'HintLabel',
    'ButtonRow',
    'RecruitButtonPlaceholder',
):
    assert f'"{legacy_name}"' in city

for function_name in (
    'show_city',
    '_show_enemy_city_with_intel_filter',
    '_show_empty',
    'set_hud_data',
    'set_enemy_city_intel',
    'set_recruitment_summaries',
):
    body = city.split(f'func {function_name}', 1)[1].split('\n\nfunc ', 1)[0]
    assert '_apply_compact_presentation_visibility()' in body, f"compact visibility missing from {function_name}"

# Production HUD owner enables both authoritative compact modes.
assert 'hud_controller.call("set_compact_presentation_enabled", true)' in presentation
assert '_right_panel.call("set_compact_presentation_enabled", true)' in presentation

# Old QA guards remain out of the production scene.
for forbidden in (
    'worldmap_left_panel_lock_guard.gd',
    'worldmap_stable_hud_mirror_controller.gd',
    'worldmap_turn_transition_late_guard.gd',
    'worldmap_territory_test_controller.gd',
):
    assert forbidden not in scene, f"QA-only controller leaked into WorldMap.tscn: {forbidden}"

# Battle routing remains intentionally unchanged until P-1D.
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in main

print("P-1B-4 territory/final HUD production validation: PASS")
