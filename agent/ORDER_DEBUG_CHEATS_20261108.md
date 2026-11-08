기준 화면: 새 가지 `feature/wm3d-debugcheats-20261108`(시작: `origin/main` `a9e3b84229f63286bbdc784d78826b0e2cdb792d`)에서 F6로 `WorldMap.tscn`을 열고(디버그 빌드), 키 3개로 ① 금·자원 전부 채움 ② 선택한 테크 즉시 완료 ③ 첩보 없이 적 성 정보 전부 표시가 된다. 출시(비디버그) 빌드에서는 키가 아무 일도 하지 않는다.
합격 기준: 6절 자동 기준 전부 + 세이브 형식 변화 0 + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(7절 체크리스트).

# 지시서 — DEBUG-CHEATS: 개발용 치트 3개 (큐 30번)

- 작성: 클코치, 2026-11-08. 김작 결정 [사실]: 11-07 "디버그 치트 먼저" 요청, 11-08 18:00 "자원을 9999로 채우면 부족해서 못 만드는 일은 없다" 방향 승인, "시작하자".
- 목적: CH-4 F6 2번(테크 완료 시 건물 켜짐)과 앞으로의 월드맵 시험이 자원 부족·첩보 절차에 막히지 않게 한다. **게임 규칙·밸런스·세이브 형식은 바꾸지 않는다.**

## 0. 규칙
큐 10절·상시 규칙. 맨 위 두 줄 유지. **허용 파일**(이 밖은 멈춤):
1. 새 파일 `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd` (기존 폴더, **새 폴더 금지**)
2. `scripts/worldmap/worldmap_main.gd` — **생성 연결 몇 줄만**(8줄 이내 목표). 기존 로직 수정 0. `_ensure_*` 패턴으로 컨트롤러를 만들어 자식 노드로 붙이고, 만드는 조건은 `OS.is_debug_build()`.
3. `scripts/worldmap/actions/spy_presentation_helper.gd` — `get_city_intel_entry` 한 함수에 디버그 분기 + 플래그 변수 1개. 다른 함수·`Button.new`/`Label.new` 추가 금지(`validate_worldmap_spy_controller_extraction.py` 보호).
4. 새 테스트 `tests/scripts/test_worldmap_debug_cheats.gd` + `.github/workflows/verify-c-track.yml`의 테스트 목록 **끝**에 1줄.
- **건드리지 않는다**: `domestic_tech_*.gd`, `spy_controller.gd`, `spy_action_service.gd`, 세이브·로드 코드, 규칙·비용·확률 값. 막히면 `agent/REPORT_DEBUG_CHEATS_STOP_20261108.md`로 멈춘다(이 항목만).

