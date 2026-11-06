기준 화면: 새 가지 `feature/wm3d-bake-20261106`(시작 `origin/main` `ab9b739`)에서 `res://WorldMap.tscn`(F6)이 3D 지도를 같은 모양으로 띄우되, 도로·바닷길 경로 계산(지금 약 4초)이 미리 구운 파일을 읽는 것으로 바뀌어 시작이 그만큼 빨라진다. 화면(도로·바닷길 위치와 모양)은 지금과 **똑같다**.
합격 기준: 보고서에 ① 같은 방법으로 잰 전후 시간(PERF2 방법, 임시 사용자 폴더) ② 구운 경로 == 실시간 계산 경로(칸 번호 완전 일치, 13 도로 + 5 바닷길) ③ 구운 파일이 없거나 입력이 바뀌면 지금처럼 실시간 계산으로 되돌아감을 보이는 테스트 ④ 기존 3D 테스트(`test_worldmap3d_roads` 121/0 등) 변화 없음. 최종 확인은 김작 F6(길이 같은 모양인지, 시작이 빨라졌는지).

# ORDER_WM3D_PERF3_BAKE_PATHS — 도로·바닷길 경로 미리 굽기 (클코치 작성, 2026-11-06)

## 0. 배경·효력
- PERF2 보고서(`agent/REPORT_WM3D_PERF2_20261106.md`, 가지 `feature/wm3d-perf-20261106` `22c8f70`)의 [사실]: 3D 시작 13.1초 중 도로 경로 2.93초·바닷길 1.07초이고, 그중 **199만 칸을 GDScript로 한 칸씩 도는 반복이 2.63초·0.82초**, 실제 A* 탐색은 0.28~0.31초·0.25초다. 이 계산의 입력(높이 격자 파일, 도시 위치, 규칙 JSON의 도로·바닷길 목록)은 모두 고정이고, 실행 중 다시 계산하는 호출처도 없다(`set_marker_position(…, rebuild_roads)` 호출처 0건).
- **근본 원인**은 "게임마다 똑같은 결과를 매번 처음부터 계산"이다. 땜질(반복을 조금 빠르게 쓰기)이 아니라 **결과를 구워 읽는 것**으로 푼다. 예상 절감 약 4초(2.63 + 0.28 + 0.82 + 0.25 ≈ 4.0, [추정] 읽는 시간 제외, 이번에 실제로 잰다).
- 큐 규칙(4·5·10절) 그대로. 새 가지 `feature/wm3d-bake-20261106`(시작 `origin/main` `ab9b739`)에만 push. `main`·다른 가지 push 금지. 이 지시서는 INTEGRATE(21번)와 **독립**이다(다른 가지).

## 1. 먼저 읽기 전용으로 확인 (보고서 표)
1. `worldmap3d/scripts/worldmap_roads.gd`의 `build_paths`·`build_sea_paths`·`_nearest_sea_cell`·`_chaikin`: 클코치가 읽은 [사실] — `build_paths`는 격자 전체에서 `h <= 2.0`이면 solid, 아니면 `weight_scale = 1 + 경사*60 + h/500`을 설정하고, 링크마다 `get_id_path`(격자 칸 번호 배열)를 얻은 뒤 `_chaikin` 4번으로 매끈하게 한다. `build_sea_paths`는 `h > 2.0`을 solid로 하고 도시마다 가장 가까운 열린 바다 칸을 찾는다. **A*의 출력은 칸 번호 목록이고, 매끈하게 하는 단계는 그 뒤에 따로 돈다.**
2. 입력 목록: ⓐ 높이 격자 `worldmap3d/maps/eastasia/terrain/heightgrid_f32.bin`(1729×1153) ⓑ `city_xz`(마커 표시 위치, `markers.json`에서 `worldmap3d_root.gd`가 만든다. 어느 코드가 어떤 값으로 만드는지 확인) ⓒ `rules.roads`(링크 13개)·`rules.sea_routes`(5개) ⓓ 상수(`SEA_MAX_M`, `SEA_SEARCH_CELLS`, `OPEN_SEA_MIN_CELLS`, 가중치 식) ⓔ 격자 크기 `gw`·`gh`·`width_km`.
3. 호출처: `worldmap3d_root.gd:341~371`(`_build_roads`, 바닷길 쪽). `set_marker_position`(557행)이 다시 부르는 경로가 있는가(PERF2는 호출처 0건이라 했다. 직접 `grep`으로 확인).
4. 다른 지도(`dummy13`)와 시험 장면이 같은 코드를 쓰는지. **굽는 것은 `eastasia`만**, 다른 지도는 지금처럼 실시간 계산으로 남는다.

## 2. 해야 할 일
### 2-A. 굽기
1. **굽는 것은 A*의 칸 번호 경로**(링크마다 `Array[Vector2i]`; 바닷길은 시작·끝 바다 칸 포함)이고, **매끈하게 하는 단계(`_chaikin`)·도시 연결선·리본 메시는 지금처럼 실행 중에 돈다**(그래야 결과가 정수 비교로 완전 일치).
2. 저장 파일: `worldmap3d/maps/eastasia/baked_paths.json`(새 폴더 없음). 내용: `{version, key, roads: [{link:[a,b], cells:[[i,j],…]}], sea_routes: [{link:[a,b], cells:[…]}]}`. `key`는 **무효 판정용 값**: 입력 ⓑⓒⓓⓔ(도시 위치는 소수 3자리로 반올림, 링크 목록, 상수, `gw`·`gh`·`width_km`)와 높이 격자 파일의 크기를 이어 붙인 문자열의 해시(SHA-256).
3. 굽는 도구 `tools/bake_worldmap3d_paths.gd`(`godot --headless --script`로 실행하는 한 파일): 실시간 계산(현재 코드 그대로)을 돌려 칸 번호를 뽑아 위 파일로 쓴다. 도구는 **실시간 계산 코드를 그대로 재사용**한다(복제 금지).

