"""HUD block 2: the 2D battle log panel on the 3D shell, with the one approved new engine read.

Pinned scope (on top of the H1 inventory commit): a new log panel scene (the 2D
`BattleLogHud` subtree copied as is) and fill script, additions to the scenario
shell, the lab's one read wrapper, one new test, this validator, its report
and the CI list. Engine, services, adapter, host, 2D scenes, goldens, data,
assets, other tests and validators unchanged. The lab gains exactly one
function, `read_battle_log_lines()`, whose only engine access is
`engine.get("battle_log_lines")` returned as a copy; no engine command is
added, so the 15 engine writes stay as they are. The shell takes the panel's
lines from one function (`log_lines()`), which calls only that wrapper.

LOG_HUD_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file
list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "2b082703f9f43dffe16b9720fac2fb28b477fa3e"  # docs(battle3d): H1 inventory of the 2D HUD for the 3D port (read only)
TIP = os.environ.get("LOG_HUD_SCOPE_TIP", "85cdbf193e26307ac509803cfb58b7b058a5573b")  # feat(battle3d): HUD block 2 ...
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SCENE = "scenes/battle3d/Battle3D_LogHud.tscn"
SCRIPT = "scripts/battle3d/battle3d_log_hud.gd"
TEST = "tests/scripts/test_battle3d_log_hud.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_log_hud.py"
REPORT = "agent/HUD_BLOCK2_LOG_RESULT_20261024.md"
PRODUCTION = "scenes/battle/Battle_Production.tscn"
NEW = {SCENE, SCRIPT, SCRIPT + ".uid", TEST, TEST + ".uid", VALIDATOR, REPORT}
MODIFIED = {SHELL, LAB, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd",
                      "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd", "scripts/battle3d/battle3d_top_hud.gd",
                      "scenes/battle/", "scenes/battle3d/Battle3D_EnginePlayLab.tscn", "scenes/battle3d/Battle3D_ScenarioShell.tscn", "scenes/battle3d/Battle3D_TopHud.tscn",
                      "tests/golden/", "data/", "assets/"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"
WRAPPER = ['func read_battle_log_lines() -> Array:', '\tvar lines = engine.get("battle_log_lines")', '\treturn [] if lines == null else (lines as Array).duplicate()']


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def blocks(lines):
    starts = [i for i, l in enumerate(lines) if l.startswith("[")] + [len(lines)]
    return [lines[a:b] for a, b in zip(starts, starts[1:])]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def text(path, base=False):
        data = git("show", f"{BASE}:{path}") if base else ((root / path).read_bytes() if live else git("show", f"{TIP}:{path}"))
        return data.decode("utf-8").replace("\r\n", "\n")

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    for p in [SCENE, SCRIPT, TEST, VALIDATOR]:
        assert p in tree, "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/scene/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    assert not [p for p in changes if p.startswith("tests/") and p not in (TEST, TEST + ".uid")], "existing tests and harnesses unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"

    # The lab: additions only, exactly the read wrapper (plus its comments); one engine access, a copy.
    lab_diff = git("diff", "--unified=0", *rev, "--", LAB).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in lab_diff.splitlines()), "lab: additions only"
    lab_added = [x[1:] for x in lab_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    code_added = [x for x in strip_comments("\n".join(lab_added)).split("\n") if x.strip()]
    assert code_added == WRAPPER, ("lab: the read wrapper only", code_added)
    lab_now = strip_comments(text(LAB))
    lab_base = strip_comments(text(LAB, base=True))
    assert len(re.findall(r'engine\.call\("(\w+)"', lab_now)) == len(re.findall(r'engine\.call\("(\w+)"', lab_base)), "no engine call added to the lab"
    assert sorted(set(re.findall(r'engine\.get\("(\w+)"\)', lab_now)) - set(re.findall(r'engine\.get\("(\w+)"\)', lab_base))) == ["battle_log_lines"], "one new engine read: battle_log_lines"

    # The scene: the 2D BattleLogHud subtree as is.
    prod = blocks(text(PRODUCTION, base=True).split("\n"))
    hud = blocks(text(SCENE).split("\n"))
    want = [[re.sub(r" unique_id=\d+", "", b[0]).replace('parent="BattleUI/ProductionHudRoot', 'parent="ProductionHudRoot')] + b[1:] for b in prod
            if b[0].startswith("[node ") and (('name="BattleLogHud"' in b[0] and 'parent="BattleUI/ProductionHudRoot"' in b[0]) or 'parent="BattleUI/ProductionHudRoot/BattleLogHud' in b[0])]
    got = [b for b in hud if b[0].startswith("[node ") and 'parent="ProductionHudRoot' in b[0]]
    clean = lambda bs: [[l for l in b if l.strip()] for b in bs]
    assert len(want) == 4 and clean(got) == clean(want), "scene nodes == the 2D BattleLogHud subtree (4 nodes)"
    prod_lines = text(PRODUCTION, base=True).split("\n")
    for eid in ["38_battle_ui_theme", "47_battle_log_panel_full"]:
        line = [l for l in prod_lines if l.startswith("[ext_resource") and f'id="{eid}"' in l]
        assert len(line) == 1 and line[0] in text(SCENE), "same resource as the 2D: " + eid

    # The fill script: shows what it is handed; the 2D join.
    fill = strip_comments(text(SCRIPT))
    assert "engine" not in fill and not re.search(RANDOM, fill) and ".call(" not in fill, "fill script: no engine access"
    assert 'log_label().text = "\\n".join(lines)' in fill and "if lines == shown: return" in fill, "2D join, apply on change only"

    # The shell: additions only; one source function; no engine access of its own.
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in sh_diff.splitlines()), "shell: additions only"
    added = strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    assert "engine" not in added and not re.search(RANDOM, added), "shell additions: no engine access, no random"
    assert re.findall(r"\blab\.(\w+)\(", added) == ["read_battle_log_lines"] and len(re.findall(r"(?<![\w.])log_lines\(\)", added)) == 2, "one source: log_lines() -> lab.read_battle_log_lines()"
    git("diff", "--check", *rev)
    print(f"LOG_HUD validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/2D scene diff 0; lab +1 read wrapper "
          f"(engine.get battle_log_lines, a copy); scene == 2D BattleLogHud subtree; one text source in the shell")


if __name__ == "__main__":
    main()
