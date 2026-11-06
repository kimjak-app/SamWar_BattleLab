기준 화면: 가지 `feature/wm3d-m7prep-20261105`(끝 `ae49670`, 코드 `8b139b4`)에서, 월드맵 전투 문맥을 `Engine` 메타에 세운 채 `Battle3D_ScenarioShell.tscn`을 열어 3D 전장을 끝까지 치르면(승리·패배) 3D 결과창에 **"월드맵으로" 버튼**이 보이고, 누르면 엔진의 복귀 함수가 결과 메타 `samwar_worldmap_battle_result`를 세운 뒤 `res://WorldMap.tscn`으로 장면이 바뀐다. 월드맵이 전투 장면으로 3D 셸을 부르는 연결(M7-3)은 아직 없다(`worldmap_main.gd` 변경 0).
합격 기준: ① 새 왕복 테스트가 승리·패배 둘 다 "버튼 → 결과 메타 → 월드맵 장면 → 정산 적용"을 실제로 증명 ② 기존 battle3d 테스트·검증기 변화 없음(아래 5절 갱신 표만 예외) ③ 변경 경로가 6절 목록 안 ④ C-track 4 shard + `Verify WorldMap3D` success. 최종 합격은 M7-3 뒤 김작 F6.

# ORDER_M7_2 — 3D 결과창에서 월드맵으로 돌아가기 (클코치 작성, 2026-11-06)

## 0. 효력과 승인
- 큐 `agent/ORDER_QUEUE.md` §1·§4·§5·§10 그대로(확인 질문 금지, 멈춤 조건이면 보고서만 남기고 멈춤).
- **김작 승인 (11-05 21:54 "푸시해줘. 승인할게")**: 엔진 쓰기 +1 = `_return_to_worldmap_with_result`. 이 단계가 15+1(set_blocked_cells) → **17**로 만든다. 검증기 개수 고정 갱신은 5절 한도 안에서만.
- 가지 `feature/wm3d-m7prep-20261105`에 이어서 커밋. 정본 가지·`main`·`PROGRESS_WM3D.md`·`worldmap_main.gd` 손대지 않는다.

## 1. 먼저 읽기 전용으로 확인 (코드를 고치기 전, 보고서에 결과 적기)
클코치가 `8b139b4`·M7-1 보고서 3절로 본 [사실]이다. 다르면 **멈춤**(큐 4절 4번).
1. 엔진 `scripts/battle_web_import_test.gd:2935-2959` `_return_to_worldmap_with_result()`: 문맥 없으면 로그 후 반환, `_get_battle_result_state()`가 빈 문자열이면 "전투가 아직 종료되지 않았습니다"로 반환, 아니면 `_build_worldmap_battle_result_payload(state)` → `Engine.set_meta("samwar_worldmap_battle_result", …)` → `change_scene_to_file(WORLDMAP_SCENE_PATH)`, 성공하면 `GameSession.clear_battle_resume_snapshot()`. 실패하면 메타를 지운다.
2. 엔진의 복귀 버튼은 렌더가 꺼진 SubViewport 안이라 사람이 누를 수 없다 [추정, 실험으로 확인해 보고서에].
3. 셸 결과창: `result_panel`(VBox, M7-1 보고서 3절 ②), 버튼 `restart_button`·`choose_button`은 문맥 모드에서 숨김(`_show_result_buttons()`). 결과창은 `_on_ending_done → _show_result` 뒤에 뜬다.
4. 엔진 쓰기 호출은 전부 `scripts/battle3d/battle3d_engine_play.gd`(랩)에서 한다(`FIFTEEN` 목록, 검증기 `validate_t1_blocked_cells.py:31-34`). 셸은 `engine.call`을 읽기 함수 1곳(`_is_unit_state_available_for_battle_slot`)만 한다.

