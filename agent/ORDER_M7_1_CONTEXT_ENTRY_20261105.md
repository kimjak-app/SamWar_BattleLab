기준 화면: 정본이 아닌 작업 가지 `feature/wm3d-m7prep-20261105`(이어서 커밋, 시작 = 그 가지 끝 `05e2e1b`)에서, 테스트로 만든 **실제 월드맵 전투 문맥**을 `Engine` 메타에 세운 채 `res://scenes/battle3d/Battle3D_ScenarioShell.tscn`을 열면 시작 패널 없이 곧바로 3D 전장이 그 문맥의 부대·장수·병력으로 시작한다. 메타가 없으면 지금처럼 시작 패널이 나온다. 아직 월드맵과는 연결하지 않는다(`worldmap_main.gd` 변경 0).
합격 기준: ① 새 테스트가 문맥 진입을 증명(부대 id·진영·병력이 문맥과 일치, 메타를 엔진이 소비) ② 기존 battle3d 테스트·검증기 전부 변화 없음 ③ 변경 경로가 6절 목록 안 ④ C-track 4 shard success. 김작 F6는 M7-3 뒤 월드맵에서 한 번에 한다(이 단계는 자동 검증).

# 지시서 — M7-1: 3D 셸의 월드맵 문맥 진입 경로

- 작성: 클코치, 2026-11-05 22:05(검수 반영: setup 메타 충돌·이어하기 스냅샷·깨진 문맥 판정·재시작 버튼) / 근거: `agent/REPORT_AUDIT_M7_20261105.md` 1-1~1-3·3절 M7-1, 김작 11-05 13:19 M7 승인·21:37 "3D 전장 연결"(밤샘 허용).
- [사실, 감사 보고서] 3D 전장은 안쪽에서 2D 엔진을 돌린다(`scripts/battle3d/battle3d_engine_host.gd:7·12-14`가 `Battle_Main.tscn`을 `UPDATE_DISABLED` SubViewport에 만듦). 엔진 `_ready`(`scripts/battle_web_import_test.gd:1491`)가 `_read_worldmap_battle_context_handoff`(`:1504`)로 `Engine` 메타 `samwar_worldmap_battle_context`를 읽고 바로 지운 뒤(`:1511-1512`) `_apply_worldmap_battle_context_handoff`(`:1617-1642`)로 고정 슬롯(`ally_main_01…`, `enemy_main_01…`, `:510-520`)에 적용한다. 3D 셸은 `start_scenario`(`scripts/battle3d/battle3d_scenario_shell.gd:204`)에서 `samwar_battle_setup` 메타를 세우고(`:209`) 랩을 만든 뒤 그 메타만 지운다(`:238`). 3D 쪽에는 `samwar_worldmap`·`battle_context`가 0건. 셸은 언제나 시작 패널에서 출발한다(`:157-170`). **엔진이 셸 안에서 문맥을 실제로 소비·적용하는지는 [미확인, 실험 필요].**

## 0. 규칙
1. 시작 전 `git status` 깨끗, `git fetch origin`, `git switch feature/wm3d-m7prep-20261105`(원격 끝이 `05e2e1b`인지, 아니면 문서 커밋뿐인지 확인). 이 가지에 이어서 커밋. push 대상은 이 가지뿐. 정본 가지·`main`·`integration/*`·`work/*`·열린 PR 가지 금지, force·삭제 금지, `gh` 읽기만.
2. 수정 경로는 6절 목록이 전부. `scripts/worldmap/worldmap_main.gd`·`worldmap3d/`·엔진 규칙 코드(`battle_web_import_test.gd`·`scripts/battle/`) 수정 금지. 목록 밖이 필요하면 멈추고 `agent/REPORT_M7_1_STOP_20261105.md`.
3. **엔진 쓰기(`engine.call` 이름)를 새로 늘리지 않는다**(이 단계는 0개). 늘려야 한다면 멈춤.
4. 코드 커밋 → CI → 보고서 커밋(`[skip ci]`). 보고서 `agent/REPORT_M7_1_20261105.md`, 진행 기록은 보고서 맨 위(정본 `PROGRESS_WM3D.md` 수정 금지). 확인 질문 없이 진행(큐 10절).
5. [사실]과 다르면 추정하지 말고 STOP 보고서.

