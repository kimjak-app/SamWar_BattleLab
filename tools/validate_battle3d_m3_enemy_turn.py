"""M3 3D enemy-turn playback: pinned scope, zero engine diff, exact command and
read boundaries, three independent cursors, no world-map/result handoff.

M3_3D_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, hashlib, os, re, subprocess

BASE = "cbc1e43abfcc59aa40883883b5dcc4182ecf21e1"
TIP = os.environ.get("M3_3D_SCOPE_TIP", "HEAD")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
S3_1_VALIDATOR = "tools/validate_battle_enemy_events_s3_1.py"
M2_HARNESS = "tests/scripts/support/battle3d_engine_attack_harness.gd"
VALIDATOR = "tools/validate_battle3d_m3_enemy_turn.py"
REPORT = "agent/BATTLE3D_M3_RESULT_20261020.md"
HARNESS = "tests/scripts/support/battle3d_enemy_turn_harness.gd"
GOLDEN = "tests/golden/battle3d_m3_start_v0.json"
CI_TESTS = ["tests/scripts/test_battle3d_enemy_turn_equivalence_shard_1.gd", "tests/scripts/test_battle3d_enemy_turn_equivalence_shard_2.gd",
            "tests/scripts/test_battle3d_enemy_turn_equivalence_shard_3.gd", "tests/scripts/test_battle3d_enemy_turn_locks.gd",
            "tests/scripts/test_battle3d_enemy_turn_default_layout.gd"]
OTHER_TESTS = ["tests/scripts/test_battle3d_enemy_turn_equivalence.gd", "tests/scripts/test_battle3d_enemy_turn_manual.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, GOLDEN, *CI_TESTS, *OTHER_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW, S3_1_VALIDATOR, M2_HARNESS}
PROTECTED = ["scripts/battle_web_import_test.gd", "scripts/battle/services/battle_enemy_event_log_service.gd",
             "scripts/battle/services/battle_event_log_service.gd", "scripts/battle3d/lab_presentation.gd",
             "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd",
             "scripts/battle3d/battle3d_movement_adapter.gd", "tools/validate_battle3d_contract.py",
             "tools/validate_battle3d_m2_engine_attack.py", "tests/scripts/support/battle_enemy_turn_oracle_harness.gd",
             "tests/scripts/support/battle_attack_oracle_harness.gd"]
GOLDENS = {"tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
           "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
           "tests/golden/battle_enemy_turn_baseline_v0.json": "a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7"}
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing",
            "_handle_right_click_cancel", "try_basic_attack", "_try_attack_enemy_target_from_attack_select"}
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states",
                   "battle_action_event_log", "ally_move_event_log", "battle_grid_controller", "enemy_action_event_log"}
VIEW_FIELDS = {"unit_id", "side", "unit_type", "grid_cell", "facing", "current_troops", "max_troops",
               "allocated_troops", "footprint", "has_moved", "has_acted", "status_effects", "move_range", "attack_range"}
CURSORS = {"_consume_events": ("ally_move_event_log", "event_cursor"),
           "_consume_action_events": ("battle_action_event_log", "action_cursor"),
           "_consume_enemy_events": ("enemy_action_event_log", "enemy_cursor")}
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|_try_show_battle_result|change_scene|samwar_worldmap|" \
            r"_on_defend_button_pressed|_end_ally_turn_by_wait|_auto_wait_active_ally|_play_enemy|_start_new_round|full_auto|" \
            r"_mark_enemy_unit_acted|_return_to_ally_turn|_finish_enemy_actor|_finish_enemy_basic|_enemy_reaction_hit_on"


def check_state_writes(code):
    # M2 field set plus every other engine-owned value the M3 UI displays.
    # unit_type is left to the unit-write rule: M2's model picker rewrites a
    # local view copy (model_value.unit_type), never engine state.
    fields = r"(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action|current_troops|current_hp|is_defending|" \
             r"facing|status_effects|battle_round|is_demo_animating|active_unit_state|move_range|attack_range|side|" \
             r"max_troops|allocated_troops|dead_unit_ids|battle_momentum)"
    assignment = r"\s*(?:[+*/%&|^\-]|<<|>>|\*\*)?=(?!=)"
    assert not re.search(r"\b" + fields + assignment, code), "state assignment"
    assert not re.search(r"\[\s*['\"]" + fields + r"['\"]\s*\]" + assignment, code), "indexed state assignment"
    assert not re.search(r"\.(?:set|set_deferred)\(\s*['\"]" + fields + r"['\"]", code), "state property setter"


def functions(code):
    return {m.group(1): m.group(0) for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", code, re.M | re.S)}


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

    # G0 scope and zero engine diff.
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

    # Allowed edits to earlier files are exact.
    old_s31 = text(S3_1_VALIDATOR, True)
    assert text(S3_1_VALIDATOR) == old_s31.replace('TIP = os.environ.get("S3_1_SCOPE_TIP", "HEAD")',
                                                   'TIP = os.environ.get("S3_1_SCOPE_TIP", "cbc1e43abfcc59aa40883883b5dcc4182ecf21e1")', 1) \
        and text(S3_1_VALIDATOR) != old_s31, "S3-1 validator: only the default TIP pin"
    old_m2 = text(M2_HARNESS, True)
    m2_old_line = '\t\tif positions: expect(view.position.distance_to(lab.board.world(unit.grid_cell))<.001,label+" cell "+unit.unit_id)\n'
    m2_new = ('\t\tif positions and lab.playback.has(unit.unit_id):\n'
              '\t\t\t# M3: an enemy path playback may still run after the engine callback; it must end on the engine cell.\n'
              '\t\t\texpect(lab.playback[unit.unit_id].path[-1]==unit.grid_cell,label+" playback ends on engine cell "+unit.unit_id)\n'
              '\t\telif positions: expect(view.position.distance_to(lab.board.world(unit.grid_cell))<.001,label+" cell "+unit.unit_id)\n')
    assert old_m2.count(m2_old_line) == 1 and text(M2_HARNESS) == old_m2.replace(m2_old_line, m2_new), "M2 harness: only the playback-aware position check"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    # 3D command/read boundary.
    play = text(PLAY)
    code = "\n".join(line.split("#", 1)[0] for line in play.splitlines())
    calls = re.findall(r'engine\.call\("([^"\n]+)"', code)
    assert set(calls) == COMMANDS | READ_CALLS, "exact six commands and three read calls: " + str(set(calls))
    assert set(calls) & COMMANDS == COMMANDS and len(COMMANDS) == 6
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "explicit read properties: " + str(set(props))
    assert len(re.findall(r"engine\.get\(", code)) == len(props), "no dynamic property names"
    assert not re.search(r"engine\.(?!get\(|call\()\w+", code), "no alternate engine access"
    assert not re.search(r"\b(?:engine|battle|unit|candidate|target|active|host)\s*\.\s*(?:set\w*\s*\(|\w+\s*=(?!=))", code), "engine/unit write"
    check_state_writes(code)
    assert not re.search(r"\b(?:apply_damage|set_grid_cell|set_facing|set_has_moved|set_has_acted|set_last_action|set_deferred|get_distance|find_move_path|request_move|acknowledge_presentation|emit)\s*\(", code), "rules/state/log writes belong to engine"
    assert not re.search(r"\.call\(\s*['\"](?:set_|apply_|_)", code.replace("engine.call(", "")), "dynamic state setter"
    assert not re.search(FORBIDDEN, code), "world-map/result/turn-control call: " + str(re.findall(FORBIDDEN, code))
    f = functions(code)
    assert code.count("target.is_defending") == 1 and "target.is_defending" in f["_refresh_target_info"], "defense read only in target panel"
    reads = set(re.findall(r"\b(?:unit|candidate|target|active)\.(\w+)", code))
    assert reads <= VIEW_FIELDS | {"is_defending"}, reads
    # Three independent cursors, one log each.
    for name, (log, cursor) in CURSORS.items():
        body = f[name]
        assert f'engine.get("{log}").export()' in body and f"events[{cursor}]" in body and re.search(cursor + r"\s*\+=\s*1", body), name
        others = [c for _, c in CURSORS.values() if c != cursor] + [l for l, _ in CURSORS.values() if l != log]
        assert not any(o in body for o in others), "cursor/log mixed in " + name
    assert "_consume_enemy_events()" in f["_process"] and "_consume_enemy_events()" in f["_input_locked"]
    # Playback and display come from event fields; truth comes from engine state.
    assert "event.path" in f["_start_enemy_move"] and "playback[event.unit_id]" in f["_start_enemy_move"], "enemy path playback"
    assert "if playback.has(enemy_moving_id): return" in f["_advance_enemy_presentation"], "queue waits for the path playback"
    assert "event.damage_applied" in f["_show_enemy_hit"] and "raw_damage" not in code, "hit shows damage_applied"
    lock = f["_input_locked"]
    assert lock.index("battle_result.is_empty()") < lock.index('"current_phase"') < lock.index("_enemy_presentation_busy()"), "result lock outranks phase and queue"
    assert 'battle_result = event.result_state' in f["_consume_enemy_events"], "end lock on receipt"
    assert re.search(r"value\.has_acted.*\n.*value\.has_moved", f["action_state_text"]), "action state from engine flags"
    assert 'root.visible = engine.call("_is_unit_state_available_for_battle_slot",unit)' in f["_sync_views"], "visibility authority"
    for p in CI_TESTS + OTHER_TESTS:
        assert "WorldMap.tscn" not in text(p) and "Battle_Main.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M3_3D validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine diff 0; six commands; "
          f"{len(READ_PROPERTIES)} read properties; three cursors; no world-map/result/turn-control calls")


if __name__ == "__main__":
    main()
