기준 화면: `WorldMap.tscn`(F6) — 적 도시 선택 → 정탐(정보 수집) → 적 도시 정보 창의 정탐 결과(재고 9품목·소속 장수·관측 턴), 그리고 P0 화면(국가 창고·도시 창고) 그대로.
합격 기준: 김작 F6(통합본) ①~⑥(지시서 맨 위) + CI C-track 4 shard 초록.

# REPORT_SPY_INTEL_P3 — 정탐이 실제 도시 재고와 소속 장수를 보여 준다 (큐 37번, GOAL-SPY-01 P3) (클코드, 2026-11-27)

- **됐나**: 코드·시험은 됐다. **CI는 shard 0만 알려진 컷인 길이 검사로 빨강**(7절, 클코치 판단 필요), shard 1·2·3 초록, 로컬 C-track 212개 전부 통과. 정확 정탐은 적 도시의 실제 `resource_stock`(P0 장부, 9품목)·소속 장수·관측 턴을 보이고, 정치 1 추정 정탐은 그대로다. `worldmap_main.gd` **0줄 변경** → 고정 다시 걸기(③) 필요 없음.
- **가지**: `feature/wm3d-spy-intel-20261127`, 시작 `feature/wm3d-stock-p0-20261127` @ `2e3360f2f9d6360369d20e16c11c90c019c577f3`. ① 패치 그대로 `7db1de1` → ② 코드 `61691d2` → 시험 12 `ae4b763`(지시서 6절, 시험 파일만) → 추가분 2 `9da4142`(지시서 7절: 관측 당시 소유 세력 기록·표시 + 시험 13~15) → 시험 15 추가 `f2c3902`(16:55, 시험 파일만, 마지막 커밋, `[skip ci]` 없음). 큐 36 가지는 건드리지 않음. `main` 푸시·병합·삭제·강제 푸시 없음.
- **기준 SHA 차이(지시서 6절)**: CI 초록이던 `1d68293` → 시작점 `2e3360f`의 차이는 `agent/PROGRESS_WM3D.md`·`agent/REPORT_STOCK_AUTHORITY_P0_20261127.md` 문서 2개뿐(실행 코드·검사기·CI 설정 0, `git diff --stat 1d68293 2e3360f`로 확인). 이번 가지 후보 SHA의 새 CI 실행 번호는 7절.
- **패치**: `agent/patches/EASTWAR_Spy_Intel_Snapshot_20261127.patch` SHA256 `0564b334876f327d1d316beb1c92724cb379bff191167c393dcaf668098e279f`(지시서 값과 같음 확인), `git apply --check` 통과, **수정 없이** 적용(파일 4개).
- **세이브**: 큐 36 백업 `C:\eastwar_tmp\saves_backup_20261127\` 그대로 둠. 이 작업은 세이브 파일을 만들지 않았다(시험은 메모리 안에서 저장·불러오기).

## 1. 바꾼 자리
| 파일 | 자리 | 바꾼 것 |
|---|---|---|
| `spy_action_service.gd` | 상수 `SPY_INFO_HEROES_MIN_APTITUDE = 3` | 2절 |
| 〃 | `_get_spy_info_visibility_level` → 기존 본문은 `_get_spy_info_base_visibility_level`로 이름만 옮김 | 정치 3 이상이면 목록 끝에 `"heroes"` |
| 〃 | `_build_spy_info_payload` 앞부분 + 새 `_build_exact_spy_intel_snapshot` | `estimated == false`이고 `resources`/`heroes`가 있으면 `WorldMapSpyIntelSnapshotService.build_snapshot({precision:"exact", …})` 결과로 `payload.resources`(9키)·`payload.heroes`, `payload.observed_turn`·`payload.unknown_fields`. 소유 세력이 비면 `heroes`는 빼고 `unknown_fields`에 `heroes` |
| 〃 | 추정(정치 1) 경로·`resource_seed` 경로 | **0줄 변경**(정확 정탐에서는 그 분기에 들어가지 않음) |
| `spy_controller.gd` | 새 어댑터 `_get_spy_intel_city_stock` | P0 `_get_city_storage`(9품목). 장부에 숫자가 아닌 값이 있으면 그 값을 넘겨 스냅숏이 "모름"으로 표시(0으로 바꿔 보이지 않음) |
| 〃 | 새 어댑터 `_get_spy_intel_city_hero_rows` | 주둔 명단(`_get_city_stationed_hero_ids_for_battle_context`) + 장수 상태(`_normalize_hero_runtime_state`) → `{hero_id, display_name, status, faction_id(=side), role(태수면 governor)}` |
| 〃 | `normalize_city_intel_registry` 허용 필드 | `"heroes"` 추가(지시서 2-7: 없으면 저장 때 필드가 떨어져 나감) |
| `worldmap_city_info_panel_base.gd` | `heroes` 공개 판정·이름 "소속 장수", 힌트 끝에 새 줄 | `재고: 금 N · 쌀 N · … · 소금 N`(0은 0, 모름은 `?`), `소속 장수 N명: 이름(정상/부상), …` 또는 `소속 장수 0명`, 소유 세력 모름이면 `소속 장수 ?`. 관측 턴은 기존 첫 줄 ` · N턴`(= `observed_turn`) |
| `spy_presentation_helper.gd` | `heroes` 공개 판정·이름, 확인값에 `소속 장수 N명` | 창과 같은 판정 |
| `worldmap_debug_cheats_controller.gd` | `INTEL_FIELDS` | `"heroes"` 추가(지시서 2-6) |
| `.github/workflows/verify-c-track.yml` | C-track 목록 끝 | 시험 2줄 |

택한 해석:
- `observed_turn`은 정확 정탐 payload에만 넣었다. 정치 1 추정 정탐은 "0줄 변경"(지시서 2-4)이라 payload 키도 그대로 둔다. 추정 정탐의 관측 턴은 기존처럼 `city_intel[city].turn`(창 첫 줄 ` · N턴`).
- `heroes`는 "공개" 필드에만 넣고 "잠김" 목록(6개 고정 문구)에는 넣지 않았다. 잠김 문구가 도우미 여러 곳에 하드코딩돼 있어, 넣으면 기존 화면 문구가 모두 바뀐다(코드를 덜 바꾸는 쪽).

## 2. 장수 단계 상수
`spy_action_service.gd` `SPY_INFO_HEROES_MIN_APTITUDE := 3` [제안] — 정치 적성 3·4·5 단계 목록 **끝에** `"heroes"`. 1·2 단계는 그대로. 바꾸라는 말이 나오면 이 상수만 바꾼다.

정치 단계별 필드 전/후 + 기술 보정(지시서 6·7절). "보정" = `_get_modified_spy_visibility_level_mvp`의 정보 가시성 순보정 ≥ 0.05(국가 테크 − 적 도시 저항)가 사다리 한 칸(`resources`→`publicSupport`→`loyalty`→`governor`)을 더하는 경우.
| 정치 | 보정 | 정확/추정 | 전(`2e3360f`) | 후(이번) | `resources` 값 |
|---|---|---|---|---|---|
| 1 | 없음 | 추정 | `troops_estimated` | 같음 | — |
| 1 | 있음 | 추정 | `troops_estimated`, `resources` | 같음 | **예전 값 그대로**(`resource_seed`, 실제 재고 아님) |
| 2 | 없음 | 정확 | `troops` | 같음 | — |
| 2 | 있음 | 정확 | `troops`, `resources` | 같음 | 실제 재고(이번에 바뀜) |
| 3 | 없음 | 정확 | `troops`, `resources` | `troops`, `resources`, **`heroes`** | 실제 재고 |
| 4 | 없음 | 정확 | `troops`, `resources`, `publicSupport`, `loyalty` | 〃 + **`heroes`** | 실제 재고 |
| 5 | 없음 | 정확 | `troops`, `resources`, `publicSupport`, `loyalty`, `governor`, `tech` | 〃 + **`heroes`** | 실제 재고 |
- 3~5에 보정이 붙으면 사다리 다음 칸이 더해지는 것도 예전과 같다(사다리 0줄 변경).
- 기존 정확/추정 경계(정치 1만 추정)는 그대로다. 필드 목록에서 바뀐 것은 3·4·5 기본 목록 끝의 `heroes` 하나뿐이고, `heroes`는 보정 사다리에 넣지 않았다. 실제 재고는 `estimated == false`일 때만 넣는다(`fields.has("resources")`만 보고 넣지 않음). 시험 8이 다섯 단계를, 시험 13이 보정 네 경우를 확인한다.

## 3. 기존 시험 변경
| 시험 | 준비/문자열 변경 | 기대 동작 변경 |
|---|---|---|
| `test_worldmap_debug_cheats.gd` 22·273 | 정보 공개 필드 목록 6개 → 7개(`heroes`), 메시지 "six" → "seven" | 0 (치트 ③이 모든 필드를 공개한다는 기대는 같음. 필드 목록 자체가 지시서 2-6으로 늘어난 직접 결과) |
그 밖의 기존 시험·검사기 변경 0. 정탐 시험 `test_worldmap_spy_controller_extraction`(49)·`test_worldmap_spy_routing`(71) 기대값 그대로 PASS.

## 4. 시험 결과
- 채코치 단위 시험 `test_spy_intel_snapshot_service.gd`: `[SPY_INTEL_SNAPSHOT] checks=16 failures=[]`(C-track 등록).
- 새 통합 시험 `tests/scripts/test_worldmap_spy_intel_p3.gd`(+`.uid`, C-track 등록): `[SPY_INTEL_P3] checks=48 failures=[]`(시험 1~15).
  1. 적 도시 쌀 40 → 정치 5 정확 정탐 `resources.rice == 40`(9키) ✔
  2. 금 0 → `resources.gold == 0`, `unknown_fields`에 없음 ✔ / 장부의 철을 숫자가 아닌 값으로 → `unknown_fields`에 `resources.iron`, 창 문구 `금 0`·`철 ?`·`쌀 40` ✔
  3. 정탐 전에 재고를 바꾸면(쌀 777) 바뀐 값, 씨앗값 아님 ✔
  4. 같은 세력 정상·부상만, 포로·사망·타국·중복 제외 ✔
  5. 주둔 0명 → `heroes == []`, 창 문구 `소속 장수 0명` ✔
  6. `observed_turn` == 정탐한 턴, 다음 턴에도 기록 턴 그대로 ✔
  7. 정치 1 → `troops_estimated`만(`resources`·`heroes`·`unknown_fields`·`observed_turn` 없음) ✔
  8. 정치 2 → `troops`만 / 정치 3 → `troops`·`resources`·`heroes`, 4·5는 끝에 `heroes` ✔
  9. 저장(JSON)→불러오기 → `city_intel[A]` 깊은 비교 같음(숫자는 값으로 비교: JSON은 정수를 실수로 읽음) ✔, `heroes` 필드가 정규화에서 살아남음 ✔
  10. P0 회귀: 비용 있는 정탐(민심 교란, 금 300)이 도시에서 빠지고 국가 금 = 도시 합계 = 캐시 ✔ (정보 수집 자체는 비용이 0이라 비용 있는 행동으로 확인)
  11. 실패한 정탐(주사위 100)은 `city_intel`을 바꾸지 않음 ✔
  12. (지시서 6절 추가) 정탐 성공(쌀 40, 장수 1명) 직후 그 도시 쌀 40→90, 그 장수를 다른 도시로 이동(`_apply_battle_settlement_move_hero` — 명단과 장수 위치를 함께 바꾸는 게임 함수), 턴 +1, 저장(JSON)→불러오기 → `city_intel[A]`의 쌀 40·장수 명단·`observed_turn`이 **정탐 때 값 그대로**, 창 힌트도 기록(쌀 40)만 보임 ✔ / 다시 정탐하면 그때만 쌀 90·장수 0명·새 턴으로 바뀜 ✔. 기록은 그 시점의 사진이고 창은 기록만 쓴다.
  - 시험 작성 메모: 처음에는 장수 이동을 도시 명단 배열만 고치는 방식으로 썼는데, 불러오기가 장수 위치로 명단을 다시 만들어 장수가 되돌아왔다(실제 게임의 이동이 아니었음). 게임의 이동 함수로 바꾼 뒤 통과. 제품 코드 변경 없음.
  13. (지시서 7절) 보정 네 경우, HUD 씨앗 쌀 500 / 실제 쌀 40: 기본 1 = `troops_estimated`(재고 없음) ✔ / 보정 1 = `troops_estimated`+`resources`, 값은 **씨앗 그대로(쌀 500)**, `unknown_fields`·`observed_turn` 없음 ✔ / 보정 2 = `troops`+`resources`(**실제 40**), 장수 없음 ✔ / 기본 3 = `troops`+`resources`(실제 40)+`heroes` ✔. 보정은 국가 테크 전부 완료(정보 가시성 0.08)와 대상 도시 치안 50(저항 0.02, 기존 정탐 시험과 같은 준비)으로 실제 사다리 함수에서 만들었다.
  14. `heroes`가 저장(JSON)→불러오기 뒤 `city_intel`(필드·명단)과 창 힌트(`소속 장수 1명 (관측 당시 … 소속): …`)에 남음 ✔
  15. 관측 뒤 그 도시 소유권을 다른 세력으로 바꿔도 기록의 `owner_faction_id`·명단은 관측 때 그대로, 창은 `관측 당시 <관측 때 세력> 소속` ✔ / (16:55 추가) `owner_faction_id`가 없는 옛 기록을 저장→불러오기 해도 키가 생기지 않고(현재 소유로 채워 넣지 않음) 창 표시는 예전과 같음(소유 문구 없음) ✔
- 표시 규칙(지시서 7절): 정확 정탐 기록에 `owner_faction_id`(관측 당시 소유 세력)를 넣고, 창의 장수 줄은 늘 그 기록 기준으로 `소속 장수 N명 (관측 당시 ○○ 소속): …`이라고 쓴다(현재 소유국으로 바꿔 보이지 않음).
- 로컬 전체: 6절.

## 4-1. 남은 문제(범위 밖, 지시서 7절)
- **추정 정탐(정치 1) + 기술 보정이면 `resources`가 붙는데, 그 값은 예전처럼 도시 고정 씨앗값(`resource_seed`)이다.** 실제 재고가 아니라 "추정 재고" 규칙이 아직 없다. 이번에는 지시서대로 0줄 변경으로 두었고(시험 13이 지킴), 추정 재고를 어떻게 보일지(반올림·범위 등)는 별도 결정이 필요하다.
- `heroes`는 "잠김" 목록 문구(6개 고정)에는 안 나온다(1절 택한 해석).

## 5. 고정 다시 걸기
필요 없음. `worldmap_main.gd`는 0줄 변경(P0 고정 `e206d60`과 같음). 정탐 서비스·컨트롤러를 바이트 동결하는 검사기는 없었다(검사기 72개 통과). `validate_worldmap_trade_phase2_extraction.py`는 커밋 전 작업 트리만 보고 실패, 커밋 뒤 PASS(P0 때와 같음).

## 6. 로컬 검증
- C-track Godot 시험 목록 **212개**(큐 36의 210 + 이번 2)를 4개씩 병렬로 돌렸다. 211개 exit 0. 1개 `test_battle3d_block7_board_data`는 병렬 실행 중 출력 없이 비정상 종료(종료 코드 -1066598273, 로그 0줄)했고, 단독 재실행에서 `[BLOCK7_BOARD_DATA] PASS: 13 checks, 0 failures`. 3D 전장 판 데이터 시험이라 이번 변경과 닿는 곳이 없다(로컬 병렬 실행의 일시 오류로 본다, [추정]). CI에서는 shard 순서대로 하나씩 돈다.
- 정적 검사기 72개 → 실패 0(커밋 뒤).
- 가져오기(`--editor --import`) 뒤 새 `.uid` 1개(`test_worldmap_spy_intel_p3.gd.uid`) 외 작업 트리 변화 없음.

## 7. CI
- 푸시: `feature/wm3d-spy-intel-20261127` 새 가지, `7db1de1..f2c3902` 커밋 5개 한 번에(김작 "푸시해줘"). 원격 = 로컬 HEAD `f2c39026de246a21b61f9d51f497516c7cd75073`. 마지막 커밋에 `[skip ci]` 없음.
- `Verify C-track refactor` 실행 `45966240063`(head `f2c3902`): **failure** — shard 1·2·3 **success**, **shard 0 failure**. https://github.com/kimjak-app/SamWar_BattleLab/actions/runs/45966240063
  - 원인(전체 로그 `gh api …/actions/jobs/140395469271/logs`, 26,179줄): **알려진 육전 컷인 길이 검사**만 실패. `test_battle3d_cutin_result_toast.gd` `[CUTIN] checks=16 failures=["at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.95, 3.968, 3.926, 3.97, 3.947]"]` — 다섯 컷인 중 하나가 3.926초(기준 3.95초). 11-10·11-11에도 같은 검사가 같은 식(3.934·3.943초)으로 빨갰다. 이번 변경(정탐·도시 정보 창)은 3D 전장 컷인 코드를 건드리지 않는다.
  - shard 0의 정적 검사기 **72개는 모두 통과**했고, Godot 시험은 33번째인 이 컷인 시험에서 `set -e`로 멈췄다. 그래서 **shard 0에 배정된 나머지 20개 시험과 장면 불러오기 단계는 CI에서 돌지 않았다**: `test_battle3d_oblique_click`, `test_battle3d_block7_board_data`, `test_battle3d_look12_tree_height`, `test_battle3d_edge_scroll_gates`, `test_battle3d_block46_facing_ground`, `test_battle3d_block46b_panel_avoid`, `test_battle3d_block46d_panel_sweep`, `test_battle3d_block6a_panel_body_gap`, `test_battle_t1_enemy_ai_blocked`, `test_single_side_exhaustion_turn_order`, `test_worldmap_domestic_tech_research_service_extraction`, `test_worldmap_military_controller_extraction`, `test_worldmap_battle_settlement_applier_extraction`, `test_worldmap_troop_rebalance_service_extraction`, `test_worldmap_diplomacy_validation_extraction`, `test_worldmap_trade_routing`, **`test_worldmap_spy_routing`**, `test_battle3d_worldmap_retreat`, `test_worldmap_left_panel_grip`, **`test_worldmap_debug_cheats`**. 이 20개는 로컬 전체 실행(6절)에서 모두 통과했다(정탐 관련 두 개도 포함).
  - 큐 6절에 따라 `gh` 재실행은 하지 않았다. 지시서(큐 36 3절 "컷인 길이 검사만 빨가면 멈추지 말고 보고")대로 보고만 하고, **합격 기준 "C-track 4 shard 초록"은 아직 못 채운 상태**다. 클코치 판단 필요: (가) CI 재실행 허락(김작/클코치가 Actions 화면에서 실행하거나 지시로 허락) — 재실행하면 나머지 20개도 CI에서 확인된다, (나) 큐 35 답신 3 때처럼 컷인 관찰 자료로 받고 로컬 결과로 갈음.
- `Verify WorldMap3D`: 실행되지 않음(경로 조건: `worldmap3d/**`·`scripts/worldmap/map3d/**`·`WorldMap3D_*.tscn`·`tests/scripts/test_worldmap3d_*.gd`·`scripts/worldmap_city_marker.gd`·`WorldMap.tscn`·자기 yml만. 이번 변경은 그 경로 밖).

## 8. 통합 F6 체크리스트(김작, P0 + P3 한 번에)
가지 `feature/wm3d-spy-intel-20261127`(P0 포함)으로 F6. 세이브는 새 이름으로(큐 36 백업은 그대로).
P0(큐 36 보고서 9절):
1. 새 게임 → 좌측 국가 창고 = 한성 도시 상세 창고 값과 같음.
2. 도시 하나 더 가진 상태에서 내부 이송 → 두 도시 값이 바뀌고 국가 창고 합계는 그대로.
3. 수동 무역(수출) → 그 도시 금이 늘고 국가 창고 금도 같은 만큼.
4. 턴 몇 번 넘겨 생산 → 도시 연구 시작 가능, 그 도시 창고에서 비용이 빠짐.
5. 외교 사신·정탐·모병 → 국가 창고와 수도 창고에서 비용이 빠지고, 턴을 넘겨도 되살아나지 않음.
6. Ctrl+Shift+G → 국가 창고가 "0 / 9999"가 아니라 채운 값 합계.
7. 저장 → 불러오기 → 값 그대로. 옛 세이브를 불러오면 출력 창에 `[STOCK_MIGRATION]` 줄(있던 도시만).
P3(이번):
8. ① 정치 3 이상 재상으로 적 도시 정탐 성공 → 정보 창 힌트에 `재고: 금 … · 쌀 … · …`(9품목, 실제 값). 0인 품목은 0.
9. ② 같은 힌트에 `소속 장수 N명 (관측 당시 ○○ 소속): 이름(정상/부상)`. 포로·사망·타국 장수는 없음. 장수 없는 도시는 `소속 장수 0명`. 정탐 뒤 그 도시 재고·장수가 바뀌어도 다시 정탐하기 전까지 힌트는 정탐 때 값 그대로.
10. ③ 힌트 첫 줄 `정보 수준: … · N턴` = 정탐한 턴.
11. ④ 정치 1 재상으로 정탐 → 예전처럼 병력 추정만(재고·장수 줄 없음).
12. ⑤ 저장 → 불러오기 → 같은 도시 정보 창의 정탐 내용 그대로.
13. ⑥ 위 P0 1~7 그대로.
