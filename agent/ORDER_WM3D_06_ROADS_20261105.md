기준 화면: 정본 가지 `feature/wm3d-intake-20261101`에서 ① `res://WorldMap3D_Host_Test.tscn`(3D) F6 → 육로 13개·해로 5개가 지도 위에 보인다 ② `res://WorldMap.tscn`(2D) F6 → 성도–건업 길이 새로 보여 길이 18개가 된다. 두 화면의 길 연결이 같은 쌍이다.
합격 기준: 김작 F6 — 3D에서 길 18개가 보이고(육로 13 + 해로 5), 해로는 바다 위로만 지나며, 선이 확대·축소 때 끊기지 않고 2px 이상으로 읽히고, 2D의 길 18개와 같은 도시 쌍을 잇는다. 도로를 켜도 체감상 끊김이 없다. 자동 조건: 새 길 일치 테스트 통과, 올린 커밋에서 `Verify C-track refactor` 4 shard와 `Verify WorldMap3D` success.

# 지시서 — T-WM3D-06: 3D 도로·해로 켜기 + 성도–건업 육로를 2D에도 추가 (길 18개 통일)

- 작성: 클코치, 2026-11-05 10:30 / 김작 결정: 11-05 10:2x "18개로 통일" (성도–건업 육로를 2D에도 추가, 게임 규칙·`neighbors`는 바꾸지 않음)
- 시작 HEAD: `367ad63` 또는 그 이후(`feature/wm3d-intake-20261101`). 05 F6는 김작 합격(11-05 09:50).
- 근거([사실], 원격 `367ad63` 대조):
  - 2D `WorldMap.tscn` `RouteLayer`의 Route 노드는 17개(육로 12 + 해로 5, `route_type = "sea"` 5개). 성도–건업 Route 노드는 없다.
  - 그런데 2D 마커 `neighbors`에는 성도 `["luoyang","jianye"]`(845행), 건업 `["luoyang","chengdu","yecheng","sabi"]`(881행)로 서로 들어 있고, `neighbors`는 `worldmap_main.gd`·`military_controller.gd`·`trade_controller.gd`가 읽는다. 즉 게임 규칙상 이미 이웃인데 길만 안 그려져 있다.
  - 3D `rule_data_eastasia.json`: `roads` 13개(성도–건업 포함) + `sea_routes` 5개 = 18. 해로 5쌍은 2D와 같다(경주–교토, 경주–오사카, 건업–사비, 큐슈–오사카, 큐슈–사비).
  - 3D 육로는 `worldmap3d_root.gd` `_build_roads()`(323행~)가 `WorldMapRoads.build_paths`(A*, 바다·급경사 회피 + Chaikin 4회)로 만들지만, `worldmap3d/scenes/worldmap3d_eastasia.tscn` 13행 `show_roads = false`라 **지금은 아예 안 만든다**(꺼 둔 이유는 [미확인], 1절에서 조사).
  - 3D 해로는 **그리는 코드가 없다**: `_build_roads()`는 `WorldMapRibbons.build(geo, roads.paths, [], 0.8)`로 육로만 그리고 `rules.sea_routes`를 쓰는 곳이 없다(2절에서 확인).
  - 2D `worldmap_route_path.gd` 15~16행: `LAND_ROUTE_COLOR := Color(0.86, 0.62, 0.32, 0.72)`, `SEA_ROUTE_COLOR := Color(0.55, 0.82, 1.0, 0.48)`, 너비 육로 4.5·해로 2.5. 3D 길 색은 이 값에 맞춘다(계획서 §3-7-2).
  - `ArmyLayer`·`EffectLayer`는 `WorldMap.tscn`에 빈 노드로만 있고 스크립트에서 참조가 없다([사실], `rg` 0건). 3D에서 2D 루트를 숨겨도 잃는 것이 없다.

## 0. 규칙