## 1. 클코치가 미리 확인한 것 [사실, `origin/main` `a9e3b84` 읽기]
- **재고는 세 곳**이고 서로 동기화 코드가 없다: ⓐ 도시 `resource_stock`(시드 `build_supply_resource_defaults`; 나라 합계의 원본) ⓑ 도시 `storage`(연구 서비스·교역·도시창 '금전'이 읽음) ⓒ `_player_state["resource_stock"]`(나라 합계, `_rebuild_occupation_runtime_indexes_mvp`(7191줄 근처)가 ⓐ의 합으로 **매번 덮어씀**). 따라서 ⓒ만 올리면 곧 원래대로 돌아간다. **ⓐ와 ⓑ를 둘 다 채우고 재집계**해야 한다. 기존 쓰기 수단: `_set_city_storage`(3759줄), 도시 `resource_stock` 변경자 `set_city_resource_amount`(약 2015줄), 소유 도시 목록 `_get_national_payment_city_ids_mvp`(7845줄 근처).
- 창고 용량 `WAREHOUSE_CAPACITY`(main 561줄): 쌀·보리 1000, 수산물 500, 목재 800, 철 500, 말 300, 비단 300, 소금 400, **금 9999**. HUD 상태 라벨용이며 값을 깎는 코드는 못 찾았다(`economy_city`·교역만 확인, 턴 처리 쪽은 [미확인]).
- 연구비: 도시 테크는 도시 `storage`, 나라 테크는 `resource_stock`에서 `domestic_tech_research_service.gd`의 `validate_actual_charge`(235줄 근처)가 판정. 문구 `부족: 금 N`은 `_format_domestic_tech_actual_charge_shortage_mvp`(트리 프레젠테이션 684줄). 옛 `_start_city_tech`(main 10382줄)는 scripts 안 호출처 0건(tests는 [미확인]).
- 테크 완료 표시: `complete_national_research(active)` / `complete_city_research(city_id, active)` — `active`에는 `tech_id`만 있으면 된다(`remaining_turns`는 없어도 됨). **단, 둘 다 해당 범위의 '진행 중 연구' 슬롯을 비운다**(다른 연구가 진행 중이면 지워짐). 연구 중 슬롯을 건드리지 않는 단순 표시는 `mark_completed_from_normalize(scope, city_id, tech_id)`, 도시 미러 동기화는 `sync_city_completed_mirror(city_id)`. 완료 연출 큐 `_enqueue_domestic_tech_completion_presentations_mvp`, 표면 갱신 `_refresh_domestic_tech_effect_display_surfaces_mvp`. 선택된 테크는 트리 프레젠테이션 컨트롤러의 `_selected_domestic_tech_id_mvp`·`_selected_domestic_tech_city_id_mvp`.
- 첩보: 적 정보는 `_player_state["city_intel"][city_id] = {turn, fields, estimated, payload}`. UI 소비처는 모두 `spy_presentation_helper.gd`의 `get_city_intel_entry(city_id)`(50줄) 한 곳을 거친다(`format_visibility_summary`·`format_known_info_summary`, main의 baseline 함수 4개 3942·3990·4057·4144줄). 실제 값 생성기는 `spy_controller._service`(`SpyActionService`)의 `_build_spy_info_payload(city_id, fields, estimated)`(363줄), 호출처는 `_gather_spy_info` 1곳. `city_intel`은 `_player_state`에 있어 **세이브에 들어간다**.
- 검증기: `validate_worldmap_main_integrity.py`는 줄 수·함수 수 **하한**만 본다. 스파이 추출 검증기는 프레젠터에 지정 함수들이 있고 `Button.new`/`Label.new`가 없는지만 본다.
- `scripts/` 안에 `is_debug_build` 사용처는 현재 0건(CH-4 가지에만 `OS.is_debug_build()` 키 패턴이 있음).

## 2. 시작 전 확인 (어긋나면 멈춤)
`origin/main` = `a9e3b84`. 1절의 줄 번호는 근처 값이니 함수명으로 찾는다. 그리고 [미확인] 4건을 확인해 보고서에 적는다: ① 쓸 키 3개가 기존 입력(`shared_ui_controller.handle_input`, 카메라 컨트롤러)과 겹치지 않는지 `grep`(권장 후보: Ctrl+Shift+G / T / I) ② 새 컨트롤러가 자식 노드의 `_unhandled_key_input`으로 받을 때 테크트리 오버레이가 열린 상태에서도 키가 들어오는지 ③ 테크 카탈로그에서 전체 목록을 얻는 공개 수단 ④ 턴 진행 중 도시 재고가 용량으로 깎이는지.

## 3. 치트 ① 금·자원 채우기 (Ctrl+Shift+G)
- 내 소유 도시마다 자원별로 `WAREHOUSE_CAPACITY` 값(금 9999 등)을 **ⓐ 도시 `resource_stock`과 ⓑ 도시 `storage` 둘 다**에 넣고, 재집계(`_rebuild_occupation_runtime_indexes_mvp`)와 화면 갱신(좌측 국고·도시창)을 한다. 값을 용량에서 자르거나 도시 수로 나누지 않는다(나라 합계가 용량을 넘어 보여도 그대로 두고 보고서에 관찰만 적는다).
- 새 저장 키·플래그를 만들지 않는다. 한 번 누르면 채움(토글 아님). 누를 때 상태 줄 메시지 1개(`_set_save_management_status` 등 기존 수단).

