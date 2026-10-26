"""HUD block 7: the 20x20 terrain port (board) with the engine's 18x10 play area.

Pinned scope (on top of 0dd9239, block 4-3): the delivered archives unpacked unchanged (DELIVERED), Godot's import files
for them, the play area defined once (lab_heightfield.gd PLAY_SIZE) and read by the projection, the lab, the shell and
the connect lab, the click guard for cells outside it, the contract validator's board assertions split into board and
play area, the two tests that loaded battlefield.glb moved to the built board, seven new tests with two fixtures, this
validator, its report and the CI list. Engine, services, adapter (VIEW_FIELDS), host, 2D scenes, goldens and data unchanged;
battlefield.glb kept.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's and the 15 writes are
counted as before.

TERRAIN_PORT_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "0dd923981bf73e97a453cb10f34c90b990c29855"  # docs(battle3d): HUD block 4-3 report (origin/feature/hud-block43-controls-fix-20261026)
DELIVERED = "9a6f6f29e51bef52b3472acc30e1cb0ad3a67602"  # chore(battle3d): the Grok 20x20 terrain port and its preview scene as delivered
TIP = os.environ.get("TERRAIN_PORT_SCOPE_TIP", "@@TIP@@")
BOARD = "scripts/battle3d/lab_heightfield.gd"
PROJECTION = "scripts/battle3d/battle3d_grid_projection.gd"
PRESENTATION = "scripts/battle3d/lab_presentation.gd"
CONNECT = "scripts/battle3d/battle3d_connect_lab.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
CONTRACT = "tools/validate_battle3d_contract.py"
PARITY = "tests/scripts/test_battle3d_movement_parity.gd"
OBLIQUE = "tests/scripts/test_battle3d_oblique_click.gd"
CAMERA_TEST = "tests/scripts/test_battle3d_camera_center.gd"
NEW_TESTS = ["tests/scripts/test_battle3d_block7_outside_cells.gd", "tests/scripts/test_battle3d_block7_old_play_area.gd", "tests/scripts/test_battle3d_block7_foot_height.gd",
             "tests/scripts/test_battle3d_block7_board_data.gd", "tests/scripts/test_battle3d_block7_triangle_budget.gd", "tests/scripts/test_battle3d_block7_defaults.gd",
             "tests/scripts/test_battle3d_block7_ford_demo_moves.gd"]
FIXTURES = ["tests/data/block7_old_play_area_0dd9239.json", "tests/data/block7_old_demo_reach_0dd9239.json"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_terrain_port.py"
REPORT = "agent/HUD_BLOCK7_TERRAIN_PORT_RESULT_20261026.md"
EDITED_AFTER_DELIVERY = {BOARD, PRESENTATION, CONNECT}  # delivered files the play-area split then edits
MODIFIED = {PROJECTION, SHELL, LAB, CONTRACT, PARITY, OBLIQUE, CAMERA_TEST, WORKFLOW}
NEW = {VALIDATOR, REPORT, *NEW_TESTS, *FIXTURES, *(p + ".uid" for p in NEW_TESTS)}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/ui/", "scripts/worldmap/",
                      "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "tests/golden/", "tests/scripts/support/", "data/"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
PLAY_READERS = {BOARD, PROJECTION, PRESENTATION, CONNECT, SHELL}


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

    def text(path, at=None):
        if at is not None:
            return git("show", f"{at}:{path}").decode("utf-8").replace("\r\n", "\n")
        data = (root / path).read_bytes() if live else git("show", f"{TIP}:{path}")
        return data.decode("utf-8").replace("\r\n", "\n")

    def diff(path, a=BASE):
        d = git("diff", "--unified=0", *([a] if live else [a, TIP]), "--", path).decode("utf-8").splitlines()
        return [x[1:] for x in d if x.startswith("-") and not x.startswith("---")], [x[1:] for x in d if x.startswith("+") and not x.startswith("+++")]

    def blob(path, at):
        return git("rev-parse", f"{at}:{path}").decode().strip()

    # The delivery commit: the archives' files only, on top of the base.
    delivered = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", BASE, DELIVERED).decode().splitlines())
    textures = [p for p in delivered if p.startswith("assets/terrain_textures_pack/") and p.endswith(".png")]
    assert len(textures) == 28 and len(delivered) == 38, ("the delivery: 28 textures + 10 files", len(textures), len(delivered))
    assert git("rev-parse", f"{DELIVERED}^").decode().strip() == BASE, "the delivery sits directly on the base"

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    imported = {p for p in changes if (p.endswith(".import") or p.endswith(".uid")) and (p.rsplit(".", 1)[0] in delivered)}
    for p, status in changes.items():
        ok = p in delivered and status == delivered[p] or (p in MODIFIED and status == "M") or (p in NEW and status == "A") or (p in imported and status == "A")
        assert ok, ("out of scope", status, p)
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/2D/golden/data diff must be 0: " + p
    assert not [p for p in changes if p.startswith("scenes/") and p != "scenes/battle3d/Terrain20x20_Preview.tscn"], "no scene changed but the delivered preview"
    for p in delivered:
        if p not in EDITED_AFTER_DELIVERY and p in tree:
            assert live or blob(p, TIP) == blob(p, DELIVERED), "delivered file unchanged after the delivery: " + p
    assert "assets/battle3d/battlefield.glb" in tree and "assets/battle3d/battlefield.glb" not in changes, "battlefield.glb kept and unchanged"
    for p in [VALIDATOR, *NEW_TESTS, *FIXTURES]:
        assert p in tree, "missing in the audited tree: " + p
    assert not [p for p in changes if p.startswith("tools/") and p not in (VALIDATOR, CONTRACT)], "other validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS]), "workflow: the seven tests and this validator added"

    # No new engine read or command; the 15 writes as they were.
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, at=BASE))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    gets = lambda code: re.findall(r'engine\.get\("(\w+)"\)', code)
    assert set(calls(lab_now)) == set(calls(lab_base)), ("no new engine call name", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert set(gets(lab_now)) == set(gets(lab_base)), ("no new engine property name", sorted(set(gets(lab_now)) - set(gets(lab_base))))
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    for path in [PROJECTION, SHELL, PRESENTATION, CONNECT, BOARD]:
        assert not re.search(r"engine\.(call|get|set)\(|engine\.\w+\s*=", strip_comments("\n".join(diff(path)[1]))), path + ": no engine access added"
    removed, added = diff(LAB)
    assert not removed and len(added) == 3 and "if not board.valid(cell):" in added[0], ("the lab: only the click guard", added)
    lab = text(LAB)
    click = lab[lab.index("func _click_world(pos: Vector2) -> void:"):]
    assert click.index("if not board.valid(cell):") < click.index('engine.get("current_phase")') and "return" in click[click.index("if not board.valid(cell):"):click.index('engine.get("current_phase")')], "the guard returns before the first engine read"

    # The play area: one definition, its readers, no 18/10 literal left in the 3D presentation.
    defs = {p: re.findall(r"^const\s+PLAY_SIZE\s*:=\s*Vector2i\((\d+),\s*(\d+)\)", text(p), re.M) for p in tree if p.startswith("scripts/") and p.endswith(".gd")}
    assert {p: d for p, d in defs.items() if d} == {BOARD: [("18", "10")]}, "PLAY_SIZE defined once, in lab_heightfield.gd, as 18x10"
    readers = {p for p in tree if p.startswith("scripts/") and p.endswith(".gd") and "PLAY_SIZE" in strip_comments(text(p))}
    assert readers == PLAY_READERS, ("PLAY_SIZE readers", sorted(readers))
    board = strip_comments(text(BOARD))
    assert re.search(r"func valid\(c: Vector2i\) -> bool:\n\s*return c\.x >= 0 and c\.y >= 0 and c\.x < PLAY_SIZE\.x and c\.y < PLAY_SIZE\.y", board), "valid() is the play area"
    assert re.search(r"func on_board\(c: Vector2i\) -> bool:\n\s*return c\.x >= 0 and c\.y >= 0 and c\.x < SIZE\.x and c\.y < SIZE\.y", board) and "if on_board(c) and c.y < terrain_cells.size():" in board, "terrain types over the board"
    assert "grid_width=heightfield.PLAY_SIZE.x" in text(PROJECTION) and "grid_height=heightfield.PLAY_SIZE.y" in text(PROJECTION), "the projection's grid is the play area"
    presentation = strip_comments(text(PRESENTATION))
    assert "board.SIZE" not in presentation and presentation.count("focus.x=clampf(focus.x,0,board.PLAY_SIZE.x*board.CELL)") == 2, "the lab: focus, clamps, grid lines over the play area"
    assert "range(board.PLAY_SIZE.x)" in text(CONNECT) and "board.SIZE" not in strip_comments(text(CONNECT)), "the connect lab's annotations over the play area"
    assert "lab.board.PLAY_SIZE.x * lab.board.CELL, lab.board.PLAY_SIZE.y * lab.board.CELL" in text(SHELL) and "board.SIZE" not in strip_comments(text(SHELL)), "the shell's camera limit is the play area"
    for p in [LAB, SHELL, PRESENTATION, CONNECT, PROJECTION, "scripts/battle3d/lab_demo_port.gd"]:
        assert not re.search(r"range\((18|10)\)", strip_comments(text(p))), p + ": no range(18)/range(10)"

    # The changed tests and the contract validator: no check removed; battlefield.glb no longer loaded.
    for p in [PARITY, OBLIQUE]:
        now, then = strip_comments(text(p)), strip_comments(text(p, at=BASE))
        assert now.count("expect(") >= then.count("expect("), (p, "checks not reduced", then.count("expect("), now.count("expect("))
        assert "battlefield.glb" not in now and "TerrainBuilder.new()" in now and not re.search(r"range\((18|10)\)", now), p + ": the built board and the play area"
    removed, added = diff(CAMERA_TEST)
    assert len(removed) == 1 and len(added) == 1 and "lab.board.SIZE.x" in removed[0] and "lab.board.PLAY_SIZE.x" in added[0], ("camera test: only its focus limit", removed, added)
    contract_now, contract_then = text(CONTRACT), text(CONTRACT, at=BASE)
    assert len(re.findall(r"^\s*assert\b", contract_now, re.M)) >= len(re.findall(r"^\s*assert\b", contract_then, re.M)), "contract validator: asserts not reduced"
    assert not [p for p in tree if p.startswith("tests/scripts/") and p.endswith(".gd") and "battlefield.glb" in strip_comments(text(p))], "no test loads battlefield.glb"
    git("diff", "--check", *rev)
    print(f"TERRAIN_PORT validator PASS: base={BASE} delivered={DELIVERED} scope={TIP}; {len(changes)} paths; no new engine read or write; PLAY_SIZE once, {len(readers)} reader files")


if __name__ == "__main__":
    main()
