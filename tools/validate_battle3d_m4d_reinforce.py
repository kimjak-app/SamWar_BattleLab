"""M4-d 3D reinforcement arrivals: pinned scope, zero engine/service/adapter
diff, write calls unchanged (exactly the M4-a eight), read calls unchanged,
read properties = M4-a + `tactic_event_log`, a fourth independent cursor that
handles only reinforcement_arrived, arrivals shown from the event (engine cell
wins), units hidden and never sent before their arrival, no deploy/world-map/
result/strategy/skill calls, no hard-coded roster.

M4D_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, hashlib, os, re, subprocess

BASE = "3ea98f3e20309d53c6200ed4b92ad8d09650dffa"  # docs(battle): pin S4-1 validator ...
TIP = os.environ.get("M4D_SCOPE_TIP", "22f4facc66c41fde1662ca74fcffea4d48d1cb81")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m4d_reinforce.py"
REPORT = "agent/BATTLE3D_M4D_RESULT_20261022.md"
HARNESS = "tests/scripts/support/battle3d_reinforce_harness.gd"
CI_TESTS = ["tests/scripts/test_battle3d_reinforce_default_rounds.gd", "tests/scripts/test_battle3d_reinforce_blocking.gd",
            "tests/scripts/test_battle3d_reinforce_mixed_log.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW}
PROTECTED = ["scripts/battle_web_import_test.gd", "scripts/battle_unit_state.gd", "scripts/battle3d/lab_presentation.gd",
             "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
             "scripts/battle/services/battle_tactic_event_log_service.gd",
             "tests/scripts/support/battle3d_defend_harness.gd", "tests/scripts/support/battle3d_wait_harness.gd",
             "tests/scripts/support/battle3d_enemy_turn_harness.gd", "tests/scripts/support/battle3d_engine_attack_harness.gd",
             "tests/scripts/support/battle_enemy_turn_oracle_harness.gd", "tests/scripts/support/battle_tactic_oracle_harness.gd",
             "tools/validate_battle3d_m1b_engine_move.py", "tools/validate_battle3d_m2_engine_attack.py", "tools/validate_battle3d_m3_enemy_turn.py",
             "tools/validate_battle3d_m3b_wait.py", "tools/validate_battle3d_m4a_defend.py", "tools/validate_battle3d_m4b_strategy.py",
             "tests/scripts/support/battle3d_strategy_harness.gd", "tools/validate_battle_enemy_events_s3_1.py",
             "tools/validate_battle_tactic_events_s4_1.py", "tools/validate_battle3d_contract.py"]
GOLDENS = {"tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
           "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
           "tests/golden/battle_enemy_turn_baseline_v0.json": "a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7",
           "tests/golden/battle3d_m3_start_v0.json": "c1a1291fa0a2f23307b67316db64a3c663c38d43e15fd904f5b4e4e67921926a",
           "tests/golden/battle_tactic_baseline_v0.json": "2693536d50b23799ee3e63e4419912bf08929ea40c516bb86f284f959811db2d"}
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
            "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed",
            "_on_strategy_button_pressed", "_try_use_strategy_on_target"}
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot",
              "_can_use_strategy", "_get_strategy_targets", "_get_strategy_success_rate"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states", "battle_action_event_log",
                   "ally_move_event_log", "battle_grid_controller", "enemy_action_event_log", "tactic_event_log"}
VIEW_FIELDS = {"unit_id", "side", "unit_type", "grid_cell", "facing", "current_troops", "max_troops", "allocated_troops", "footprint",
               "has_moved", "has_acted", "status_effects", "move_range", "attack_range"}
FORBIDDEN = r"worldmap|world_map|WorldMap|payload|result_toast|result_video|_try_show_battle_result|change_scene|samwar_worldmap|" \
            r"_recover_wounded_troops_for_defend|_auto_wait_active_ally|_play_enemy|_start_new_round|full_auto|" \
            r"_mark_enemy_unit_acted|_mark_ally_unit_acted|_return_to_ally_turn|_finish_enemy_actor|_finish_enemy_basic|_enemy_reaction_hit_on|" \
            r"_on_unique_skill_button_pressed|_try_use_unique_skill|_begin_unique_skill|_try_auto_unique_skill|" \
            r"_deploy_reinforce|_deploy_city_reinforcement|_try_deploy|_set_unit_deployed|capacity_slot|_show_reinforcement_arrival_toast|arrival_round|" \
            r"_resolve_strategy|strategy_roll_override|has_deployed_reinforce"
ROSTER_TOKENS = r"reinforce_0|_demo\b|test_unit|\bsize\(\)\s*[=<>!]=?\s*(?:6|8|10)\b|\b(?:6|8|10)\s*[=<>!]=?\s*\w+\.size\(\)|\brange\((?:6|8|10)\)|[<>]=?\s*(?:6|8|10)\b"
CHANGED_FUNCTIONS = {"_process", "_sync_views", "_click_world", "_present_enemy_event", "_consume_tactic_events"}
NEW_FUNCTIONS = {"_flush_arrivals", "_present_arrival", "_round_start_pending", "_unit_shown", "_waiting_unit_at"}
NEW_MEMBERS = {"arrival_presentations", "arrival_texts", "pending_arrivals", "held_unit_ids"}


def check_state_writes(code):
    fields = r"(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action|current_troops|current_hp|is_defending|" \
             r"facing|status_effects|battle_round|is_demo_animating|active_unit_state|move_range|attack_range|side|" \
             r"max_troops|allocated_troops|dead_unit_ids|battle_momentum|is_deployed)"
    assignment = r"\s*(?:[+*/%&|^\-]|<<|>>|\*\*)?=(?!=)"
    assert not re.search(r"\b(?:unit|candidate|target|active|waited|defended|engine)\." + fields + assignment, code), "state assignment"
    assert not re.search(r"\[\s*['\"]" + fields + r"['\"]\s*\]" + assignment, code), "indexed state assignment"
    assert not re.search(r"\.(?:set|set_deferred)\(\s*['\"]" + fields + r"['\"]", code), "state property setter"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", code, re.M | re.S)}


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
    assert not [p for p in changes if p.startswith("scripts/") and p != PLAY], "engine/service/adapter diff must be 0 lines"
    for p in PROTECTED:
        assert text(p) == text(p, True), "protected bytes: " + p
    for p, digest in GOLDENS.items():
        assert hashlib.sha256(raw(p).replace(b"\r\n", b"\n")).hexdigest() == digest, "golden changed " + p
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    code = strip_comments(text(PLAY))
    old_code = strip_comments(text(PLAY, True))
    calls = re.findall(r'engine\.call\("([^"\n]+)"', code)
    assert set(calls) == COMMANDS | READ_CALLS, "write/read calls unchanged (ten commands): " + str(set(calls) ^ (COMMANDS | READ_CALLS))
    assert len(re.findall(r"engine\.call\(", code)) == len(calls), "no dynamic method names"
    old_calls = re.findall(r'engine\.call\("([^"\n]+)"', old_code)
    for c in COMMANDS:
        assert calls.count(c) == old_calls.count(c), "write call sites unchanged: " + c
    props = re.findall(r'engine\.get\("([^"\n]+)"\)', code)
    assert set(props) == READ_PROPERTIES, "read properties: " + str(set(props) ^ READ_PROPERTIES)
    assert len(re.findall(r"engine\.get\(", code)) == len(props), "no dynamic property names"
    assert not re.search(r"engine\.(?!get\(|call\()\w+", code), "no alternate engine access"
    check_state_writes(code)
    assert not re.search(FORBIDDEN, code), "forbidden call/rule: " + str(re.findall(FORBIDDEN, code))
    assert not re.search(ROSTER_TOKENS, code), "no hard-coded reinforcement ids or roster counts: " + str(re.findall(ROSTER_TOKENS, code))
    reads = set(re.findall(r"\b(?:unit|candidate|target|active|waited|defended)\.(\w+)", code))
    assert reads <= VIEW_FIELDS | {"is_defending"}, reads
    f, old_f = functions(code), functions(old_code)
    assert set(f) - set(old_f) == NEW_FUNCTIONS, "new functions: " + str((set(f) - set(old_f)) ^ NEW_FUNCTIONS)
    changed = {n for n in old_f if f.get(n) != old_f[n]}
    assert changed <= CHANGED_FUNCTIONS, "only listed shared functions change: " + str(changed - CHANGED_FUNCTIONS)
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old_code) == NEW_MEMBERS, "new members: " + str(members(code) - members(old_code))

    # Fourth cursor: reads the whole log, handles one kind, skips the rest.
    consume = f["_consume_tactic_events"]
    assert 'engine.get("tactic_event_log").export()' in consume and "tactic_cursor += 1" in consume and "_consume_enemy_events()" in consume
    assert re.findall(r'^\t\t\t"(\w+)":', consume, re.M) == ["strategy_cast", "status_tick", "reinforcement_arrived"] and re.search(r"^\t\t\t_:\n\t\t\t\tpass", consume, re.M), "one kind handled, others skipped"
    assert not re.search(r"push_error|assert|\bbreak\b|\breturn\b|quit\(", consume), "other kinds never stop the cursor"
    assert code.count("tactic_cursor") == 4 and "tactic_cursor = " not in code.replace("var tactic_cursor := 0", ""), "cursor only advances"
    for name in NEW_FUNCTIONS:
        assert not re.search(r"\b(event_cursor|action_cursor|enemy_cursor)\b", f[name]), "cursors stay independent: " + name
    assert "_consume_tactic_events()" in f["_process"] and "_flush_arrivals(event.round)" in f["_present_enemy_event"]
    # Arrival shown from the event; the engine cell wins; never created from a state diff.
    arrive = f["_present_arrival"]
    for token in ["event.unit_id", "event.side", "event.cell", "Adapter.to_view(unit).grid_cell", "held_unit_ids.erase(event.unit_id)", "_append_combat_line(line)"]:
        assert token in arrive, "arrival from the event: " + token
    assert "\tviews[event.unit_id].position = board.world(cell)\n" in arrive and "\tlabel.position = board.world(cell)+Vector3(0,4.8,0)\n" in arrive \
        and arrive.count("board.world(") == 2, "position exactly from the engine cell"
    assert "if _round_start_pending(event.round):" in consume and "pending_arrivals[event.round] = pending_arrivals.get(event.round,[]) + [event]" in consume, "arrival held for its replayed round_started"
    pending = f["_round_start_pending"]
    assert 'queued.kind == "round_started" and queued.round == round_number' in pending and "for queued in enemy_queue:" in pending, "hold reads the replay queue"
    assert '"지원군 도착 · %s · %s" % [side_text,event.unit_id]' in arrive, "arrival line"
    assert re.findall(r"held_unit_ids\[[^\]]+\] = true", code) == ["held_unit_ids[event.unit_id] = true"] and "held_unit_ids[event.unit_id] = true" in consume, "a unit is held only by its own arrival event"
    assert code.count("held_unit_ids.erase(") == 1, "released only when its arrival is presented"
    shown = [x.strip() for x in f["_unit_shown"].splitlines() if x.strip()]
    assert shown[1:] == ["return not held_unit_ids.has(unit_id)"], "visibility: engine deployed flag minus held arrivals " + str(shown)
    assert "_consume_tactic_events()" in f["_sync_views"].splitlines()[1], "arrivals are held before visibility is decided"
    waiting = f["_waiting_unit_at"]
    assert 'not engine.call("_is_unit_state_available_for_battle_slot",candidate) or not _unit_shown(value.unit_id)' in waiting and "value.current_troops > 0" in waiting, "waiting = live and not deployed (or held)"
    # Hidden and never sent before arrival.
    sync = f["_sync_views"]
    assert 'root.visible = engine.call("_is_unit_state_available_for_battle_slot",unit) and _unit_shown(value.unit_id)' in sync, "visibility needs engine deploy and an arrival"
    world = f["_click_world"]
    picks = [x.strip() for x in world.splitlines() if "unit = candidate" in x]
    assert picks == ['if candidate.grid_cell == cell and engine.call("_is_unit_state_available_for_battle_slot",candidate) and _unit_shown(candidate.unit_id): unit = candidate'], "selection: deployed and arrived, nothing else " + str(picks)
    assert world.index("_waiting_unit_at(cell)") < world.index('engine.call("_try_direct_move_to_cell"'), "waiting cells refused before any move call"
    assert world.index("_input_locked()") < world.index("_waiting_unit_at(cell)")

    for p in CI_TESTS + [HARNESS]:
        assert "WorldMap.tscn" not in text(p) and "Battle_Main.tscn" not in text(p), p
    git("diff", "--check", *rev)
    print(f"M4D_REINFORCE validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter diff 0; ten commands unchanged; "
          f"{len(READ_PROPERTIES)} read properties (+tactic_event_log); fourth cursor handles reinforcement_arrived only; "
          f"no deploy/world-map/result/strategy/skill calls")


if __name__ == "__main__":
    main()
