"""S2-2 pinned scope + exact controller delegation/call-order guard."""
from pathlib import Path
import os,re,subprocess,argparse
BASE="3269385529f16bc8e77ce299ad05c53e022c4a11"
# Implementation checkpoint; future stages do not widen this scope.
TIP=os.environ.get("S2_2_SCOPE_TIP","f934f31cc50f1fc3d717ffe298cdd02c0315de3b")
CONTROLLER="scripts/battle_web_import_test.gd"
SERVICE="scripts/battle/services/battle_attack_state_service.gd"
LOG="scripts/battle/services/battle_event_log_service.gd"
WORKFLOW=".github/workflows/verify-c-track.yml"
RUNNER="tests/scripts/test_battle_attack_oracle_baseline.gd"
SCHEMA="agent/BATTLE_ENGINE_EVENT_SCHEMA_MIN_v0_20261019.md"
PLAN="BATTLE_RUNTIME_REFACTOR_PLAN.md"
NEW={SERVICE,SERVICE+".uid","tools/validate_battle_s2_2_attack_state_service.py",
     "agent/BATTLE_ENGINE_S2_2_EXECUTION_20261019.md","agent/BATTLE_ENGINE_S2_2_RESULT_20261019.md"}
for stem in ["test_battle_attack_state_service","test_battle_attack_event_parity","test_battle_attack_oracle_shard_1","test_battle_attack_oracle_shard_2","support/battle_attack_event_harness"]:
    path="tests/scripts/"+stem+".gd"; NEW.update([path,path+".uid"])
def functions(s):
    return {m.group(1):m.group(0).rstrip() for m in re.finditer(r"^func (\w+)\([^\n]*\).*?(?=^func |\Z)",s,re.M|re.S)}
