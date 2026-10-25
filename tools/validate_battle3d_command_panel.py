"""HUD block 4-2: the 2D floating command panel and facing arrows on the 3D shell, with the one approved new read N7.

Pinned scope (on top of feature/base-block41-merged-20261025 4a57108): a new
panel scene (the 2D `FloatingAllyCommandPanel` and `FacingArrowPanel` nodes
copied as is) and script, additions to the scenario shell and to the lab's read
functions, one new test, this validator, its report and the CI list. Engine,
services, adapter, host, 2D scenes, the other HUD blocks, goldens, data and
assets unchanged.

The lab gains exactly one new engine call name, N7
`_get_effective_unique_skill_cost` (a value copy), and no command, so the 15
engine writes stay as they are. The panel script reads nothing from the engine
and its buttons call only the shell's callables; the shell wires them to the
lab's request_attack / request_skill / request_strategy / request_defend /
request_wait and confirm_facing only.

COMMAND_PANEL_SCOPE_TIP=<commit> audits BASE..commit and reads every file and
file list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "4a57108cdc84c8ee0d8e022652c5d82b9404d1e1"  # Merge feature/test-strengthen-20261025 (base with block 4-1)
TIP = os.environ.get("COMMAND_PANEL_SCOPE_TIP", "HEAD")
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SCENE = "scenes/battle3d/Battle3D_CommandPanel.tscn"
SCRIPT = "scripts/battle3d/battle3d_command_panel.gd"
TEST = "tests/scripts/test_battle3d_command_panel.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_command_panel.py"
REPORT = "agent/HUD_BLOCK42_COMMAND_PANEL_RESULT_20261025.md"
PRODUCTION = "scenes/battle/Battle_Production.tscn"
C = "scripts/battle_web_import_test.gd"
NEW = {SCENE, SCRIPT, SCRIPT + ".uid", TEST, TEST + ".uid", VALIDATOR, REPORT}
MODIFIED = {SHELL, LAB, WORKFLOW}
TOP_HUD_TEST = "tests/scripts/test_battle3d_top_hud.gd"
ROSTER_TEST = "tests/scripts/test_battle3d_ally_roster_actor.gd"
EXTRA_MODIFIED = {TOP_HUD_TEST, ROSTER_TEST}  # existing tests changed for the hidden lab UI (file:line and reason in the report)
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/battle_facing_arrow_tile_button.gd", "scripts/worldmap/",
                      "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd",
                      "scripts/battle3d/battle3d_movement_adapter.gd", "scripts/battle3d/battle3d_top_hud.gd", "scripts/battle3d/battle3d_top_commands.gd",
                      "scripts/battle3d/battle3d_log_hud.gd", "scripts/battle3d/battle3d_enemy_roster_hud.gd", "scripts/battle3d/battle3d_ally_roster_hud.gd",
                      "scripts/battle3d/battle3d_current_actor_hud.gd", "scripts/battle3d/battle3d_hero_data_reader.gd", "scenes/battle/", "scenes/battle3d/Battle3D_EnginePlayLab.tscn",
                      "scenes/battle3d/Battle3D_ScenarioShell.tscn", "scenes/battle3d/Battle3D_TopHud.tscn", "scenes/battle3d/Battle3D_LogHud.tscn",
                      "scenes/battle3d/Battle3D_EnemyRosterHud.tscn", "scenes/battle3d/Battle3D_AllyRosterHud.tscn", "scenes/battle3d/Battle3D_CurrentActorHud.tscn",
                      "tests/golden/", "tests/scripts/support/", "data/", "assets/"]
NEW_CALLS = ["_get_effective_unique_skill_cost"]
ADDED_CALLS = ["_get_effective_unique_skill_cost", "_get_unique_skill_for_unit"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
PANEL_LAB_CALLS = ["confirm_facing", "request_attack", "request_defend", "request_skill", "request_strategy", "request_wait"]
SHELL_LAB_READS = ["hud_active_unit_id", "hud_command_panel_open", "hud_range_cell_positions", "hud_skill_cost", "hud_unique_skill"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def blocks(lines):
    starts = [i for i, l in enumerate(lines) if l.startswith("[")] + [len(lines)]
    return [lines[a:b] for a, b in zip(starts, starts[1:])]


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |^const |^var |\Z)", code, re.M | re.S)}


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

    def added_lines(path):
        diff = git("diff", "--unified=0", *rev, "--", path).decode("utf-8")
        assert not any(x.startswith("-") and not x.startswith("---") for x in diff.splitlines()), path + ": additions only"
        return strip_comments("\n".join(x[1:] for x in diff.splitlines() if x.startswith("+") and not x.startswith("+++")))

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    for p, status in changes.items():
        assert (p in MODIFIED | EXTRA_MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    for p in [SCENE, SCRIPT, TEST, VALIDATOR]:
        assert p in tree, "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/2D scene/other HUD/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    th = added_lines(TOP_HUD_TEST)
    assert [l.strip() for l in th.splitlines() if l.strip()] == ["h.shell._lab_info_box().visible = true", "h.shell._lab_info_box().visible = false", "await process_frame"], ("top HUD test: only the info box shown for the wide-panel check", th)
    rt = git("diff", "--unified=0", *rev, "--", ROSTER_TEST).decode("utf-8")
    assert "lab.rejected == rejected_before + 1" in rt and "roster.roster_rect().has_point(point)" in rt and "hovered == null" in rt, "4-1 test: the roster click still checked, now through to the lab's world click"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"

    # The lab: additions only; the new engine call name is N7 exactly; no command; the 15 writes as they were.
    added = added_lines(LAB)
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    assert sorted(set(calls(lab_now)) - set(calls(lab_base))) == NEW_CALLS, ("new engine call names must be N7 exactly", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert sorted(set(calls(added))) == ADDED_CALLS, ("added lines: N7 and an existing name", sorted(set(calls(added))))
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    assert set(re.findall(r'engine\.get\("(\w+)"\)', lab_now)) == set(re.findall(r'engine\.get\("(\w+)"\)', lab_base)), "engine.get names unchanged"
    f = functions(lab_now)
    assert 'int(engine.call("_get_effective_unique_skill_cost", unit, skill))' in f["hud_skill_cost"], "N7: an int copy"
    for name in ["hud_command_panel_open", "hud_range_cell_positions"]:
        assert name in f and not calls(f[name]), name + ": no engine call"

    # The scene: the 2D FloatingAllyCommandPanel and FacingArrowPanel nodes as is, under a layer-7 CanvasLayer.
    prod = blocks(text(PRODUCTION, base=True).split("\n"))
    scene = text(SCENE)
    want = []
    for name in ["FloatingAllyCommandPanel", "FacingArrowPanel"]:
        want += [[re.sub(r" unique_id=\d+", "", b[0]).replace('parent="BattleUI/', 'parent="').replace('parent="BattleUI"', 'parent="."')] + b[1:] for b in prod
                 if b[0].startswith("[node ") and ((f'name="{name}" ' in b[0] and 'parent="BattleUI"' in b[0]) or f'parent="BattleUI/{name}' in b[0])]
    got = [b for b in blocks(scene.split("\n")) if b[0].startswith("[node ") and "parent=" in b[0]]
    clean = lambda bs: [[l for l in b if l.strip()] for b in bs]
    assert len(want) == 11 and clean(got) == clean(want), "scene nodes == the 2D panel (6) and arrow (5) nodes"
    assert '[node name="Battle3DCommandPanel" type="CanvasLayer"]\nlayer = 7' in scene, "layer 7"

    # The panel script: no engine access; buttons call only the shell's callables; the 2D rule constants.
    panel = strip_comments(text(SCRIPT))
    assert "engine" not in panel and ".call(\"" not in panel.replace('button.call("set_tile_style"', "") and not re.search(RANDOM, panel), "panel: no engine access"
    assert re.findall(r"\bon_(\w+)\.call\(", panel) and set(re.findall(r"\bon_(\w+)\.call\(", panel)) == {"attack", "skill", "strategy", "defend", "wait", "facing"}, "panel buttons call only the shell's callables"
    c_src = text(C, base=True)
    for const, value in [("VIEWPORT_MARGIN", "12.0"), ("ANCHOR_GAP", "22.0"), ("GRID_AVOID_PADDING", "10.0"), ("DISTANCE_SCORE_WEIGHT", "8.0"), ("FAR_FALLBACK_SCORE", "1000000.0"), ("NEAR_CANDIDATE_COUNT", "8")]:
        assert f"const FLOATING_COMMAND_PANEL_{const} := {value}" in c_src and f"const {const} := {value}" in panel, "2D constant " + const
    for color in ["Color(0.09, 0.1, 0.13, 1.0)", "Color(0.84, 0.76, 0.54, 1.0)", "Color(0.16, 0.18, 0.23, 1.0)", "Color(0.88, 0.8, 0.58, 1.0)", "Color(1.0, 0.86, 0.42, 0.22)"]:
        assert color in c_src and color in panel, "2D style " + color
    assert "Control.MOUSE_FILTER_IGNORE" in panel and "Control.MOUSE_FILTER_STOP" in panel, "only the panel, buttons and arrows take the mouse"

    # The shell: additions only; no engine access; the panel's callables are the lab's commands; reads from the lab only.
    sh_added = added_lines(SHELL)
    assert "engine" not in sh_added and not re.search(RANDOM, sh_added), "shell additions: no engine access, no random"
    wired = re.findall(r"command_panel\.on_\w+ = func\([^)]*\): lab\.(\w+)\(", sh_added)
    assert sorted(wired) == PANEL_LAB_CALLS, ("panel callables -> lab commands", sorted(wired))
    reads = sorted(set(re.findall(r"\blab\.(hud_\w+)\(", sh_added)))
    assert reads == SHELL_LAB_READS, ("shell reads", reads)
    for line in ["button.position.x = LAB_OFFSCREEN_X", "lab.facing_ui.position.x = LAB_OFFSCREEN_X", "_lab_info_box().visible = false"]:
        assert line in sh_added, "lab UI hidden: " + line
    git("diff", "--check", *rev)
    print(f"COMMAND_PANEL validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; new engine read = N7 only; 15 writes unchanged; "
          f"panel buttons -> lab {', '.join(PANEL_LAB_CALLS)}; scene == 2D panel + arrows (11 nodes)")


if __name__ == "__main__":
    main()
