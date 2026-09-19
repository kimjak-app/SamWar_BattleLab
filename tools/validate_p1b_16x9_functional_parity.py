#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def read(path: str) -> str:
    p = ROOT / path
    assert p.exists(), f"missing parity path: {path}"
    return p.read_text(encoding="utf-8")

scene = read("WorldMap.tscn")
main = read("scripts/worldmap/worldmap_main.gd")
hud_presentation = read("scripts/worldmap/ui/worldmap_hud_presentation_controller.gd")
hud_source = read("scripts/worldmap/hud/worldmap_hud_controller.gd")
city_source = read("scripts/worldmap_city_info_panel_base.gd")
warehouse = read("scripts/worldmap/ui/worldmap_warehouse_tabs_controller.gd")
garrison = read("scripts/worldmap/ui/worldmap_garrison_compact_controller.gd")
readability = read("scripts/worldmap/ui/worldmap_readability_controller.gd")
refinement = read("scripts/worldmap/ui/worldmap_panel_refinement_controller.gd")
tech = read("scripts/worldmap/ui/worldmap_tech_badge_summary_controller.gd")
territory = read("scripts/worldmap/ui/worldmap_territory_controller.gd")
city_action = read("scripts/worldmap/ui/worldmap_city_action_controller.gd")
turn_summary = read("scripts/worldmap/ui/worldmap_turn_summary_controller.gd")
speech = read("scripts/worldmap/ui/worldmap_character_speech_controller.gd")
compass_installer = read("scripts/worldmap/ui/worldmap_turn_compass_installer.gd")
background = read("scripts/worldmap/worldmap_background_refresh_tool.gd")
city_marker = read("scripts/worldmap_city_marker.gd")
top_nav = read("scripts/worldmap/ui/worldmap_top_nav.gd")
action_presentation = read("scripts/worldmap/ui/worldmap_action_presentation_controller.gd")

# 1. 16:9 Design-2 world baseline.
assert 'worldmap_bg_v2_test.png' in scene
assert 'worldmap_bg_v2_test.png' in background
assert 'const WORLD_SIZE := Vector2(2048.0, 1152.0)' in background
assert '2048x1152 production coordinates' in city_marker
assert 'position = Vector2(1024, 576)' in scene

# 2. Approved compact HUD dimensions/placement.
assert 'const LEFT_PANEL_WIDTH := 320.0' in hud_presentation
assert 'const RIGHT_PANEL_WIDTH := 308.0' in hud_presentation
assert 'const HUD_SIDE_MARGIN_RATIO := 0.025' in hud_presentation
assert 'const HUD_TOP_MARGIN_RATIO := 0.144' in hud_presentation
assert '[node name="HudPositionOwner" type="Node" parent="."]' in scene

# 3. Legacy presentation cannot republish itself on later refreshes.
assert 'func set_compact_presentation_enabled' in hud_source
assert 'func _apply_compact_visibility()' in hud_source
assert 'func set_compact_presentation_enabled' in city_source
assert 'func _apply_compact_presentation_visibility()' in city_source
assert 'hud_controller.call("set_compact_presentation_enabled", true)' in hud_presentation
assert '_right_panel.call("set_compact_presentation_enabled", true)' in hud_presentation

# Hidden calendar remains a live data token for compass/turn summary.
assert '_set_label("calendar", str(model.get("calendar", "")), not _compact_presentation_enabled)' in hud_source
assert '_set_label("calendar", "", false)' not in hud_source

# 4. Warehouse tabs.
assert 'TAB_FUNDS_FOOD := "funds_food"' in warehouse
assert 'TAB_SPECIALTIES := "specialties"' in warehouse
assert '"자금·식량"' in warehouse
assert '"특산물"' in warehouse

# 5. Compact three-column garrison.
assert 'const COMPACT_GARRISON_HEIGHT := 96.0' in garrison
assert '_compact_grid.columns = 3' in garrison
assert '"도시 소속 무장"' in garrison

# 6. Readability / role summaries / portrait sizes.
assert 'const FONT_DELTA := 3' in readability
assert 'const CHANCELLOR_PORTRAIT_SIZE := Vector2(78.0, 88.0)' in readability
assert 'const GOVERNOR_PORTRAIT_SIZE := Vector2(64.0, 72.0)' in readability
assert 'AdminRoleResolver.format_summary' in readability

