기준 화면: 없음(3D HUD에 외교 창이 아직 안 붙어 있음 — `agent/REPORT_SPY_UI_3D_GAP_20261127.md`). 검증은 CI 시험과 클코치 독립 검증. 김작 F6은 HUD 연결 뒤 최종본에서 한 번에.
합격 기준: 외교 요청이 T에 접수(비용 예약)되고 T의 턴 끝 정산에서 한 번만 결과가 확정되어 T+1 시작에 보인다. 저장/불러오기·중간 불러오기에도 중복 정산·중복 차감·중복 반환 0. 기존 외교 수치·판정 그대로. CI C-track 4 shard 초록.

# REPORT_STRATEGY_P1 — 전략 요청 대장 + 기본 외교 T 접수 → T+1 결과 (큐 38, PC v0.2 P1) (클코드, 2026-11-27)

- **됐나**: 코드·시험·고정 다시 걸기를 끝냈다(CI는 7절). `worldmap_main.gd` **0줄 변경**.
- **가지**: `feature/wm3d-strategy-p1-20261127`, 시작 `main` `e3bf2537eea616d608f14f1fc44cdadfb69a8823`. 코드 `45ee6d9565bec6c8493a375bd86214be593d6290` → 고정 `e847d91`(마지막 커밋, `[skip ci]` 없음). `main` 병합 안 함(클코치).
- **작업 폴더**: 정본 폴더 `C:\dev\SamWar_BattleLab_cc`는 김작 F6 상태(`d7a9b3c`)를 건드리지 않으려고 쓰지 않았다. 이 가지는 별도 작업 트리 `C:\eastwar_tmp\strategy-p1`(큐 22 `C:\eastwar_tmp\bake`와 같은 방식)에서 만들었다.

## 1. 확인 결과 (지시서 2절, 코드 쓰기 전)
1. **현행 외교 흐름** [사실, `e3bf253`]: 플레이어 버튼 → `worldmap_action_coordinator.gd:168` → `diplomacy_controller.execute` → `diplomacy_action_service.execute`(26행). 그 안에서 순서대로 ① 문맥 만들기(`_build_diplomacy_action_validation_context`, 비용 확인 포함) ② `validate_action`(쿨다운·관계·자원) ③ **비용 차감** `apply_diplomacy_resource_cost`(62행, P0 도시 경로) ④ 동맹이면 `apply_alliance_action` → `propose_alliance(…, prepaid_payment)`(③의 결과를 prepaid로 넘겨 두 번 안 뺌), 아니면 우호도(`apply_diplomacy_relation_delta`)·**쿨다운**(`set_diplomacy_action_cooldown`, 80행)·교역 협정(`apply_trade_agreement_state`) ⑤ 결과 저장. `prepaid_payment`는 동맹 경로에서만 쓰였다.
2. **진입점**: 플레이어 외교 버튼은 모두 코디네이터 → `diplomacy_controller.execute`를 탄다(`_apply_diplomacy_action`·`execute_now`·영상 끝 `complete` 포함). 컨트롤러 `execute`를 부르는 곳은 코디네이터 하나뿐. 정탐 이간질·군사 지원은 다른 함수(`apply_spy_relation_delta`, `_request_military_support`)라 영향 없음. 시험 쪽: 외교 시험 4개가 "버튼 경로 결과 = 즉시 실행 결과"를 비교한다(3절 표).
3. **중간 저장 뒤 재진입**: `finish_enemy_turn`은 `completed_turn_resolution_ids`에 이번 턴이 있으면 바로 돌아간다(156~162행, 그대로). 없으면 내정(자체 중복 방지 `last_domestic_apply_turn`) → 새 정산 → 턴 넘김을 다시 돈다. 새 정산은 요청마다 `applied_transaction_id`(= 턴 정산 ID)를 찍고, 상태가 `pending`이 아니거나 같은 ID가 찍힌 요청은 건너뛰므로 두 번 적용되지 않는다(시험 8).
4. **기간·쿨다운이 줄어드는 자리**: 내정 `_apply_domestic_turn_mvp` 첫머리(`worldmap_main.gd` `_normalize_faction_relations_for_world_state` / `_advance_diplomacy_cooldowns_for_world_turn`, 서비스 `advance_diplomacy_state_entry`·`advance_alliance_state_entry`)에서 교역 협정 기간·쿨다운·동맹 기간을 1씩 줄인다. 새 정산은 그 **뒤**(턴 컨트롤러 `apply_domestic_turn` 다음, `advance_world_turn` 앞)에 들어가므로 새 동맹은 T+1 첫 화면에 8턴, 새 쿨다운도 온전한 값(사절 1, 동맹 4)으로 시작한다(시험 3·5·6).

