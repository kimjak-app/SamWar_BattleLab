"""HUD block 6a: the option box clear of the HUD and above it, retreated roster cards kept (dimmed, "퇴각"), the 2D roster
side banners and their fold, and a test for two holes of the block 4-6d sweep test.

Pinned scope (on top of 3cb836b, block 4-6d): the shell (option box place and layer, retreated cards, the banner pulse),
the two roster scripts (retreat tint and text, the fold), the new fold script, three earlier tests changed on one line
each where they read the old rule (top commands: the option box's x; enemy roster: a card follows its unit view; ally
roster: every node ignores the mouse), four new tests, this validator, its report and the CI list. Engine, services,
adapter, host, lab, 2D, scenes, goldens, data, assets, the command panel and the unit markers unchanged.

No new engine read and no command: the lab is not changed (its engine.call / engine.get names and the 15 writes are the
base's); the roster scripts and the fold script have no engine access; the shell adds none. The fold takes its numbers
from the 2D presentation controller and the 2D banner nodes (checked here against those files).

ROSTER_OPTION_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "3cb836be216ff4d657a86a2f03174f2b8880f820"  # docs(battle3d): HUD block 4-6d test fixes and panel reach report
TIP = os.environ.get("ROSTER_OPTION_SCOPE_TIP", "39aeb65abcf24839a07ea58751f7333f138a0ef4")  # test(battle3d): HUD block 6a tests, validator and CI lines
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
ALLY = "scripts/battle3d/battle3d_ally_roster_hud.gd"
ENEMY = "scripts/battle3d/battle3d_enemy_roster_hud.gd"
FOLD = "scripts/battle3d/battle3d_roster_fold.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
TWOD_FOLD = "scripts/battle/presentation/production/battle_roster_presentation_controller.gd"
TWOD_SCENE = "scenes/battle/Battle_Production.tscn"
CHANGED_TESTS = {"tests/scripts/test_battle3d_top_commands.gd": "enemy_roster.roster_rect().position.x", "tests/scripts/test_battle3d_enemy_roster.gd": "u.current_troops <= 0",
                 "tests/scripts/test_battle3d_ally_roster_actor.gd": "AllyRosterSideBanner"}
NEW_TESTS = ["tests/scripts/test_battle3d_block6a_option_box.gd", "tests/scripts/test_battle3d_block6a_roster_retreat.gd",
             "tests/scripts/test_battle3d_block6a_roster_fold.gd", "tests/scripts/test_battle3d_block6a_panel_body_gap.gd"]
UNCHANGED = ["scripts/battle3d/battle3d_command_panel.gd", "scripts/battle3d/battle3d_unit_markers.gd", "tests/scripts/test_battle3d_block46d_panel_sweep.gd",
             "tests/scripts/test_battle3d_option_ai_level.gd", "tests/scripts/test_battle3d_option_ai_level_auto.gd", "tests/scripts/test_battle3d_option_strategy_gaps.gd",
             "tests/scripts/test_battle3d_edge_scroll_gates.gd", "tests/scripts/test_battle3d_block46b_marker_layout.gd", "tests/scripts/test_battle3d_command_panel.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_roster_option.py"
REPORT = "agent/HUD_BLOCK6A_ROSTER_OPTION_RESULT_20261027.md"
NEW = {VALIDATOR, REPORT, FOLD, FOLD + ".uid", *NEW_TESTS, *(p + ".uid" for p in NEW_TESTS)}
MODIFIED = {SHELL, ALLY, ENEMY, WORKFLOW, *CHANGED_TESTS}
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
    for p in UNCHANGED:
        assert p not in changes, "unchanged: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    removed, added = diff(WORKFLOW)
    assert not removed and sorted(x.strip() for x in added) == sorted([VALIDATOR, *NEW_TESTS]), "workflow: the four tests and this validator added"

    # No engine access: the lab unchanged (above), none in the roster scripts or the fold, none added to the shell.
    for path in [ALLY, ENEMY, FOLD]:
        assert "engine" not in strip_comments(text(path)), path + ": no engine access"
    assert not re.search(r"engine", strip_comments("\n".join(diff(SHELL)[1]))), "the shell: no engine access added"

    # Commit A: the option box placed clear of the HUD and on a layer above it; the lab's own build untouched.
    shell = text(SHELL)
    assert re.search(r"^const OPTION_LAYER := (\d+)", shell, re.M) and int(re.search(r"^const OPTION_LAYER := (\d+)", shell, re.M).group(1)) > 10, "option layer above the HUD (5-10)"
    assert "(box.get_parent() as CanvasLayer).layer = OPTION_LAYER" in shell and "box.position = option_box_position(" in shell and "func option_box_position(size: Vector2) -> Vector2:" in shell, "option box"
    assert shell.index("func _place_lab_commands()") < shell.index("func toggle_option_box()"), "the shell's function order kept"
    # Commit B: retreated = 0 troops from the display value; the card kept.
    assert shell.count('var retreated: bool = not value.is_empty() and int(value.current_troops) <= 0') == 2 and shell.count('"visible":(lab.views.has(id) and lab.views[id].visible) or retreated, "retreated":retreated') == 2, "retreated cards"
    for path in [ALLY, ENEMY]:
        src = text(path)
        assert 'const RETREAT_TINT := Color(0.62, 0.62, 0.62, 0.72)' in src and 'const RETREAT_TEXT := "퇴각"' in src and 'if bool(card.get("retreated", false)): node.modulate = RETREAT_TINT' in src, path + ": retreat"
        assert "fold.show_cards(" in src and "if fold.collapsed: return fold.folded_rect()" in src, path + ": the fold"
    # Commit C: the fold's numbers are the 2D's.
    fold, twod = text(FOLD), text(TWOD_FOLD)
    for const in ["TRANSITION_DURATION", "PORTRAIT_SIZE", "PORTRAIT_STEP", "PORTRAIT_TOP"]:
        a = re.search(rf"^const {const} := (.+?)(\s*#.*)?$", fold, re.M).group(1).replace(".0", "")
        b = re.search(rf"^const {const} := (.+)$", twod, re.M).group(1).replace(".0", "")
        assert a == b, ("2D constant", const, a, b)
    assert re.search(r'Vector2\(4\.0, 115\.0\) if side_name == "Ally" else Vector2\(1856\.0, 115\.0\)', twod) and 'BANNER_FOLDED := {"ally":Vector2(4.0, 115.0), "enemy":Vector2(1856.0, 115.0)}' in fold, "folded banner = 2D"
    assert 'var x := 8.0 if side_name == "Ally" else 1840.0' in twod and 'PORTRAIT_X := {"ally":8.0, "enemy":1840.0}' in fold, "portrait column = 2D"
    assert "Color(0.62, 0.62, 0.62, 0.72)" in twod and "RETREAT_TINT := Color(0.62, 0.62, 0.62, 0.72)" in fold, "retreat tint = 2D"
    scene = text(TWOD_SCENE)
    for side, key in [("Ally", "ally"), ("Enemy", "enemy")]:
        block = scene[scene.index(f'[node name="{side}RosterSideBanner"'):]
        block = block[:block.index("\n[node ")]
        left, top = (float(re.search(rf"^offset_{k} = (.+)$", block, re.M).group(1)) for k in ["left", "top"])
        right, bottom = (float(re.search(rf"^offset_{k} = (.+)$", block, re.M).group(1)) for k in ["right", "bottom"])
        assert f'"{key}":Vector2({left}, {top})' in fold and "BANNER_SIZE := Vector2(%s, %s)" % (right - left, bottom - top) in fold, ("banner place = 2D tscn", side, left, top)
        assert f"roster_side_banner_{key}.png" in fold, "banner texture = 2D"
    assert "MOUSE_FILTER_STOP" in fold and fold.count("MOUSE_FILTER_STOP") == 1, "only the banner takes the mouse"
    # The earlier tests: one line each, checks kept.
    for path, needle in CHANGED_TESTS.items():
        removed, added = diff(path)
        assert len(removed) == 1 and 1 <= len(added) <= 2 and any(needle in x for x in added), ("one line changed", path, removed, added)
        assert strip_comments(text(path)).count("expect(") == strip_comments(text(path, base=True)).count("expect("), path + ": checks kept"
    git("diff", "--check", *rev)
    print(f"ROSTER_OPTION validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no engine access added; option layer/place, retreat cards, 2D fold numbers")


if __name__ == "__main__":
    main()