### 2-B. 읽기 (`worldmap_roads.gd`)
1. `build_paths`·`build_sea_paths`가 시작할 때 구운 파일이 있고 `key`가 지금 입력과 **같으면** 칸 반복과 A* 탐색을 건너뛰고 구운 칸 번호로 이어서(매끈하게 하기 이후는 기존 코드) 진행한다.
2. 파일이 없거나 `key`가 다르면 **지금 방식 그대로 실시간 계산** + `push_warning`(한 줄). 결과는 절대 틀리지 않아야 한다(구운 것이 낡았으면 항상 실시간으로 되돌아간다).
3. 공개 인터페이스(`paths`·`sea_paths`·`sea_links`)와 `worldmap3d_root.gd` 호출 방식은 바꾸지 않는다. 바꿔야 하면 가장 작게(예: `build_paths(geo, city_xz, links, baked := {})`의 선택 인자) 하고 보고서에.

### 2-C. 테스트 (새 파일 `tests/scripts/test_worldmap3d_baked_paths.gd`(+`.uid`) + CI 목록 1줄)
- ⓐ **일치**: 구운 파일의 13 도로·5 바닷길 칸 번호가 실시간 계산 결과와 **완전 일치**(길이·각 칸 모두). `paths`·`sea_paths` 최종 점 목록(`_chaikin` 뒤)도 구운 경로 사용 시와 실시간 시가 완전 일치.
- ⓑ **낡음 감지**: 도시 위치를 1칸 옮기거나 링크 하나를 빼면(테스트 안에서만 입력 변경) `key`가 달라져 실시간 계산으로 돌아가고 경고가 난다.
- ⓒ **파일 없음**: 구운 파일을 가린 채(테스트용 경로 지정 또는 임시 이름) 실행하면 지금과 같은 결과.
- ⓓ **구운 파일 최신성**: 현재 입력으로 새로 구운 결과와 저장소의 `baked_paths.json`이 같다(입력을 바꾸고 다시 굽는 것을 잊으면 CI가 빨개진다).
- 기존 3D 테스트(`test_worldmap3d_roads.gd` 등) 기대값은 바꾸지 않는다.

### 2-D. 시간 측정 (PERF2와 같은 방법)
- 같은 PC에서 **구운 파일 사용 전/후** 각 5회(창 렌더 + headless), 1회째와 2~5회 중앙값을 분리. 단계 `도로 경로`(10)·`바닷길 경로`(12)와 CSV 방식 `build_ms`. 임시 사용자 폴더 사용(김작 `user://` 건드리지 않음).
- 구운 JSON 파일 크기와 읽는 시간(ms)을 보고서에.

### 2-E. 읽기 전용 시험 (코드 커밋 없음, 보고서에만)
- 지형 메시(2.16초)·강 메시(1.04초)를 `ArrayMesh`로 구워 `.res`로 저장했을 때 **파일 크기와 읽는 시간**을 임시 폴더에서 재본다(지형 삼각형 2.64M, 강 405k). 파일이 너무 크거나(예: 수십 MB 이상) 읽는 시간이 계산보다 느리면 굽기가 이득이 아니다. 숫자만 보고한다. 이 파일은 **커밋하지 않는다.**

## 3. 하지 말 것
- 지형·강 굽기 구현 금지(2-E는 측정만). 스레드·로딩 화면·2D 선행 표시 금지(별도 지시서).
- `worldmap_main.gd`·씬·설정 파일 수정 금지. 도로·바닷길의 **모양을 바꾸는** 어떤 변경도 금지(결과 완전 일치가 합격 조건).
- 테스트 기대값 완화 금지. 다른 지도(`dummy13`) 동작 변경 금지.

## 4. 수정·추가 경로 (이것이 전부)
- 수정: `worldmap3d/scripts/worldmap_roads.gd`, (필요 시 가장 작게) `worldmap3d/scripts/worldmap3d_root.gd`, CI 테스트 목록(1줄)
- 추가: `worldmap3d/maps/eastasia/baked_paths.json`, `tools/bake_worldmap3d_paths.gd`(+`.uid`), `tests/scripts/test_worldmap3d_baked_paths.gd`(+`.uid`), `agent/REPORT_WM3D_PERF3_20261106.md`, `agent/evidence/perf3_*.txt`
- 그 밖은 멈춤.

## 5. 합격 기준 (자동)
새 테스트 전부 통과 + 기존 `worldmap3d` 테스트·검증기 변화 없음 + push 후 C-track 4 shard·`Verify WorldMap3D` success + 2-D 측정표가 보고서에 있고 `도로 경로`+`바닷길 경로` 합이 줄었다.

## 6. 보고서
맨 위 두 줄 + 1절 확인 표 + 바꾼 것 요약 + 구운 파일 설명(`key`가 무엇으로 만들어지는지) + 2-C 결과 원문 + 2-D 전후표 + 2-E 시험 숫자 + 택한 해석 + 김작 F6 확인 목록(길이 이전과 같은 모양인지 두 번 비교: 도로 13개, 바닷길 5개).
