"""S1-1 checkpoint guard, including unstaged/staged/untracked changes."""
from pathlib import Path
import argparse
import json
import os
import re
import subprocess
import sys

BASE = "62f5b726260aa3e6134225e7e903b1098792f23a"
# Scope is pinned to the S1-1 commit so later stages (S1-2+) can change controllers
# without breaking this guard. S1_1_SCOPE_TIP=HEAD restores the old live-worktree check.
TIP = os.environ.get("S1_1_SCOPE_TIP", "af8e365d85ccd524ee010fe8eabc972ce1cd82dd")
WORKFLOW = ".github/workflows/verify-c-track.yml"
ALLOWED = {
    "scripts/battle/services/battle_event_log_service.gd",
    "scripts/battle/services/battle_state_fingerprint_service.gd",
    "tests/scripts/test_battle_move_oracle_baseline.gd",
    "tests/scripts/test_battle_event_log_service.gd",
    "tests/scripts/test_battle_state_fingerprint_service.gd",
    "tests/golden/battle_move_baseline_v0.json",
    "tools/validate_battle_s1_1_observation_baseline.py",
    "agent/BATTLE_ENGINE_S1_0_ACTION_EVENT_AUDIT_20261019.md",
    "agent/BATTLE_ENGINE_EVENT_SCHEMA_MIN_v0_20261019.md",
    "agent/BATTLE_ENGINE_S1_1_RESULT_20261019.md",
}
ALLOWED |= {p + ".uid" for p in list(ALLOWED) if p.endswith(".gd")}
CONTROLLERS = ["scripts/battle_web_import_test.gd", "scripts/battle/battle_controller.gd"]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()

    def require(ok, message):
        if not ok:
            raise ValueError(message)

    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])

    require(git("cat-file", "-t", BASE).strip() == b"commit", "base missing")
    live = TIP == "HEAD"
    revs = [BASE] if live else [BASE, TIP]
    if not live:
        require(git("cat-file", "-t", TIP).strip() == b"commit", "pinned S1-1 tip missing")
    changes = {}
    for line in git("diff", "--no-renames", "--name-status", *revs, "--").decode().splitlines():
        status, path = line.split("\t", 1)
        changes[path] = status
    if live:
        for path in git("ls-files", "--others", "--exclude-standard").decode().splitlines():
            changes.setdefault(path, "A")
    require(changes.get(WORKFLOW) == "M", "workflow must include S1-1 calls")
    for path, status in changes.items():
        if path == WORKFLOW:
            require(status == "M", "workflow must be modification only")
            count = git("diff", "--numstat", *revs, "--", WORKFLOW).decode().split()
            require(len(count) >= 3 and count[1] == "0", "workflow deleted/rewritten lines")
            patch = git("diff", "--unified=0", *revs, "--", WORKFLOW).decode()
            additions = [s[1:].strip() for s in patch.splitlines() if s.startswith("+") and not s.startswith("+++")]
            expected = {"tools/validate_battle_s1_1_observation_baseline.py", "tests/scripts/test_battle_event_log_service.gd", "tests/scripts/test_battle_state_fingerprint_service.gd", "tests/scripts/test_battle_move_oracle_baseline.gd"}
            require(set(additions) == expected and len(additions) == 4, "workflow must add exactly the four S1-1 calls")
        else:
            require(status == "A", f"non-addition forbidden: {status} {path}")
            require(path in ALLOWED or path.startswith("tests/scripts/support/"), f"outside scope: {path}")
    for path in CONTROLLERS:
        current = (root / path).read_bytes() if live else git("show", f"{TIP}:{path}")
        require(current == git("show", f"{BASE}:{path}"), f"controller bytes changed: {path}")
    for name in ["battle_event_log_service", "battle_state_fingerprint_service"]:
        path = root / "scripts/battle/services" / (name + ".gd")
        source = path.read_text(encoding="utf-8")
        code = "\n".join(line.split("#", 1)[0] for line in source.splitlines())
        require(re.search(r"^extends RefCounted$", code, re.M), f"not RefCounted: {name}")
        forbidden = re.search(r"\b(Node\w*|SceneTree|await|Tween|signal|AudioStream\w*|ResourceLoader|get_tree)\b", code)
        require(forbidden is None, f"forbidden token in {name}: {forbidden.group(0) if forbidden else ''}")
        require(not re.search(r"\b(?:load|preload)\s*\([^\n]*\.(?:tscn|scn)", code), f"scene load in {name}")
        uid = path.with_suffix(".gd.uid")
        require(uid.exists() and uid.read_text().strip().startswith("uid://"), f"missing UID: {name}")
    for path in ALLOWED:
        require((root / path).exists(), f"missing required file: {path}")
    baseline = json.loads((root / "tests/golden/battle_move_baseline_v0.json").read_text(encoding="utf-8"))
    require(baseline["base_commit"] == BASE and baseline["schema_version"] == 0, "golden base/schema")
    require([s["case"] for s in baseline["scenarios"]] == ["M1", "M2", "M3_occupied", "M3_range", "M3_no_path", "M4", "M5"], "golden scenario coverage")
    m4 = next(s for s in baseline["scenarios"] if s["case"] == "M4")
    start, finish, reverted = m4["checkpoints"]
    require(reverted["units"][0]["last_action"] == finish["units"][0]["last_action"] != start["units"][0]["last_action"], "M4 must preserve last_action non-restoration")
    git("diff", "--check", *revs, "--")
    print(f"S1_1_OBSERVATION_BASELINE PASS: {len(changes)} paths; controllers byte-identical; workflow +4/-0; golden 5 scenarios / 7 cases")


if __name__ == "__main__":
    try:
        main()
    except (ValueError, OSError, KeyError, subprocess.CalledProcessError) as error:
        print(f"S1_1_OBSERVATION_BASELINE FAIL: {error}", file=sys.stderr)
        sys.exit(1)
