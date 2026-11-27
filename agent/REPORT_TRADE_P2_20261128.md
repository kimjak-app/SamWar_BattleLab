# 큐 40 보고 — P2 수동 대외무역: 한 번 접수, T+1 정산 (+ P1 공통 반환 보류)

- 지시서: `agent/ORDER_TRADE_P2_MANUAL_EXTERNAL_20261128.md` (orders `60065d9`의 3-4 문구 수정 포함)
- 가지: `feature/wm3d-trade-p2-20261128`, 기준 `main` `7c27f3c`
- 커밋: 코드 `8101226` → 시험 보강 `d2d7d34`(마지막, `[skip ci]` 없음) → 이 보고서(`[skip ci]`). `worldmap_main.gd`·고정 파일 변경 0이라 재고정 커밋 없음.

## 1. 확인 결과
1. **호출 경로**: 상세 창 [수동 무역 실행] `_on_manual_trade_execution_button_pressed` → (맥락 행동이면 영상 뒤) `_execute_external_manual_trade_order` → `worldmap_action_coordinator.execute_trade_order`(145행) → `trade_controller.execute_order`. 맥락 메뉴 경로는 `coordinator.execute("trade")` → `trade_controller.execute(_, _, source)` → `execute_order(get_manual_trade_order(source))`. 저장된 수동 주문은 `_manual_trade_orders`(저장 키 `manual_trade_orders`) — **어디서도 자동 실행하지 않는다**(버튼만 읽음). 자동무역은 `apply_domestic_turn` 안에서 `run_chancellor_auto_trade`로 같은 도시 창고(`_get_city_storage`)를 읽는다 → 순서: 내정(자동무역 포함) → P1 외교 정산 → P2 무역 정산.
2. **상대 도시 창고**: `_get_city_storage`/`_set_city_storage`는 세력과 상관없이 같은 도시 `resource_stock` 단일 장부(P0) — 상대 세력 도시도 같다. STOP 사유 없음.
3. **물물교환**: 코드에 물물교환 경로·비율·AI 수락 기준이 없다(`trade_action_service` 행동은 `import`/`export`뿐, 그 밖의 행동은 `reason: "action"`으로 거절). → **넣지 않음**(채비서 42-5).
4. **자국 이송**(`internal_trade_transfer_service.gd`): 손대지 않음, 지금처럼 즉시.

## 2. 장부 선택과 이유
**P1 장부(`_player_state["strategy_pending_requests"]`)에 `domain: "trade"`로 넣었다.** 이유: 저장/불러오기에 이미 실리고, 요청마다 `applied_transaction_id` 중복 막기·`resolve_turn`·반환(`_refund`)을 그대로 같이 쓴다. 옆 장부를 만들면 이 셋을 다시 만들어야 한다.
- `resolve_turn(host, turn, transaction_id, domain = "diplomacy")`: 한 번에 한 영역만 정산(영역 없는 옛 요청 = 외교). 외교 컨트롤러 호출은 그대로라 외교만, 무역 컨트롤러의 새 `resolve_trade_requests`가 `"trade"`만. `last_strategy_request_results`는 같은 정산 ID면 두 영역 결과를 이어 붙인다.
- 정산 순서: `worldmap_turn_controller._resolve_strategy_requests`(정산 자리 하나)에서 외교 → 무역 순으로 부르고 결과를 합친다. `finish_enemy_turn`의 호출 줄은 그대로.
- 무역에는 세력 쌍당 대기 1건 한도를 적용하지 않았다(지시서 7-3 "병행 한도 임의 신설 금지"). 같은 주문 재클릭은 **접수 때 저장 주문(초안)을 소비**해서 막는다 — 다시 누르면 주문이 없어 `missing_order`, 재예약 0.

