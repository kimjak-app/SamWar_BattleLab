"""HUD block 1: the 2D top command row (option, speed, auto, end turn, retreat) on the 3D shell.

Pinned scope (on top of the H1 inventory commit): a new command-row script,
additions to the scenario shell, one new test, this validator, its report and
the CI list. The lab (`battle3d_engine_play.gd` and its scene), engine,
services, adapter, host, every scene, goldens, data, assets, other tests and
validators unchanged, so the 15 engine writes stay as they are. The row calls
the lab's own functions only (request_auto, request_wait, cycle_speed,
toggle_option_panel); retreat is a picture with no handler; the shell's only
engine access added is the read the lab already makes
(`is_full_auto_battle_enabled`). No random.

TOP_COMMANDS_SCOPE_TIP=<commit> audits BASE..commit and reads every file and
file list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "2b082703f9f43dffe16b9720fac2fb28b477fa3e"  # docs(battle3d): H1 inventory of the 2D HUD for the 3D port (read only)
TIP = os.environ.get("TOP_COMMANDS_SCOPE_TIP", "923c149edf8be050a213f82701a271816b6f43fb")  # feat(battle3d): HUD block 1 ...
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
ROW = "scripts/battle3d/battle3d_top_commands.gd"
TEST = "tests/scripts/test_battle3d_top_commands.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_top_commands.py"
REPORT = "agent/HUD_BLOCK1_TOP_COMMANDS_RESULT_20261024.md"
NEW = {ROW, ROW + ".uid", TEST, TEST + ".uid", VALIDATOR, REPORT}
MODIFIED = {SHELL, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_engine_play.gd", "scripts/battle3d/battle3d_unit_adapter.gd",
                      "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scripts/battle3d/battle3d_top_hud.gd", "scenes/", "tests/golden/", "data/", "assets/"]
TEXTURES = ["res://assets/ui/battle/top_actions/auto_battle_button.png", "res://assets/ui/battle/top_actions/end_turn_button.png", "res://assets/ui/battle/top_actions/retreat_button.png"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |\Z)", code, re.M | re.S)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def text(path):
        data = (root / path).read_bytes() if live else git("show", f"{TIP}:{path}")
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
    for p in [ROW, TEST, VALIDATOR, SHELL]:
        assert p in tree, "missing in the audited tree: " + p
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "lab/engine/service/scene/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged"
    assert not [p for p in changes if p.startswith("tests/") and p not in (TEST, TEST + ".uid")], "existing tests and harnesses unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"

    # The row: reads nothing, writes nothing; the 2D textures; retreat a picture only.
    row = strip_comments(text(ROW))
    assert "engine" not in row and not re.search(RANDOM, row), "row: no engine access, no random"
    assert re.findall(r"\.call\(", row) == [".call(" for _ in re.findall(r"on_\w+\.call\(\)", row)], "row: only its own callables are called"
    assert all(t in row for t in TEXTURES), "the 2D top-action textures"
    assert "retreat_button.disabled = true" in row and "retreat_button.pressed.connect" not in row and 'const RETREAT_TOOLTIP := "월드맵 연결 후 사용"' in text(ROW), "retreat: disabled, no handler"
    assert "const FIRST_X := 1435.0" in row and "const ROW_Y := 27.0" in row and "const BUTTON_SIZE := Vector2(68.0, 68.0)" in row and "const BUTTON_GAP := 18.0" in row, "row geometry"

    # Shell: additions only; the buttons call the lab's own functions; the one engine read the lab already makes.
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in sh_diff.splitlines()), "shell: additions only"
    added = strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    assert not re.search(RANDOM, added)
    assert re.findall(r"engine\.(\w+)\(", added) == ["get"] and re.findall(r'engine\.get\("(\w+)"\)', added) == ["is_full_auto_battle_enabled"], "shell: one existing engine read only"
    calls = sorted(set(re.findall(r"\blab\.(\w+)\(", added)))
    assert calls == ["cycle_speed", "request_auto", "request_wait", "toggle_option_panel"], ("lab functions called", calls)
    f = functions(strip_comments(text(SHELL)))
    place = f["_place_lab_commands"]
    assert "button.position.x = LAB_OFFSCREEN_X" in place and "box.visible = false" in place and "lab.option_toggle.visible = false" in place, "lab auto/speed off-screen, option box closed"
    git("diff", "--check", *rev)
    print(f"TOP_COMMANDS validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; lab/engine/scene diff 0; row calls the lab's own functions; "
          f"retreat picture only; one existing engine read in the shell")


if __name__ == "__main__":
    main()