1. 시작 전 `git status` 깨끗, `git log -1`이 `367ad63` 이후인지 확인. 아니면 멈춤.
2. **`scripts/worldmap/worldmap_main.gd` 수정 금지**(pinned 검사기). `neighbors`·`route_types` 데이터와 게임 규칙 스크립트 수정 금지.
3. 수정·추가 파일은 **아래 5절의 경로뿐**. 새 폴더 금지. 다른 곳을 고쳐야 할 것 같으면 멈추고 보고.
4. `WorldMap.tscn`은 **텍스트로만** 고친다(Godot 에디터로 열어 저장 금지). 변경은 새 `sub_resource` 1개 + 새 Route 노드 블록 1개(자식 Path2D·Line2D 포함) 추가가 전부여야 한다(헤더 `load_steps`가 있으면 맞춰서 +1).
5. push는 `feature/wm3d-intake-20261101` 하나, force 없음, 검증 통과 후에만(김작 사전 승인). 보호 가지 금지. `gh`는 읽기 명령만.
6. 코드 커밋 push → CI 확인 → 보고서 커밋 push(`[skip ci]`) 순서, 합치지 않음. 보고서: `agent/REPORT_WM3D_06_20261105.md`.
7. 1절 조사 결과가 이 지시서의 전제와 다르면(특히 [사실]로 적은 것) 추정으로 진행하지 말고 멈추고 보고.

## 1. 먼저 읽기 전용으로 확인 (결과를 보고서 표로)

1. **`show_roads = false`의 이유:** `git log -S"show_roads" -- worldmap3d/scenes/worldmap3d_eastasia.tscn worldmap3d/scripts/worldmap3d_root.gd`와 그 커밋 메시지·`worldmap3d/` 안 README·`bake_meta.json`·`map_config.json` 설명에 이유가 있는지. 없으면 "[미확인]".
2. **데이터 흐름:** `rules.roads`와 `rules.sea_routes`가 어디서 읽혀 어디에 저장되는지(`worldmap_config.gd` 등, 파일·줄). `sea_routes`를 쓰는 코드가 0곳임을 `rg`로 확인.
3. **해수면 높이:** `_build_sea()`(263행~)의 바다 평면 높이(y)와 `geo`가 바다 격자 높이를 어떻게 다루는지(`grid_height_m ≤ 2.0` = 바다 기준과 같은지). 해로 리본을 바다 위에 놓는 데 필요한 값을 파일·줄과 함께 적는다.
4. **`WorldMapRibbons.build` 높이:** `y = geo.mesh_height_at(p) + lift_km`이라 바다 밑 지형을 따라가면 리본이 물 아래에 묻힐 수 있는지. 묻힌다면 아래 2-2의 `floor_y` 방식이 필요한지.
5. **2D 길 조회:** 2D에서 Route 노드를 찾아 쓰는 코드(군대 이동 등)가 `start_city_id`/`end_city_id`로 찾는지, 노드가 없으면 무엇을 하는지(`rg "route_id|start_city_id|RouteLayer" scripts`). 성도–건업 노드를 추가하면 달라지는 2D 동작이 있으면 표로(좋은 변화인지 [추정]으로 판단 포함).
6. **2D 길 개수를 단언하는 곳:** `rg -n "17|RouteLayer|Route_" tests tools .github`로 길 17개·Route 노드 이름·개수를 검사하는 테스트·검증기가 있는지. 있으면 어느 파일 몇 줄인지 표로 — 있으면 멈추고 보고(5절 밖이면 임의로 고치지 않음).
7. **성능 측정 수단:** 3D 테스트 HUD(`worldmap_test_hud.gd`)·`tools/perf_bench.gd` 등에 FPS 표시·벤치가 있는지(파일명·사용법). 헤드리스로 못 재면 그렇다고 적는다.

## 2. 3D 쪽 (`worldmap3d/`)

### 2-1. 육로 켜기
- `worldmap3d/scenes/worldmap3d_eastasia.tscn` 13행 `show_roads = false` → `true`. (`worldmap3d_eastasia_v2_3_test.tscn` 등 다른 장면은 건드리지 않는다.)
- `_build_roads()`의 길 재질을 2D 색에 맞춘다: `core_color` = `Color(0.86, 0.62, 0.32)`(2D `LAND_ROUTE_COLOR` rgb), `edge_color` = 같은 색을 어둡게(예 `Color(0.45, 0.30, 0.14)`), `opacity` 0.85 안팎, `width_km`·`min_px 2.0`은 유지. 정확한 값은 F6에서 김작이 읽히는지 보고 조정할 수 있으니 상수 한 곳(파일 위쪽 `const`)로 모아 둔다.