## 3. 넣은 것
| 단계 | 내용 |
|---|---|
| 접수 | `trade_controller.execute_order` → `StrategyRequestService.submit_player_trade(main, trade, order)`. 기존 `validate_order` 그대로(수입 총액은 따로 검사). 품목마다 현행 식으로 확정: 수입 `ceil(price*amount/eff)`, 수출 `floor(price*amount*eff)`. 내 쪽 지급분(`pay` = 수입 금 + 수출 품목)만 출발 도시에서 **한 번** 빼서 `reserved_assets`. 상대 지급분(`receive` = 수입 품목 + 수출 금)과 품목별 행동·수량·시세·효율·시장 턴·접수 당시 양쪽 세력을 `fixed_context`에 저장. 결과 `submitted: true, completed: false`, "수동 무역을 접수했습니다. 결과는 다음 턴에 나옵니다." + 정산 뒤 출발 도시 순변화 `preview` |
| 정산 | 접수 순서(요청 id)대로 건마다 최신 상태로 다시 검사: 출발 도시 소유 = 접수 세력(`source_changed`), 상대가 빈 성 아님(`unclaimed_city`), 상대 도시 소유 = 접수 세력(`target_changed`), 멸망 아님, **지금 관계에서 교역 가능**(`relation`, 외교 정산 뒤 상태), 상대 도시 `resource_stock`에 상대 지급분 전부(`partner_shortage`). 전부 되면 한 번에 예약분 → 상대 도시, 상대 지급분 → 내 도시. **재계산 없음** |
| 실패 | 부분 성사 없이 예약 전액 1회 반환(P1 `_refund`: 원래 도시가 아직 요청 세력 것이면 거기, 아니면 그 세력의 첫 납부 도시 = 수도) |
| 반환 보류(P1 공통) | 돌려줄 도시가 둘 다 없으면 건너뛰지 않고 요청에 `unrefunded`(원래 도시별 양), 상태 `held`, 결과 메시지 "돌려받을 도시가 없어 예약한 비용을 보류했습니다.", 로그 `[STRATEGY_REFUND_HELD] request=… source=… unrefunded=…`. 점령자·상대·국가 장부로 가는 길 없음. 보류분 지급 방법은 범위 밖 |
| 자동무역 | 규칙·순서 그대로. 예약분은 접수 때 이미 창고에서 빠져 있어 쓸 수 없다. 우회 경로 없음(자동무역은 `get_city_storage`만 읽음) |
| 옛 세이브 | 저장된 수동 주문은 초안으로만 복원(지금과 같음), 자동 접수·실행 0 |
| 국가 창고 | 별도 쓰기 없음(도시 합계, P0) |
| 옛 즉시 경로 | `execute_order_immediately`로 남김(버튼은 더 이상 안 감). 검사기가 요구하는 `_action_service.execute_order(self, order, …)` 호출문이 여기 있다 |
- 바뀐 파일: `strategy_request_service.gd`, `trade_controller.gd`, `worldmap_turn_controller.gd`, 시험 3개 + 새 시험, `verify-c-track.yml`. `trade_action_service.gd`(가격 식)·`trade_automation_service.gd`·`worldmap_main.gd`·`diplomacy_controller.gd`는 0줄.

## 4. 기존 시험 변경 표 (즉시 실행 → 접수 + 정산)
| 파일 | 전 | 후 |
|---|---|---|
| `test_worldmap_trade_controller_extraction.gd` | 실행 결과 `applied` == 미리보기, 실행 직후 출발 도시 = 전 + 미리보기 | 상대 도시에 재고를 넣고, 결과 `preview` == 미리보기, `submitted`·미완료 확인(+1), 접수 직후 내 지급분만 빠짐(+1), `resolve_trade_requests` 뒤 출발 도시 = 전 + 미리보기 |
| `test_worldmap_trade_routing.gd` | `applied`로 금·식량·소금 변화, 실행 직후 출발 도시 = 전 + `applied`; 영상 흐름 `_last_result.applied` == 저장 미리보기 | 상대 도시 재고를 넣고 `preview`로 같은 확인, 정산 뒤 출발 도시 = 전 + `preview`, 상대 도시가 정확히 반대로 변함(+3); 영상 흐름 `_last_result.preview` == 저장 미리보기 |
| `test_worldmap_stock_authority_p0.gd` | 수동 수출 금 `applied.gold`, 실행 직후 국가 합계 +금 | 상대 도시 금 1000, `preview.gold`, 정산 뒤 국가 합계 +금 |
"대상 창고 변화 없음"(라우팅) 확인은 접수 시점에 그대로 성립해 유지했다. 확인을 뺀 것 0.