## 1. 먼저 읽기 전용 확인 (보고서 표로)
1. 셸 `_ready`·`start_scenario`(`:157-238`)와 `Battle3D_EngineHost`·`Battle3D_EnginePlayLab`의 생성 순서를 줄 번호로 정리: 어느 시점에 안쪽 엔진 `_ready`가 도는지, 그때 `samwar_worldmap_battle_context` 메타가 아직 있어야 하는지, 셸이 `samwar_battle_setup`을 세우고 지우는 시점이 문맥 메타와 충돌하는지.
2. 엔진 `_apply_worldmap_battle_context_handoff`(`:1617-1642`)가 3D 랩 시작 전에 끝나는지(`engine_play`가 엔진의 `all_battle_unit_states`를 읽는 시점 `:279-309`과의 선후). 문맥이 적용되지 않은 상태로 랩이 부대를 그리는 경쟁 조건이 있는지.
3. 문맥에서 3D가 그리는 값: 모델 종류(`engine_play:304` 보병·기병 둘로 줄임), 장수 표시(`battle3d_hero_data_reader.gd:8`, 월드맵 `hero_design_data_registry`), 병력 수치. 월드맵 문맥의 `hero_ids`·`troop_composition` 키가 3D에서 읽히는 경로.
4. 시작 패널 건너뛰기를 구현할 가장 작은 자리(셸 `_ready` 분기 vs 별도 함수). 기존 `default`/`win_practice` 시나리오 시작과 `scenario_new_battle`(새 전투)이 문맥 모드에서 어떻게 동작해야 하는지(문맥 모드에서는 "새 전투" 버튼이 같은 문맥을 재시작하면 안 된다: 메타는 소비되어 없어짐).

5. **이어하기 스냅샷**: 엔진 `_ready`는 `문맥 적용(:1491) → _try_restore_battle_resume_snapshot(:1492) → _read_battle_setup_port(:1494)` 순서. 같은 전투 id의 `user://battle_runtime_resume.json`이 있으면 복원 후 3D가 부대를 그린다. 복원 상태에서 랩이 정상으로 그리는지(`engine_play:279-309`), 스냅샷이 지워지는 곳(엔진 `_return_to_worldmap_with_result` 성공 뒤 `:2958`뿐)을 정리. 테스트에서 스냅샷을 만들 수 있으면 복원 진입도 단언, 어려우면 [미확인]으로 보고(우회 금지).

## 2. 구현
### 2-1. 문맥 진입 경로 (`battle3d_scenario_shell.gd`)
- `_ready`에서 `Engine.has_meta("samwar_worldmap_battle_context")`이면 시작 패널을 건너뛰고 문맥 모드로 곧바로 랩을 만든다. 메타를 **셸이 읽거나 지우지 않는다**(엔진이 소비한다). 셸이 `samwar_battle_setup`을 세울 필요가 있는지는 1절 1번 결과에 따라 판단(기존 시나리오 시작과 같은 순서를 최대한 재사용).
- 문맥 모드 플래그(`worldmap_context_mode`)를 셸에 둬서 결과창·새 전투 버튼 처리에 쓴다(M7-2가 이어받음). 이번에는 플래그만 두고, 문맥 모드에서는 "새 전투" 버튼을 숨기거나 비활성(이유 문구 없이 눈에 띄지 않게, 1절 4번 결과대로).
- 메타가 없으면 지금과 **완전히 같은 동작**(시작 패널, 시나리오 고르기).
- **문맥 모드에서는 `samwar_battle_setup` 메타를 절대 세우지 않는다**(엔진이 문맥을 먼저 적용하고 setup을 나중에 읽으므로 setup이 문맥의 병력을 덮어쓸 수 있다). `scenario_setup`/`SETUP_KEY` 경로를 문맥 모드가 타지 않게 하고 테스트로 못 박는다.
- 깨진 문맥(키 누락·빈 딕셔너리): 엔진은 스스로 "테스트 전투"로 폴백하므로 3D 쪽에서 실패를 직접 볼 수 없다. **랩 생성 직후 엔진의 `worldmap_battle_context`가 비어 있으면**(문맥 적용 실패) 랩을 닫고 시작 패널로 되돌린다(경고 줄 1개, 엔진 쓰기 없음, 크래시 0).

### 2-2. 결과 문구 (`battle3d_engine_play.gd`의 `RESULT_TEXT`만)
- `RESULT_TEXT`(`:105`)에 `retreat`(후퇴) 항목을 추가한다(없는 키는 기존 폴백 유지). 이번 단계에서 후퇴 처리 자체는 만들지 않는다(M7-4).

### 2-3. 그 밖
- 엔진 호스트(`battle3d_engine_host.gd`)는 1절 1·2번 결과 **증명된 경우에만** 최소 수정한다(예: 문맥 모드에서 엔진을 만든 직후 적용 완료를 기다리는 한 줄). 규칙 3(엔진 쓰기 0) 준수.