def main():
    parser=argparse.ArgumentParser();parser.add_argument("--root",type=Path,default=Path(__file__).resolve().parents[1]);root=parser.parse_args().root.resolve()
    def git(*args):return subprocess.check_output(["git","-C",str(root),*args]).decode("utf-8")
    live=TIP=="HEAD"; rev=[BASE] if live else [BASE,TIP]
    def source(path,base=False):return (root/path).read_text(encoding="utf-8") if live and not base else git("show",f"{BASE if base else TIP}:{path}")
    changes=dict((line.split("\t",1)[1],line.split("\t",1)[0]) for line in git("diff","--no-renames","--name-status",*rev).splitlines())
    if live:
        for path in git("ls-files","--others","--exclude-standard").splitlines():changes.setdefault(path,"A")
    modified={CONTROLLER,LOG,WORKFLOW,RUNNER,SCHEMA,PLAN}
    for path,status in changes.items():assert (path in modified and status=="M") or (path in NEW and status=="A"),(status,path)
    for path in NEW:assert source(path).strip(),path
    old,new=source(CONTROLLER,True),source(CONTROLLER)
    a,b=functions(old),functions(new)
    assert set(a)==set(b),"controller function set unchanged"
    allowed={"play_basic_attack_demo","_finish_basic_attack_demo","_commit_basic_attack_unit_contract","_cleanup_dead_units"}
    for name in a:
        if name not in allowed:assert a[name]==b[name],"out-of-scope controller function: "+name
    new_header=new[:new.index("\nfunc ")]
    new_header="\n".join(line for line in new_header.split("\n") if not line.startswith(("var attack_state_service :=","var battle_action_event_log :=")))
    assert old[:old.index("\nfunc ")]==new_header,"controller header scope"
    # Reverse only the reviewed delegation to recover the exact base functions.
    play=b["play_basic_attack_demo"].replace(
        "var attack_result: Dictionary = attack_state_service.apply_attack_damage(active_unit_state, selected_attack_target_state, attack_damage, attack_angle_type)\n\tvar applied_attack_damage: int = attack_result.damage_applied",
        "var applied_attack_damage := selected_attack_target_state.apply_damage(attack_damage)")
    play=play.replace('\n\tbattle_action_event_log.emit("attack_resolved", attack_result.fields)',"")
    assert play==a["play_basic_attack_demo"],"request write/call ordering"
    assert '\t\t_gain_momentum_for_basic_attack(active_unit_state)\n\tbattle_action_event_log.emit("attack_resolved", attack_result.fields)\n\t_update_enemy_target_visuals' in b["play_basic_attack_demo"],"request event position"
    finish=b["_finish_basic_attack_demo"].replace('\n\tif active_unit_state != null and active_unit_state.side == "ally" and not active_unit_state.unit_id.is_empty():\n\t\tbattle_action_event_log.emit("action_completed", {"unit_id":active_unit_state.unit_id})',"")
    assert finish==a["_finish_basic_attack_demo"],"finish sequence including exact controller pending-clear call"
    assert '\t_mark_ally_unit_acted(active_unit_state)\n\tif active_unit_state != null and active_unit_state.side == "ally" and not active_unit_state.unit_id.is_empty():\n\t\tbattle_action_event_log.emit("action_completed", {"unit_id":active_unit_state.unit_id})\n\t_show_unit_closeup_for_ally' in b["_finish_basic_attack_demo"],"completion event position"
    assert b["_finish_basic_attack_demo"].count("_clear_pending_move_snapshot()")==1
    cleanup=b["_cleanup_dead_units"].replace('\n\t\t\tbattle_action_event_log.emit("unit_defeated", {"unit_id":unit_state.unit_id})',"")
    assert cleanup==a["_cleanup_dead_units"],"shared death cleanup unchanged"
    assert 'action_lock_state_service.erase_unit_id(unit_state.unit_id)\n\t\t\tbattle_action_event_log.emit("unit_defeated"' in b["_cleanup_dead_units"],"death event after registration and lock removal"
    contract=b["_commit_basic_attack_unit_contract"]
    metadata=a["_commit_basic_attack_unit_contract"].split("\tattacker_state.attacked_this_turn",1)[1].split("\tif attacker_state.unit_type",1)[0]
    metadata="\tattacker_state.attacked_this_turn"+metadata.rstrip()
    contract=contract.replace("\tattack_state_service.commit_attack_metadata(attacker_state)",metadata)
    contract=contract.replace("attack_state_service.apply_post_fire_penalty(attacker_state)",'attacker_state.apply_status_effect("post_fire_penalty", 1, 40)')
    movement=a["_commit_basic_attack_unit_contract"].split("\tif UnitTypeContractScript.can_move_after_attack",1)[1]
    contract=contract.replace("\tattack_state_service.commit_post_attack_movement(attacker_state)","\tif UnitTypeContractScript.can_move_after_attack"+movement)
    assert contract==a["_commit_basic_attack_unit_contract"],"metadata/status/log write sequence"
    svc=source(SERVICE);sf=functions(svc)
    code="\n".join(line.split("#",1)[0] for line in svc.splitlines())
    assert re.search(r"^extends RefCounted$",code,re.M)
    assert not re.search(r"\b(Node\w*|SceneTree|Tween|await|signal|Callable|get_tree)\b",code)
    assert not re.search(r"^var ",code,re.M),"stateless service"
    assert set(sf)=={"apply_attack_damage","commit_attack_metadata","apply_post_fire_penalty","commit_post_attack_movement"}
    assert sf["commit_attack_metadata"].split("\n",1)[1]==metadata.replace("attacker_state","attacker")
    assert 'attacker.apply_status_effect("post_fire_penalty", 1, 40)' in sf["apply_post_fire_penalty"]
    assert sf["commit_post_attack_movement"].split("\n",1)[1]==("\tif UnitTypeContractScript.can_move_after_attack"+movement).replace("UnitTypeContractScript","UnitTypeContract").replace("attacker_state","attacker")
    assert sf["apply_attack_damage"].count("target.apply_damage(damage)")==1
    assert not re.search(r"(has_acted|has_moved|current_phase)\s*=",code)
    # Old observation fixture and both goldens are protected by the scope allowlist.
    expected_runner=source(RUNNER,True).replace("func _initialize() -> void:","func case_labels() -> Array:\n\treturn CASES\n\nfunc _initialize() -> void:",1).replace("var labels: Array = CASES","var labels: Array = case_labels()",1)
    assert source(RUNNER)==expected_runner,"oracle runner comparison/guards unchanged"
    for i,sl in [(1,"0,8"),(2,"8")]:
        assert source(f"tests/scripts/test_battle_attack_oracle_shard_{i}.gd")==f'extends "res://tests/scripts/test_battle_attack_oracle_baseline.gd"\n\nfunc case_labels() -> Array:\n\treturn CASES.slice({sl})\n'
    labels=re.search(r"const CASES := (.*)",source(RUNNER))[1]
    import ast
    cases=ast.literal_eval(labels);assert len(cases)==16 and len(set(cases))==16
    oldwf=source(WORKFLOW,True)
    expected_wf=oldwf.replace("            tests/scripts/test_battle_attack_oracle_baseline.gd","            tests/scripts/test_battle_attack_oracle_shard_1.gd\n            tests/scripts/test_battle_attack_oracle_shard_2.gd\n            tests/scripts/test_battle_attack_state_service.gd\n            tests/scripts/test_battle_attack_event_parity.gd",1).replace("            tools/validate_battle_s2_1_attack_baseline.py","            tools/validate_battle_s2_1_attack_baseline.py\n            tools/validate_battle_s2_2_attack_state_service.py",1)
    assert source(WORKFLOW)==expected_wf,"CI preserves all old checks, shards exact original case set"
    log=source(LOG);lf=functions(log);oldlf=functions(source(LOG,True))
    for name in ["clear","emit","export","_flags","_cell","_json_value"]:assert lf[name]==oldlf[name],"existing event log API/JSON policy unchanged: "+name
    for kind in ["attack_resolved","action_completed","unit_defeated"]:assert '"'+kind+'"' in log and '`'+kind+'`' in source(SCHEMA)
    git("diff","--check",*rev)
    print(f"S2_2_ATTACK_STATE PASS: scope={TIP}; {len(changes)} paths; four controller functions; exact write/call order; immutable goldens/harness; CI 8+8 case partition")
if __name__=="__main__":main()
