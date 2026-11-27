기준 화면: `WorldMap.tscn`(F6, 3D 월드맵) — 국가 창고 창, 도시 상세 창(창고), 무역(수동·재상 자동·내부 이송), 도시·국가 연구 시작. (지시서 `agent/ORDER_STOCK_AUTHORITY_P0_20261127.md`와 같음)
합격 기준: 이번에는 **코드 변경 0으로 멈춘다.** 조사표(지시서 4절 1단계)와 멈춘 이유, 답신에서 고를 선택지만 올린다.

# REPORT_STOCK_AUTHORITY_P0_STOP — 외교 비용은 도시가 아니라 국가 합계를 직접 깎는다 (클코드, 2026-11-27, 큐 36번)

- **됐나**: 안 됐다. 코드 커밋 0. 이 보고서와 진행 기록만 올렸다(`[skip ci]`).
- **가지**: `feature/wm3d-stock-p0-20261127` = `origin/main` `8cc0640b741447151eebb7ed98d3193136a5ad59` + 문서 커밋. `main` 푸시 없음.
- **세이브 백업(지시서 1절 4)**: 끝냈다. `%APPDATA%\Godot\app_userdata\SamWar_BattleLab\` 통째 → `C:\eastwar_tmp\saves_backup_20261127\`(파일 204개, 20,045,200바이트). 원본 삭제 없음.
- **막힌 것 (큐 4절 3·4번)**:
  1. [사실 불일치] 지시서 0절은 외교 비용(`diplomacy_action_service`)을 `resource_stock`(도시) 쪽 사용처로 적었다. 실제로는 `scripts/worldmap/actions/diplomacy_action_service.gd` 666~712행이 **국가 합계 `_player_state["resource_stock"]`를 읽고(668행) 직접 깎아 쓴다(705행)**. 도시 장부는 건드리지 않는다. 그래서 외교 비용은 다음 국가 합계 재계산(`_rebuild_occupation_runtime_indexes_mvp`, `sync_player_resource_compatibility`)에서 **되살아난다**(5절 시험 5번과 같은 종류의 버그).
  2. [범위 밖 파일] 이걸 도시에서 빼게 바꾸려면 서비스가 부르는 호스트가 `scripts/worldmap/actions/diplomacy_controller.gd`(서비스는 `host`=컨트롤러만 안다)라서, 컨트롤러에 국가 비용 전달 함수 1개를 더해야 한다. 이 파일은 허용 목록(0절 + `city_resource_service.gd`)에 없다.
  3. [목록에 없는 시험] 국가 단위 비용(`_can_pay_generic_resource_cost`/`_apply_generic_resource_cost`, 외교 비용)을 도시 합계 기준으로 바꾸면, **국가 `resource_stock`을 직접 심고 시작하는 시험 9개**의 준비 단계가 더는 효과가 없다(국가 값은 도시 합계로 다시 계산되므로). 지시서 4절 목록에 없는 파일들이다(아래 3-4).
- **추천**: 선택 A(5절). 클코치 답신을 기다린다.

## 1. 조사표 — `storage` 읽기·쓰기 전부 (`main 8cc0640`, 코드 읽기만)
### 1-1. `worldmap_main.gd`
| 줄 | 함수 | 읽기/쓰기 | 지금 하는 일 | 바꿀 방식(답신 뒤) |
|---|---|---|---|---|
| 1616~1618 | `_query_domestic_tech_research_service` `"city_storage"` | 읽기 | 연구 서비스에 도시 창고 전달 | `_get_city_storage` 경유 → `resource_stock` |
| 1632~1634 | `_mutate_domestic_tech_research_service` `"set_city_storage"` | 쓰기 | 도시 연구 비용 차감 결과 저장 | `_set_city_storage` 경유 → `resource_stock` |
| 2819 | 도시 상세 모델 `"storage_summary"` | 읽기 | 도시 상세 창 창고 칸 | 같음(읽는 장부만 `resource_stock`) |
| 3666·3671 | `_populate_internal_trade_transfer_panel` | 읽기 | 내부 이송 창 "보유 N" | 같음 |
| 3759~3766 | `_set_city_storage` | 쓰기 | `city["storage"]` = 키 9개 정리 | `city["resource_stock"]`에 쓰고 국가 합계 다시 계산 |
| 12867~12870 | `_get_mutable_city_runtime_state` | 쓰기 | 도시 상태를 꺼낼 때마다 `storage`가 없으면 **기본값(한성=국가 합계 복사, 나머지 0)으로 만들어 넣음** | 이 4줄 삭제 |
| 12933~12934 | `_serialize_worldmap_city_runtime_state` | 쓰기(세이브) | 세이브에 `storage` 기록 | 삭제(세이브에 `storage` 키 없음 = 시험 10) |
| 13057~13060 | `_apply_worldmap_city_runtime_state` | 쓰기(불러오기) | 세이브 `storage` 복원, 없으면 기본값 | 버리고 로그 `[STOCK_MIGRATION] city=… dropped_storage={…}`, 최상위 `stock_ledger: "resource_stock_v1"` 있으면 다시 처리 안 함 |
| 13352~13363 | `_get_city_storage` | 읽기+쓰기 | `storage` 읽고(없으면 기본값) 런타임에 다시 써 둠 | `resource_stock`(공급 기본값 보장 뒤)을 키 9개로 돌려줌, 쓰기 없음 |
| 13370~13372 | `_build_default_city_storage` | 읽기 | 한성만 국가 합계 복사 | 삭제 |
| 558~560, 754, 1494, 2825~2923, 13375~13389 | 상수·카드 노드·요약 문구 | 표시 | 창고 칸 UI(장부 아님) | 그대로 |
| 8199~8408 | `storage_flat`·`storage_cap_pct` | 테크 효과 값 | 장부 아님(효과 이름) | 그대로 |

### 1-2. 서비스·컨트롤러 (모두 허용 목록 안)
| 파일:줄 | 읽기/쓰기 | 경로 | 바꿀 방식 |
|---|---|---|---|
| `actions/internal_trade_transfer_service.gd:22·39·40·48·49` | 읽기·쓰기 | `adapter.get_city_storage`/`set_city_storage` → `trade_controller` → main `_get_city_storage`/`_set_city_storage` | 서비스 0줄(접근 함수가 `resource_stock`을 다룸) |
| `actions/trade_action_service.gd:13·24~32·72~97` | 읽기·쓰기 | 같음(`context.source_storage`) | 같음 |
| `actions/trade_automation_service.gd:129~252` | 읽기·쓰기 | 같음 | 같음 |
| `actions/trade_controller.gd:281·364~374` | 전달 | main `_get_city_storage`/`_set_city_storage` | 0줄 |
| `domestic_tech/domestic_tech_research_service.gd:283·587` | 쓰기·읽기 | `set_city_storage`/`city_storage`(도시 연구 비용) | 0줄(main 접근 함수 경유) |
| `economy_city/city_detail_presentation_controller.gd:147~209` | 표시 | 받은 사전을 문자열로 | 0줄 |
| `domestic_tech/domestic_tech_effect_provider.gd` | — | `storage_flat`(효과 이름)·`_format_city_storage_summary`(함수 이름 목록)만 | 0줄 |
| `ui/worldmap_debug_cheats_controller.gd:5·92~98` | 읽기·쓰기 | `resource_stock`(96행)과 `storage`(98행)를 **둘 다** 채움 | `storage` 줄 삭제, 주석 정리 |
| `economy_city/economy_city_helpers.gd:86~90` | — | 받은 사전에서 숫자만 | 0줄 |
| `economy_city/city_resource_service.gd:18~56` | — | `get_city_storage`가 `city_data["storage"]`를 읽고 없으면 `build_default_city_storage`(한성 복사) | `resource_stock`을 읽게, `build_default_city_storage` 삭제, 옛 `storage` 버리기 도우미 1개 추가 |

택한 해석(답신 뒤 구현 때): 함수 이름 `_get_city_storage`/`_set_city_storage`/`get_city_storage`·질의 이름 `city_storage`는 **어댑터 이름으로 남기고 내용만 `resource_stock`으로** 바꾼다. 무역 3종·연구·표시 서비스와 그 시험을 덜 건드리고(코드를 덜 바꾸는 쪽), `tools/validate_worldmap_main_integrity.py:31`(`"city storage": "func _get_city_storage"`)도 그대로 맞는다. 도시 상태 사전의 `storage` 키는 완전히 없어진다.

## 2. 조사표 — 국가 합계를 직접 읽거나 쓰는 곳 전부
| 파일:줄 | 읽기/쓰기 | 지금 | 바꿀 방식(답신 뒤) |
|---|---|---|---|
| `worldmap_main.gd:1463~1464` `set_player_resource_compatibility` | 쓰기(파생) | `sync_player_resource_compatibility` 결과를 `_player_state.resource_stock`에만 넣음, **`national_aggregation.resources`는 안 고침** | 둘 다 같은 도시 합계로 |
| `worldmap_main.gd:7191~7212` `_rebuild_occupation_runtime_indexes_mvp` | 쓰기(파생) | 소속 도시 `resource_stock` 합계 → `national_aggregation.resources`와 `_player_state.resource_stock` | 합계 계산을 도우미 하나로(값 동일) |
| `worldmap_main.gd:7837~7839` `_get_total_recruitment_food_stock` | 읽기 | 국가 `resource_stock` 식량 3종 합 | 도시 합계 |
| `worldmap_main.gd:7889~7902` `_can_pay_generic_resource_cost` | 읽기 | 국가 `resource_stock` | 도시 합계 |
| `worldmap_main.gd:7905~7933` `_apply_generic_resource_cost` | **쓰기** | 국가 `resource_stock`에서 직접 뺌(식량은 쌀→보리→수산물) | `plan_national_city_stock_payment`(수도 먼저, 나머지 이름순, `food`는 쌀→보리→수산물) + 커밋 + 합계 재계산. 돌려주는 모양 `{before, after, cost, paid}` 유지 |
| ↳ 부르는 곳 | | `spy_action_service.gd:601·754·911·1215·1275`(정탐 5종, `spy_controller.gd:191` 경유), `worldmap_main.gd:7941` `_apply_recruitment_cost` | 부르는 쪽 0줄 |
| `worldmap_main.gd:12281~12282`, `12296~12297` | 읽기 | 국가 식량·금 > 0 | 도시 합계 |
| `worldmap_main.gd:13345~13349` `_get_player_national_resource_stock_mvp` | 읽기 | `national_aggregation.resources` 먼저, 없으면 `_player_state.resource_stock` (국가 창고 창·요약이 이것만 씀) | 소속 도시 합계를 그 자리에서 계산 |
| `domestic_tech_research_service.gd:227` `has_national_food_group_scope` | 읽기 | `player_value resource_stock` | 도시 합계 질의 |
| `domestic_tech_research_service.gd:286` (국가 연구 비용) | **쓰기** | `set_player_value resource_stock` | 새 변경 `charge_national_city_stock`(main이 `plan_national_city_stock_payment`로 도시에서 뺌) |
| `domestic_tech_research_service.gd:590` | 읽기 | `player_value resource_stock` | 도시 합계 질의 |
| **`actions/diplomacy_action_service.gd:666~678` `can_pay_diplomacy_resource_cost`** | 읽기 | 국가 `resource_stock`(식량만 호스트 `_get_total_recruitment_food_stock`) | **멈춤 — 5절** |
| **`actions/diplomacy_action_service.gd:681~712` `apply_diplomacy_resource_cost`** | **쓰기** | 국가 `resource_stock`에서 직접 빼고 `host.set("_player_state")` | **멈춤 — 5절** |
| ↳ 부르는 곳 | | 같은 파일 62(`execute`)·279(동맹)·654(옛 교역 협정) | |

[추정] 증상 원인: 위 1463~1464행이 `national_aggregation.resources`를 안 고치므로, 생산·무역 뒤 국가 창고 창(`_get_player_national_resource_stock_mvp`)이 옛 값을 보인다. 무역·도시 연구는 `storage`(한성만 국가 복사, 나머지 0)를 쓰므로 생산 수입(`resource_stock`)과 따로 논다. 치트 ① 뒤 0/9999는 [미확인] — 5절 시험 9로 확인 예정.

## 3. 조사표 — 시험·검사기
### 3-1. `storage` 키를 직접 보는 시험(지시서 목록, 답신 뒤 `resource_stock` 기준으로)
| 시험 | 줄 | 바꿀 것 |
|---|---|---|
| `test_worldmap_city_resource_service_extraction.gd` | 22~25(`build_default_city_storage`·한성 복사) | 지워지는 함수 → "`get_city_storage`는 `resource_stock`을 읽고 `storage`는 무시" 확인으로 |
| `test_worldmap_debug_cheats.gd` | 6·101~105·112~113·120~125·140~141·254 | `city["storage"]` 확인 → `resource_stock` 확인(이미 같은 줄에서 확인 중)·"`storage` 키 없음" |
| `test_worldmap_domestic_tech_research_service_extraction.gd` | 54~74·120~121·133·146~147 | 가짜 호스트의 도시 사전 키 `storage` → `resource_stock`, 국가 질의·변경 이름 추가. 기대값(140·70·15) 그대로 |
| `test_worldmap_internal_trade_transfer_extraction.gd`, `test_worldmap_trade_automation_extraction.gd`, `test_worldmap_trade_controller_extraction.gd`, `test_worldmap_trade_routing.gd` | `_get_city_storage`/`_set_city_storage` 호출만 | 0줄 예상(접근 함수 이름 유지) |
| `test_worldmap_city_detail_presentation_extraction.gd`, `test_worldmap_domestic_tech_effect_provider_extraction.gd`, `test_worldmap_diplomacy_controller_extraction.gd`, `test_unit3d_face_travel.gd` | 문구·카드 이름·주석에 단어만 | 0줄 |
| `tools/validate_worldmap_main_integrity.py:31` | `func _get_city_storage` 존재 | 0줄(이름 유지) |

### 3-2. 세이브 경로
저장 `_serialize_worldmap_state`(12729~12749, 최상위 키 `version`… → `stock_ledger` 추가), 도시 저장 12931~12934, 불러오기 `_apply_worldmap_state`(12752~12788, 끝에서 `_rebuild_occupation_runtime_indexes_mvp`가 국가 합계를 도시에서 다시 만듦 → 국가 값 이중 반영 없음), 도시 불러오기 13051~13060.

### 3-3. 바이트 고정
`tools/p1_exact_delta.py` 부르는 곳 3개(지시서 3절과 같음). 답신 뒤 3절 순서대로.

### 3-4. **지시서 목록에 없는데 영향받는 시험 9개** (국가 `resource_stock`을 직접 심고 시작)
| 시험 | 줄 | 왜 깨지나 |
|---|---|---|
| `test_worldmap_diplomacy_alliance_extraction.gd` | 29, 145~155 | 국가 금을 심고 `apply_diplomacy_resource_cost` 차감을 국가 값으로 확인 |
| `test_worldmap_diplomacy_controller_extraction.gd` | 79, 130 | 가짜 호스트 `_player_state.resource_stock` |
| `test_worldmap_diplomacy_mutation_extraction.gd` | 30, 50~58 | `_apply_generic_resource_cost`와 `apply_diplomacy_resource_cost`의 **결과·상태 일치** 확인 — 한쪽만 도시로 바꾸면 반드시 깨짐 |
| `test_worldmap_diplomacy_routing.gd` | 31 | 국가 금으로 외교 가능 여부 |
| `test_worldmap_diplomacy_state_extraction.gd` | 29 | 같음 |
| `test_worldmap_diplomacy_validation_extraction.gd` | 30 | 같음 |
| `test_worldmap_spy_controller_extraction.gd` | 27 | 국가 금으로 정탐 비용(main `_apply_generic_resource_cost`) |
| `test_worldmap_spy_routing.gd` | 38 | 같음 |
| `test_worldmap_military_controller_extraction.gd` | 44 | 국가 금·쌀로 모병 비용 |

검사기: `tools/validate_worldmap_diplomacy_service_separation.py:77`은 서비스 `execute` 본문에 `_apply_generic_resource_cost` 글자가 있으면 실패. `apply_diplomacy_resource_cost`는 다른 함수라 선택 A는 걸리지 않는다(새 이름을 쓰면 더 안전).

## 4. 지금까지 한 것
- `git fetch`, 큐·36번 지시서 다시 읽음, 새 가지 생성(`main 8cc0640`), 세이브 백업.
- 코드·시험·검사기 수정 0. Godot 실행 0.

## 5. 답신에서 고를 것
- **A(추천)**: 허용 범위를 넓힌다.
  1. `scripts/worldmap/actions/diplomacy_controller.gd`에 전달 함수 2개(각 1줄, 기존 `_get_total_recruitment_food_stock` 전달과 같은 모양): 국가 비용 확인·차감 → main의 `_can_pay_generic_resource_cost`/`_apply_generic_resource_cost`(도시에서 빼는 새 방식).
  2. `diplomacy_action_service.gd`의 `can_pay_…`/`apply_diplomacy_resource_cost`는 호스트에 그 함수가 있으면 위임한다(없으면 지금 코드 — 가짜 호스트 시험용). 돌려주는 모양 `{before, after, cost, paid}` 유지.
  3. 3-4의 시험 9개는 **준비 단계만** 바꾼다: 국가 `resource_stock`에 심던 값을 수도(또는 시험이 쓰는 소속 도시) `resource_stock`에 심고 합계 재계산. 기대값(수치·순서·문구)은 그대로. 바뀐 줄을 표로 보고.
- **B**: 외교 비용은 이번 범위에서 뺀다(국가 직접 차감 유지). 외교 비용이 다음 합계 재계산에서 되살아나는 버그가 남고, `test_worldmap_diplomacy_mutation_extraction.gd`의 일치 확인은 여전히 깨지므로 그 시험 처리 방법도 정해 줘야 한다. 비추천.
- 정탐·모병(main `_apply_generic_resource_cost`)은 이미 허용 범위(`worldmap_main.gd` 국가 직접 쓰기 줄)지만, 그 시험 3개(3-4 아래 3줄) 준비 단계 변경 허용도 답신에 같이 적어 주면 두 번 멈추지 않는다.

## 6. 다음
- 대기: 10분마다 `git fetch origin feature/wm3d-orders-20261105`로 답신(`agent/ORDER_STOCK_AUTHORITY_P0_REPLY_1_*.md`)과 큐를 확인한다(김작 11-27 지시: 10분 간격). 답신이 오면 1~3절 표대로 구현 → 시험 → 고정 다시 걸기 → 푸시.
