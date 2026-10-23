# N4 격자 크기 가정 조사 (2026-10-24)

- base commit: `ba058c8a8e09f955230b5d48dd97e9de09074637` (detached worktree `night4/base`)
- 읽기만, 코드 변경 0
- 합격 판정은 하지 않는다
- 방법: grep 과 정적 읽기만 했다. Godot 은 실행하지 않았다.

## 요약

### 크기의 원천(source of truth)

원천이 둘이다. 2D 엔진용 하나, 3D 랩용 하나다. 둘을 맞춰 주는 코드는 없다.

1. **엔진(2D/ISO)**: `scenes/battle/Battle_Production.tscn:733-734` 의 `BattleGridController` 노드 `grid_width = 18`, `grid_height = 10`.
   - `Battle_Main.tscn` 은 이 씬을 그대로 상속한다.
   - 스크립트 기본값은 `scripts/battle_grid_controller.gd:4-5` 의 14×8 이다. 씬이 덮어쓴다.
2. **3D 랩**: `assets/battle3d/heightfield.json` 의 `board.width = 18`, `board.height = 10` (cell_size 3.0, 높이 샘플 61×109).
   - `lab_heightfield.gd:13` 이 읽고, `battle3d_grid_projection.gd:7-8` 이 이 값으로 격자 크기를 정한다.
3. **숨은 원천**: 시작·증원 칸은 데이터에 없다. 씬의 유닛 마커 픽셀 위치(`Battle_Production.tscn:2161-2262`)를 `world_to_grid` 로 바꿔서 정한다. 격자 크기를 바꾸면 칸 좌표가 따라 바뀐다.

**읽는 쪽**: `battle_grid_controller.gd`, `battle_iso_grid_projection.gd`(configure_from 으로 복사), 엔진 `battle_web_import_test.gd`(전부 `battle_grid_controller.grid_width/height` 또는 `is_in_bounds` 경유), 서비스(인자로 받은 grid), 3D `battle3d_engine_play.gd`(엔진 grid 와 heightfield 둘 다), `lab_presentation.gd`(heightfield).

**하드코딩하는 쪽**: `battle3d_connect_lab.gd:90-91` `range(18)/range(10)`, 창 제목 2곳 "18x10", `validate_battle3d_contract.py:30` `(18,10)`, `test_battle3d_movement_parity.gd:71-72` flat 18×10, `test_battle3d_oblique_click.gd:93` `==180`, 테스트 harness 의 "먼 구석" 칸 `(0,9)`/`(17,0)`, 씬 복사본 2개(`Battle_Land.tscn`, `Battle_UI_Production_Test.tscn`), 디버그 격자선 노드 개수(세로 19, 가로 11), heightfield 의 강 위치·숲 규칙 상수.

**엔진 본체에는 18, 10, 17, 9 를 크기로 쓰는 숫자 리터럴이 없다.** 엔진의 18 들은 모두 픽셀·피해량·시간 값이다(우연).

### 영역별 · 효과별 개수

| 영역 | 깨짐 | 어색함 | 문제 없음 | 무관(우연) | 합계 |
|---|---|---|---|---|---|
| 엔진 | 0 | 2 | 9 | 1 | 12 |
| 서비스 | 0 | 1 | 9 | 1 | 11 |
| 3D 랩 | 4 | 4 | 8 | 1 | 17 |
| 셸 | 0 | 0 | 1 | 0 | 1 |
| 씬 | 0 | 4 | 4 | 0 | 8 |
| 데이터 | 0 | 2 | 1 | 0 | 3 |
| 테스트·골든 | 6 | 2 | 3 | 0 | 11 |
| 검증기 | 2 | 1 | 0 | 1 | 4 |
| **합계** | **12** | **16** | **35** | **4** | **67** |

핵심만 말하면 이렇다.

- 엔진 규칙은 크기를 한 곳에서 읽는다. `Battle_Production.tscn` 의 두 값을 20/20 으로 바꾸면 엔진은 돌아갈 것으로 보인다.
- 대신 시작 칸이 모두 바뀐다(예: 이순신 (3,8) → (3,17)). 기본 배치 골든과 그 테스트는 전부 깨진다.
- 3D 랩은 heightfield.json 과 battlefield.glb 를 다시 만들지 않으면 깨진다. 엔진 크기와 3D 크기를 비교하는 검사가 없어서 조용히 어긋난다.
- ISO 칸은 화면에서 약 0.7배로 작아진다(137×77px → 96×54px). 유닛 토큰은 크기가 고정이라 겹쳐 보일 수 있다.

