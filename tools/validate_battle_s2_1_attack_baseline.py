"""S2-1 observation scope; HEAD explicitly audits the live worktree."""
from pathlib import Path
import json
import os
import subprocess

ROOT = Path(__file__).resolve().parents[1]
BASE = "2ba04645f7736fbee3a0eecd8a9ef0a38ef13b02"
TIP = os.environ.get("S2_1_SCOPE_TIP", "538665f1c7b369ea87ffdfd0e828513ea3f1c4ef")
WORKFLOW = ".github/workflows/verify-c-track.yml"
F2 = "tests/scripts/test_battle3d_engine_move_integration.gd"
GOLDEN = "tests/golden/battle_attack_baseline_v0.json"
NEW = {"tests/scripts/support/battle_attack_oracle_harness.gd", "tests/scripts/test_battle_attack_oracle_baseline.gd", GOLDEN,
       "tools/validate_battle_s2_1_attack_baseline.py", "agent/BATTLE_ENGINE_S2_1_RESULT_20261019.md"}
NEW |= {name + ".uid" for name in list(NEW) if name.endswith(".gd")}
CASES = {"A1","A2_side","A2_back","A3","A4","A5","A6","A7_range","A7_acted","A7a","A7b","A8","A9","A10","A11"}

def main():
    def git(*args): return subprocess.check_output(["git", "-C", str(ROOT), *args])
    live = TIP == "HEAD"
    revisions = [BASE] if live else [BASE, TIP]
    changes = dict((row.split("\t",1)[1],row.split("\t",1)[0]) for row in git("diff","--no-renames","--name-status",*revisions).decode().splitlines())
    if live:
        for name in git("ls-files","--others","--exclude-standard").decode().splitlines(): changes.setdefault(name,"A")
    for name,status in changes.items():
        assert (name in NEW and status=="A") or (name in [WORKFLOW,F2] and status=="M"), (status,name)
    def source(name): return (ROOT/name).read_text(encoding="utf-8") if live else git("show",f"{TIP}:{name}").decode()
    for name in [WORKFLOW,F2]:
        stat = git("diff","--numstat",*revisions,"--",name).decode().split()
        assert stat and stat[1]=="0", name+" additions only"
    patch=git("diff","--unified=0",*revisions,"--",WORKFLOW).decode()
    added=[line[1:].strip() for line in patch.splitlines() if line.startswith("+") and not line.startswith("+++")]
    assert sorted(added)==sorted(["tools/validate_battle_s2_1_attack_baseline.py","tests/scripts/test_battle_attack_oracle_baseline.gd"])
    # Exact F2 delta protects the rest of the existing integration test.
    original=git("show",f"{BASE}:{F2}").decode().replace("\r\n","\n")
    extra='''\tvar executed_detour: Array = []
\tfor event in lab.engine.get("ally_move_event_log").export():
\t\tif event.kind == "unit_moved" and event.unit_id == "yi_sunsin":
\t\t\texecuted_detour.clear()
\t\t\tfor cell in event.path: executed_detour.append(Vector2i(cell[0],cell[1]))
\texpect(executed_detour.size() > 2 and lab.playback.has("yi_sunsin") and lab.playback["yi_sunsin"].path == executed_detour,"detour playback equals engine executed path")
'''
    assert source(F2).replace("\r\n","\n")==original.replace('\texpect(detour.size()-1 > 2,"executed path detours around occupancy")\n','\texpect(detour.size()-1 > 2,"executed path detours around occupancy")\n'+extra)
    golden=json.loads(source(GOLDEN))
    assert golden["base_commit"]==BASE
    assert len(golden["scenarios"])==len(CASES)
    assert {case["case"] for case in golden["scenarios"]}==CASES
    cases={case["case"]:case for case in golden["scenarios"]}
    assert cases["A7a"]["observation_note"]=="엔진 함수는 대상 진영을 검사하지 않음(알려진 미보호 경계)"
    assert cases["A7b"]["input_evidence"]["allies_excluded"] is True
    assert cases["A7b"]["input_evidence"]["mouse_input_simulated"] is False
    for label in ["A1","A2_side","A2_back","A3","A4","A6","A7a","A8","A9","A10"]:
        assert {"requested","animating","finished_before_enemy","finished_after_enemy_start","after_enemy_slot"} <= {p["stage"] for p in cases[label]["checkpoints"]}
    for case in golden["scenarios"]:
        for checkpoint in case["checkpoints"]:
            assert len(checkpoint["units"])==10
            assert all(len(unit)==40 for unit in checkpoint["units"])
    print("S2_1_ATTACK_BASELINE PASS: scope, immutable production, exact F2 delta, 15 cases, ten 40-field fingerprints")

if __name__=="__main__": main()
