기준 화면: 새 가지 `feature/wm3d-bake-20261106`(시작 `origin/main` `ab9b739`)에서 `res://WorldMap.tscn`(F6)이 3D 지도를 같은 모양으로 띄우되, 도로·바닷길 경로 계산(지금 약 4초)이 미리 구운 파일을 읽는 것으로 바뀌어 시작이 그만큼 빨라진다. 화면(도로·바닷길 위치와 모양)은 지금과 **똑같다**.
합격 기준: 보고서에 ① 같은 방법으로 잰 전후 시간(PERF2 방법, 임시 사용자 폴더) ② 구운 경로 == 실시간 계산 경로(칸 번호 완전 일치, 13 도로 + 5 바닷길) ③ 구운 파일이 없거나 입력이 바뀌면 지금처럼 실시간 계산으로 되돌아감을 보이는 테스트 ④ 기존 3D 테스트(`test_worldmap3d_roads` 121/0 등) 변화 없음. 최종 확인은 김작 F6(길이 같은 모양인지, 시작이 빨라졌는지).

# REPORT_WM3D_PERF3 — 도로·바닷길 A* 경로 미리 굽기 (클코드, 2026-11-06)

## 요약
- [사실] 3D 시작(정식 `WorldMap.tscn`, 창 렌더, 2~5회 중앙값) **13.05초 → 9.11초 (−3.94초)**. headless 12.17 → 8.07초(−4.10초).
- [사실] 도로+바닷길 단계 합 4.43초 → 0.45초. 구운 칸 번호는 실시간 A*와 **13 도로 + 5 바닷길, 4530칸 모두 같고**, 매끈하게 한 최종 점 목록도 완전히 같다.
- [사실] 구운 파일이 없거나 입력이 바뀌면 경고 한 줄과 함께 실시간 A*로 돌아가고, 결과는 실시간 계산과 같다(테스트 105/0).
- 커밋: 코드 `cb121b0`, 보고서·증거 이 커밋.
- **멈춤**: C-track shard 0이 알려진 `[CUTIN]` 길이 검사로 빨개져 합격 기준 1개를 못 채움(7절, `REPORT_WM3D_PERF3_STOP_20261106.md`).

## 1. 먼저 확인 (읽기 전용)
| 항목 | 확인 결과 |
|---|---|
| `build_paths` | [사실] 클코치 설명과 같음: `h <= 2.0` solid, 아니면 `1 + 경사*60 + h/500`, 링크마다 양 끝 칸을 열고(`set_point_solid(…, false)`, **다음 링크에도 열린 채 남음**) `get_id_path` → 끝점은 도시 좌표 그대로, 가운데는 칸 중심 → `_chaikin` 4번. 길이 없으면 `[a, b]` |
| `build_sea_paths` | [사실] `h > 2.0` solid, 도시마다 `_nearest_sea_cell`(반경 80칸, 5000칸 이상 열린 바다만), `get_id_path`, 바다 부분만 `_chaikin` 4번, 앞뒤에 도시 좌표. 실패 3종은 `push_error` 후 건너뜀 |
| A*의 출력 | [사실] 칸 번호 배열. 매끈하게 하기는 그 뒤 별도 단계 |
| ⓐ 높이 격자 | `worldmap3d/maps/eastasia/terrain/heightgrid_f32.bin` 7,974,148 바이트, `grid_size` 1729×1153 (`map_config.json` `height.grid_size`) |
| ⓑ `city_xz` | [사실] `worldmap3d_root.gd` `_ready`(93행, 이 가지 기준): `markers.json`의 `markers[cid].x_km / z_km` → `marker_xz`. 이것이 `_build_roads`·`_build_sea_routes`에 그대로 들어간다 |
| ⓒ 링크 | `rule_data_eastasia.json` `roads` 13개, `sea_routes` 5개 (루트의 `rule_data_path` 덮어쓰기도 같은 `rules`로 들어옴) |
| ⓓ 상수 | `SEA_MAX_M 2.0`, `SEA_SEARCH_CELLS 80`, `OPEN_SEA_MIN_CELLS 5000`, 땅 solid 2.0, 가중치 식, 대각선 규칙, 유클리드 휴리스틱 |
| ⓔ 격자 | `gw 1729`, `gh 1153`, `width_km 5549.823`, `height_km 3699.882` (`size_km`) |
| 호출처 | [사실] `worldmap3d_root.gd` `_build_roads`(347행)·`_build_sea_routes`(371행) ← `_ready`, `set_marker_position(…, rebuild_roads=true)`(561행). `set_marker_position` 호출처는 `tools/acceptance_tests.gd` 323·363행 2곳뿐이고 둘 다 `rebuild_roads=false` → 실행 중 다시 계산하는 경로 0건(PERF2와 같음). 다시 부르더라도 마커가 옮겨졌으면 key가 달라져 실시간으로 돈다 |
| 다른 지도 | [사실] 같은 `worldmap3d_root.gd`를 쓰는 장면은 `worldmap3d_eastasia.tscn` 하나. `dummy13`은 `tools/acceptance_tests.gd`만 쓴다(CI 아님). `dummy13`은 굽지 않고 경고 없이 지금처럼 실시간 |