## 2. 바꾼 자리
| 파일 | 자리 | 바꾼 것 |
|---|---|---|
| `scripts/worldmap/actions/strategy_request_service.gd`(새, +`.uid`) | 전체 | 대장(`_player_state.strategy_pending_requests`), 접수(`submit_player_diplomacy`, AI용 `submit_strategy_request`), 정산(`resolve_turn`), 무효·반환, 0-2 상수 |
| `diplomacy_action_service.gd` | `execute` 인자 `prepaid_payment`(기본 `{}`) | 비어 있으면 **지금과 완전히 같음**. 요청 자신의 예약을 넘기면 비용 확인을 통과로 보고 다시 빼지 않는다(나머지 판정·적용은 그대로) |
| `diplomacy_controller.gd` | `execute` | 플레이어 버튼 → `submit_player_diplomacy`(접수) |
| 〃 | 새 함수 | `execute_immediately`(예전 즉시 경로, 버튼은 안 씀), `submit_strategy_request`, `resolve_strategy_requests`, `get_pending_strategy_requests`, 도시 재고 전달 3개(`_get_national_payment_city_ids_mvp`·`_get_city_storage`·`_set_city_storage`) |
| `scripts/worldmap/turn/worldmap_turn_controller.gd` | `finish_enemy_turn` | 내정 뒤·턴 넘김 앞에 `_resolve_strategy_requests(source_turn, transaction_id)`. 결과는 `last_turn_resolution_result.strategy_request_results`와 상태 문구 "전략 요청 N건 결과" |
| 〃 | 새 `_resolve_strategy_requests` | 턴 컨트롤러를 가진 월드맵(부모 노드)의 `_ensure_diplomacy_controller()`를 통해 정산을 부른다. 지시서 1절대로 main에 새 명령 이름을 넣지 않았다 |
| `.github/workflows/verify-c-track.yml` | C-track 목록 | 새 시험 1줄 |
| 기존 외교 시험 4개, 검사기 1개, `tools/p1_exact_delta.py` | 3절·5절 | |

- **결과 표시(최소)**: 정산 결과는 `_player_state.last_strategy_request_results`(턴·정산 ID·요청별 결과), 각 외교 결과는 지금처럼 `last_diplomacy_action_result`, 턴 요약 `last_turn_resolution_result.strategy_request_results`, 상태 줄. 새 창 없음.
- **AI 접수 통로**: `submit_strategy_request(source, action, target_faction, target_city)`. AI 출처는 비용을 **그 세력의 도시**에서 원자적으로 예약하고, 정산은 같은 `resolve_turn`에서 두 세력 사이 우호도 + 그 쌍의 쿨다운으로 처리한다. 지원 행동은 사절·조공·관계 회복. **교역 협정·동맹은 AI 출처로 접수하지 않는다**(`unsupported_source_action`) — 외교 서비스의 교역 협정·동맹 함수가 "현재 플레이어 세력"에 묶여 있어 AI 출처로 바꾸려면 그 함수들을 크게 고쳐야 한다(지시서 0-1 6번의 STOP 범위; 플레이어 경로는 영향 없음). AI가 언제 외교를 할지는 P5.

## 3. 규칙 상수 (지시서 0-2) — `scripts/worldmap/actions/strategy_request_service.gd` 머리 한 곳
| 규칙 | 상수 | 값 |
|---|---|---|
| 비용 시점 | `RESERVE_COST_ON_SUBMIT` | `true`(접수 때 도시에서 원자 차감) |
| 결과 시점 | `RESOLVE_DELAY_TURNS` | `0`(T 턴 끝 정산 → T+1 시작에 보임, 플레이어·AI 같음) |
| 중복 | `MAX_PENDING_PER_PAIR_AND_DOMAIN` | `1`(국가 쌍·분야당) + 현행 쿨다운 그대로(정산 때 걸림) |
| 무효 | `REFUND_ON_INVALID` | `true`(예약분 1회 반환: 뺀 도시, 그 도시가 이제 남의 것이면 수도) |
| 정상 거절 | `KEEP_COST_ON_REJECTION` | `true`(동맹 수락 점수 < 70 → 비용 소모, 쿨다운 4) |
| 대상 행동 | `PLAYER_DIPLOMACY_ACTIONS` / `AI_SOURCE_ACTIONS` | 5종 / 사절·조공·관계 회복 |
- 비용·우호도·쿨다운·동맹 70점·기간 수치는 외교 서비스의 기존 정의(`get_action_definition`)를 그대로 쓴다(새 값 0).
- 침공: 정산은 침공 상태를 건드리지 않는다. T에 정해진 침공은 T+1 동맹으로 소급 취소되지 않는다(시험 11).
- **무효 판정**: 정산 때 ① 대상·출처 세력이 `defeated_factions`에 있음 ② 그 쌍의 관계 항목이 `faction_relations`에 없음 ③ 대상 도시의 현재 소유가 접수 때 대상 세력과 다름 ④ 기존 검증(쿨다운·관계 상태 등)이 실패 — 중 하나면 `invalid` + 1회 반환. 동맹 수락 점수 미달은 무효가 아니라 정상 거절.

