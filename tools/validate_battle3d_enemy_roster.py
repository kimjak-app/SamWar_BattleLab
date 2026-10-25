"""HUD block 3: the 2D enemy roster on the 3D shell, with the four approved new reads N1-N4.

Pinned scope (on top of the H1 inventory commit): a new roster scene (the 2D
`EnemyRosterHud` subtree copied as is) and fill script, additions to the
scenario shell, the lab's read functions, one new test, this validator, its
report and the CI list. Engine, services, adapter (VIEW_FIELDS untouched), host,
2D scenes, goldens, data, assets, other tests and validators unchanged.

The lab gains exactly the approved reads and no command, so the 15 engine
writes stay as they are:
  N1 the unit field `display_name` (read in the lab, never added to VIEW_FIELDS);
  N2 `_get_closeup_portrait_texture_for_unit` (once per unit);
  N3 `_get_troop_icon_texture_for_visual_key` (again only when facing changes);
  N4 `_get_formation_status_summary_text` (only while no enemy replay is pending).
The block 2 log read (`battle_log_lines`) is not on this branch. The shell builds
the cards in one function (`enemy_cards()`) from lab values and those reads.

ENEMY_ROSTER_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file
list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "2b082703f9f43dffe16b9720fac2fb28b477fa3e"  # docs(battle3d): H1 inventory of the 2D HUD for the 3D port (read only)
TIP = os.environ.get("ENEMY_ROSTER_SCOPE_TIP", "84c655825325e94b920c704043354e9b17f3f35e")  # feat(battle3d): HUD block 3 ...
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SCENE = "scenes/battle3d/Battle3D_EnemyRosterHud.tscn"
SCRIPT = "scripts/battle3d/battle3d_enemy_roster_hud.gd"
TEST = "tests/scripts/test_battle3d_enemy_roster.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_enemy_roster.py"
REPORT = "agent/HUD_BLOCK3_ENEMY_ROSTER_RESULT_20261025.md"
PRODUCTION = "scenes/battle/Battle_Production.tscn"
NEW = {SCENE, SCRIPT, SCRIPT + ".uid", TEST, TEST + ".uid", VALIDATOR, REPORT}
MODIFIED = {SHELL, LAB, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/battle3d/battle3d_unit_adapter.gd",
                      "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scripts/battle3d/battle3d_top_hud.gd", "scenes/battle/", "scenes/battle3d/Battle3D_EnginePlayLab.tscn",
                      "scenes/battle3d/Battle3D_ScenarioShell.tscn", "scenes/battle3d/Battle3D_TopHud.tscn", "tests/golden/", "data/", "assets/"]
APPROVED_CALLS = ["_get_closeup_portrait_texture_for_unit", "_get_formation_status_summary_text", "_get_troop_icon_texture_for_visual_key"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
SHELL_LAB_CALLS = ["hud_display_name", "hud_enemy_unit_ids", "hud_portrait", "hud_status_summary", "hud_troop_icon", "hud_unit_type_name"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def blocks(lines):
    starts = [i for i, l in enumerate(lines) if l.startswith("[")] + [len(lines)]
    return [lines[a:b] for a, b in zip(starts, starts[1:])]


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |^const |^var |\Z)", code, re.M | re.S)}


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
    for p in [SCENE, SCRIPT, TEST, VALIDATOR]:
        assert p in tree, "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/adapter/scene/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    assert not [p for p in changes if p.startswith("tests/") and p not in (TEST, TEST + ".uid")], "existing tests and harnesses unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"

    # The lab: additions only; the new engine reads are exactly N1-N4; no command added.
    lab_diff = git("diff", "--unified=0", *rev, "--", LAB).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in lab_diff.splitlines()), "lab: additions only"
    added = strip_comments("\n".join(x[1:] for x in lab_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    new_calls = sorted(set(re.findall(r'engine\.call\("(\w+)"', lab_now)) - set(re.findall(r'engine\.call\("(\w+)"', lab_base)))
    assert new_calls == APPROVED_CALLS, ("new engine calls must be N2-N4 exactly", new_calls)
    assert sorted(set(re.findall(r'engine\.call\("(\w+)"', added))) == APPROVED_CALLS, "the added lines call exactly N2-N4"
    assert not set(re.findall(r'engine\.call\("(\w+)"', added)) & set(FIFTEEN), "no write command added"
    assert set(re.findall(r'engine\.get\("(\w+)"\)', added)) <= {"all_battle_unit_states"}, "no new engine property read (all_battle_unit_states is an existing read)"
    assert set(re.findall(r'engine\.get\("(\w+)"\)', lab_now)) == set(re.findall(r'engine\.get\("(\w+)"\)', lab_base)), "engine.get names unchanged"
    assert "battle_log_lines" not in lab_now, "the block 2 log read is not on this branch"
    assert re.findall(r"\bunit\.display_name\b", added) == ["unit.display_name"], "N1: the display_name field, read once in hud_display_name"
    f = functions(lab_now)
    assert "if not hud_portraits.has(unit_id):" in f["hud_portrait"], "N2 once per unit"
    assert "cached[0] != unit.facing" in f["hud_troop_icon"], "N3 again only when facing changes"
    assert "if not _enemy_presentation_busy() or not hud_status_texts.has(unit_id):" in f["hud_status_summary"], "N4 only while no enemy replay is pending"
    adapter = text("scripts/battle3d/battle3d_unit_adapter.gd")
    assert "display_name" not in adapter, "VIEW_FIELDS untouched (no display_name)"

    # The scene: the 2D EnemyRosterHud subtree as is.
    prod_lines = text(PRODUCTION, base=True).split("\n")
    prod = blocks(prod_lines)
    hud = blocks(text(SCENE).split("\n"))
    want = [[re.sub(r" unique_id=\d+", "", b[0]).replace('parent="BattleUI/ProductionHudRoot', 'parent="ProductionHudRoot')] + b[1:] for b in prod
            if b[0].startswith("[node ") and (('name="EnemyRosterHud"' in b[0] and 'parent="BattleUI/ProductionHudRoot"' in b[0]) or 'parent="BattleUI/ProductionHudRoot/EnemyRosterHud' in b[0])]
    got = [b for b in hud if b[0].startswith("[node ") and 'parent="ProductionHudRoot' in b[0]]
    clean = lambda bs: [[l for l in b if l.strip()] for b in bs]
    assert len(want) == 70 and clean(got) == clean(want), "scene nodes == the 2D EnemyRosterHud subtree (70 nodes)"
    for eid in ["35_unique_skill_ready_icon", "38_battle_ui_theme", "43_roster_panel_frame_full"]:
        line = [l for l in prod_lines if l.startswith("[ext_resource") and f'id="{eid}"' in l]
        assert len(line) == 1 and line[0] in text(SCENE), "same resource as the 2D: " + eid
    for sid in ["RosterHeaderIconStyle", "RosterHeaderTransparentStyle"]:
        w = [b for b in prod if b[0].startswith("[sub_resource") and f'id="{sid}"' in b[0]]
        g = [b for b in hud if b[0].startswith("[sub_resource") and f'id="{sid}"' in b[0]]
        assert len(w) == 1 and clean(g) == clean(w), "same style as the 2D: " + sid

    # The fill script: no engine access; the 2D card rules.
    fill = strip_comments(text(SCRIPT))
    assert "engine" not in fill and not re.search(RANDOM, fill) and ".call(" not in fill, "fill script: no engine access"
    assert '"UniqueSkillReadyIcon"' in fill and "if cards == shown: return" in fill and "Color(1.0, 0.86, 0.46, 0.98)" in fill, "ready icon hidden, apply on change, 2D gold frame"

    # The shell: additions only; no engine access; cards from lab values and the lab's read functions only.
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in sh_diff.splitlines()), "shell: additions only"
    sh_added = strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    assert "engine" not in sh_added and not re.search(RANDOM, sh_added), "shell additions: no engine access, no random"
    assert sorted(set(re.findall(r"\blab\.(\w+)\(", sh_added))) == SHELL_LAB_CALLS, sorted(set(re.findall(r"\blab\.(\w+)\(", sh_added)))
    git("diff", "--check", *rev)
    print(f"ENEMY_ROSTER validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; engine/service/adapter/2D scene diff 0; "
          f"new reads = N1 display_name + {', '.join(APPROVED_CALLS)}; no write added; scene == 2D EnemyRosterHud (70 nodes)")


if __name__ == "__main__":
    main()
