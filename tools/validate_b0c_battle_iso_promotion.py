#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PROD_DIR = ROOT / "scripts/battle/presentation/iso"

production = {
    "battle_iso_grid_projection.gd": "class_name BattleIsoGridProjection",
    "battle_iso_range_overlay_tile.gd": 'extends "res://scripts/battle_range_overlay_tile.gd"',
    "battle_iso_facing_arrow_tile_button.gd": 'extends "res://scripts/battle_facing_arrow_tile_button.gd"',
    "battle_iso_facing_indicator_label.gd": "extends Label",
}

for name, marker in production.items():
    path = PROD_DIR / name
    assert path.exists(), f"missing production ISO module: {path.relative_to(ROOT)}"
    text = path.read_text(encoding="utf-8")
    assert marker in text, f"missing production owner marker in {name}: {marker}"
    uid_path = path.with_suffix(path.suffix + ".uid")
    assert uid_path.exists(), f"missing tracked UID: {uid_path.relative_to(ROOT)}"
    assert uid_path.read_text(encoding="utf-8").strip().startswith("uid://")

for name in production:
    old_path = ROOT / "tests/scripts" / name
    text = old_path.read_text(encoding="utf-8")
    expected = f'extends "res://scripts/battle/presentation/iso/{name}"'
    assert expected in text, f"legacy wrapper does not delegate: {name}"
    assert "class_name " not in text, f"legacy wrapper duplicates class_name: {name}"

iso_test = (ROOT / "tests/scripts/battle_ui_production_imjin_iso_movement_test.gd").read_text(encoding="utf-8")
for name in production:
    assert f"res://scripts/battle/presentation/iso/{name}" in iso_test
assert "res://tests/scripts/battle_iso_" not in iso_test

worldmap = (ROOT / "scripts/worldmap/worldmap_main.gd").read_text(encoding="utf-8")
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in worldmap
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"' not in worldmap

print("B-0C production ISO promotion static validation: PASS")
