"""M5-b scenario selection, result overlay and new battle (3D shell around the lab).

Pinned scope: new shell script + scene only; the lab (`battle3d_engine_play.gd`),
engine, services, adapter, host, goldens and existing tests unchanged (so the
fourteen engine writes and twelve reads of the lab stay as they are). The shell
sends no engine command: its only engine access is the approved read call
`_is_unit_state_available_for_battle_slot`; the start setup goes in through the
`samwar_battle_setup` meta (set right before a new lab, removed when a lab
closes); scenario data lives in the shell constants only; no WorldMap / save /
scene change / random call.

M5B_SCOPE_TIP=<commit> audits BASE..commit; HEAD (default until the reviewer
pins the merged implementation commit) audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "204a9041772e0f6b1e188b71905125ad046f7941"  # feat(battle3d): ... (M5-a2)
TIP = os.environ.get("M5B_SCOPE_TIP", "81fdc434f366af17ffd1d4ba79c8b28f3afdf463")  # feat(battle3d): ... (M5-b)
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
SCENE = "scenes/battle3d/Battle3D_ScenarioShell.tscn"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m5b_scenario.py"
PINNED = "tools/validate_battle3d_m5a2_auto_hold.py"  # previous stack stage: TIP default pinned (one line)
REPORT = "agent/BATTLE3D_M5B_RESULT_20261023.md"
HARNESS = "tests/scripts/support/battle3d_scenario_harness.gd"
BASES = ["tests/scripts/test_battle3d_scenario_victory.gd"]
CI_TESTS = ["tests/scripts/test_battle3d_scenario_start.gd", "tests/scripts/test_battle3d_scenario_defeat.gd", "tests/scripts/test_battle3d_scenario_new_battle.gd"] \
    + [f"tests/scripts/test_battle3d_scenario_victory_seed_{n}.gd" for n in (1, 2, 3)]
GD = [SHELL, HARNESS, *BASES, *CI_TESTS]
NEW = {VALIDATOR, REPORT, SCENE, *GD} | {p + ".uid" for p in GD}
MODIFIED = {WORKFLOW, PINNED}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_engine_play.gd", "scripts/battle3d/battle3d_unit_adapter.gd",
                      "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scenes/battle3d/Battle3D_EnginePlayLab.tscn", "scenes/battle/", "tests/golden/", "data/"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"
FORBIDDEN = r"worldmap|world_map|WorldMap|GameSession|save_|resume|change_scene|strategy_roll_override|time_scale|_toggle_full_auto|set_auto_presentation_hold|" \
            r"set_enemy_ai_level|Engine\.get_meta|\.set\(|FileAccess|ResourceSaver|JSON"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |\Z)", code, re.M | re.S)}


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
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "lab/engine/service/adapter/host/golden/data diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p not in (VALIDATOR, PINNED)], "existing validators unchanged"
    pin_diff = [x for x in git("diff", "--unified=0", *rev, "--", PINNED).decode().splitlines() if x[:1] in "+-" and not x.startswith(("+++", "---"))]
    assert len(pin_diff) in (0, 2) and all(x[1:].startswith('TIP = os.environ.get("M5A2_SCOPE_TIP", ') for x in pin_diff), ("previous validator: TIP pin only", pin_diff)
    assert not [p for p in changes if p.startswith("tests/scripts/") and p not in NEW], "existing tests and harnesses unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, *CI_TESTS]), added

    scene = text(SCENE)
    assert 'path="res://scripts/battle3d/battle3d_scenario_shell.gd"' in scene and scene.count("[node ") == 1, "scene = the shell script only"
    code = strip_comments(text(SHELL))
    assert not re.search(RANDOM, code), "no random"
    assert not re.search(FORBIDDEN, code), "forbidden: " + str(re.findall(FORBIDDEN, code))
    assert re.findall(r'engine\.call\("([^"\n]+)"', code) == ["_is_unit_state_available_for_battle_slot"], "the only engine access: one approved read call"
    assert "engine.get(" not in code and len(re.findall(r"engine\.", code)) == 1, "no other engine access"
    assert re.findall(r"Engine\.(\w+)\(", code) == ["set_meta", "has_meta", "remove_meta"], "meta set once, removed on close: " + str(re.findall(r"Engine\.(\w+)\(", code))
    f = functions(code)
    start = f["start_scenario"]
    assert start.index("_close_lab()") < start.index("Engine.set_meta(SETUP_KEY, setup)") < start.index("lab = create_lab()") < start.index("add_child(lab)"), "close old -> setup meta -> new lab"
    close = f["_close_lab"]
    assert close.index("Engine.remove_meta(SETUP_KEY)") < close.index("lab.free()") and "grid.free()" in close, "meta removed; lab and the orphan ISO grid freed"
    assert 'const SETUP_KEY := "samwar_battle_setup"' in code and "const WIN_PRACTICE_RATIO := 0.25" in code
    assert 'const ENEMY_IDS := ["guan_yu", "zhang_fei", "xiahou_dun", "enemy_reinforce_01_demo", "enemy_reinforce_02_test_unit"]' in code
    setup = f["scenario_setup"]
    assert 'if id != "win_practice": return {}' in setup and 'overrides[unit_id] = {"troops_ratio":WIN_PRACTICE_RATIO}' in setup, "default = no setup; win practice = five enemies at 1/4"
    show = f["_show_result"]
    assert "lab.RESULT_TEXT.get(lab.battle_result" in show and "lab.current_round" in show and "Adapter.to_view(unit)" in show, "overlay from engine-derived values only"
    proc = f["_process"]
    assert "lab.battle_result.is_empty()" in proc and "lab._enemy_presentation_busy()" in proc, "overlay after the lab's result and replay"
    assert [x.strip() for x in f["create_lab"].splitlines() if x.strip()] == ["func create_lab() -> Node:", "return load(LAB_SCENE).instantiate()"], "the lab scene, nothing else"
    git("diff", "--check", *rev)
    print(f"M5B_SCENARIO validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; lab/engine/service/adapter/host diff 0; shell sends no engine command "
          f"(one approved read call); setup meta set before a new lab and removed on close; scenario data in the shell only; no WorldMap/save/random")


if __name__ == "__main__":
    main()