## 2. 해야 할 일
1. **랩에 함수 1개**: `battle3d_engine_play.gd`에 `request_return_to_worldmap()`을 만든다. 안에서 `engine.call("_return_to_worldmap_with_result")`를 **한 번만** 부른다(기존 15개 함수와 같은 모양·같은 파일). 엔진 파일은 고치지 않는다.
2. **셸에 버튼 1개**: `battle3d_scenario_shell.gd`의 결과창 `row`에 "월드맵으로" 버튼(`worldmap_button`, 크기는 기존 버튼과 같게)을 만든다. `pressed → lab.request_return_to_worldmap()`. `_show_result_buttons()`에서 `worldmap_button.visible = worldmap_context_mode`. 기존 두 버튼 로직은 바꾸지 않는다(추가만).
3. 버튼을 연타해도 복귀 함수가 두 번 돌지 않게 한다: 누른 뒤 `worldmap_button.disabled = true`(엔진이 실패해 장면이 안 바뀌면 다시 켠다 — 엔진이 로그만 남기고 반환하는 경로가 있으므로, 버튼은 한 번 누르면 비활성, 장면이 안 바뀌었으면 다음 프레임에 복구).
4. **왕복 테스트 새 파일** `tests/scripts/test_battle3d_worldmap_result_return.gd`(+`.uid`): 승리 1판·패배 1판.
   - 실제 월드맵 빌더로 문맥 생성(M7-1 답신 1의 방식 그대로, 출정 확인·핸드오프 호출 금지) → 셸을 문맥으로 연다 → 전투를 끝낸다(**결과를 만드는 방법은 기존 테스트가 쓰는 방식을 따른다**; 엔진 내부 값을 바꾸는 우회가 필요하면 그 방법·이유를 보고서에 적고, 3D 전장 종료 경로를 실제로 타는 쪽을 우선한다).
   - 확인: ① 결과창에서 `worldmap_button` 보임, 문맥 밖(시나리오 모드) 결과창에서는 안 보임 ② 버튼 누름 → `Engine.has_meta("samwar_worldmap_battle_result")` 참, 값의 `result`/`transaction_id`가 문맥과 일치 ③ 장면이 `WorldMap.tscn`으로 바뀜(또는 `change_scene_to_file` 호출이 이 경로로 갔음을 증명) ④ `user://battle_runtime_resume.json`이 없음 ⑤ 월드맵이 그 메타를 받아 정산(`battle_settlement_applier`)까지 적용한 결과가 2D 경로의 같은 입력 결과와 **같다**(기존 `test_worldmap_battle_main_roundtrip_settlement`의 방식을 재사용해 비교) ⑥ 연타해도 결과 메타가 한 번만 생김.
   - 테스트 끝에 메타·파일·장면을 정리해 다른 테스트에 영향이 없게 한다. 테스트는 실패 시 종료 코드 1.
5. CI 등록: `.github/workflows/verify-c-track.yml`에 이 테스트 **한 줄** 추가(기존 줄 불변, 추가만). 검증기 `validate_battle3d_contract.py`가 이 테스트 파일을 허용하도록 M7-1 때와 같은 방식으로 기대만 갱신.

## 3. 하지 말 것
- 엔진·서비스·씬·골든·데이터·에셋·`worldmap_main.gd` 수정 금지. 엔진 쓰기는 `_return_to_worldmap_with_result` 1개만.
- 후퇴 버튼(`battle3d_top_commands.gd`)은 이 단계에서 건드리지 않는다(M7-4).
- CI 재실행 버튼, 허용 오차 조정, 기존 테스트 수정 금지.

## 4. 로컬 검증 (결과 줄 원문을 보고서에)
M7-1 지시서의 로컬 검증 전부 + 새 왕복 테스트 + `test_worldmap_battle_main_roundtrip_settlement` + `test_worldmap_to_battle_input_lifecycle` + 3D 월드맵 8종 + 검증기 전부(72개).

## 5. 검증기 갱신 (상한)
엔진 쓰기 개수와 목록을 고정하는 검증기만, **토큰·숫자 줄만** 고친다: `validate_t1_blocked_cells.py`(`FIFTEEN`과 "15+1=16" → 17), `validate_battle3d_command_panel.py`(`:50`, `:121`), 그 밖에 개수 고정에 걸리는 검증기. **상한: 검증기 파일 4개, 파일당 10줄 이내.** 논리를 바꿔야 하거나 상한을 넘으면 멈춤. 보고서에 파일·줄·전후를 표로(M7-1의 "검증기 갱신 표" 형식).

## 6. 수정·추가 경로 목록 (이 밖은 멈춤)
`scripts/battle3d/battle3d_engine_play.gd`, `scripts/battle3d/battle3d_scenario_shell.gd`, `tests/scripts/test_battle3d_worldmap_result_return.gd`(+`.uid`), `tools/validate_battle3d_contract.py`, 5절 검증기, `.github/workflows/verify-c-track.yml`(+1줄), `agent/REPORT_M7_2_20261106.md`.

## 7. 멈춤 조건 (큐 4절 외 추가)
- 3D 셸 안에서 엔진이 `change_scene_to_file`을 불렀을 때 장면이 안 바뀌거나 셸이 남는 등 1절 3항 [추정]이 틀릴 때.
- 5절 상한 초과, 6절 밖 수정.
- 승리·패배 결과의 정산이 2D 경로와 **다를 때**(이건 3D 문제가 아니라 문맥/정산 문제일 수 있으니 고치지 말고 차이 표를 보고서에).

## 8. 보고서와 마무리
- `agent/REPORT_M7_2_20261106.md`(`[skip ci]`), 맨 위 "기준 화면 / 합격 기준" 두 줄. 로컬 결과 줄 원문, 검증기 갱신 표, diff, 택한 해석.
- **다음 단계(M7-4)에 필요한 사실**을 반드시: ① 랩 함수 이름·줄 ② 엔진 쓰기 개수와 목록 위치 ③ 결과창·상단 버튼 줄 번호.
- 끝나면 큐를 다시 읽고 다음 항목(M7-4)으로 간다.