## 2. 바꾼 것
- `worldmap3d/scripts/worldmap_roads.gd`
  - 실시간 A* 부분을 `live_road_cells` / `live_sea_cells`로 떼어냄(코드 내용 그대로, 결과를 `{link, cells}` / `{link, status, cells}`로 돌려줌).
  - `build_paths` / `build_sea_paths`: 구운 칸 번호(key 일치 시) 또는 실시간 결과 → **기존과 같은 코드로** 점 목록 → `_chaikin` 4번. 바닷길 실패 3종은 같은 `push_error` 문구를 그대로 낸다.
  - 새 공개 값: `baked_file`(기본 `""` = 항상 실시간), `road_cells`·`sea_cells`, `last_road_source`·`last_sea_source`("baked"/"live"), `last_warning`.
  - `section_key()`, `bake_dict()`(실시간 A*로 파일 내용 생성), `bake_text()`(파일 글).
  - 공개 인터페이스 `paths`·`sea_paths`·`sea_links`와 `build_paths(geo, city_xz, links)`·`build_sea_paths(…)` 서명은 그대로.
- `worldmap3d/scripts/worldmap3d_root.gd` +4줄: `BAKED_PATHS_FILE`, `BAKED_PATHS_MAPS := ["eastasia"]`, `_ready`에서 맵이 목록에 있으면 `roads.baked_file = <map_config 폴더>/baked_paths.json`.
- 추가: `worldmap3d/maps/eastasia/baked_paths.json`(47,756 바이트), `tools/bake_worldmap3d_paths.gd`(+`.uid`), `tests/scripts/test_worldmap3d_baked_paths.gd`(+`.uid`).
- CI 목록: **고치지 않음**. [사실] C-track은 `worldmap3d/`를 `.gdignore`로 빼고 돌기 때문에 이 테스트를 돌릴 수 없고, `verify-worldmap3d.yml`이 `tests/scripts/test_worldmap3d_*.gd`를 글롭으로 모두 돈다 → 새 테스트는 파일 이름만으로 3D CI에 들어간다(CI 로그에서 확인, 7절).

## 3. 구운 파일과 `key`
```
{
  "version": 1,
  "key": SHA-256(roads_key + sea_routes_key),
  "roads_key": "…", "sea_routes_key": "…",
  "roads":      [{"link":[a,b], "cells":[[i,j],…]}, …],             13줄
  "sea_routes": [{"link":[a,b], "status":"ok", "cells":[[i,j],…]}, …]   5줄 (status: ok / unknown_city / no_sea_cell / no_path)
}
```
- 링크 한 개가 한 줄이라 다시 구웠을 때 diff로 어느 길이 바뀌었는지 보인다. 도로 칸 3,077개 + 바닷길 칸 1,453개 = 4,530개.
- **구역 key**(`section_key`, 도로·바닷길 따로) = 다음을 줄로 이은 글의 SHA-256:
  - `v1` + 구역 이름 + A* 규칙 문자열(땅 solid 2.0, 가중치 식, 대각선, 휴리스틱, 끝 칸 열기 / 바다 쪽은 `SEA_MAX_M`·`SEA_SEARCH_CELLS`·`OPEN_SEA_MIN_CELLS` 값)
  - `gw`·`gh`·`width_km`·`height_km`
  - 높이 격자 **바이트 수와 내용 SHA-256**(지시서는 크기만, 같은 크기로 높이만 바뀌는 경우까지 잡도록 내용도 넣음 — 더 엄격한 쪽)
  - 모든 도시의 위치(km, 소수 3자리)와 **그 위치의 격자 칸**(반올림 경계에서 칸이 바뀌는 경우까지 잡음)
  - 링크 목록(순서 포함. 도로 A*는 앞 링크가 연 끝 칸이 뒤 링크에 영향을 주므로 순서도 입력)
