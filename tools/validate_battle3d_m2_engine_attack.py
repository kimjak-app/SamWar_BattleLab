"""M2-3D scope, immutable engine and explicit command/read boundaries.

M2_3D_SCOPE_TIP=HEAD checks the live tree; the final default pins implementation.
Additional Kimjak approval: target.is_defending ONLY in target information panel.
"""
from pathlib import Path
import hashlib
import os
import re
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASE = "afe03675b5abe0918951676f770a1c1516f6cd1a"
TIP = os.environ.get("M2_3D_SCOPE_TIP", "1ee52824175610696eb0efc6462c13be286fb4a5")
PLAY = "scripts/battle3d/battle3d_engine_play.gd"
HOST = "scripts/battle3d/battle3d_engine_host.gd"
WORKFLOW = ".github/workflows/verify-c-track.yml"
VALIDATOR = "tools/validate_battle3d_m2_engine_attack.py"
REPORT = "agent/BATTLE3D_M2_RESULT_20261019.md"
TESTS = [f"tests/scripts/test_battle3d_engine_attack_{suffix}.gd" for suffix in
         ["shard_1", "shard_2", "shard_3", "rejections", "sync"]]
HARNESS = "tests/scripts/support/battle3d_engine_attack_harness.gd"
MANUAL = "tests/scripts/test_battle3d_engine_attack_manual.gd"
NEW = {VALIDATOR, REPORT, HARNESS, MANUAL, *TESTS}
NEW |= {p + ".uid" for p in list(NEW) if p.endswith(".gd")}
COMMANDS = {"_select_ally_unit", "_try_direct_move_to_cell", "_select_post_move_facing",
            "_handle_right_click_cancel", "try_basic_attack", "_try_attack_enemy_target_from_attack_select"}
READ_CALLS = {"_get_alive_enemy_units", "is_unit_in_attack_range", "_is_unit_state_available_for_battle_slot"}
READ_PROPERTIES = {"current_phase", "is_demo_animating", "active_unit_state", "all_battle_unit_states",
                   "battle_action_event_log", "ally_move_event_log", "battle_grid_controller"}
VIEW_FIELDS = {"unit_id", "side", "unit_type", "grid_cell", "facing", "current_troops", "max_troops",
               "allocated_troops", "footprint", "has_moved", "has_acted", "status_effects", "move_range", "attack_range"}
ADDITIONAL_READ = "target.is_defending"

def git(*args):
    return subprocess.check_output(["git", "-C", str(ROOT), *args])

def check_state_writes(code):
    fields = r"(?:grid_cell|has_moved|has_acted|current_phase|ally_has_moved|last_action|current_troops|current_hp|is_defending)"
    assignment = r"\s*(?:[+*/%&|^\-]|<<|>>|\*\*)?=(?!=)"
    assert not re.search(r"\b"+fields+assignment,code), "state assignment (including is_defending and compound writes)"
    assert not re.search(r"\[\s*['\"]"+fields+r"['\"]\s*\]"+assignment,code), "indexed state assignment"
    assert not re.search(r"\.(?:set|set_deferred)\(\s*['\"]"+fields+r"['\"]",code), "state property setter"

