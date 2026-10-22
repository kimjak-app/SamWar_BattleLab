"""M5-c enemy AI level option panel (3D): pinned scope, zero
engine/service/adapter/shell diff, exactly fifteen engine write calls (M5-a2
fourteen + `set_enemy_ai_level`, one call site in `request_ai_level`), read
properties unchanged (twelve) and two new read calls (`get_enemy_ai_level`,
`get_pending_enemy_ai_level`), no level rule computed in 3D (no flag names),
the panel usable under input locks, a refusal shown.

M5C_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "63b08fe738eb7337f6f1c3e4734f4981e3ca1c60"  # feat(battle3d): ... (M5-b), night3 stack
TIP = os.environ.get("M5C_SCOPE_TIP", "f11375974b0df1c22ffb4d3c4c8fe30174dd7d3f")  # feat(battle3d): ... (M5-c), night3 stack
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m5c_option_panel.py"
PINNED = "tools/validate_battle3d_m5b_scenario.py"  # previous stack stage: TIP default pinned (one line)
REPORT = "agent/BATTLE3D_M5C_RESULT_20261023.md"
HARNESS = "tests/scripts/support/battle3d_option_harness.gd"
BASES = []
CI_TESTS = ["tests/scripts/test_battle3d_option_ai_level.gd", "tests/scripts/test_battle3d_option_ai_level_auto.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, *BASES, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW, PINNED}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd",
                      "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd", "scripts/battle3d/battle3d_scenario_shell.gd", "tests/golden/",
                      "tests/scripts/support/battle3d_auto_hold_harness.gd", "tests/scripts/support/battle3d_scenario_harness.gd", "tests/scripts/test_battle3d_auto_",
                      "tests/scripts/test_battle3d_scenario_", "tools/validate_battle3d_m5a2_auto_hold.py"]
LEVEL = "set_enemy_ai_level"
END_COMMANDS = ["_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
                "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle", "set_auto_presentation_hold", LEVEL]
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
            "_try_attack_enemy_target_from_attack_select", *END_COMMANDS}
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot", "_can_use_strategy", "_get_strategy_targets",
              "_get_strategy_success_rate", "_can_use_unique_skill", "_get_unique_skill_for_unit", "_get_unique_skill_valid_targets",
              "_should_unique_skill_resolve_without_manual_target", "get_enemy_ai_level", "get_pending_enemy_ai_level"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states", "battle_action_event_log", "ally_move_event_log",
                   "battle_grid_controller", "enemy_action_event_log", "tactic_event_log", "battle_momentum", "is_manual_unique_skill_preview_pending",
                   "is_full_auto_battle_enabled"}
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|change_scene|_tick_full_auto|_stop_full_auto|_set_full_auto|_run_auto_action|" \
            r"_try_auto_|_auto_wait_active_ally|_get_auto_battle_max_steps|auto_battle_step_count|_consume_confused_ally_turn|strategy_roll_override|" \
            r"create_timer|set_speed_scale|\.speed_scale|process_mode|\bauto_presentation_hold\b|enemy_strategy_enabled|enemy_skill_spread_enabled|" \
            r"enemy_skill_cap_enabled|\b_pending_enemy_ai_level|enemy_ai_level_applied|flags_for_ai_level|samwar_battle_setup"
NEW_FUNCTIONS = {"_build_option_ui", "toggle_option_panel", "request_ai_level", "_refresh_option_ui", "_ai_level_text"}
INSERTED = {"_ready": ["\t_build_option_ui()"], "_sync_views": ["\t_refresh_option_ui()"]}
NEW_MEMBERS = {"AI_LEVEL_ORDER", "AI_LEVEL_TEXT", "option_toggle", "option_panel", "ai_level_label", "ai_level_buttons", "ai_level_texts"}


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
    for p in NEW - {REPORT}:
        assert raw(p).strip(), "missing " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES) or p in NEW, "engine/service/adapter/golden/existing test diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p not in (VALIDATOR, PINNED)], "existing validators unchanged"
    pin_diff = [x for x in git("diff", "--unified=0", *rev, "--", PINNED).decode().splitlines() if x[:1] in "+-" and not x.startswith(("+++", "---"))]
    assert len(pin_diff) in (0, 2) and all(x[1:].startswith("TIP = os.environ.get(\"M5B_SCOPE_TIP\", ") for x in pin_diff), ("previous validator: TIP pin only", pin_diff)
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
    assert set(calls) == COMMANDS | READ_CALLS, "fifteen commands and the read calls: " + str(set(calls) ^ (COMMANDS | READ_CALLS))
    assert len(COMMANDS) == 15 and all(calls.count(c) == 1 for c in END_COMMANDS), "one call site per end command (toggle, hold and level included)"
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "read properties unchanged: " + str(set(props) ^ READ_PROPERTIES)
    assert len(re.findall(r"engine\.get\(", code)) == len(props) and not re.search(r"engine\.(?!get\(|call\()\w+", code), "no dynamic or alternate engine access"
    assert not re.search(FORBIDDEN, code), "forbidden (incl. level rules): " + str(re.findall(FORBIDDEN, code))
    f, of = functions(code), functions(old_code)
    assert set(f) - set(of) == NEW_FUNCTIONS and not set(of) - set(f), "new functions: " + str(set(f) ^ set(of))
    changed = {n for n in of if f.get(n) != of[n]}
    assert changed == set(INSERTED), "changed functions: " + str(changed)
    norm = lambda s: [x.rstrip() for x in s.splitlines() if x.strip()]
    for name, lines in INSERTED.items():
        assert [x for x in norm(f[name]) if x not in norm(of[name])] == lines and [x for x in norm(of[name]) if x not in norm(f[name])] == [], "only the insertion in " + name
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old_code) == NEW_MEMBERS, "new members: " + str(members(code) - members(old_code))
    assert [n for n, b in f.items() if LEVEL in b] == ["request_ai_level"], "level command only in request_ai_level"
    req = f["request_ai_level"]
    assert "_input_locked" not in req and "if not ready_for_input: return" in req, "usable under input locks (the engine accepts a level any time)"
    assert f'if not engine.call("{LEVEL}", level):' in req and '_ai_level_text("적 AI 변경 거절 · 엔진이 %s 등급을 받지 않았습니다" % AI_LEVEL_TEXT.get(level, level))' in req, "refusal shown"
    ref = f["_refresh_option_ui"]
    assert 'var current: String = engine.call("get_enemy_ai_level")' in ref and 'var pending: String = engine.call("get_pending_enemy_ai_level")' in ref, "panel from engine values"
    assert '"적 AI: %s" % AI_LEVEL_TEXT.get(current, current)' in ref and '" → %s (다음 적 턴부터 적용)" % AI_LEVEL_TEXT.get(pending, pending)' in ref
    assert 'const AI_LEVEL_ORDER := ["low", "mid", "high"]' in code and 'const AI_LEVEL_TEXT := {"low":"하", "mid":"중", "high":"상"}' in code
    assert "engine." not in f["toggle_option_panel"] and "option_toggle.pressed.connect(toggle_option_panel)" in f["_build_option_ui"], "fold = presentation only"
    assert "request_ai_level.bind(level)" in f["_build_option_ui"] and code.count("request_ai_level") == 2, "buttons only, no hotkey"
    assert "box.position = Vector2(size.x-230,16)" in f["_build_option_ui"], "own top-right area"

    for p in CI_TESTS + BASES + [HARNESS]:
        assert "WorldMap.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M5C_OPTION_PANEL validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter/shell diff 0; fifteen commands (+{LEVEL}, one call site); "
          f"{len(READ_PROPERTIES)} read properties + get_enemy_ai_level / get_pending_enemy_ai_level; no level rule in 3D; refusal shown")


if __name__ == "__main__":
    main()