## 5. 새 시험 `tests/scripts/test_worldmap_trade_p2.gd`
`[TRADE_P2] checks=60 failures=[]` (C-track 등록, CITIES65 시험 뒤)
1. 구매·판매(쌀 10 수출 + 소금 4 수입): 접수 때 쌀 10 + 수입 금만 한 번 빠짐, 미완료, 상대 그대로 → 그 턴 시세를 0.80↔1.20 반대 끝으로 옮김(새 견적이 실제로 달라짐 확인) → 정산: 출발 도시 변화 = 접수 미리보기, 상대 = 정확히 반대, 결과 1번, 같은/새 정산 ID로 다시 해도 0 ✔
2. 물물교환: 기존 경로 없음 — `barter` 행동은 `action`으로 거절 ✔
3. 상대 소금 정확히 6 → 6 수입 성립 / 7 → 부분 0, 예약 1회 반환, 다시 정산해도 재반환 0 / 같은 상대 소금 6을 4·4 두 주문 → 첫째 성립, 둘째 무효·반환(상대 6 → 2) ✔
4. 외교 순서: 접수 뒤 교역 불가(적대)로 바뀜 → `relation` 무효·반환, 그 턴 내정 결과 불변. **협정 만료만으로는 무효 아님**(orders `60065d9`): 만료 + 여전히 교역 가능 → 정상 성사, 만료 + 기존 규칙상 막힘(`suspended`) → 무효·반환 1회. 실제 턴 끝(`request_end_turn` → `finish_enemy_turn`)에서 무역 요청이 정산되고 턴 결과 `strategy_request_results`에 실림 ✔
5. 소유권: 출발 도시(한성)를 잃음 → `source_changed`, 예약 전액이 플레이어 수도(사비)로 1회, 점령자·상대 0 / 상대 도시가 제3세력 → `target_changed`, 빈 성 → `unclaimed_city`, 둘 다 출발 도시로 반환 ✔
6. 쌀 10을 전부 수출 예약 → 자동무역 실행 뒤에도 예약 10 그대로, 정산 때 상대 +10. 자국 이송은 즉시 ✔
7. 재클릭(저장 주문 소비 → 재예약 0), 접수 뒤 저장/불러오기(같은 재고·대기 1건), 정산 뒤 저장/불러오기 + 다시 정산(재지급 0), T+1 불러오기(변화 0), 옛 세이브의 저장 주문 → 턴을 넘겨도 새 요청 0·초안 유지·실행 결과 불변 ✔
8. 반환 보류: 플레이어 도시가 하나도 없게 바꿈 → 무역 요청 `held`, `unrefunded` = {한성: 지급분}, 어떤 도시에도 안 들어감. P1 외교(사절) 요청도 같은 경로로 `held`·`unrefunded` = 예약분 ✔
9. 회귀: P0 86 · P3 · P1 49 · CITIES65 322 모두 아래 전체 실행에서 통과.

## 6. CI
- `Verify C-track refactor` 실행 `46053956161` (head `d2d7d34`): **초록**, 4개 묶음(shard 0~3) 모두 success, 재실행 없음. 끝난 시각 2026-11-27 19:23 UTC.
- `Verify WorldMap3D`: **이번 푸시에는 돌지 않았다.** 그 작업의 경로 조건(`worldmap3d/**`, `scripts/worldmap/map3d/**`, `WorldMap3D_*.tscn`, `tests/scripts/test_worldmap3d_*.gd`, `scripts/worldmap_city_marker.gd`, `WorldMap.tscn`, 자기 yml)에 걸리는 파일을 바꾸지 않았기 때문. 수동 실행(`workflow_dispatch`)은 CI 쓰기 권한이라 하지 않았다. 대신 같은 시험 8개를 로컬에서 돌려 모두 통과(7절). 클코치가 합격 조건상 WorldMap3D 초록이 꼭 필요하면 수동 실행이 필요하다.

## 7. 로컬 전체
- 작업 트리 `8101226`(코드): C-track 시험 215개(CI 목록 그대로, 4개 병렬) **215 실행, 215 종료 코드 0**. 검증 스크립트 72개 **72 통과**.
- `d2d7d34`(시험 보강): `test_worldmap_trade_p2` 다시 `checks=60 failures=[]`(코드 변경 없음).
- WorldMap3D 시험 8개 모두 통과(adapter 56 · camera_controller 61 · camera_external_input 20 · color_parity 57 · host 58 · mem_probe 37 · production 28 · roads 172).

## 8. 남은 문제
- 보류(`held`)된 반환분을 나중에 어떻게 돌려줄지(도시를 되찾으면 지급 등)는 정하지 않았다 — 자리만 있음(`unrefunded`).
- 무역 결과는 상태 줄·턴 요약·`last_strategy_request_results`·`last_external_manual_trade_execution_result`(접수 결과)에만 나온다. 성사/무효 결과 창은 HUD 연결 때.
- 상세 창 버튼 글자는 아직 "수동 무역 실행"(UI 파일은 이번 범위 밖) — HUD 연결 때 "수동 무역 접수"로.
- 대기 중인 무역 요청의 취소 기능은 없다(`cancelled` 상태 이름만).
- 큐 39 보고서 `agent/REPORT_CITIES65_PREVIEW_20261127.md`는 `feature/wm3d-cities65-preview-20261127` `c6ad926`(`[skip ci]`)에 있다(`main` 합류는 `7c27f3c`까지라 빠짐).
