"""T3: the three paths outside the move search refuse a blocked cell, the way each already refuses an occupied or
out-of-bounds cell: the candidate is dropped, and with no candidate left the unit stays. No new path search.

Pinned scope (on top of 8d16003, the T2 split tip): the engine in exactly three places and nothing else,
  - battle_web_import_test.gd _apply_resolver_advance_toward_target: its one destination condition gains
    "and not battle_grid_controller.is_blocked(destination)" (one line replaced);
  - battle_web_import_test.gd _apply_resolver_retreat_move: two lines added after the bounds check
    (if battle_grid_controller.is_blocked(destination): return);
  - battle_production_controller.gd _get_post_skill_reposition_valid_cells: two lines added after the range check
    (if battle_grid_controller.is_blocked(candidate): continue);
two new tests, this validator, its report and the CI list. The 3D lab, the grid, the movement service, every other
engine, scene, data and test file unchanged; is_blocked is called in exactly these three places outside the service.

T3_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree; HEAD audits the
live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "8d1600330ce7df4fb0f3b3b79c693c9e03e0dd18"  # test(battle3d): T2 validator: the split report is in scope
TIP = os.environ.get("T3_SCOPE_TIP", "16738b17ead42188b995c832d41dc3f5bc8b9b93")  # test(battle): T3 validator and CI lines
ENGINE = "scripts/battle_web_import_test.gd"
PRODUCTION = "scripts/battle/battle_production_controller.gd"
TESTS = ["tests/scripts/test_battle_t3_blocked_paths.gd", "tests/scripts/test_battle3d_t3_blocked_paths.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_t3_blocked_all_paths.py"
REPORT = "claude/REPORT_T3_20261029.md"
NEW = {VALIDATOR, REPORT, *TESTS, *(p + ".uid" for p in TESTS)}
MODIFIED = {ENGINE, PRODUCTION, WORKFLOW}
ADVANCE_OLD = "\tif battle_grid_controller.is_in_bounds(destination) and _is_valid_destination_for_unit(destination, caster_state, true):"
ADVANCE_NEW = "\tif battle_grid_controller.is_in_bounds(destination) and not battle_grid_controller.is_blocked(destination) and _is_valid_destination_for_unit(destination, caster_state, true):"
RETREAT_NEW = ["\tif battle_grid_controller.is_blocked(destination):", "\t\treturn"]
REDEPLOY_NEW = ["\t\tif battle_grid_controller.is_blocked(candidate):", "\t\t\tcontinue"]


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def body(source, name):
    return re.search(r"^func " + name + r"\(.*?(?=^func |\Z)", source, re.M | re.S).group(0)


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
        d = git("diff", "--unified=0", *rev, "--", path).decode("utf-8").replace("\r\n", "\n").splitlines()
        return [x[1:] for x in d if x.startswith("-") and not x.startswith("---")], [x[1:] for x in d if x.startswith("+") and not x.startswith("+++")]

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *TESTS]), ("workflow: the two tests and this validator added", removed, added)

    # The engine: one replaced line in advance, two added lines in retreat.
    engine, engine_base = text(ENGINE), text(ENGINE, base=True)
    removed, added = diff(ENGINE)
    assert removed == [ADVANCE_OLD] and added == [ADVANCE_NEW, *RETREAT_NEW], ("engine: advance condition and retreat check only", removed, added)
    assert ADVANCE_NEW in body(engine, "_apply_resolver_advance_toward_target"), "the advance condition is in advance"
    retreat = body(engine, "_apply_resolver_retreat_move")
    order = ["if not battle_grid_controller.is_in_bounds(destination):", RETREAT_NEW[0].strip(), "if not _is_valid_destination_for_unit(destination, unit_state, true):"]
    assert [retreat.index(x) for x in order] == sorted(retreat.index(x) for x in order), "retreat: bounds, blocked, occupied"
    # The production controller: two added lines in the redeploy candidates.
    production = text(PRODUCTION)
    removed, added = diff(PRODUCTION)
    assert not removed and added == REDEPLOY_NEW, ("production: the redeploy check only", removed, added)
    redeploy = body(production, "_get_post_skill_reposition_valid_cells")
    order = ["if battle_grid_controller.get_distance(origin_cell, candidate) > reposition_range:", REDEPLOY_NEW[0].strip(), "if not _is_valid_destination_for_unit(candidate, caster_state, false):"]
    assert [redeploy.index(x) for x in order] == sorted(redeploy.index(x) for x in order), "redeploy: range, blocked, occupied"

    # is_blocked outside the movement service: exactly the three new places.
    calls = lambda code: len(re.findall(r"\bis_blocked\(", strip_comments(code)))
    assert calls(engine_base) == 0 and calls(text(PRODUCTION, base=True)) == 0, "no is_blocked call in the base engine files"
    assert calls(engine) == 2 and calls(production) == 1, ("three is_blocked calls", calls(engine), calls(production))
    git("diff", "--check", *rev)
    print(f"T3 validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; advance, retreat, redeploy refuse a blocked cell (3 is_blocked calls)")


if __name__ == "__main__":
    main()
