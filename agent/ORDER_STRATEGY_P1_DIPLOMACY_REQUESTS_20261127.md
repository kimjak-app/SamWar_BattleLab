기준 화면: 없음(3D HUD에 외교 창이 아직 안 붙어 있음 — `agent/REPORT_SPY_UI_3D_GAP_20261127.md`). 검증은 CI 시험과 클코치 독립 검증. 김작 F6은 HUD 연결 뒤 최종본에서 한 번에.
합격 기준: 외교 요청이 T에 접수(비용 예약)되고 T의 턴 끝 정산에서 한 번만 결과가 확정되어 T+1 시작에 보인다. 저장/불러오기·중간 불러오기에도 중복 정산·중복 차감·중복 반환 0. 기존 외교 수치·판정(비용, 우호도, 쿨다운, 동맹 70점, 기간)은 그대로. CI C-track 4 shard 초록.

# 큐 38 — 전략 요청 대장(공통) + 기본 외교를 T 접수 → T+1 결과로 (PC v0.2 P1)

작성: 클코치 / 2026-11-27 20:55. 기준 `main` `e3bf253`(큐 36 P0 + 37 P3 합류본).
승인: 김작 11-27 "재기준 승인, 이 작업하는 동안 계속 허락, 승인 전부" / 20:39 "main에 합쳐(조건부)" / 20:44 "규칙은 나중에 고칠 수 있다, 지금은 제대로 돌아갈 기본". **규칙은 아래 0-2 기본안(전부 현행 값·현행 판정)으로 구현**하고, 바꿀 수 있게 상수 한 곳에 모은다.
새 가지: `feature/wm3d-strategy-p1-20261127` (`e3bf253`에서). 이 가지 푸시는 승인됨. `main` 병합은 클코치가 CI·검증 뒤 한다(클코드는 안 함).

## 0. 범위
### 0-1. 만드는 것
1. **전략 요청 대장**(공통, 외교·무역 공용): `_player_state["strategy_pending_requests"]`(저장은 `_player_state` 통째 저장이라 자동, 12737행). 항목 키: `request_id`, `domain`("diplomacy"), `action_id`, `source_faction_id`, `target_faction_id`, `target_city_id`(있으면), `submitted_turn`, `resolve_turn`(= submitted_turn), `status`("pending"/"resolved"/"invalid"/"cancelled"), `reserved_assets`(도시별 실제로 뺀 양 `{city_id: {res: n}}`), `fixed_context`(접수 때 판정에 필요한 값), `applied_transaction_id`, `result`.
2. **접수**: 플레이어 외교 행동 5종(사절·조공·교역 협정·관계 회복·동맹 제안)을 누르면 즉시 실행 대신 접수. 접수 때 ① 기존 검증(`can_execute`류) ② **같은 국가 쌍·같은 분야(diplomacy)에 pending 1건이면 거절** ③ 비용을 P0 국가 비용 경로(도시에서 원자 차감)로 **즉시 예약**(빠진 도시별 양을 `reserved_assets`에) ④ 항목 저장.
3. **정산**: 세계 턴 T의 턴 끝에서 그 턴의 pending을 `request_id` 순으로 한 번씩 정산. 결과 = 기존 외교 서비스의 실행 결과(우호도·쿨다운·동맹·교역 협정 기간)를 그대로 적용. 예약한 비용은 이미 빠졌으므로 **정산 때 다시 빼지 않는다**(기존 `prepaid_payment` 경로 재사용, 단 "자기 요청의 유효한 예약"인지 확인 — 채비서 25 코드 메모).
4. **무효 처리**: 정산 때 대상 세력이 없어졌거나(멸망·관계 항목 없음) 기존 검증이 실패하면 `invalid` + 예약분을 **한 번만** 돌려준다(뺀 도시로, 그 도시가 이제 내 것이 아니면 수도로). 정상 거절(동맹 점수 < 70)은 현행대로 비용 소모·쿨다운 적용.
5. **결과 표시(최소)**: T+1 시작 때 `last_turn_resolution_result`(이미 있는 결산 요약)에 외교 결과 줄을 더하거나, 그게 고정 파일이면 `_player_state["last_strategy_request_results"]`에 남기고 상태 문구 한 줄. 새 창은 만들지 않는다(HUD 연결 때).
6. **AI 접수 통로**: 같은 대장에 `source_faction_id`가 AI인 항목을 넣는 함수(`submit_strategy_request(source, …)`)와 정산 경로. AI가 **언제** 외교를 할지 정하는 판단은 P5(이번 범위 아님). 이번엔 시험에서 AI 항목 1건(사절)을 넣어 같은 정산을 타는지만 본다. 기존 외교 서비스가 "현재 플레이어 세력"에 묶여 있어 AI 출처 정산이 크게 바뀌어야 하면 **그 부분만 STOP 보고**(플레이어 경로는 계속).

