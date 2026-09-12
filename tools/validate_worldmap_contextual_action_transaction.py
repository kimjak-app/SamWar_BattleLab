#!/usr/bin/env python3
"""Static contract checks for foreign-city contextual action execution."""

from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]


def read(relative_path: str) -> str:
    return (ROOT / relative_path).read_text(encoding="utf-8")


def require(source: str, token: str, label: str) -> None:
    if token not in source:
        raise AssertionError(f"missing {label}: {token}")


def forbid(source: str, token: str, label: str) -> None:
    if token in source:
        raise AssertionError(f"forbidden {label}: {token}")


def require_return_after_request(source: str, action_type: str) -> None:
    request = (
        f'_request_contextual_worldmap_action_presentation("{action_type}", '
    )
    position = source.find(request)
    if position < 0:
        raise AssertionError(f"missing {action_type} presentation request")
    following_lines = source[position:].splitlines()[1:3]
    if not following_lines or following_lines[0].strip() != "return":
        raise AssertionError(
            f"{action_type} must return immediately after requesting presentation"
        )


def main() -> None:
    coordinator = read("scripts/worldmap/actions/worldmap_action_coordinator.gd")
    worldmap = read("scripts/worldmap/worldmap_main.gd")
    city_actions = read("scripts/worldmap/ui/worldmap_city_action_test_controller.gd")
    presentation = read("scripts/worldmap/ui/worldmap_action_presentation_controller.gd")

    for token in (
        'const VALID_ACTION_TYPES := ["diplomacy", "spy", "trade"]',
        "var _pending_presentation := false",
        "var _resolving := false",
        "func request_presentation(",
        "func complete(",
        "var raw_result: Variant = execute_action.call(",
        "action_resolved.emit(completed_type, result)",
    ):
        require(coordinator, token, "coordinator transaction contract")

    for token in (
        'preload("res://scripts/worldmap/actions/worldmap_action_coordinator.gd")',
        "_setup_contextual_worldmap_action_coordinator()",
        'Callable(self, "_execute_contextual_worldmap_action")',
        '"diplomacy":\n\t\t\tresult = _apply_diplomacy_action',
        '"spy":\n\t\t\tresult = _apply_spy_action',
        '"trade":\n\t\t\tvar order:',
    ):
        require(worldmap, token, "WorldMap coordinator bridge")

    for old_state in (
        "var _contextual_worldmap_action_type",
        "var _contextual_worldmap_action_target_city_id",
        "var _contextual_worldmap_action_source_city_id",
        "var _contextual_worldmap_action_pending",
    ):
        forbid(worldmap, old_state, "legacy main-owned contextual state")

    require_return_after_request(worldmap, "diplomacy")
    require_return_after_request(worldmap, "spy")

    require(
        city_actions,
        'production_world_map.call(\n\t\t"open_contextual_worldmap_action",',
        "foreign-city button production route",
    )
    forbid(city_actions, "action_video_test_requested", "video-only city action route")
    forbid(presentation, "_video_test_only", "video-only presentation state")
    require(
        presentation,
        'production_world_map.call("complete_contextual_worldmap_action", action_type, action_id, target_city_id)',
        "video completion execution route",
    )
    require(
        presentation,
        "func _on_action_resolved(action_type: String, result: Dictionary) -> void:\n\t_show_result(action_type, result)",
        "resolved result scroll route",
    )

    print("PASS: WorldMap contextual actions open production UI, execute once after video, and present results.")


if __name__ == "__main__":
    main()