- 실행 시 구역 key가 다르거나, 파일이 없거나, 버전이 다르면 → `push_warning("WorldMapRoads: roads: baked file … is stale (…) -> live A*")` 한 줄(구역마다) + 실시간 A*.
- 다시 굽기: `godot --headless --path . --script res://tools/bake_worldmap3d_paths.gd`. 도구는 실제 맵 루트(`worldmap3d_eastasia.tscn`, 도로 끔)로 입력을 읽고 `WorldMapRoads.bake_dict`(실시간 A* 그 코드)로 칸을 뽑는다. 복제한 계산 없음.
```
[BAKE_PATHS] wrote res://worldmap3d/maps/eastasia/baked_paths.json: 13 roads, 5 sea routes, 4530 cells, key e32e7021d813652cc5fd85f4fbfa16c4013c776e25bf3740d22774892a51ae09 (4095 ms)
```

## 4. 테스트 `test_worldmap3d_baked_paths.gd` 결과 (원문: `agent/evidence/perf3_test_baked_paths.txt`)
```
[PASS] the EastAsia root points WorldMapRoads at res://worldmap3d/maps/eastasia/baked_paths.json
[PASS] the real scene used the baked cells (roads baked, sea baked)
[PASS] baked: 13 road + 5 sea cell lists (13, 5)
[BAKED_PATHS] live A* + smoothing 4420 ms
[BAKED_PATHS] a roads: 3077 cells compared
[BAKED_PATHS] a sea: 1453 cells compared
[PASS] a: smoothed paths, sea paths and sea_links identical
[PASS] d: committed key == fresh bake (e32e7021d813652c)
[PASS] d: committed road cells == fresh bake
[PASS] d: committed sea cells == fresh bake
[PASS] d: committed file text == fresh bake text
[PASS] b moved chengdu: roads fall back live (roads: baked file … is stale (inputs changed; re-run tools/bake_worldmap3d_paths.gd))
[PASS] b moved chengdu: smoothed paths, sea paths and sea_links identical
[PASS] b link removed: roads fall back live (…stale…)
[PASS] c missing: roads fall back live (roads: baked file res://worldmap3d/maps/eastasia/__no_baked_paths__.json is missing or unreadable)
[BAKED_PATHS] checks=105 failures=0
```
- ⓐ 일치: 링크 18개 각각 길이·모든 칸이 같다(`Vector2i` 비교), 최종 `paths`·`sea_paths`(`PackedVector2Array ==`, 실수 완전 일치)·`sea_links` 같다.
- ⓑ 낡음: 청두를 1칸(3.21 km) 옮김 / 도로·바닷길 링크 1개씩 뺌 → 두 구역 다 경고 + 실시간, 결과는 같은 입력의 실시간 계산과 같다.
- ⓒ 파일 없음: 경고 + 실시간, 결과 같음.
- ⓓ 최신성: 지금 입력으로 새로 구운 결과 == 저장소 파일(값과 **글 그대로**).
- [사실] 시험 삼아 저장소 파일의 칸 하나(`[475,660]` → `[475,661]`)를 바꾸고 돌리면 4개 실패(ⓐ 도로 1개·최종 경로, ⓓ 칸·글)로 빨개졌다. 파일은 원래대로 되돌렸다(`cmp` 같음).

기존 3D 테스트 (로컬, 이 가지):
```
[WM3D_ROADS] checks=121 failures=[]
[WM3D_PRODUCTION] checks=28 failures=[]
[WORLDMAP3D_HOST] PASS: 58 checks, 0 failures
[WORLDMAP3D_ADAPTER] PASS: 56 checks, 0 failures
[WORLDMAP3D_CAMERA_CONTROLLER] PASS: 61 checks, 0 failures
[WORLDMAP3D_CAMERA_EXTERNAL_INPUT] PASS: 20 checks, 0 failures
[WM3D_COLOR_PARITY] checks=57 failures=[]
[WM3D_MEM_PROBE] checks=37 failures=[]
validators=72 pass=72 fail=0
```
[사실] `WM3D_ROADS`가 찍는 길 길이·직선 비율 줄도 그대로다(같은 점 목록이므로).

