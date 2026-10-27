"""HUD block 4-6c: the command panel keeps clear of the HUD too, a smaller face chip closer to the unit, and acted units
keep their number and badges bright.

Pinned scope (on top of 27aa734, block 4-6b): the command panel and the shell (the HUD rects with the panel state, one
hud_rects() shared with the camera centring), the marker script (chip constants, the acted darkening on the chip and the
bar), two earlier tests changed only where they were tied to the old numbers (block 4-6 markers: where the darkening is
read; block 4-6b layout: the chip formula and the view count floor), three new tests, this validator, its report and the
CI list. Engine, services, adapter, host, 2D, scenes, goldens, data and assets unchanged; the command panel, panel drag,
block 4-6b panel avoidance and arrow tests unchanged.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's and the 15 writes are
counted as before (the lab is not changed at all); the marker script and the command panel have no engine access.

PANEL_HUD_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "27aa734db24d995e7c18fd4033871d9dff88c7c9"  # docs(battle3d): block 4-6b report: commit count
TIP = os.environ.get("PANEL_HUD_SCOPE_TIP", "@@TIP@@")
MARKERS = "scripts/battle3d/battle3d_unit_markers.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
PANEL = "scripts/battle3d/battle3d_command_panel.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
MARKERS_46 = "tests/scripts/test_battle3d_block46_unit_markers.gd"
LAYOUT_46B = "tests/scripts/test_battle3d_block46b_marker_layout.gd"
NEW_TESTS = ["tests/scripts/test_battle3d_block46c_panel_hud.gd", "tests/scripts/test_battle3d_block46c_chip.gd", "tests/scripts/test_battle3d_block46c_acted.gd"]
UNCHANGED_TESTS = ["tests/scripts/test_battle3d_command_panel.gd", "tests/scripts/test_battle3d_command_panel_checks.gd", "tests/scripts/test_battle3d_panel_drag.gd",
                   "tests/scripts/test_battle3d_block46b_panel_avoid.gd", "tests/scripts/test_battle3d_block46b_arrow_look.gd", "tests/scripts/test_battle3d_camera_center.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_panel_hud.py"
REPORT = "agent/HUD_BLOCK46C_PANEL_HUD_CHIP_RESULT_20261027.md"
NEW = {VALIDATOR, REPORT, *NEW_TESTS, *(p + ".uid" for p in NEW_TESTS)}
MODIFIED = {MARKERS, PANEL, SHELL, MARKERS_46, LAYOUT_46B, WORKFLOW}
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
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS]), "workflow: the three tests and this validator added"

    # No engine access in the changed scripts (the lab is unchanged, so its reads and the 15 writes are the base's).
    for path in [MARKERS, PANEL]:
        assert "engine" not in strip_comments(text(path)), path + ": no engine access"
    assert not re.search(r"engine\.", strip_comments("\n".join(diff(SHELL)[1]))), "the shell: no engine access added"

    # Commit A: the HUD rects, one list, handed to the panel; the order of the filters.
    shell = text(SHELL)
    assert "func hud_rects() -> Array:" in shell and "CameraCenter.free_rect(get_viewport().get_visible_rect(), hud_rects())" in shell and '"hud_rects":hud_rects()' in shell, "hud_rects shared"
    panel = text(PANEL)
    order = ["if not covers(best_rect, avoid_rects) and not covers(best_rect, hud_rects): return best_position", "if free_near != Vector2.INF: return free_near",
             "if free_corner != Vector2.INF: return free_corner", "if best_index < NEAR_CANDIDATE_COUNT and covers(best_rect, avoid_rects) and clear_position != Vector2.INF:"]
    assert all(x in panel for x in order) and [panel.index(x) for x in order] == sorted(panel.index(x) for x in order), "panel: the four filters in order"
    assert 'hud_rects = state.get("hud_rects", [])' in panel, "the panel reads the HUD rects from its state"
    # Commit B: chip constants.
    markers = text(MARKERS)
    for const, value in [("CHIP_FRAC", "0.42"), ("CHIP_MIN", "30.0"), ("CHIP_MAX", "64.0"), ("CHIP_RIGHT", "0.35"), ("CHIP_UP", "0.33"), ("BAR_FRAC", "0.90"), ("FONT_FRAC", "0.17"), ("LAYER", "0")]:
        assert re.search(rf"^const {const} := {re.escape(value)}\b", markers, re.M), ("marker constant", const, value)
    assert "MOUSE_FILTER_STOP" not in markers and "MOUSE_FILTER_PASS" not in markers, "the mouse passes"
    # Commit C: the acted darkening on the chip and the bar only.
    assert "frame.modulate = shade" in markers and "for node in [back, fill]: node.modulate = Color(shade.r, shade.g, shade.b, BAR_ALPHA)" in markers and "root.modulate = READY" in markers, "acted: chip and bar"
    assert "root.modulate = ACTED" not in markers, "the whole marker is not darkened"
    # The earlier tests: only the old-number lines.
    removed, added = diff(MARKERS_46)
    assert [x.strip() for x in removed] == ["var mod: Color = markers.markers[unit.unit_id].modulate"] and len(added) == 1 and '.get_node("Chip").modulate' in added[0], ("4-6 marker test", removed, added)
    removed, added = diff(LAYOUT_46B)
    assert len(removed) == len(added) == 3 and all(("0.55" in x or "checked >= 30" in x) for x in removed), ("4-6b layout test: the chip formula and the view floor", removed)
    for p in [MARKERS_46, LAYOUT_46B]:
        assert strip_comments(text(p)).count("expect(") == strip_comments(text(p, base=True)).count("expect("), p + ": checks kept"
    git("diff", "--check", *rev)
    print(f"PANEL_HUD validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no engine access added; HUD rects, chip 0.42/30/64, acted chip and bar")


if __name__ == "__main__":
    main()
