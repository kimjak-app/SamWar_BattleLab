from pathlib import Path
import sys


ROOT = Path(__file__).resolve().parents[1]
WORLDMAP = ROOT / "scripts/worldmap/worldmap_main.gd"
TEST = ROOT / "tests/scripts/test_worldmap_to_battle_input_lifecycle.gd"
CANONICAL_BATTLE_SCENE = "res://scenes/battle/Battle_Main.tscn"


def require(condition: bool, message: str) -> None:
    if not condition:
        print(f"FAIL: {message}")
        sys.exit(1)


def function_body(source: str, signature: str, next_signature: str) -> str:
    start = source.find(signature)
    require(start >= 0, f"missing {signature}")
    end = source.find(next_signature, start + len(signature))
    require(end >= 0, f"missing boundary after {signature}")
    return source[start:end]


def main() -> None:
    source = WORLDMAP.read_text(encoding="utf-8")
    test_source = TEST.read_text(encoding="utf-8")
    require(
        f'const WORLDMAP_BATTLE_SCENE_PATH := "{CANONICAL_BATTLE_SCENE}"' in source,
        "WorldMap canonical battle path must target Battle_Main",
    )
    require(
        f'const BATTLE_SCENE_PATH := "{CANONICAL_BATTLE_SCENE}"' in test_source,
        "execution regression must target Battle_Main",
    )

    input_body = function_body(source, "func _input(event: InputEvent) -> void:", "func _unhandled_input(event: InputEvent) -> void:")
    unhandled_body = function_body(source, "func _unhandled_input(event: InputEvent) -> void:", "func _hide_retired_top_worldmap_hud()")
    transition_body = function_body(source, "func _change_scene_to_battle_with_context(handoff_context: Dictionary) -> void:", "func _rollback_player_attack_handoff")

    handoff_guard = "if _ensure_camera_controller().is_battle_entry_handoff_in_progress():"
    skip_guard = "if _is_worldmap_battle_entry_handoff_skip_event(event):"
    for label, body in (("_input", input_body), ("_unhandled_input", unhandled_body)):
        handoff = body.find(handoff_guard)
        handled = body.find("handoff_viewport.set_input_as_handled()", handoff)
        skip_check = body.find(skip_guard, handoff)
        skip = body.find("_skip_worldmap_battle_entry_camera_handoff()", handoff)
        require(
            handoff >= 0 and handled >= 0 and skip_check >= 0 and skip >= 0,
            f"{label} handoff branch incomplete",
        )
        require(
            handoff < handled < skip_check < skip,
            f"{label} must consume input before evaluating and executing skip transition",
        )

    disable = transition_body.find("set_process_input(false)")
    disable_unhandled = transition_body.find("set_process_unhandled_input(false)")
    change_scene = transition_body.find("change_scene_to_file(WORLDMAP_BATTLE_SCENE_PATH)")
    restore = transition_body.find("set_process_input(true)")
    require(disable >= 0 and disable_unhandled >= 0 and change_scene >= 0, "transition input lifecycle controls missing")
    require(disable < change_scene and disable_unhandled < change_scene, "old scene input must be disabled before transition")
    require(restore > change_scene, "failed transition must restore WorldMap input")

    for token in (
        "_handoff_battle_context_to_battle_scene",
        "worldmap.call(\"_input\", skip_event)",
        "InputEventMouseButton.new()",
        "BattleSupplyRuntime configured",
        "runtime supply panel visible",
        "context consumed exactly once",
    ):
        require(token in test_source, f"execution regression test missing {token}")

    print("WORLDMAP TO BATTLE INPUT LIFECYCLE PASS: canonical Battle_Main route; camera-controller handoff guard; input consumed before skip transition; old scene input disabled; execution test covers duplicate and mixed skip input")


if __name__ == "__main__":
    main()
