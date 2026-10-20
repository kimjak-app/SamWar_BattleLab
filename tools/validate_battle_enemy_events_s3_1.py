"""S3-1 enemy-turn event recording: pinned scope, additive-only controller delta,
observation-only service, immutable existing goldens, exact CI wiring.

S3_1_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, ast, hashlib, json, os, re, subprocess

BASE = "a19a08d4a370b68e50ee5a8cf24513d6689b6024"
TIP = os.environ.get("S3_1_SCOPE_TIP", "1404c6c6456aa82b155b39519a2e285cfd5c307c")
CONTROLLER = "scripts/battle_web_import_test.gd"
SERVICE = "scripts/battle/services/battle_enemy_event_log_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
GOLDEN = "tests/golden/battle_enemy_turn_baseline_v0.json"
HARNESS = "tests/scripts/support/battle_enemy_turn_oracle_harness.gd"
RUNNER = "tests/scripts/test_battle_enemy_turn_oracle_baseline.gd"
OLD_GOLDENS = {
    "tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
    "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
}
NEW = {SERVICE, GOLDEN, "tools/validate_battle_enemy_events_s3_1.py", "agent/BATTLE_ENGINE_S3_1_RESULT_20261020.md"}
for stem in ["support/battle_enemy_turn_oracle_harness", "support/battle_enemy_event_observer_battle",
             "test_battle_enemy_event_log_service", "test_battle_enemy_turn_oracle_baseline",
             "test_battle_enemy_turn_oracle_shard_1", "test_battle_enemy_turn_oracle_shard_2",
             "test_battle_enemy_turn_event_semantics"]:
    NEW.add("tests/scripts/" + stem + ".gd")
NEW |= {path + ".uid" for path in list(NEW) if path.endswith(".gd")}
NEW.add(SERVICE + ".uid")
MODIFIED = {CONTROLLER, WORKFLOW}
KINDS = ["enemy_turn_started", "enemy_actor_selected", "enemy_moved", "enemy_attack_resolved", "enemy_waited",
         "enemy_action_completed", "enemy_skill_used", "round_started", "battle_ended"]
HEADER = 'var enemy_action_event_log := preload("res://scripts/battle/services/battle_enemy_event_log_service.gd").new()'
LOG = "enemy_action_event_log."
# function -> exact recording lines it gains (order preserved)
EXPECTED = {
    "_try_auto_unique_skill_for_actor": ['\tenemy_action_event_log.record_skill(caster_state, skill_data, target_state)'],
    "_play_enemy_ai_turn": ['\tenemy_action_event_log.emit("enemy_turn_started", {"round":battle_round})'],
    "_play_enemy_ai_for_actor": [
        '\tenemy_action_event_log.record_unit("enemy_actor_selected", enemy_actor_state)',
        '\t\tenemy_action_event_log.record_waited(enemy_actor_state, "confused")',
        '\t\tenemy_action_event_log.record_waited(enemy_actor_state, "no_target")',
        '\t\tenemy_action_event_log.record_waited(enemy_actor_state, "wait")',
        '\t\tenemy_action_event_log.record_waited(enemy_actor_state, "no_path")'],
    "_play_enemy_actor_basic_attack_from_current_cell": ['\t\tenemy_action_event_log.record_waited(enemy_actor_state, "no_target")'],
    "_play_enemy_actor_path_move_then_act": [
        '\t\tenemy_action_event_log.record_waited(enemy_actor_state, "path_blocked")',
        '\tenemy_action_event_log.stage_move_path(enemy_actor_state.unit_id, move_path)'],
    "_finish_enemy_actor_basic_move": ['\tenemy_action_event_log.emit_staged_move(enemy_actor_state.unit_id, target_cell)'],
    "_play_enemy_actor_basic_attack_or_wait_after_move": ['\tenemy_action_event_log.record_waited(enemy_actor_state, "wait")'],
    "_enemy_reaction_hit_on": ['\t\tenemy_action_event_log.record_attack(current_enemy_ai_actor_state, target_state, attack_damage, applied_attack_damage, attack_angle_type)'],
    "_handle_battle_end_guard": ['\t\tenemy_action_event_log.emit("battle_ended", {"result_state":battle_result_state})'],
    "_start_new_round": ['\tenemy_action_event_log.emit("round_started", {"round":battle_round})'],
    "_mark_enemy_unit_acted": ['\t\tenemy_action_event_log.record_unit("enemy_action_completed", unit_state)'],
}
# Exact neighbours: the recording line sits directly after these lines.
AFTER = [
    ("_play_enemy_ai_turn", '\t\treturn', 'enemy_turn_started'),
    ("_play_enemy_ai_for_actor", '\tcurrent_enemy_ai_actor_state = enemy_actor_state', 'enemy_actor_selected'),
    ("_finish_enemy_actor_basic_move", '\tenemy_actor_state.set_grid_cell(target_cell)', 'emit_staged_move'),
    ("_enemy_reaction_hit_on", '\t\tvar applied_attack_damage := target_state.apply_damage(attack_damage)', 'record_attack'),
    ("_handle_battle_end_guard", '\t\thas_logged_battle_end_guard = true', 'battle_ended'),
    ("_start_new_round", '\t_show_round_start_banner()', 'round_started'),
    ("_mark_enemy_unit_acted", '\t\tprint("[ENEMY_TURN] round=%d actor=%s acted remaining=%d" % [battle_round, unit_state.unit_id, _get_remaining_unacted_enemy_count()])', 'enemy_action_completed'),
    ("_play_enemy_actor_path_move_then_act", '\t_focus_camera_on_unit(enemy_actor_state)', 'stage_move_path'),
]


def functions(source):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", source, re.M | re.S)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args]).decode("utf-8")

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def source(path, base=False):
        if live and not base:
            return (root / path).read_text(encoding="utf-8")
        return git("show", f"{BASE if base else TIP}:{path}")

    def raw(path):
        return (root / path).read_bytes() if live else subprocess.check_output(["git", "-C", str(root), "show", f"{TIP}:{path}"])

    # G0 scope
    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", *rev).splitlines())
    if live:
        for path in git("ls-files", "--others", "--exclude-standard").splitlines():
            changes.setdefault(path, "A")
    for path, status in changes.items():
        assert (path in MODIFIED and status == "M") or (path in NEW and status == "A"), ("out of scope", status, path)
    for path in NEW:
        assert source(path).strip(), "missing new file " + path
    for path, digest in OLD_GOLDENS.items():
        assert hashlib.sha256(raw(path)).hexdigest() == digest, "existing golden changed " + path

    # Controller: additions only, every added line is a recording call, removing
    # them restores the BASE source byte for byte (no deletion or reordering).
    stat = git("diff", "--numstat", *rev, "--", CONTROLLER).split()
    assert stat and stat[1] == "0", "controller additions only"
    old, new = source(CONTROLLER, True), source(CONTROLLER)
    added = [line for line in new.split("\n") if line.strip().startswith(LOG) or line == HEADER]
    assert len(added) == 1 + sum(len(v) for v in EXPECTED.values()), ("recording line count", len(added))
    stripped = "\n".join(line for line in new.split("\n") if not (line.strip().startswith(LOG) or line == HEADER))
    assert stripped == old, "controller minus recording lines == BASE"
    assert new.count(HEADER) == 1 and HEADER in new[:new.index("\nfunc ")], "log member declared once in header"
    a, b = functions(old), functions(new)
    assert set(a) == set(b), "controller function set unchanged"
    for name in b:
        lines = [line for line in b[name].split("\n") if line.strip().startswith(LOG)]
        assert lines == EXPECTED.get(name, []), ("recording lines in " + name, lines)
    for name, previous, marker in AFTER:
        body = b[name].split("\n")
        index = [i for i, line in enumerate(body) if line.strip().startswith(LOG) and marker in line]
        assert len(index) == 1 and body[index[0] - 1] == previous, ("recording position", name, marker)
    assert old.count("enemy_action_event_log") == 0
    for line in added:
        assert not re.search(r"\b\w+\s*=[^=]", line.split("(", 1)[0]), "recording line assigns nothing: " + line
    for other in ["battle_action_event_log", "ally_move_event_log"]:
        assert old.count(other) == new.count(other), "ally log usage unchanged: " + other

    # Service: RefCounted, no scene/Node/signal access, log-only members, reads units only.
    svc = source(SERVICE)
    code = "\n".join(line.split("#", 1)[0] for line in svc.splitlines())
    assert re.search(r"^extends RefCounted$", code, re.M)
    assert not re.search(r"\b(Node\w*|SceneTree|Tween|await|signal|Callable|get_tree|call_deferred)\b", code)
    members = re.findall(r"^var (\w+)", code, re.M)
    assert members == ["_events", "_sequence", "_staged_move_unit_id", "_staged_move_path"], members
    assert not re.search(r"\b(attacker|target|caster|unit)\.\w+\s*(=[^=]|\+=|-=)", code), "service writes no unit field"
    assert not re.search(r"\.(apply_damage|set_grid_cell|apply_status_effect|reset_action_flags|heal)\(", code)
    fields = re.search(r"const FIELDS := \{(.*?)\n\}", svc, re.S).group(1)
    assert re.findall(r'^\t"(\w+)":', fields, re.M) == KINDS, "exact event kinds"
    assert 'const WAIT_REASONS := ["wait", "confused", "no_path", "path_blocked", "no_target"]' in svc
    assert "return _events.duplicate(true)" in svc, "export is a deep copy"

    # CI: previous checks kept, exactly the new checks added in place.
    expected_wf = source(WORKFLOW, True).replace(
        "            tools/validate_battle_s2_2_attack_state_service.py\n",
        "            tools/validate_battle_s2_2_attack_state_service.py\n            tools/validate_battle_enemy_events_s3_1.py\n", 1).replace(
        "            tests/scripts/test_battle_attack_event_parity.gd\n",
        "            tests/scripts/test_battle_attack_event_parity.gd\n"
        "            tests/scripts/test_battle_enemy_event_log_service.gd\n"
        "            tests/scripts/test_battle_enemy_turn_oracle_shard_1.gd\n"
        "            tests/scripts/test_battle_enemy_turn_oracle_shard_2.gd\n"
        "            tests/scripts/test_battle_enemy_turn_event_semantics.gd\n", 1)
    assert source(WORKFLOW) == expected_wf, "CI wiring exact"

    # Oracle: cases, exact shard partition, golden captured on BASE.
    cases = ast.literal_eval(re.search(r"const CASES := (\[.*?\])", source(HARNESS), re.S).group(1))
    assert len(cases) >= 12 and len(cases) == len(set(cases)), "case list"
    for i, sl in [(1, "0,10"), (2, "10")]:
        assert source(f"tests/scripts/test_battle_enemy_turn_oracle_shard_{i}.gd") == (
            f'extends "res://tests/scripts/test_battle_enemy_turn_oracle_baseline.gd"\n\nfunc case_labels() -> Array:\n\treturn super.case_labels().slice({sl})\n')
    assert f'const BASE_COMMIT := "{BASE}"' in source(RUNNER)
    golden = json.loads(source(GOLDEN))
    assert golden["base_commit"] == BASE
    assert [item["case"] for item in golden["scenarios"]] == cases, "golden covers every case in order"
    for item in golden["scenarios"]:
        assert set(item) == {"case", "spec", "checkpoints", "ally_logs_start", "ally_logs_end"}, "golden holds no enemy events"
        for point in item["checkpoints"]:
            assert len(point["units"]) == 10 and all(len(unit) == 40 for unit in point["units"])
        for logs in [item["ally_logs_start"], item["ally_logs_end"]]:
            assert set(logs) == {"battle_action_event_log", "ally_move_event_log"}

    git("diff", "--check", *rev)
    print(f"S3_1_ENEMY_EVENTS PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; "
          f"{len(added)} additive controller lines in {len(EXPECTED)} functions; observation-only service; "
          f"existing goldens unchanged; {len(cases)} oracle cases (10+{len(cases) - 10} shards)")


if __name__ == "__main__":
    main()
