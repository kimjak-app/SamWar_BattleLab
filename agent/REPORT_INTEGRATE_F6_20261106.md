기준 화면: 새 가지 `feature/wm3d-integrate-20261106`에서 `res://WorldMap.tscn`(F6) — 성 안 창이 좌측 정보창 옆에 뜨고(CH-2b), 좌측 정보창 맨 위 띠로 끌리며(CH-2c), 5성 안 배치(CH-3)가 보이고, 오른쪽 아래가 해·달 턴 버튼(18번)이다. 한 가지(한 빌드)에서 전부 보인다.
합격 기준: 5절 자동 기준 + C-track 4 shard·`Verify WorldMap3D` success. 최종 합격은 김작 F6 한 번(아래 체크 목록). 김작 승인 전에는 `main`에 합치지 않는다.

# REPORT_INTEGRATE_F6 — 가지 3개를 한 가지에 합침 (클코드, 2026-11-06)

## 김작 F6 체크 목록 (지시서 7절 그대로)
1. 클코드가 `feature/wm3d-integrate-20261106`을 체크아웃해 준 상태에서 F6로 `WorldMap.tscn`.
2. **성 안 창(CH-2b)**: 한성(내 도시)을 누르면 좌측 정보창 오른쪽에 붙어 뜨는가. 창이 떠 있어도 지도 드래그·휠이 되는가. 적 성을 누르면 닫히는가.
3. **좌측 정보창 띠(CH-2c)**: 맨 위 얇은 띠를 끌면 정보창이 움직이고 성 안 창이 따라오는가.
4. **5성 안 배치(CH-3)**: 5성 안이 참고 그림처럼 보이는가, 다른 도시는 안내 글인가.
5. **턴 버튼(18번)**: 오른쪽 아래 버튼을 누르면 하늘이 해→노을→달→새벽으로 도는가, 턴이 한 번만 지나가는가(달력·턴 수 +1), 턴 요약 팝업이 뜨는가, 끝나면 낮에서 멈추는가, 금테 바깥을 눌러도 안 눌리는가, 호버 툴팁 「턴 종료」.
6. M7(3D 전투 후퇴·복귀)은 **월드맵에서 3D 전장으로 가는 길(M7-3)이 아직 없어 F6로는 못 본다.** 자동 테스트로만 확인한다.

[사실] 김작님 PC의 작업 폴더(`C:\dev\SamWar_BattleLab_cc`)는 지금 `feature/wm3d-integrate-20261106`이 체크아웃된 상태다(작업 트리 깨끗).

## 1. 먼저 확인
| 항목 | 지시서 | 실제 | 판정 |
|---|---|---|---|
| cityhud 끝 | `ad80253` | `ad80253` | 같음 |
| m7prep 끝 | `0bfff7c` | `0bfff7c` | 같음 |
| turnbtn 끝 | `ff033bb` | `ff033bb` | 같음 |
| cityhud 시작(merge-base) | `9160baf` | `9160baf`, `origin/main`(`ab9b739`)의 조상 | 맞음 |
| m7prep 시작 | `9160baf` | `9160baf`, 조상 | 맞음 |
| turnbtn 시작 | `ab9b739` | `ab9b739` = `origin/main` | 맞음 |

[사실] `verify-c-track.yml`의 Godot 테스트는 **줄 순서 라운드로빈**이다: `tests=( … )` 목록 4개(166·352·374·400행)를 하나의 카운터(`$RUNNER_TEMP/ci_test_index`)로 이어 세고 `index % 4 == SHARD`인 테스트만 돈다. 세 가지가 더한 줄은 모두 **마지막 목록(400행~)의 끝**이라, 기존 198개 테스트의 shard 배정은 하나도 밀리지 않는다(아래 표).

## 2. 병합 3건
| 순서 | 병합 커밋 | 들어온 가지(끝) | 충돌 |
|---|---|---|---|
| ① | `002ac6c` | `feature/wm3d-cityhud-20261105` (`ad80253`) | 없음 |
| ② | `b254c06` | `feature/wm3d-m7prep-20261105` (`0bfff7c`) | `.github/workflows/verify-c-track.yml` 1곳 |
| ③ | `b06fc4a` | `feature/wm3d-turnbtn-20261106` (`ff033bb`) | `.github/workflows/verify-c-track.yml` 1곳 |
| +  | `dac3a8b` | smoke 테스트 + CI 1줄 | — |

