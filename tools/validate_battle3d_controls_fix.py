"""HUD block 4-3: 3D controls fix (acted-ally click, camera centring, facing arrows, panel drag) on the 3D shell.

Pinned scope (on top of integration 2f7f53f, blocks 4-2 and 5 merged): two new helper scripts (camera centring
math, facing tile), changes to the lab, the shell and the command panel script, four new tests, additions to the
block 4-2 test (and its arrow checks moved to the screen-direction rule), this validator, its report and the CI
list. Engine, services, adapter (VIEW_FIELDS), host, 2D scenes, other HUD files, goldens, data and assets unchanged.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's and the 15 writes
are counted as before. The lab, the shell and the new scripts carry none of the M5-c forbidden names.

CONTROLS_FIX_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "2f7f53f"  # Merge feature/hud-block5-cutin-result-toast-20261025 (integration with blocks 4-2 and 5)
TIP = os.environ.get("CONTROLS_FIX_SCOPE_TIP", "HEAD")
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
PANEL = "scripts/battle3d/battle3d_command_panel.gd"
CAMERA = "scripts/battle3d/battle3d_camera_center.gd"
TILE = "scripts/battle3d/battle3d_facing_tile.gd"
PANEL_TEST = "tests/scripts/test_battle3d_command_panel.gd"
NEW_TESTS = ["tests/scripts/test_battle3d_acted_ally_click.gd", "tests/scripts/test_battle3d_camera_center.gd", "tests/scripts/test_battle3d_facing_arrows.gd", "tests/scripts/test_battle3d_panel_drag.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_controls_fix.py"
REPORT = "agent/HUD_BLOCK43_CONTROLS_FIX_RESULT_20261026.md"
GD_NEW = [CAMERA, TILE, *NEW_TESTS]
NEW = {VALIDATOR, REPORT, *GD_NEW, *(p + ".uid" for p in GD_NEW)}
MODIFIED = {LAB, SHELL, PANEL, PANEL_TEST, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/battle_facing_arrow_tile_button.gd", "scripts/ui/",
                      "scripts/worldmap/", "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd",
                      "scenes/", "tests/golden/", "tests/scripts/support/", "data/", "assets/"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
FORBIDDEN = r"result_toast|result_video|world_?map|WorldMap"


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
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/2D/scene/golden/data/asset diff must be 0: " + p
    for p in [CAMERA, TILE, VALIDATOR, *NEW_TESTS]:
        assert p in tree, "missing in the audited tree: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS]), "workflow: the four tests and this validator added"

    # No new engine read or command; the 15 writes as they were.
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    gets = lambda code: re.findall(r'engine\.get\("(\w+)"\)', code)
    assert set(calls(lab_now)) == set(calls(lab_base)), ("no new engine call name", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert set(gets(lab_now)) == set(gets(lab_base)), ("no new engine property name", sorted(set(gets(lab_now)) - set(gets(lab_base))))
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    for code in [lab_now, strip_comments(text(SHELL)), strip_comments(text(PANEL)), strip_comments(text(CAMERA)), strip_comments(text(TILE))]:
        assert not re.search(FORBIDDEN, code), "no forbidden name"
    for path in [SHELL, PANEL, CAMERA, TILE]:
        assert "engine" not in strip_comments("\n".join(diff(path)[1])) or path == SHELL and not re.search(r"engine\.(call|set)\(|engine\.\w+\s*=", strip_comments("\n".join(diff(path)[1]))), path + ": no engine command"

    # Item 1: the lab keeps the acting ally on a click on an ally that already acted (before the engine selection).
    lab = text(LAB)
    guard = lab.index("if unit != acting and Adapter.to_view(unit).has_acted:")
    assert guard < lab.index('engine.call("_select_ally_unit",unit,false,false,false)'), "item 1: the acted-ally guard comes before the engine selection"
    assert "and not hud_cutin_hold # block 4-3" in lab, "the command panel stays closed while a cut-in holds"
    shell = text(SHELL)
    assert "# block 4-3: never over the unit's own cell" in shell, "item 1: the panel avoids the acting unit's own cell"
    # Item 2: camera centring from the shell's HUD rectangles, eased, per ally turn, stopped by the player's own camera input.
    assert "CameraCenter.free_rect(get_viewport().get_visible_rect(), obstacles)" in shell and 'tween_property(lab, "focus", camera_target, CAMERA_CENTER_SEC)' in shell and "manual_camera_turn = camera_turn_key()" in shell, "item 2"
    assert "clampf(wanted.x, 0.0, board_size.x)" in text(CAMERA) and "clampf(wanted.z, 0.0, board_size.y)" in text(CAMERA), "item 2: the focus clamp is kept"
    # Item 3: the arrow direction is the projected unit -> neighbour vector; the tile is the projected diamond with a polygon hit area.
    assert '"direction":(lab.camera.unproject_position(lab.board.world(target)) - lab.camera.unproject_position(lab.board.world(cell))).normalized()' in shell, "item 3: screen direction"
    assert "Geometry2D.is_point_in_polygon(point, corners)" in text(TILE) and "arrow.set_tile(" in text(PANEL), "item 3: diamond tile and hit area"
    # Item 4: drag by the panel background, clamped, per turn.
    panel = text(PANEL)
    assert "panel.gui_input.connect(_on_panel_input)" in panel and "clamp_position(panel.position + event.position - drag_offset, PANEL_SIZE, viewport_size)" in panel and "if key != drag_key: drag_position = Vector2.INF" in panel, "item 4"
    # Cleanup: the Node.owner shadowing variable is gone.
    assert not re.search(r"\bvar owner\b", shell), "no `var owner` in the shell"
    # The block 4-2 test: removed lines only in the two arrow checks and the expected-position rects; the additions are present.
    removed, added = diff(PANEL_TEST)
    assert all(("TEXT[d]" in x or "want" in x or "arrow_sizes" in x or "grid texts" in x or "is_equal_approx(h.shell.cell_screen_rect" in x) for x in removed), ("block 4-2 test: only the arrow checks changed", removed)
    for needle in ["func block43_additions() -> void:", "skill_cost_up", "func independent_open(lab, b) -> bool:", "func expected_position(", "_on_strategy_button_pressed", "hud_range_cell_positions()"]:
        assert any(needle in x for x in added), "block 4-2 test addition: " + needle
    git("diff", "--check", *rev)
    print(f"CONTROLS_FIX validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no new engine read or write; items 1-4 and cleanup present")


if __name__ == "__main__":
    main()