### 0-2. 규칙 기본안 (김작 20:44 — 나중에 고칠 수 있게 상수로)
| 규칙 | 값 |
|---|---|
| 비용 | 현행(사절 금 30, 조공 100, 교역 협정 80, 관계 회복 120, 동맹 금 200+비단 50) |
| 비용 시점 | 접수 때 예약(도시에서 원자 차감) |
| 결과 시점 | T 턴 끝 정산 → T+1 시작에 보임. 플레이어·AI 같음 |
| 정상 거절 | 비용 소모(현행) |
| 무효 | 예약분 1회 반환 |
| 중복 | 국가 쌍·분야당 pending 1건 + 현행 쿨다운 그대로(쿨다운은 정산 때 걸림 — 현행 "실행 때" 위치 그대로) |
| 동맹 판정 | 현행 점수 ≥ 70 결정론 |
| 침공 | T에 이미 정해진 침공은 T+1 동맹으로 소급 취소 안 함 |

### 0-3. 안 하는 것
대외무역·물물교환(P2), 새 비용·확률·기간, AI 외교 판단(P5), 원군(P6), UI 창(HUD 연결 작업), 테크 게이트.

## 1. 정산 자리 — **내정 뒤, 턴 넘기기 앞** [클코치 기술 결정]
`scripts/worldmap/turn/worldmap_turn_controller.gd` `finish_enemy_turn()`:
```
stage = domestic_resolution
apply_domestic_turn            (기존: 외교 기간·쿨다운 감소 → 생산 … → 시장가 → 재상 자동무역)
[새] resolve_strategy_requests(source_turn, transaction_id)   ← 여기
advance_world_turn (T → T+1)
```
- 이유: 내정이 기존 기간·쿨다운을 1씩 줄인 **뒤**에 새 결과를 넣으면 새 동맹은 T+1 첫 화면에 8턴, 새 쿨다운도 온전한 값으로 시작한다(채비서 28·25의 4/8 경계 문제를 상수 보정 없이 해결). 예약은 접수 때 이미 빠졌으므로 같은 턴 재상 자동무역이 그 돈을 쓸 수 없다.
- 예전 클코치 제안("내정 앞")과 달라진 점이다. 외교 결과가 같은 턴 무역 효율에 반영되는 문제는 P2에서 무역 정산을 이 자리 **안에서 외교 다음**에 두면 된다.
- 턴 컨트롤러의 `_do`는 main 이름 분기라 새 이름을 못 넣는다. 정산은 **새 서비스**(`scripts/worldmap/actions/strategy_request_service.gd` 등)가 맡고, 턴 컨트롤러는 그 서비스를 부르기만 한다. 서비스는 외교 컨트롤러(`_ensure_diplomacy_controller`)를 통해 쓴다. main을 꼭 건드려야 하면 4절.
- 중복 방지: 항목 `applied_transaction_id == transaction_id`면 건너뜀. 이미 `completed_turn_resolution_ids`에 있는 턴이면 정산 함수 자체를 안 부름(기존 조기 반환 그대로).

## 2. 확인부터 (코드 쓰기 전, 보고서 1절)
1. 현행 외교 `execute` 흐름에서 비용 차감·결과 적용·쿨다운 설정이 어디서 일어나는지, `prepaid_payment`가 어떻게 쓰이는지.
2. 플레이어 외교 버튼(2D 패널)·외교 라우팅 시험이 부르는 진입점. 접수로 바꾸면 **기존 외교 시험의 기대 동작이 바뀐다**(즉시 → 다음 턴). 바뀌는 시험 목록과 이유를 표로(아래 3절).
3. 중간 저장(stage `domestic_resolution` 도중) 뒤 불러오기에서 `finish_enemy_turn`이 다시 도는 경로.
4. 동맹·교역 협정 기간과 쿨다운이 줄어드는 정확한 자리(내정 안 1번 단계)와 새 결과가 그 뒤에 들어가는지.

