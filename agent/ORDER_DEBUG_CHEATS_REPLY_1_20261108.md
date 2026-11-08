기준 화면: 가지 `feature/wm3d-debugcheats-20261108`(끝 `dc63ec8`, 코드는 `main` `a9e3b84`와 같음)에서 이어서, F6로 `WorldMap.tscn`을 열고(디버그 빌드) 키 3개로 치트 ①②③이 동작한다. **`worldmap_main.gd` 변경 0줄.**
합격 기준: 원 지시서 6절 자동 기준 전부(아래 정정 반영) + `worldmap_main.gd`·`tools/p1_exact_delta.py` 변경 0 + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(원 지시서 7절).

# 답신 1 — 큐 30번 STOP에 대한 클코치 결정 (2026-11-08)

## 0. 먼저: 지시서 오류 인정 [사실]
원 지시서 1절은 "`validate_worldmap_main_integrity.py`는 하한만 본다"고만 적었고, `validate_worldmap_diplomacy_routing.py` → `tools/p1_exact_delta.py`가 `worldmap_main.gd`를 `9b2cd8e`와 **바이트 단위로 고정**한다는 사실을 빠뜨렸다. 클코치가 `tools/`에서 `worldmap_main.gd`를 grep할 때 이 간접 경로(`p1_exact_delta` 모듈)를 놓쳤다. 클코드의 멈춤은 정당하다(큐 4절 3·4번). 원 지시서 0절 2항("main 연결 몇 줄")과 9절의 해당 문구는 **폐기**한다.

## 1. 결정: A안
- `worldmap_main.gd` **0줄**. `tools/p1_exact_delta.py` 수정 **금지**(B안 기각: 고정 기준을 옮기는 건 검증 구조 변경이라 이번 범위 밖).
- 컨트롤러 `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd`를 `WorldMap.tscn` 루트의 **자식 `Node` 1개**로 붙인다. 이름 `WorldMapDebugCheatsController`. 선례: `WorldMapCityInteriorController`(CH-2b), `WorldMapTechBadgeSummaryController`, `WorldMapTerritoryController`(같은 형식으로, 클코드가 그 노드 블록을 보고 `unique_id`·`ext_resource` 형식을 맞춘다).
- 컨트롤러는 `_ready`에서 `OS.is_debug_build()`가 false면 **즉시 `queue_free()`**(출시 빌드에서 아무 입력도 받지 않음). main 접근은 `get_parent()`(= main 스크립트) 또는 `get_node("..")`의 기존 공개/밑줄 메서드 `call`로만. 새 시그널·그룹·autoload 금지.
- **허용 파일 정정**: 원 지시서 허용 목록의 2번(`worldmap_main.gd`)을 **`WorldMap.tscn`(노드 1개 추가만)** 으로 바꾼다. 나머지(새 컨트롤러, `spy_presentation_helper.gd`의 `get_city_intel_entry` 분기, 새 테스트, `verify-c-track.yml` 1줄)는 그대로.

## 2. `WorldMap.tscn`을 읽는 검증기 전부 실행 (필수)
`tools/`에서 `WorldMap.tscn`을 참조하는 `validate_p1b*`(p1b1·p1b2·p1b3·p1b4·16x9_functional_parity)와 `validate_battle3d_*` 전부, 그리고 `test_worldmap3d_host.gd`·`test_worldmap3d_production.gd`·`test_worldmap_city_interior_window.gd`·`test_worldmap_left_panel_grip.gd`를 노드 추가 **전후로** 돌려 결과 줄 원문을 보고서에. 깨지는 게 하나라도 있으면 그 검사 파일을 고치지 말고 다시 멈춘다(허용 오차 조정·재실행 금지). 노드 수·`unique_id` 중복 검사 같은 것이 있으면 어느 검사인지 적는다.

## 3. 치트 ③ `_adapter` 질문 — 인정
`service.set("_adapter", spy_controller)` 한 줄을 **컨트롤러(디버그 경로) 안에서만**, **`_adapter`가 비어 있을 때만** 하는 것을 인정한다. 스파이 파일 수정이 아니고, 정상 첩보 흐름이 같은 값을 넣기 때문이다. 세팅 전후로 정상 첩보(`gather_info`) 경로가 변하지 않는 테스트 1개를 추가한다(`_adapter` 기존값이 있으면 덮어쓰지 않음 포함).

## 4. 원 지시서 정정 (그 외 변경 없음)
- 6절 테스트 5번 "컨트롤러 미생성 경로" → "비디버그 시뮬레이션에서 `_ready`가 `queue_free()`를 부르고, 이후 입력 무동작".
- 자동 합격의 "`worldmap_main.gd` 변경이 연결 몇 줄뿐(diff 원문)" → "`git diff a9e3b84 -- scripts/worldmap/worldmap_main.gd tools/p1_exact_delta.py`가 **비어 있음**(원문 첨부)".
- 8절 보고서에 `WorldMap.tscn` diff 원문(노드 블록)과 2절 결과를 추가.
- 2절 [미확인] 2번(테크트리 열림 중 키 수신)은 테스트로 확인하고 결과를 적는다. 안 들어오면 치트 ②는 `_input`을 쓰되 그 근거를 적는다.

## 5. 진행
STOP 보고서(`dc63ec8`)가 올라간 이 가지에서 이어서 코드 커밋 → CI → 보고서 순서. 큐 5·10절 상시 규칙 그대로. 다른 멈춤 조건이 생기면 이번처럼 STOP 보고서로 멈춘다.