### 2-2. 해로 새로 그리기 (`worldmap_roads.gd`에 `build_sea_paths`, `worldmap3d_root.gd`에 `_build_sea_routes()`)
- 방식(바다 위로만 지나게, 3D 격자 기준): 바다 칸(`grid_height_m ≤ 2.0`)만 걷는 A* — 육로 A*의 반대(육지가 solid). 출발·도착은 두 도시에서 **가장 가까운 바다 칸**(반경을 넓혀 가며 찾기)이고, 도시와 그 바다 칸 사이는 짧은 직선으로 잇는다. 경로는 `_chaikin` 4회로 부드럽게. 바다 칸을 못 찾거나 경로가 없으면 오류를 찍고 그 해로만 건너뛴다(전체를 죽이지 않음).
- 그리기: `WorldMapRibbons.build`를 쓴다. 해수면 아래로 묻히지 않게 1절 4번에서 확인한 방식으로 높이를 바다 위에 맞춘다(예: `build`에 기본값이 있는 선택 인수 `floor_y`를 추가해 `y = maxf(mesh_height, floor_y) + lift`; 기본값이면 기존 호출 결과가 바이트 단위로 같아야 한다). 재질은 육로와 같은 `worldmap_ribbon.gdshader`, 색 `Color(0.55, 0.82, 1.0)`(2D `SEA_ROUTE_COLOR` rgb), `min_px 2.0`, 너비는 육로보다 좁게(2D 2.5/4.5 비율), `opacity` 0.6 안팎, `render_priority`는 육로와 겹침이 없게.
- `rules.sea_routes`(5쌍)를 그대로 쓰고, `show_roads`가 true일 때만 만든다(`set_marker_position(…, rebuild_roads)`가 해로도 다시 만들게 한다).
- 통계: `stats.road_tris`와 별개로 `stats.sea_route_tris`, `stats.sea_route_count`, `stats.road_count`, `stats.sea_build_ms`를 남긴다(기존 `build` 로그 한 줄에 붙이되 기존 필드 순서·이름은 안 바꾼다).

### 2-3. 길 품질 보고(고치지는 말 것)
육로 13개·해로 5개 각각의 경로 길이(km)와 직선 거리 대비 배수를 표로. 배수가 1.6을 넘거나(우회가 큼) 카라코룸 육로 2개(업성·평양, 약 1,300km 고비)에 이상이 있으면 어느 길인지 적고, 이번에는 고치지 않는다(김작 F6 판단).

## 3. 2D 쪽 — 성도–건업 육로 추가 (`WorldMap.tscn`, 텍스트 편집)

- 기존 `Route_Luoyang_Chengdu`(315~328행)와 **같은 구조**로 `Route_Chengdu_Jianye`를 `RouteLayer` 아래에 추가: `script`·`route_id = "Route_Chengdu_Jianye"`·`start_city_id = "chengdu"`·`end_city_id = "jianye"`(`route_type` 없음 = 육로), 자식 `Path2D`(curve = 새 `Curve2D_route_chengdu_jianye`)와 `Line2D`(`width = 4.5`, `default_color = Color(0.86, 0.62, 0.32, 0.72)`).
- 새 `Curve2D` 점 3개(기존 육로와 같은 3점 형식, 핸들 0): 시작 성도 `(408.5, 730.5)`, 가운데 `(681.75, 705)` 안팎, 끝 건업 `(955, 670)`. 가운데 점은 다른 길(낙양–성도, 낙양–건업)과 **교차하지 않게** 선택하고(교차 여부를 직접 계산해 보고), 직선 중점 `(681.75, 700.25)`에서 아래쪽으로 조금만 휘게 한다. `Line2D.points`는 기존 육로가 베이크된 점을 갖고 있으나 런타임 `_refresh_route_line`이 다시 계산하므로 **시작·가운데·끝 점을 직선으로 이은 간단한 점 목록**으로 쓰고, 런타임에 덮어써지는지 확인한다.
- `unique_id`는 기존 값과 겹치지 않는 임의 값. 노드 이름·`route_id` 철자는 기존 `Route_<A>_<B>` 규칙(예 `Route_Luoyang_Chengdu`).
- `RouteTypeLabel`·도시 패널이 길 종류를 읽는 곳(`route_types` 사전)은 육로가 기본값이라 바꿀 것이 없다(1절 5번에서 확인한 대로).

