"""HUD label move (T1): the lab's round/momentum text labels moved under the HUD, not hidden.

Pinned scope (on top of the HUD spike): the scenario shell, the HUD script (one
read helper), the HUD spike test and the CI list (this validator); the lab
(`battle3d_engine_play.gd` and its scene), engine, services, adapter, host, 2D
scenes, the HUD scene, goldens, other tests, harnesses and validators
unchanged. The shell no longer hides the labels: it sets only their position,
size and minimum width, from the HUD frame rect, the labels' own text size and
the lab's info panel rect. No engine access, no random.

HUD_LABEL_MOVE_SCOPE_TIP=<commit> audits BASE..commit and reads every file and
file list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "eebb1040c6ff9b8d3583e9ea286ee2fce31f6fd1"  # docs(battle3d): HUD spike report ... (feature/hud-spike-top-20261023)
TIP = os.environ.get("HUD_LABEL_MOVE_SCOPE_TIP", "HEAD")
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
HUD_SCRIPT = "scripts/battle3d/battle3d_top_hud.gd"
TEST = "tests/scripts/test_battle3d_top_hud.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_hud_label_move.py"
REPORT = "agent/HUD_LABEL_MOVE_RESULT_20261024.md"
NEW = {VALIDATOR, REPORT}
MODIFIED = {SHELL, HUD_SCRIPT, TEST, WORKFLOW}
PROTECTED_PREFIXES = ["scripts/battle_web_import_test.gd", "scripts/battle/", "scripts/battle3d/battle3d_engine_play.gd", "scripts/battle3d/battle3d_unit_adapter.gd",
                      "scripts/battle3d/battle3d_engine_host.gd", "scripts/battle3d/lab_presentation.gd", "scripts/battle3d/battle3d_movement_adapter.gd",
                      "scenes/", "tests/golden/", "data/", "assets/"]
RANDOM = r"\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|pick_random|shuffle"


def functions(code):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^(?:static )?func (\w+)\(.*?(?=^(?:static )?func |\Z)", code, re.M | re.S)}


def strip_comments(source):
    return "\n".join(line.split("#", 1)[0].rstrip() for line in source.splitlines())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]

    def raw(path):
        return (root / path).read_bytes() if live else git("show", f"{TIP}:{path}")

    def text(path):
        return raw(path).decode("utf-8").replace("\r\n", "\n")

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
    assert VALIDATOR in tree and SHELL in tree and TEST in tree, "files in the audited tree"
    for p in changes:
        assert not any(p.startswith(x) for x in PROTECTED_PREFIXES), "lab/engine/service/adapter/host/scene/golden/data/asset diff must be 0: " + p
    assert not [p for p in changes if p.startswith("tools/") and p != VALIDATOR], "existing validators unchanged (the HUD spike validator stays pinned)"
    assert not [p for p in changes if p.startswith("tests/") and p != TEST], "other tests and harnesses unchanged"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert [x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")] == [VALIDATOR], "workflow: this validator only"

    # HUD script: one read helper added, nothing else.
    hud_diff = git("diff", "--unified=0", *rev, "--", HUD_SCRIPT).decode()
    hud_added = [x[1:] for x in hud_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert not any(x.startswith("-") and not x.startswith("---") for x in hud_diff.splitlines()), "HUD script: additions only"
    assert [x for x in hud_added if x.strip()] == ["func frame_rect() -> Rect2:", '\treturn get_node("ProductionHudRoot/TopHudRoot").get_global_rect()'], hud_added

    # Shell: no hiding left; label writes are position/size/min width only; lab members read are known UI ones.
    code = strip_comments(text(SHELL))
    assert "hide_lab_top_labels" not in code and not re.search(r"(turn_label|momentum_label|label)\.visible\s*=", code), "labels are never hidden"
    assert not re.search(RANDOM, code), "no random"
    f = functions(code)
    place = f["_place_lab_top_labels"]
    assert "engine" not in place and ".call(" not in place, "placement: no engine access"
    writes = sorted(set(re.findall(r"\blabel\.([\w.]+)\s*=[^=]", place)))
    assert writes == ["custom_minimum_size.x", "position", "size"], ("label writes", writes)
    assert set(re.findall(r"\blab\.(\w+)", place)) == {"info", "turn_label", "momentum_label"}, set(re.findall(r"\blab\.(\w+)", place))
    assert "top_hud.frame_rect()" in place and "frame.end.y + LAB_LABEL_GAP" in place and "frame.get_center().x - text_size.x * 0.5" in place and "left_limit" in place, "under the HUD frame, centred, right of the info panel"
    refresh = f["_refresh_top_hud"]
    assert "_place_lab_top_labels()" in refresh and "visible" not in refresh.split("top_hud.visible = live", 1)[1], "refresh places, never hides"
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode()
    sh_added = strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++")))
    assert "engine" not in sh_added, "shell additions: no engine access"
    git("diff", "--check", *rev)
    print(f"HUD_LABEL_MOVE validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; lab/engine/scene diff 0; labels never hidden; "
          f"label writes = position/size/min width only (from the HUD frame, text size, info panel); no engine access")


if __name__ == "__main__":
    main()
