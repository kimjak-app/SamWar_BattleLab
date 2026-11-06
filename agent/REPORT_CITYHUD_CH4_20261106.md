기준 화면: 새 가지 `feature/wm3d-cityhud4-20261106`(시작: 25번 HUDFIX가 `main`에 합류된 뒤의 `origin/main` 끝 `a9e3b84229f63286bbdc784d78826b0e2cdb792d`, 코드 커밋 `c989fdc4af545ec5adec1b10a61089374f2666b5`)에서 F6로 `WorldMap.tscn`을 열고 내 도시(한성·평양·건업·에도·교토)를 눌렀을 때, 성 안 그림에 **그 도시가 완료한 테크의 건물만** 그려진다(생활 건물·민가·배경은 항상). 시장은 완료된 가장 높은 단계 하나, 항구 자리는 무역항이 있으면 무역항. 테크를 완료하면 창이 열려 있는 동안 건물이 켜진다.
합격 기준: 6절 자동 기준 전부 + `main` 수정 0줄 + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(7절 체크리스트).

# REPORT_CITYHUD_CH4 — 성 안 건물을 테크 완료와 연동 (클코드, 2026-11-06)

- **됐나**: 됐다. 성 안 그림이 열린 도시의 완료 테크를 따른다. 새 검사 75개, 기존 검사 전부 통과.
- **CI**: `Verify C-track refactor` run `42232869404` **success**(4 shard 모두). `Verify WorldMap3D`는 경로 조건에 안 걸려 실행되지 않았고, 같은 묶음 8개를 로컬에서 돌려 모두 통과했다(7절).
- **막힌 것**: 없음. 판단이 필요한 곳 2건은 "택한 해석"에 적었다(배지 테스트 부재, 매 프레임 비용).

판정: **자동 기준 합격 — 김작 F6 대기**

