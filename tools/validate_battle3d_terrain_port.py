"""HUD block 7: the 20x20 terrain port (board) with the engine's 18x10 play area.

Pinned scope (on top of 0dd9239, block 4-3): the delivered archives unpacked unchanged (DELIVERED), Godot's import files
for them, the play area defined once (lab_heightfield.gd PLAY_SIZE) and read by the projection, the lab, the shell and
the connect lab, the click guard for cells outside it, the contract validator's board assertions split into board and
play area, the two tests that loaded battlefield.glb moved to the built board, seven new tests with two fixtures, this
validator, its report and the CI list. Engine, services, adapter (VIEW_FIELDS), host, 2D scenes, goldens and data unchanged;
battlefield.glb kept.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's and the 15 writes are
counted as before.

Block 8 (look pass 1+2) extends the same scope on top of block 7 (LOOK_BASE): Grok's files as delivered (LOOK_A), only
the builder's three compile fixes (LOOK_B), only the forest density's two defaults (LOOK_C), then the outer ground texture
(new asset + import) set by the game lab and the preview, the lab's background colour, two block 7 test expectations and
two new tests. The pin moved from d441c23 (block 7) to the block 8 implementation commit so this one validator audits
both blocks; every block 7 check stays.

TERRAIN_PORT_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "0dd923981bf73e97a453cb10f34c90b990c29855"  # docs(battle3d): HUD block 4-3 report (origin/feature/hud-block43-controls-fix-20261026)
DELIVERED = "9a6f6f29e51bef52b3472acc30e1cb0ad3a67602"  # chore(battle3d): the Grok 20x20 terrain port and its preview scene as delivered
TIP = os.environ.get("TERRAIN_PORT_SCOPE_TIP", "3824924a5cbcd9fff0450a9465ee5d0e523ea8da")  # feat(battle3d): block 8 look pass 1+2 wiring (was d441c23, block 7)
LOOK_BASE = "7d1558e3f0b47d53c30f8621b80bcf1ec9208ade"  # docs(battle3d): HUD block 7 terrain port report
LOOK_A = "e9f450e"  # chore(battle3d): Grok look pass 1+2 files as delivered
LOOK_B = "923cb2c"  # fix(battle3d): the builder's three compile errors only
LOOK_C = "13932f1"  # feat(battle3d): forest density 1-3 trees per cell
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
BUILDER = "scripts/battle3d/terrain_board_builder.gd"
PREVIEW = "scripts/battle3d/terrain_preview.gd"
LOOK_AS_DELIVERED = {"scripts/battle3d/eastwar_terrain_20x20.gdshader", "README_미리보기.md"}  # replaced by look pass 1+2, unchanged since LOOK_A
WATER = "scripts/battle3d/eastwar_terrain_20x20_water.gdshader"
OUTER = "assets/terrain_textures_pack/outer_ground_B20.png"
LOOK_TESTS = ["tests/scripts/test_battle3d_look12_tree_height.gd", "tests/scripts/test_battle3d_look12_forest_fade.gd"]
LOOK_REPORT = "agent/HUD_BLOCK8_LOOK12_RESULT_20261026.md"
EDITED_AFTER_DELIVERY = {BOARD, PRESENTATION, CONNECT, BUILDER, PREVIEW, *LOOK_AS_DELIVERED}  # delivered files later edited (block 7 split, block 8 look)
MODIFIED = {PROJECTION, SHELL, LAB, CONTRACT, PARITY, OBLIQUE, CAMERA_TEST, WORKFLOW}
NEW = {VALIDATOR, REPORT, *NEW_TESTS, *FIXTURES, *(p + ".uid" for p in NEW_TESTS),
       WATER, WATER + ".uid", OUTER, OUTER + ".import", LOOK_REPORT, *LOOK_TESTS, *(p + ".uid" for p in LOOK_TESTS)}
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
        return subprocess.check_output(["git", "-c", "core.quotepath=false", "-C", str(root), *args])

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
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS, *LOOK_TESTS]), "workflow: the seven block 7 tests, the two block 8 tests and this validator added"

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
    found = subprocess.run(["git", "-c", "core.quotepath=false", "-C", str(root), "grep", *(["--untracked"] if live else []), "-l", "PLAY_SIZE", *([] if live else [TIP]), "--", "scripts/*.gd"], capture_output=True).stdout.decode()
    candidates = {line.split(":", 1)[1] if not live else line for line in found.splitlines()}  # one git grep instead of reading every script
    defs = {p: re.findall(r"^const\s+PLAY_SIZE\s*:=\s*Vector2i\((\d+),\s*(\d+)\)", text(p), re.M) for p in candidates}
    assert {p: d for p, d in defs.items() if d} == {BOARD: [("18", "10")]}, "PLAY_SIZE defined once, in lab_heightfield.gd, as 18x10"
    readers = {p for p in candidates if "PLAY_SIZE" in strip_comments(text(p))}
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
    found = subprocess.run(["git", "-c", "core.quotepath=false", "-C", str(root), "grep", *(["--untracked"] if live else []), "-l", "battlefield.glb", *([] if live else [TIP]), "--", "tests/scripts/*.gd"], capture_output=True).stdout.decode()
    assert not [p for p in found.splitlines() if "battlefield.glb" in strip_comments(text(p.split(":", 1)[1] if not live else p))], "no test loads battlefield.glb"
    # Block 8: Grok's files as delivered, then only the instructed lines.
    for p in LOOK_AS_DELIVERED | {WATER}:
        assert live or blob(p, TIP) == blob(p, LOOK_A), "look pass file as delivered: " + p
    changed_look = dict((l.split("\t", 1)[1], l.split("\t", 1)[0]) for l in git("diff", "--no-renames", "--name-status", LOOK_BASE, LOOK_A).decode().splitlines())
    assert set(changed_look) == {BUILDER, PREVIEW, WATER, WATER + ".uid", *LOOK_AS_DELIVERED}, ("look pass A: the zip's files only", sorted(changed_look))
    removed, added = diff(BUILDER, a=LOOK_A)
    assert sorted(x.strip() for x in removed) == sorted(["var contour_wave: float = absf(fract(elev * 7.5) - 0.5) * 2.0", "ok = False", "chosen_ok = True",
                                                        "@export_range(1, 6, 1) var forest_trees_per_cell_min: int = 2", "@export_range(1, 6, 1) var forest_trees_per_cell_max: int = 4"]) \
        and sorted(x.strip() for x in added) == sorted(["var contour_wave: float = absf(fposmod(elev * 7.5, 1.0) - 0.5) * 2.0", "ok = false", "chosen_ok = true",
                                                        "@export_range(1, 6, 1) var forest_trees_per_cell_min: int = 1", "@export_range(1, 6, 1) var forest_trees_per_cell_max: int = 3"]), ("builder: three compile fixes and two density defaults only", removed, added)
    for path, allowed in [(PREVIEW, ["OUTER_GROUND = preload(", "field.outer_ground_texture = OUTER_GROUND"]),
                          (PRESENTATION, ["OUTER_GROUND = preload(", "field.outer_ground_texture = OUTER_GROUND", 'background_color=Color("8d897a")'])]:
        removed, added = diff(path, a=LOOK_A)
        assert len(added) == len(allowed) and all(any(a in x for x in added) for a in allowed) and len(removed) == len(allowed) - 2, (path, "block 8: the outer ground (and the background colour) only", removed, added)
    assert f'preload("res://{OUTER}")' in text(PRESENTATION) and f'preload("res://{OUTER}")' in text(PREVIEW), "the game lab and the preview load the same outer ground"
    assert "mipmaps/generate=true" in text(OUTER + ".import"), "the outer ground is imported with mipmaps"
    for p in ["tests/scripts/test_battle3d_block7_defaults.gd", "tests/scripts/test_battle3d_block7_triangle_budget.gd"]:
        now, then = strip_comments(text(p)), strip_comments(text(p, at=LOOK_BASE))
        assert now.count("expect(") >= then.count("expect("), (p, "block 8 changed expectations, checks not reduced", then.count("expect("), now.count("expect("))
    removed, added = diff("tests/scripts/test_battle3d_block7_triangle_budget.gd", a=LOOK_BASE)
    assert [x for x in removed if x.startswith("const ")] == ["const BACKGROUND_MAX := 7488"] and "const BACKGROUND_MAX := 12000" in "\n".join(added) \
        and all(f"const {k}" in text("tests/scripts/test_battle3d_block7_triangle_budget.gd") for k in ["TERRAIN_MAX := 28800", "TREES_MAX := 16000", "TREE_MAX := 200"]), "triangle budget: only the background ceiling moved (12,000)"
    assert 'var haze_color: Color = Color("8d897a")' in text(BUILDER) and 'background_color=Color("8d897a")' in text(PRESENTATION), "background = haze colour"
    git("diff", "--check", *rev)
    print(f"TERRAIN_PORT validator PASS: base={BASE} delivered={DELIVERED} scope={TIP}; {len(changes)} paths; no new engine read or write; PLAY_SIZE once, {len(readers)} reader files")


if __name__ == "__main__":
    main()
