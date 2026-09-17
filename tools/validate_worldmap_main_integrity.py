#!/usr/bin/env python3
"""Fail fast if the production WorldMap god script is accidentally truncated.

This guard exists because worldmap_main.gd was catastrophically shortened twice
(2026-09-06 and 2026-09-12) by updates that were intended to touch only a small
part of the file.  It deliberately checks broad structural invariants rather
than feature-specific behavior.
"""

from __future__ import annotations

import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MAIN = ROOT / "scripts/worldmap/worldmap_main.gd"
CAMERA_CONTROLLER = ROOT / "scripts/worldmap/camera/worldmap_camera_controller.gd"
MIN_MAIN_LINE_COUNT = 14_000
MIN_WORLD_MAP_ORCHESTRATION_LINE_COUNT = 15_000
MIN_FUNCTION_COUNT = 900

REQUIRED_MAIN_TOKENS = {
    "camera controller wiring": "func _ensure_camera_controller",
    "city storage": "func _get_city_storage",
    "save serialization": "func _serialize_worldmap_state",
    "save load": "func _load_worldmap_state",
    "battle handoff orchestration": "func _start_worldmap_battle_entry_camera_handoff",
    "turn runtime": "func _ensure_worldmap_runtime_state_defaults",
    "city marker selection": "func _on_city_marker_selected",
    "diplomacy validation": "func _validate_diplomacy_action",
    "spy validation": "func _validate_spy_action",
    "trade controller bridge": "func _ensure_trade_controller",
}

REQUIRED_CAMERA_TOKENS = {
    "camera configuration": "func configure",
    "camera input": "func handle_unhandled_input",
    "camera clamp": "func get_clamped_position_for_zoom",
    "battle handoff state": "_battle_entry_handoff_in_progress",
}


def main() -> None:
    source = MAIN.read_text(encoding="utf-8")
    camera_source = CAMERA_CONTROLLER.read_text(encoding="utf-8")
    line_count = len(source.splitlines())
    orchestration_line_count = line_count + len(camera_source.splitlines())
    function_count = len(re.findall(r"^(?:static\s+)?func\s+", source, flags=re.MULTILINE))

    failures: list[str] = []
    if line_count < MIN_MAIN_LINE_COUNT:
        failures.append(
            f"worldmap_main.gd has only {line_count} lines; expected at least "
            f"{MIN_MAIN_LINE_COUNT}. Possible whole-file truncation."
        )
    if orchestration_line_count < MIN_WORLD_MAP_ORCHESTRATION_LINE_COUNT:
        failures.append(
            f"WorldMap main + extracted camera controller have only {orchestration_line_count} lines; "
            f"expected at least {MIN_WORLD_MAP_ORCHESTRATION_LINE_COUNT}. Possible extraction loss."
        )
    if function_count < MIN_FUNCTION_COUNT:
        failures.append(
            f"worldmap_main.gd has only {function_count} functions; expected at least "
            f"{MIN_FUNCTION_COUNT}. Possible whole-file truncation."
        )

    for label, token in REQUIRED_MAIN_TOKENS.items():
        if token not in source:
            failures.append(f"missing structural sentinel [{label}]: {token}")
    for label, token in REQUIRED_CAMERA_TOKENS.items():
        if token not in camera_source:
            failures.append(f"missing camera-controller sentinel [{label}]: {token}")

    if failures:
        raise SystemExit("FAIL: WorldMap main integrity guard\n- " + "\n- ".join(failures))

    print(
        "PASS: WorldMap main integrity guard "
        f"({line_count} main lines, {orchestration_line_count} orchestration lines, "
        f"{function_count} main functions, all sentinels present)."
    )


if __name__ == "__main__":
    main()
