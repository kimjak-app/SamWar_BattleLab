"""HUD block 4-4: the camera's edge scroll and zoom-out limit, plus three small fixes (row 5 bridge by default, the
builder's play area from PLAY_SIZE, the density comment).

Pinned scope (on top of 0a5028a, block 8): the new edge scroll helper, the lab (edge scroll on the WASD pan path, zoom
constants), the engine lab (its input locks for the edge scroll, the option check box), the shell (edge scroll =
manual camera input), the builder (bridges, comment), four new tests, two changed tests (block 7 defaults: bridges;
block 7 outside cells: the off-ground point search), this validator, its report and the CI list. Engine, services,
adapter (VIEW_FIELDS), host, 2D, other HUD files, goldens, data and assets unchanged; camera_center, oblique_click and
movement_parity unchanged.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's and the 15 writes are
counted as before.

PLAY_SIZE: still defined once (lab_heightfield.gd) and read by the same five files. lab_presentation.gd already read it
(focus, clamps, grid), so `field.play_cells = board.PLAY_SIZE` adds a use there, not a reader file; the builder keeps
its own @export play_cells default and is given PLAY_SIZE by the game lab before it builds.

EDGE_SCROLL_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "0a5028ae67fb147a8421da518e1a36bea65c50ea"  # docs(battle3d): block 8 report (feature/look-pass12-20261026)
TIP = os.environ.get("EDGE_SCROLL_SCOPE_TIP", "0e9791dd50b48d8d46b20ae061eddc123287348d")  # test(battle3d): HUD block 4-4 validator and its CI line
HEIGHTFIELD = "scripts/battle3d/lab_heightfield.gd"
PRESENTATION = "scripts/battle3d/lab_presentation.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
EDGE = "scripts/battle3d/battle3d_edge_scroll.gd"
BUILDER = "scripts/battle3d/terrain_board_builder.gd"
NEW_TESTS = ["tests/scripts/test_battle3d_edge_scroll_direction.gd", "tests/scripts/test_battle3d_edge_scroll_limits.gd",
             "tests/scripts/test_battle3d_edge_scroll_gates.gd", "tests/scripts/test_battle3d_zoom_limit.gd"]
DEFAULTS_TEST = "tests/scripts/test_battle3d_block7_defaults.gd"
OUTSIDE_TEST = "tests/scripts/test_battle3d_block7_outside_cells.gd"
UNCHANGED_TESTS = ["tests/scripts/test_battle3d_camera_center.gd", "tests/scripts/test_battle3d_oblique_click.gd", "tests/scripts/test_battle3d_movement_parity.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_edge_scroll.py"
REPORT = "agent/HUD_BLOCK44_EDGE_SCROLL_RESULT_20261027.md"
NEW = {EDGE, EDGE + ".uid", VALIDATOR, REPORT, *NEW_TESTS, *(p + ".uid" for p in NEW_TESTS)}
MODIFIED = {PRESENTATION, LAB, SHELL, BUILDER, DEFAULTS_TEST, OUTSIDE_TEST, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/ui/", "scripts/worldmap/",
                      "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scenes/", "tests/golden/", "tests/scripts/support/", "data/", "assets/"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
PLAY_READERS = {HEIGHTFIELD, "scripts/battle3d/battle3d_grid_projection.gd", PRESENTATION, "scripts/battle3d/battle3d_connect_lab.gd", SHELL}


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
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    for p in UNCHANGED_TESTS:
        assert p not in changes, "unchanged by the order: " + p
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS]), "workflow: the four tests and this validator added"

    # No new engine read or command; the 15 writes as they were.
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    gets = lambda code: re.findall(r'engine\.get\("(\w+)"\)', code)
    assert set(calls(lab_now)) == set(calls(lab_base)), ("no new engine call name", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert set(gets(lab_now)) == set(gets(lab_base)), ("no new engine property name", sorted(set(gets(lab_now)) - set(gets(lab_base))))
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    for path in [PRESENTATION, SHELL, EDGE]:
        added = diff(path)[1] if path != EDGE else text(EDGE).splitlines()
        assert not re.search(r"engine\.", strip_comments("\n".join(added))), path + ": no engine access"

    # 1. The edge scroll: constants, pure direction, the WASD pan path, the gates, the option, the shell rule.
    edge = text(EDGE)
    assert re.search(r"^const EDGE_PX := 16\b", edge, re.M) and re.search(r"^const EDGE_SPEED_SCALE := 1\.0\b", edge, re.M), "EDGE_PX 16, EDGE_SPEED_SCALE 1.0"
    presentation = text(PRESENTATION)
    assert "edge = EdgeScroll.direction(edge_mouse,get_viewport().get_visible_rect().size)*EdgeScroll.EDGE_SPEED_SCALE" in presentation and "pan = edge" in presentation, "edge scroll on the WASD pan path"
    assert presentation.count("focus.x=clampf(focus.x,0,board.PLAY_SIZE.x*board.CELL)") == 2, "the play area's focus limits kept"
    assert "get_viewport().gui_get_hovered_control()==null" in presentation and "get_window().has_focus()" in presentation and "NOTIFICATION_WM_MOUSE_EXIT" in presentation, "HUD / focus / window gates"
    lab = text(LAB)
    gate = lab[lab.index("func _edge_scroll_allowed() -> bool:"):lab.index("func _enemy_presentation_busy() -> bool:")]
    for needle in ["super._edge_scroll_allowed()", "battle_result.is_empty()", '"is_full_auto_battle_enabled"', '"enemy_turn"', '"is_demo_animating"', "_enemy_presentation_busy()", "hud_cutin_hold", "option_toggle.get_parent().visible"]:
        assert needle in gate, "edge scroll locks: " + needle
    assert '"화면 가장자리 스크롤"' in lab and "edge_scroll_check.button_pressed = edge_scroll_enabled" in lab, "the option check box"
    assert "lab.edge_scrolled.connect(_on_edge_scrolled)" in text(SHELL) and "manual_camera_turn = camera_turn_key()" in text(SHELL), "the shell treats the edge scroll as manual"
    # 2. The zoom range.
    assert re.search(r"^const ZOOM_MIN := 20\.0", presentation, re.M) and re.search(r"^const ZOOM_MAX := 42\.0", presentation, re.M), "zoom 20..42"
    assert "clampf(zoom+(-3 if event.button_index==MOUSE_BUTTON_WHEEL_UP else 3),ZOOM_MIN,ZOOM_MAX)" in presentation and not re.search(r",20,70\)", presentation), "the wheel uses the constants"
    assert "terrain_preview.gd" not in changes and "scripts/battle3d/terrain_preview.gd" not in changes, "the preview scene untouched"

    # 4-A: bridges. 4-B: play_cells from PLAY_SIZE. 4-C: the comment. The builder changes nothing else.
    removed, added = diff(BUILDER)
    assert sorted(x.strip() for x in removed) == sorted(["## Toggle 3D wooden log bridges (default false: ford row 5 shows shallow sand/gravel bar)", "@export var show_bridges: bool = false",
                                                        "## 5) Optional 3D Wooden Log Bridges (default OFF: show_bridges = false)", "for bridge_row in [5.5, 14.5]:",
                                                        "## Trees per forest cell (2~4, fixed deterministic seed, >= 0.4m inside cell border, non-overlapping)"]), ("builder: only the bridges and the comment", removed)
    assert "@export var show_bridges: bool = true" in text(BUILDER) and "@export var show_far_bridge: bool = false" in text(BUILDER) and "for bridge_row in ([5.5, 14.5] if show_far_bridge else [5.5]):" in text(BUILDER), "4-A"
    assert "## Trees per forest cell (1~3," in text(BUILDER), "4-C"
    assert presentation.index("field.play_cells = board.PLAY_SIZE") < presentation.index("field.setup_from_board(board)"), "4-B: the play area given before the build"
    found = subprocess.run(["git", "-c", "core.quotepath=false", "-C", str(root), "grep", *(["--untracked"] if live else []), "-l", "PLAY_SIZE", *([] if live else [TIP]), "--", "scripts/*.gd"], capture_output=True).stdout.decode()
    candidates = {line.split(":", 1)[1] if not live else line for line in found.splitlines()}
    defs = {p: re.findall(r"^const\s+PLAY_SIZE\s*:=\s*Vector2i\((\d+),\s*(\d+)\)", text(p), re.M) for p in candidates}
    assert {p: d for p, d in defs.items() if d} == {HEIGHTFIELD: [("18", "10")]}, "PLAY_SIZE defined once, in lab_heightfield.gd, as 18x10"
    readers = {p for p in candidates if "PLAY_SIZE" in strip_comments(text(p))}
    assert readers == PLAY_READERS, ("PLAY_SIZE readers: the same five files (lab_presentation already read it)", sorted(readers))

    # Changed tests: checks not reduced; the outside-cells test only its off-ground point search.
    for p in [DEFAULTS_TEST, OUTSIDE_TEST]:
        assert strip_comments(text(p)).count("expect(") >= strip_comments(text(p, base=True)).count("expect("), (p, "checks not reduced")
    removed, added = diff(OUTSIDE_TEST)
    assert len(removed) == 4 and all("view.size" in x for x in removed[:3]) and removed[3].strip() == "break" and "first_ground_cell(lab, Vector2(x, y)) == MISS" in "\n".join(added), ("outside cells: only the search", removed, added)
    git("diff", "--check", *rev)
    print(f"EDGE_SCROLL validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no new engine read or write; edge 16 px, zoom 20..42, bridges, play_cells, comment")


if __name__ == "__main__":
    main()