def main():
    live = TIP == "HEAD"
    rev = [BASE] if live else [BASE, TIP]
    def source(path, base=False):
        return (ROOT/path).read_bytes() if live and not base else git("show", f"{BASE if base else TIP}:{path}")
    def text(path, base=False):
        return source(path, base).decode("utf-8").replace("\r\n", "\n")
    changes = dict((line.split("\t",1)[1],line.split("\t",1)[0]) for line in
                   git("diff", "--no-renames", "--name-status", *rev).decode().splitlines())
    if live:
        for p in git("ls-files", "--others", "--exclude-standard").decode().splitlines(): changes.setdefault(p,"A")
    # No engine/service/adapter/oracle/old-test/old-validator changes are allowed.
    for p, status in changes.items():
        assert (p in {PLAY,HOST,WORKFLOW} and status=="M") or (p in NEW and status=="A"), (status,p)
    for p in NEW: assert source(p).strip(), p
    protected = ["scripts/battle_web_import_test.gd", "scripts/battle3d/lab_presentation.gd",
                 "scripts/battle3d/battle3d_unit_adapter.gd", "tools/validate_battle3d_contract.py",
                 "tests/scripts/support/battle_attack_oracle_harness.gd",
                 "tests/scripts/test_battle3d_engine_move_integration.gd"]
    for p in protected: assert text(p)==text(p,True), "protected bytes: "+p
    for p, digest in {
        "tests/golden/battle_attack_baseline_v0.json":"d018cbe618c06043ea6ac6fd22c8a56faa42f284d4e6613f01bfa98dad3dd91c",
        "tests/golden/battle_move_baseline_v0.json":"b35d3f7987bb2efca5efe1d379b6eddc00cdca1558c17e88733dd1389cf714bd",
    }.items():
        assert hashlib.sha256(source(p).replace(b"\r\n",b"\n")).hexdigest()==digest, p
    workflow_diff=git("diff","--unified=0",*rev,"--",WORKFLOW).decode()
    assert not any(x.startswith("-") and not x.startswith("---") for x in workflow_diff.splitlines()), "workflow additions only"
    added=[x[1:].strip() for x in workflow_diff.splitlines() if x.startswith("+") and not x.startswith("+++")]
    assert sorted(added)==sorted([VALIDATOR,*TESTS]), added
    play=text(PLAY)
    host=text(HOST)
    code="\n".join(line.split("#",1)[0] for line in play.splitlines())
    calls=re.findall(r'engine\.call\("([^"\n]+)"',code)
    assert set(calls)==COMMANDS|READ_CALLS, "exact six commands and three read calls: "+str(set(calls))
    assert len(re.findall(r'engine\.call\(',code))==len(calls), "no dynamic method names"
    props=re.findall(r'engine\.get\("([^"\n]+)"\)',code)
    assert set(props)==READ_PROPERTIES, "explicit read properties"
    assert len(re.findall(r'engine\.get\(',code))==len(props), "no dynamic property names"
    assert not re.search(r'engine\.(?!get\(|call\()\w+',code), "no alternate engine access"
    assert not re.search(r'\b(?:engine|battle|unit|candidate|target|active)\s*\.\s*(?:set\w*\s*\(|\w+\s*=(?!=))',code), "engine/unit write"
    check_state_writes(code)
    assert not re.search(r'\b(?:apply_damage|set_grid_cell|set_facing|set_has_moved|set_has_acted|set_last_action|set_deferred|get_distance|find_move_path|request_move|acknowledge_presentation)\s*\(',code), "rules/state belong to engine"
    assert not re.search(r'\.call\(\s*[\'"](?:set_|apply_)',code), "dynamic state setter"
    assert not re.search(r'\.(?:attack_range|move_range)\s*[+\-*/]',code), "no range recomputation"
    functions={m.group(1):m.group(0) for m in re.finditer(r'^func (\w+)\([^\n]*\).*?(?=^func |\Z)',code,re.M|re.S)}
    assert code.count(ADDITIONAL_READ)==1 and ADDITIONAL_READ in functions["_refresh_target_info"], "defense read only in target panel"
    reads=set(re.findall(r'\b(?:unit|candidate|target|active)\.(\w+)',code))
    assert reads <= VIEW_FIELDS|{"is_defending"}, reads
    assert 'get_tiles_in_range(value.grid_cell,value.attack_range)' in functions["_show_attack_range"], "range delegated unchanged"
    assert 'engine.call("_get_alive_enemy_units")' in functions["_click_attack_cell"], "enemy-only input candidates"
    assert 'engine.call("is_unit_in_attack_range"' in functions["_click_attack_cell"], "range authority"
    assert 'root.visible = engine.call("_is_unit_state_available_for_battle_slot",unit)' in functions["_sync_views"], "visibility authority"
    assert 'event.damage_applied' in functions["_show_attack_damage"] and 'event.angle_type' in functions["_show_attack_damage"]
    assert 'events[action_cursor]' in functions["_consume_action_events"] and 'action_cursor+=1' in functions["_consume_action_events"]
    assert 'events[event_cursor]' in functions["_consume_events"], "independent movement cursor"
    assert 'event.path' in functions["_consume_events"] and 'playback.erase(event.unit_id)' in functions["_consume_events"]
    original=text(HOST,True)
    expected=original.replace('\tbattle = load("res://scenes/battle/Battle_Main.tscn").instantiate()', '\tbattle = create_battle()')
    factory='\nfunc create_battle() -> Node:\n\t# Test hosts may attach a transparent observer before the scene enters the tree.\n\treturn load("res://scenes/battle/Battle_Main.tscn").instantiate()\n'
    expected=expected.replace('\nfunc _skip_intro()',factory+'\nfunc _skip_intro()')
    assert host==expected, "host only adds pre-tree observer factory; intro/audio/isolation unchanged"
    for p in TESTS:
        assert "Battle_Main.tscn" not in text(p) and "WorldMap.tscn" not in text(p)
    assert 'super._try_attack_enemy_target_from_attack_select(target)' in text(HARNESS), "spy delegates original once"
    assert 'point(case,stage)' in text(HARNESS) and 'fingerprint.diff' in text(HARNESS), "existing golden comparison"
    assert not re.search(r'\.(?:_finish_basic_attack_demo|_play_enemy_turn_demo)\(',text(HARNESS)), "real completion/Tween required"
    print("M2_3D validator PASS: pinned scope, immutable engine/goldens/adapter, six commands, explicit reads, target-only is_defending, independent cursors")

if __name__=="__main__": main()
