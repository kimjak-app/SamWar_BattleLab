"""HUD block 4-1: the 2D ally roster and current-actor panel on the 3D shell, with the approved new reads N5, N6 and the hero data registry.

Pinned scope (on top of integration d1a91bf): a new ally roster scene (the 2D
`AllyRosterHud` subtree copied as is) and fill script, a current-actor wrapper
scene (the 2D `CurrentActorInfoHud.tscn` instanced unchanged) and fill script
(the 2D bridge's run-time layout ported, no engine access), a read-only hero data
reader, additions to the scenario shell and to the lab's read functions, one new
test, this validator, its report and the CI list. Engine, services, adapter
(VIEW_FIELDS untouched), host, 2D scenes, the block 3 roster, goldens, data,
assets, other tests and validators unchanged.

The lab gains exactly two new engine calls and no command, so the 15 engine
writes stay as they are:
  N5 `_get_unit_status_display_entries` (a deep copy, only while no enemy replay is pending);
  N6 `_get_hero_id_for_unit_state` (a string copy).
Its other added calls are names the lab already calls (`_can_use_unique_skill`,
`_get_unique_skill_for_unit`, `_get_troop_icon_texture_for_visual_key`). The
registry (`hero_design_data_registry.gd`, outside the engine) is read only in the
reader file, with exactly get_base_stats / get_battle_profile /
get_unique_skill_for_hero, each a deep copy; the lab and the shell have no
world-map text.

ALLY_ROSTER_ACTOR_SCOPE_TIP=<commit> audits BASE..commit and reads every file and
file list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "d1a91bfacb9c33e292563ea7b6b84340c294741a"  # integration: blocks 1-3 and the read proposals
TIP = os.environ.get("ALLY_ROSTER_ACTOR_SCOPE_TIP", "2fe5f060ff6afdcf305a98b58da29fc6d28c2543")  # feat(battle3d): HUD block 4-1 ally roster and current-actor panel
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
ROSTER_SCENE = "scenes/battle3d/Battle3D_AllyRosterHud.tscn"
ROSTER_SCRIPT = "scripts/battle3d/battle3d_ally_roster_hud.gd"
ACTOR_SCENE = "scenes/battle3d/Battle3D_CurrentActorHud.tscn"
ACTOR_SCRIPT = "scripts/battle3d/battle3d_current_actor_hud.gd"
READER = "scripts/battle3d/battle3d_hero_data_reader.gd"
TEST = "tests/scripts/test_battle3d_ally_roster_actor.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_ally_roster_actor.py"
REPORT = "agent/HUD_BLOCK41_ALLY_ROSTER_ACTOR_RESULT_20261025.md"
PRODUCTION = "scenes/battle/Battle_Production.tscn"
CA = "scripts/battle/presentation/production/battle_current_actor_hud_controller.gd"
LEGEND = "scripts/battle/presentation/production/battle_status_empty_legend_controller.gd"
REGISTRY = "res://scripts/worldmap/hero_design_data_registry.gd"
GD_NEW = [ROSTER_SCRIPT, ACTOR_SCRIPT, READER, TEST]
NEW = {ROSTER_SCENE, ACTOR_SCENE, VALIDATOR, REPORT, *GD_NEW, *(p + ".uid" for p in GD_NEW)}
MODIFIED = {SHELL, LAB, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/worldmap/", "scripts/battle3d/battle3d_unit_adapter.gd",
                      "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scripts/battle3d/battle3d_top_hud.gd", "scripts/battle3d/battle3d_top_commands.gd", "scripts/battle3d/battle3d_log_hud.gd",
                      "scripts/battle3d/battle3d_enemy_roster_hud.gd", "scenes/battle/", "scenes/battle3d/Battle3D_EnginePlayLab.tscn",
                      "scenes/battle3d/Battle3D_ScenarioShell.tscn", "scenes/battle3d/Battle3D_TopHud.tscn", "scenes/battle3d/Battle3D_LogHud.tscn",
                      "scenes/battle3d/Battle3D_EnemyRosterHud.tscn", "tests/golden/", "data/", "assets/"]
NEW_CALLS = ["_get_hero_id_for_unit_state", "_get_unit_status_display_entries"]
ADDED_CALLS = ["_can_use_unique_skill", "_get_hero_id_for_unit_state", "_get_troop_icon_texture_for_visual_key", "_get_unique_skill_for_unit", "_get_unit_status_display_entries"]
REGISTRY_CALLS = ["get_base_stats", "get_battle_profile", "get_unique_skill_for_hero"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
SHELL_LAB_CALLS = ["hud_active_unit_id", "hud_ally_actor_id", "hud_ally_unit_ids", "hud_display_name", "hud_hero_id", "hud_portrait", "hud_skill_ready",
                   "hud_status_entries", "hud_status_summary", "hud_troop_icon", "hud_troop_icon_for_key", "hud_unique_skill", "hud_unit_type_name"]
SHELL_READER_CALLS = ["base_stats", "battle_profile", "current_actor_portrait", "portrait_country", "resolve_hero_id", "unique_skill_for_hero"]
WORLDMAP = r"(?i)world_?map"
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def blocks(lines):
    starts = [i for i, l in enumerate(lines) if l.startswith("[")] + [len(lines)]
    return [lines[a:b] for a, b in zip(starts, starts[1:])]


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |^const |^var |^static var |\Z)", code, re.M | re.S)}


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

    def added_lines(path):
        diff = git("diff", "--unified=0", *rev, "--", path).decode("utf-8")
        assert not any(x.startswith("-") and not x.startswith("---") for x in diff.splitlines()), path + ": additions only"
        return strip_comments("\n".join(x[1:] for x in diff.splitlines() if x.startswith("+") and not x.startswith("+++")))

    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    for p in [ROSTER_SCENE, ROSTER_SCRIPT, ACTOR_SCENE, ACTOR_SCRIPT, READER, TEST, VALIDATOR]:
        assert p in tree, "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/2D scene/block 3/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    assert not [p for p in changes if p.startswith("tests/") and p not in (TEST, TEST + ".uid")], "existing tests and harnesses unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"

    # The lab: additions only; the new engine call names are N5 and N6 exactly; no command added; the 15 writes as they were.
    added = added_lines(LAB)
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    assert sorted(set(calls(lab_now)) - set(calls(lab_base))) == NEW_CALLS, ("new engine call names must be N5 and N6 exactly", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert sorted(set(calls(added))) == ADDED_CALLS, ("added lines: N5, N6 and names the lab already calls", sorted(set(calls(added))))
    assert not set(calls(added)) & set(FIFTEEN), "no write command added"
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    assert set(re.findall(r'engine\.get\("(\w+)"\)', added)) <= {"all_battle_unit_states", "active_unit_state", "current_phase"}, "only existing property reads"
    assert set(re.findall(r'engine\.get\("(\w+)"\)', lab_now)) == set(re.findall(r'engine\.get\("(\w+)"\)', lab_base)), "engine.get names unchanged"
    assert not re.search(WORLDMAP, added), "lab: no world-map text"
    f = functions(lab_now)
    assert "if not _enemy_presentation_busy() or not hud_status_entry_lists.has(unit_id):" in f["hud_status_entries"] and ".duplicate(true)" in f["hud_status_entries"], "N5: deep copy, only while no enemy replay is pending"
    assert "String(engine.call(\"_get_hero_id_for_unit_state\", unit))" in f["hud_hero_id"], "N6: a string copy"
    assert "\"ally_turn\", \"facing_select\", \"attack_select\", \"unique_skill_target_select\", \"strategy\"" in lab_now, "the 2D ally actor phases"
    adapter = text("scripts/battle3d/battle3d_unit_adapter.gd")
    assert adapter == text("scripts/battle3d/battle3d_unit_adapter.gd", base=True), "adapter (VIEW_FIELDS) untouched"

    # The reader: the registry's three approved reads only, deep copies, the 2D alias table; no engine access.
    reader = strip_comments(text(READER))
    assert re.findall(r'preload\("([^"]+)"\)', reader) == [REGISTRY], "reader: the registry preload only"
    assert sorted(set(re.findall(r"\bRegistry\.(\w+)\(", reader))) == REGISTRY_CALLS, ("reader: exactly the three approved registry reads", sorted(set(re.findall(r"\bRegistry\.(\w+)\(", reader))))
    assert all(f"Registry.{c}(hero_id).duplicate(true)" in reader for c in REGISTRY_CALLS), "reader: every registry value is a deep copy"
    assert "engine" not in reader and ".call(" not in reader and not re.search(RANDOM, reader), "reader: no engine access"
    alias = lambda code: re.search(r"HERO_ID_ALIASES := \{(.*?)\}", code, re.S).group(1).split()
    assert alias(reader) == alias(text(CA, base=True)), "reader: the 2D bridge's hero id alias table"
    assert 'res://assets/heroes/portraits/current_actor/%s/%s_%s.png' in reader and '["korea", "china", "japan", "mongol"]' in reader, "reader: the 2D current-actor portrait rule"

    # The ally roster scene: the 2D AllyRosterHud subtree as is.
    prod_lines = text(PRODUCTION, base=True).split("\n")
    prod = blocks(prod_lines)
    hud = blocks(text(ROSTER_SCENE).split("\n"))
    want = [[re.sub(r" unique_id=\d+", "", b[0]).replace('parent="BattleUI/ProductionHudRoot', 'parent="ProductionHudRoot')] + b[1:] for b in prod
            if b[0].startswith("[node ") and (('name="AllyRosterHud"' in b[0] and 'parent="BattleUI/ProductionHudRoot"' in b[0]) or 'parent="BattleUI/ProductionHudRoot/AllyRosterHud' in b[0])]
    got = [b for b in hud if b[0].startswith("[node ") and 'parent="ProductionHudRoot' in b[0]]
    clean = lambda bs: [[l for l in b if l.strip()] for b in bs]
    assert len(want) == 70 and clean(got) == clean(want), "scene nodes == the 2D AllyRosterHud subtree (70 nodes)"
    for eid in ["35_unique_skill_ready_icon", "38_battle_ui_theme", "43_roster_panel_frame_full"]:
        line = [l for l in prod_lines if l.startswith("[ext_resource") and f'id="{eid}"' in l]
        assert len(line) == 1 and line[0] in text(ROSTER_SCENE), "same resource as the 2D: " + eid
    for sid in ["RosterHeaderIconStyle", "RosterHeaderTransparentStyle"]:
        w = [b for b in prod if b[0].startswith("[sub_resource") and f'id="{sid}"' in b[0]]
        g = [b for b in hud if b[0].startswith("[sub_resource") and f'id="{sid}"' in b[0]]
        assert len(w) == 1 and clean(g) == clean(w), "same style as the 2D: " + sid

    # The current-actor scene: the 2D CurrentActorInfoHud.tscn instanced unchanged under a ProductionHudRoot at the 2D offset.
    actor_scene = text(ACTOR_SCENE)
    assert 'path="res://scenes/battle/ui/CurrentActorInfoHud.tscn"' in actor_scene and '[node name="CurrentActorInfoHud" parent="ProductionHudRoot" instance=' in actor_scene, "the 2D panel scene instanced"
    assert "offset_left = -3.0\noffset_top = 2.0" in actor_scene and len([b for b in blocks(actor_scene.split("\n")) if b[0].startswith("[node ")]) == 3, "wrapper: CanvasLayer, ProductionHudRoot (-3, 2), the instance; no override"

    # The fill scripts: no engine access; the 2D rules; every node ignores the mouse.
    roster_fill, actor_fill = strip_comments(text(ROSTER_SCRIPT)), strip_comments(text(ACTOR_SCRIPT))
    for code in (roster_fill, actor_fill):
        assert "engine" not in code and not re.search(RANDOM.replace("|shuffle", ""), code) and ".call(" not in code and not re.search(WORLDMAP, code), "fill script: no engine access"
        assert "mouse_filter = Control.MOUSE_FILTER_IGNORE" in code and "_ignore_mouse(get_node(\"ProductionHudRoot\"))" in code, "fill script: every node ignores the mouse"
    assert '"UniqueSkillReadyIcon"' in roster_fill and "if cards == shown: return" in roster_fill and "Color(1.0, 0.86, 0.46, 0.98)" in roster_fill, "roster: ready icon, apply on change, 2D gold frame"
    ca = text(CA, base=True)
    for m in re.finditer(r'_set_control_offsets\(hud, "([^"]+)", ([\d.]+), ([\d.]+), ([\d.]+), ([\d.]+)\)', ca):
        assert f'_offsets("{m.group(1)}", {m.group(2)}, {m.group(3)}, {m.group(4)}, {m.group(5)})' in actor_fill, "panel: the 2D offset of " + m.group(1)
    for m in re.finditer(r'_sync_bound_texture\(hud, "([^"]+)", (ICON_\w+), "(\w+)"', ca):
        assert f'_bound("{m.group(1)}", {m.group(2)}, "{m.group(3)}"' in actor_fill, "panel: the 2D static icon " + m.group(3)
    for m in re.finditer(r'const (ICON_\w+|UNIQUE_SKILL_READY_BADGE) := preload\("([^"]+)"\)', ca):
        assert f'const {m.group(1)} := preload("{m.group(2)}")' in actor_fill, "panel: the 2D texture " + m.group(1)
    for line in [l.strip() for l in text(LEGEND, base=True).split("\n") if l.strip().startswith('{"text":')]:
        assert line in text(ACTOR_SCRIPT), "panel: the 2D empty-status legend item " + line
    for v in ['"평지"', '"방어 0%"', '"이동 0%"', "Vector2(122.0, -18.0)", "Vector2(84.0, 84.0)", "0.88 + 0.12 * sin(float(Time.get_ticks_msec()) / 220.0)", "if actor == shown: return"]:
        assert v in actor_fill, "panel: " + v

    # The shell: additions only; no engine access; values from the lab's reads and the reader only.
    sh_added = added_lines(SHELL)
    assert "engine" not in sh_added and not re.search(RANDOM, sh_added) and not re.search(WORLDMAP, sh_added), "shell additions: no engine access, no random, no world-map text"
    assert sorted(set(re.findall(r"\blab\.(\w+)\(", sh_added))) == SHELL_LAB_CALLS, sorted(set(re.findall(r"\blab\.(\w+)\(", sh_added)))
    assert sorted(set(re.findall(r"\bHeroData\.(\w+)\(", sh_added))) == SHELL_READER_CALLS, sorted(set(re.findall(r"\bHeroData\.(\w+)\(", sh_added)))
    assert 'preload("res://scripts/battle3d/battle3d_hero_data_reader.gd")' in sh_added, "shell: the reader"
    git("diff", "--check", *rev)
    print(f"ALLY_ROSTER_ACTOR validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter/2D scene/block 3 diff 0; "
          f"new engine reads = {', '.join(NEW_CALLS)}; registry reads = {', '.join(REGISTRY_CALLS)} (reader only); 15 writes unchanged; scene == 2D AllyRosterHud (70 nodes)")


if __name__ == "__main__":
    main()
