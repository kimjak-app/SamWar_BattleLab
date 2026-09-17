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
HUD_CONTROLLER = ROOT / "scripts/worldmap/hud/worldmap_hud_controller.gd"
SHARED_UI_CONTROLLER = ROOT / "scripts/worldmap/ui/worldmap_shared_ui_controller.gd"
CALENDAR_SERVICE = ROOT / "scripts/worldmap/turn/world_calendar_service.gd"
TURN_ECONOMY_SERVICE = ROOT / "scripts/worldmap/turn/world_turn_economy_service.gd"
TURN_STATE_SERVICE = ROOT / "scripts/worldmap/turn/world_turn_state_service.gd"
TURN_CONTROLLER = ROOT / "scripts/worldmap/turn/worldmap_turn_controller.gd"
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

REQUIRED_HUD_TOKENS = {
    "world status refresh": "func refresh_world_status",
    "selected city binding": "func refresh_selected_city_binding",
    "HUD visibility": "func set_hud_visible",
    "warehouse presentation": "func refresh_warehouse",
}

REQUIRED_SHARED_UI_TOKENS = {
    "generic modal": "func show_help_modal",
    "shared drag input": "func handle_input",
    "viewport clamp": "func move_panel_to_screen_position",
    "shared position delegation": "func request_panel_position",
}

REQUIRED_CALENDAR_TOKENS = {
    "turn calendar snapshot": "func get_calendar",
    "calendar display label": "func format_label",
    "season boundary": "func is_season_boundary",
    "world month serial": "func world_month_serial",
}

REQUIRED_TURN_ECONOMY_TOKENS = {
    "city income": "func calculate_city_income",
    "tax calculation": "func calculate_city_gold_tax_income",
    "supply income": "func apply_supply_income_effect",
    "hero upkeep": "func calculate_hero_upkeep_delta",
}

REQUIRED_TURN_STATE_TOKENS = {
    "public support tick": "func apply_public_support_tick",
    "seasonal loyalty tick": "func apply_seasonal_loyalty_tick",
    "city loyalty tick": "func apply_city_loyalty_tick",
    "loyalty calculation": "func calculate_city_loyalty_drift",
}

REQUIRED_TURN_CONTROLLER_TOKENS = {
    "end-turn request": "func request_end_turn",
    "enemy phase": "func run_enemy_turn",
    "turn completion": "func finish_enemy_turn",
    "turn increment": "func advance_world_turn",
}


def main() -> None:
    source = MAIN.read_text(encoding="utf-8")
    camera_source = CAMERA_CONTROLLER.read_text(encoding="utf-8")
    hud_source = HUD_CONTROLLER.read_text(encoding="utf-8")
    shared_ui_source = SHARED_UI_CONTROLLER.read_text(encoding="utf-8")
    calendar_source = CALENDAR_SERVICE.read_text(encoding="utf-8")
    turn_economy_source = TURN_ECONOMY_SERVICE.read_text(encoding="utf-8")
    turn_state_source = TURN_STATE_SERVICE.read_text(encoding="utf-8")
    turn_controller_source = TURN_CONTROLLER.read_text(encoding="utf-8")
    line_count = len(source.splitlines())
    orchestration_line_count = (
        line_count
        + len(camera_source.splitlines())
        + len(hud_source.splitlines())
        + len(shared_ui_source.splitlines())
        + len(calendar_source.splitlines())
        + len(turn_economy_source.splitlines())
        + len(turn_state_source.splitlines())
        + len(turn_controller_source.splitlines())
    )
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
    for label, token in REQUIRED_HUD_TOKENS.items():
        if token not in hud_source:
            failures.append(f"missing HUD-controller sentinel [{label}]: {token}")
    for label, token in REQUIRED_SHARED_UI_TOKENS.items():
        if token not in shared_ui_source:
            failures.append(f"missing shared-UI-controller sentinel [{label}]: {token}")
    for label, token in REQUIRED_CALENDAR_TOKENS.items():
        if token not in calendar_source:
            failures.append(f"missing calendar-service sentinel [{label}]: {token}")
    for label, token in REQUIRED_TURN_ECONOMY_TOKENS.items():
        if token not in turn_economy_source:
            failures.append(f"missing turn-economy-service sentinel [{label}]: {token}")
    for label, token in REQUIRED_TURN_STATE_TOKENS.items():
        if token not in turn_state_source:
            failures.append(f"missing turn-state-service sentinel [{label}]: {token}")
    for label, token in REQUIRED_TURN_CONTROLLER_TOKENS.items():
        if token not in turn_controller_source:
            failures.append(f"missing turn-controller sentinel [{label}]: {token}")

    if failures:
        raise SystemExit("FAIL: WorldMap main integrity guard\n- " + "\n- ".join(failures))

    print(
        "PASS: WorldMap main integrity guard "
        f"({line_count} main lines, {orchestration_line_count} orchestration lines, "
        f"{function_count} main functions, all sentinels present)."
    )


if __name__ == "__main__":
    main()
