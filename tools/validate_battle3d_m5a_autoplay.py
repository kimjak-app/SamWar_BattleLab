"""M5-a 3D auto play + speed: pinned scope, zero engine/service/adapter diff,
exactly thirteen engine write calls (M4-c1 twelve + `_toggle_full_auto_battle`,
one call site, acceptance read back from `is_full_auto_battle_enabled`), read
boundary = M4-c1 + that one flag, `Engine.time_scale` only in the speed setter
and the restore in `_exit_tree`, the auto lock in `_input_locked` and the
shared command guidance, no auto decision made by 3D, no random / dice hook.

M5A_SCOPE_TIP=<commit> audits BASE..commit; the default is the merged
implementation commit. M5A_SCOPE_TIP=HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, hashlib, os, re, subprocess

BASE = "406bb73a024c3a0277ac8c06b891c30bc9e96e6b"  # merged M4-c2 tip (stack base)
TIP = os.environ.get("M5A_SCOPE_TIP", "651ac3723f506a880f79ec1ded91263d13c2e50a")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m5a_autoplay.py"
REPORT = "agent/BATTLE3D_M5A_RESULT_20261022.md"
HARNESS = "tests/scripts/support/battle3d_auto_harness.gd"
EQUIVALENCE = "tests/scripts/test_battle3d_auto_equivalence.gd"
CI_TESTS = ["tests/scripts/test_battle3d_auto_equivalence_seed_1.gd", "tests/scripts/test_battle3d_auto_equivalence_seed_2.gd",
            "tests/scripts/test_battle3d_auto_equivalence_seed_3.gd", "tests/scripts/test_battle3d_auto_speed.gd",
            "tests/scripts/test_battle3d_auto_stop_rejections.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, EQUIVALENCE, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd",
                      "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd", "tests/golden/", "tests/scripts/support/battle3d_skill_harness.gd",
                      "tests/scripts/support/battle3d_strategy_harness.gd", "tests/scripts/test_battle3d_skill_", "tools/validate_battle3d_m4c1_skill.py"]
TOGGLE = "_toggle_full_auto_battle"
END_COMMANDS = ["_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
                "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", TOGGLE]
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
            "_try_attack_enemy_target_from_attack_select", *END_COMMANDS}
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot", "_can_use_strategy", "_get_strategy_targets",
              "_get_strategy_success_rate", "_can_use_unique_skill", "_get_unique_skill_for_unit", "_get_unique_skill_valid_targets",
              "_should_unique_skill_resolve_without_manual_target"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states", "battle_action_event_log", "ally_move_event_log",
                   "battle_grid_controller", "enemy_action_event_log", "tactic_event_log", "battle_momentum", "is_manual_unique_skill_preview_pending",
                   "is_full_auto_battle_enabled"}
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|change_scene|_tick_full_auto|_stop_full_auto|_set_full_auto|_run_auto_action|" \
            r"_try_auto_|_auto_wait_active_ally|_get_auto_battle_max_steps|auto_battle_step_count|_consume_confused_ally_turn|strategy_roll_override|" \
            r"create_timer|set_speed_scale|\.speed_scale|process_mode"
NEW_FUNCTIONS = {"_build_auto_ui", "request_auto", "cycle_speed", "_apply_speed", "_exit_tree", "_refresh_auto_ui", "_note_quiet_auto_actions", "_auto_text"}
CHANGED_FUNCTIONS = {"_ready", "_process", "_sync_views", "_input_locked", "_ally_command_block_reason"}
NEW_MEMBERS = {"AUTO_STATUS", "SPEED_STEPS", "auto_button", "speed_button", "speed_index", "auto_was_on", "auto_press_pending", "auto_texts", "auto_marks"}


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\(.*?(?=^func |\Z)", code, re.M | re.S)}


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0] for line in source.splitlines())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def raw(path, base=False):
        return (root / path).read_bytes() if live and not base else git("show", f"{BASE if base else TIP}:{path}")

    def text(path, base=False):
        return raw(path, base).decode("utf-8").replace("\r\n", "\n")

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    for p in NEW:
        assert raw(p).strip(), "missing " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES) or p in NEW, "engine/service/adapter/golden/existing test diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    tracked = (git("ls-files", "scripts/battle3d") if live else git("ls-tree", "-r", "--name-only", TIP, "--", "scripts/battle3d")).decode().splitlines()  # pinned: the TIP tree
    for p in set(tracked):
        if p.endswith(".gd"):
            body = strip_comments(text(p))
            assert not re.search(r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random", body), "3D random call: " + p

    play = text(PLAY)
    code, old_code = strip_comments(play), strip_comments(text(PLAY, True))
    calls = re.findall(r'engine\.call\("([^"\n]+)"', code)
    assert set(calls) == COMMANDS | READ_CALLS, "thirteen commands and the M4-c1 read calls: " + str(set(calls) ^ (COMMANDS | READ_CALLS))
    assert len(COMMANDS) == 13 and all(calls.count(c) == 1 for c in END_COMMANDS), "one call site per end command (toggle included)"
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "read properties: " + str(set(props) ^ READ_PROPERTIES)
    assert len(re.findall(r"engine\.get\(", code)) == len(props) and not re.search(r"engine\.(?!get\(|call\()\w+", code), "no dynamic or alternate engine access"
    assert not re.search(r"is_full_auto_battle_enabled\s*=(?!=)|\.set\(\s*\"is_full_auto", code), "3D never writes the auto flag"
    assert not re.search(FORBIDDEN, code), "forbidden call: " + str(re.findall(FORBIDDEN, code))
    f, of = functions(code), functions(old_code)
    assert set(f) - set(of) == NEW_FUNCTIONS, "new functions: " + str((set(f) - set(of)) ^ NEW_FUNCTIONS)
    changed = {n for n in of if f.get(n) != of[n]}
    assert changed <= CHANGED_FUNCTIONS, "only listed shared functions change: " + str(changed - CHANGED_FUNCTIONS)
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old_code) == NEW_MEMBERS, "new members: " + str(members(code) - members(old_code))
    # Shared-function changes are minimal and exact.
    norm = lambda s: [x for x in s.splitlines() if x.strip()]
    diff_lines = lambda name: [x for x in norm(f[name]) if x not in norm(of[name])]
    assert diff_lines("_ready") == ["\t_build_auto_ui()"] and diff_lines("_process") == ["\tauto_press_pending = false"]
    assert sorted(diff_lines("_sync_views")) == sorted(["\t_refresh_auto_ui()", '\tattack_button.disabled = phase != "ally_turn" or engine.get("is_demo_animating") or active == null or _enemy_presentation_busy() or ended or engine.get("is_full_auto_battle_enabled")']), diff_lines("_sync_views")
    assert diff_lines("_input_locked") == ['\tif engine.get("is_full_auto_battle_enabled"):', '\t\t_reject("자동 진행 중 · [자동 ■]로 중지한 뒤 조작하세요")'], diff_lines("_input_locked")
    lock = f["_input_locked"]
    assert lock.index("battle_result.is_empty()") < lock.index("is_full_auto_battle_enabled") < lock.index('"enemy_turn"'), "auto lock after the end lock"
    assert diff_lines("_ally_command_block_reason") == ['\tif engine.get("is_full_auto_battle_enabled"): return "자동 진행 중 · [자동 ■]로 중지한 뒤 조작하세요"']
    # Toggle request: lock + guidance only for a start, one call, acceptance from the engine flag.
    req = f["request_auto"]
    steps = [x.strip() for x in req.splitlines() if x.strip()]
    assert steps[1] == "if not ready_for_input: return" and "if auto_press_pending:" in req
    start = req[req.index("if not was_on:"):req.index(f'engine.call("{TOGGLE}")')]
    assert "if _input_locked(): return" in start and '_ally_command_block_reason("자동")' in start, "start only through the lock and the shared guidance"
    after = req[req.index(f'engine.call("{TOGGLE}")'):]
    assert 'if engine.get("is_full_auto_battle_enabled") == was_on:' in after and after.index("_reject(") < after.index("auto_was_on = not was_on"), "acceptance read back before reporting"
    assert code.count("request_auto") == 2 and "auto_button.pressed.connect(request_auto)" in f["_build_auto_ui"], "button only, no hotkey"
    # Speed: Engine.time_scale only in the setter and the restore.
    users = {n for n, body in f.items() if "time_scale" in body}
    assert users == {"_apply_speed", "_exit_tree"}, "Engine.time_scale only in the speed setter and the restore: " + str(users)
    assert "Engine.time_scale = SPEED_STEPS[speed_index]" in f["_apply_speed"] and "Engine.time_scale = 1.0" in f["_exit_tree"]
    assert re.search(r"^const SPEED_STEPS := \[1\.0, 2\.0, 4\.0\]$", code, re.M) and "engine." not in f["cycle_speed"] + f["_apply_speed"], "1x/2x/4x, never an engine call"
    # 3D never decides: no toggle outside request_auto; the end is read from the engine flag.
    assert [n for n, body in f.items() if TOGGLE in body] == ["request_auto"]
    ref = f["_refresh_auto_ui"]
    assert 'var on: bool = engine.get("is_full_auto_battle_enabled")' in ref and "if auto_was_on and not on:" in ref
    assert '\t\t_auto_text(AUTO_STATUS)' in req and '_auto_text("자동 중지 · 진행 중인 행동이 끝나면 수동 조작")' in req, "start/stop shown"
    assert '_auto_text("자동 종료 · 엔진이 자동전투를 껐습니다" + ("" if battle_result.is_empty() else " · " + RESULT_TEXT.get(battle_result,battle_result)))' in ref, "engine-ended auto shown"
    assert 'const AUTO_STATUS := "자동 진행 중 · 엔진이 행동을 선택합니다 / [자동 ■]로 중지"' in code
    quiet = f["_note_quiet_auto_actions"]
    assert 'if auto_marks[value.unit_id] == counts: _auto_text("자동 · %s 행동 완료 (대기 또는 혼란: 엔진 이벤트 없음)" % value.unit_id)' in quiet, "event-less auto action shown"
    assert 'filter(func(e): return e.kind == "action_completed")' in quiet and '["skill_cast", "strategy_cast"]' in quiet and "value.has_acted" in quiet

    for p in CI_TESTS + [HARNESS, EQUIVALENCE]:
        assert "WorldMap.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M5A_AUTOPLAY validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter diff 0; thirteen commands (+{TOGGLE}, one call site); "
          f"{len(READ_PROPERTIES)} read properties (+is_full_auto_battle_enabled); Engine.time_scale only in _apply_speed/_exit_tree; auto lock in _input_locked")


if __name__ == "__main__":
    main()
