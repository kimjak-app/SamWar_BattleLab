#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "WorldMap.tscn"
MAIN = ROOT / "scripts/worldmap/worldmap_main.gd"
SHARED = ROOT / "scripts/worldmap/ui/worldmap_shared_ui_controller.gd"
CITY_INFO_BASE = ROOT / "scripts/worldmap_city_info_panel_base.gd"

PROD_SCRIPTS = [
    ROOT / "scripts/worldmap/ui/worldmap_hud_presentation_controller.gd",
    ROOT / "scripts/worldmap/ui/worldmap_warehouse_tabs_controller.gd",
    ROOT / "scripts/worldmap/ui/worldmap_garrison_compact_controller.gd",
    ROOT / "scripts/worldmap/ui/worldmap_readability_controller.gd",
    ROOT / "scripts/worldmap/ui/worldmap_panel_refinement_controller.gd",
    ROOT / "scripts/worldmap/ui/worldmap_tech_badge_summary_controller.gd",
]

for path in [SCENE, MAIN, SHARED, CITY_INFO_BASE, *PROD_SCRIPTS]:
    assert path.exists(), f"missing P-1B-2 path: {path.relative_to(ROOT)}"

scene = SCENE.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")
shared = SHARED.read_text(encoding="utf-8")
city_info = CITY_INFO_BASE.read_text(encoding="utf-8")

for script_path in PROD_SCRIPTS:
    source = script_path.read_text(encoding="utf-8")
    assert "ProductionWorldMap" not in source, f"test-host path leaked into {script_path.name}"
    assert "_test_controller" not in source, f"test controller dependency leaked into {script_path.name}"

required_nodes = [
    "HudPositionOwner",
    "WorldMapWarehouseTabsController",
    "WorldMapGarrisonCompactController",
    "WorldMapReadabilityController",
    "WorldMapPanelRefinementController",
    "WorldMapTechBadgeSummaryController",
]
for node_name in required_nodes:
    assert f'[node name="{node_name}"' in scene, f"missing production HUD controller node: {node_name}"

for legacy_script in (
    "worldmap_hud_position_test_controller.gd",
    "worldmap_warehouse_tabs_test_controller.gd",
    "worldmap_garrison_compact_test_controller.gd",
    "worldmap_readability_test_controller.gd",
    "worldmap_panel_refinement_test_controller.gd",
    "worldmap_tech_badge_test_controller.gd",
    "worldmap_stable_hud_mirror_controller.gd",
    "worldmap_left_panel_lock_guard.gd",
    "worldmap_turn_transition_late_guard.gd",
):
    assert legacy_script not in scene, f"test/guard controller attached to production scene: {legacy_script}"

# Existing production UI routing must delegate position requests to HudPositionOwner.
assert 'get_node_or_null("HudPositionOwner")' in shared
assert 'request_hud_panel_global_position' in shared
assert 'request_hud_panel_position' in shared

hud = PROD_SCRIPTS[0].read_text(encoding="utf-8")
assert 'const LEFT_PANEL_WIDTH := 320.0' in hud
assert 'const RIGHT_PANEL_WIDTH := 308.0' in hud
assert 'const HUD_TOP_MARGIN_RATIO := 0.144' in hud
assert 'func request_hud_panel_position' in hud
assert '_get_default_position(panel, true)' in hud
assert '_get_default_position(panel, false)' in hud

# Current selected-city implementation creates GarrisonCard dynamically.
assert '_garrison_card.name = "GarrisonCard"' in city_info
assert '_garrison_list_container.name = "GarrisonList"' in city_info

warehouse = PROD_SCRIPTS[1].read_text(encoding="utf-8")
assert 'TAB_FUNDS_FOOD' in warehouse
assert 'TAB_SPECIALTIES' in warehouse
assert '"자금·식량"' in warehouse
assert '"특산물"' in warehouse

garrison = PROD_SCRIPTS[2].read_text(encoding="utf-8")
assert 'COMPACT_GARRISON_HEIGHT := 96.0' in garrison
assert '_compact_grid.columns = 3' in garrison

tech = PROD_SCRIPTS[5].read_text(encoding="utf-8")
assert '_get_completed_national_domestic_tech_snapshot_mvp' in tech
assert '_get_completed_city_domestic_tech_snapshot_mvp' in tech
assert 'LEFT_SAMPLE_BADGES' not in tech
assert 'RIGHT_SAMPLE_BADGES' not in tech

# P-1B-2 must not prematurely switch the battle entry.
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in main

print("P-1B-2 Production WorldMap HUD static validation: PASS")
