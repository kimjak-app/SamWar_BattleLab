기준 화면: 없음(보이는 화면 변화 0). 읽기 전용 조사이며 코드·테스트·워크플로·씬을 수정하지 않는다. 대상은 정본 가지 `feature/wm3d-intake-20261101`(HEAD `9160baf` 또는 그 이후)의 "월드맵 → 3D 전장 → 정산 → 월드맵 복귀" 연결 가능성이다.
합격 기준: 김작이 보고서(`agent/REPORT_AUDIT_M7_20261105.md`)만 읽고 "3D 전장 연결(M7)이 어떤 단계로 몇 개 파일을 어떻게 고쳐야 하는지"를 판단할 수 있다(F6 없음). 확인 못 한 것은 [미확인]으로 적는다.

# 지시서 — AUDIT-M7: 월드맵에서 3D 전장으로 들어가 싸우고 결과를 반영해 돌아오기 (읽기 전용 감사)

- 작성: 클코치, 2026-11-05 13:55 / 김작 결정: "당연히 3D 전장으로 옮겨가게 해야지. 3D 전장에서 싸우게 해야 해"(11-05 13:19). 이것이 설계서 `EASTWAR_3D_BATTLE_MASTER_DESIGN_v1_1` §9의 "M7 별도 승인"에 대한 승인이다. 이 지시서는 **감사까지만**이고 구현 지시서는 감사 보고서를 읽고 클코치가 따로 쓴다.
- 배경 [사실, 프로젝트 문서]: 지금 월드맵 공격은 `worldmap_main.gd`의 전투 진입 → `change_scene_to_file("res://scenes/battle/Battle_Main.tscn")`(2D 전투)로 간다. 3D 전장은 `scenes/battle3d/Battle3D_ScenarioShell.tscn`(독립 진입점, 고정 시나리오) 등으로 따로 있다. 설계서는 월드맵 왕복에 `samwar_worldmap_battle_context` / `samwar_worldmap_battle_result` 메타 핸드오프, T02 트랜잭션 ID 검증, 정산 원자성이 얽혀 있다고 적었고 계약은 `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`, 서비스는 `scripts/worldmap/battle/battle_context_service.gd`·`battle_result_service.gd`다. 후퇴 버튼은 "M7 때 작동"으로 미뤄졌고 엔진 쓰기가 하나 늘어난다(`claude/DECISION_LOG_20261024.md` §3). 3D 전장이 월드맵의 전투 데이터로 시작할 수 있는지는 [미확인].

## 0. 규칙
1. 코드·테스트·워크플로·씬·`project.godot` 수정 금지. 임시 실험은 하지 말 것(필요하면 "실험이 필요함"으로 보고). 새 폴더 금지.
2. push는 `feature/wm3d-intake-20261101`에 **보고서 커밋 1개만**(`[skip ci]`, force 없음). `gh`는 읽기만.
3. 추정은 [추정], 못 확인한 것은 [미확인]. 증명 안 된 것을 결론처럼 쓰지 말 것. 파일·줄 번호로 근거를 단다.
4. 시작 전 `git status` 깨끗, 이 일이 끝나면 `PROGRESS_WM3D.md`에 "M7 감사 완료" 한 줄(별도 `[skip ci]` 커밋 가능, 보고서와 같은 커밋도 허용).