## 엔진

`scripts/battle_web_import_test.gd`

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| E1 | battle_web_import_test.gd:12066-12087 (`_sync_unit_state_cells_from_markers`) | 시작 칸 = 마커 픽셀 위치 ÷ 칸 크기 | 어색함 | 직교 칸이 106.7×108px → 96×54px 가 되어 칸 좌표가 바뀐다. 배치 비율은 유지되지만 아군–적 거리 17칸 → 25칸으로 늘어 접촉이 늦다. | 씬 마커 위치, 또는 칸 좌표를 데이터로 분리 |
| E2 | :9317, :9343 (증원 배치) | 증원 칸 = 마커 위치를 현재 grid(ISO)로 변환 | 문제 없음 | 18×10 과 같은 경로다. 크기만 따라간다. 실제 칸 값은 실행으로 확인 필요. | 없음 |
| E3 | :12872-12873 | 이동 목표를 `grid_width-1`, `grid_height-1` 로 clamp | 문제 없음 | 크기를 읽는다. | 없음 |
| E4 | :13766-13767 | 자동 이동이 모든 칸을 순회 | 문제 없음 | 180칸 → 400칸, 비용 약 2.2배. | 없음 |
| E5 | :15171 | 적 경로 탐색 상한 = `grid_width*grid_height` | 문제 없음 | 크기를 읽는다. 상한 360 → 400. | 없음 |
| E6 | :14789, :14802, :70 | 디버그 격자선을 `grid_width+1`, `grid_height+1` 개 그림. 상수 이름 `SHOW_LOGICAL_GRID_14X8_GUIDE` | 문제 없음 | 상수가 false 라 꺼져 있다. 켜면 씬 노드가 모자라 일부 선이 빠진다(씬 C4). 이름도 낡았다. | 씬 C4, 상수 이름 |
| E7 | :2653, 4394, 5634, 5643, 6555, 6580, 6645, 11657, 11709, 11746, 12101, 14495, 14749, 14755, 14822, 14895, 14970, 15114 | `battle_grid_controller.is_in_bounds()` 로 경계 검사 | 문제 없음 | 한 곳의 크기를 따른다. | 없음 |
| E8 | :11622-11755 | 범위 표시가 씬의 ColorRect 풀(112개)을 넘으면 자름 | 문제 없음 | 최대 사거리 5 = 61칸이라 112개 안이다. 넓은 판에서는 가장자리 잘림이 줄어 표시 칸이 조금 늘 뿐이다. | 사거리 7 이상이 생기면 풀 늘리기 |
| E9 | :55, :11760-11773 | 범위 칸이 보드 안쪽(가로 32px 여백)에 있어야 표시 | 문제 없음 | 보드 사각형 기준이라 크기와 무관. | 없음 |
| E10 | :33 `MOVE_HIGHLIGHT_SIZE` 68×56 | 이동 하이라이트 기본 크기 | 문제 없음 | ISO 컨트롤러가 칸 크기로 덮어쓴다(battle_iso_production_controller.gd:187-193). 대체값일 뿐. | 없음 |
| E11 | :7656 `_get_visual_token_base_scale_for_unit` | 유닛 토큰 크기가 슬롯별 고정 배율 | 어색함 | 칸이 0.7배로 작아져도 토큰은 그대로라 이웃 칸과 겹쳐 보인다. | 토큰 배율을 칸 크기에 연동 |
| E12 | :32 `ENEMY_GUARD_STEP_DISTANCE 18.0`, :337 `UNIQUE_SKILL_SPLASH_DAMAGE 18`, :1136-1140 `(-18,-96)` 오프셋, 0.18 지속시간 다수 | 픽셀·피해량·시간 | 무관 | 격자 크기와 상관없는 우연한 18. | 없음 |

## 서비스

