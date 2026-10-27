"""T2: the play area's forest as two 6-cell groves with 32 Tripo pines (16 a grove, 2-3 a cell).

Pinned scope (on top of 1050ff7, the T1 branch tip): the pine GLB and its import files (from experiment pine500), the
board builder (the GLB link, forest_tree_count and the grove placement), terrain_types.json (play-area forest cells
only), the triangle budget test's one-tree limit (200 -> 500, approved 10-27), the tests that pinned the old forest
cells, the forest fade test marked skipped (additions only), the T1 reference helper's uid, the new T2 test and its
helper, this validator, its report and the CI list. The engine, the 3D lab and every other file unchanged.

terrain_types.json: outside the 18x10 play area nothing changes; inside it only forest changes: the old forest cells
become plain and exactly two 2x3/3x2 rectangles become forest (12 cells; a grove may reuse old forest cells).

T2_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree; HEAD audits the
live worktree.
"""
from pathlib import Path
import argparse, json, os, re, subprocess

BASE = "1050ff73b1ecfc64aaf194e537f066dd620157ae"  # docs(battle): T1 report: causes of the last two failures (forest overlap)
TIP = os.environ.get("T2_SCOPE_TIP", "1e13012b2de8db46513924334b2357843e767482")  # test(battle3d): T2 grove test reads C1 from terrain_types.json itself
BUILDER = "scripts/battle3d/terrain_board_builder.gd"
TERRAIN = "assets/battle3d/terrain_types.json"
BUDGET = "tests/scripts/test_battle3d_block7_triangle_budget.gd"
FADE = "tests/scripts/test_battle3d_look12_forest_fade.gd"
REPOINTED = ["tests/scripts/test_battle3d_block7_defaults.gd", "tests/scripts/test_battle3d_block7_old_play_area.gd",
             "tests/scripts/test_battle3d_t1_blocked_cells.gd", "tests/scripts/test_battle_blocked_cells.gd"]
PINE = "assets/battle3d/pine/"
TEST = "tests/scripts/test_battle3d_t2_forest_groves.gd"
HELPER = "tests/scripts/support/battle3d_t2_groves.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_t2_forest_groves.py"
REPORT = "agent/T2_FOREST_GROVES_RESULT_20261028.md"
NEW = {TEST, TEST + ".uid", HELPER, HELPER + ".uid", "tests/scripts/support/battle3d_blocked_reference.gd.uid", VALIDATOR, REPORT}
MODIFIED = {BUILDER, TERRAIN, BUDGET, FADE, WORKFLOW, *REPOINTED}
PLAY = (18, 10)


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
        assert (p in MODIFIED and status == "M") or ((p in NEW or p.startswith(PINE)) and status == "A"), ("out of scope", status, p)
    assert {PINE + "pine_typeA_500tris_slim050.glb", PINE + "pine_typeA_500tris_slim050.glb.import"} <= set(changes), "the pine GLB and its import"
    assert not [p for p in changes if p.startswith(("scripts/battle/", "scripts/battle_")) or p == "scripts/battle3d/battle3d_engine_play.gd"], "engine and lab unchanged"

    # terrain_types.json: play-area forest only; two 6-cell rectangles of former plain.
    old, new = json.loads(text(TERRAIN, base=True)), json.loads(text(TERRAIN))
    assert {k: v for k, v in old.items() if k != "cells"} == {k: v for k, v in new.items() if k != "cells"}, "only the cells change"
    moved = []
    for y, row in enumerate(new["cells"]):
        for x, kind in enumerate(row):
            was = old["cells"][y][x]
            if x < PLAY[0] and y < PLAY[1]:
                assert kind == was or {was, kind} == {"forest", "plain"}, ("play cell: forest <-> plain only", x, y, was, kind)
                if kind == "forest": moved.append((x, y))
            else:
                assert kind == was, ("scenery cell changed", x, y, was, kind)
    left, right = [c for c in moved if c[0] < 9], [c for c in moved if c[0] >= 9]
    for grove in (left, right):
        xs, ys = sorted({c[0] for c in grove}), sorted({c[1] for c in grove})
        assert len(grove) == 6 and len(xs) * len(ys) == 6 and sorted(map(len, (xs, ys))) == [2, 3], ("a 2x3 or 3x2 grove", grove)
        assert xs == list(range(xs[0], xs[-1] + 1)) and ys == list(range(ys[0], ys[-1] + 1)), ("a rectangle", grove)

    # The builder: the pine link, the tree count, the grove limits, the defaults that keep trees inside the play area.
    builder = text(BUILDER)
    for line in ['const FOREST_TREE_GLB := "res://assets/battle3d/pine/pine_typeA_500tris_slim050.glb"', "@export var forest_tree_count: int = 32",
                 "const GROVE_MIN_SPACING := 1.2", "const GROVE_MAX_OVERHANG := 0.5", "@export var forest_trees_outside_play: bool = false",
                 "@export var scatter_boundary_trees: bool = false", "@export var scatter_inner_trees: bool = true",
                 "forest_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON"]:
        assert line in builder, ("builder", line)
    assert "func _grove_tree_placements(" in builder and "func _forest_groves(" in builder and "static func _mesh_from_glb(" in builder, "grove placement and GLB link"
    assert "_sweep_tree_transforms" not in builder and "SWEEP_" not in builder, "the experiment's outside-play sweep is not taken"

    # Tests: the budget's one-tree limit only; the fade test additions only; the new test in the CI list.
    removed, added = diff(BUDGET)
    assert [x.strip() for x in removed] == ["# and <= 200 each.", "const TREE_MAX := 200"] and any("const TREE_MAX := 500" in x for x in added), ("budget: TREE_MAX only", removed)
    budget = text(BUDGET)
    assert "const TREES_MAX := 16000" in budget and "const BACKGROUND_MAX := 12000" in budget and "const TERRAIN_MAX := 28800" in budget, "budget ceilings unchanged"
    removed, added = diff(FADE)
    assert not removed and any("SKIP" in x for x in added), ("fade test: skip lines added, nothing removed", removed)
    for p in REPOINTED:
        removed, added = diff(p)
        assert len(removed) <= 6, ("re-pointed test: small change", p, removed)
    if WORKFLOW in changes:
        removed, added = diff(WORKFLOW)
        assert not removed and sorted(x.strip() for x in added) == sorted([TEST, VALIDATOR]), ("workflow: the T2 test and this validator added", added)
    git("diff", "--check", *rev)
    print(f"T2 validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; groves {sorted(left)} + {sorted(right)}; builder 32 trees, 1.2 m, 0.5 m")


if __name__ == "__main__":
    main()
