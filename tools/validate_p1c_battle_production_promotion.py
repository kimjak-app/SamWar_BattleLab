#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

def read(path: str) -> str:
    p = ROOT / path
    assert p.exists(), f"missing P-1C path: {path}"
    return p.read_text(encoding="utf-8")

battle_main = read("scenes/battle/Battle_Main.tscn")
battle_prod = read("scenes/battle/Battle_Production.tscn")
prod_ctl = read("scripts/battle/battle_production_controller.gd")
iso_ctl = read("scripts/battle/presentation/iso/battle_iso_production_controller.gd")
bottom = read("scripts/battle/presentation/production/battle_current_actor_hud_controller.gd")
battle_core = read("scripts/battle_web_import_test.gd")
worldmap = read("scripts/worldmap/worldmap_main.gd")

assert 'res://scenes/battle/Battle_Production.tscn' in battle_main
assert 'Battle_Land.tscn' not in battle_main
assert 'type="Script"' not in battle_main

assert 'uid="uid://p1cbattleprod260919"' in battle_prod
assert 'res://scripts/battle/presentation/iso/battle_iso_production_controller.gd' in battle_prod
assert 'BattleUI/ProductionHudRoot' in battle_prod
assert '[node name="BattleSupplyHud"' in battle_prod
assert 'battle_supply_hud_mock.gd' not in battle_prod
assert 'res://tests/' not in battle_prod
assert 'battle_auto_turn_camera_guard.gd' in battle_prod
assert 'battle_status_empty_legend_controller.gd' in battle_prod

assert 'class_name BattleProductionController' in prod_ctl
assert 'extends "res://scripts/battle/battle_controller.gd"' in prod_ctl
assert 'PHASE_POST_SKILL_REPOSITION_SELECT' in prod_ctl
assert '_begin_post_skill_reposition' in prod_ctl
for forbidden in (
    'IMJIN_TEST_BATTLE_ROSTER',
    'KOREA_DEMO_HERO_IDS',
    'JAPAN_DEMO_HERO_IDS',
    'toyotomi_hideyoshi',
):
    assert forbidden not in prod_ctl

assert 'class_name BattleIsoProductionController' in iso_ctl
assert 'extends "res://scripts/battle/battle_production_controller.gd"' in iso_ctl
assert 'battle_iso_grid_projection.gd' in iso_ctl
assert '_install_iso_grid_projection' in iso_ctl
assert 'res://tests/' not in iso_ctl

assert 'res://scenes/battle/ui/CurrentActorInfoHud.tscn' in bottom
assert 'res://tests/' not in bottom
for sample in ('식량 820', '식량 740', '3 / 30 · 잔여 27', 'SHOW_WARNING_SAMPLE'):
    assert sample not in bottom
assert 'controller.get("worldmap_battle_context")' in bottom

assert 'var production_battle_supply_hud: Control = null' in battle_core
assert 'BattleUI/ProductionHudRoot/BattleSupplyHud' in battle_core
assert 'func _refresh_production_battle_supply_hud' in battle_core
assert 'func _refresh_production_battle_supply_side' in battle_core
assert 'battle_supply_panel.visible = false' in battle_core

# P-1C prepares Battle_Main only. P-1D performs the actual WorldMap switch.
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"' not in worldmap

print("P-1C Battle production promotion static validation: PASS")
