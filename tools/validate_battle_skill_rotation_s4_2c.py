"""S4-2c enemy unique skill rotation (engine only).

The S4-2b recent-use penalty (40/20, `recent_use_penalty`, `adjusted_skill_score`)
is removed and replaced by a rotation order (oldest last use first, never used
first; then raw score; then actor order); a yield happens only when two or more
candidates (the deciding actor + others with raw >= 130) cannot all be paid by
the shared momentum. Pinned scope: changed files, 3D / existing goldens /
existing pinned validators unchanged, the rules service pure, both flags still
default false, the controller change limited to the spread call site, the S4-2
strategy code byte-identical.

Pinned to the S4-2c implementation commit e347ef4 (the S4-2c addendum on top is
audited by tools/validate_battle_skill_cap_s4_2c2.py); S4_2C_SCOPE_TIP=HEAD
audits the live worktree instead.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "b83a40216649e802e0e4471d376303e901256261"  # docs(battle): tidy the S4-2 validator scope note
TIP = os.environ.get("S4_2C_SCOPE_TIP", "e347ef4cc1339f59038f499490e32aab5aac6720")  # feat(battle): ... rotation order (S4-2c)
ENGINE = "scripts/battle_web_import_test.gd"
RULES = "scripts/battle/services/battle_enemy_tactic_rules_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle_skill_rotation_s4_2c.py"
REPORT = "agent/BATTLE_S4_2C_RESULT_20261022.md"
NEW = {VALIDATOR, REPORT, "tests/scripts/support/battle_enemy_skill_rotation_harness.gd", "tests/scripts/support/battle_enemy_skill_rotation_harness.gd.uid"}
# Spread-only tests rewritten for the new rule (allowed by the instruction), and the pure-rule test's spread part.
MODIFIED = {ENGINE, RULES, WORKFLOW, "tests/scripts/test_battle_enemy_skill_spread_behavior.gd", "tests/scripts/test_battle_enemy_tactic_rules_service.gd"}
CI_ADDED = [VALIDATOR]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|\bshuffle\s*\(|pick_random"
CALL_SITE = {"_should_enemy_yield_unique_skill", "_get_enemy_skill_spread_entry"}


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
    assert not [p for p in changes if p.startswith("tests/golden/")], "goldens unchanged (the spread golden is the flag-off parity)"
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing (pinned) validators unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted(CI_ADDED), added

    # Rules service: penalty removed, rotation pinned, pure.
    rules = strip_comments(text(RULES))
    old_rules = strip_comments(text(RULES, True))
    for gone in ["recent_use_penalty", "adjusted_skill_score", "RECENT_USE_PENALTY_ONE_ROUND", "RECENT_USE_PENALTY_TWO_ROUNDS", "adjusted"]:
        assert gone not in rules, "penalty removed: " + gone
    assert rules.startswith("extends RefCounted") and not re.search(r"^var ", rules, re.M), "no state"
    assert all(x.startswith("static func ") for x in re.findall(r"^\w*\s*func .*$", rules, re.M)), "static functions only"
    assert not re.search(RANDOM + r"|\bawait\b|create_timer|get_tree|Engine\.|\.set\(|BattleUnitState", rules), "pure"
    assert "const HIGH_VALUE_SKILL_SCORE := 130" in rules and "const NO_USE_ROUND := -1" in rules, "threshold and never-used marker kept"
    rf, orf = functions(rules), functions(old_rules)
    for name in ["can_enemy_use_strategy", "is_strategy_target_blocked", "keeps_plan_target"]:
        assert rf[name] == orf[name], "S4-2a strategy rule unchanged: " + name
    body = lambda name: "\n".join(x for x in rf[name].split("\n")[1:] if x.strip())
    assert body("ranks_ahead") == ("\tif a.last_use_round != b.last_use_round:\n\t\treturn a.last_use_round < b.last_use_round\n"
                                   "\tif a.raw != b.raw:\n\t\treturn a.raw > b.raw\n\treturn a.order < b.order"), "rotation order: last use, raw, actor order"
    assert body("should_yield_unique_skill") == (
        "\tvar candidates: Array = [actor]\n\tfor other in others:\n\t\tif other.raw >= HIGH_VALUE_SKILL_SCORE:\n\t\t\tcandidates.append(other)\n"
        "\tif candidates.size() < 2:\n\t\treturn false\n\tvar total_cost := 0\n\tfor candidate in candidates:\n\t\ttotal_cost += candidate.cost\n"
        "\tif total_cost <= momentum:\n\t\treturn false\n\tfor candidate in candidates:\n\t\tif candidate != actor and ranks_ahead(candidate, actor):\n\t\t\treturn true\n"
        "\treturn false"), "yield: two or more candidates not all affordable, someone ranks ahead"
    assert set(rf) == {"can_enemy_use_strategy", "is_strategy_target_blocked", "keeps_plan_target", "ranks_ahead", "should_yield_unique_skill"}

    # Controller: only the spread call site changes; flags default false; enemy-only guard kept.
    code, old = strip_comments(text(ENGINE)), strip_comments(text(ENGINE, True))
    f, of = functions(code), functions(old)
    assert set(f) == set(of), "no function added or removed"
    changed = {n for n in of if f[n] != of[n]}
    assert changed <= CALL_SITE, "only the spread call site changes: " + str(changed - CALL_SITE)
    top = lambda s: [x for x in s.splitlines() if x and not x.startswith(("\t", " ", "func "))]
    assert top(code) == top(old), "class-level lines unchanged (flags, history, preload)"
    for flag in ["enemy_strategy_enabled", "enemy_skill_spread_enabled"]:
        assert re.search(r"^var " + flag + r" := false\b", code, re.M), "flag default false: " + flag
    assert 'if not enemy_skill_spread_enabled or caster_state == null or caster_state.side != "enemy":\n\t\treturn false' in f["_should_enemy_yield_unique_skill"], "enemy-only, behind the flag"
    assert "_has_enemy_unit_acted(unit_state)" in f["_should_enemy_yield_unique_skill"] and "_can_actor_use_unique_skill(unit_state)" in f["_should_enemy_yield_unique_skill"], "candidates: unacted enemies that can use their skill"
    assert "adjusted" not in f["_get_enemy_skill_spread_entry"] + f["_should_enemy_yield_unique_skill"], "no adjusted score left"
    assert '"last_use_round":last_use_round' in f["_get_enemy_skill_spread_entry"] and '"raw":raw' in f["_get_enemy_skill_spread_entry"]
    for name in CALL_SITE:
        assert not re.search(RANDOM, f[name]), "no random number in " + name
    assert f["_record_enemy_unique_skill_use"] == of["_record_enemy_unique_skill_use"], "history recorded as before"
    git("diff", "--check", *rev)
    print(f"S4_2C_SKILL_ROTATION validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; penalty removed; rotation order pinned "
          f"(last use, raw, actor order); yield only when >=2 candidates exceed the momentum; flags default false; 3D/goldens/validators unchanged")


if __name__ == "__main__":
    main()