`scripts/battle_grid_controller.gd`, `scripts/battle/`

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| S1 | battle_grid_controller.gd:4-5 | 기본값 14×8 | 문제 없음 | 씬이 덮어쓴다. 다만 기본값이 실제와 달라 헷갈린다. | 선택: 기본값 정리 |
| S2 | battle_grid_controller.gd:24-30 | 칸 크기 = 보드 크기 ÷ 칸 수 | 문제 없음 | 계산은 맞다. 20×20 에서 직교 칸은 96×54px(정사각형 아님). 시작 칸 계산(E1)에만 쓰인다. | 없음 |
| S3 | battle_grid_controller.gd:33-34 `is_in_bounds` | 경계 = 0..w-1, 0..h-1 | 문제 없음 | 유일한 경계 검사 원천이다. | 없음 |
| S4 | battle_grid_controller.gd:61-68 `get_tiles_in_range` | 모든 칸을 돌며 거리 비교 | 문제 없음 | 호출마다 400칸 순회. 비용 2.2배. | 필요하면 사거리 사각형만 순회 |
| S5 | presentation/iso/battle_iso_grid_projection.gd:15-20 | 원본 컨트롤러 크기를 복사 | 문제 없음 | 크기를 읽는다. | 없음 |
| S6 | battle_iso_grid_projection.gd:35-41 | 반칸 = 보드 ÷ (w+h). 보드는 1920×1080 고정 | 어색함 | 18+10=28 → 20+20=40. 마름모가 137×77px → 96×54px(약 0.7배). 판 모양도 기운 마름모에서 대칭 마름모로 바뀐다. | 보드 마커 크기 또는 카메라 줌 |
| S7 | battle_iso_grid_projection.gd:60-79 | `grid_height` 를 오프셋으로 사용 | 문제 없음 | 크기를 읽는다. | 없음 |
| S8 | services/battle_movement_query_service.gd:44, :59 | 인자로 받은 grid 의 `is_in_bounds` | 문제 없음 | 크기를 읽는다. | 없음 |
| S9 | presentation/iso/battle_iso_production_controller.gd:21-29, :133-153 | 직교 컨트롤러로 시작 칸을 먼저 정하고 ISO 로 교체. 범위 밖 유닛은 경고 후 건너뜀 | 문제 없음 | 순서와 검사 모두 크기를 읽는다. | 없음 |
| S10 | battle/battle_production_controller.gd:144 | `get_tiles_in_range` 사용 | 문제 없음 | 크기를 읽는다. | 없음 |
| S11 | battle/battle_momentum_state.gd:6 `MAX_MOMENTUM := 10` | 기세 상한 | 무관 | 우연한 10. | 없음 |

`battle_setup_rules_service.gd`, `battle_enemy_tactic_rules_service.gd`, `battle_combat_query_service.gd`, `unit_type_contract.gd` 에서는 격자 크기 가정을 찾지 못했다.

## 3D 랩

`scripts/battle3d/`, `assets/battle3d/`

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| L1 | assets/battle3d/heightfield.json `board` | 18×10, cell 3.0, 높이 샘플 61×109, river_center 28.0, ford_row 5 | 깨짐 | 엔진만 바꾸면 3D 판은 18×10 그대로다. width/height 만 고치고 heights 를 안 늘리면 lab_heightfield.gd:38-41 에서 배열 범위를 넘는다. | Blender 에서 heightfield 재생성 |
| L2 | assets/battle3d/battlefield.glb | 지형 메시 54×30m | 깨짐 | 18열·10행 밖 칸에는 지형도 충돌체도 없다. | glb 재생성 |
| L3 | lab_heightfield.gd:13, :20 | SIZE 를 JSON 에서 읽음, `valid()` 경계 | 문제 없음 | 3D 쪽 원천이다. 스스로는 크기를 따른다. | 없음 |
| L4 | lab_heightfield.gd:56 | 숲 규칙이 미터 상수(`x<6 and z>11`, `x>W-12 and z<9`) | 어색함 | 60×60m 판에서 왼쪽 숲이 z 11~60 전체로 길게 늘어난다. 강 위치(28m)도 중앙이 아니게 된다. | 지형 규칙 재설계 |
| L5 | battle3d_grid_projection.gd:6-8 | 3D 격자 크기 = heightfield 크기(엔진 크기 아님) | 깨짐 | 엔진 20×20, 3D 18×10 이면 x≥18 또는 y≥10 칸 클릭이 (-1,-1) 이 된다. 둘을 비교하는 assert 가 없다. heightfield 도 20×20 으로 바꾸면 문제 없음. | 크기 일치 검사 추가 또는 원천 통일 |
| L6 | battle3d_engine_play.gd:131 (`queries.grid = engine grid`) + 위치는 `board.world()` | 이동 질의는 엔진 크기, 그리기는 heightfield 크기 | 깨짐 | 크기가 다르면 범위 밖 칸의 유닛·이동점이 지형 밖 허공에 그려진다. | L5 와 같음 |
| L7 | battle3d_engine_play.gd:157 | 창 제목 "18x10" | 어색함 | 문자열만 틀린다. | 제목을 SIZE 로 |
| L8 | battle3d_connect_lab.gd:90-91, :15 | `range(18)`, `range(10)`, 제목 "18x10" | 어색함 | 강 표시가 18열·10행까지만 나온다. 판이 더 작아지면 오히려 범위 밖 접근이 된다. | `board.SIZE` 로 교체 |
| L9 | lab_presentation.gd:8, :270 | 초기·HOME 초점 = 판 중앙(SIZE 사용) | 문제 없음 | 크기를 읽는다. | 없음 |
| L10 | lab_presentation.gd:10, :210-213, :252 | 직교 카메라 size 기본 60, 줌 20~70, 오프셋 (43,40,43)m | 어색함 | 54×30m 판에 맞춘 값이다. 60×60m 판은 기본 줌에서 다 안 보일 수 있고 최대 70 으로도 빠듯하다. | 줌 기본값·상한을 판 크기에서 계산 |
| L11 | lab_presentation.gd:152-161 | 격자선을 SIZE 로 그림 | 문제 없음 | 선 수만 늘어난다. | 없음 |
| L12 | lab_presentation.gd:62, :190 | 로그·부제 "%d × %d" | 문제 없음 | SIZE 를 읽는다. | 없음 |
| L13 | lab_presentation.gd:219-220, :280-281 | 이동(pan) clamp = 판 크기 | 문제 없음 | SIZE 를 읽는다. | 없음 |
| L14 | lab_demo_port.gd:6-9 | 데모 칸 (3,5),(4,2),(14,6),(15,2) | 문제 없음 | 20×20 안이다. 엔진 플레이에서는 `port.units.clear()` 로 비운다. | 없음 |
| L15 | battle3d_engine_host.gd:6 | 엔진용 SubViewport 1280×720 | 무관 | 렌더 크기다. 격자와 무관. | 없음 |
| L16 | lab_presentation.gd:46, :50 | 그림자 거리 100, camera.far 200 | 문제 없음 | 60m 판에도 넉넉하다. | 없음 |
| L17 | battle3d_movement_adapter.gd:13-21, battle3d_unit_adapter.gd | grid 를 인자로 받음, grid_cell 복사 | 문제 없음 | 크기를 하드코딩하지 않는다. | 없음 |

