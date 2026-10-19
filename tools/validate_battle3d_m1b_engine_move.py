"""M1-b immutable-engine and command-boundary guard. HEAD includes worktree."""
import os
import re
import subprocess
from pathlib import Path

BASE = "22b7ee73f567132ad1b8060adae4a4bb8d2f5e8c"
TIP = os.environ.get("M1B_SCOPE_TIP", "a91e1e0be0b56fda7ddd0b8832de891bea16cf22")
ROOT = Path(__file__).resolve().parents[1]
NEW = {
    "scripts/battle3d/battle3d_engine_host.gd",
    "scripts/battle3d/battle3d_engine_play.gd",
    "scenes/battle3d/Battle3D_EnginePlayLab.tscn",
    "tests/scripts/test_battle3d_engine_move_integration.gd",
    "tools/validate_battle3d_m1b_engine_move.py",
    "agent/BATTLE3D_M1B_RESULT_20261019.md",
}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
WORKFLOW = ".github/workflows/verify-c-track.yml"
CONTRACT = "tools/validate_battle3d_contract.py"

def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])

def main():
    live = TIP == "HEAD"
    revisions = [BASE] if live else [BASE, TIP]
    changes = dict((line.split("\t", 1)[1], line.split("\t", 1)[0]) for line in git("diff", "--no-renames", "--name-status", *revisions).decode().splitlines())
    if live:
        for path in git("ls-files", "--others", "--exclude-standard").decode().splitlines(): changes.setdefault(path, "A")
    for path, status in changes.items():
        assert (path in NEW and status == "A") or (path in [WORKFLOW, CONTRACT] and status == "M"), (status,path)
    # The allowlist excludes every pre-existing engine, service, 3D and golden file.
    patch = git("diff", "--numstat", *revisions, "--", WORKFLOW).decode().split()
    if patch: assert patch[1] == "0", "workflow must only add lines"
    workflow_diff = git("diff", "--unified=0", *revisions, "--", WORKFLOW).decode()
    additions = [line[1:].strip() for line in workflow_diff.splitlines() if line.startswith("+") and not line.startswith("+++")]
    assert sorted(additions) == sorted(["tools/validate_battle3d_m1b_engine_move.py", "tests/scripts/test_battle3d_engine_move_integration.gd"])
    final_paths = git("ls-files").decode().splitlines() if live else git("ls-tree", "-r", "--name-only", TIP).decode().splitlines()
    for suffix in ["", ".uid"]:
        removed = "tests/scripts/test_battle3d_engine_move_preflight.gd" + suffix
        assert not (ROOT/removed).exists() if live else removed not in final_paths
    def source(path):
        return (ROOT/path).read_text(encoding="utf-8") if live else git("show",f"{TIP}:{path}").decode()
    original = git("show",f"{BASE}:{CONTRACT}").decode().replace("\r\n", "\n")
    expected = original.replace("    assert 'WorldMap.tscn' not in text and 'Battle_Main.tscn' not in text", "    assert 'WorldMap.tscn' not in text\n    if file != S/'battle3d_engine_host.gd':\n        assert 'Battle_Main.tscn' not in text")
    assert source(CONTRACT).replace("\r\n", "\n") == expected, "only exact host path exception authorized"
    play = source("scripts/battle3d/battle3d_engine_play.gd")
    host = source("scripts/battle3d/battle3d_engine_host.gd")
    calls = set(re.findall(r'engine\.call\("([^"]+)"',play))
    assert calls == {"_select_ally_unit","_try_direct_move_to_cell","_select_post_move_facing","_handle_right_click_cancel"}, calls
    assert set(re.findall(r'battle\.call\("([^"]+)"',host)) == {"_skip_battle_intro_camera_zoom"}
    code = "\n".join(line.split("#",1)[0] for line in (play+host).splitlines())
    assert not re.search(r'\b(?:engine|battle|unit|candidate)\s*\.\s*(?:set\w*\s*\(|\w+\s*=(?!=))',code), "engine state write"
    assert not re.search(r'\b(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action)\s*=(?!=)',code), "state assignment"
    assert not re.search(r'\bset_(?:grid_cell|facing|has_moved|has_acted|last_action)\s*\(',code), "state setter"
    assert not re.search(r'\.call\(\s*[\'"]set_',code), "dynamic setter"
    assert not re.search(r'\b(?:BFS|path_to|find_move_path|get_distance|request_move|acknowledge_presentation)\s*\(',code), "rules must stay in engine/query service"
    assert 'extends SubViewport' in host and 'UPDATE_DISABLED' in host
    assert 'event.path' in play and 'playback.erase(event.unit_id)' in play
    assert 'Adapter.to_view(unit)' in play
    assert 'super._ready()' in play and 'lab_presentation.gd' in play
    print("M1B validator PASS: scope, immutable originals, four commands, read-only state, executed events")

if __name__ == "__main__": main()
