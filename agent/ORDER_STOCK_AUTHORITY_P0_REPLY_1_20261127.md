기준 화면: 큐 36 지시서와 같음 — `WorldMap.tscn`(F6) 국가 창고·도시 상세 창고·무역 3종·도시/국가 연구·외교·정탐·모병 비용.
합격 기준: 큐 36 지시서와 같음 + 외교·정탐·모병 비용이 도시에서 빠지고 턴이 지나도 되살아나지 않음.

# 큐 36 답신 1 — A안 승인: 외교 비용도 도시에서 빼기, 허용 범위 확장

작성: 클코치 / 2026-11-27 12:40. 대상: `agent/REPORT_STOCK_AUTHORITY_P0_STOP_20261127.md`(`dd962cb`). 승인 근거: 김작 11-27 12:17 "재기준 승인, 이 작업하는 동안 계속 허락, 승인 전부".
멈춤은 정당했다. **지시서 0절에서 외교 비용을 도시 `resource_stock` 사용처로 적은 것은 클코치 오류**다(실제로는 `diplomacy_action_service.gd` 666~712행이 국가 합계를 직접 읽고 쓴다). 조사표 1~3절의 해석(접근 함수 이름 `_get_city_storage`/`_set_city_storage`/`get_city_storage`/`city_storage`는 남기고 내용만 `resource_stock`)은 **그대로 승인**.

## 1. 허용 범위 추가
1. `scripts/worldmap/actions/diplomacy_controller.gd`: 국가 비용 확인·차감 전달 함수 2개(보고서 5절 A-1 그대로, main `_can_pay_generic_resource_cost`/`_apply_generic_resource_cost`로).
2. `scripts/worldmap/actions/diplomacy_action_service.gd`: `can_pay_diplomacy_resource_cost`/`apply_diplomacy_resource_cost`가 호스트에 그 함수가 있으면 위임, 없으면 지금 코드(보고서 5절 A-2). 반환 모양 `{before, after, cost, paid}` 유지. `validate_worldmap_diplomacy_service_separation.py:77`에 걸리지 않게(새 이름 권장).
3. 시험 9개(보고서 3-4)의 **준비 단계만** 변경: 국가 `resource_stock`에 심던 값을 시험이 쓰는 소속 도시(없으면 수도) `resource_stock`에 심고 합계 재계산. 기대값(수치·순서·문구)은 그대로. 대상: `test_worldmap_diplomacy_alliance_extraction`, `test_worldmap_diplomacy_controller_extraction`, `test_worldmap_diplomacy_mutation_extraction`, `test_worldmap_diplomacy_routing`, `test_worldmap_diplomacy_state_extraction`, `test_worldmap_diplomacy_validation_extraction`, `test_worldmap_spy_controller_extraction`, `test_worldmap_spy_routing`, `test_worldmap_military_controller_extraction`. 가짜 호스트를 쓰는 시험은 가짜 호스트에 도시 상태를 주는 방식으로.
4. `test_worldmap_diplomacy_mutation_extraction.gd`의 "`_apply_generic_resource_cost`와 `apply_diplomacy_resource_cost` 결과 일치" 확인은 **유지**한다(위임하면 둘이 같은 경로라 일치해야 정상).
5. 보고서 2절 표의 국가 읽기 자리(`1463~1464`, `7837~7839`, `12281~12282`, `12296~12297`, `13345~13349`, 연구 서비스 227·590행)도 바꾸는 것 허용. 특히 **1463~1464행이 `national_aggregation.resources`를 안 고치는 문제는 같이 고친다**(국가 창고 창이 옛 값을 보이는 원인 [추정]).

## 2. 시험 추가 (지시서 5절에 더함 — 채비서 검수 요청, 드라이브 `04_채비서_GOAL-SPY-01_최종검수_인계.md`)
11. 옛 세이브에서 `resource_stock`이 0이고 `storage`에만 값이 있는 도시는 불러온 뒤에도 **0**(A안, 합산 없음).
12. 여러 품목 비용(예: 금 + 비단, 금 + 식량) 중 **하나라도 모자라 거절되면 아무 품목도 빠지지 않는다**(부분 차감 금지). 외교·정탐·모병·국가 연구 각 1건.
13. 국가 비용 차감 뒤 도시별 합계가 정확히 그 비용만큼 줄고, 턴(국가 합계 재계산)이 지나도 되살아나지 않는다(지시서 5번을 외교·정탐·모병까지).

## 3. 나머지
지시서 그대로(고정 다시 걸기 3절 순서, 컷인 길이 검사만 빨가면 보고, 마지막 커밋은 코드 커밋). 보고서에 "답신 1" 절 + 위 1-3의 바뀐 시험 표.

## 4. 보고서에 같이 적을 것 (채비서 검토 `08_채비서_…STOP답신검토`, 12:41 추가)
- 외교 위임으로 바뀐 것은 **비용 확인·차감·합계 갱신뿐**이고 외교 점수·수락/거절·쿨다운·동맹 기간은 그대로임을 diff 근거로 한 줄씩.
- 시험 9개 표는 칸을 "준비 단계(재고 심기) 변경" / "기대 동작 변경"으로 나눈다. 기대 동작 변경 칸은 0이어야 한다.
- 시험 12(부분 부족 거절)는 도시 재고·국가 합계·결과 메시지 세 가지가 모두 시도 전과 같음을 확인.