# 7. Stability/tax colors and contextual help.
assert 'const STABLE_THRESHOLD := 80' in refinement
assert 'const CAUTION_THRESHOLD := 60' in refinement
assert 'const TAX_GREEN_MAX := 30.0' in refinement
assert 'const TAX_YELLOW_MAX := 60.0' in refinement
assert 'WorldMapHoverTooltip.tscn' in refinement

# 8. Real tech badges only. Test samples are intentionally NOT parity.
assert '_get_completed_national_domestic_tech_snapshot_mvp' in tech
assert '_get_completed_city_domestic_tech_snapshot_mvp' in tech
assert '_get_domestic_tech_definition_mvp' in tech
assert '_get_domestic_tech_resolved_icon_path_mvp' in tech
assert 'var icon := load(icon_path) as Texture2D' in tech
assert 'LEFT_SAMPLE_BADGES' not in tech
assert 'RIGHT_SAMPLE_BADGES' not in tech
assert 'sample' not in tech.lower()
assert 'func refresh_from_runtime()' in tech
assert '_refresh_worldmap_tech_badge_summary_if_present()' in main

# 9. Top navigation.
assert 'WorldMapTopNav.tscn' in scene
assert '_open_techtree_if_available' in top_nav
assert '$AudioSettingsPopup.popup_centered()' in top_nav

# 10. Turn-end compass.
assert 'worldmap_turn_compass.gd' in compass_installer
assert 'bind_world_scene' in compass_installer
assert 'TurnEndCompass' in compass_installer

# 11. Contextual city action menu.
assert 'class_name WorldMapCityActionController' in city_action
for action in ('"spy"', '"diplomacy"', '"trade"'):
    assert action in city_action
assert 'open_contextual_worldmap_action' in city_action
assert 'AttackButtonPlaceholder' in city_action
assert 'action_video_test_requested' not in city_action

# 12. Action video/result presentation.
assert 'WorldMapActionPresentation.tscn' in scene
assert 'contextual_worldmap_action_presentation_requested' in action_presentation
assert 'contextual_worldmap_action_resolved' in action_presentation
assert 'complete_contextual_worldmap_action' in action_presentation

# 13. Territory overlay.
assert 'class_name WorldMapTerritoryController' in territory
assert 'worldmap_land_sea_mask_v1_0_4096x2304.png' in territory
assert 'territory_shader.gdshader' in territory
assert '[node name="WorldMapTerritoryController" type="Node" parent="."]' in scene
assert '_refresh_territory_overlay_if_present()' in main

# 14. Turn summary popup: now bound to real compass rather than hidden QA button-down trigger.
assert 'WorldMapTurnSummaryPopup.tscn' in turn_summary
assert 'get_node_or_null("WorldMapUI/TurnEndCompass")' in turn_summary
assert 'compass.connect("turn_end_requested", callback)' in turn_summary
assert '_show_current_turn_summary()' in turn_summary
assert '_hide_post_turn_log_nodes()' in turn_summary

# 15. Character speech on chancellor/governor assignment and policy.
assert 'WorldMapCharacterSpeechPopup.tscn' in speech
for hook in (
    'chancellor_assign.item_selected.connect',
    'governor_assign.item_selected.connect',
    'chancellor_policy.item_selected.connect',
    'governor_policy.item_selected.connect',
):
    assert hook in speech
assert '_show_character' in speech
assert '_build_policy_speech' in speech

# 16. Editor-preview controller is not needed in production because the canonical
# scene itself now stores the approved background/cities/routes. No QA wrapper is
# permitted as a player-facing dependency.
for qa_only in (
    'worldmap_16x9_test_host.gd',
    'worldmap_16x9_editor_preview.gd',
    'worldmap_left_panel_lock_guard.gd',
    'worldmap_stable_hud_mirror_controller.gd',
    'worldmap_turn_transition_late_guard.gd',
    'worldmap_v2_background_test_controller.gd',
    'worldmap_territory_test_controller.gd',
    'worldmap_tech_badge_test_controller.gd',
):
    assert qa_only not in scene, f"QA-only dependency leaked into production: {qa_only}"

# P-1B parity work still intentionally leaves battle routing untouched.
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in main

print("P-1B 16:9 functional parity validation: PASS (real-tech exception enforced)")