## 1. 시작 확인
- [사실] 시작 `main` 해시: `git rev-parse origin/main` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`. 새 가지를 여기서 땄다(`git switch -c feature/wm3d-cityhud4-20261106 origin/main`, 추적 설정은 바로 해제해 `main`으로 잘못 push될 길을 없앴다).
- [사실] 시작 전제: `worldmap_city_interior_controller.gd`에 `TitleLabel`·`CloseButton` 없음(grep 0줄). 지시서 1절 [사실]은 `a9e3b84`에서 모두 맞았다 — 배치표 5성·항목 필드·생활 5종 `tech_id` `""`·시장/교토 항구 `slot_candidates`·교토 `commerce_port` `compare_only`·`commerce_shipyard` 별도 슬롯, main의 `_get_completed_city_domestic_tech_snapshot_mvp`(8742행)·`_is_city_domestic_tech_completed_mvp`(8072행), `_draw_city`가 `items_for_city` 전부를 그림.
- [사실] 배치표의 `tech_id`와 `slot_candidates`에 나오는 테크 24종(노점·상설시장, 교토 `commerce_port` 포함)이 모두 테크 카탈로그(`domestic_tech_catalog.gd`)에 있다.

### 1절 [미확인] 두 건의 확인 결과
1. **시장 후보별 그림 크기** — [사실] 원본 PNG: 노점·상설 128×128, 대형 192×128(kr/cn/jp 같음). 교토 항구 192×128, 무역항 256×128. 배치표는 슬롯 항목 하나(대형시장/무역항)의 `w,h` = 원본 × `scale`(1.25)만 가진다. 발 자리 규칙(`ax, ay` = 그림 아래 가운데, 왼쪽 위 = `(ax - w/2, ay - h)`, 배치표 `coord` 설명과 `item_top_left()`)대로 **다른 단계의 그림은 자기 원본 크기 × 1.25로, 같은 발 자리 `(ax, ay)`에** 그린다. 그래서 노점·상설은 160×160, 항구는 240×160, 대형·무역항은 배치표 `w,h` 그대로(CH-3과 같은 사각형). 테스트 3·4번이 발 자리와 크기를 확인한다.
2. **게임 시작 직후 완료 테크** — [사실] 새 테스트가 아무것도 바꾸기 전에 찍은 값: 5성 모두 `{  }`(빈 사전). 원문:
```
[CITY_INTERIOR_TECH_LINK] start completed hanseong = {  }
[CITY_INTERIOR_TECH_LINK] start completed pyeongyang = {  }
[CITY_INTERIOR_TECH_LINK] start completed jianye = {  }
[CITY_INTERIOR_TECH_LINK] start completed edo = {  }
[CITY_INTERIOR_TECH_LINK] start completed kyoto = {  }
```
   그래서 새 게임 직후 창에는 배경 + 생활 5종 + 민가만 보인다(한성 16개 = 민가 11 + 생활 5).

## 2. 변경 요약 (코드 커밋 `c989fdc`, 5파일, +371 −5)
| 파일 | 내용 |
|---|---|
| `scripts/worldmap/ui/worldmap_city_interior_controller.gd` | `building_key_to_draw(item, completed, show_all)`(정적, 2절 규칙 1~5): 민가·생활(`tech_id ""`) 항상 / `slot_candidates`는 앞에서부터 완료된 첫 후보, 없으면 빈 슬롯 / 그 밖은 `completed.get(tech_id)`. `_draw_city`가 그 키의 그림을 그리고, 다른 단계면 자기 원본 크기 × `scale`로 같은 발 자리에 둔다. 노드에 `drawn_key` 메타 추가(테스트용). `_process`(열려 있을 때만)가 열린 도시의 완료 사본 ≠ 마지막으로 그린 사본이면 다시 그린다. `debug_show_all`(기본 false, 바꾸면 열린 도시를 다시 그림), `Ctrl+Shift+K` 토글(`OS.is_debug_build()`일 때만, 열려 있을 때만). `get_draw_count()`. `MAIN_MEMBERS`에 스냅숏 함수 이름 추가 |
| `tests/scripts/test_worldmap_city_interior_layouts.gd` | 컨트롤러를 찾은 직후 `debug_show_all = true` 한 줄 + 머리 주석 한 줄. CH-3 숫자 검사는 그대로(93개) |
| `tests/scripts/test_worldmap_city_interior_tech_link.gd` (+`.uid`) | 새 검사 75개(5절 1~9번) |
| `.github/workflows/verify-c-track.yml` | 마지막 목록 끝에 새 테스트 한 줄(인덱스 208 → shard 0, 기존 테스트 shard 이동 0) |

- [사실] `scripts/worldmap/worldmap_main.gd`·`worldmap3d/` 변경 0줄(`git diff a9e3b84 c989fdc --name-only`에 없음). 배치표·`worldmap_city_interior_layouts.gd`·창 겉틀·닫기 규칙·`PLACEHOLDER_TEXT` 변경 0.
- [사실] 변경 파일 5개가 모두 허용 목록 안이다(컨트롤러, 테스트들, 새 테스트를 C-track 목록 끝에 넣는 한 줄).

## 3. 5절 결과 숫자
로컬(Godot 4.6.2, 테스트마다 임시 `APPDATA`):
```
test_worldmap_city_interior_tech_link exit=0 | [CITY_INTERIOR_TECH_LINK] checks=75 failures=[]
test_worldmap_city_interior_layouts   exit=0 | [CITY_INTERIOR_LAYOUT] checks=93 failures=[]
test_worldmap_city_interior_window    exit=0 | [CITY_INTERIOR] checks=126 failures=[]
test_worldmap_integrated_hud_smoke    exit=0 | [INTEGRATED_HUD_SMOKE] checks=12 failures=0
test_worldmap_left_panel_grip         exit=0 | [LEFT_PANEL_GRIP] checks=28 failures=[]
test_worldmap_turn_button_daynight    exit=0 | [TURN_BUTTON_DAYNIGHT] checks=43 failures=[]
test_worldmap_city_building_assets    exit=0 | [CITY_BUILDING_ASSETS] checks=482 failures=[]
```
- [사실] 창 테스트 125 → 126: 그 테스트는 컨트롤러 `MAIN_MEMBERS`의 이름마다 "main에 있다"를 하나씩 검사한다. 스냅숏 함수 이름을 목록에 넣어 1개 늘었다(통과). 그 밖의 기존 숫자는 HUDFIX와 같다(layouts 93, grip 28, smoke 12, turn button 43).
- 새 검사 내역(모두 통과):
  1. 완료 0개: 한성 16개 = 민가 11 + 생활 5, 테크 건물 0, 배경이 맨 아래.
  2. `mil_barracks` 완료 → 병영 1개만 늘고 나머지 16개 그대로(17).
  3. 시장: 없음 → 슬롯 비움 / 노점 → 노점 / 노점+상설 → 상설 / +대형 → 대형. 매번 시장 그림 **1개**, 발 자리 (440, 480) 같음, 크기 = 자기 원본 × 1.25.
  4. 교토 항구 자리: 없음 → 비움 / 항구 → 항구 / 항구+조선소 → 항구 + 조선소 / +무역항 → 무역항 하나 + 조선소 / 무역항만 → 무역항, 조선소 없음. `compare_only` 항구는 어느 경우에도 없음. 발 자리 (672, 736).
  5. 내륙 한성에 해안 테크 7종 완료 → 해안 건물 0(16개 그대로).
  6. 한성에 병영·노점·관개 완료 → 평양 창에는 테크 건물 0.
  7. 열린 채 5프레임: 다시 그림 0회. 열린 채 `mil_barracks` 완료 → 3프레임 안에 병영이 켜지고 다시 그림 정확히 1회, 그 뒤 5프레임 0회. 닫았다 열어도 유지.
  8. `debug_show_all = true` → 5성 모두 CH-3 숫자(30·28·29·29·30)와 `items_for_city` 순서 그대로. false → 규칙대로 복귀. `Ctrl+Shift+K` 켬 → 30, 그냥 `K` 무시, 다시 `Ctrl+Shift+K` 끔 → 16.
  9. 위 모든 경우에 `get_drawn_items()` == 규칙이 그리는 항목(안 그린 항목은 들어 있지 않음).
- [사실] 테스트가 틀린 코드를 잡는지 한 번 확인했다: 규칙 5번을 일부러 "항상 그림"으로 바꾸자 `exit=1`(1번부터 실패). 원래대로 되돌린 뒤 커밋했다(diff 동일 확인).
- WorldMap3D 묶음 8개 로컬: 전부 `exit=0`(color_parity 57, mem_probe 37, production 28, roads 121, 나머지 3개는 요약 줄 없이 exit 0). host 로그의 `hero_cutin_presentation.gd` 컴파일 오류 한 줄은 HUDFIX 때와 같은 기존 소음이다.

## 4. 갱신 비용 (한 줄)
- [사실] 열린 도시 1곳의 완료 사본 + Dictionary 비교 1회 = **평균 786.6 µs/프레임**(로컬 헤드리스 디버그 실행, 1000회 평균, 창이 열려 있을 때만; CI 러너 483.4 µs). 원인 측정: main의 스냅숏 함수 1회 857.9 µs 중 **테크 카탈로그 정의 재생성(`get_city_definitions`)이 832.4 µs**, `_player_state` 원값 읽기는 0.5 µs.

## 5. 키 조합과 근거
- **`Ctrl+Shift+K`**(창이 열려 있을 때, `OS.is_debug_build()`일 때만). 출시본에서는 동작하지 않는다.
- [사실] 근거: 게임 코드의 키 상수 grep(`KEY_[A-Z0-9_]+`) 결과 `KEY_K`는 0회. `ctrl_pressed`·`shift_pressed`·`alt_pressed`를 쓰는 곳도 0곳. `project.godot`에 키 입력 매핑 0개. ESC·F키는 쓰지 않았다.

## 6. 택한 해석
1. **"기존 배지 테스트가 쓰는 방식"** — [사실] 테크 배지(`worldmap_tech_badge_summary_controller.gd`, `worldmap_tech_badge_test_controller.gd`)를 쓰는 테스트는 저장소에 없다(`git grep` 0건). 그래서 새 우회로를 만들지 않고 **게임이 턴 끝에 실제로 쓰는 완료 경로** `main._ensure_domestic_tech_research_service().complete_city_research(city_id, {"tech_id": ...})`로 완료 상태를 만들었다. 경우마다 `_player_state.city_domestic_tech_completed`를 `{}`로 비운 뒤 다시 완료시키고, 끝에 원래 완료 사전·도시 상태·도시 주인을 되돌린다.
2. **매 프레임 비용** — 지시서 3절 방식(열린 도시 사본 비교 1회)을 그대로 따랐다. 위 0.79 ms의 97%는 main 스냅숏 함수 안의 카탈로그 재생성이다. [추정] 원값(`_player_state`의 그 도시 값)이 바뀌었을 때만 스냅숏을 다시 읽으면 1 µs 아래로 줄일 수 있다. 다만 지시서 방식과 달라지므로 이번에는 넣지 않았다. 클코치 판단이 필요하다.
3. **슬롯의 다른 단계 크기** — 배치표에 크기가 없어서 "자기 원본 × 배치표 `scale`, 발 자리 같음"으로 했다(1절 [미확인] 1). 슬롯 자기 건물(대형시장·무역항)은 CH-3과 같은 사각형이다.
4. **조선소 없이 무역항** — 카탈로그상 무역항은 조선소가 선행이지만, 그림 규칙은 선행을 보지 않는다(완료 목록만 본다). 테스트 4번의 "무역항만" 경우는 규칙 확인용이다.

## 7. CI
- [사실] `Verify C-track refactor` run `42232869404`(커밋 `c989fdc`): **success**, 14:19:19Z → 14:41:09Z.
```
verify (shard 3 of 4) 127942899957 success
verify (shard 1 of 4) 127942899981 success
verify (shard 0 of 4) 127942900000 success
verify (shard 2 of 4) 127942900039 success
```
- [사실] CI 로그의 요약 줄:
```
[CITY_INTERIOR_TECH_LINK] checks=75 failures=[]
[CITY_INTERIOR_LAYOUT] checks=93 failures=[]
[CITY_INTERIOR] checks=126 failures=[]
[INTEGRATED_HUD_SMOKE] checks=12 failures=0
[LEFT_PANEL_GRIP] checks=28 failures=[]
[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]
[CITY_INTERIOR_TECH_LINK] per-frame check (snapshot copy + Dictionary compare, open city only) = 483.4 us avg over 1000
```
- [사실] 알려진 `[CUTIN]` 흔들림: 이번에는 없었다(shard 0 success).
- [사실] `Verify WorldMap3D`: 이 커밋에 실행 없음(`gh run list --commit c989fdc` = C-track 1개). 바뀐 경로(`scripts/worldmap/ui/`, `tests/scripts/test_worldmap_city_interior_*`, `verify-c-track.yml`)가 그 워크플로의 `paths` 조건 밖이다. 대신 같은 묶음 8개를 로컬에서 돌렸다(3절 끝, `agent/evidence/cityhud4_20261106/wm3d_local.txt`).

## 8. 김작 F6 체크리스트
1. **새 게임 시작 직후** 한성을 눌러 창을 연다 → 건물은 거의 없고 생활 5종·민가·배경만 보인다.
2. 테크트리에서 한성 테크 하나를 완료시킨다 → 창이 열려 있으면 그 건물이 켜진다(닫았다 열어도 유지).
3. 시장 테크를 단계별로 완료 → 같은 자리 그림이 바뀐다(겹쳐 쌓이지 않음).
4. 교토(해안)에서 항구 → 무역항 → 조선소.
5. "전부 표시" 키로 5성이 CH-3 모습으로 돌아오는지.
- **"전부 표시" 키**: 창이 열린 상태에서 `Ctrl+Shift+K`(F6 실행은 디버그 빌드라 동작). 한 번 더 누르면 규칙대로 돌아온다.
- **테크를 빠르게 완료시키는 기존 개발/테스트 경로**: [사실] **없다.** main·`domestic_tech/`에 테크 즉시 완료용 디버그 함수·치트·실행 인수가 없다(grep `debug|cheat|instant|force` × `tech|research` → 걸린 것은 `_get_domestic_tech_completion_debug_object_class_name_mvp`라는 디버그용 이름 출력 함수 하나뿐이다. main과 완료 연출 컨트롤러에 같은 이름으로 있다). 테스트는 연구 서비스의 `complete_city_research`를 직접 부르지만 이는 F6 화면에서 누를 수 있는 길이 아니다. F6에서는 일반 경로(테크트리에서 연구 시작 → 턴 종료 반복)를 쓴다. 참고 [사실]: 노점시장·병영 설치는 선행 없음, 상설시장 ← 노점, 대형시장 ← 상설. 교토 항구(선행 없음) → 조선소(← 항구) → 무역항(← 조선소 + 국가 테크 `nation_alliance_system`)이라, 4번은 실제로는 항구 → 조선소 → 무역항 순서로 열린다.

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-cityhud4-20261106` 체크아웃, `git status` 깨끗.
2. 원격 `feature/wm3d-cityhud4-20261106` = 이 보고서 커밋(코드 `c989fdc` 위 `[skip ci]` 1개). `main`·orders·intake·그 밖의 가지·태그·PR 변경 0.
3. `main` 수정 0줄, `worldmap_main.gd`·`worldmap3d/` 수정 0줄.
4. 김작 사용자 파일(`user://`) 손대지 않음 — 로컬 Godot 실행은 모두 임시 `APPDATA`.
5. 다음: 김작 F6(8절). 합격하면 `main` 합류 지시서가 필요하다. 22번 bake 가지는 여전히 별도 지시서 대기.
