"""Static M-8 boundary validator; visual behavior is covered by the Godot test."""

from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
MAIN_PATH = "scripts/worldmap/worldmap_main.gd"
CONTROLLER_PATH = "scripts/worldmap/t03/t03_battle_presentation_controller.gd"
MAIN = (ROOT / MAIN_PATH).read_text(encoding="utf-8")
CONTROLLER = (ROOT / CONTROLLER_PATH).read_text(encoding="utf-8")
M7_MAIN = subprocess.check_output(["git", "show", f"ccd0f4b:{MAIN_PATH}"], cwd=ROOT, text=True, encoding="utf-8")


def functions(source: str) -> dict[str, str]:
    matches = list(re.finditer(r"(?m)^func\s+([A-Za-z0-9_]+)\([^\n]*", source))
    return {
        match.group(1): source[match.start() : matches[index + 1].start() if index + 1 < len(matches) else len(source)].rstrip()
        for index, match in enumerate(matches)
    }


current = functions(MAIN)
baseline = functions(M7_MAIN)

assert "class_name T03BattlePresentationController" in CONTROLLER
assert "extends Node" in CONTROLLER
assert "signal presentation_completed(result: Dictionary)" in CONTROLLER
assert "signal presentation_queue_empty(result: Dictionary)" in CONTROLLER
for forbidden in [
    "configure(host", "_player_state", "_city_runtime_states", "_hero_runtime_states",
    "set_city_troops", "set_city_owner", "add_wounded", "rollback", "apply_result",
    "_advance_world_turn_mvp", "_run_enemy_turn_mvp", "_save_worldmap_state", "save_game",
    "GameAudio", "/root/GameAudio", "change_scene",
]:
    assert forbidden not in CONTROLLER, f"presentation crossed domain/orchestration boundary: {forbidden}"
for method in [
    "setup", "build_report", "enqueue_report", "try_present_next", "skip_video",
    "finish_video", "show_result_card", "confirm_report", "reset_presentation", "get_state_snapshot",
]:
    assert f"func {method}(" in CONTROLLER, f"missing presentation method: {method}"
for state in ["_active_report", "_phase", "_completion_emitted", "_queue_empty_emitted"]:
    assert state in CONTROLLER, f"missing presentation-owned state: {state}"
for wording in [
    "%s군이 %s을 점령했습니다.", "%s군이 방어에 성공했습니다.",
    "공격군 · 정상병 %d · 부상병 %d · 전사 %d · 이탈 %d",
    "방어군 · 정상병 %d · 부상병 %d · 전사 %d · 이탈 %d",
    "30턴 수비 승리", "전투 종료",
]:
    assert wording in CONTROLLER, f"presentation wording changed: {wording}"
assert "ResourceLoader.exists(_video_path)" in CONTROLLER and "_video_player.play()" in CONTROLLER
assert "show_result_card()" in functions(CONTROLLER)["skip_video"]
assert "show_result_card()" in functions(CONTROLLER)["finish_video"]
assert "presentation_completed.emit(result.duplicate(true))" in CONTROLLER

for wrapper, delegate in {
    "_build_t03_battle_report": "build_report",
    "_queue_t03_automatic_battle_report": "enqueue_report",
    "_setup_t03_battle_presentation": ".setup()",
    "_try_present_next_t03_battle_report": "try_present_next",
    "_on_t03_battle_video_skipped": "skip_video",
    "_on_t03_battle_video_finished": "finish_video",
    "_show_t03_battle_report_card": "show_result_card",
    "_on_t03_battle_report_confirmed": "confirm_report",
}.items():
    assert delegate in current[wrapper], f"non-delegating presentation wrapper: {wrapper}"

coordinator = current["_on_t03_battle_presentation_completed"]
assert "_save_worldmap_state()" in coordinator
assert "_present_t05_outcome_if_needed" in coordinator
assert "_try_present_next_t03_battle_report" in coordinator
entry = current["_try_present_next_t03_battle_report"]
assert "_has_terminal_korea_outcome_mvp()" in entry and "TURN_PHASE_PLAYER" in entry
assert '"report_queue"' in current["_t03_battle_presentation_query"]
assert '"acknowledged_report_ids"' in current["_t03_battle_presentation_query"]
assert '"set_report_queue"' in current["_t03_battle_presentation_mutation"]
assert '"set_acknowledged_report_ids"' in current["_t03_battle_presentation_mutation"]
assert "_t03_active_report" not in MAIN

for protected in [
    "_resolve_t03_automatic_invasion", "_apply_t03_strategic_battle_result",
    "_finalize_t03_strategic_battle_result", "_advance_world_turn_mvp", "_save_worldmap_state",
    "_is_hero_captured_for_battle", "_get_hero_battle_exclusion_reason",
    "_sync_worldmap_hero_locations_from_city_runtime_states", "_rebuild_occupation_runtime_indexes_mvp",
]:
    assert current[protected] == baseline[protected], f"M-8 changed protected coordinator/domain function: {protected}"

for unchanged_path in [
    "scripts/worldmap/t03/strategic_battle_transaction_service.gd",
    "scripts/worldmap/t03/auto_battle_resolver.gd",
    "scripts/worldmap/military/wounded_recovery_service.gd",
    "scripts/worldmap/battle/battle_result_service.gd",
    "scripts/worldmap/battle/battle_settlement_applier.gd",
]:
    current_bytes = (ROOT / unchanged_path).read_bytes()
    baseline_bytes = subprocess.check_output(["git", "show", f"ccd0f4b:{unchanged_path}"], cwd=ROOT)
    assert current_bytes == baseline_bytes, f"M-8 changed protected domain module: {unchanged_path}"

print("PASS: M-8 T03 presentation controller, queue ownership, exactly-once callback, and turn/save boundary")