## 3. 새 테스트 `tests/scripts/test_battle3d_worldmap_context_entry.gd`
결과 줄 `[BATTLE3D_CONTEXT_ENTRY] checks=N failures=[]`.
1. **실제 문맥 확보**: `test_worldmap_battle_main_roundtrip_settlement.gd`가 하는 방식(`WorldMap.tscn` 인스턴스 → 실제 공격 확인 흐름 → `samwar_worldmap_battle_context` 메타가 세워지는 시점)을 참고해 **실제 월드맵이 만든 문맥**을 얻는다. 그 흐름 중 장면 전환(`change_scene_to_file`)은 일어나지 않게(테스트용 우회가 필요하면 보고서에 방법·이유) 하고, 얻은 딕셔너리를 `Engine` 메타로 세운 채 셸 장면을 인스턴스한다.
2. 셸이 시작 패널 없이 문맥 모드로 시작(시작 패널 숨김, 랩 존재), 메타가 엔진에 의해 소비되어 `Engine.has_meta`가 false.
3. 3D 랩의 아군·적 부대의 수·병종·병력·진영이 문맥의 `troop_composition`/`attacker_*`/`defender_*`와 일치(문맥 키가 가리키는 값만 비교, 계산하지 않음).
4. 장수 id(`hero_ids`)가 3D에 표시되는지는 읽을 수 있는 값(HUD 로스터)만 단언. 표시 못 하는 항목은 "[미확인, 3D 표시 미구현]"으로 보고서에 목록(단언하지 않음).
5. 메타 없이 셸을 열면 시작 패널이 나온다(기존 동작 불변).
6. 깨진 문맥(빈 딕셔너리·필수 키 누락)에서 시작 패널로 되돌아오고 오류·크래시 0.
6-1. 문맥 모드에서 `Engine`에 `samwar_battle_setup`이 세워지지 않았음, 문맥 모드의 "다시 시작/시나리오 선택" 버튼이 숨겨져 있음.
7. 고치기 전(경로 없음) 문맥 모드 단언들이 실패하는 것을 한 번 확인한 기록.
- 이 테스트를 `verify-c-track.yml`의 battle3d 테스트 목록(보고서에 목록 구조·shard 선택 근거)에 등록(5절).

## 4. 로컬 검증 (결과 줄 원문을 표로)
1. 새 테스트 통과(+고치기 전 실패 기록), 소요 시간(`timeout 300s` 이내).
2. 기존 battle3d 테스트 전체(`tests/scripts/test_battle3d_*.gd`, CI가 도는 105개와 같은 목록)와 `battle3d` 검증기(`tools/validate_battle3d_*.py`)가 변화 없음. **셸 파일을 바꾸면 이 검증기들이 소스 토큰을 요구할 수 있다**: 실패하는 검증기가 나오면 토큰 기대만 새 코드에 맞춰 갱신하고(약화·삭제 금지) 무엇을 무엇으로 바꿨는지 표로 보고. 검증기 갱신이 3개를 넘으면 멈추고 보고.
3. 정적 검증기 72/72, 3D 월드맵 테스트 8종·왕복 28·입력 수명주기 PASS(M7-0b 상태) 변화 없음, `WorldMap.tscn`·`Battle3D_ScenarioShell.tscn` `--quit-after 5` 오류 줄 0.
4. `git status --short`이 6절 목록 안, `git diff --check`, `git diff --stat`에 `worldmap_main.gd`·엔진 규칙 코드 0.

## 5. 커밋·push·CI
1. 커밋 1: `feat(battle3d): shell starts straight from a worldmap battle context when one is present (M7-1)`
2. push `feature/wm3d-m7prep-20261105`, 원격 해시 = 로컬 HEAD. `gh run watch`로 `Verify C-track refactor`(4 shard) 확인(컷인 예외는 큐 4절 1번). 실패하면 고치지 말고 읽기 전용 조사 후 STOP.
3. 보고서 커밋(`[skip ci]`).
4. 같은 커밋에서 `.github/workflows/verify-c-track.yml`에 새 테스트 등록(가장 가벼운 shard 하나, 기존 항목 불변).

## 6. 수정·추가 가능 경로 (이 목록이 전부)
1. `scripts/battle3d/battle3d_scenario_shell.gd`
2. `scripts/battle3d/battle3d_engine_play.gd` (`RESULT_TEXT`만)
3. `scripts/battle3d/battle3d_engine_host.gd` (1절 1·2번이 증명한 경우만)
4. `tests/scripts/test_battle3d_worldmap_context_entry.gd` (+ `.uid`)
5. `.github/workflows/verify-c-track.yml` (테스트 1개 추가만)
6. `tools/validate_battle3d_*.py` (4절 2번의 토큰 기대 갱신만, 3개 이하)
7. `agent/REPORT_M7_1_20261105.md` (보고서 커밋)

## 7. 보고서
맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약(됐나 / 엔진이 셸 안에서 문맥을 소비했나 / 막힌 것), "택한 해석", 1절 표, 4절 결과 표, diff 전체, CI 표, "[미확인] 목록(3D 표시되지 않는 항목)", 막힌 것, 종료 루틴 5줄. **다음 단계(M7-2)에 필요한 사실**: 문맥 모드 플래그 이름, 결과창이 있는 곳(`shell:560-568`), 엔진이 결과를 만드는 시점.

## 8. 하지 않는 것
- `worldmap_main.gd`·엔진 규칙·3D 월드맵 수정, 엔진 쓰기 추가(복귀·후퇴는 M7-2·4), 지형·보급 HUD 구현, 해상도 대응, 문맥 없이 시작 시 동작 변경, 재실행으로 때우기, 정본 가지 push.
