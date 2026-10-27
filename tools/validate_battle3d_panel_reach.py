"""HUD block 4-6d: two tests tightened (the block 4-6b marker count equals the test's own expectation; the block 4-6c acted
test reads each part as drawn, parents included) and the command panel's candidates around the unit and its marker (no
jump to a far corner).

Pinned scope (on top of 8f901b1, block 4-6c): the marker script (reach_rect from the geometry it is handed), the shell
(reach_rect in the panel state), the command panel (step 3 around reach_rect, and round a HUD panel in the way), the two
tests above, one new test, this validator, its report and the CI list. Engine, services, adapter, host, lab, 2D, scenes,
goldens, data and assets unchanged; the command panel, panel drag, camera centre, block 4-6b panel avoidance, block 4-6c
panel HUD and chip tests unchanged; the chip and arrow constants unchanged.

No new engine read and no command: the lab is not changed (its engine.call / engine.get names and the 15 writes are the
base's); the marker script and the command panel have no engine access; the shell adds none.

PANEL_REACH_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "8f901b137b10d36ffaafa6a6a0bfe75232df1e5e"  # docs(battle3d): HUD block 4-6c panel HUD avoidance and chip report
TIP = os.environ.get("PANEL_REACH_SCOPE_TIP", "HEAD")
MARKERS = "scripts/battle3d/battle3d_unit_markers.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
PANEL = "scripts/battle3d/battle3d_command_panel.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAYOUT_46B = "tests/scripts/test_battle3d_block46b_marker_layout.gd"
ACTED_46C = "tests/scripts/test_battle3d_block46c_acted.gd"
NEW_TEST = "tests/scripts/test_battle3d_block46d_panel_sweep.gd"
UNCHANGED_TESTS = ["tests/scripts/test_battle3d_command_panel.gd", "tests/scripts/test_battle3d_command_panel_checks.gd", "tests/scripts/test_battle3d_panel_drag.gd",
                   "tests/scripts/test_battle3d_camera_center.gd", "tests/scripts/test_battle3d_block46b_panel_avoid.gd", "tests/scripts/test_battle3d_block46b_arrow_look.gd",
                   "tests/scripts/test_battle3d_block46c_panel_hud.gd", "tests/scripts/test_battle3d_block46c_chip.gd", "tests/scripts/test_battle3d_block46_unit_markers.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_panel_reach.py"
REPORT = "agent/HUD_BLOCK46D_TEST_FIX_PANEL_REACH_RESULT_20261027.md"
NEW = {VALIDATOR, REPORT, NEW_TEST, NEW_TEST + ".uid"}
MODIFIED = {MARKERS, PANEL, SHELL, LAYOUT_46B, ACTED_46C, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/ui/", "scripts/worldmap/",
                      "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      LAB, "scenes/", "tests/golden/", "tests/scripts/support/", "data/", "assets/"]


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-c", "core.quotepath=false", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def text(path, base=False):
        data = git("show", f"{BASE}:{path}") if base else ((root / path).read_bytes() if live else git("show", f"{TIP}:{path}"))
        return data.decode("utf-8").replace("\r\n", "\n")

    def diff(path):
        d = git("diff", "--unified=0", *rev, "--", path).decode("utf-8").splitlines()
        return [x[1:] for x in d if x.startswith("-") and not x.startswith("---")], [x[1:] for x in d if x.startswith("+") and not x.startswith("+++")]

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/lab/2D/scene/golden/data/asset diff must be 0: " + p
    for p in UNCHANGED_TESTS:
        assert p not in changes, "unchanged: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, NEW_TEST]), "workflow: the new test and this validator added"

    # No engine access: the lab unchanged (above), none in the marker script or the panel, none added to the shell.
    for path in [MARKERS, PANEL]:
        assert "engine" not in strip_comments(text(path)), path + ": no engine access"
    assert not re.search(r"engine", strip_comments("\n".join(diff(SHELL)[1]))), "the shell: no engine access added"
    assert len(diff(SHELL)[0]) == 1 and '"reach_rect":lab.unit_markers.reach_rect(id)' in text(SHELL), "the shell hands reach_rect to the panel"

    # The marker script: reach_rect added; every block 4-6c constant as it was.
    markers, markers_base = text(MARKERS), text(MARKERS, base=True)
    removed, added = diff(MARKERS)
    assert not removed, ("the marker script: additions only", removed)
    assert "func reach_rect(unit_id: String) -> Rect2:" in markers and "geometries[unit_id] = geometry" in markers, "reach_rect from the last geometry"
    for const in re.findall(r"^const (\w+) :=", markers_base, re.M):
        line = re.search(rf"^const {const} :=.*$", markers_base, re.M).group(0)
        assert line in markers, ("marker constant changed", const)

    # The panel: the steps in order, step 3 only after the near candidates, the 2D score and clamp unchanged.
    panel, panel_base = text(PANEL), text(PANEL, base=True)
    order = ["if not covers(best_rect, avoid_rects) and not covers(best_rect, hud_rects): return best_position", "if free_near != Vector2.INF: return free_near",
             "var free_reach := reach_position(anchor, panel_size, cell_rects, viewport_size)", "if free_reach != Vector2.INF: return free_reach",
             "if free_corner != Vector2.INF: return free_corner", "if best_index < NEAR_CANDIDATE_COUNT and covers(best_rect, avoid_rects) and clear_position != Vector2.INF:"]
    assert all(panel.count(x) == 1 for x in order) and [panel.index(x) for x in order] == sorted(panel.index(x) for x in order), "panel: the five steps in order"
    for name in ["score_position", "clamp_position", "candidate_positions", "covers", "_on_panel_input"]:
        body = lambda src: re.search(rf"^(static )?func {name}\(.*?(?=^\S)", src + "\nend", re.M | re.S).group(0)
        assert body(panel) == body(panel_base), name + " unchanged"
    assert re.search(r"^const ANCHOR_GAP := 22\.0$", panel, re.M) and 'reach_rect = state.get("reach_rect", Rect2())' in panel, "the gap and the state"
    removed, added = diff(PANEL)
    assert removed and all(x.strip().startswith("#") for x in removed), ("panel: only the step comment replaced, no code removed", removed)

    # The two tests: the floor gone, the count equal; each part read with its parents.
    layout = strip_comments(text(LAYOUT_46B))
    assert "checked >= " not in layout and "checked == total" in layout and "expected[key][0] += 1" in layout, "4-6b layout: count equals the test's expectation"
    assert layout.count("expect(") == strip_comments(text(LAYOUT_46B, base=True)).count("expect(") + 1, "4-6b layout: one check added"
    acted = strip_comments(text(ACTED_46C))
    assert "func drawn(node: CanvasItem, m: Control) -> Color:" in acted and "c *= (up as CanvasItem).modulate" in acted and "map(func(l): return drawn(l, pm))" in acted, "4-6c acted: as drawn"
    assert acted.count("expect(") == strip_comments(text(ACTED_46C, base=True)).count("expect("), "4-6c acted: checks kept"
    git("diff", "--check", *rev)
    print(f"PANEL_REACH validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no engine access added; reach_rect step 3, tests as drawn / exact count")


if __name__ == "__main__":
    main()
