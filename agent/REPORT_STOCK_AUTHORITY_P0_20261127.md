기준 화면: `WorldMap.tscn`(F6, 3D 월드맵) — 국가 창고 창, 도시 상세 창(창고), 무역(수동·재상 자동·내부 이송), 도시·국가 연구 시작, 외교·정탐·모병 비용.
합격 기준: 김작 F6에서 ① 국가 창고 = 소속 도시 재고 합계 ② 무역·이송 뒤에도 국가 합계가 맞음 ③ 생산으로 모은 자원으로 도시 연구 시작 ④ 치트 Ctrl+Shift+G 뒤 국가 창고가 채운 값 + 외교·정탐·모병 비용이 도시에서 빠지고 턴이 지나도 되살아나지 않음. 그리고 C-track 4 shard + WorldMap3D 초록.

# REPORT_STOCK_AUTHORITY_P0 — 도시 재고 장부를 `resource_stock` 하나로 (큐 36번, 답신 1 A안) (클코드, 2026-11-27)

- **됐나**: 됐다. 코드·시험·고정 다시 걸기를 끝냈다. 로컬 C-track 210개 전부 exit 0, 정적 검사기 72개 전부 통과, 새 시험 `[STOCK_AUTHORITY_P0] checks=86 failures=[]`. CI `Verify C-track refactor` `45952527223` 4 shard 모두 success. `Verify WorldMap3D`는 경로 조건에 걸리지 않아 실행 안 됨(7절).
- **가지**: `feature/wm3d-stock-p0-20261127`. 시작 `main` `8cc0640b741447151eebb7ed98d3193136a5ad59` → STOP 보고 `dd962cb` → 코드 `e206d60678196550a4763906456bbc0ce11a67a4` → 고정 `1d68293`(마지막 커밋, 코드 커밋). `main` 푸시 없음, 삭제·강제 푸시 없음.
- **세이브 백업**: `C:\eastwar_tmp\saves_backup_20261127\`(작업 시작 전, 파일 204개, 20,045,200바이트).
- **남은 것**: 김작 F6(9절). 합격하면 `main` 합류는 별도 합류 지시서.
- **택한 해석**: 접근 함수 이름(`_get_city_storage`/`_set_city_storage`/`get_city_storage`/질의 `city_storage`)은 어댑터 이름으로 남기고 내용만 `resource_stock`(답신 1 승인). 도시 상태 사전의 `storage` 키는 없어졌다.

## 1. 조사표
STOP 보고서 `agent/REPORT_STOCK_AUTHORITY_P0_STOP_20261127.md`(`dd962cb`) 1~3절 그대로. 구현하면서 더 찾은 것:
- `_get_national_payment_city_ids_mvp`(국가 비용을 낼 도시 목록)는 `_city_runtime_states`에 있는 도시만 봤다. 국가 합계(`CITY_HUD_DATA` 전체 + 소유자 검사)와 대상이 같도록 같은 도우미를 쓰게 바꿨다.
- `sync_player_resource_compatibility`는 `owned_city_ids` 기준 도시를 더했다. 시험이 세력을 바꾸면(외교 라우팅 `silla`) 실제 소유 도시 합계와 어긋났다. → 국가 캐시 두 개 모두 **그 자리의 실제 소유 도시 합계**를 넣게 했다(1464행 문제 같이 해결).
- 국가 테크 32종의 실제 비용은 **전부 금 하나**(`build_actual_charge_plan` 확인). 그래서 "여러 품목 중 하나 부족"인 국가 테크는 존재하지 않는다 → 시험 12의 국가 테크 건은 "금 1 부족, 식량 충분"으로 했다.

## 2. 바꾼 자리
| 파일 | 자리 | 바꾼 것 |
|---|---|---|
| `worldmap_main.gd` | `_mutate_city_resource_service` `set_player_resource_compatibility` | `_player_state.resource_stock`과 `national_aggregation.resources` 둘 다 실제 소유 도시 합계로 |
| 〃 | 연구 질의 `national_resource_stock`, 변경 `charge_national_city_stock`(새 항목) | 국가 연구 비용을 도시에서 뺀다 |
| 〃 | `_set_city_storage` | `city["resource_stock"]`에 쓰고 국가 캐시 갱신 |
| 〃 | `_get_total_recruitment_food_stock`, `_can_pay_generic_resource_cost`, 식량·금 보유 확인 2곳 | 실제 소유 도시 합계를 읽음 |
| 〃 | `_apply_generic_resource_cost` | 3-1절 |
| 〃 | `_get_national_payment_city_ids_mvp` | 국가 합계와 같은 도시 목록(수도 먼저) |
| 〃 | `_get_player_national_resource_stock_mvp` + 새 도우미 2개(`_get_player_city_ids_for_national_stock_mvp`, `_sum_city_resource_stocks_mvp`) | 매번 소유 도시 합계 계산(재집계와 같은 소유자 검사) |
| 〃 | `_get_city_storage` | 공급 기본값 보장 뒤 `resource_stock`(9품목)을 돌려줌. 런타임에 쓰기 없음 |
| 〃 | `_get_mutable_city_runtime_state`, `_normalize_city_storage`·`_build_default_city_storage`(삭제) | `storage` 기본값(한성 = 국가 합계 복사) 제거 |
| 〃 | 세이브 저장/불러오기, 상수 `STOCK_LEDGER_VERSION` | 3-3절 |
| `city_resource_service.gd` | `get_city_storage(city_data)`, `build_default_city_storage` 삭제 | `resource_stock`만 읽음 |
| `domestic_tech_research_service.gd` | 227·590행 질의, 국가 차감 | 국가 합계 질의 / 도시에서 차감(`charge_national_city_stock`) |
| `diplomacy_action_service.gd` | `can_pay_…`/`apply_diplomacy_resource_cost` 앞에 위임 3줄씩 | 3-2절 |
| `diplomacy_controller.gd` | 전달 함수 2개 | 3-2절 |
| `worldmap_debug_cheats_controller.gd` | ① 채우기 | `storage` 쓰기 삭제(`resource_stock`만) |
| `.github/workflows/verify-c-track.yml` | C-track 목록 끝 | 새 시험 1줄 |
| 검사기 3개 + `tools/p1_exact_delta.py` | 4절 | |

`_rebuild_occupation_runtime_indexes_mvp`는 **한 줄도 안 바꿨다**(보호 함수 검사기 3개가 지킨다).

### 3-1. 국가 비용 처리 방식
| 자리 | 전 | 후 | 고른 방식과 이유 |
|---|---|---|---|
| `_apply_generic_resource_cost`(정탐 5종·모병·외교 위임) | 국가 합계에서 바로 뺌, 모자라면 있는 만큼(부분) | `plan_national_city_stock_payment`로 계획 → 커밋 → 재집계. **하나라도 모자라면 아무것도 안 뺌**(지불 0) | 여러 품목을 한 번에 원자적으로 계획하는 `plan_national_…`. 수도 먼저, 나머지 도시 id 순, `food` = 쌀→보리→수산물(옛 순서와 같음). 부르는 쪽은 모두 먼저 확인하므로 정상 흐름은 같다 |
| 국가 연구 비용(`domestic_tech_research_service`) | `set_player_value resource_stock` | 서비스가 뺄 양을 계산 → main `charge_national_city_stock` → `plan_national_…` 커밋 | 같음 |
| 외교 비용 | 서비스가 국가 합계 직접 | 컨트롤러 → main 위 함수 | 같음(답신 1) |

### 3-2. 외교 위임이 바꾼 것(답신 1 4절) — diff 근거
`git diff 8cc0640 e206d60 -- scripts/worldmap/actions/diplomacy_*` 전체가 아래 3곳이다.
- `diplomacy_action_service.gd:666` `can_pay_diplomacy_resource_cost`: 맨 앞에 "호스트에 `_can_pay_national_city_stock_cost`가 있으면 그 결과를 돌려준다" 3줄. **비용 확인만.**
- `diplomacy_action_service.gd:681` `apply_diplomacy_resource_cost`: 맨 앞에 "호스트에 `_pay_national_city_stock_cost`가 있으면 그 결과" 2줄. **비용 차감·합계 갱신만.** 반환 모양 `{before, after, cost, paid}` 같음.
- `diplomacy_controller.gd:553` 뒤: 전달 함수 2개(main `_can_pay_generic_resource_cost` / `_apply_generic_resource_cost`).
- 외교 점수·수락/거절 확률·쿨다운·동맹 기간·교역 협정을 다루는 함수(`execute`, `apply_diplomacy_relation_delta`, `apply_alliance_action`, `propose_trade_agreement`, `calculate_alliance_acceptance_chance`, `advance_*`)는 **0줄 변경**. 외교 시험 6개의 결과·상태 일치 확인(예: `DIPLOMACY_ROUTING` 172개, `DIPLOMACY_MUTATION_2B` 67개)이 기대값 그대로 통과.

### 3-3. 세이브
- 저장: 최상위 `"stock_ledger": "resource_stock_v1"` 추가, 도시 `storage` 저장 삭제.
- 불러오기: 표시가 없는(옛) 세이브의 도시에 `storage`가 있으면 버리고 도시마다 한 줄 `[STOCK_MIGRATION] city=… dropped_storage={…}`. 표시가 있으면 처리하지 않는다. `resource_stock`만 이어받고 국가 합계는 끝의 재집계가 도시에서 다시 만든다(이중 반영 없음).
- 새 시험 로그 원문: `[STOCK_MIGRATION] city=hanseong dropped_storage={ "gold": 7777, "rice": 9, "silk": 55 }`, `[STOCK_MIGRATION] city=pyeongyang dropped_storage={ "gold": 500, "rice": 500 }`. 다시 저장·불러오기에서는 0줄.

## 4. 고정 다시 걸기 (`tools/p1_exact_delta.py`)
- ① 코드 커밋 `e206d60`(`worldmap_main.gd` 포함) → ② 고정 커밋 `1d68293`(`p1_exact_delta.py`만, `P0_STOCK_CHECKPOINT = "e206d60…"`).
- `EXPECTED_P0_STOCK_MAIN_DELTA` = `line_delta(9b2cd8e, e206d60)` **132줄**. `assert_main_is_approved_p1_state`: 현재 파일 == `e206d60`, P0 차이 == 132줄 목록, 옛 P-1 차이(`EXPECTED_P1_MAIN_DELTA`)도 계속 확인. `main 8cc0640`의 `worldmap_main.gd` == `9b2cd8e`(blob 같음, 확인함).
- 같은 방식으로 **다른 검사기가 바이트 동결한 파일 6개**도 정확한 차이로 고정(`EXPECTED_P0_STOCK_FROZEN_DELTAS`, `frozen_text_matches`): `diplomacy_action_service.gd` 5줄, 외교 시험 5개(routing 26 / validation 13 / mutation 19 / state 21 / alliance 25줄). 기준은 `8cc0640`의 내용(= 각 검사기 기준 내용, 8cc0640에서 그 검사기들이 통과했으므로).

| 검사기 | 줄 | 고친 것 | 이유 |
|---|---|---|---|
| `validate_worldmap_trade_controller_extraction.py` | 79 | 동결 비교 → `frozen_text_matches` | `diplomacy_action_service.gd` 승인 변경(답신 1) |
| `validate_worldmap_spy_controller_extraction.py` | 109 | 같음 | 같음 |
| `validate_worldmap_diplomacy_controller_extraction.py` | 152 | 컨트롤러 추가 함수 목록에 `_can_pay_national_city_stock_cost`, `_pay_national_city_stock_cost` | 답신 1 전달 함수 2개 |
| 〃 | 168 | 허용 main 호출에 `_can_pay_generic_resource_cost`, `_apply_generic_resource_cost` | 같음 |
| 〃 | 191, 208 | 외교 시험 5개·서비스 동결 비교 → `frozen_text_matches` | 시험 준비 단계(답신 1-3)·서비스 위임 |
- `validate_worldmap_trade_routing.py`, `validate_worldmap_spy_routing.py`는 위 두 검사기를 불러서 같이 통과. `validate_worldmap_trade_phase2_extraction.py`는 커밋 전 작업 트리(`git diff HEAD`)만 보므로 수정 0(커밋 뒤 통과).

## 5. 바뀐 시험
### 5-1. 시험 9개(답신 1-3) — 칸을 나눔
| 시험 | 준비 단계(재고 심기) 변경 | 기대 동작 변경 |
|---|---|---|
| `test_worldmap_diplomacy_alliance_extraction` | `_player_state` 설정 7곳 → `_set_state`(그 상태의 `resource_stock`을 수도에 심고 다른 소유 도시는 비움) | 0 |
| `test_worldmap_diplomacy_controller_extraction` | 가짜 호스트에 도시 재고 `_city_stock["own"]` + 국가 비용 함수 2개(`_player_state`를 넣으면 그 재고를 도시에 심음), 130행 국가 재고 비우기 → 도시 재고 비우기 | 0 |
| `test_worldmap_diplomacy_mutation_extraction` | `_set_state` 4곳 | 0 (일치 확인 유지) |
| `test_worldmap_diplomacy_routing` | `_set_state` 2곳, 134행 국가 금 0 → `_set_national_gold(0)` | 0 |
| `test_worldmap_diplomacy_state_extraction` | `_set_state` 5곳 | 0 |
| `test_worldmap_diplomacy_validation_extraction` | `_set_state` 1곳 | 0 |
| `test_worldmap_spy_controller_extraction` | `_set_state`를 도시 상태 교체 뒤로 옮김, 103행 → `_set_national_gold(0)` | 0 |
| `test_worldmap_spy_routing` | 같음, 84·187행 → `_set_national_gold(…)` | 0 |
| `test_worldmap_military_controller_extraction` | 44행 국가 재고 → 수도 `resource_stock`(다른 소유 도시 비움) | 0 |
- 근거: 9개 파일의 diff에서 `_expect(` 줄 변경 **0줄**(`git diff -U0 8cc0640 e206d60` 집계). 결과: 9개 모두 PASS(alliance 52·controller 131·mutation 67·routing 172·state 50·validation 54·spy controller 49·spy routing 71·military 17).

### 5-2. `storage`를 직접 보던 시험
| 시험 | 전 기대값 | 후 기대값 | 이유 |
|---|---|---|---|
| `test_worldmap_city_resource_service_extraction` 22~25 | `build_default_city_storage("sabi")` 금 0 / 한성은 국가 금 99 복사 | `get_city_storage({})` 9품목 0 / `resource_stock` 금 99 읽고 `storage` 무시 | 지워진 함수(한성 복사 폐지) |
| `test_worldmap_debug_cheats` 6·99~141·254 | `city["storage"]`도 용량 값 / 적 `storage` 불변 | `resource_stock` = 용량 값이고 `storage` 키 없음 / 적 도시도 `storage` 키 없음 | 장부 하나 |
| `test_worldmap_domestic_tech_research_service_extraction` | 가짜 도시 키 `storage` | 가짜 도시 키 `resource_stock`, 가짜 국가 질의·차감 추가. 수치(140·70·15) 그대로 | 장부 이름 |
| 무역 4개·도시 상세·효과 제공자 | — | 0줄 | 접근 함수 이름 유지 |

### 5-3. 새 시험 `tests/scripts/test_worldmap_stock_authority_p0.gd`(+`.uid`, C-track 등록)
실제 `WorldMap.tscn` 새 게임(한성) + 이웃 평양을 아군으로. `[STOCK_AUTHORITY_P0] checks=86 failures=[]`.
1 쌀 40+60=100 / 2 이송 10 → 30·70, 국가 100 / 3 재상 자동무역·수동 수출 뒤 국가 = 도시 합계, 수출 금이 국가 합계에 보임 / 4 생산 수입으로 도시 연구 시작, 비용이 한성 `resource_stock`에서 빠짐 / 5 국가 연구 비용이 수도에서 빠지고 재집계 뒤에도 유지 / 6 저장→불러오기 같음 / 7 옛 세이브 `storage` 버림·다시 저장 그대로 / 8 소유권 바뀌면 합계 대상 바뀜 / 9 치트 뒤 국가 = 용량 × 소유 도시 수, 창고 표시 줄도 / 10 세이브에 `storage` 키 없음 / 11 `resource_stock` 0 + `storage`만 → 0 / 12 외교 동맹(비단 0)·정탐 이간질(비단 0)·모병(식량 0)·국가 테크(금 1 부족) 거절: **도시 재고·국가 합계(캐시 포함)·결과 메시지(시도 전 확인 함수의 메시지와 같음) 세 가지 모두 그대로** / 13 모병·외교 사신·정탐 정보 수집 비용이 도시 합계에서 정확히 빠지고 재집계 뒤 유지. 모든 단계에서 국가 캐시 두 개 = 실제 합계도 확인.

## 6. 검증
- 로컬(Godot 4.6.2, `--headless -s`): C-track Godot 시험 목록 **210개**를 4개씩 병렬 → **210/210 exit 0**. 정적 검사기 72개 → **실패 0**. 가져오기(`--editor --import`) 뒤 작업 트리에 새 `.uid` 1개 외 변화 없음.
- **213 / 210 차이(정정)**: 진행 중에 "213개"라고 말한 것은 `verify-c-track.yml` 안의 `.gd` 경로를 **모두** 센 수였다. 그중 3개는 시험 목록이 아니라 CI가 shard 0의 "Project parse and WorldMap/Battle Main load" 단계에서 `cat > … <<'GDSCRIPT'`로 그 자리에서 만들고 돌린 뒤 지우는 장면 불러오기 스크립트다: `tests/_ci_worldmap_scene_load.gd`, `tests/_ci_battle_main_scene_load.gd`, `tests/_ci_imjin_iso_scene_load.gd`. 저장소에 파일이 없어서 로컬 시험 실행기로는 돌리지 않았다(빠뜨린 시험이 아님). 이 3개가 하는 일(`WorldMap.tscn`·`Battle_Main.tscn`·임진 장면 불러오기)은 CI shard 0에서 확인된다(아래 실행 번호). 그래서 실제 C-track Godot 시험은 210개(기존 209 + 새 시험 1)다.
- CI: 7절.

## 7. CI
- 푸시: `feature/wm3d-stock-p0-20261127` `dd962cb..1d68293`(코드 `e206d60` + 고정 `1d68293` 한 번에, 김작 승인). 원격 = 로컬 HEAD `1d6829355675e822b474912dfeb8e9e7f376ab49`. 마지막 커밋에 `[skip ci]` 없음.
- `Verify C-track refactor` 실행 `45952527223`(head `1d68293`): **success** — shard 0·1·2·3 모두 success(shard 0의 정적 검사기 72개, 장면 불러오기 3개, 육전 컷인 길이 검사 포함). https://github.com/kimjak-app/SamWar_BattleLab/actions/runs/45952527223
- `Verify WorldMap3D`: **실행되지 않음**. 이 작업 흐름은 `worldmap3d/**`, `scripts/worldmap/map3d/**`, `WorldMap3D_*.tscn`, `tests/scripts/test_worldmap3d_*.gd`, `scripts/worldmap_city_marker.gd`, `WorldMap.tscn`, 자기 yml이 바뀔 때만 돈다(`paths` 조건). 이번 두 커밋은 그 경로를 하나도 건드리지 않았다. 손으로 돌리는 `workflow_dispatch`는 `gh` 쓰기 명령이라 큐 6절에 따라 하지 않았다. 필요하면 김작/클코치가 Actions 화면에서 실행하거나 지시로 허락해 주면 된다.

## 8. 답신 1 4절 항목(채비서 검토)
1. **외교 위임 범위**: 3-2절 — 바뀐 것은 비용 확인·차감·합계 갱신뿐(서비스 2곳 위임 5줄 + 컨트롤러 전달 함수 2개). 외교 점수·수락/거절·쿨다운·동맹 기간 함수는 diff 0줄.
2. **시험 9개 표 칸 나눔**: 5-1절 — "준비 단계(재고 심기) 변경" / "기대 동작 변경". 기대 동작 변경 칸 **9개 모두 0**(`_expect(` 줄 변경 0줄).
3. **시험 12(부분 부족 거절)**: 5-3절 12번 — 외교·정탐·모병·국가 테크 각 1건에서 ① 도시 재고(소유 도시 전부) ② 국가 합계(실제 합계와 `_player_state.resource_stock` 캐시 둘 다) ③ 결과 메시지(시도 전 확인 함수가 낸 메시지 = 시도 결과 메시지)가 모두 시도 전과 같음을 확인. 국가 테크는 카탈로그 32종이 모두 금 하나만 비용이라 "금 1 부족"으로 확인(1절).

## 9. F6 체크리스트(김작)
1. 새 게임 → 좌측 국가 창고 = 한성 도시 상세 창고 값과 같음.
2. 도시 하나 더 가진 상태에서 내부 이송 → 두 도시 값이 바뀌고 국가 창고 합계는 그대로.
3. 수동 무역(수출) → 그 도시 금이 늘고 국가 창고 금도 같은 만큼.
4. 턴 몇 번 넘겨 생산 → 도시 연구 시작 가능, 그 도시 창고에서 비용이 빠짐.
5. 외교 사신·정탐·모병 → 국가 창고와 수도 창고에서 비용이 빠지고, 턴을 넘겨도 되살아나지 않음.
6. Ctrl+Shift+G → 국가 창고가 "0 / 9999"가 아니라 채운 값 합계.
7. 저장 → 불러오기 → 값 그대로. 옛 세이브를 불러오면 출력 창에 `[STOCK_MIGRATION]` 줄(있던 도시만).
