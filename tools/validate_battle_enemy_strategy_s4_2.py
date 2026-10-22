"""S4-2 enemy strategy (S4-2a) + enemy unique skill spread (S4-2b), engine only.

Pinned scope and exact change shape: no 3D / existing validator / existing
golden change; the controller changes only in the `_resolve_strategy` split,
the enemy AI insertion point after the ATTACK branch, and the two enemy hooks
in `_try_auto_unique_skill_for_actor`, plus new functions and three members;
both flags default to false and are set only under tests/; the new rules
service is pure (static, no state, no random numbers, no await); the nine
existing enemy event kinds are unchanged and exactly one kind is added; the
ally strategy entry points are byte-identical.

S4_2_SCOPE_TIP=<commit> audits BASE..commit; the default is the merged implementation commit (HEAD audits the live worktree; it was the default until the reviewer
re-pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, ast, os, re, subprocess

BASE = "8957b27c9cbf68e7c4b444b7397a2e68edb7ca93"  # chore(battle3d): pin the M4-c1 validator ...
TIP = os.environ.get("S4_2_SCOPE_TIP", "04ce32d26a9a474ee69ac8b2eced01768e73a872")
ENGINE = "scripts/battle_web_import_test.gd"
EVENT_LOG = "scripts/battle/services/battle_enemy_event_log_service.gd"
RULES = "scripts/battle/services/battle_enemy_tactic_rules_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle_enemy_strategy_s4_2.py"
REPORT = "agent/BATTLE_S4_2_RESULT_20261022.md"
GOLDENS_NEW = ["tests/golden/battle_enemy_strategy_base_v0.json", "tests/golden/battle_enemy_skill_spread_base_v0.json"]
SUPPORT = ["tests/scripts/support/battle_enemy_strategy_oracle_harness.gd", "tests/scripts/support/battle_enemy_strategy_observer_battle.gd",
           "tests/scripts/support/battle_enemy_rules_flags_on_battle.gd", "tests/scripts/support/battle_enemy_skill_seam_battle.gd",
           "tests/scripts/support/battle_enemy_skill_spread_observer_battle.gd"]
TEST_BASES = ["tests/scripts/test_battle_enemy_strategy_base_parity.gd", "tests/scripts/test_battle_enemy_rules_ally_parity.gd"]
CI_TESTS = ["tests/scripts/test_battle_enemy_strategy_base_parity_shard_1.gd", "tests/scripts/test_battle_enemy_strategy_base_parity_shard_2.gd",
            "tests/scripts/test_battle_enemy_strategy_base_parity_shard_3.gd", "tests/scripts/test_battle_enemy_rules_ally_parity_shard_1.gd",
            "tests/scripts/test_battle_enemy_rules_ally_parity_shard_2.gd", "tests/scripts/test_battle_enemy_rules_ally_parity_shard_3.gd",
            "tests/scripts/test_battle_enemy_rules_ally_parity_shard_4.gd", "tests/scripts/test_battle_enemy_strategy_behavior.gd",
            "tests/scripts/test_battle_enemy_skill_spread_base_parity.gd", "tests/scripts/test_battle_enemy_skill_spread_behavior.gd",
            "tests/scripts/test_battle_enemy_tactic_rules_service.gd"]
NEW = {RULES, VALIDATOR, REPORT, *GOLDENS_NEW, *SUPPORT, *TEST_BASES, *CI_TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
MODIFIED = {ENGINE, EVENT_LOG, WORKFLOW}
FLAGS = ["enemy_strategy_enabled", "enemy_skill_spread_enabled"]
NEW_FUNCTIONS = {"_resolve_strategy_effect", "_try_enemy_strategy_for_actor", "_get_enemy_strategy_target_for_actor", "_resolve_enemy_strategy",
                 "_should_enemy_yield_unique_skill", "_get_enemy_skill_spread_order", "_get_enemy_skill_spread_entry", "_record_enemy_unique_skill_use"}
CHANGED_FUNCTIONS = {"_resolve_strategy", "_play_enemy_ai_for_actor", "_try_auto_unique_skill_for_actor"}
ALLY_UNCHANGED = ["_on_strategy_button_pressed", "_try_use_strategy_on_target", "_can_use_strategy", "_get_strategy_range", "_get_strategy_tier",
                  "_get_strategy_outcome_pool", "_get_strategy_targets", "_get_strategy_success_rate", "_roll_strategy_outcome", "_strategy_roll_success",
                  "_strategy_roll_pool_index", "_mark_ally_unit_acted", "_run_auto_action_for_active_ally_once", "_mark_enemy_unit_acted",
                  "_advance_enemy_turn_or_return_to_ally", "_can_actor_use_unique_skill", "_is_unique_skill_high_value_for_actor",
                  "_score_unique_skill_plan_for_actor", "_get_enemy_ai_target_state_from_candidates", "_get_next_available_enemy_ai_actor",
                  "_persist_battle_resume_snapshot", "reset_demo_state", "_play_enemy_actor_basic_attack_or_wait_after_move"]
OLD_KINDS = ["enemy_turn_started", "enemy_actor_selected", "enemy_moved", "enemy_attack_resolved", "enemy_waited", "enemy_action_completed",
             "enemy_skill_used", "round_started", "battle_ended"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|\bshuffle\s*\(|pick_random"


def functions(code):
    # Signatures may span several lines (e.g. `_score_unique_skill_plan_for_actor`).
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\(.*?(?=^func |\Z)", code, re.M | re.S)}


def toplevel(code):
    # Class-level lines (outside function bodies).
    out, inside = [], False
    for line in code.splitlines():
        if line.startswith("func "):
            inside = True
            continue
        if inside and (line.startswith("\t") or not line.strip()):
            continue
        inside = False
        out.append(line)
    return [x for x in out if x.strip()]


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() if not line.lstrip().startswith("##") else "" for line in source.splitlines())


def gd_fields(source):
    m = re.search(r"^const FIELDS := (\{.*?\n\})", source, re.M | re.S)
    assert m, "FIELDS table"
    body = "\n".join(line.split("#", 1)[0] for line in m.group(1).splitlines())
    return list(ast.literal_eval(body).items())


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
    assert not [p for p in changes if p.startswith("scripts/battle3d/")], "3D files unchanged"
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    assert not [p for p in changes if p.startswith("tests/golden/") and p not in GOLDENS_NEW], "existing goldens unchanged"
    import json
    for p in GOLDENS_NEW:
        assert json.loads(raw(p))["base_commit"] == BASE, "new golden captured on BASE: " + p
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    # Controller: exact change shape.
    new_src, old_src = text(ENGINE), text(ENGINE, True)
    new, old = strip_comments(new_src), strip_comments(old_src)
    f, of = functions(new), functions(old)
    assert set(f) - set(of) == NEW_FUNCTIONS, "new functions: " + str((set(f) - set(of)) ^ NEW_FUNCTIONS)
    assert set(of) <= set(f), "no function removed"
    changed = {n for n in of if f[n] != of[n]}
    assert changed == CHANGED_FUNCTIONS, "only the allowed functions change: " + str(changed ^ CHANGED_FUNCTIONS)
    top_added = [x for x in toplevel(new) if x not in toplevel(old)]
    assert top_added == ['const BattleEnemyTacticRulesServiceScript := preload("res://scripts/battle/services/battle_enemy_tactic_rules_service.gd")',
                         "var enemy_strategy_enabled := false", "var enemy_skill_spread_enabled := false",
                         "var enemy_skill_last_use_round := {}"], "class-level additions: " + str(top_added)
    assert [x for x in toplevel(old) if x not in toplevel(new)] == [], "no class-level line removed"
    # _resolve_strategy: old body == new ally body with the core call expanded back.
    core = f["_resolve_strategy_effect"].split("\n", 1)[1]
    expanded = f["_resolve_strategy"].replace("\t_resolve_strategy_effect(caster_state, target_state)\n", core.rstrip("\n") + "\n\n")
    norm = lambda s: re.sub(r"\n\s*\n", "\n", s).strip()
    assert norm(expanded) == norm(of["_resolve_strategy"]), "ally _resolve_strategy == shared core + the unchanged ally follow-up (same order)"
    for token in ["_mark_ally_unit_acted", "_mark_enemy_unit_acted", "_set_phase", "_play_enemy_turn_demo", "side", "_show_unit_closeup_for_ally", "floating_ally"]:
        assert token not in core, "the shared core has no side-specific follow-up: " + token
    # Enemy AI: two lines after the ATTACK branch, nothing else.
    ai_old = of["_play_enemy_ai_for_actor"]
    attack_block = '\tif action_reason == "ATTACK":\n\t\t_play_enemy_actor_basic_attack_from_current_cell(enemy_actor_state, target_state)\n\t\treturn\n'
    assert f["_play_enemy_ai_for_actor"] == ai_old.replace(attack_block, attack_block + "\tif _try_enemy_strategy_for_actor(enemy_actor_state, decision_plan):\n\t\treturn\n"), "enemy strategy inserted only after the ATTACK branch (D order)"
    # Skill hooks: the yield check after the value checks, the history record after record_skill.
    sk_old = of["_try_auto_unique_skill_for_actor"]
    a = "\tif not require_high_value and not _is_unique_skill_fallback_value_for_actor(caster_state, skill_data, target_state):\n\t\treturn false\n"
    b = "\tenemy_action_event_log.record_skill(caster_state, skill_data, target_state)\n"
    expect_sk = sk_old.replace(a, a + "\tif _should_enemy_yield_unique_skill(caster_state, skill_data, target_state):\n\t\treturn false\n").replace(b, b + "\t_record_enemy_unique_skill_use(caster_state)\n")
    assert f["_try_auto_unique_skill_for_actor"] == expect_sk, "skill spread hooks only"
    for name in ALLY_UNCHANGED:
        assert f[name] == of[name], "unchanged: " + name

    # Flags: default false, set only under tests/.
    for flag in FLAGS:
        assert re.search(r"^var " + flag + r" := false\b", new, re.M), "flag default false: " + flag
        assert len(re.findall(r"\b" + flag + r"\s*=(?!=)", new)) == 0, "the engine never assigns " + flag
    for p in git("ls-files", "scripts", "scenes", "*.gd").decode().splitlines() + [x for x in changes if live and x.endswith(".gd")]:
        if p.startswith("tests/") or not p.endswith(".gd") or not (root / p).exists() and live:
            continue
        body = text(p)
        for flag in FLAGS:
            if p == ENGINE:
                continue
            assert flag not in body, "flag referenced outside tests: " + p

    # Enemy strategy and spread functions: guards, no momentum for strategy, no random numbers.
    strat = f["_try_enemy_strategy_for_actor"]
    assert strat.index("if not enemy_strategy_enabled:") < strat.index("_resolve_enemy_strategy("), "strategy behind its flag"
    assert 'enemy_actor_state.side != "enemy"' in strat and "STRATEGY_BASIC_INTELLIGENCE" in strat and "_is_unit_confused(enemy_actor_state)" in strat and "_has_enemy_unit_acted(enemy_actor_state)" in strat
    target = f["_get_enemy_strategy_target_for_actor"]
    assert "_get_strategy_targets(enemy_actor_state)" in target and "_get_strategy_outcome_pool(enemy_actor_state)" in target and "is_strategy_target_blocked" in target
    assert "_get_enemy_ai_target_state_from_candidates(enemy_actor_state, candidates)" in target, "existing enemy target selection reused"
    enemy_post = f["_resolve_enemy_strategy"]
    order = ["enemy_action_event_log.record_strategy(caster_state, target_state)", "_resolve_strategy_effect(caster_state, target_state)",
             "_mark_enemy_unit_acted(caster_state)", "_advance_enemy_turn_or_return_to_ally()"]
    assert [enemy_post.index(x) for x in order] == sorted(enemy_post.index(x) for x in order), "attempt -> effect -> close -> advance"
    for token in ["_mark_ally_unit_acted", "_set_phase", "_play_enemy_turn_demo", "_show_unit_closeup_for_ally", "_update_ally_ready_frames", "floating_ally"]:
        assert token not in enemy_post, "no ally follow-up in the enemy strategy: " + token
    for name in ["_try_enemy_strategy_for_actor", "_get_enemy_strategy_target_for_actor", "_resolve_enemy_strategy"]:
        assert "battle_momentum" not in f[name], "strategy costs no momentum: " + name
    for name in NEW_FUNCTIONS:
        assert not re.search(RANDOM, f[name]), "no random number in " + name
    assert "randf()" not in f["_resolve_strategy_effect"] and "_strategy_roll_success(success_rate)" in f["_resolve_strategy_effect"] and "_roll_strategy_outcome(caster_state)" in f["_resolve_strategy_effect"], "dice only through the existing helpers"
    yield_fn = f["_should_enemy_yield_unique_skill"]
    assert 'if not enemy_skill_spread_enabled or caster_state == null or caster_state.side != "enemy":\n\t\treturn false' in yield_fn, "spread is enemy-only and behind its flag"
    assert "BattleEnemyTacticRulesServiceScript.should_yield_unique_skill(actor, others, battle_momentum.get_value(\"enemy\"))" in yield_fn
    assert "_can_actor_use_unique_skill(unit_state)" in yield_fn and "_has_enemy_unit_acted(unit_state)" in yield_fn, "candidates: unacted enemies that can use their skill"
    assert 'if enemy_skill_spread_enabled and caster_state != null and caster_state.side == "enemy":' in f["_record_enemy_unique_skill_use"]
    assert len(re.findall(r"enemy_skill_last_use_round\[", new)) == 1, "history written in one place"
    assert "enemy_skill_last_use_round" not in f["_persist_battle_resume_snapshot"], "history not in the resume snapshot"

    # New rules service: pure.
    rules = text(RULES)
    rules_code = strip_comments(rules)
    assert rules_code.startswith("extends RefCounted"), "RefCounted service"
    assert not re.search(r"^var ", rules_code, re.M), "no state"
    assert all(line.startswith("static func ") for line in re.findall(r"^\w*\s*func .*$", rules_code, re.M)), "static functions only"
    assert not re.search(RANDOM + r"|\bawait\b|create_timer|get_tree|Engine\.|\.set\(|BattleUnitState", rules_code), "pure: no random, await, tree, setters or unit objects"
    assert not re.search(r"\b\w+\.\w+\s*(?:[+\-*/]?=)(?!=)", rules_code), "no field writes"
    assert "const RECENT_USE_PENALTY_ONE_ROUND := 40" in rules and "const RECENT_USE_PENALTY_TWO_ROUNDS := 20" in rules and "const HIGH_VALUE_SKILL_SCORE := 130" in rules, "penalty constants and the unchanged threshold"
    assert ">= 130" in of["_is_unique_skill_high_value_for_actor"], "controller threshold still 130"
    rf = functions(rules_code.replace("static func ", "func "))
    pinned = {
        "adjusted_skill_score": "\treturn raw_score - recent_use_penalty(current_round, last_use_round)",
        "recent_use_penalty": "\tif last_use_round == NO_USE_ROUND:\n\t\treturn 0\n\tmatch current_round - last_use_round:\n\t\t1:\n\t\t\treturn RECENT_USE_PENALTY_ONE_ROUND\n\t\t2:\n\t\t\treturn RECENT_USE_PENALTY_TWO_ROUNDS\n\treturn 0",
        "ranks_ahead": "\tif a.adjusted != b.adjusted:\n\t\treturn a.adjusted > b.adjusted\n\tif a.last_use_round != b.last_use_round:\n\t\treturn a.last_use_round < b.last_use_round\n\treturn a.order < b.order",
        "should_yield_unique_skill": "\tfor other in others:\n\t\tif other.raw < HIGH_VALUE_SKILL_SCORE:\n\t\t\tcontinue\n\t\tif not ranks_ahead(other, actor):\n\t\t\tcontinue\n\t\tif momentum - actor.cost < other.cost:\n\t\t\treturn true\n\treturn false",
        "is_strategy_target_blocked": "\tfor status_id in pool_status_ids:\n\t\tif target_status_ids.has(status_id):\n\t\t\treturn true\n\treturn false",
        "can_enemy_use_strategy": "\treturn alive and not acted and not confused and intelligence >= basic_intelligence",
        "keeps_plan_target": "\treturn not plan_target_id.is_empty() and candidate_ids.has(plan_target_id)",
    }
    assert set(rf) == set(pinned), "rules service functions: " + str(set(rf) ^ set(pinned))
    for name, body in pinned.items():
        indented = "\n".join(line for line in rf[name].split("\n")[1:] if line.startswith("\t"))
        assert norm(indented) == norm(body), "rules body pinned (design §3.2/§4.1): " + name

    # Event log: the nine kinds unchanged, one kind added.
    ev_new, ev_old = text(EVENT_LOG), text(EVENT_LOG, True)
    fields_new, fields_old = gd_fields(ev_new), gd_fields(ev_old)
    assert [k for k, _ in fields_old] == OLD_KINDS and fields_new[:9] == fields_old, "existing nine kinds: same names, fields and order"
    assert fields_new[9:] == [("enemy_strategy_used", ["unit_id", "target_id"])], "exactly one new kind"
    fn_new, fn_old = functions(strip_comments(ev_new)), functions(strip_comments(ev_old))
    assert set(fn_new) - set(fn_old) == {"record_strategy"} and {n for n in fn_old if fn_new[n] != fn_old[n]} == {"_valid_fields"}
    v = fn_old["_valid_fields"].replace('\t\t"enemy_moved":\n', '\t\t"enemy_strategy_used":\n\t\t\treturn _id(fields.target_id)\n\t\t"enemy_moved":\n', 1)
    assert fn_new["_valid_fields"] == v, "_valid_fields: one branch added for the new kind"
    assert norm(fn_new["record_strategy"].split("\n", 1)[1]) == norm('\tif caster == null or caster.side != "enemy" or target == null:\n\t\treturn {}\n'
        '\treturn emit("enemy_strategy_used", {"unit_id": caster.unit_id, "target_id": target.unit_id})'), "record_strategy pinned (both fields)"

    git("diff", "--check", *rev)
    print(f"S4_2_ENEMY_STRATEGY validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; 3D/validators/existing goldens unchanged; "
          f"controller: {len(NEW_FUNCTIONS)} new functions, {len(CHANGED_FUNCTIONS)} allowed changes (strategy split, AI insertion, skill hooks); "
          f"flags default false and set only in tests; pure rules service; nine event kinds unchanged + enemy_strategy_used")


if __name__ == "__main__":
    main()
