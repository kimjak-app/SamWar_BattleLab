"""HUD block 4-6: the battlefield's duplicate text hidden (F3 debug toggle), the acting side in the TurnHud, unit markers
(face, troop bar and number, acted darkening, selection), facing arrows on the ground and status badges.

Pinned scope (on top of 886426a, block 4-4 pushed): the lab (debug text, F3), the engine lab (markers, arrows, turn side,
debug lines), the shell (the side to the top HUD), the top HUD script (the side in the TurnHud title), the new marker
script, four new tests, this validator, its report and the CI list. Engine, services, adapter (VIEW_FIELDS), host, 2D,
scenes, other HUD files, goldens, data and assets unchanged (no new image); existing tests unchanged.

No new engine read and no command: the lab's engine.call / engine.get name sets are the base's (the markers use the
display values, N2 hud_portrait and N5 hud_status_entries already there) and the 15 writes are counted as before.

UNIT_MARKERS_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file list from that commit's tree;
HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "886426a00b854fcdca59f106c96806e25c69bed2"  # ci: per-test timeout 120s -> 300s (feature/hud-block44-edge-scroll-20261026, pushed)
TIP = os.environ.get("UNIT_MARKERS_SCOPE_TIP", "65f392cb7012d029df3e38e29ad3fdf045072025")  # test(battle3d): HUD block 4-6 tests, validator and CI lines
PRESENTATION = "scripts/battle3d/lab_presentation.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
TOP_HUD = "scripts/battle3d/battle3d_top_hud.gd"
MARKERS = "scripts/battle3d/battle3d_unit_markers.gd"
NEW_TESTS = ["tests/scripts/test_battle3d_block46_debug_text.gd", "tests/scripts/test_battle3d_block46_unit_markers.gd",
             "tests/scripts/test_battle3d_block46_facing_ground.gd", "tests/scripts/test_battle3d_block46_marker_mouse.gd"]
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_unit_markers.py"
REPORT = "agent/HUD_BLOCK46_UNIT_MARKER_RESULT_20261027.md"
NEW = {MARKERS, MARKERS + ".uid", VALIDATOR, REPORT, *NEW_TESTS, *(p + ".uid" for p in NEW_TESTS)}
MODIFIED = {PRESENTATION, LAB, SHELL, TOP_HUD, WORKFLOW}
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
    assert not [p for p in changes if p.startswith("tests/") and p not in NEW], "existing tests unchanged"
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
    for path in [PRESENTATION, SHELL, TOP_HUD]:
        assert not re.search(r"engine\.(call|set)\(|engine\.\w+\s*=", strip_comments("\n".join(diff(path)[1]))), path + ": no engine command"
    assert "engine" not in strip_comments(text(MARKERS)), "the marker script has no engine access"

    # Commit A: hidden, not removed; F3; the side in the TurnHud.
    presentation = text(PRESENTATION)
    assert "static var debug_text_visible := false" in presentation and "if event.keycode==KEY_F3:" in presentation and 'label.set_meta("unit_info",true)' in presentation, "debug text off by default, F3"
    removed, added = diff(PRESENTATION)
    assert not [x for x in removed if x.strip()], ("the lab: nothing removed", removed)
    lab = text(LAB)
    assert "action_badges.visible = debug_text_visible" in lab and "const HIDE_TOP_LINES := false" in lab, "the state lines through their parent; the top lines kept shown"
    assert not [x for x in diff(LAB)[0] if x.strip()], ("the engine lab: nothing removed", diff(LAB)[0])
    assert 'return "적군 턴" if engine.get("current_phase") == "enemy_turn" or _enemy_presentation_busy() else "아군 턴"' in lab, "the acting side"
    assert "top_hud.show_side(lab.hud_turn_side())" in text(SHELL) and 'get_node("ProductionHudRoot/TopHudRoot/TurnHud/Frame")' in text(TOP_HUD), "the side in the TurnHud title"
    # Commit B / C: markers, arrows, badges.
    markers = text(MARKERS)
    assert re.search(r"^const LAYER := 0\b", markers, re.M) and markers.count("MOUSE_FILTER_IGNORE") >= 2 and "MOUSE_FILTER_STOP" not in markers and "MOUSE_FILTER_PASS" not in markers, "markers: layer 0, the mouse passes"
    assert 'float(current) / float(most)' in markers and '"%d / %d" % [current, int(value.get("max_troops", 0))]' in markers and "ACTED if bool(value.get(\"has_acted\", false)) else READY" in markers, "bar, number, acted"
    assert "const MAX_BADGES := 3" in markers and '"+%d" % (status_badges.size() - MAX_BADGES)' in markers, "badges: three, then +n"
    assert "unit_markers.show_unit(id, display_values.get(id, {}), hud_portrait(id) if on else null, id == selected" in lab and "hud_status_entries(id)" in lab, "the markers use the display values, N2 and N5"
    assert 'arrow.rotation = Vector3(0, atan2(-direction.x, -direction.z), 0)' in lab and 'if child.has_meta("facing_arrow"): _place_facing_arrow(child, root, value.facing)' in lab, "facing arrows from the engine facing"
    git("diff", "--check", *rev)
    print(f"UNIT_MARKERS validator PASS: base={BASE} scope={TIP}; {len(changes)} paths; no new engine read or write; debug text hidden (F3), side, markers, arrows, badges")


if __name__ == "__main__":
    main()