## 4. 치트 ② 선택한 테크 즉시 완료 (Ctrl+Shift+T)
- 테크트리 오버레이가 열려 있고 테크가 선택돼 있을 때: 그 테크를 **비용·선행조건·진행 중 연구와 무관하게** 완료 처리한다. 범위(나라/도시)는 테크 정의를 따르고, 도시 테크는 선택된 도시 기준. **자원을 차감하지 않는다.** 다른 연구가 진행 중이면 그대로 둔다(1절의 슬롯 비우기 주의 — `mark_completed_from_normalize` 계열을 우선 검토, 다른 수단이면 근거를 보고서에).
- 완료 후 화면 갱신(트리 오버레이, 효과 표면, 배지 요약)은 정상 완료와 같은 경로를 쓴다. 완료 연출 카드는 띄워도 되고 생략해도 된다(보고서에 택한 쪽 기록).
- 이미 완료된 테크·선택 없음·오버레이 닫힘이면 아무 일 없이 상태 줄에 이유만.
- (선택, 쉬우면) Ctrl+Shift+Alt+T = 현재 범위의 모든 테크 완료. 어려우면 하지 않고 보고서에 "미구현" 한 줄.

## 5. 치트 ③ 첩보 없이 적 성 정보 보기 (Ctrl+Shift+I, 토글)
- 방식은 **읽을 때 합성**(세이브를 건드리지 않는다). `spy_presentation_helper.gd`에 플래그(기본 false)를 두고, true이고 대상이 내 도시가 아니면 `get_city_intel_entry`가 모든 필드(`troops`·`resources`·`publicSupport`·`loyalty`·`governor`·`tech`)를 가진 entry를 돌려준다. payload는 `_build_spy_info_payload`로 만든 **실제 값**(추정치 `troops_estimated` 아님).
- 합성 entry를 `_player_state["city_intel"]`에 **쓰지 않는다**(세이브 오염 금지). 켜고 끌 때 선택된 도시 패널을 다시 그린다. 끄면 원래 첩보 상태(없음/부분)로 복귀.
- `_build_spy_info_payload`는 밑줄 함수라 외부 호출이 어색하다. 호출 경로(예: `_ensure_spy_controller()._service.call(...)`)가 막히면 **스파이 파일을 고치지 말고** 멈춤 보고(대안은 김작 결정).

## 6. 공통 안전 + 테스트
- 컨트롤러는 `OS.is_debug_build()`가 false면 **생성되지 않는다**. 테스트에서 검증할 수 있게 "활성 여부"를 주입 가능한 함수로 분리(비디버그 시뮬레이션 시 3개 치트 모두 무동작).
- 세이브 형식 변화 0: 치트 실행 전후 `_player_state` 키 집합 비교 테스트(치트로 새 키가 생기면 실패).
- 새 `tests/scripts/test_worldmap_debug_cheats.gd`(키 입력 대신 컨트롤러 메서드 직접 호출):
  1. ①: 소유 도시 전부의 ⓐ·ⓑ·재집계 후 ⓒ가 용량 값. 이후 `validate_start`가 금 부족 사유(`insufficient_cost`)를 내지 않음(도시 테크·나라 테크 각 1개).
  2. ①을 적 도시에 쓰지 않음(소유 도시만).
  3. ②: 선택 테크 완료됨, 자원 변화 0, 진행 중 연구 슬롯 보존, 이미 완료·선택 없음 → 무변화. 도시 테크는 다른 도시에 안 퍼짐.
  4. ③: 플래그 on → 적 도시 entry가 6필드 + 실제 값, `city_intel` 불변; off → 원래 값으로 복귀; 내 도시는 영향 없음.
  5. 비활성(비디버그) 시뮬레이션 → ①②③ 모두 무동작, 컨트롤러 미생성 경로.
  6. 키 충돌: 선택한 3개 키가 기존 입력과 안 겹침(2절 ① 결과를 상수로 고정).