## 5. 2-D 전후 시간 (원문: `agent/evidence/perf3_timing_raw.txt`, 방법: `perf3_method.txt`)
- 방법: PERF2 driver 그대로, 정식 `WorldMap.tscn`, 1920×1080, 같은 PC, 전·후 × 창/headless × 5회, 지점+모드마다 새 임시 사용자 폴더(1회째 = 차가운 시작). 전 = `origin/main` `ab9b739` 작업 폴더, 후 = 이 가지 `cb121b0`. 김작 `user://` 건드리지 않음.
- 단계 시간은 PERF2 임시 마커 대신 루트가 늘 남기는 `stats.road_build_ms`(도로 A* + 매끈 + 리본 메시)·`sea_build_ms`(바닷길 같은 범위)와 `build_ms`(CSV와 같은 값)를 썼다.

| 값 (ms) | 모드 | 전 1회 | 전 2~5 중앙 | 후 1회 | 후 2~5 중앙 | 차이 |
|---|---|---|---|---|---|---|
| 시작 전체(장면 전환 → 보임+2프레임) | 창 | 12,976 | 13,052 | 9,106 | **9,112** | **−3,940** |
| 〃 | headless | 12,452 | 12,165 | 8,180 | 8,067 | −4,099 |
| `build_ms`(3D 지도 만들기) | 창 | 8,606 | 8,694 | 4,717 | 4,725 | −3,968 |
| 〃 | headless | 8,566 | 8,324 | 4,356 | 4,288 | −4,036 |
| 도로 경로 `road_build_ms` | 창 | 3,159 | 3,197 | 296 | 295 | −2,902 |
| 〃 | headless | 3,301 | 3,177 | 281 | 280 | −2,897 |
| 바닷길 경로 `sea_build_ms` | 창 | 1,176 | 1,188 | 154 | 152 | −1,036 |
| 〃 | headless | 1,172 | 1,197 | 157 | 151 | −1,046 |
| 도로+바닷길 합 | 창 | | 4,425 | | 447 | −3,978 |
| 〃 | headless | | 4,393 | | 432 | −3,961 |

구운 파일 읽기 (`agent/evidence/perf3_micro.txt`, headless 3회, 값은 거의 같아 1회만):
| 항목 | ms |
|---|---|
| 파일 47,756 바이트 읽기 + JSON 해석 | 2.1 |
| 구역 key 1개 계산(대부분 높이 격자 8 MB SHA-256) | 34.8 |
| `build_paths` 구운 것 사용(key + 해석 + 매끈) / 실시간 | 43.2 / 2,926.7 |
| `build_sea_paths` 구운 것 / 실시간 | 38.1 / 1,071.4 |

- [사실] 남은 비용의 대부분은 key의 격자 해시다(구역마다 약 35 ms, 합 약 70 ms). [추정] 해시를 한 번만 계산해 두면 약 35 ms 더 줄지만, 이번에는 "낡으면 반드시 실시간" 쪽을 우선해 매번 계산한다.
- 도로·바닷길 단계에 남은 약 0.45초는 리본 메시 만들기다(이번 범위 밖).

## 6. 2-E 지형·강 메시 굽기 시험 (측정만, 파일은 임시 폴더, 커밋 안 함)
| 대상 | 지금 계산 | `.res` 그대로 | `.res` 압축 |
|---|---|---|---|
| 지형 타일 109개(LOD0 삼각형 2,639,484, LOD 포함) | 2,061 ms | 70.4 MB, 읽기 55~57 ms | 20.3 MB, 읽기 201~204 ms |
| 강 메시(삼각형 404,966) | 1,103 ms | 17.1 MB, 읽기 13~18 ms | 5.2 MB, 읽기 42~46 ms |

