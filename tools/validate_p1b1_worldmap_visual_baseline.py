#!/usr/bin/env python3
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
SCENE = ROOT / "WorldMap.tscn"
BACKGROUND = ROOT / "scripts/worldmap/worldmap_background_refresh_tool.gd"
CITY_MARKER = ROOT / "scripts/worldmap_city_marker.gd"
ROUTE = ROOT / "scripts/worldmap_route_path.gd"
MAIN = ROOT / "scripts/worldmap/worldmap_main.gd"
DESIGN2 = ROOT / "assets/source/worldmap/worldmap_bg_v2_test.png"

for path in (SCENE, BACKGROUND, CITY_MARKER, ROUTE, MAIN, DESIGN2):
    assert path.exists(), f"missing required P-1B-1 path: {path.relative_to(ROOT)}"

scene = SCENE.read_text(encoding="utf-8")
background = BACKGROUND.read_text(encoding="utf-8")

# The canonical scene itself must persist Design-2. Runtime/editor tools may
# reassert the same state, but they must not be the only source of truth.
assert 'path="res://assets/source/worldmap/worldmap_bg_v2_test.png" id="2_worldmap_v2_master"' in scene
assert scene.count('[sub_resource type="AtlasTexture" id="AtlasTexture_worldmap_v2_') == 4
assert scene.count('texture = SubResource("AtlasTexture_worldmap_v2_') == 4
assert "assets/worldmap/tiles/worldmap_tile_" not in scene
assert "2_tile_a1" not in scene
assert "3_tile_a2" not in scene
assert "4_tile_b1" not in scene
assert "5_tile_b2" not in scene
assert "\\n" not in scene, "literal escaped newline leaked into WorldMap.tscn"
city_marker = CITY_MARKER.read_text(encoding="utf-8")
route = ROUTE.read_text(encoding="utf-8")
main = MAIN.read_text(encoding="utf-8")

EXPECTED = {
    "luoyang": (765.0, 586.5),
    "yecheng": (842.5, 499.0),
    "chengdu": (408.5, 730.5),
    "jianye": (955.0, 670.0),
    "karakorum": (1029.5, 272.5),
    "pyeongyang": (1178.0, 342.0),
    "hanseong": (1235.0, 424.5),
    "gyeongju": (1303.0, 488.5),
    "sabi": (1236.0, 523.5),
    "kyoto": (1543.5, 492.5),
    "osaka": (1513.5, 567.0),
    "kyushu": (1397.5, 628.5),
    "edo": (1602.5, 414.5),
}

for city_id, position in EXPECTED.items():
    pattern = re.compile(
        rf'\[node name="CityMarker_[^"]+"[^\]]*\]\n'
        rf'position = Vector2\({re.escape(str(position[0]).rstrip("0").rstrip("."))}(?:\.0)?, '
        rf'{re.escape(str(position[1]).rstrip("0").rstrip("."))}(?:\.0)?\)'
        rf'[\s\S]*?city_id = "{re.escape(city_id)}"'
    )
    assert pattern.search(scene), f"production scene city position mismatch: {city_id}"

name_text_blocks = re.findall(
    r'\[node name="NameText"[^\]]*parent="WorldMapRoot/CityLayer/CityMarker_[^"]+"[\s\S]*?(?=\n\[node |\Z)',
    scene,
)
assert len(name_text_blocks) == 13, f"expected 13 city name blocks, found {len(name_text_blocks)}"
for block in name_text_blocks:
    assert "position = Vector2(0, 16)" in block, "city label offset is not production 16px baseline"

for name, expected_position in (
    ("Tile_A1_TopLeft", "Vector2(0, 0)"),
    ("Tile_A2_TopRight", "Vector2(1024, 0)"),
    ("Tile_B1_BottomLeft", "Vector2(0, 576)"),
    ("Tile_B2_BottomRight", "Vector2(1024, 576)"),
):
    block_match = re.search(rf'\[node name="{name}"[^\]]*\][\s\S]*?(?=\n\[node |\Z)', scene)
    assert block_match, f"missing tile node: {name}"
    block = block_match.group(0)
    if expected_position == "Vector2(0, 0)":
        assert "position =" not in block or expected_position in block, f"unexpected top-left tile position: {name}"
    else:
        assert f"position = {expected_position}" in block, f"tile position mismatch: {name}"

camera = re.search(r'\[node name="WorldMapCamera"[^\]]*\][\s\S]*?(?=\n\[node |\Z)', scene)
assert camera, "missing WorldMapCamera"
camera_block = camera.group(0)
for required in (
    "position = Vector2(1024, 576)",
    "limit_left = 0",
    "limit_top = 0",
    "limit_right = 2048",
    "limit_bottom = 1152",
):
    assert required in camera_block, f"production camera baseline missing: {required}"

assert 'preload("res://assets/source/worldmap/worldmap_bg_v2_test.png")' in background
assert "const WORLD_SIZE := Vector2(2048.0, 1152.0)" in background
for required in (
    'Rect2(0, 0, 2048, 1152), Vector2(0, 0)',
    'Rect2(2048, 0, 2048, 1152), Vector2(1024, 0)',
    'Rect2(0, 1152, 2048, 1152), Vector2(0, 576)',
    'Rect2(2048, 1152, 2048, 1152), Vector2(1024, 576)',
):
    assert required in background, f"production Design-2 atlas geometry missing: {required}"

assert "camera.limit_right = int(WORLD_SIZE.x)" in background
assert "camera.limit_bottom = int(WORLD_SIZE.y)" in background

for city_id in EXPECTED:
    assert f'"{city_id}": Vector2(' in city_marker, f"seed baseline missing city: {city_id}"
assert "2048x1152 production coordinates" in city_marker

assert 'func _refresh_route_geometry()' in route
assert 'call_deferred("_refresh_route_geometry")' in route

# P-1B-1 must not prematurely switch battle runtime.
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"' in main
assert 'const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"' not in main

print("P-1B-1 WorldMap visual baseline static validation: PASS")