- 기존 검사 전부 변화 없이 통과 — 특히 `validate_worldmap_main_integrity.py`, 스파이 추출 검증기, `test_worldmap_spy_controller_extraction.gd`, `test_worldmap3d_host.gd`, `test_worldmap3d_production.gd`, `test_worldmap_city_interior_window.gd`, `test_worldmap_left_panel_grip.gd`. 하나라도 깨지면 허용 오차 조정·재실행 금지, 멈춤.
- 자동 합격: 위 전부 + 변경 파일이 허용 목록 안 + `worldmap_main.gd` 변경이 연결 몇 줄뿐(diff 원문을 보고서에) + C-track 4 shard·`Verify WorldMap3D` 초록(알려진 `[CUTIN]` 흔들림은 큐 4절 규칙대로 근거 기록, 재실행 금지).

## 7. 김작 F6 체크리스트 (보고서 맨 아래에 그대로 옮길 것)
1. 새 게임 시작 → Ctrl+Shift+G → 좌측 국고 금이 9999 근처로, 한성 도시창 '금전'도 9999.
2. 테크트리에서 도시 테크 하나 선택 → "연구 시작" 가능(자원 부족 안 뜸) → 시작해도 정상 진행.
3. 다른 테크를 선택하고 Ctrl+Shift+T → 즉시 완료 표시, 선행 안 채워도 됨. (CH-4 가지가 합쳐진 빌드라면 성 안 건물 점등까지 — 이 가지에는 CH-4가 없으므로 이 항목은 CH-4 쪽에서 확인.)
4. 적 도시 선택 → 정보 "미확인/잠김" → Ctrl+Shift+I → 병력·자원·민심·충성도·태수·기술 전부 값으로 표시 → 다시 Ctrl+Shift+I → 원래대로.
5. 저장 후 불러오기 → 치트로 채운 자원은 그대로(정상 데이터), ③의 합성 정보는 사라짐.
- 출시 빌드 비활성은 자동 테스트(6절 5번)로 갈음. 별도 export 확인은 하지 않는다.

## 8. 보고서
`agent/REPORT_DEBUG_CHEATS_20261108.md`: 맨 위 두 줄 + 3줄 요약 + 2절 [미확인] 4건 결과 + 시작 `main` 해시 + 변경 요약 + `worldmap_main.gd` diff 원문 + 6절 결과 줄 원문 + 택한 키·근거 + 관찰(나라 합계가 용량 초과로 보이는지, 턴 후 재고 변화) + F6 체크리스트 + 종료 루틴 5줄(OPERATING_RULES §4: ① 정본 git status·현재 가지 ② 새로 생긴 폴더·worktree·가지·태그와 삭제 예정 ③ 푸시된 것/로컬만 ④ CI ⑤ 김작이 결정할 것). 보고서·증거는 새 가지에 `[skip ci]`, UTF-8. 끝낼 때 정본 작업 폴더를 이 가지로 체크아웃해 둔다.

## 9. 하지 않는 것
`main` 푸시·병합, 새 폴더, 스파이·연구 서비스 수정, 비용·확률·밸런스 변경, 세이브 키 추가, 치트 사용 기록을 세이브에 남기기, 허용 오차·재실행.

## 큐 행 (이전 행 29번 바로 뒤에 삽입)
| 30 | `agent/ORDER_DEBUG_CHEATS_20261108.md` | 준비됨 — **새 가지** `feature/wm3d-debugcheats-20261108`(시작 `main` `a9e3b84`). 디버그 빌드 전용 치트 3개(자원 9999 채움 / 선택 테크 즉시 완료 / 첩보 없이 적 성 정보). `main` 수정은 생성 연결 몇 줄만, 푸시는 이 가지에만. 27번(CH-4)과 독립 |
