"""M3-b 3D wait command: pinned scope, zero engine diff, exactly seven engine
write calls (M2 six + `_end_ally_turn_by_wait`), unchanged read boundary, no
defend/world-map/result/turn-control calls, wait guarded and read back.

M3B_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, hashlib, os, re, subprocess

BASE = "c7e4fe8eac3c9d8339ec32e44574a498f6a8a960"
TIP = os.environ.get("M3B_SCOPE_TIP", "47f4fbf1c65cd65a74c2923710a353852009a05c")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
M3_VALIDATOR = "tools/validate_battle3d_m3_enemy_turn.py"
VALIDATOR = "tools/validate_battle3d_m3b_wait.py"
REPORT = "agent/BATTLE3D_M3B_RESULT_20261020.md"
HARNESS = "tests/scripts/support/battle3d_wait_harness.gd"
CI_TESTS = ["tests/scripts/test_battle3d_wait_equivalence.gd", "tests/scripts/test_battle3d_wait_default_round.gd",
            "tests/scripts/test_battle3d_wait_rejections.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW}
PROTECTED = ["scripts/battle_web_import_test.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_unit_adapter.gd",
             "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
             "tests/scripts/support/battle3d_enemy_turn_harness.gd", "tests/scripts/support/battle3d_engine_attack_harness.gd",
             "tests/scripts/support/battle_enemy_turn_oracle_harness.gd", "tools/validate_battle3d_m2_engine_attack.py",
             "tools/validate_battle_enemy_events_s3_1.py", "tools/validate_battle3d_contract.py"]
GOLDENS = {"tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
           "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
           "tests/golden/battle_enemy_turn_baseline_v0.json": "a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7",
           "tests/golden/battle3d_m3_start_v0.json": "c1a1291fa0a2f23307b67316db64a3c663c38d43e15fd904f5b4e4e67921926a"}
WAIT = "_end_ally_turn_by_wait"
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing",
            "_handle_right_click_cancel", "try_basic_attack", "_try_attack_enemy_target_from_attack_select", WAIT}
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states",
                   "battle_action_event_log", "ally_move_event_log", "battle_grid_controller", "enemy_action_event_log"}
VIEW_FIELDS = {"unit_id", "side", "unit_type", "grid_cell", "facing", "current_troops", "max_troops",
               "allocated_troops", "footprint", "has_moved", "has_acted", "status_effects", "move_range", "attack_range"}
# M3 list minus the now-approved wait; defend stays forbidden (M4).
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|_try_show_battle_result|change_scene|samwar_worldmap|" \
            r"_on_defend_button_pressed|_recover_wounded_troops_for_defend|_auto_wait_active_ally|_play_enemy|_start_new_round|full_auto|" \
            r"_mark_enemy_unit_acted|_mark_ally_unit_acted|_return_to_ally_turn|_finish_enemy_actor|_finish_enemy_basic|_enemy_reaction_hit_on"
CHANGED_FUNCTIONS = {"_build_ui", "_build_attack_ui", "_sync_views", "_wait_block_reason", "request_wait"}


def check_state_writes(code):
    fields = r"(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action|current_troops|current_hp|is_defending|" \
             r"facing|status_effects|battle_round|is_demo_animating|active_unit_state|move_range|attack_range|side|" \
             r"max_troops|allocated_troops|dead_unit_ids|battle_momentum)"
    assignment = r"\s*(?:[+*/%&|^\-]|<<|>>|\*\*)?=(?!=)"
    assert not re.search(r"\b" + fields + assignment, code), "state assignment"
    assert not re.search(r"\[\s*['\"]" + fields + r"['\"]\s*\]" + assignment, code), "indexed state assignment"
    assert not re.search(r"\.(?:set|set_deferred)\(\s*['\"]" + fields + r"['\"]", code), "state property setter"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", code, re.M | re.S)}


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
    engine_paths = [p for p in changes if p.startswith("scripts/") and p != PLAY]
    assert not engine_paths, "engine/service diff must be 0 lines: " + str(engine_paths)
    assert not git("diff", "--numstat", *rev, "--", "scripts/battle_web_import_test.gd", "scripts/battle").strip(), "engine numstat"
    for p in PROTECTED:
        assert text(p) == text(p, True), "protected bytes: " + p
    for p, digest in GOLDENS.items():
        assert hashlib.sha256(raw(p).replace(b"\r\n", b"\n")).hexdigest() == digest, "golden changed " + p
    assert text(M3_VALIDATOR) == text(M3_VALIDATOR, True), "M3 validator unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    play = text(PLAY)
    code = "\n".join(line.split("#", 1)[0] for line in play.splitlines())
    old_code = "\n".join(line.split("#", 1)[0] for line in text(PLAY, True).splitlines())
    calls = re.findall(r'engine\.call\("([^"\n]+)"', code)
    assert set(calls) == COMMANDS | READ_CALLS, "exact seven commands and three read calls: " + str(set(calls))
    assert len(COMMANDS) == 7 and calls.count(WAIT) == 1, "one wait call site"
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "read properties unchanged: " + str(set(props))
    assert len(re.findall(r"engine\.get\(", code)) == len(props), "no dynamic property names"
    assert not re.search(r"engine\.(?!get\(|call\()\w+", code), "no alternate engine access"
    assert not re.search(r"\b(?:engine|battle|unit|candidate|target|active|host|waited)\s*\.\s*(?:set\w*\s*\(|\w+\s*=(?!=))", code), "engine/unit write"
    check_state_writes(code)
    assert not re.search(r"\b(?:apply_damage|set_grid_cell|set_facing|set_has_moved|set_has_acted|set_last_action|set_deferred|get_distance|find_move_path|request_move|acknowledge_presentation|emit)\s*\(", code)
    assert not re.search(FORBIDDEN, code), "defend/world-map/result/turn-control call: " + str(re.findall(FORBIDDEN, code))
    reads = set(re.findall(r"\b(?:unit|candidate|target|active|waited)\.(\w+)", code))
    assert reads <= VIEW_FIELDS | {"is_defending"}, reads
    f, old_f = functions(code), functions(old_code)
    changed = {n for n in f if f[n] != old_f.get(n)} | {n for n in old_f if n not in f}
    assert changed <= CHANGED_FUNCTIONS, "only wait-related functions change: " + str(changed - CHANGED_FUNCTIONS)
    wait = f["request_wait"]
    assert wait.index("_input_locked()") < wait.index("_wait_block_reason()") < wait.index(f'engine.call("{WAIT}")'), "lock, then guidance, then the command"
    after = wait[wait.index(f'engine.call("{WAIT}")'):]
    assert "has_acted" in after and "if not accepted:" in after and after.index("if not accepted:") < after.index("_append_combat_line"), "acceptance read back before reporting success"
    assert '"행동 불가 · 엔진이 대기를 수락하지 않았습니다"' in after
    block = f["_wait_block_reason"]
    order = ["battle_result.is_empty()", '"enemy_turn"', '"is_demo_animating"', "_enemy_presentation_busy()", 'phase != "ally_turn"', "active == null", "has_acted"]
    assert [block.index(x) for x in order] == sorted(block.index(x) for x in order), "result > enemy_turn > animating > queue > phase > selection > acted"
    assert code.count("request_wait") == 2 and "wait_button.pressed.connect(request_wait)" in f["_build_attack_ui"], "button only, no hotkey"
    assert "request_wait" not in f["_unhandled_input"]
    assert "wait_button.disabled = not wait_block.is_empty()" in f["_sync_views"], "button state from the same guidance"
    for p in CI_TESTS:
        assert "WorldMap.tscn" not in text(p) and "Battle_Main.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M3B_WAIT validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine diff 0; seven commands "
          f"(+{WAIT}); {len(READ_PROPERTIES)} read properties unchanged; no defend/world-map/result calls")


if __name__ == "__main__":
    main()