## 4. 고정 다시 걸기
- ① 코드 `45ee6d9` → ② 고정 `e847d91`(`tools/p1_exact_delta.py`만, `P1_STRATEGY_CHECKPOINT = "45ee6d9…"`).
- `frozen_text_matches`를 **승인 단계 사슬**로 넓혔다: 동결 파일은 검사기가 기대하는 글 → (P0 단계가 있으면) P0 정확한 차이 → (P1 단계가 있으면) P1 정확한 차이로만 바뀔 수 있다. P0만 있던 파일·단계 없는 파일의 판정은 예전과 같다.
- P1 정확한 차이(P0 글 기준): `diplomacy_action_service.gd` 9줄, 시험 `routing` 5줄·`mutation_extraction` 3줄·`state_extraction` 3줄.
- 컨트롤러 함수 동결(`validate_worldmap_diplomacy_controller_extraction.py`): 새 `approved_function_body`로 `execute` 본문만 정확한 차이 4줄 허용. 늘어난 함수 목록·main 호출 허용 목록에 이번 이름을 더함(지우거나 느슨하게 한 검사 0).
- `worldmap_main.gd`는 안 바뀌어 P0 고정(`e206d60`)이 그대로 맞는다.
- 정적 검사기 72개 → 실패 0. `validate_worldmap_trade_phase2_extraction.py`는 커밋 전 작업 트리만 보므로 커밋 뒤 PASS(P0·P3 때와 같음).

## 5. 기존 시험 변경 — 기대 동작 변경은 "즉시 → 다음 턴"만
| 시험 | 전 기대 | 후 기대 | 이유 |
|---|---|---|---|
| `test_worldmap_diplomacy_routing` `_parity` | 버튼 경로 결과·상태 = 즉시 실행(`service.execute`) | 버튼 경로 결과·상태 = 접수(`submit_player_diplomacy`) | 버튼이 접수로 바뀜 |
| 〃 91행(동맹, 수락 점수 0) | 실패(거절) | 접수 성공(수락 판정은 턴 끝) | 판정 시점이 T 턴 끝으로 |
| `test_worldmap_diplomacy_mutation_extraction` `_check_production_parity` | 버튼 결과·상태 = 즉시 실행 | = 접수 | 같음 |
| `test_worldmap_diplomacy_state_extraction` 교역 협정 생산 경로 | = 즉시 실행 | = 접수 | 같음 |
| `test_worldmap_diplomacy_controller_extraction` 표시 확인 | 버튼 직후 "관계 80 → 85 / 금전 -30", 쿨다운 1 | **턴 끝 정산 1번 뒤** 같은 문구·쿨다운 1 | 결과는 정산 뒤에 보임. 수치 그대로 |
| 〃 가짜 호스트 | — | 도시 재고 전달 3개 추가(준비 단계) | 대장이 도시별로 예약·반환 |
- 수치(비용 30/100/80/120/금 200+비단 50, 우호도, 쿨다운 1/2/2/3/4, 70점, 교역 협정 6턴·동맹 8턴) 기대값은 하나도 안 바꿨다. 서비스 `execute`를 직접 부르는 외교 시험(즉시 경로)은 그대로 통과한다.