## 1. 조사 항목 (보고서 표로)
1. **3D 전장 진입점들**: `scenes/battle3d/` 아래 씬(`Battle3D_ScenarioShell`, `Battle3D_EnginePlayLab`, `Battle3D_EngineConnectLab` 등)의 역할 구분과 현재 "최종본"이 무엇인지(`claude/BASELINE_FINAL_BUILD_20261030.md` 기준), 각각이 어떤 입력(시나리오 파일·고정 픽스처·context)으로 시작하는지. `scripts/battle3d/`의 시작 함수와 읽는 데이터.
2. **월드맵의 전투 문맥**: `worldmap_main.gd`에서 `samwar_worldmap_battle_context`를 만드는 곳(함수·줄), 담기는 키 전체(공격/방어 도시·부대·장수·병력·지형·`result_return_destination` 등), `battle_context_service.gd`의 역할. 2D 전투(`Battle_Main.tscn`, 스크립트 `scripts/battle_web_import_test.gd`)가 이 문맥을 어떻게 읽는지.
3. **3D 전장이 그 문맥으로 시작 가능한가**: 3D 쪽 시작 경로가 위 키들을 읽을 수 있는지, 없다면 빈 부분(예: 시나리오 고정, 장수·부대 편성 입력 부재)을 항목별로. "가능 / 부분 / 불가 / [미확인]"으로 판정.
4. **결과 반환·정산**: `samwar_worldmap_battle_result` 키 전체, `battle_result_service.gd`, T02 트랜잭션 ID 검증·정산 원자성 코드 위치(`_consume_worldmap_battle_result_if_any` 등), 2D 전투가 결과를 만드는 곳. 3D 전장에서 같은 결과 딕셔너리를 만들 수 있는지, 승패·피해·포로·점령 반영에 필요한 값이 3D 엔진에 있는지.
5. **복귀 경로**: `result_return_destination`(main ≈6516행)과 3D 전장 종료 후 월드맵으로 돌아가는 방법, 08에서 정식화된 `WorldMap.tscn` 3D 호스트가 복귀 때 다시 만들어지는 것과의 상호작용(전투 중 3D 월드맵 해제 확인은 07 보고서 참고). 3D 전장 → 월드맵 복귀 시 메모리·로딩 시간 추정 근거.
6. **엔진 쓰기·후퇴**: 현재 3D 연결의 엔진 쓰기 15개 목록과 "16번째 없음" 원칙, 후퇴가 월드맵 연결에서 필요로 하는 변경(후퇴 핸들러 두 개 정리 포함), 필요한 새 엔진 쓰기가 있는지.
7. **핀·검증기**: M7 구현이 `worldmap_main.gd`를 고쳐야 하는 줄이 몇 군데인지(전투 진입 분기, 복귀 목적지 등)와 핀 검증기(`validate_worldmap_diplomacy_routing.py`, `p1_exact_delta.py`) 재고정 영향. 2-E(카메라 분리)와 같은 커밋으로 묶을 수 있는 줄이 있는지 표로.
8. **폴백 설계**: 3D 전장을 못 쓰는 경우(모바일, 리소스 없음, 사용자 설정이 2D 전투)에 2D `Battle_Main.tscn`으로 되돌리는 방법. 설정 항목(2D/3D 전투)이 필요한지.
9. **설계서 M0~M6 현황**: 설계서 v1.1의 단계 표(§11.2)에서 지금 어디까지 구현·인수됐는지를 코드·테스트·보고서로 확인(M6 인수 기준 §11.4의 8개 중 충족/미충족). 월드맵 연결 전에 먼저 채워야 할 전투 UI·엔진 항목이 있으면 목록.
10. **테스트·CI 영향**: M7이 건드릴 기존 테스트(월드맵↔전투 왕복 테스트 2개의 `bool constructor` 오류 포함: `test_worldmap_battle_main_roundtrip_settlement.gd` 82행, `test_worldmap_to_battle_input_lifecycle.gd` 22행)와 새로 필요한 테스트 종류. 위 두 오류의 원인을 읽기 전용으로 확정(정의 없는 `_worldmap_battle_entry_handoff_in_progress`를 읽는 문제인지, 이번 08 변경과 무관한지 `git log -S`·이전 HEAD 대조로 증명).

## 2. 판정표 (보고서에 표로)
| 질문 | 판정 | 근거 |
|---|---|---|
| 3D 전장이 월드맵 문맥으로 시작할 수 있나 | 가능/부분/불가/[미확인] | |
| 결과 딕셔너리를 3D 엔진이 만들 수 있나 | | |
| 정산(T02) 변경 없이 연결 가능한가 | | |
| 새 엔진 쓰기가 필요한가(후퇴 포함) | | |
| `worldmap_main.gd` 수정이 필요한 줄 수 | | |
| M6 인수 기준 충족 상태 | | |

그 뒤 **단계 분해안**을 제시한다(적용 금지, 제안만): 예) M7-1 문맥 읽기, M7-2 결과 반환, M7-3 복귀·메모리, M7-4 후퇴, M7-5 설정·폴백. 각 단계의 수정 예상 경로, 위험, 필요한 김작 F6 항목, 추천 순서 1개를 이유와 함께.

## 3. 보고서·push
- 파일 `agent/REPORT_AUDIT_M7_20261105.md`. 맨 위 "기준 화면 / 합격 기준" 두 줄 → 3줄 요약(연결 가능성 / 가장 큰 장애 / 김작이 정할 것) → "택한 해석" → 1절 결과 표 → 2절 판정표와 단계 분해안 → 막힌 것 → 종료 루틴 5줄(① 정본 `git status`·HEAD ② 새로 만든 것 ③ push한 것 ④ CI(`[skip ci]`라 없음) ⑤ 김작이 결정할 것).
- 커밋: `docs(agent): report REPORT_AUDIT_M7_20261105 [skip ci]`, push 후 원격 해시 = 로컬 HEAD 확인.

## 4. 하지 않는 것
- 코드·테스트·씬·워크플로 수정, 3D 전장 연결 구현, 2-E(카메라 분리) 작업, 임시 실험 커밋, 재실행으로 때우기.
