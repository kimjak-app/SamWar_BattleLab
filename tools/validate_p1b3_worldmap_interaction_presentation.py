#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "WorldMap.tscn"
CITY = ROOT / "scripts/worldmap/ui/worldmap_city_action_controller.gd"
COMPASS_INSTALLER = ROOT / "scripts/worldmap/ui/worldmap_turn_compass_installer.gd"
HUD = ROOT / "scripts/worldmap/ui/worldmap_hud_presentation_controller.gd"
TOP_NAV = ROOT / "scripts/worldmap/ui/worldmap_top_nav.gd"
ACTION = ROOT / "scripts/worldmap/ui/worldmap_action_presentation_controller.gd"
MAIN = ROOT / "scripts/worldmap/worldmap_main.gd"

for path in (SCENE, CITY, COMPASS_INSTALLER, HUD, TOP_NAV, ACTION, MAIN):
    assert path.exists(), f"missing P-1B-3 path: {path.relative_to(ROOT)}"

scene = SCENE.read_text(encoding="utf-8")
city = CITY.read_text(encoding="utf-8")
installer = COMPASS_INSTALLER.read_text(encoding="utf-8")
hud = HUD.read_text(encoding="utf-8")
top_nav = TOP_NAV.read_text(encoding="utf-8")
action = ACTION.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")

# Production scene owns the interaction/presentation stack.
for required in (
    'path="res://WorldMapTopNav.tscn" id="22_top_nav"',
    'path="res://scenes/worldmap/ui/WorldMapActionPresentation.tscn" id="23_action_presentation"',
    '[node name="WorldMapCityActionController" type="Node" parent="."]',
    '[node name="WorldMapTurnCompassInstaller" type="Node" parent="."]',
    '[node name="TopNavCanvas" type="CanvasLayer" parent="."]',
    '[node name="TopNav" parent="TopNavCanvas" instance=ExtResource("22_top_nav")]',
    '[node name="WorldMapActionPresentation" parent="." instance=ExtResource("23_action_presentation")]',
    'production_world_map_path = NodePath("../..")',
    'production_world_map_path = NodePath("..")',
    'city_action_controller_path = NodePath("../WorldMapCityActionController")',
):
    assert required in scene, f"missing production interaction scene contract: {required}"

# Production city action controller must not depend on the QA wrapper.
assert 'get_node_or_null("../ProductionWorldMap")' not in city
assert 'action_video_test_requested' not in city
assert 'CityActionTest' not in city
assert '@onready var world_map: Node = get_parent()' in city
assert 'open_contextual_worldmap_action' in city
assert 'AttackButtonPlaceholder' in city

# Turn compass is installed against the production root and preserves the existing turn button contract.
assert 'TURN_COMPASS_SCRIPT' in installer
assert 'compass.call("bind_world_scene", world_map)' in installer
assert 'WorldMapUI' in installer

# TopNav remains self-contained and tech/system behavior is real.
assert '_open_techtree_if_available' in top_nav
assert '$AudioSettingsPopup.popup_centered()' in top_nav

# Action presentation remains connected to real production signals.
assert 'contextual_worldmap_action_presentation_requested' in action
assert 'contextual_worldmap_action_resolved' in action
assert 'complete_contextual_worldmap_action' in action

# Legacy standalone top UI/debug artifacts are hidden by production HUD ownership.
assert 'DomesticTechTreeButtonMVP' in hud
assert 'CameraDebugLabel' in hud
assert '_hide_late_legacy_top_ui' in hud

# P-1B-3 still does not switch the battle scene.
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in main
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"' not in main

print("P-1B-3 Production WorldMap interaction/presentation static validation: PASS")
