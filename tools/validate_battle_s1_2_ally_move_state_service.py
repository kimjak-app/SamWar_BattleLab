"""S1-2 scope and sequencing guard. HEAD opts into live-worktree checks."""
from pathlib import Path
import argparse
import os
import re
import subprocess

BASE = "bc2c433b698ed261410b2754c6d500256ea83f2e"
# Pinned implementation checkpoint; later stages do not expand this scope.
TIP = os.environ.get("S1_2_SCOPE_TIP", "b4c4ec99c30e38244f2526cb6b4473f7641ce16b")
CONTROLLER = "scripts/battle_web_import_test.gd"
SERVICE = "scripts/battle/services/battle_ally_move_state_service.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
REPORT = "agent/BATTLE_ENGINE_S1_2_RESULT_20261019.md"
NEW = {SERVICE, SERVICE + ".uid", REPORT, "tools/validate_battle_s1_2_ally_move_state_service.py"}
for name in ["tests/scripts/test_battle_ally_move_state_service.gd", "tests/scripts/test_battle_ally_move_event_parity.gd", "tests/scripts/support/battle_ally_move_event_harness.gd"]:
    NEW.update([name, name + ".uid"])


def functions(source):
    return {m.group(1): m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)", source, re.M | re.S)}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    root = parser.parse_args().root.resolve()
    def git(*args):
        return subprocess.check_output(["git", "-C", str(root), *args])
    live = TIP == "HEAD"
    revisions = [BASE] if live else [BASE, TIP]
    def source(path, base=False):
        return (root/path).read_text(encoding="utf-8") if live and not base else git("show", f"{BASE if base else TIP}:{path}").decode("utf-8")
    changes = dict((line.split("\t",1)[1],line.split("\t",1)[0]) for line in git("diff","--no-renames","--name-status",*revisions).decode().splitlines())
    if live:
        for path in git("ls-files","--others","--exclude-standard").decode().splitlines():
            changes.setdefault(path,"A")
    for path,status in changes.items():
        assert (path in [CONTROLLER,WORKFLOW] and status=="M") or (path in NEW and status=="A"), (status,path)
    assert changes.get(CONTROLLER)=="M" and changes.get(WORKFLOW)=="M"
    workflow_patch = git("diff","--unified=0",*revisions,"--",WORKFLOW).decode()
    additions = [line[1:].strip() for line in workflow_patch.splitlines() if line.startswith("+") and not line.startswith("+++")]
    assert set(additions)=={"tools/validate_battle_s1_2_ally_move_state_service.py","tests/scripts/test_battle_ally_move_state_service.gd","tests/scripts/test_battle_ally_move_event_parity.gd"} and len(additions)==3
    assert git("diff","--numstat",*revisions,"--",WORKFLOW).decode().split()[1]=="0"
    old,new = source(CONTROLLER,True),source(CONTROLLER)
    a,b = functions(old),functions(new)
    changed = {"play_basic_move_demo","_finish_basic_move_demo","_select_post_move_facing","_store_pending_ally_move_snapshot","_rollback_pending_ally_move"}
    added = {"_record_ally_move_events","_apply_ally_move_step_facing"}
    assert set(b)-set(a)==added and not set(a)-set(b)
    for name in a:
        if name not in changed: assert a[name]==b[name], "out-of-scope function: " + name
    # Includes every enemy, shared facing, resume, attack and turn function.
    for name in ["_apply_unit_movement_facing","_set_unit_facing","_finish_enemy_actor_basic_move"]:
        assert a[name]==b[name], name
    old_header=old[:old.index("\nfunc ")]
    new_header=new[:new.index("\nfunc ")]
    new_header="\n".join(line for line in new_header.split("\n") if not line.startswith(("var ally_move_state_service :=", "var ally_move_event_log :=")))
    assert old_header==new_header,"only service/log members may be added"
    finish=b["_finish_basic_move_demo"]
    signature=a["_finish_basic_move_demo"].splitlines()[0].replace(") -> void:",", move_path: Array = []) -> void:")
    assert finish.splitlines()[0]==signature
    assert new.count("_finish_basic_move_demo.bind(")==1
    assert "target_cell, move_path.duplicate(true))" in b["play_basic_move_demo"]
    # Preserve every presentation/log statement in the original completion order.
    sequence=["_sync_selected_ally_markers_to_position(","ally_move_state_service.apply_destination(","_apply_unit_facing_visuals()","_debug_print_combat_distance(","_update_cell_size_visual_guide(",'print("ALLY MOVED',"ally_move_state_service.commit_move_metadata(","ally_has_moved = true","_reset_unit_group_positions()"]
    offsets=[finish.index(token) for token in sequence]
    assert offsets==sorted(offsets),"completion write/presentation ordering"
    assert "active_unit_state.set_grid_cell" not in finish
    for wrapper,method in [("_store_pending_ally_move_snapshot","capture_snapshot"),("_rollback_pending_ally_move","rollback"),("_select_post_move_facing","confirm_facing"),("_apply_ally_move_step_facing","apply_step_facing")]:
        assert "ally_move_state_service."+method+"(" in b[wrapper]
    svc=source(SERVICE)
    code="\n".join(line.split("#",1)[0] for line in svc.splitlines())
    assert re.search(r"^extends RefCounted$",code,re.M)
    assert not re.search(r"\b(Node\w*|SceneTree|Tween|await|signal|AudioStream\w*|Callable|get_tree)\b",code)
    assert not re.search(r"^var ",code,re.M),"service must be stateless"
    sf=functions(svc)
    assert "set_grid_cell" in sf["apply_destination"]
    assert "set_grid_cell" not in sf["commit_move_metadata"]
    assert '"moved_distance":grid_distance' in sf["commit_move_metadata"]
    assert "last_action" not in sf["rollback"]
    assert not re.search(r"has_acted\s*=",code)
    assert 'to_cell.x == from_cell.x' in sf["apply_step_facing"]
    schema=source("agent/BATTLE_ENGINE_EVENT_SCHEMA_MIN_v0_20261019.md")
    for kind in ["unit_moved","facing_changed","move_confirmed","move_reverted"]:
        assert '"'+kind+'"' in code and '`'+kind+'`' in schema
    for field in ["unit_id","from","to","path","movement_kind","facing_before","facing_after","flags_before","flags_after","last_action_after","reason","restored_fields"]:
        assert '"'+field+'"' in code and field in schema
    # Existing harness is immutable; the new copy replaces observation output only.
    original=source("tests/scripts/support/battle_move_oracle_harness.gd",True)
    expected=original.replace('"events":log_service.export()', '"events":battle.get("ally_move_event_log").export()')
    assert source("tests/scripts/support/battle_ally_move_event_harness.gd")==expected
    for path in NEW: assert source(path).strip(),path
    git("diff","--check",*revisions)
    print(f"S1_2_ALLY_MOVE_STATE PASS: scope={TIP}; {len(changes)} paths; only five existing functions changed; enemy/shared functions unchanged; split write ordering; workflow +3/-0")


if __name__ == "__main__":
    main()
