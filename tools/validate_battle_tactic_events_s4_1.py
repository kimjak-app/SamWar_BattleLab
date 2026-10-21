"""S4-1 tactic event recording: pinned scope, controller delta = additive
recording lines + the strategy dice helpers only, observation-only service,
test-only dice hook, immutable existing goldens/3D/pinned validators, golden
captured on BASE covering every unique-skill effect_type, exact CI wiring.

S4_1_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, hashlib, json, os, re, subprocess

BASE = "608cb77d0d99e9cbefbfecd9ee0f02eb51b6a296"
TIP = os.environ.get("S4_1_SCOPE_TIP", "1d0f5b608a798b4bb32cd1632045be95761d297d")
CONTROLLER = "scripts/battle_web_import_test.gd"
SERVICE = "scripts/battle/services/battle_tactic_event_log_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
GOLDEN = "tests/golden/battle_tactic_baseline_v0.json"
HARNESS = "tests/scripts/support/battle_tactic_oracle_harness.gd"
RUNNER = "tests/scripts/test_battle_tactic_oracle_baseline.gd"
VALIDATOR = "tools/validate_battle_tactic_events_s4_1.py"
REPORT = "agent/BATTLE_S4_1_RESULT_20261021.md"
SKILLS = "data/heroes/generated/hero_unique_skills.json"
OLD_GOLDENS = {
    "tests/golden/battle_attack_baseline_v0.json": "d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
    "tests/golden/battle_move_baseline_v0.json": "b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
    "tests/golden/battle_enemy_turn_baseline_v0.json": "a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7",
    "tests/golden/battle3d_m3_start_v0.json": "c1a1291fa0a2f23307b67316db64a3c663c38d43e15fd904f5b4e4e67921926a",
}
CI_TESTS = ["test_battle_tactic_event_log_service", "test_battle_tactic_oracle_shard_1", "test_battle_tactic_oracle_shard_2",
            "test_battle_tactic_oracle_shard_3", "test_battle_tactic_oracle_shard_4", "test_battle_tactic_dice_hook",
            "test_battle_tactic_event_semantics", "test_battle_tactic_skill_semantics_shard_1", "test_battle_tactic_skill_semantics_shard_2"]
SCRIPTS = CI_TESTS + ["test_battle_tactic_oracle_baseline", "test_battle_tactic_skill_semantics",
                      "support/battle_tactic_oracle_harness", "support/battle_tactic_observer_battle"]
NEW = {SERVICE, SERVICE + ".uid", GOLDEN, VALIDATOR, REPORT}
for stem in SCRIPTS:
    NEW |= {"tests/scripts/%s.gd" % stem, "tests/scripts/%s.gd.uid" % stem}
MODIFIED = {CONTROLLER, WORKFLOW}
KINDS = ["strategy_cast", "status_tick", "skill_cast", "skill_effect", "skill_finished", "reinforcement_arrived"]
LOG = "tactic_event_log."
HEADER = ['var tactic_event_log := preload("res://scripts/battle/services/battle_tactic_event_log_service.gd").new()',
          'var strategy_roll_override: Callable = Callable() # Test-only dice hook (S4-1); game code never sets it.']
# The only non-additive controller change: the two strategy rolls go through helpers.
DICE_LINES = [('\tif randf() <= success_rate:', '\tif _strategy_roll_success(success_rate):'),
              ('\treturn pool[randi() % pool.size()].duplicate(true)', '\treturn pool[_strategy_roll_pool_index(pool.size())].duplicate(true)')]
DICE_FUNCS = {
    "_strategy_roll_success": 'func _strategy_roll_success(success_rate: float) -> bool:\n\tif strategy_roll_override.is_valid():\n'
                              '\t\treturn bool(strategy_roll_override.call("success", success_rate))\n\treturn randf() <= success_rate',
    "_strategy_roll_pool_index": 'func _strategy_roll_pool_index(pool_size: int) -> int:\n\tif strategy_roll_override.is_valid():\n'
                                 '\t\treturn int(strategy_roll_override.call("pool_index", pool_size))\n\treturn randi() % pool_size',
}
# function -> exact recording lines it gains (order preserved)
EXPECTED = {
    "_resolve_strategy": ['\t\ttactic_event_log.record_strategy_cast(caster_state, target_state, success_rate, true, status_id, turns)',
                          '\t\ttactic_event_log.record_strategy_cast(caster_state, target_state, success_rate, false, "", 0)'],
    "_consume_strategy_status_after_unit_action": ['\ttactic_event_log.stage_status_tick(unit_state)', '\ttactic_event_log.emit_staged_status_tick(unit_state)'],
    "_begin_unique_skill_sequence": ['\ttactic_event_log.record_skill_cast(caster_state, plan, executable_skill, selected_target)'],
    "_apply_resolver_skill_plan": [
        '\t\t\t\ttactic_event_log.stage_skill_command(caster_state, target_state)',
        '\t\t\t\ttactic_event_log.record_skill_damage(caster_state, target_state, applied, damage_flag)',
        '\t\t\t\t\ttactic_event_log.record_skill_heal(caster_state, target_state, healed)',
        '\t\t\t\ttactic_event_log.record_skill_status(caster_state, target_state, status_id, status_turns, amount)',
        '\t\t\t\ttactic_event_log.stage_skill_command(caster_state, target_state)',
        '\t\t\t\t\ttactic_event_log.record_staged_cleanse(caster_state, target_state)',
        '\t\t\t\t\t\ttactic_event_log.record_skill_momentum(caster_state, momentum_side, gained)',
        '\t\t\t\t\t\ttactic_event_log.record_skill_momentum(caster_state, momentum_side, -drained)',
        '\t\t\t\t\ttactic_event_log.stage_skill_command(caster_state, target_state)',
        '\t\t\t\t\ttactic_event_log.record_staged_move(caster_state, target_state)'],
    "_finalize_unique_skill_action": ['\ttactic_event_log.record_skill_finished(caster_state, _get_unique_skill_remaining_cooldown_turns(caster_state))'],
    "_try_deploy_reinforce_01_pair": ['\t\ttactic_event_log.record_reinforcement(ally_reinforce_01_unit_state, battle_round, "reinforce_01")',
                                      '\t\ttactic_event_log.record_reinforcement(enemy_reinforce_01_unit_state, battle_round, "reinforce_01")'],
    "_try_deploy_city_reinforce_02_pair": ['\t\ttactic_event_log.record_reinforcement(ally_reinforce_02_unit_state, battle_round, "city_reinforce_02")',
                                           '\t\ttactic_event_log.record_reinforcement(enemy_reinforce_02_unit_state, battle_round, "city_reinforce_02")'],
}
# Exact neighbours: (function, line before the recording line, marker of the recording line)
AFTER = [
    ("_resolve_strategy", '\t\t_append_battle_log("책략 성공! %s에게 %s %d턴!" % [target_state.display_name, status_name, turns])', "success_rate, true"),
    ("_resolve_strategy", '\t\t_append_battle_log("책략 실패!")', "success_rate, false"),
    ("_consume_strategy_status_after_unit_action", '\t\treturn', "stage_status_tick"),
    ("_consume_strategy_status_after_unit_action", '\tunit_state.tick_status_effects()', "emit_staged_status_tick"),
    ("_begin_unique_skill_sequence", '\t\treturn', "record_skill_cast"),
    ("_apply_resolver_skill_plan", '\t\t\t\ttarget_state.apply_status_effect(status_id, status_turns, amount)', "record_skill_status"),
    ("_apply_resolver_skill_plan", '\t\t\t\t\t_apply_resolver_retreat_move(target_state, amount)', "record_staged_move"),
    ("_apply_resolver_skill_plan", '\t\t\t\t\t\tbattle_momentum.spend(momentum_side, drained, String(command.get("status_id", "skill_drain")))', "-drained"),
    ("_apply_resolver_skill_plan", '\t\t\t\t\tif gained > 0:', "gained)"),
    ("_apply_resolver_skill_plan", '\t\t\t\t\tstatus_hits += 1', "record_staged_cleanse"),
    ("_finalize_unique_skill_action", '\t_set_unique_skill_cooldown(caster_state, int(skill_data.get("cooldown_turns", 0)))', "record_skill_finished"),
    ("_try_deploy_reinforce_01_pair", '\t\tarriving_units.append(_get_hero_id_for_unit_state(ally_reinforce_01_unit_state))', "ally_reinforce_01"),
    ("_try_deploy_reinforce_01_pair", '\t\tarriving_units.append(_get_hero_id_for_unit_state(enemy_reinforce_01_unit_state))', "enemy_reinforce_01"),
    ("_try_deploy_city_reinforce_02_pair", '\t\tarriving_units.append(_get_hero_id_for_unit_state(ally_reinforce_02_unit_state))', "ally_reinforce_02"),
    ("_try_deploy_city_reinforce_02_pair", '\t\tarriving_units.append(_get_hero_id_for_unit_state(enemy_reinforce_02_unit_state))', "enemy_reinforce_02"),
]
# Lines that must directly follow a recording line (the record precedes them).
BEFORE = [
    ("_apply_resolver_skill_plan", "record_skill_damage", '\t\t\t\tdamage_hits += 1'),
    ("_apply_resolver_skill_plan", "record_skill_heal", '\t\t\t\t\theal_hits += 1'),
    ("_begin_unique_skill_sequence", "record_skill_cast", '\tpending_unique_skill_plan = plan.duplicate(true)'),
]


def functions(source):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", source, re.M | re.S)}


def harness_cases(harness):
    def const(name):
        return re.findall(r'"(\w+)"', re.search(r"const %s := \[(.*?)\]" % name, harness, re.S).group(1))
    return const("STRATEGY_CASES") + ["K_" + e for e in const("SKILL_EFFECT_TYPES")] + const("OTHER_CASES"), const("SKILL_EFFECT_TYPES")


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
            return (root / path).read_text(encoding="utf-8").replace("\r\n", "\n")
        return git("show", f"{BASE if base else TIP}:{path}").replace("\r\n", "\n")

    def raw(path):
        return (root / path).read_bytes() if live else subprocess.check_output(["git", "-C", str(root), "show", f"{TIP}:{path}"])

    # Scope: whitelist (3D, existing services/tests/harnesses, pinned validators untouched).
    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", *rev).splitlines())
    if live:
        for path in git("ls-files", "--others", "--exclude-standard").splitlines():
            changes.setdefault(path, "A")
    for path, status in changes.items():
        assert (path in MODIFIED and status == "M") or (path in NEW and status == "A"), ("out of scope", status, path)
    for path in NEW:
        assert source(path).strip(), "missing new file " + path
    assert not [p for p in changes if p.startswith("scripts/battle3d/")], "3D files unchanged"
    for path, digest in OLD_GOLDENS.items():
        assert hashlib.sha256(raw(path).replace(b"\r\n", b"\n")).hexdigest() == digest, "existing golden changed " + path

    # Controller: minus recording lines, header lines and the dice helpers, with
    # the two dice lines reverted, the source equals BASE byte for byte.
    old, new = source(CONTROLLER, True), source(CONTROLLER)
    a, b = functions(old), functions(new)
    assert set(b) - set(a) == set(DICE_FUNCS) and set(a) <= set(b), "only the two dice helpers are new functions"
    for name, body in DICE_FUNCS.items():
        assert b[name] == body, "dice helper body exact: " + name
    recording = [line for line in new.split("\n") if line.strip().startswith(LOG)]
    assert len(recording) == sum(len(v) for v in EXPECTED.values()), ("recording line count", len(recording))
    stripped = new
    for name in DICE_FUNCS:
        stripped = stripped.replace("\n\n\n" + b[name], "", 1)
    stripped = "\n".join(line for line in stripped.split("\n") if not (line.strip().startswith(LOG) or line in HEADER))
    for old_line, new_line in DICE_LINES:
        assert new.count(new_line) == 1 and old.count(old_line) == 1, "dice call site " + new_line
        stripped = stripped.replace(new_line, old_line, 1)
    assert stripped == old, "controller minus recording lines and dice helpers == BASE"
    for line in HEADER:
        assert new.count(line) == 1 and line in new[:new.index("\nfunc ")], "header member declared once: " + line
    for name in b:
        lines = [line for line in b[name].split("\n") if line.strip().startswith(LOG)]
        assert lines == EXPECTED.get(name, []), ("recording lines in " + name, lines)
    for name, previous, marker in AFTER:
        body = b[name].split("\n")
        index = [i for i, line in enumerate(body) if line.strip().startswith(LOG) and marker in line]
        assert len(index) == 1 and body[index[0] - 1] == previous, ("recording position", name, marker)
    for name, marker, following in BEFORE:
        body = b[name].split("\n")
        index = [i for i, line in enumerate(body) if line.strip().startswith(LOG) and marker in line]
        assert len(index) == 1 and body[index[0] + 1] == following, ("recording position", name, marker)
    for line in recording:
        assert not re.search(r"\b(randf|randi|randf_range|randi_range|seed|await|create_timer|emit_signal)\b", line), "recording line rolls/awaits: " + line
        assert not re.search(r"\b\w+\s*=[^=]", line.split("(", 1)[0]), "recording line assigns nothing: " + line
    for token in ["randf()", "randi()", "randf_range(", "randi_range("]:
        assert old.count(token) == new.count(token), "random call count unchanged: " + token
    assert "randf()" not in b["_resolve_strategy"] and "randi()" not in b["_roll_strategy_outcome"], "strategy rolls only inside the helpers"
    assert old.count("tactic_event_log") == 0 and old.count("strategy_roll_override") == 0
    for other in ["battle_action_event_log", "ally_move_event_log", "enemy_action_event_log"]:
        assert old.count(other) == new.count(other), "existing log usage unchanged: " + other
    numstat = git("diff", "--numstat", *rev, "--", CONTROLLER).split()
    added_lines, removed_lines = int(numstat[0]), int(numstat[1])
    assert removed_lines == len(DICE_LINES), "only the two dice lines removed"

    # Hook: set only by tests; nothing outside tests references it except the controller.
    tracked = [p for p in git("ls-files").splitlines() + (git("ls-files", "--others", "--exclude-standard").splitlines() if live else [])
               if p.endswith((".gd", ".tscn", ".py", ".tres", ".cfg"))]
    for path in tracked:
        if path.startswith("tests/") or path in (CONTROLLER, VALIDATOR):
            continue
        try:
            text = source(path)
        except (subprocess.CalledProcessError, FileNotFoundError):
            continue
        assert "strategy_roll_override" not in text, "dice hook referenced outside tests: " + path
        if path != SERVICE:
            assert "tactic_event_log" not in text, "tactic log consumer outside the controller (3D must not read it yet): " + path
    assert not re.findall(r"strategy_roll_override\s*=[^=]", new), "controller never sets the hook (declared empty only)"

    # Service: observation-only.
    svc = source(SERVICE)
    code = "\n".join(line.split("#", 1)[0] for line in svc.splitlines())
    assert re.search(r"^extends RefCounted$", code, re.M)
    assert not re.search(r"\b(Node\w*|SceneTree|Tween|await|signal|Callable|get_tree|call_deferred|create_timer|randf|randi|randf_range|randi_range|seed|RandomNumberGenerator)\b", code), "service: no scene/timer/random access"
    members = re.findall(r"^var (\w+)", code, re.M)
    assert members == ["_events", "_sequence", "_staged_tick", "_staged_command"], members
    assert not re.search(r"\b(caster|target|unit)\.\w+\s*(=[^=]|\+=|-=)", code), "service writes no unit field"
    assert not re.search(r"\.(apply_damage|set_grid_cell|apply_status_effect|tick_status_effects|reset_action_flags|heal|erase|clear)\(", code.replace("_events.clear()", "")), "service calls no mutating unit method"
    fields = re.search(r"const FIELDS := \{(.*?)\n\}", svc, re.S).group(1)
    assert re.findall(r'^\t"(\w+)":', fields, re.M) == KINDS, "exact event kinds"
    assert "return _events.duplicate(true)" in svc, "export is a deep copy"

    # CI wiring: previous checks kept, exactly the new checks added in place.
    expected_wf = source(WORKFLOW, True).replace(
        "            tools/validate_battle_enemy_events_s3_1.py\n",
        "            tools/validate_battle_enemy_events_s3_1.py\n            tools/validate_battle_tactic_events_s4_1.py\n", 1).replace(
        "            tests/scripts/test_battle_enemy_turn_event_semantics.gd\n",
        "            tests/scripts/test_battle_enemy_turn_event_semantics.gd\n" + "".join("            tests/scripts/%s.gd\n" % t for t in CI_TESTS), 1)
    assert source(WORKFLOW) == expected_wf, "CI wiring exact"

    # Oracle: every effect_type in the data, golden captured on BASE, exact shards.
    cases, effect_types = harness_cases(source(HARNESS))
    data_types = sorted({s["effect_type"] for s in json.loads(source(SKILLS))["skills"]})
    assert sorted(effect_types) == data_types and len(effect_types) == len(set(effect_types)), "one skill case per effect_type in the data"
    assert len(cases) == len(set(cases)) >= 16
    for i, sl in [(1, "0,13"), (2, "13,26"), (3, "26,39"), (4, "39")]:
        assert source(f"tests/scripts/test_battle_tactic_oracle_shard_{i}.gd") == (
            f'extends "res://tests/scripts/test_battle_tactic_oracle_baseline.gd"\n\nfunc case_labels() -> Array:\n\treturn super.case_labels().slice({sl})\n')
    for i, sl in [(1, "0,20"), (2, "20")]:
        assert source(f"tests/scripts/test_battle_tactic_skill_semantics_shard_{i}.gd") == (
            f'extends "res://tests/scripts/test_battle_tactic_skill_semantics.gd"\n\nfunc case_labels() -> Array:\n\treturn super.case_labels().slice({sl})\n')
    assert f'const BASE_COMMIT := "{BASE}"' in source(RUNNER)
    golden = json.loads(source(GOLDEN))
    assert golden["base_commit"] == BASE
    assert [item["case"] for item in golden["scenarios"]] == cases, "golden covers every case in order"
    for item in golden["scenarios"]:
        assert set(item) == {"case", "spec", "checkpoints", "logs_end"}, "golden holds no tactic events"
        assert [p["stage"] for p in item["checkpoints"]] == ["start", "acted", "settled"]
        for point in item["checkpoints"]:
            assert len(point["units"]) == 10 and all(len(unit) == 40 for unit in point["units"]) and len(point["controller"]) == 12
        assert set(item["logs_end"]) == {"battle_action_event_log", "ally_move_event_log", "enemy_action_event_log"}

    # Report states the same controller delta.
    delta = f"CONTROLLER_DELTA: +{added_lines} -{removed_lines}; recording lines {len(recording)} in {len(EXPECTED)} functions; header lines {len(HEADER)}; dice helpers {len(DICE_FUNCS)}"
    assert delta in source(REPORT), "report states the controller delta: " + delta

    git("diff", "--check", *rev)
    print(f"S4_1_TACTIC_EVENTS PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; {delta}; observation-only service; "
          f"hook set only in tests; {len(cases)} oracle cases ({len(effect_types)} effect_types) golden on BASE; existing goldens unchanged")


if __name__ == "__main__":
    main()
