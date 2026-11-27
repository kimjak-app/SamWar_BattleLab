기준 화면: `WorldMap.tscn`(F6, 3D 월드맵) — 국가 창고 창, 도시 상세 창(창고), 무역(수동·재상 자동·내부 이송), 도시·국가 연구 시작.
합격 기준: 김작 F6에서 ① 국가 창고 = 소속 도시 재고 합계로 보이고 ② 무역·이송 뒤에도 국가 합계가 맞고 ③ 생산으로 모은 자원으로 도시 연구를 시작할 수 있고 ④ 치트 Ctrl+Shift+G 뒤 국가 창고가 0/9999가 아니라 채운 값으로 보이면 합격. 그리고 C-track 4 shard + WorldMap3D 초록.

# 큐 36 — STOCK-AUTHORITY-P0: 도시 재고 장부를 `resource_stock` 하나로

작성: 클코치 / 2026-11-27. 승인: 김작 11-27 12:17 채팅 "재기준 승인, 이 작업하는 동안 계속 허락할거야. 승인 전부" + 공유 폴더 `00_EASTWAR_GOAL_SPY_01.md`의 김작 승인 범위(A안). 관련: `claude/COOP_SPY_STOCK_AUTHORITY_20261127.md`(프로젝트 문서), 드라이브 회신 `01_클코치_GOAL-SPY-01_회신.md` 3절.

## 0. 왜
[사실, `main 8cc0640`] 도시 재고가 두 장부로 갈라져 있다.
- `resource_stock`(`_city_runtime_states[city]["resource_stock"]`): 생산·유지비(`city_resource_service`), 외교 비용(`diplomacy_action_service`), 전투 정산(`t03/strategic_battle_transaction_service`), 출병(`military/player_attack_deployment_service`). 국가 합계는 `CityResourceService.aggregate_city_stocks()` → `sync_player_resource_compatibility()`가 **이것만** 더해 `_player_state["resource_stock"]`에 넣는다.
- `storage`(`_city_runtime_states[city]["storage"]`): 무역 3종(`trade_action_service`, `trade_automation_service`, `internal_trade_transfer_service`, `trade_controller`), 도시 연구 비용(`domestic_tech_research_service` 도시 범위), 도시 상세 창(`city_detail_presentation_controller`), 테크 효과(`domestic_tech_effect_provider`), 치트(`worldmap_debug_cheats_controller`), `economy_city_helpers`. `worldmap_main.gd` 안에서 41곳. 기본값은 **한성만 국가 합계 복사**, 나머지 0(`city_resource_service.gd::build_default_city_storage`).
- 국가 합계를 직접 쓰는 곳: `domestic_tech_research_service.gd` 286행(국가 연구 비용), `worldmap_main.gd::_apply_generic_resource_cost`(7905행~, 7927행 쓰기), `_rebuild_occupation_runtime_indexes_mvp`(7191행~, 7212행 쓰기).
- 증상[추정]: 무역 수익이 국가 창고에 안 보임, 생산 수입으로 도시 연구 불가("자원이 부족해 연구를 시작할 수 없습니다"), 치트 ① 뒤 국가 창고 0/9999.