## 4. 새 테스트 `tests/scripts/test_worldmap3d_roads.gd` (+ `.gd.uid`)

`verify-worldmap3d.yml`이 `tests/scripts/test_worldmap3d_*.gd`를 자동 실행한다. 끝에 `[WM3D_ROADS] checks=N failures=[...]` 한 줄, 실패 시 `quit(1)`.

1. **길 쌍 일치:** `WorldMap.tscn` 텍스트의 Route 노드 18개(`start_city_id`/`end_city_id`/`route_type`)를 파싱해, 3D `rule_data_eastasia.json`의 `roads`(13, 육로)·`sea_routes`(5, 해로)와 **쌍 집합이 같고 종류도 같음**(도시 순서 무관). 개수 18 == 13 + 5.
2. **neighbors 일치:** `WorldMap.tscn` 마커 13개의 `neighbors`에서 만든 무방향 쌍 집합 == 위 Route 18쌍(길 없는 이웃·이웃 없는 길이 없다).
3. **3D가 실제로 만든 것:** `worldmap3d_eastasia.tscn`을 헤드리스로 로드해(기존 3D 테스트의 로드 방식을 따른다) `roads.paths.size() == 13`, 해로 경로 수 == 5, `stats.road_tris > 0`, `stats.sea_route_tris > 0`. 장면 로드가 헤드리스에서 안 되면 `worldmap_geo.gd`·`WorldMapRoads`만 따로 만들어 같은 검사를 하고 그렇게 한 이유를 보고.
4. **바다 위로만:** 해로 경로의 모든 점 중 두 끝 도시와의 직선 구간(도시와 가장 가까운 바다 칸 사이)을 뺀 점이 `grid_height_m ≤ 2.0`(바다) 칸에 있다. 육로 점은 `> 2.0`(육지) 칸에 있다(끝점 허용 오차는 주석으로 명시).
5. **높이 인수 호환:** `WorldMapRibbons.build`에 `floor_y`를 추가했다면 기본값 호출이 기존과 같은 메시(정점 수·인덱스 수 동일)를 만든다.

## 5. 수정·추가 경로 (이 목록이 전부, 새 파일은 테스트와 그 `.uid`뿐)

1. `WorldMap.tscn`
2. `worldmap3d/scenes/worldmap3d_eastasia.tscn`
3. `worldmap3d/scripts/worldmap3d_root.gd`
4. `worldmap3d/scripts/worldmap_roads.gd`
5. `worldmap3d/scripts/worldmap_ribbons.gd` (2-2에서 `floor_y`가 필요할 때만)
6. `tests/scripts/test_worldmap3d_roads.gd`
7. `tests/scripts/test_worldmap3d_roads.gd.uid`

목록 밖이 `git status --short`에 나오면 멈추고 보고. `WorldMap.tscn`을 고쳤으므로 3D CI `paths`에는 이미 `WorldMap.tscn`이 있어(05) 별도 워크플로 수정은 없다.

## 6. 로컬 검증 (매번 `godot --headless --path . --script …`, 결과 줄 원문을 표로)

