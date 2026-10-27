"""HUD block 4-6b: the unit markers placed and sized like the 2D marker, bigger outlined facing arrows (three styles,
drawn on top), and the command panel kept clear of the selected unit's marker.

Pinned scope (on top of 7138f88, block 4-6): the marker script, the engine lab (marker geometry, arrows), the command
panel and the shell (the selected marker's parts as rects to keep clear of), two block 4-6 tests changed only where they
were tied to the old shape (the 60 px bar, one anchor point, the arrow's mesh type), three new tests, this validator, its
report and the CI list. Engine, services, adapter (VIEW_FIELDS), host, 2D, scenes, goldens, data and assets unchanged;
the command panel and panel drag tests unchanged.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's and the 15 writes are
counted as before; the marker script and the command panel have no engine access.

MARKER_LOOK_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "7138f883136516b929fada1e4f65561e4bb9699d"  # docs(battle3d): HUD block 4-6 unit marker report
TIP = os.environ.get("MARKER_LOOK_SCOPE_TIP", "1ea534bf7bafe86008a6795341cf6ecb616e289d")  # test(battle3d): HUD block 4-6b tests, validator and CI lines
MARKERS = "scripts/battle3d/battle3d_unit_markers.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
PANEL = "scripts/battle3d/battle3d_command_panel.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
FACING_46 = "tests/scripts/test_battle3d_block46_facing_ground.gd"
MARKERS_46 = "tests/scripts/test_battle3d_block46_unit_markers.gd"
NEW_TESTS = ["tests/scripts/test_battle3d_block46b_marker_layout.gd", "tests/scripts/test_battle3d_block46b_arrow_look.gd",
             "tests/scripts/test_battle3d_block46b_panel_avoid.gd"]
UNCHANGED_TESTS = ["tests/scripts/test_battle3d_command_panel.gd", "tests/scripts/test_battle3d_command_panel_checks.gd", "tests/scripts/test_battle3d_panel_drag.gd",
                   "tests/scripts/test_battle3d_block46_debug_text.gd", "tests/scripts/test_battle3d_block46_marker_mouse.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_marker_look.py"
REPORT = "agent/HUD_BLOCK46B_MARKER_LOOK_RESULT_20261027.md"
NEW = {VALIDATOR, REPORT, *NEW_TESTS, *(p + ".uid" for p in NEW_TESTS)}
MODIFIED = {MARKERS, LAB, PANEL, SHELL, FACING_46, MARKERS_46, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/ui/", "scripts/worldmap/",
                      "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scenes/", "tests/golden/", "tests/scripts/support/", "data/", "assets/"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]


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
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/2D/scene/golden/data/asset diff must be 0: " + p
    for p in UNCHANGED_TESTS:
        assert p not in changes, "unchanged: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS]), "workflow: the three tests and this validator added"

    # No new engine read or command; the 15 writes as they were.
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    gets = lambda code: re.findall(r'engine\.get\("(\w+)"\)', code)
    assert set(calls(lab_now)) == set(calls(lab_base)), ("no new engine call name", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert set(gets(lab_now)) == set(gets(lab_base)), ("no new engine property name", sorted(set(gets(lab_now)) - set(gets(lab_base))))
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    for path in [MARKERS, PANEL]:
        assert "engine" not in strip_comments(text(path)), path + ": no engine access"
    assert not re.search(r"engine\.", strip_comments("\n".join(diff(SHELL)[1]))), "the shell: no engine access added"

    # Commit A: place and size.
    markers = text(MARKERS)
    for const, value in [("CHIP_FRAC", "0.55"), ("CHIP_MIN", "34.0"), ("CHIP_MAX", "80.0"), ("CHIP_RIGHT", "0.38"), ("CHIP_UP", "0.55"), ("BAR_FRAC", "0.90"),
                         ("BAR_MIN", "60.0"), ("BAR_MAX", "150.0"), ("BAR_HEIGHT_FRAC", "0.09"), ("BAR_HEIGHT_MIN", "7.0"), ("BAR_GAP", "2.0"), ("FONT_FRAC", "0.17"),
                         ("FONT_MIN", "13"), ("FONT_MAX", "22"), ("DISC_RADIUS", "1.27"), ("LAYER", "0")]:
        assert re.search(rf"^const {const} := {re.escape(value)}\b", markers, re.M), ("marker constant", const, value)
    assert "HEAD" not in strip_comments(markers) and "MOUSE_FILTER_STOP" not in markers and "MOUSE_FILTER_PASS" not in markers, "no head height; the mouse passes"
    assert "static func layout(foot: Vector2, body: Vector2, disc_bottom: Vector2, cell_px: float) -> Dictionary:" in markers and "func rects_of(unit_id: String) -> Array:" in markers, "layout, rects_of"
    lab = text(LAB)
    assert '"cell_px":foot.distance_to(camera.unproject_position(ground + right * board.CELL))' in lab, "cell_px measured from the camera projection"
    # Commit B: arrows.
    for const in ["const ARROW_STYLE := 0", 'const ARROW_FILL := Color("f4e7c4")', 'const ARROW_OUTLINE := Color("241c14")', "const ARROW_ON_TOP := true", "const FACING_ARROW_DISTANCE := 1.0"]:
        assert const in lab, const
    assert "material.no_depth_test = true" in lab and 'arrow.rotation = Vector3(0, atan2(-direction.x, -direction.z), 0)' in lab, "arrows on top, turned to the engine facing"
    # Commit C: the panel keeps clear.
    panel = text(PANEL)
    assert "covers(Rect2(best_position, panel_size), avoid_rects) and clear_position != Vector2.INF" in panel and 'avoid_rects = state.get("avoid_rects", [])' in panel, "panel avoidance"
    assert '"avoid_rects":avoid_rects' in text(SHELL) and "lab.unit_markers.rects_of(id)" in text(SHELL), "the shell hands the marker parts over"
    # The two block 4-6 tests: only the old-shape lines.
    removed, added = diff(FACING_46)
    assert [x.strip() for x in removed] == ["func arrow_of(lab, id: String) -> MeshInstance3D:"] and len(added) == 1 and "-> Node3D:" in added[0], ("4-6 facing test: the return type only", removed, added)
    removed, added = diff(MARKERS_46)
    assert len(removed) == len(added) <= 10 and all(("BAR_W" in x or "Vector2(400, 400)" in x or "Vector2(-500, 400)" in x or "60 px" in x) for x in removed), ("4-6 marker test: the old-shape lines only", removed)
    assert strip_comments(text(MARKERS_46)).count("expect(") == strip_comments(text(MARKERS_46, base=True)).count("expect("), "4-6 marker test: checks kept"
    git("diff", "--check", *rev)
    print(f"MARKER_LOOK validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no new engine read or write; markers sized by cell_px, arrows, panel avoidance")


if __name__ == "__main__":
    main()