## 3. 기존 시험
- 외교가 "즉시"에서 "다음 턴"으로 바뀌는 것은 **의도된 기대 동작 변경**이다. 바꾸는 시험은 표로: 시험 / 전 기대 / 후 기대 / 이유. 수치(비용·우호도·쿨다운·70점·기간)는 그대로여야 한다.
- 즉시 실행 경로가 다른 곳(치트, 정탐 이간질, 군사 지원 등)에서 쓰이면 그 경로는 그대로 둔다(외교 행동 5종의 플레이어 버튼 경로만 접수로).

## 4. 허용 파일
새 파일(`scripts/worldmap/actions/strategy_request_*.gd`, 새 시험), `diplomacy_action_service.gd`, `diplomacy_controller.gd`, `diplomacy_presentation_helper.gd`, `scripts/worldmap/turn/worldmap_turn_controller.gd`, 기대 동작이 바뀌는 외교 시험, `verify-c-track.yml`, 검사기·`tools/p1_exact_delta.py`(고정 다시 걸기·정확한 차이 허용만).
- `worldmap_main.gd`는 원칙적으로 안 건드림. 꼭 필요하면 한 줄 전달 함수까지 + P0 방식 재고정(`P1_STRATEGY_MAIN_CHECKPOINT` + 정확한 차이, 기존 확인 유지). 턴 컨트롤러를 검사하는 `validate_worldmap_main_integrity.py`·`validate_worldmap_wounded_recovery_service_extraction.py` 등은 정확한 차이만 허용하도록.
- 검사를 지우거나 느슨하게 하지 않는다. 위 밖 파일이 필요하면 STOP.

## 5. 시험 — 새 통합 시험 `tests/scripts/test_worldmap_strategy_p1.gd`, `[STRATEGY_P1] checks=N failures=[...]`, C-track 등록
실제 `WorldMap.tscn` 새 게임.
1. 사절 접수(T) → 금 30이 **즉시** 도시에서 빠짐(국가 합계 = 도시 합계), 우호도는 **아직 그대로**, 대장에 pending 1건.
2. 같은 대상에 두 번째 외교 접수 → 거절, 추가 차감 0.
3. 턴 종료 → T+1: 우호도 +5, 쿨다운 1, 대장 항목 resolved + `applied_transaction_id`, 금은 **다시 안 빠짐**.
4. 조공·관계 회복·교역 협정 각 1건: 현행 수치 그대로 반영(우호도·쿨다운·교역 협정 6턴).
5. 동맹: 점수 ≥ 70이면 T+1에 동맹 + `alliance_turns_remaining == 8`(첫 화면 8). 점수 69면 거절 + 비용 소모 + 쿨다운 4.
6. 기존 동맹 하나가 있는 상태에서 새 동맹 정산 → 기존 것은 1 줄고 새 것은 8(같은 턴).
7. 무효: 접수 뒤 대상 세력 소멸(또는 관계 항목 삭제)로 만들고 턴 종료 → invalid, 예약분이 뺀 도시로 **한 번** 돌아옴. 그 도시를 잃은 경우 수도로.
8. 중간 저장: 접수 → 저장 → 불러오기 → 턴 종료 → 결과 1회. / stage `domestic_resolution`에서 정산 직후 저장 → 불러오기 → `finish_enemy_turn` 재진입 → 중복 0(우호도·금·반환 모두).
9. 같은 턴 재상 자동무역이 예약된 금을 쓰지 못함(예약 뒤 금이 자동무역에 필요한 양보다 적게 남도록 준비).
10. AI 출처 사절 1건 → 같은 정산 경로로 T+1 반영(0-1의 6번; 안 되면 STOP 보고로 대체).
11. 침공 회귀: T에 정해진 적 침공 이벤트가 T+1 동맹 성립으로 취소되지 않음.
12. P0·P3 회귀: `[STOCK_AUTHORITY_P0]`·`[SPY_INTEL_P3]` 그대로 통과.

## 6. 보고·푸시
- 커밋: 코드 → (필요하면) 고정 다시 걸기, 마지막 커밋 `[skip ci]` 없음, 한 번에 푸시 → CI 확인 → 보고서 `agent/REPORT_STRATEGY_P1_20261127.md` 따로 `[skip ci]`.
- 보고서: 2절 확인 결과, 바꾼 자리 표, 0-2 상수 위치, 기존 시험 변경 표(기대 동작 변경은 "즉시→다음 턴"만), 시험 1~12, CI 실행 번호, 남은 문제, **최종 F6 체크리스트(HUD 연결 뒤)**.
- 막히면 STOP 보고 → 클코치 답신. 김작은 자고 있을 수 있으니 부르지 않는다.
