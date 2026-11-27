기준 화면: `WorldMap.tscn`(F6) — 적 도시 선택 → 정탐(정보 수집) → 적 도시 정보 창의 정탐 결과(재고 9품목·소속 장수·관측 턴), 그리고 P0 화면(국가 창고·도시 창고) 그대로.
합격 기준: 김작 F6(통합본)에서 ① 정탐 성공 시 적 도시의 **실제** `resource_stock`이 보이고(0은 0, 모르는 건 "?") ② 그 도시 소속 장수 명단(포로·사망·타국 제외, 0명이면 "0명")과 ③ 관측 턴이 보이며 ④ 정치 1 추정 정탐은 예전 그대로, ⑤ 저장→불러오기 뒤에도 정탐 기록이 같고 ⑥ P0 합격 기준(국가 창고 = 도시 합계 등)도 그대로. CI C-track 4 shard 초록.

# 큐 37 — 정탐이 실제 도시 재고와 소속 장수를 보여 준다 (GOAL-SPY-01 P3)

작성: 클코치 / 2026-11-27 16:25. 승인: 김작 11-27 "재기준 승인, 이 작업하는 동안 계속 허락, 승인 전부" + 채비서 24번에 적힌 김작 확인("수동 F6는 재고·정탐 통합본에서 한 번에, 작업 이어가줘").
`main` 푸시·병합, 가지 삭제, 강제 푸시는 이 지시서 범위가 아니다.

## 0. 시작점
- **기준 가지: `feature/wm3d-stock-p0-20261127` @ `2e3360f`**(큐 36 P0, CI 초록, F6 전). `main`이 아니다.
- 새 가지: `feature/wm3d-spy-intel-20261127`을 `2e3360f`에서 딴다. 큐 36 가지는 건드리지 않는다.
- 채코치(Codex) 패치: 이 orders 가지의 `agent/patches/EASTWAR_Spy_Intel_Snapshot_20261127.patch` (SHA256 `0564b334876f327d1d316beb1c92724cb379bff191167c393dcaf668098e279f`). `2e3360f`에 `git apply --check` 통과 확인함(클코치). 내용: `scripts/worldmap/actions/spy_intel_snapshot_service.gd`(`WorldMapSpyIntelSnapshotService.build_snapshot`), `tests/scripts/test_spy_intel_snapshot_service.gd`, `.uid` 2개. **패치 내용은 고치지 말고 그대로 적용**(첫 커밋). 고칠 게 있으면 아래 4절 범위에서 별도 커밋.

## 1. 지금 문제 [사실, `2e3360f`]
- `spy_action_service.gd` `_build_spy_info_payload` "resources"가 도시 **고정 씨앗값**(`city_data.resource_seed`)을 보여 준다. 실제 `resource_stock`이 아님 → 무역·생산·전투로 바뀐 재고가 정탐에 안 보인다.
- 소속 장수 항목이 없다.
- 관측 턴은 `city_intel[city].turn`에만 있고 payload에는 없다.

## 2. 바꿀 것
1. **재고(정확 정탐)**: `estimated == false`이고 "resources" 필드가 있으면, 대상 도시의 실제 `resource_stock`(P0의 `_get_city_storage` 어댑터, 9품목)을 `WorldMapSpyIntelSnapshotService.build_snapshot({precision:"exact", fields:["resources"], stock:…, city_id, observed_turn})`에 넣어 `payload.resources`(9키 딕셔너리)로. 값이 없거나 숫자가 아닌 품목은 `payload.unknown_fields`에 `resources.<id>`로 남는다. `resource_seed` 경로는 정확 정탐에서 쓰지 않는다.
2. **소속 장수**: 새 필드 `"heroes"`. 정치 적성 3·4·5 단계 목록 끝에 추가(1·2 단계는 그대로). 원천은 대상 도시 주둔 명단(`_get_stationed_hero_ids_for_city` / 배틀 문맥 어댑터) + 장수 항목. `build_snapshot`의 `heroes` 입력 행 = `{hero_id, display_name, status, faction_id(= 장수 side), role}`, `owner_faction_id` = 도시 소유 세력. 결과는 같은 세력·`normal`/`wounded`만, 포로·사망·타국 제외, 중복 제거. **0명이면 빈 배열**(=확인된 0명). 소유 세력이 비어 있으면 `unknown_fields`에 `heroes`.
   - 단계 배치(3·4·5에 장수)는 [제안]이다. 상수 한 곳에 두고 보고서에 적는다. 바꾸라는 말이 나오면 그 상수만 바꾼다.
3. **관측 턴**: payload에 `observed_turn`(= 결과 `turn`). `city_intel` 등록 항목도 그대로 `turn` 유지(기존 UI "· N턴").
4. **추정 정탐(정치 1)은 0줄 변경**: `troops_estimated`만, 재고·장수 없음. 회귀 시험으로 지킨다.
5. **표시**: 적 도시 정보 창(`worldmap_city_info_panel_base.gd` 정탐 힌트 영역)에 재고 9품목(0은 "0", 모름은 "?")과 장수 명단(이름·상태, 0명이면 "장수 0명"), 관측 턴. 새 창·새 버튼은 만들지 않는다. 기존 힌트 문자열 형식이 시험에 고정돼 있으면 그 시험만 기대 문자열 갱신(5절 표에 기록).
6. **치트 정보 공개**(`worldmap_debug_cheats_controller.gd` 256행 `INTEL_FIELDS`)도 같은 함수를 쓰므로 `heroes`를 목록에 더한다.
7. 저장: `city_intel`은 이미 `_player_state`로 저장된다. payload에 딕셔너리·배열이 들어가도 `normalize_city_intel_registry`가 깊은 복사로 유지하는지 확인하고, 깨지면 그 함수만 고친다.

