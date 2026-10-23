"""S4-3 battle start setup port, enemy AI level and auto presentation hold (engine only).

Pinned scope: changed files, 3D / existing goldens / existing pinned validators
unchanged, the new rules service pure, the setup meta read in its own function
(separate from the WorldMap battle context handoff; no save / resume / WorldMap
call added), the controller change limited to the new functions plus one line in
`_ready`, one line at the enemy turn start and the auto tick gate, defaults
unchanged (flags false, level "low", hold false), no new random number.

S4_3_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "c13ecc44a6880948b46b2d4034eec027f4abc385"  # chore(battle): pin the S4-2c addendum validator (before S4-3)
TIP = os.environ.get("S4_3_SCOPE_TIP", "06e9db0d7e48353dbe164dd1b6ad17c2fbcf9ad7")  # feat(battle): ... (S4-3)
ENGINE = "scripts/battle_web_import_test.gd"
SERVICE = "scripts/battle/services/battle_setup_rules_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle_setup_port_s4_3.py"
REPORT = "agent/BATTLE_S4_3_RESULT_20261022.md"
GOLDEN = "tests/golden/battle_setup_port_base_v0.json"
TESTS = ["tests/scripts/test_battle_setup_port_base_parity.gd", "tests/scripts/test_battle_setup_port_base_parity_shard_1.gd",
         "tests/scripts/test_battle_setup_port_base_parity_shard_2.gd", "tests/scripts/test_battle_setup_port_s4_3.gd",
         "tests/scripts/test_battle_enemy_ai_level_s4_3.gd", "tests/scripts/test_battle_enemy_ai_level_mid_default.gd",
         "tests/scripts/test_battle_auto_presentation_hold_s4_3.gd"]
SCRIPTS = [SERVICE, "tests/scripts/support/battle_setup_s43_harness.gd"] + TESTS
NEW = {VALIDATOR, REPORT, GOLDEN} | set(SCRIPTS) | {p + ".uid" for p in SCRIPTS}
MODIFIED = {ENGINE, WORKFLOW}
CI_ADDED = [VALIDATOR] + [t for t in TESTS if t != "tests/scripts/test_battle_setup_port_base_parity.gd"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|\bshuffle\s*\(|pick_random"
FORBIDDEN_CALLS = r"GameSession|save_battle_resume_snapshot|_persist_battle_resume_snapshot|change_scene|WORLDMAP|worldmap|resume"
ADDED_FUNCS = {"_read_battle_setup_port", "_apply_battle_setup_unit_override", "_log_battle_setup_ignored", "set_enemy_ai_level",
               "get_enemy_ai_level", "get_pending_enemy_ai_level", "_apply_pending_enemy_ai_level", "set_auto_presentation_hold"}
INSERTED = {  # changed function -> the exact lines added to it
    "_ready": ["\t_read_battle_setup_port()"],
    "_play_enemy_ai_turn": ["\t_apply_pending_enemy_ai_level()"],
    "_tick_full_auto_battle_if_needed": ["\tif auto_presentation_hold:", "\t\treturn"],
}
ADDED_TOP = ['const BattleSetupRulesServiceScript := preload("res://scripts/battle/services/battle_setup_rules_service.gd")',
             'const BATTLE_SETUP_META_KEY := "samwar_battle_setup"', 'var enemy_ai_level := "low"', "var enemy_ai_level_applied := false",
             'var _pending_enemy_ai_level := ""', "var auto_presentation_hold := false"]


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
    for p in NEW - {REPORT}:
        assert raw(p).strip(), "missing " + p
    assert not [p for p in changes if p.startswith("scripts/battle3d/")], "3D unchanged"
    assert not [p for p in changes if p.startswith("tests/golden/") and p != GOLDEN], "existing goldens unchanged"
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing (pinned) validators unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted(CI_ADDED), added

    # Rules service: pure.
    service = strip_comments(text(SERVICE))
    assert service.startswith("extends RefCounted") and not re.search(r"^var ", service, re.M), "no state"
    assert all(x.startswith("static func ") for x in re.findall(r"^\w*\s*func .*$", service, re.M)), "static functions only"
    assert not re.search(RANDOM + r"|\bawait\b|create_timer|get_tree|Engine\.|\.set\(|BattleUnitState", service), "pure"
    sf = functions(service)
    assert set(sf) == {"is_valid_troops_ratio", "scale_troop_value", "is_valid_ai_level", "flags_for_ai_level"}, set(sf)
    assert 'const AI_LEVELS := ["low", "mid", "high"]' in service
    assert "return maxi(1, int(floor(float(value) * ratio)))" in sf["scale_troop_value"], "round down, at least 1"
    assert 'var smart := level == "mid" or level == "high"' in sf["flags_for_ai_level"] and '"enemy_skill_cap_enabled":true' in sf["flags_for_ai_level"], "low = cap only; mid/high = all three"

    # Controller.
    code, old = strip_comments(text(ENGINE)), strip_comments(text(ENGINE, True))
    f, of = functions(code), functions(old)
    assert set(f) - set(of) == ADDED_FUNCS and not set(of) - set(f), "functions added: " + str(set(f) ^ set(of))
    changed = {n for n in of if f[n] != of[n]}
    assert changed == set(INSERTED), "changed: " + str(changed)
    for name, lines in INSERTED.items():
        new_lines = f[name].split("\n")
        for line in lines:
            new_lines.remove(line)
        assert new_lines == of[name].split("\n"), "only the insertion in " + name
    assert f["_tick_full_auto_battle_if_needed"].split("\n")[1:3] == INSERTED["_tick_full_auto_battle_if_needed"], "hold gate is the first statement of the auto tick"
    ept = f["_play_enemy_ai_turn"]
    assert ept.index("\t_apply_pending_enemy_ai_level()") < ept.index('enemy_action_event_log.emit("enemy_turn_started"') and ept.index("return") < ept.index("\t_apply_pending_enemy_ai_level()"), "level applied at the enemy turn start, after the end guard"
    assert f["_ready"].index("\t_try_restore_battle_resume_snapshot()") < f["_ready"].index("\t_read_battle_setup_port()") < f["_ready"].index('\t_refresh_production_battle_hud("ready")'), "setup read after the WorldMap/resume reads, before the HUD"
    assert len(re.findall(r"^\t+_apply_pending_enemy_ai_level\(\)", code, re.M)) == 2, "applied only at the enemy turn start and from the start setup"
    top = lambda s: [x for x in s.splitlines() if x and not x.startswith(("\t", " ", "func "))]
    assert [x for x in top(old) if x not in top(code)] == [] and [x.split(" #")[0].rstrip() for x in top(code) if x not in top(old)] == ADDED_TOP, "class-level additions"
    for flag in ["enemy_strategy_enabled", "enemy_skill_spread_enabled", "enemy_skill_cap_enabled"]:
        assert re.search(r"^var " + flag + r" := false\b", code, re.M), "flag default false: " + flag
    # The setup read is its own function, separate from the WorldMap handoff.
    port = f["_read_battle_setup_port"]
    assert "Engine.has_meta(BATTLE_SETUP_META_KEY)" in port and "Engine.get_meta(BATTLE_SETUP_META_KEY)" in port and "Engine.remove_meta(BATTLE_SETUP_META_KEY)" in port, "read once and removed"
    assert f["_read_worldmap_battle_context_handoff"] == of["_read_worldmap_battle_context_handoff"], "WorldMap handoff unchanged"
    for name in ADDED_FUNCS:
        assert not re.search(FORBIDDEN_CALLS, f[name]), "no WorldMap / save / resume call in " + name
        assert not re.search(RANDOM, f[name]), "no random number in " + name
    over = f["_apply_battle_setup_unit_override"]
    assert "BattleSetupRulesServiceScript.is_valid_troops_ratio(ratio)" in over and "for field in BattleSetupRulesServiceScript.TROOP_FIELDS:" in over, "ratio checked, six fields together"
    lvl = f["set_enemy_ai_level"]
    assert lvl.index("if not BattleSetupRulesServiceScript.is_valid_ai_level(level):\n\t\treturn false") < lvl.index("_pending_enemy_ai_level ="), "invalid value: no change"
    assert "enemy_strategy_enabled" not in lvl and "enemy_ai_level =" not in lvl.replace("_pending_enemy_ai_level =", ""), "set only stores the pending value"
    hold = f["set_auto_presentation_hold"]
    assert 'if was_holding and not hold and is_full_auto_battle_enabled and current_phase == PHASE_ALLY_TURN and not is_demo_animating:\n\t\tcall_deferred("_tick_full_auto_battle_if_needed")' in hold, "release resumes a blocked tick"
    assert code.count("auto_presentation_hold = ") == 1, "hold written only by set_auto_presentation_hold"
    git("diff", "--check", *rev)
    print(f"S4_3_BATTLE_SETUP validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; setup meta read once in its own function (no WorldMap/save/resume call); "
          f"level applied at the enemy turn start; hold gate first in the auto tick; defaults unchanged; 3D/goldens/validators unchanged")


if __name__ == "__main__":
    main()