## 1. 결정된 규칙 (김작 승인)
1. **재고는 도시별 `resource_stock` 하나.** 국가 창고는 **현재 소속 도시의 품목별 합계를 보여 주기만** 한다. 국가 창고를 따로 저장하거나 따로 증감하지 않는다.
2. `storage`는 **없앤다.** 읽던 곳은 `resource_stock`을 읽고, 쓰던 곳은 `resource_stock`에 쓴다.
3. 국가 단위 비용(국가 연구, 일반 비용 등)은 **도시에서 빼는 방식**: 이미 있는 `plan_national_city_stock_payment`(`city_resource_service.gd` 191행~) 또는 수도 우선 `apply_player_resource_delta_capital_first`를 쓴다. 어느 쪽인지는 각 자리의 지금 의미(국가 전체에서 빼던 것)에 맞춰 고르고 보고서에 표로.
4. **옛 세이브(A안)**: 불러올 때 `resource_stock`만 이어받고 `storage`는 **합산하지 않고 버린다.** 버린 값은 도시별로 로그 한 줄(`[STOCK_MIGRATION] city=… dropped_storage={…}`). 세이브 형식에 재고 단일화 표시(예: `stock_ledger: "resource_stock_v1"`)를 넣어 두 번 처리하지 않는다. 기존 세이브 원본은 **작업 시작 전에** `user://` 세이브 폴더를 `C:\eastwar_tmp\saves_backup_20261127\`로 통째 복사(삭제 아님).

## 2. 가지·금지
- 새 가지 `feature/wm3d-stock-p0-20261127`(`main` `8cc0640`에서). 푸시는 이 가지만. `main` 합류는 **김작 F6 합격 뒤** 별도 합류 지시서(김작 11-27 "승인 전부" — F6 "합격"을 합류 승인으로 본다).
- **`worldmap_main.gd` 수정 허용**(이번 작업 한정, 김작 재기준 승인). 범위는 `storage`·국가 직접 쓰기·세이브 마이그레이션 관련 줄만. 그 밖의 줄을 바꾸면 멈춤.
- 허용 서비스 파일: 0절 목록 + `city_resource_service.gd`. 그 밖은 멈추고 보고.
- 바이트 고정은 **풀지 않고 다시 건다**(3절).
- 새 `.gd`·`.tscn`은 `.uid` 같이. 푸시의 마지막 커밋은 코드 커밋(`[skip ci]` 금지).
- 삭제·강제 푸시 없음.

## 3. 바이트 고정 다시 걸기 (`tools/p1_exact_delta.py`)
[사실] 지금 방식: `assert_main_is_approved_p1_state`가 현재 `worldmap_main.gd` == 커밋 `9b2cd8e`(`P1_MAIN_CHECKPOINT`)의 내용인지 보고, `EXPECTED_P1_MAIN_DELTA`로 그 전 단계와의 줄 차이를 고정한다(P-1C·P-1D 때 같은 방식). 부르는 곳: `validate_worldmap_diplomacy_routing.py`, `validate_worldmap_player_attack_deployment_service_extraction.py`, `validate_worldmap_t03_battle_presentation_extraction.py`.
- 같은 방식으로 한 단계 추가: `P0_STOCK_MAIN_CHECKPOINT = <코드 커밋 SHA>` + `EXPECTED_P0_STOCK_MAIN_DELTA = line_delta(<9b2cd8e 내용>, <새 내용>)`(파일 머리 주석의 재생성 방법 그대로). 현재 파일은 새 체크포인트와 같아야 하고, 새 체크포인트와 `9b2cd8e` 사이의 줄 차이는 이 목록과 정확히 같아야 한다. **기존 `P1` 검사도 남긴다**(옛 단계의 차이도 계속 고정).
- 순서: ① 코드 커밋(`worldmap_main.gd` 포함) ② 고정 커밋(`p1_exact_delta.py`만, ①의 SHA를 적음, `worldmap_main.gd`는 안 바뀜). 두 커밋을 **한 번에 푸시**하고 ②가 마지막이라 CI가 ②에서 돈다(①만으로는 고정 검사가 실패하는 게 정상).
- `validate_worldmap_main_integrity.py` 등 `worldmap_main.gd` 내용을 보는 다른 검사기가 깨지면: 기대값 수정이 이번 변경의 직접 결과일 때만 고치고, 고친 검사기·줄·이유를 표로. 판단이 애매하면 멈춤.

## 4. 순서
1. **조사표 먼저(코드 수정 전, 보고서 첫 절)**: `storage` 읽기·쓰기 전부(파일·줄·읽기/쓰기·바꿀 방식), 국가 직접 쓰기 전부, `storage`를 보는 시험·검사기 전부[클코치가 본 것: `test_worldmap_domestic_tech_research_service_extraction`, `test_worldmap_city_resource_service_extraction`, `test_worldmap_debug_cheats`, `test_worldmap_diplomacy_controller_extraction`, `test_worldmap_trade_controller_extraction`, `test_worldmap_domestic_tech_effect_provider_extraction`, `test_worldmap_internal_trade_transfer_extraction`, `test_worldmap_city_detail_presentation_extraction`, `test_worldmap_trade_routing`, `test_worldmap_trade_automation_extraction`, `test_unit3d_face_travel`, `tools/validate_worldmap_main_integrity.py`], 세이브 저장·복원 경로(`worldmap_main.gd` 12934·13058행 근처). 멈춤 조건이 아니면 그대로 이어서 구현.
2. 세이브 백업 → 구현 → 시험 → 고정 다시 걸기 → 푸시.

## 5. 시험
- **기존 시험 기대값 규칙**: `storage`를 직접 확인하던 시험은 `resource_stock` 기준으로 고친다(이번 변경의 직접 결과). 그 밖의 기대값(수치·순서·문구)은 바꾸지 않는다. 바뀐 시험마다 "전/후 기대값, 이유"를 표로.
- 새 시험 `tests/scripts/test_worldmap_stock_authority_p0.gd`(+`.uid`), 출력 `[STOCK_AUTHORITY_P0] checks=N failures=[]`, C-track 등록:
  1. 같은 세력 A·B 쌀 40·60 → 국가 창고 100.
  2. A→B 내부 이송 10 → 30·70, 국가 100.
  3. 재상 자동무역·수동 무역 뒤 국가 합계 = 도시 합계(무역으로 늘어난 금이 국가 합계에 보임).
  4. 생산으로 늘어난 자원으로 도시 연구 시작 가능, 비용이 해당 도시 `resource_stock`에서 빠짐.
  5. 국가 연구 비용이 도시에서 빠지고, 턴 뒤 국가 합계 재계산에서도 빠진 채 유지(되살아나지 않음).
  6. 저장 → 불러오기 후 도시·국가 값 같음, 이중 반영 없음.
  7. 옛 형식 세이브(`storage`와 `resource_stock`이 다른 값) 불러오기 → `resource_stock`만 남고 로그 1줄, 다시 저장·불러오기 해도 그대로.
  8. 도시 소유권이 바뀌면 국가 합계 대상이 바뀜.
  9. 치트 Ctrl+Shift+G 뒤 국가 창고 = 도시 합계(9999 계열 값), 0/9999 아님.
  10. 저장 파일에 `storage` 키가 더 이상 생기지 않음.
- C-track 4 shard + WorldMap3D 초록. 육전 컷인 길이 검사(shard 0, 알려진 간헐 문제)만 빨가면 멈추지 말고 보고.

## 6. 보고
`agent/REPORT_STOCK_AUTHORITY_P0_20261127.md`(5줄 종료 루틴): 조사표, 바꾼 자리 표, 국가 비용 처리 방식 표, 바뀐 시험 표, 고정 다시 걸기(두 SHA·줄 차이 개수), 세이브 백업 위치, CI 실행 번호, F6 체크리스트.

## 7. 범위 밖
정탐 연결(이 다음 큐), 외교·무역 T+1, 무역 양국 정산, 새 자원 품목, 치트 ① "전 자원 9999"로 바꾸기(별도 — 단 9번 시험이 통과하면 표시 문제는 해결).
