"""HUD polish 1-A: the lab's debug "부대 상태" text moved off-screen by the scenario shell.

Pinned scope (on top of integration 150d179): the shell gains one code line that
moves `lab.roster_label` to x = LAB_OFFSCREEN_X inside `_place_lab_commands`
(once per lab, like the lab's auto/speed buttons), plus comments; one new test,
this validator, its report and the CI list. The lab and every other file
unchanged: the node and its text stay (the lab tests read the text); no engine
access, no engine read or write added.

LAB_ROSTER_OFFSCREEN_SCOPE_TIP=<commit> audits BASE..commit and reads every file
and file list from that commit's tree; HEAD audits the live worktree.
"""
from pathlib import Path
import argparse, os, re, subprocess

BASE = "150d179928a4b0d56d49d4ea9f1c9f6788427f1d"  # Merge feature/hud-read-proposals-20261024 (docs)
TIP = os.environ.get("LAB_ROSTER_OFFSCREEN_SCOPE_TIP", "HEAD")
SHELL = "scripts/battle3d/battle3d_scenario_shell.gd"
TEST = "tests/scripts/test_battle3d_lab_roster_label_offscreen.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_lab_roster_label_offscreen.py"
REPORT = "agent/HUD_POLISH1_A_LAB_LABEL_RESULT_20261025.md"
NEW = {TEST, TEST + ".uid", VALIDATOR, REPORT}
MODIFIED = {SHELL, WORKFLOW}


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
    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(p, "A")
        tree = set(git("ls-files").decode().splitlines()) | {p for p, s in changes.items() if s == "A"}
    else:
        tree = set(git("ls-tree", "-r", "--name-only", TIP).decode().splitlines())
    for p, status in changes.items():
        assert (p in MODIFIED and status == "M") or (p in NEW and status == "A"), ("out of scope: only the shell, the new test, this validator, its report and the CI list", status, p)
    assert TEST in tree and VALIDATOR in tree, "files in the audited tree"
    wf_diff = git("diff", "--unified=0", *rev, "--", WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in wf_diff.splitlines()), "workflow additions only"
    assert sorted(x[1:].strip() for x in wf_diff.splitlines() if x.startswith("+") and not x.startswith("+++")) == sorted([VALIDATOR, TEST]), "workflow: the test and this validator"
    sh_diff = git("diff", "--unified=0", *rev, "--", SHELL).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in sh_diff.splitlines()), "shell: additions only"
    code = [x for x in strip_comments("\n".join(x[1:] for x in sh_diff.splitlines() if x.startswith("+") and not x.startswith("+++"))).split("\n") if x.strip()]
    assert code == ["\tlab.roster_label.position.x = LAB_OFFSCREEN_X"], ("shell: the one off-screen line only", code)
    shell = (root / SHELL).read_text(encoding="utf-8") if live else git("show", f"{TIP}:{SHELL}").decode("utf-8")
    place = shell[shell.index("func _place_lab_commands()"):shell.index("func toggle_option_box()")]
    assert "lab.roster_label.position.x = LAB_OFFSCREEN_X" in place and "commands_lab = lab" in place, "inside the once-per-lab placement"
    git("diff", "--check", *rev)
    print(f"LAB_ROSTER_OFFSCREEN validator PASS: base={BASE[:7]} scope={TIP}; {len(changes)} paths; one shell line moves the lab roster_label off-screen; lab and engine untouched")


if __name__ == "__main__":
    main()