[사실] 코드 파일 충돌 0. 다른 파일 충돌이 없어 멈춤 조건에 걸리지 않았다.
[사실] ② 병합 커밋 메시지 끝에 git이 넣은 `# Conflicts:` 주석 2줄이 남았다(내용 영향 없음, push 뒤라 고치지 않음).

### 충돌 해결 전후 (해결 규칙: 합집합, 기존 줄 그대로, 기존 목록 끝에 m7prep → cityhud → turnbtn)
② 충돌 원문:
```
<<<<<<< HEAD
            tests/scripts/test_worldmap_city_building_assets.gd
            tests/scripts/test_worldmap_city_interior_window.gd
            tests/scripts/test_worldmap_city_interior_layouts.gd
            tests/scripts/test_worldmap_left_panel_grip.gd
=======
            tests/scripts/test_battle3d_worldmap_context_entry.gd
            tests/scripts/test_battle3d_worldmap_result_return.gd
            tests/scripts/test_battle3d_worldmap_retreat.gd
>>>>>>> origin/feature/wm3d-m7prep-20261105
```
③ 충돌 원문: HEAD 쪽 = 위 7줄(해결 순서대로), 들어온 쪽 = `tests/scripts/test_worldmap_turn_button_daynight.gd`.
최종 (`origin/main` 대비 목록 끝 diff):
```
             tests/scripts/test_worldmap_spy_controller_extraction.gd
+            tests/scripts/test_battle3d_worldmap_context_entry.gd
+            tests/scripts/test_battle3d_worldmap_result_return.gd
+            tests/scripts/test_battle3d_worldmap_retreat.gd
+            tests/scripts/test_worldmap_city_building_assets.gd
+            tests/scripts/test_worldmap_city_interior_window.gd
+            tests/scripts/test_worldmap_city_interior_layouts.gd
+            tests/scripts/test_worldmap_left_panel_grip.gd
+            tests/scripts/test_worldmap_turn_button_daynight.gd
+            tests/scripts/test_worldmap_integrated_hud_smoke.gd
           )
```
중복 줄 0.

## 3. diff 합 확인 (`git diff --numstat`, 병합 3건 뒤 · smoke 커밋 전)
| 범위 | 파일 | 줄 |
|---|---|---|
| `origin/main...cityhud` | 247 | |
| `origin/main...m7prep` | 21 | |
| `origin/main...turnbtn` | 27 | |
| 세 가지 합(겹침은 `verify-c-track.yml` 1개뿐: +4, +3, +1) | 293 | +14325 / −18 |
| `origin/main..HEAD` | 293 | +14325 / −18 (`verify-c-track.yml` +8) |

[사실] 파일별 numstat이 겹침 1개 외에는 모두 가지 쪽과 같다. 사라지거나 두 번 들어간 코드 없음.

## 4. shard 배정 (smoke 포함 최종, 라운드로빈 index % 4)
| shard | `origin/main` | 통합 가지 |
|---|---|---|
| 0 | 50 | 52 |
| 1 | 50 | 52 |
| 2 | 49 | 52 |
| 3 | 49 | 51 |
| 합계 | 198 | 207 |

| index | shard | 더한 테스트 |
|---|---|---|
| 198 | 2 | `test_battle3d_worldmap_context_entry.gd` |
| 199 | 3 | `test_battle3d_worldmap_result_return.gd` |
| 200 | 0 | `test_battle3d_worldmap_retreat.gd` |
| 201 | 1 | `test_worldmap_city_building_assets.gd` |
| 202 | 2 | `test_worldmap_city_interior_window.gd` |
| 203 | 3 | `test_worldmap_city_interior_layouts.gd` |
| 204 | 0 | `test_worldmap_left_panel_grip.gd` |
| 205 | 1 | `test_worldmap_turn_button_daynight.gd` |
| 206 | 2 | `test_worldmap_integrated_hud_smoke.gd` |

[사실] 기존 테스트 중 shard가 바뀐 것 0개. 가지마다 따로 돌 때와 index는 달라졌다(예: CH-2c 보고서의 grip 201 → 204, shard 1 → 0).