1. 새 테스트를 **먼저(코드 변경 전) 돌려서** 실패하는지 확인(1·2번 검사가 2D 17개 때문에 실패해야 정상), 코드 변경 후 `failures=[]`.
2. 기존 3D 테스트 전부(`tests/scripts/test_worldmap3d_*.gd`): 어댑터 48, 카메라 50, 외부 입력 20, 호스트 38, 색 일치 57 등 변화 없음.
3. 정적 검증기: C-track "Static validators" 72개 전체. `validate_worldmap_trade_phase2_extraction.py`는 `.tscn`이 커밋 전 작업 트리에 있으면 실패하는 구조(67~68행, 05 보고서 확인)이므로 **커밋 뒤 깨끗한 트리에서** 다시 돌려 통과를 확인.
4. `WorldMap.tscn`을 로드·인스턴스하는 기존 테스트(`test_worldmap_diplomacy_controller_extraction.gd`, `test_worldmap_battle_main_roundtrip_settlement.gd`, `test_worldmap_to_battle_input_lifecycle.gd`)를 고치기 전/후 모두 돌려 결과가 같은지 표로(뒤의 둘은 고치기 전에도 같은 오류로 실패하던 기존 문제). 새 실패가 생기면 멈춤.
5. `--quit-after 5 res://WorldMap.tscn`과 `res://WorldMap3D_Host_Test.tscn`: 오류 줄 0.
6. `git diff --stat`: `WorldMap.tscn`은 추가만(삭제 줄 0 또는 `load_steps` 1줄), `worldmap_main.gd` 변경 0, 5절 목록만.
7. 2-3 길 품질 표, 1절 조사 표.

## 7. 커밋·push·CI

1. 커밋 1: `feat(worldmap): 3D roads and sea routes on, Chengdu-Jianye road added in 2D (18 roads, T-WM3D-06)`
2. `git push origin feature/wm3d-intake-20261101`, 원격 해시 = 로컬 HEAD.
3. `gh run watch`(읽기)로 `Verify C-track refactor`(4 shard)와 `Verify WorldMap3D`가 끝날 때까지 기다리고 결과·단계·`[WM3D_ROADS]` 줄 원문을 적는다. 실패하면 **고치지 말고** 실패 단계·오류 줄(앞뒤 5줄)을 보고. shard 0의 컷인 줄(`[CUTIN] 3D cut-ins`, `observe lag ms`, `checks=`)과 첫 컷인 fps는 결과와 무관하게 **항상 보고**(60fps 이상이면 표시).
4. 그 다음 보고서 커밋(`[skip ci]`).

## 8. 보고서 (`agent/REPORT_WM3D_06_20261105.md`)

1. 맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약(결과 / 자동 검증 / 김작이 할 일).
2. "택한 해석" 줄.
3. 1절 조사 표, 6절 결과 표, 길 품질 표, 바뀐 부분 diff(코드·`WorldMap.tscn` 추가분 전체), CI 표.
4. 막힌 것(없으면 "없음").
5. **김작 F6 안내(그대로 옮길 것):** ① `res://WorldMap3D_Host_Test.tscn` F6 → 길이 보이는지: 육로(주황 선) 13개, 해로(하늘색 선) 5개 ② 해로가 육지를 가로지르지 않고 바다 위로만 가는지(경주–교토·경주–오사카·사비–큐슈·사비–건업·오사카–큐슈) ③ 확대·축소·회전해도 선이 끊기거나 깜빡이지 않는지, 멀리서도 2px 이상으로 읽히는지 ④ 성도–건업 육로가 보이는지 ⑤ 카라코룸 길 2개가 이상하게 돌아가지 않는지 ⑥ 도로를 켜도 끊김이 느껴지지 않는지 ⑦ `res://WorldMap.tscn`(2D) F6 → 성도–건업 길이 새로 보이고 다른 길과 겹치지 않는지, 길 개수가 18개로 보이는지.
6. 종료 루틴 5줄: ① 정본 `git status`·가지·HEAD ② 새로 만든 것 ③ push한 것 ④ CI ⑤ 김작이 결정할 것.

## 9. 하지 않는 것

- `worldmap_main.gd`·`neighbors`·`route_types`·게임 규칙 수정, `WorldMap.tscn` 에디터 저장, 전투 진입·VRAM(07), 프로덕션 전환(08), 길 모양을 손으로 다듬기(2-3은 보고만), 컷인 테스트 수정(관찰만), 테스트 통과를 위한 허용 오차 완화, 재실행으로 때우기.