## 셸

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| H1 | scripts/battle3d/battle3d_scenario_shell.gd:103-107 | lab 의 grid 를 정리만 함. 나머지는 UI 좌표 | 문제 없음 | 격자 크기 가정이 없다. | 없음 |

## 씬

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| C1 | scenes/battle/Battle_Production.tscn:733-734 | `grid_width = 18`, `grid_height = 10` | 문제 없음 | 엔진 원천이다. 바꿀 곳이 바로 여기다. | 이 두 줄 |
| C2 | Battle_Production.tscn:2309-2312 | 보드 마커 (0,0)~(1920,1080) | 문제 없음 | 크기는 그대로 두고 칸만 작아진다(S6). | 칸을 키우려면 여기 |
| C3 | Battle_Production.tscn:2161-2262 | 유닛 마커 10개 픽셀 위치 | 어색함 | 시작 칸이 바뀐다. 18×10 → 20×20: 이순신 (3,8)→(3,17), 관우 (14,2)→(16,5), 증원 (3,9)→(3,19), (14,1)→(16,2). | 마커 재배치 또는 칸 데이터화 |
| C4 | Battle_Production.tscn:810 이후 `LogicalGridGuideLayer` | Line2D 세로 19개, 가로 11개(18×10 용) | 어색함 | 20×20 에는 21+21 개가 필요하다. 디버그가 꺼져 있어 평소엔 안 보인다. | 선 노드 추가 또는 코드 생성 |
| C5 | Battle_Production.tscn:983 이후 `MoveRangeCell_00..` | 범위 표시 풀 112개 | 문제 없음 | 사거리로 정해지는 수라 격자 크기와 거의 무관(E8). | 없음 |
| C6 | Battle_Land.tscn:658-659 | 옛 씬의 18×10 복사본 | 어색함 | 원천이 갈라진다. `t02_battle_context_smoke.gd`, `test_single_side_exhaustion_turn_order.gd` 가 이 씬을 쓴다. | 같이 바꾸거나 폐기 |
| C7 | tests/scenes/Battle_UI_Production_Test.tscn:726-727 | 테스트 씬의 18×10 복사본 | 어색함 | 원천이 갈라진다. `verify_battle_supply_hud_mock.gd` 가 쓴다. | 같이 바꾸기 |
| C8 | scenes/battle3d/*.tscn (3개) | 스크립트만 붙어 있음 | 문제 없음 | 크기·카메라 값이 씬에 없다. 모두 스크립트에서 만든다. | 없음 |

`_incoming/Battle_Land_BEFORE_T08_BACKUP.tscn` 같은 백업 파일은 범위에서 뺐다.

## 데이터

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| D1 | data/ 전체 | 배치·증원 좌표 없음 | 문제 없음 | 좌표는 씬 마커에 있다(C3). | 없음 |
| D2 | data/heroes/generated/hero_unique_skills.json | 고유기 range ≤5, radius ≤3 | 어색함 | 규칙은 그대로 돈다. 판이 2.2배라 기술이 덮는 비율이 줄어 밸런스가 달라진다. | 기획 판단 |
| D3 | data/heroes/generated/unit_type_rules.json | 이동력 2~4 | 어색함 | 시작 거리 17→25칸이라 접촉까지 2~3턴 더 걸린다. | 기획 판단 또는 배치 조정 |

## 테스트·골든

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| T1 | tests/golden/battle3d_m3_start_v0.json `layouts/default` | 기본 배치 칸 (3,8),(5,7)… | 깨짐 | 마커에서 나온 칸이 바뀐다(C3). | 골든 재생성 |
| T2 | tests/golden/battle_setup_port_base_v0.json | 기본 배치로 끝까지 싸운 해시(예: seed_1 11라운드 패배) | 깨짐 | 시작 칸과 거리가 바뀌어 전투 전체가 달라진다. | 골든 재생성 |
| T3 | test_battle3d_{defend,skill,strategy,wait}_default_round.gd, test_battle3d_reinforce_default_rounds.gd, test_battle3d_enemy_turn_default_layout.gd, test_battle3d_enemy_turn_manual.gd | "손대지 않은 기본 18×10 전투"와 T1 골든 비교. strategy 는 "어떤 아군도 닿지 못한다"는 거리 가정 | 깨짐 | 시작 칸·거리 가정이 바뀐다. | 테스트 기대값 재작성 |
| T4 | tests/scripts/test_battle_setup_port_base_parity.gd | T2 골든 비교 | 깨짐 | T2 와 같다. | 골든 재생성 |
| T5 | tests/scripts/test_battle3d_movement_parity.gd:71-72, :84 | 비교용 flat grid 를 18×10 으로 고정. 모서리 (17,9),(17,0) | 깨짐 | heightfield 를 20×20 으로 만들면 projection 과 flat 의 경계가 달라 가장자리 결과가 어긋난다. | `flat.grid_width = projection.grid_width` |
| T6 | tests/scripts/test_battle3d_oblique_click.gd:93 | 칸 총수 `==180` | 깨짐 | 400 이 된다. | SIZE.x*SIZE.y 로 |
| T7 | support/battle_enemy_turn_oracle_harness.gd:119-120, battle_enemy_strategy_oracle_harness.gd:74-75, battle_tactic_oracle_harness.gd:64, battle3d_enemy_turn_harness.gd:108-109, battle3d_enemy_strategy_harness.gd:13-14, battle_enemy_skill_{cap,rotation}_harness.gd, battle3d_enemy_skill_harness.gd:19, test_battle3d_skill_rejections.gd:99 | `(0,9)`,`(17,0)`,`(17,9)` 를 "먼 구석"으로 사용 | 어색함 | 20×20 에서도 범위 안이라 돈다. 하지만 더는 구석이 아니고 가장자리 효과가 사라진다. | 구석 칸을 크기에서 계산 |
| T8 | tests/golden/battle_{attack,move,enemy_turn,enemy_strategy,enemy_skill_spread,tactic}_*_v0.json | fixture 로 10유닛 칸을 모두 고정 | 어색함 | 대부분 판 중앙(y=4) 사례라 그대로일 가능성이 있다. 가장자리가 결과에 영향을 주는 사례는 달라질 수 있다. 실행 없이는 모른다. | 실행 후 판단 |
| T9 | tests/scripts/test_battle_movement_query_service.gd:16-17 | 자체 6×5 격자 | 문제 없음 | 본 격자와 독립. | 없음 |
| T10 | 위 T3 파일 2줄째 주석들, battle_ui_production_imjin_iso_movement_test.gd:6 | 주석 "18x10" | 문제 없음 | 주석만 틀린다. | 주석 |
| T11 | tests/scripts/test_battle3d_engine_move_integration.gd:79 | (17,9) 클릭을 사거리로 거부 | 문제 없음 | 20×20 에서도 사거리 밖이다. | 없음 |

## 검증기

| # | 파일:줄 | 가정 | 20×20 효과 | 이유 | 고칠 곳 |
|---|---|---|---|---|---|
| V1 | tools/validate_battle3d_contract.py:30, :32 | `assert (width,height)==(18,10)`, 메시지 "18x10 metadata" | 깨짐 | heightfield 를 바꾸면 바로 실패한다. | 기대값 갱신 |
| V2 | tools/validate_battle3d_m2_engine_attack.py, m3_enemy_turn, m3b_wait, m4a_defend, m4b_strategy, m4c1_skill, m4d_reinforce, validate_battle_enemy_events_s3_1.py, validate_battle_tactic_events_s4_1.py | 골든 SHA-256 고정(예: attack baseline `d018cb…`) | 깨짐 | 골든을 다시 만들면 해시가 달라진다. | 해시 재고정 |
| V3 | 위 battle3d 검증기들의 `PROTECTED` 목록(예: validate_battle3d_m3_enemy_turn.py:27-31, :98-99) | battle_web_import_test.gd, lab_presentation.gd 등 바이트 불변 | 어색함 | 각자 고정 BASE 와 비교하는 마일스톤 검증기다. 이 파일들을 고치면 다시 돌릴 때 걸릴 수 있다. 실제 비교 범위는 확인 못 했다. | 검증기 운영 방침 |
| V4 | validate_battle_s2_1_attack_baseline.py:56, validate_battle_enemy_events_s3_1.py:168, validate_battle_tactic_events_s4_1.py:240 `len(units)==10`, validate_battle3d_m4d_reinforce.py:56 ROSTER 정규식 6/8/10, validate_t06_t07_playable_transaction.py:84 `MAX_MOMENTUM := 10` | 유닛 수·기세 상한 | 무관 | 우연한 10. 격자와 무관. | 없음 |

검증기 90개 가운데 격자 크기를 직접 보는 것은 V1 하나뿐이다.

## 측정

- 런타임 측정은 하지 않았다. 정적 읽기와 grep 만 했다.
- 시작 칸 숫자(C3)는 마커 좌표와 `floor(x / (1920/w))`, `floor(y / (1080/h))` 로 손계산했다. 18×10 결과는 T1 골든의 `(3,8)`, `(5,7)` 과 맞았다.
- 나중에 읽기 전용 런타임 확인을 한다면 이렇게 할 수 있다.
  1. 작업 사본에서 `Battle_Production.tscn` 의 두 값만 20/20 으로 바꾼 임시 브랜치를 만든다(원본은 손대지 않음).
  2. headless Godot 로 `Battle_Main.tscn` 을 띄워 `battle_grid_controller.describe_grid()` 와 10유닛 `grid_cell` 을 출력만 한다.
  3. 같은 방식으로 3D 랩을 띄워 `projection.grid_width/height` 와 엔진 grid 크기를 나란히 출력한다. 불일치 여부만 본다.
  4. 기존 골든 테스트를 돌려 어느 것이 바뀌는지 목록만 뽑는다. 골든은 덮어쓰지 않는다.
  5. ISO 칸 픽셀 크기와 토큰 크기를 스크린샷 한 장으로 비교한다.

## 확인 못 한 것

- 전투 배경 그림 `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png` 에 18×10 격자나 지형이 그려져 있는지. 그려져 있다면 20×20 에서 어긋난다.
- 증원 배치(E2) 때 마커가 이미 ISO 칸으로 옮겨진 상태인지, 실제로 어떤 칸이 나오는지.
- fixture 기반 골든(T8)이 20×20 에서 바뀌는지. 실행이 필요하다.
- 3D 카메라 기본 줌 60 으로 60×60m 판이 다 보이는지(L10). 화면 계산만으로는 단정하지 않았다.
- `PROTECTED` 검증기(V3)가 지금도 정기적으로 돌고, 무엇과 비교하는지.
- 2D 카메라의 줌·인트로 연출(battle_web_import_test.gd:2299-2398)이 보드 크기와 묶여 있는지 깊게 보지 않았다. 보드 픽셀 크기는 그대로라 영향은 작다고 봤다.
- `agent/*.md` 문서 속 "18x10" 표기는 코드가 아니라 범위에서 뺐다.
- 판이 커질 때 적 AI 의 판단 품질(목표 선택, 우회)이 어떻게 변하는지는 정적으로 판단하지 않았다.
