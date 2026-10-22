"""M4-c2 3D enemy unique skill replay: pinned scope, zero engine/service/adapter
diff, the twelve M4-c1 write calls unchanged and no new read, the fourth cursor
kinds unchanged, enemy-cast skill_* held until the replay reaches that caster's
enemy_skill_used (shown as they arrive afterwards), enemy-cast strategy_cast held
with that enemy's status ticks until its replayed enemy_action_completed (log
order), held events never dropped, enemy display through the M4-c1 indicators
with the "적 " prefix, its own lists and label meta, the ally momentum note
untouched, no random / dice hook.

M4C2_SCOPE_TIP=<commit> audits BASE..commit; the default is the merged
implementation commit. M4C2_SCOPE_TIP=HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "b83a40216649e802e0e4471d376303e901256261"  # chore(battle): tidy the S4-2 validator scope note (S4-2 merged)
TIP = os.environ.get("M4C2_SCOPE_TIP", "2b2340d7cf41bd8ef0566a7f59ec8c50a410b4c2")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m4c2_enemy_skill.py"
REPORT = "agent/BATTLE3D_M4C2_RESULT_20261022.md"
HARNESS = "tests/scripts/support/battle3d_enemy_skill_harness.gd"
CI_TESTS = ["tests/scripts/test_battle3d_enemy_skill_equivalence.gd", "tests/scripts/test_battle3d_enemy_skill_default_round.gd",
            "tests/scripts/test_battle3d_enemy_skill_mixed_log.gd"]
NEW = {VALIDATOR, REPORT, HARNESS, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {PLAY, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd",
                      "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd", "tests/golden/", "tests/scripts/support/battle3d_skill_harness.gd",
                      "tests/scripts/test_battle3d_skill_", "tests/scripts/test_battle3d_enemy_turn", "tests/scripts/test_battle3d_strategy_"]
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
            "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
            "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target"}
KINDS = ["strategy_cast", "status_tick", "reinforcement_arrived", "skill_cast", "skill_effect", "skill_finished"]
NEW_FUNCTIONS = {"_present_enemy_skill_event", "_open_enemy_skill", "_close_enemy_skill"}
CHANGED_FUNCTIONS = {"_consume_tactic_events", "_present_enemy_event", "_consume_enemy_events", "_finish_enemy_summary", "_skill_line", "_skill_label",
                     "_present_skill_event", "_present_skill_effect"}
NEW_MEMBERS = {"pending_enemy_skills", "enemy_skill_open", "pending_enemy_strategies", "enemy_skill_presentations", "enemy_skill_texts",
               "enemy_skill_leftovers", "presenting_enemy_skill"}


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
    for p in git("ls-files", "scripts/battle3d").decode().splitlines():
        if p.endswith(".gd"):
            assert not re.search(r"\b(randf|randi|randf_range|randi_range|RandomNumberGenerator)\b|\bseed\s*\(|strategy_roll_override", strip_comments(text(p))), "3D random/hook: " + p

    code, old = strip_comments(text(PLAY)), strip_comments(text(PLAY, True))
    calls, old_calls = re.findall(r'engine\.call\("([^"\n]+)"', code), re.findall(r'engine\.call\("([^"\n]+)"', old)
    assert sorted(calls) == sorted(old_calls) and COMMANDS <= set(calls), "no new engine call (twelve writes unchanged)"
    assert sorted(re.findall(r'engine\.get\("([^"\n]+)"\)', code)) == sorted(re.findall(r'engine\.get\("([^"\n]+)"\)', old)), "no new engine read"
    f, of = functions(code), functions(old)
    assert set(f) - set(of) == NEW_FUNCTIONS, "new functions: " + str((set(f) - set(of)) ^ NEW_FUNCTIONS)
    changed = {n for n in of if f.get(n) != of[n]}
    assert changed <= CHANGED_FUNCTIONS, "only listed functions change: " + str(changed - CHANGED_FUNCTIONS)
    members = lambda s: set(re.findall(r"^(?:var|const) (\w+)", s, re.M))
    assert members(code) - members(old) == NEW_MEMBERS, "new members: " + str(members(code) - members(old))

    consume = f["_consume_tactic_events"]
    kinds = [k for line in re.findall(r'^\t\t\t("[^\n]*"):', consume, re.M) for k in re.findall(r'"(\w+)"', line)]
    assert kinds == KINDS and re.search(r"^\t\t\t_:\n\t\t\t\tpass", consume, re.M), "cursor kinds unchanged: " + str(kinds)
    assert ('\t\t\t\tif _skill_caster_side(event) == "ally": _present_skill_event(event)\n'
            '\t\t\t\telif enemy_skill_open.has(event.caster_id): _present_enemy_skill_event(event)\n'
            '\t\t\t\telse: pending_enemy_skills[event.caster_id] = pending_enemy_skills.get(event.caster_id,[]) + [event]') in consume, "enemy skill_*: hold until the replay opens the caster"
    assert ('if _skill_caster_side(event) == "enemy" and _enemy_completion_pending(event.caster_id):\n'
            '\t\t\t\t\tpending_enemy_strategies[event.caster_id] = pending_enemy_strategies.get(event.caster_id,[]) + [event]') in consume, "enemy strategy_cast held until its completion"
    assert not re.search(r"\bbreak\b|\breturn\b|tactic_cursor\s*-=", consume), "the cursor never waits"
    enemy_event = f["_present_enemy_event"]
    used = enemy_event[enemy_event.index('"enemy_skill_used":'):enemy_event.index('"enemy_action_completed":')]
    assert "_open_enemy_skill(event.unit_id)" in used
    done = enemy_event[enemy_event.index('"enemy_action_completed":'):enemy_event.index('"round_started":')]
    assert done.index("_close_enemy_skill(event.unit_id)") < done.index("_flush_enemy_ticks(event.unit_id)"), "close (held strategy + ticks in log order) at the replayed completion"
    opener, closer = f["_open_enemy_skill"], f["_close_enemy_skill"]
    assert "\tfor event in pending_enemy_skills.get(caster_id,[]): _present_enemy_skill_event(event)\n" in opener, "held events shown in arrival (log) order"
    assert "enemy_skill_open[caster_id] = true" in opener and opener.index("_present_enemy_skill_event(event)") < opener.index("pending_enemy_skills.erase(caster_id)")
    assert "pending_enemy_skills.erase" not in closer and "enemy_skill_leftovers.append" in closer, "held skill events are never dropped (left over is recorded)"
    assert "held.sort_custom(func(a, b): return a.sequence < b.sequence)" in closer and "_present_strategy_cast(event)" in closer and "_present_status_tick(event)" in closer
    assert code.count("pending_enemy_skills.erase") == 1, "skill holds only cleared after being shown"
    pe = f["_present_enemy_skill_event"]
    assert [x.rstrip() for x in pe.split("\n")[1:] if x.strip()][:3] == ["\tpresenting_enemy_skill = true", "\t_present_skill_event(event)", "\tpresenting_enemy_skill = false"], "the M4-c1 indicators, flagged"
    line = f["_skill_line"]
    assert 'line = "적 " + line' in line and "enemy_skill_texts.append(line)" in line and line.index("if presenting_enemy_skill:") < line.index("skill_texts.append(line)")
    assert 'label.set_meta("enemy_skill_label" if presenting_enemy_skill else "skill_label",unit_id)' in f["_skill_label"]
    assert len(re.findall(r"momentum_note = ", code)) == 2 and all(re.search(r"if not presenting_enemy_skill: momentum_note = ", x) for x in [f["_present_skill_event"], f["_present_skill_effect"]]), "enemy skills never touch the ally momentum note"
    assert "if presenting_enemy_skill: enemy_skill_presentations.append(event.duplicate(true))" in f["_present_skill_event"]
    assert re.search(r'"enemy_action_completed":\n\t\t\t\tif not enemy_slot\.is_empty\(\):[ ]*\n\t\t\t\t\tenemy_slot\.append\(event\)\n\t\t\t\t\t_finish_enemy_summary\(enemy_slot\)', f["_consume_enemy_events"]), "a completion after battle_ended makes no second summary"
    assert 'slot.any(func(e): return e.kind == "enemy_skill_used")' in f["_finish_enemy_summary"], "skill troop changes kept in the slot summary"
    git("diff", "--check", *rev)
    print(f"M4C2_ENEMY_SKILL validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter diff 0; twelve writes and reads unchanged; "
          f"cursor kinds {KINDS}; enemy skill_* held until its replayed enemy_skill_used, enemy strategy_cast with its completion, never dropped")


if __name__ == "__main__":
    main()