- [사실] 읽기는 계산보다 10~100배 빠르다. 다만 크기가 압축해도 지형 20 MB·강 5 MB이고, 압축하지 않으면 87 MB다.
- [추정] 읽기 시간은 방금 저장한 파일이라 OS 디스크 캐시에 있던 값이다. 차가운 디스크(첫 실행)에서는 더 느릴 수 있다. 압축본이 저장소 크기·읽기 시간 둘 다 무난한 후보다.
- [추정] 지형은 높이 격자에서 바로 나오는 결정적 계산이라 이번과 같은 key 방식으로 무효를 판정할 수 있다. 결정은 클코치·김작 몫.

## 7. CI (`cb121b0`)
- [사실] `Verify WorldMap3D` run `42173394109`: **success**. CI 로그: `[BAKED_PATHS] live A* + smoothing 3216 ms`, `[BAKED_PATHS] checks=105 failures=0`, `[WM3D_ROADS] checks=121 failures=[]`, `[WM3D_PRODUCTION] checks=28 failures=[]`, 장면을 만들 때마다 `[WorldMap3D] map 'eastasia' built in 3832~4047 ms … roads 13, sea routes 5, sea build 121~123 ms`.
- [사실] `Verify C-track refactor` run `42173394148`: shard 1·2·3 success, **shard 0 failure** — 알려진 `[CUTIN]` 길이 검사(`test_battle3d_cutin_result_toast.gd`, 실제 3.935~3.966초 < 3.95초). 이번 변경과 무관(C-track은 `worldmap3d/`를 빼고 돌고 테스트 목록도 `main`과 같다). **합격 기준의 "C-track 4 shard success"를 못 채워 이 단계는 멈춤** → `agent/REPORT_WM3D_PERF3_STOP_20261106.md`.

## 8. 택한 해석
- "도로 경로(10)·바닷길 경로(12)" 단계 시간은 PERF2 임시 마커 대신 루트의 `road_build_ms`·`sea_build_ms`로 쟀다. 두 값은 PERF2 마커 구간을 포함하고 리본 메시까지 넣은 범위다. 줄어든 양 비교에는 같은 범위의 전후라 문제없다.
- `key`: 지시서의 "높이 격자 파일 크기" 대신 **크기 + 내용 해시**, 도시 위치에 **격자 칸**도 넣었다(더 엄격한 쪽). 구역마다 key를 따로 두고(`roads_key`·`sea_routes_key`), 맨 위 `key`는 둘을 합친 해시다. 도로 계산은 바닷길 링크와 무관하므로 구역별로 판정한다.
- 파일 모양: 지시서의 `roads: [{link, cells}]`·`sea_routes: [{link, cells}]`에 바닷길 `status`와 두 구역 key 필드를 더했다. 실패한 바닷길 링크도 구운 파일에서 같은 `push_error`가 나도록 하기 위해서다(EastAsia 5개는 모두 `ok`).
- `dummy13` 등 다른 지도는 `BAKED_PATHS_MAPS`에 없으면 `baked_file`이 비어 경고 없이 실시간(동작 변화 없음). EastAsia에서 파일이 지워지면 경고 + 실시간.
- CI 목록 1줄: 3D CI가 글롭으로 잡으므로 넣지 않았다(2절).

## 9. 김작 F6 확인 목록
1. 클코드가 `feature/wm3d-bake-20261106`을 체크아웃해 준 상태에서 F6로 `WorldMap.tscn`(3D).
2. 시작이 전보다 빨라졌는가(이 PC 기준 약 13초 → 약 9초).
3. **도로 13개**가 이전과 같은 모양인가 — `main`(또는 다른 가지)에서 한 번, 이 가지에서 한 번, 같은 곳을 비교.
4. **바닷길 5개**가 이전과 같은 모양인가 — 같은 방법으로 두 번 비교.
5. 출력 창에 `WorldMapRoads: … -> live A*` 경고가 **없어야** 한다(있으면 구운 파일이 낡은 것).

## 10. 못 본 것
- [미확인] 김작 F6(모양 비교·체감 시간).
- [미확인] 릴리스 빌드(내보내기 템플릿 없음) 시간.
- [미확인] 차가운 디스크에서 2-E `.res` 읽기 시간.
- 측정용 `origin/main` 작업 폴더(`C:\eastwar_tmp\pbefore`)는 지웠다. 이 가지 작업 폴더(`C:\eastwar_tmp\bake`)는 답신을 이을 수 있게 남겨 둔다.
