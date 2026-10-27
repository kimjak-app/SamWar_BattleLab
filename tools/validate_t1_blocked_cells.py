"""T1: cells no unit may enter. The engine's grid holds a blocked-cell list (empty by default), its movement service
refuses a blocked cell in is_cell_walkable (a unit already on one may leave it), and the 3D engine lab hands the forest
cells to the engine with one new write.

Pinned scope (on top of 0947281, integration with block 6a): BattleGridController (blocked_cells, set_blocked_cells,
is_blocked: additions only), BattleMovementQueryService (two added lines in is_cell_walkable, nothing else), the engine
lab (forest_cells and the one set_blocked_cells line: additions only), three new tests, this validator, its report and
the CI list. Every other engine, service, 2D, scene, data and asset file unchanged.

Engine writes from the 3D lab: the base's 15 (engine.call names, each as often as before) plus set_blocked_cells once,
on the engine's own grid controller (queries.grid = engine.get("battle_grid_controller"), an existing read) = 16. No new
engine.call or engine.get name.

T1_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree; HEAD audits the
live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "0947281bc9b1c6f964fe6ed63da5ce835d4b9309"  # Merge branch 'feature/hud-block6a-roster-option-20261027' into integration
TIP = os.environ.get("T1_SCOPE_TIP", "631973846c80ac8972210313ab0782e417113c4f")  # test(battle): T1 blocked-cell tests, validator and CI lines
GRID = "scripts/battle_grid_controller.gd"
SERVICE = "scripts/battle/services/battle_movement_query_service.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
TESTS = ["tests/scripts/test_battle_blocked_cells.gd", "tests/scripts/test_battle3d_t1_blocked_cells.gd", "tests/scripts/test_battle_t1_enemy_ai_blocked.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_t1_blocked_cells.py"
REPORT = "agent/T1_BLOCKED_CELLS_RESULT_20261027.md"
NEW = {VALIDATOR, REPORT, *TESTS, *(p + ".uid" for p in TESTS)}
MODIFIED = {GRID, SERVICE, LAB, WORKFLOW}
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
NEW_WRITE = "set_blocked_cells"


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
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *TESTS]), "workflow: the three tests and this validator added"

    # The engine change: the grid's list (additions only) and two lines in is_cell_walkable.
    removed, added = diff(GRID)
    assert not removed, ("grid controller: additions only", removed)
    grid = text(GRID)
    assert "var blocked_cells: Dictionary = {}" in grid and "func set_blocked_cells(cells: Array) -> void:" in grid and "func is_blocked(cell: Vector2i) -> bool:" in grid, "the blocked-cell list"
    assert "\treturn blocked_cells.has(cell)" in grid, "is_blocked reads the list only"
    removed, added = diff(SERVICE)
    assert not removed and [x.strip() for x in added] == ["if grid_controller.is_blocked(cell):", "return false"], ("service: two lines added", removed, added)
    service = text(SERVICE)
    walk = re.search(r"^func is_cell_walkable\(.*?(?=^func )", service, re.M | re.S).group(0)
    order = ["not grid_controller.is_in_bounds(cell)", "if cell == start_cell:", "if grid_controller.is_blocked(cell):", "return not is_cell_occupied_except("]
    assert [walk.index(x) for x in order] == sorted(walk.index(x) for x in order), "is_cell_walkable: bounds, start cell, blocked, occupied"

    # The 3D lab: one new write, nothing else to the engine.
    lab, lab_base = text(LAB), text(LAB, base=True)
    removed, added = diff(LAB)
    assert not removed, ("lab: additions only", removed)
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    gets = lambda code: re.findall(r'engine\.get\("(\w+)"\)', code)
    assert sorted(calls(strip_comments(lab))) == sorted(calls(strip_comments(lab_base))), "no engine.call name added or removed"
    assert sorted(set(gets(strip_comments(lab)))) == sorted(set(gets(strip_comments(lab_base)))), "no new engine.get name"
    assert [calls(lab).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes as before"
    writes = [w for w in FIFTEEN if w in calls(lab)]
    new_writes = re.findall(r"\b(\w+)\.(" + NEW_WRITE + r")\(", strip_comments(lab))
    assert new_writes == [("grid", NEW_WRITE)] and 'queries.grid = engine.get("battle_grid_controller")' in lab, ("one set_blocked_cells on the engine grid", new_writes)
    assert NEW_WRITE not in strip_comments(lab_base), "the new write is new"
    assert len(writes) + len(new_writes) == 16, ("15 + 1 = 16 engine writes", len(writes), len(new_writes))
    assert "func forest_cells() -> Array:" in lab and 'board.terrain(Vector2i(x, y)) == "forest"' in lab, "forest cells from the lab's terrain types"
    git("diff", "--check", *rev)
    print(f"T1 validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; blocked-cell list + is_cell_walkable; engine writes 15 + set_blocked_cells = 16")


if __name__ == "__main__":
    main()