## 5. smoke 테스트 `tests/scripts/test_worldmap_integrated_hud_smoke.gd` (+`.uid` `uid://c81m13fepqgpy`, CI 1줄)
정식 `WorldMap.tscn`, 1920×1080. 기본 보기 그대로(이 PC 임시 사용자 폴더 = 설정 파일 없음 → 3D).
- ⓐ `TurnEndCompass`에 `SkyA`(TextureRect)·`TurnEndHitArea`
- ⓑ `LeftPanelGrip`이 좌측 정보창 `MarginContainer/Content`의 첫 자식, 보임
- ⓒ 도시 성 안 컨트롤러 스크립트를 가진 노드가 1개, 한성 `try_open` → 창 위치 = 좌측 패널 오른쪽 끝 + `DOCK_GAP`, 같은 y
- ⓓ 하늘 창 중심을 실제 마우스 클릭(입력 이벤트) 1번 → `turn_end_requested` 1번, 연출 중 두 번째 클릭 → 0번 추가, 턴(실제 적 턴·경제 처리)이 끝난 뒤에도 1번
기존 테스트 기대값은 바꾸지 않았다.

## 6. 로컬 결과 (임시 사용자 폴더, 테스트마다 따로)
```
test_worldmap_integrated_hud_smoke exit=0 | [INTEGRATED_HUD_SMOKE] checks=12 failures=0   (map view: 3d, turn presentation finished: true)
test_battle3d_top_commands exit=0 | [TOP_COMMANDS] checks=39 failures=[]
test_battle3d_worldmap_context_entry exit=0 | [BATTLE3D_CONTEXT_ENTRY] checks=35 failures=[]
test_battle3d_worldmap_result_return exit=0 | [BATTLE3D_RESULT_RETURN] checks=194 failures=[]
test_battle3d_worldmap_retreat exit=0 | [BATTLE3D_RETREAT] checks=99 failures=[]
test_worldmap_city_building_assets exit=0 | [CITY_BUILDING_ASSETS] checks=482 failures=[]
test_worldmap_city_interior_window exit=0 | [CITY_INTERIOR] checks=93 failures=[]
test_worldmap_city_interior_layouts exit=0 | [CITY_INTERIOR_LAYOUT] checks=93 failures=[]
test_worldmap_left_panel_grip exit=0 | [LEFT_PANEL_GRIP] checks=28 failures=[]
test_worldmap_turn_button_daynight exit=0 | [TURN_BUTTON_DAYNIGHT] checks=43 failures=[]
validators=72 pass=72 fail=0
```

## 7. CI (`dac3a8b`)
[사실] 둘 다 success.
- `Verify C-track refactor` run `42172124442`: shard 0 `127742145996`·1 `127742145972`·2 `127742146046`·3 `127742145600` 모두 success.
- `Verify WorldMap3D` run `42172124412`: success.

CI 로그 원문(해당 줄):
```
shard 0: [BATTLE3D_RETREAT] checks=99 failures=[]
shard 0: [LEFT_PANEL_GRIP] checks=28 failures=[]
shard 1: [CITY_BUILDING_ASSETS] checks=482 failures=[]
shard 1: [TURN_BUTTON_DAYNIGHT] checks=43 failures=[]
shard 2: [BATTLE3D_CONTEXT_ENTRY] checks=35 failures=[]
shard 2: [CITY_INTERIOR] checks=93 failures=[]
shard 2: [INTEGRATED_HUD_SMOKE] map view: 3d
shard 2: [INTEGRATED_HUD_SMOKE] checks=12 failures=0
shard 3: [BATTLE3D_RESULT_RETURN] checks=194 failures=[]
shard 3: [CITY_INTERIOR_LAYOUT] checks=93 failures=[]
```
[사실] 각 테스트가 4절 표의 shard에서 돌았다.

## 8. 못 본 것
- [미확인] 김작 F6 화면 확인(체크 목록 1~5) — 이 보고서 이후.
- [사실] 입력 수명주기 Godot 테스트(`test_worldmap_to_battle_input_lifecycle.gd`)는 C-track 테스트 목록에 없다(목록에는 검증기 `tools/validate_worldmap_to_battle_input_lifecycle.py`만 있고 통과). 로컬에서도 돌리지 않았다(이 PC 300초 시간 초과는 알려진 문제). → [미확인] 이 테스트 자체의 통합 가지 결과.
- [미확인] smoke ⓓ는 3D 보기에서만 확인했다(2D 보기 클릭은 18번 테스트가 가짜 월드로 확인).
- M7(3D 후퇴·복귀)은 M7-3 전이라 F6로 볼 수 없다. 자동 테스트만.
