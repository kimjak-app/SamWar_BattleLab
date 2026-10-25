"""HUD block 5: the 2D hero cut-in, battle toasts, still skill toast and ending video on the 3D shell.

Pinned scope (on top of feature/base-block41-merged-20261025 4a57108): a new
scene (the 2D RoundToastRoot, UniqueSkillToastRoot and HeroCutinOverlay nodes
copied, the overlay's layer 40 -> 9) and script, a read-only cut-in registry
reader, additions to the scenario shell and the lab, one new test, this
validator, its report and the CI list. Engine, services, adapter, host, 2D
scenes, the cut-in registry and scene, other HUD blocks, goldens, data and
assets (no new video file) unchanged.

No new engine read and no command: the lab's engine.call and engine.get name
sets are unchanged and the 15 writes stay as they are. The registry (outside the
engine) is read only in the reader file, with canonicalize_hero_id, find_entry
and get_static_fallback_image_path. The lab and the shell carry none of the
names the M5-c option-panel validator forbids (result_toast, result_video,
worldmap).

CUTIN_TOAST_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file
list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "4a57108cdc84c8ee0d8e022652c5d82b9404d1e1"  # Merge feature/test-strengthen-20261025 (base with block 4-1)
TIP = os.environ.get("CUTIN_TOAST_SCOPE_TIP", "HEAD")
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
LAB = "scripts/battle3d/battle3d_engine_play.gd"
SCENE = "scenes/battle3d/Battle3D_CutinToastHud.tscn"
SCRIPT = "scripts/battle3d/battle3d_cutin_toast_hud.gd"
READER = "scripts/battle3d/battle3d_cutin_reader.gd"
TEST = "tests/scripts/test_battle3d_cutin_result_toast.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_cutin_result_toast.py"
REPORT = "agent/HUD_BLOCK5_CUTIN_RESULT_TOAST_RESULT_20261025.md"
PRODUCTION = "scenes/battle/Battle_Production.tscn"
REGISTRY = "res://scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd"
GD_NEW = [SCRIPT, READER, TEST]
NEW = {SCENE, VALIDATOR, REPORT, *GD_NEW, *(p + ".uid" for p in GD_NEW)}
MODIFIED = {SHELL, LAB, WORKFLOW}
EXTRA_MODIFIED = set()  # existing tests changed (file:line and reason in the report)
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle_unit_state.gd", "scripts/ui/", "scripts/worldmap/", "scenes/ui/",
                      "scripts/battle3d/battle3d_unit_adapter.gd", "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd",
                      "scripts/battle3d/battle3d_movement_adapter.gd", "scripts/battle3d/battle3d_top_hud.gd", "scripts/battle3d/battle3d_top_commands.gd",
                      "scripts/battle3d/battle3d_log_hud.gd", "scripts/battle3d/battle3d_enemy_roster_hud.gd", "scripts/battle3d/battle3d_ally_roster_hud.gd",
                      "scripts/battle3d/battle3d_current_actor_hud.gd", "scripts/battle3d/battle3d_hero_data_reader.gd", "scenes/battle/", "scenes/battle3d/Battle3D_EnginePlayLab.tscn",
                      "scenes/battle3d/Battle3D_ScenarioShell.tscn", "tests/golden/", "tests/scripts/support/", "data/", "assets/"]
FIFTEEN = ["_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing", "_handle_right_click_cancel", "try_basic_attack",
           "_try_attack_enemy_target_from_attack_select", "_end_ally_turn_by_wait", "_on_defend_button_pressed", "_on_strategy_button_pressed",
           "_try_use_strategy_on_target", "_on_unique_skill_button_pressed", "_try_use_unique_skill_on_target", "_toggle_full_auto_battle",
           "set_auto_presentation_hold", "set_enemy_ai_level"]
REGISTRY_CALLS = ["canonicalize_hero_id", "find_entry", "get_static_fallback_image_path"]
FORBIDDEN = r"result_toast|result_video|world_?map|WorldMap"
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def blocks(lines):
    starts = [i for i, l in enumerate(lines) if l.startswith("[")] + [len(lines)]
    return [lines[a:b] for a, b in zip(starts, starts[1:])]


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
        assert (p in MODIFIED | EXTRA_MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope", status, p)
    for p in [SCENE, SCRIPT, READER, TEST, VALIDATOR]:
        assert p in tree, "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "engine/service/2D/registry/other HUD/golden/data/asset diff must be 0: " + p
        assert not p.endswith(".ogv"), "no video file copied: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"

    # The lab: no new engine call or property name; the 15 writes as they were; no forbidden name.
    lab_now, lab_base = strip_comments(text(LAB)), strip_comments(text(LAB, base=True))
    calls = lambda code: re.findall(r'engine\.call\("(\w+)"', code)
    assert set(calls(lab_now)) == set(calls(lab_base)), ("no new engine call name", sorted(set(calls(lab_now)) - set(calls(lab_base))))
    assert [calls(lab_now).count(w) for w in FIFTEEN] == [calls(lab_base).count(w) for w in FIFTEEN], "the 15 engine writes unchanged"
    assert set(re.findall(r'engine\.get\("(\w+)"\)', lab_now)) == set(re.findall(r'engine\.get\("(\w+)"\)', lab_base)), "engine.get names unchanged"
    lab_diff = git("diff", "--unified=0", *rev, "--", LAB).decode("utf-8")
    removed = [x[1:] for x in lab_diff.splitlines() if x.startswith("-") and not x.startswith("---")]
    added_lines = [x[1:] for x in lab_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert len(removed) == 1 and removed[0].strip().startswith("attack_button.disabled =") and any(l == removed[0] + " or hud_cutin_hold" for l in added_lines), ("lab: additions only, plus the attack button's hold term", removed)
    assert not re.search(FORBIDDEN, lab_now), "lab: no forbidden name"
    for line in ["if hud_cutin_hold: # HUD block 5", "if hud_cutin_enabled and event.kind == \"skill_cast\":", "if hud_cutin_hold or not hud_held_skill_events.is_empty(): return true"]:
        assert line in text(LAB), "lab hold: " + line

    # The reader: the registry's three reads only; no engine access.
    reader = strip_comments(text(READER))
    assert re.findall(r'preload\("([^"]+)"\)', reader) == [REGISTRY], "reader: the registry preload only"
    assert sorted(set(re.findall(r"\bRegistry\.(\w+)\(", reader))) == REGISTRY_CALLS, ("reader: the three registry reads", sorted(set(re.findall(r"\bRegistry\.(\w+)\(", reader))))
    assert "engine" not in reader and ".call(" not in reader and not re.search(RANDOM, reader), "reader: no engine access"

    # The scene: the 2D toast and cut-in nodes; only the overlay layer changed (40 -> 9).
    prod = blocks(text(PRODUCTION, base=True).split("\n"))
    scene = text(SCENE)
    def sub(name, parent):
        return [b for b in prod if b[0].startswith("[node ") and ((f'name="{name}" ' in b[0] and f'parent="{parent}"' in b[0]) or f'parent="{parent + "/" if parent != "." else ""}{name}' in b[0])]
    want = [[re.sub(r" unique_id=\d+", "", b[0]).replace('parent="BattleUI"', 'parent="ToastLayer"').replace('parent="BattleUI/', 'parent="ToastLayer/')] + b[1:]
            for b in sub("RoundToastRoot", "BattleUI") + sub("UniqueSkillToastRoot", "BattleUI")]
    want += [[re.sub(r" unique_id=\d+", "", b[0])] + ["layer = 9" if x == "layer = 40" else x for x in b[1:]] for b in sub("HeroCutinOverlay", ".")]
    got = [b for b in blocks(scene.split("\n")) if b[0].startswith("[node ") and "parent=" in b[0] and 'name="ToastLayer"' not in b[0]]
    clean = lambda bs: [[l for l in b if l.strip()] for b in bs]
    assert len(want) == 11 and clean(got) == clean(want), "scene nodes == the 2D toast (7) and cut-in overlay (4) nodes, overlay layer 9"
    assert '[node name="ToastLayer" type="CanvasLayer" parent="."]\nlayer = 8' in scene and 'path="res://scenes/ui/cutin/hero_cutin_presentation.tscn"' in scene, "toast layer 8; the shared 2D cut-in scene"

    # The HUD script: no engine access; the 2D timings.
    hud = strip_comments(text(SCRIPT))
    assert "engine" not in hud and ".call(\"" not in hud and not re.search(RANDOM, hud), "HUD script: no engine access"
    for v in ['"BATTLE %d"', '"지원군 도착!"', '"승리!"', '"패배"', "1.15, 0", "0.82, 100", "1.1 + RESULT_HOLD_EXTRA, 200", "const VIDEO_FALLBACK_SEC := 4.35", "presentation.play_cutin()", "presentation.set_playback_speed(speed)",
              "tween_method(_set_shader_progress, 0.0, 1.0, 0.42)", "tween_interval(hold)"]:
        assert v in hud, "HUD: " + v
    assert "GameAudio" not in hud, "HUD: toast sounds not played again (the engine plays them)"

    # The shell: no engine access, no forbidden name; the reader for the registry; the ending before the result panel.
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode("utf-8")
    sh_removed = [x[1:] for x in sh_diff.splitlines() if x.startswith("-") and not x.startswith("---")]
    assert sh_removed == ["\t_show_result()"], ("shell: additions, plus _show_result() -> _begin_ending() in _process", sh_removed)
    sh_added = strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    assert "engine" not in sh_added and not re.search(RANDOM, sh_added), "shell additions: no engine access, no random"
    assert not re.search(FORBIDDEN, strip_comments(text(SHELL))), "shell: no forbidden name"
    assert sorted(set(re.findall(r"\bCutinReader\.(\w+)\(", sh_added))) == ["canonical_hero", "entry_for", "fallback_image"], "shell: the reader's three functions"
    assert "lab.hud_cutin_enabled = true" in sh_added and "lab.hud_release_cutin_hold()" in sh_added, "shell: turns the lab hold on and releases it"
    git("diff", "--check", *rev)
    print(f"CUTIN_TOAST validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; no new engine read or write; registry read in the reader only; "
          f"no video copied; scene == 2D toast + cut-in nodes (11, overlay layer 9)")


if __name__ == "__main__":
    main()
