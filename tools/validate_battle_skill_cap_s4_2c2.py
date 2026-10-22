"""S4-2c addendum: enemy unique skill use cap (engine only).

A deciding enemy whose use count is 2+ above the lowest count of the other live
enemies holding a unique skill does not use it, unless the enemy side has used
no unique skill for two rounds (round - L >= 3). Behind `enemy_skill_cap_enabled`
(default false). Pinned scope: changed files, 3D / existing goldens / existing
pinned validators unchanged, the rules service pure (S4-2a/S4-2c rules
byte-identical), the controller change limited to the cap guard, the yield
candidate filter and the use record, no new random number.

S4_2C2_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "d2cd2540291ab2d96fc5f876fcdac7e1d28b90d7"  # feat(battle): ... rotation order (S4-2c)
TIP = os.environ.get("S4_2C2_SCOPE_TIP", "77b911c3748509c1d827e57c4e96042990b3e9bd")
ENGINE = "scripts/battle_web_import_test.gd"
RULES = "scripts/battle/services/battle_enemy_tactic_rules_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle_skill_cap_s4_2c2.py"
OLD_VALIDATOR = "tools/validate_battle_skill_rotation_s4_2c.py"  # re-pinned to BASE (its default TIP only)
REPORT = "agent/BATTLE_S4_2C_RESULT_20261022.md"
SUPPORT = ["tests/scripts/support/battle_enemy_skill_cap_harness.gd", "tests/scripts/support/battle_enemy_skill_cap_observer_battle.gd",
           "tests/scripts/test_battle_enemy_skill_cap_behavior.gd"]
NEW = {VALIDATOR} | set(SUPPORT) | {p + ".uid" for p in SUPPORT}
MODIFIED = {ENGINE, RULES, WORKFLOW, OLD_VALIDATOR, REPORT, "tests/scripts/test_battle_enemy_tactic_rules_service.gd"}
CI_ADDED = [VALIDATOR, "tests/scripts/test_battle_enemy_skill_cap_behavior.gd"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|\bshuffle\s*\(|pick_random"
CHANGED = {"_try_auto_unique_skill_for_actor", "_should_enemy_yield_unique_skill", "_record_enemy_unique_skill_use"}
ADDED_FUNCS = {"_is_enemy_skill_capped", "_get_enemy_unique_skill_holders"}
ADDED_VARS = ["var enemy_skill_cap_enabled := false", "var enemy_skill_use_count := {}", "var enemy_skill_last_any_use_round := -1"]


def functions(code):
    # Signature line + indented body only (class-level lines after a function are not part of it).
    out = {}
    for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |\Z)", code, re.M | re.S):
        lines = m.group(0).split("\n")
        out[m.group(1)] = "\n".join([lines[0]] + [x for x in lines[1:] if x.startswith("\t")])
    return out


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


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
    assert not [p for p in changes if p.startswith("scripts/battle3d/")], "3D unchanged"
    assert not [p for p in changes if p.startswith("tests/golden/")], "goldens unchanged"
    assert not [p for p in changes if p.startswith("tools/") and p not in (VALIDATOR, OLD_VALIDATOR)], "existing (pinned) validators unchanged"
    old_validator_diff = [x for x in git("diff", "--unified=0", *rev, "--", OLD_VALIDATOR).decode().splitlines()
                          if x[:1] in "+-" and not x.startswith(("+++", "---"))]
    assert [x for x in old_validator_diff if x.startswith("+TIP")] and all(not x[1:].strip() or x[1:].startswith(("TIP", "S4_2C_SCOPE_TIP", "re-pins", "Pinned", "audited", "audits"))
                                                                       for x in old_validator_diff), ("old validator: TIP pin and its note only", old_validator_diff)
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert all(any(c in a for c in CI_ADDED) for a in added) and all(any(c in a for a in added) for c in CI_ADDED), added

    # Rules service: earlier rules byte-identical, cap pinned, pure.
    rules = strip_comments(text(RULES))
    old_rules = strip_comments(text(RULES, True))
    assert rules.startswith(old_rules.rstrip()), "S4-2a/S4-2c rules unchanged (cap appended only)"
    assert rules.startswith("extends RefCounted") and not re.search(r"^var ", rules, re.M), "no state"
    assert all(x.startswith("static func ") for x in re.findall(r"^\w*\s*func .*$", rules, re.M)), "static functions only"
    assert not re.search(RANDOM + r"|\bawait\b|create_timer|get_tree|Engine\.|\.set\(|BattleUnitState", rules), "pure"
    assert "const SKILL_CAP_USE_GAP := 2" in rules and "const SKILL_CAP_RELEASE_IDLE_ROUNDS := 2" in rules, "cap constants"
    rf = functions(rules)
    body = "\n".join(x for x in rf["is_skill_capped"].split("\n")[1:] if x.strip())
    assert body == ("\tif other_counts.is_empty():\n\t\treturn false\n\tvar lowest: int = other_counts.min()\n"
                    "\tif own_count - lowest < SKILL_CAP_USE_GAP:\n\t\treturn false\n"
                    "\tif last_any_use_round != NO_USE_ROUND and battle_round - last_any_use_round > SKILL_CAP_RELEASE_IDLE_ROUNDS:\n\t\treturn false\n"
                    "\treturn true"), "cap: own - min(others) >= 2, released when round - L >= 3"

    # Controller.
    code, old = strip_comments(text(ENGINE)), strip_comments(text(ENGINE, True))
    f, of = functions(code), functions(old)
    assert set(f) - set(of) == ADDED_FUNCS and not set(of) - set(f), "functions added: " + str(set(f) ^ set(of))
    changed = {n for n in of if f[n] != of[n]}
    assert changed == CHANGED, "only the cap guard, the yield candidate filter and the use record change: " + str(changed)
    top = lambda s: [x for x in s.splitlines() if x and not x.startswith(("\t", " ", "func "))]
    new_top = [x for x in top(code) if x not in top(old)]
    assert [x for x in top(old) if x not in top(code)] == [] and [x.split(" #")[0].rstrip() for x in new_top] == ADDED_VARS, ("class-level: three new members", new_top)
    for flag in ["enemy_strategy_enabled", "enemy_skill_spread_enabled", "enemy_skill_cap_enabled"]:
        assert re.search(r"^var " + flag + r" := false\b", code, re.M), "flag default false: " + flag
    # Guard right before the yield check, nothing else touched in the skill path.
    removed = [x for x in of["_try_auto_unique_skill_for_actor"].split("\n") if x not in f["_try_auto_unique_skill_for_actor"].split("\n")]
    assert not removed, removed
    assert "\tif _is_enemy_skill_capped(caster_state):\n\t\treturn false\n\tif _should_enemy_yield_unique_skill(" in f["_try_auto_unique_skill_for_actor"], "cap before the yield"
    assert f["_should_enemy_yield_unique_skill"].replace("\t\tif _is_enemy_skill_capped(unit_state):\n\t\t\tcontinue\n", "", 1) == of["_should_enemy_yield_unique_skill"], "capped enemy: not a rotation candidate"
    cap = f["_is_enemy_skill_capped"]
    assert 'if not enemy_skill_cap_enabled or caster_state == null or caster_state.side != "enemy":\n\t\treturn false' in cap, "enemy-only, behind the flag"
    assert "_get_enemy_unique_skill_holders()" in cap and "unit_state != caster_state" in cap and "BattleEnemyTacticRulesServiceScript.is_skill_capped(" in cap
    holders = f["_get_enemy_unique_skill_holders"]
    assert '_get_alive_deployed_unit_states_for_side("enemy")' in holders and "is_alive()" in holders and "unique_skill_definition.is_empty()" in holders
    rec = f["_record_enemy_unique_skill_use"]
    assert '(enemy_skill_spread_enabled or enemy_skill_cap_enabled) and caster_state != null and caster_state.side == "enemy"' in rec, "enemy-only record"
    assert "enemy_skill_use_count[caster_state.unit_id] = int(enemy_skill_use_count.get(caster_state.unit_id, 0)) + 1" in rec and "enemy_skill_last_any_use_round = battle_round" in rec
    assert code.count("_record_enemy_unique_skill_use(") == old.count("_record_enemy_unique_skill_use("), "single use-confirmation point kept"
    for name in CHANGED | ADDED_FUNCS:
        assert not re.search(RANDOM, f[name]), "no random number in " + name
    git("diff", "--check", *rev)
    print(f"S4_2C2_SKILL_CAP validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; cap pinned (own - min(others) >= 2, "
          f"released after two idle rounds); cap before the yield; capped not a rotation candidate; flags default false; 3D/goldens/validators unchanged")


if __name__ == "__main__":
    main()
