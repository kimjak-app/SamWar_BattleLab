"""M5-a2 3D auto waits for the 3D presentation: pinned scope, zero
engine/service/adapter diff, exactly fourteen engine write calls (M5-a thirteen +
`set_auto_presentation_hold`, one call site in `_update_auto_hold`), read
boundary unchanged (M5-a twelve properties), the hold sent on a change only and
always false when auto is off, the battle has a result, auto is stopped from 3D
or the lab leaves the tree; the busy check made of existing 3D/engine state only.

M5A2_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "79471b2ff815fff1c55275caf9d7e4581afc3831"  # feat(battle): ... (S4-3), night3 stack
TIP = os.environ.get("M5A2_SCOPE_TIP", "aa895ccb050aec8c77015df17e1c15fcf2c960e0")  # feat(battle3d): ... (M5-a2), night3 stack
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m5a2_auto_hold.py"
REPORT = "agent/BATTLE3D_M5A2_RESULT_20261023.md"
HARNESS = "tests/scripts/support/battle3d_auto_hold_harness.gd"
BASES = ["tests/scripts/test_battle3d_auto_hold.gd", "tests/scripts/test_battle3d_auto_hold_1x.gd"]
CI_TESTS = [f"tests/scripts/test_battle3d_auto_hold_seed_{n}.gd" for n in (1, 2, 3)] + [f"tests/scripts/test_battle3d_auto_hold_1x_seed_{n}.gd" for n in (1, 2, 3)] \
    + ["tests/scripts/test_battle3d_auto_hold_release.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, *BASES, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
PINNED = "tools/validate_battle_setup_port_s4_3.py"  # previous stack stage: TIP default pinned to its commit (one line)
MODIFIED = {PLAY, WORKFLOW, PINNED}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd",
                      "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd", "tests/golden/", "tests/scripts/support/battle3d_auto_harness.gd",
                      "tests/scripts/test_battle3d_auto_equivalence", "tests/scripts/test_battle3d_auto_speed", "tests/scripts/test_battle3d_auto_stop", "tools/validate_battle3d_m5a_autoplay.py"]
HOLD = "set_auto_presentation_hold"
END_COMMANDS = ["_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed", "_try_use_strategy_on_target",
                "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle", HOLD]
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
            r"create_timer|set_speed_scale|\.speed_scale|process_mode|\bauto_presentation_hold\b"
NEW_FUNCTIONS = {"_presentation_busy", "_update_auto_hold"}
INSERTED = {"_process": ["\t_update_auto_hold()"], "request_auto": ["\t_update_auto_hold()"], "_exit_tree": ["\t_update_auto_hold(true)"]}
NEW_MEMBERS = {"auto_hold_sent"}


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
    assert len(pin_diff) in (0, 2) and all(x[1:].startswith("TIP = os.environ.get(\"S4_3_SCOPE_TIP\", ") for x in pin_diff), ("previous validator: TIP pin only", pin_diff)
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
    assert set(calls) == COMMANDS | READ_CALLS, "fourteen commands and the M4-c1 read calls: " + str(set(calls) ^ (COMMANDS | READ_CALLS))
    assert len(COMMANDS) == 14 and all(calls.count(c) == 1 for c in END_COMMANDS), "one call site per end command (toggle and hold included)"
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "read properties unchanged: " + str(set(props) ^ READ_PROPERTIES)
    assert len(re.findall(r"engine\.get\(", code)) == len(props) and not re.search(r"engine\.(?!get\(|call\()\w+", code), "no dynamic or alternate engine access"
    assert not re.search(FORBIDDEN, code), "forbidden call: " + str(re.findall(FORBIDDEN, code))
    f, of = functions(code), functions(old_code)
    assert set(f) - set(of) == NEW_FUNCTIONS and not set(of) - set(f), "new functions: " + str(set(f) ^ set(of))
    changed = {n for n in of if f.get(n) != of[n]}
    assert changed == set(INSERTED), "changed functions: " + str(changed)
    norm = lambda s: [x.rstrip() for x in s.splitlines() if x.strip()]
    for name, lines in INSERTED.items():
        assert [x for x in norm(f[name]) if x not in norm(of[name])] == lines and [x for x in norm(of[name]) if x not in norm(f[name])] == [], "only the insertion in " + name
    assert norm(f["_process"])[-1] == "\t_update_auto_hold()", "hold updated last in every frame (after consuming and the view sync)"
    req = f["request_auto"]
    assert req.index('engine.call("_toggle_full_auto_battle")') < req.index("\t_update_auto_hold()"), "stop/start from 3D updates the hold right after the toggle"
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old_code) == NEW_MEMBERS, "new members: " + str(members(code) - members(old_code))
    # One call site, sent on a change only, false on every exit.
    assert [n for n, b in f.items() if HOLD in b] == ["_update_auto_hold"], "hold called only in _update_auto_hold"
    upd = [x.strip() for x in norm(f["_update_auto_hold"])[1:]]
    assert upd == ["if not is_instance_valid(engine): return",
                   'var hold: bool = not closing and engine.get("is_full_auto_battle_enabled") and battle_result.is_empty() and _presentation_busy()',
                   "if hold == auto_hold_sent: return", "auto_hold_sent = hold", f'engine.call("{HOLD}", hold)'], upd
    assert norm(f["_update_auto_hold"])[0] == "func _update_auto_hold(closing := false) -> void:"
    assert len(re.findall(r"_update_auto_hold\(", code)) == 4, "defined once, called from _process, request_auto and _exit_tree"
    assert re.search(r"^var auto_hold_sent := false\b", code, re.M)
    assert code.count("auto_hold_sent = ") == 1, "auto_hold_sent written only next to the call"
    busy = [x.strip() for x in norm(f["_presentation_busy"])[1:]]
    assert busy == ['if engine.get("is_demo_animating") or engine.get("current_phase") == "enemy_turn": return true',
                    "if not playback.is_empty() or _enemy_presentation_busy(): return true",
                    'return event_cursor < engine.get("ally_move_event_log").export().size() or action_cursor < engine.get("battle_action_event_log").export().size() \\',
                    'or enemy_cursor < engine.get("enemy_action_event_log").export().size() or tactic_cursor < engine.get("tactic_event_log").export().size()'], busy
    ext = f["_exit_tree"]
    assert "Engine.time_scale = 1.0" in ext and ext.index("Engine.time_scale = 1.0") < ext.index("_update_auto_hold(true)")

    for p in CI_TESTS + BASES + [HARNESS]:
        assert "WorldMap.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M5A2_AUTO_HOLD validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter diff 0; fourteen commands (+{HOLD}, one call site); "
          f"{len(READ_PROPERTIES)} read properties (unchanged); hold sent on a change only, false on stop/result/exit_tree; 3D random 0")


if __name__ == "__main__":
    main()
