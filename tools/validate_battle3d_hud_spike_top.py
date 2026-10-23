"""HUD spike: the 2D top HUD (momentum diamonds, "round / 30") on the 3D scenario shell.

Pinned scope: a new HUD scene + fill script, additions to the scenario shell,
one new test and this validator; 2D scenes, engine, services, adapter, host,
the lab (`battle3d_engine_play.gd` and its scene), goldens, existing tests,
harnesses and validators unchanged. The HUD scene is the 2D `TopHudRoot`
subtree copied as is (same nodes, values, textures, theme, five styleboxes).
The HUD script reads nothing from the engine and writes nothing; the shell's
added lines hand it only the lab's existing `momentum_display` and
`current_round` (no `engine` in any added line). No new random call.

HUD_SPIKE_SCOPE_TIP=<commit> audits BASE..commit and reads every file and file
list from that commit's tree; HEAD audits the live worktree (untracked included).
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "ba058c8a8e09f955230b5d48dd97e9de09074637"  # docs(battle): record the G0 const removal checks ...
TIP = os.environ.get("HUD_SPIKE_SCOPE_TIP", "f0e91dcfd268b77e7eceead9842ba2de887e5dfa")  # feat(battle3d): HUD spike ...
HUD_SCENE = "scenes/battle3d/Battle3D_TopHud.tscn"
HUD_SCRIPT = "scripts/battle3d/battle3d_top_hud.gd"
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
TEST = "tests/scripts/test_battle3d_top_hud.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_hud_spike_top.py"
PRODUCTION = "scenes/battle/Battle_Production.tscn"
GD = [HUD_SCRIPT, TEST]
NEW = {HUD_SCENE, VALIDATOR, *GD} | {p + ".uid" for p in GD}
MODIFIED = {SHELL, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_engine_play.gd", "scripts/battle3d/battle3d_unit_adapter.gd",
                      "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scenes/battle3d/Battle3D_EnginePlayLab.tscn", "scenes/battle3d/Battle3D_ScenarioShell.tscn", "scenes/battle/", "tests/golden/", "data/", "assets/"]
LAB_MEMBERS = {"momentum_display", "current_round", "ready_for_input", "battle_result", "turn_label", "momentum_label"}
STYLEBOXES = ["StyleBoxEmpty_top_hud_transparent", "AllyDiamondFilled", "AllyDiamondEmpty", "EnemyDiamondFilled", "EnemyDiamondEmpty"]
EXT_IDS = ["38_battle_ui_theme", "41_top_hud_frame_full", "42_turn_hud_title_medium"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"
FORBIDDEN = r"engine|(?<!refresh)\.call\(|\.get\(|\.set\(|get_tree|get_parent|Engine\.|FileAccess|ResourceSaver|JSON|change_scene|time_scale"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |\Z)", code, re.M | re.S)}


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def blocks(lines):
    # [header] + body lines up to the next header
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

    def raw(path, base=False):
        return (root / path).read_bytes() if live and not base else git("show", f"{BASE if base else TIP}:{path}")

    def text(path, base=False):
        return raw(path, base).decode("utf-8").replace("\r\n", "\n")

    # Scope: in pinned mode every list comes from the TIP tree, never the worktree.
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
    for p in NEW:
        assert p in tree and raw(p).strip(), "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "2D scene/engine/service/lab/adapter/host/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    assert not [p for p in changes if p.startswith("tests/") and p not in NEW], "existing tests, harnesses and goldens unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    added = [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added) == sorted([VALIDATOR, TEST]), added

    # The HUD scene is the 2D TopHudRoot subtree as is (2D scene read at BASE; it is protected, so TIP has the same bytes).
    prod = text(PRODUCTION, base=True).split("\n")
    hud = text(HUD_SCENE).split("\n")
    prod_blocks, hud_blocks = blocks(prod), blocks(hud)
    top = [b for b in prod_blocks if b[0].startswith("[node ") and ('name="TopHudRoot"' in b[0] or 'parent="BattleUI/ProductionHudRoot/TopHudRoot' in b[0])]
    norm = []
    for b in top:
        head = re.sub(r" unique_id=\d+", "", b[0]).replace('parent="BattleUI/ProductionHudRoot', 'parent="ProductionHudRoot')
        norm.append([head, *b[1:]])
    copied = [b for b in hud_blocks if b[0].startswith("[node ") and 'parent="ProductionHudRoot' in b[0]]
    assert len(norm) == 52 and [[l for l in b if l.strip()] for b in copied] == [[l for l in b if l.strip()] for b in norm], "HUD nodes == the 2D TopHudRoot subtree (52 nodes)"
    for sid in STYLEBOXES:
        want = [b for b in prod_blocks if b[0].startswith("[sub_resource") and f'id="{sid}"' in b[0]]
        got = [b for b in hud_blocks if b[0].startswith("[sub_resource") and f'id="{sid}"' in b[0]]
        assert len(want) == 1 and [[l for l in b if l.strip()] for b in got] == [[l for l in b if l.strip()] for b in want], "stylebox == 2D: " + sid
    for eid in EXT_IDS:
        want = [l for l in prod if l.startswith("[ext_resource") and f'id="{eid}"' in l]
        assert len(want) == 1 and want[0] in hud, "same texture/theme/font resource: " + eid
    ext = [l for l in hud if l.startswith("[ext_resource")]
    assert len(ext) == 4 and 'path="res://scripts/battle3d/battle3d_top_hud.gd"' in ext[0], "resources: the HUD script + the three 2D ones"
    root_nodes = [b for b in hud_blocks if b[0].startswith("[node ") and b not in copied]
    assert [b[0] for b in root_nodes] == ['[node name="Battle3DTopHud" type="CanvasLayer"]', '[node name="ProductionHudRoot" type="Control" parent="."]'], "own root + the 2D ProductionHudRoot wrapper"
    assert "layer = 5" in root_nodes[0] and "offset_left = -3.0" in root_nodes[1] and "offset_top = 2.0" in root_nodes[1] and "mouse_filter = 2" in root_nodes[1], "layer 5; 2D ProductionHudRoot offset (-3, 2)"
    for b in prod_blocks:
        if b[0].startswith('[node name="ProductionHudRoot"'):
            assert "offset_left = -3.0" in b and "offset_top = 2.0" in b, "2D ProductionHudRoot offset is (-3, 2)"

    # HUD script: values handed in only; 2D fill rule; "%d / %d" with the 2D adapter's MAX_TURN; apply only on change.
    code = strip_comments(text(HUD_SCRIPT))
    assert not re.search(RANDOM, code), "no random"
    assert not re.search(FORBIDDEN, code), "HUD reads/writes nothing: " + str(re.findall(FORBIDDEN, code))
    assert "const MAX_TURN := BattleHudStateAdapter.MAX_TURN" in code
    f = functions(code)
    show = f["show_values"]
    assert show.index("if values == shown: return") < show.index("_fill_slots") and 'turn_label().text = "%d / %d" % [round_value, MAX_TURN]' in show, "apply only on a change; 2D turn text"
    fill = f["_fill_slots"]
    assert "var active := index < value" in fill and 'panel.theme_type_variation = "MomentumSlot%s%s" % [side, "Filled" if active else "Empty"]' in fill \
        and '"_diamond_filled_style" if active else "_diamond_empty_style"' in fill and 'add_theme_stylebox_override(&"panel"' in fill and "panel.modulate = Color.WHITE" in fill, "2D fill rule"
    assert "process_priority = 100" in f["_ready"] and "refresh.call()" in f["_process"], "refresh after the lab's own _process"

    # Shell: additions only; added lines touch the lab's existing members only and never the engine.
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode() if not live else git("diff", "--unified=0", BASE, "--", SHELL).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in sh_diff.splitlines()), "shell: additions only"
    sh_added = strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    assert "engine" not in sh_added and not re.search(RANDOM, sh_added) and ".call(" not in sh_added, "shell additions: no engine access, no random"
    assert set(re.findall(r"\blab\.(\w+)", sh_added)) == LAB_MEMBERS, ("lab members used", set(re.findall(r"\blab\.(\w+)", sh_added)))
    assert re.findall(r"lab\.(\w+)\s*=[^=]", sh_added) == [] and sorted(re.findall(r"lab\.(\w+)\.visible\s*=", sh_added)) == ["momentum_label", "turn_label"], "only the two labels' visibility is set"
    shell = text(SHELL)
    sf = functions(strip_comments(shell))
    assert 'const TOP_HUD_SCENE := "res://scenes/battle3d/Battle3D_TopHud.tscn"' in shell and "var hide_lab_top_labels := true" in shell
    refresh = sf["_refresh_top_hud"]
    assert "lab.battle_result.is_empty()" in refresh and "top_hud.show_values(lab.momentum_display.ally, lab.momentum_display.enemy, lab.current_round)" in refresh, "lab values only; hidden once the battle has a result"
    assert "top_hud.refresh = _refresh_top_hud" in sf["_ready"]
    git("diff", "--check", *rev)
    print(f"HUD_SPIKE_TOP validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; 2D scene/engine/service/lab/adapter/host diff 0; "
          f"HUD scene == 2D TopHudRoot subtree ({len(norm)} nodes, 5 styleboxes, 3 resources); HUD reads/writes nothing; shell hands it lab values only")


if __name__ == "__main__":
    main()