## 6. 시험 결과
새 통합 시험 `tests/scripts/test_worldmap_strategy_p1.gd`(+`.uid`, C-track 등록), 실제 `WorldMap.tscn` 새 게임: `[STRATEGY_P1] checks=49 failures=[]`. 3·5·6은 실제 턴 끝(`request_end_turn` → `finish_enemy_turn`)을 탄다.
1. 사절 접수 → 금 30 즉시 도시에서 빠짐(국가 = 도시 합계), 우호도 그대로, 대기 1건 ✔
2. 같은 대상 두 번째 요청 → `pending_request` 거절, 추가 차감 0 ✔
3. 턴 끝 → T+1: 우호도 +델타, 쿨다운 1, 요청 `resolved` + `applied_transaction_id` ✔ / 정산 자체는 도시 재고를 바꾸지 않음(다시 안 뺌) ✔
4. 조공·관계 회복(적대)·교역 협정: 현행 우호도 델타·쿨다운 2/3/2, 교역 협정 6턴 ✔
5. 동맹: 수락 70 → T+1 동맹 8턴 ✔ / 수락 69 → 거절, `resolved`(무효 아님), 비용 그대로 소모, 쿨다운 4 ✔
6. 기존 동맹 5 → 4, 새 동맹 8(같은 턴 끝) ✔
7. 관계 항목 삭제 → `invalid`, 30이 뺀 도시(한성)로 1회 반환, 다시 정산해도 두 번 반환 없음 ✔ / 예약한 도시(평양)를 잃은 경우 → 수도(한성)로 ✔
8. 접수 → 저장(JSON)→불러오기 → 정산: 결과 1회, 차감 0 ✔ / 정산 → 저장→불러오기 → 같은 정산 ID로 다시 정산: 변화 0 ✔ / 다른 ID로 다시 정산해도 이미 정산된 요청은 그대로 ✔
9. 예약 뒤 수도 금 10만 남김 → 재상 자동무역(내부·대외 재상 모드) 뒤에도 예약 30은 요청에 그대로, 자동무역은 남은 금 안에서만 움직임 ✔
10. AI 출처 사절(세력 A → B) → A의 도시에서 30 예약 → 같은 정산에서 A–B 우호도 +5, 그 쌍 쿨다운 1 ✔
11. T에 걸려 있던 침공 이벤트는 같은 정산에서 성립한 동맹으로 바뀌지 않음 ✔
12. P0·P3 회귀: `test_worldmap_stock_authority_p0`·`test_worldmap_spy_intel_p3`는 C-track 목록에 그대로 있고 6절 전체 실행에 포함.
- 중간 저장 재진입(지시서 5절 8번 뒷부분)은 턴 컨트롤러의 `finish_enemy_turn` 재진입 대신 **같은 정산 ID로 정산을 다시 부르는 것**으로 확인했다(중복 방지는 요청마다 찍힌 정산 ID와 기존 완료 ID 두 겹). 실제 저장 파일을 단계 중간에 만들어 불러오는 재현은 하지 않았다.

## 7. CI
- `Verify C-track refactor` 실행 `46005936669` (head `e847d91`): **초록**. 4개 묶음(shard 0~3) 모두 success, 재실행 없음. 끝난 시각 2026-11-27 13:38 UTC.
- 이번 변경은 `Verify WorldMap3D` 경로 조건에 걸리지 않아 그 작업은 돌지 않았다.

## 8. 로컬 전체
- 작업 트리 `e847d91`에서 C-track 시험 213개 전체(CI 목록 그대로, 4개 병렬): **213 실행, 213 종료 코드 0**. 새 시험 `test_worldmap_strategy_p1` 결과 `[STRATEGY_P1] checks=49 failures=[]`.
- 검증 스크립트 72개 전체(`tools/validate_*.py`, CI 목록 그대로): **72 통과, 실패 0**.
- 참고: 첫 전체 실행은 내 실행 스크립트가 경로를 넘기지 않아 정본 폴더(`d7a9b3c`)에서 돌았다(새 시험만 "파일 없음"). 경로를 고쳐 작업 트리에서 다시 돌린 결과가 위 숫자다.

## 9. 남은 문제
- AI 출처 교역 협정·동맹은 접수 거절(2절). 외교 서비스의 교역 협정·동맹 함수를 세력 두 개를 받게 바꿔야 한다(P5 때).
- 버튼 결과 화면은 접수 결과를 보여 준다(관계 변화 없음 + 비용). T+1에 나오는 결과는 상태 줄·`last_diplomacy_action_result`·턴 요약에만 있고 새 창은 없다(HUD 연결 때).
- 대기 중인 요청의 취소(`cancelled` 상태)는 상태 이름만 있고 취소 기능은 없다(범위 밖).
- 3D HUD에서는 외교 창이 숨겨져 있어(`REPORT_SPY_UI_3D_GAP_20261127.md`) F6에서 버튼을 누를 수 없다 — 검증은 시험으로만.

## 10. 최종 F6 체크리스트 (HUD 연결 뒤)
1. 적 도시 선택 → 외교 → 사절 파견: 그 자리에서 국가 창고·수도 창고 금 30이 줄고, 우호도는 그대로, "요청을 접수했습니다. 결과는 다음 턴에" 문구.
2. 같은 세력에 바로 다른 외교 → "이미 접수되어 있습니다" 거절, 금 그대로.
3. 턴 넘기기 → 다음 턴 첫 화면: 우호도 +5, 쿨다운 1턴, 상태 줄에 "전략 요청 1건 결과".
4. 동맹 제안(우호도 높게) → 다음 턴: 동맹 8턴. 낮게 → 거절, 비용은 돌아오지 않음, 쿨다운 4턴.
5. 교역 협정 → 다음 턴: 6턴.
6. 외교 접수 → 저장 → 불러오기 → 턴 넘기기: 결과 한 번, 금 다시 안 빠짐.
7. 외교 접수 뒤 그 세력이 망하면(또는 대상 도시를 빼앗기면) → 다음 턴: 무효, 비용이 돌아옴(한 번).