## 3. 시험
- 채코치 단위 시험 `test_spy_intel_snapshot_service.gd`(`[SPY_INTEL_SNAPSHOT] checks=16 failures=[]`)를 C-track 목록에 등록.
- 새 통합 시험 `tests/scripts/test_worldmap_spy_intel_p3.gd`, 출력 `[SPY_INTEL_P3] checks=N failures=[...]`, C-track 등록. 실제 `WorldMap.tscn` 새 게임. 확인 항목:
  1. 적 도시 A `resource_stock` 쌀 40으로 두고 정치 5 정확 정탐 → `payload.resources.rice == 40`.
  2. 같은 도시 금 0 → `resources.gold == 0`이고 `unknown_fields`에 없음(확인된 0). 숫자가 아닌 값을 넣은 품목은 `unknown_fields`에 있음.
  3. 정탐 전에 그 도시 재고를 바꾸면(무역·직접 설정) 바뀐 값이 보임(씨앗값 아님).
  4. 장수: 같은 세력 normal·wounded 포함, 포로·사망·타국 장수 제외, 중복 0.
  5. 주둔 장수 0명 도시 → `heroes == []`, 화면 문자열에 "0명".
  6. `observed_turn` == 정탐한 턴, 다음 턴에도 기록 턴은 그대로.
  7. 정치 1 → `troops_estimated`만, `resources`·`heroes` 키 없음(회귀).
  8. 정치 2 → `troops`만(회귀). 정치 3 → `troops`·`resources`·`heroes`.
  9. 저장→불러오기 → `city_intel[A]` 깊은 비교 같음.
  10. 정탐 비용이 P0대로 도시에서 빠지고 국가 합계 = 도시 합계(P0 회귀 한 줄).
  11. 실패한 정탐은 `city_intel`을 바꾸지 않음.

## 4. 허용 파일
`spy_action_service.gd`, `spy_controller.gd`, `spy_presentation_helper.gd`, `worldmap_city_info_panel_base.gd`, `worldmap_debug_cheats_controller.gd`, 패치 파일 4개, 새 시험 1개(+`.uid`), `verify-c-track.yml`(시험 2줄), 이 작업 때문에 기대 문자열이 바뀌는 기존 정탐 시험(준비·문자열만, 5절 표), 검사기·`tools/p1_exact_delta.py`(고정 다시 걸기만).
- `worldmap_main.gd`는 **안 건드리는 게 원칙**. 어댑터가 꼭 필요하면 한 줄 전달 함수까지만 허용하고 P0와 같은 방식으로 고정 다시 걸기(`P3_SPY_MAIN_CHECKPOINT` + 정확한 차이, P0·P-1 확인 유지).
- 정탐·무역·외교 컨트롤러 검사기가 `spy_action_service.gd` 등을 바이트 고정하고 있으면 P0의 `frozen_text_matches` 방식으로 **이번 커밋의 정확한 차이만** 허용하게 고친다. 검사 자체를 지우거나 느슨하게 하지 않는다.
- 위 밖의 파일이 필요하면 멈추고 STOP 보고.

## 5. 보고·푸시
- 커밋: ① 패치 그대로 ② 코드 ③ (필요하면) 고정 다시 걸기 — 마지막 커밋은 `[skip ci]` 없이. 세 개를 한 번에 `feature/wm3d-spy-intel-20261127`에 푸시(승인됨) → CI 확인 → 보고서 `agent/REPORT_SPY_INTEL_P3_20261127.md`는 따로 `[skip ci]` 커밋.
- 보고서: 바꾼 자리 표, 장수 단계 상수, 기존 시험 변경 표("준비/문자열" vs "기대 동작" — 기대 동작 0), 시험 1~11 결과, CI 실행 번호, **통합 F6 체크리스트**(P0 9절 7개 + 이번 ①~⑤).
- 세이브: 작업 전 백업은 큐 36 것(`C:\eastwar_tmp\saves_backup_20261127\`)을 그대로 두고, F6용 세이브는 새 이름으로.

## 6. 추가 (16:31, 채비서 검토 `27_…큐37발행검토` 반영)
- 기준 SHA: `1d68293`(CI 초록) → `2e3360f` 차이는 `agent/PROGRESS_WM3D.md`·`agent/REPORT_STOCK_AUTHORITY_P0_20261127.md` 문서 2개뿐(클코치 확인, 실행 코드·검사기·CI 설정 0). 보고서에 이 한 줄과 **이번 가지 후보 SHA의 새 CI 실행 번호**를 같이 적는다.
- 시험 12 추가: 정탐 성공 직후 대상 도시의 재고와 주둔 장수를 바꾸고(예: 쌀 40→90, 장수 1명 이동), 턴을 넘기고, 저장→불러오기 → `city_intel[A]`의 재고·장수 명단·`observed_turn`이 **정탐 때 값 그대로**. 다시 정탐하면 그때만 새 값·새 턴으로 바뀐다. (기록은 그 시점 사진이지 현재 값 창이 아니다. 표시도 기록만 쓴다.)
- 장수 노출 단계 표: 보고서에 "정치 단계별 필드 전/후" 표를 넣어, 기존 정확/추정 경계가 안 바뀌었고 `heroes`만 3·4·5에 더해졌음을 보인다.
