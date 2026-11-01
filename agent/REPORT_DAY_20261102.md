기준 화면: `CLAUDECODE_ORDER_DAY_20261102.md`의 수정 사항만 다룹니다(보고서 `REPORT_DAY_20261102.md`가 깃에 올라가 클코치가 원격에서 읽는 것).
합격 기준: ① 항목 5·6 보고가 채워짐 ② 보고서가 `agent/REPORT_DAY_20261102.md`로 `feature/wm3d-intake-20261101`에 올라가 원격 해시가 로컬과 같음 ③ 끝난 뒤 정본 `git status` 비어 있음. 김작 F6는 없음.

① 항목 5·6 모두 채움(항목 1~4는 추가 지시서 A에 따라 생략, 4의 마커 13개·`map3d` 폴더만 6에 이어 붙임). 단 항목 5의 GDScript 경고(정수 나눗셈·이름 가림)는 `--import` 출력에 **나오지 않음** — import 출력은 UID 중복 2건뿐이고, 코드 줄은 rg로 찾은 [추정] 후보로 붙임.
② 깃에 올림: 커밋 `docs(agent): report REPORT_DAY_20261102 (T-WM3D-03 prep) [skip ci]` — 해시는 아래 종료 루틴 참고(자기 커밋 해시는 올리는 파일 안에 미리 넣을 수 없어, 바탕화면 원본에만 push 뒤 적음).
③ 김작이 할 일: 없음. (놀라운 점: 2D 게임 도로 17 = 육로 12 + 해로 5, 3D 데이터는 육로 13 + 해로 5. 차이는 **성도–건업 육로 1개가 3D에만** 있음. 2D에서도 성도·건업 마커의 `neighbors`에는 서로가 들어 있으나 `RouteLayer` 노드는 없음.)

---

## 시작 상태 [사실]

- 정본 `C:\dev\SamWar_BattleLab_cc`, 가지 `feature/wm3d-intake-20261101`, HEAD `5bf2f2d8ac6ad42818af8e80ceab566c644655b0`, `git status --short` 빈 출력.
- Godot: `<Desktop>\godot\Godot_v4.6.2-stable_win64_console.exe`, `--version` = `4.6.2.stable.official.71f334935`.

## 항목 5. 경고 출처

### 5-1. `godot --headless --path . --import` 1회 실행 — 출력 전문 [사실]

종료 코드 0. 색 제어 문자만 제거한 전문:

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[   0% ] first_scan_filesystem | Started Project initialization (5 steps)
[   0% ] first_scan_filesystem | Scanning file structure...
[  16% ] first_scan_filesystem | Loading global class names...
[  33% ] first_scan_filesystem | Verifying GDExtensions...
[  50% ] first_scan_filesystem | Creating autoload scripts...
[  66% ] first_scan_filesystem | Initializing plugins...
[  83% ] first_scan_filesystem | Starting file scan...
[ DONE ] first_scan_filesystem

WARNING: UID duplicate detected between res://tests/scenes/Battle_UI_Production_Test.tscn and res://_incoming/Battle_Land_BEFORE_T08_BACKUP.tscn.
   at: _process_file_system (editor/file_system/editor_file_system.cpp:1377)
WARNING: UID duplicate detected between res://Battle_Land.tscn and res://tests/scenes/Battle_UI_Production_Test.tscn.
   at: _process_file_system (editor/file_system/editor_file_system.cpp:1377)
[   0% ] loading_editor_layout | Started Loading editor (5 steps)
[   0% ] loading_editor_layout | Loading editor layout...
[  16% ] loading_editor_layout | Loading docks...
[  33% ] loading_editor_layout | Reopening scenes...
[  50% ] loading_editor_layout | Loading central editor layout...
[  66% ] loading_editor_layout | Loading plugin window layout...
[  83% ] loading_editor_layout | Editor layout ready.
[ DONE ] loading_editor_layout
```

| # | 종류 | 경로 | 출처 | 쪽 |
|---|---|---|---|---|
| 1 | UID 중복 | `tests/scenes/Battle_UI_Production_Test.tscn` ↔ `_incoming/Battle_Land_BEFORE_T08_BACKUP.tscn` | `editor_file_system.cpp:1377` | 기존 저장소 |
| 2 | UID 중복 | `Battle_Land.tscn` ↔ `tests/scenes/Battle_UI_Production_Test.tscn` | `editor_file_system.cpp:1377` | 기존 저장소 |

- [사실] 이 import 출력에는 GDScript 경고(정수 나눗셈·이름 가림)가 **0줄**입니다.
- [사실] 재현을 위해 추가로 해 본 것(모두 파일 변경 없음): ① `--check-only --script res://worldmap3d/scripts/{worldmap3d_root,worldmap_region_labels,worldmap_camera}.gd` → 출력 없음 ② `--headless --path . --quit-after 180 res://worldmap3d/scenes/worldmap3d_eastasia_v2_3_test.tscn` → 3줄(엔진 머리줄), 경고·오류 0 ③ `--headless --editor --quit-after 600` → 위 UID 2건만.
- [추정] GDScript 분석기 경고는 에디터 GUI의 스크립트 편집기/출력 패널에서만 나오고, 헤드리스 CLI로는 찍히지 않습니다. 그래서 아래 5-2는 "경고 문구 원문"이 아니라 **지시서가 적은 위치의 코드 줄**과 rg로 찾은 후보입니다.

### 5-2. 경고가 가리키는 코드 줄 (앞뒤 2줄)

**(a) `worldmap3d/scripts/worldmap3d_root.gd:522` 이름 가림** — 쪽: `worldmap3d/` [사실: 줄 내용] / [추정: 매개변수 `name`이 `Node.name`을 가림]

```gdscript
520		_build_roads()
521
522	func set_fill_preset(name: String) -> void:
523		_preset = cfg.fill_preset(name)
524		if camera:
```

**(b) `worldmap_config.gd:78` 이름 가림** — 저장소 안 `worldmap_config.gd`는 `worldmap3d/scripts/worldmap_config.gd` **하나뿐**(rg --files) → 쪽: `worldmap3d/`.

```gdscript
76	## Active fill preset ("strong" / "medium" / "light") -> Dictionary
77	func fill_preset(name := "") -> Dictionary:
78		var presets: Dictionary = territory.get("presets", {})
79		var n: String = name if name != "" else territory.get("fill_preset", "light")
80		return presets.get(n, {"fill_far": 0.50, "fill_near": 0.08, "band": 0.80})
```
- [사실] 이 클래스는 `extends RefCounted`(5행)라 `name` 멤버가 없습니다. 78행 자체에는 가릴 이름이 보이지 않습니다.
- [미확인] 실제 경고가 77행 `name` 매개변수인지, 다른 종류인지 CLI로 확인 못 함.

**(c) 정수 나눗셈 5건** — CLI에서 경고 원문을 얻지 못해 위치 미확인. `worldmap3d/scripts/`에서 `int / int` 형태로 보이는 줄 [추정] 6곳(모두 `worldmap3d/` 쪽):

```gdscript
# worldmap3d_root.gd
188		else:
189			mesh = geo.build_terrain_mesh()
190			stats.terrain_tris = mesh.surface_get_array_index_len(0) / 3
191		terrain_mat = ShaderMaterial.new()
192		terrain_mat.shader = load(SHADERS + "worldmap_terrain.gdshader")

306			widths.append(ws)
307		var mesh := WorldMapRibbons.build(geo, lines, widths, 1.2)
308		stats.river_tris = mesh.surface_get_array_index_len(0) / 3 if mesh.get_surface_count() > 0 else 0
309		river_mat = ShaderMaterial.new()
310		river_mat.shader = load(SHADERS + "worldmap_ribbon.gdshader")

326		var mesh := WorldMapRibbons.build(geo, roads.paths, [], 0.8)
327		stats.road_build_ms = (Time.get_ticks_usec() - t) / 1000.0
328		stats.road_tris = mesh.surface_get_array_index_len(0) / 3 if mesh.get_surface_count() > 0 else 0
329		if road_mat == null:
330			road_mat = ShaderMaterial.new()
# worldmap_geo.gd
194				norms.fill(Vector3.UP)      # lighting uses the baked normal texture; vertex normals only feed shadow bias
195				var idx0 := _tile_indices(nx, nz, 1, keep, full)
196				tris0 += idx0.size() / 3
197				var lods := {}
198				var errs: Array = lod_errors.get("%d,%d" % [ti, tj], [])

217				var mesh := ArrayMesh.new()
218				mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr, [], lods)
219				out.append({"mesh": mesh, "tile": Vector2i(ti, tj), "tris": idx0.size() / 3})
220		tile_stats = {"tiles": out.size(), "tiles_skipped_sea": skipped, "tris_lod0": tris0, "tile_cells": tile_cells}
221		return out
# worldmap_region_labels.gd
73		var w := img.get_width()
74		var h := img.get_height()
75		var step := maxi(1, w / 384)
76		for y in range(0, h, step):
77			for x in range(0, w, step):
```
- [미확인] 기존 저장소 코드(`scripts/` 등) 쪽 정수 나눗셈은 검색하지 않음(후보가 수백 줄, 경고 원문 없이 고를 근거 없음).

**(d) `worldmap3d/scripts/worldmap_region_labels.gd` 관련 경고**: import 출력 기준 **0건** [사실]. 단 75행 `w / 384`는 정수 나눗셈 후보 [추정].

### 5-3. 끝난 뒤 `git status --short` [사실]
빈 출력(위 import·check-only·smoke·editor 실행 모두 뒤에 확인).

## 항목 6. 도로 17 대 13, 설정 화면, 도시 표

### 6-1. 게임(2D) `WorldMap.tscn` → `WorldMapRoot/RouteLayer` 자식 17개 [사실]

`route_type` 줄이 없으면 스크립트 기본값 `"land"`(`scripts/worldmap_route_path.gd:8` `@export_enum("land", "sea") var route_type: String = "land"`).

| tscn 줄 | 노드 이름(= route_id) | start_city_id | end_city_id | route_type |
|---|---|---|---|---|
| 301 | Route_Luoyang_Yecheng | luoyang | yecheng | land(기본) |
| 315 | Route_Luoyang_Chengdu | luoyang | chengdu | land(기본) |
| 329 | Route_Luoyang_Jianye | luoyang | jianye | land(기본) |
| 343 | Route_Yecheng_Jianye | yecheng | jianye | land(기본) |
| 357 | Route_Yecheng_Karakorum | yecheng | karakorum | land(기본) |
| 371 | Route_Hanseong_Pyeongyang | hanseong | pyeongyang | land(기본) |
| 385 | Route_Pyeongyang_Karakorum | pyeongyang | karakorum | land(기본) |
| 399 | Route_Hanseong_Gyeongju | hanseong | gyeongju | land(기본) |
| 413 | Route_Hanseong_Sabi | hanseong | sabi | land(기본) |
| 427 | Route_Gyeongju_Sabi | gyeongju | sabi | land(기본) |
| 441 | Route_Kyoto_Osaka | kyoto | osaka | land(기본) |
| 455 | Route_Kyoto_Edo | kyoto | edo | land(기본) |
| 469 | Route_Gyeongju_Kyoto | gyeongju | kyoto | sea (474행) |
| 528 | Route_Gyeongju_Osaka | gyeongju | osaka | sea (533행) |
| 587 | Route_Sabi_Kyushu | sabi | kyushu | sea (592행) |
| 646 | Route_Sabi_Jianye | sabi | jianye | sea (651행) |
| 705 | Route_Kyushu_Osaka | kyushu | osaka | sea (710행) |

합계: land 12 + sea 5 = 17.

### 6-2. 3D 데이터 `worldmap3d/maps/eastasia/rule_data_eastasia.json` [사실]

- `eastasia/` 안에서 "road"가 들어간 JSON은 이 파일 하나(rg). 최상위 키: `_comment, version, factions, cities, roads, sea_routes`.
- 도로에 **id·종류 필드가 없음**. `roads`(229행~)는 `[도시, 도시]` 쌍 목록, `sea_routes`(283행~)도 같은 모양. 종류는 어느 목록에 있는지로만 구분.
- 사용처: `worldmap3d_root.gd:325` `roads.build_paths(geo, marker_xz, rules.roads)` — 리본은 `roads`만 그림 [사실: 그 줄].

| # | 목록 | 끝 A | 끝 B |
|---|---|---|---|
| 1 | roads | chengdu | jianye |
| 2 | roads | chengdu | luoyang |
| 3 | roads | edo | kyoto |
| 4 | roads | gyeongju | hanseong |
| 5 | roads | gyeongju | sabi |
| 6 | roads | hanseong | pyeongyang |
| 7 | roads | hanseong | sabi |
| 8 | roads | jianye | luoyang |
| 9 | roads | jianye | yecheng |
| 10 | roads | karakorum | pyeongyang |
| 11 | roads | karakorum | yecheng |
| 12 | roads | kyoto | osaka |
| 13 | roads | luoyang | yecheng |
| 14 | sea_routes | gyeongju | kyoto |
| 15 | sea_routes | gyeongju | osaka |
| 16 | sea_routes | jianye | sabi |
| 17 | sea_routes | kyushu | osaka |
| 18 | sea_routes | kyushu | sabi |

합계: roads 13 + sea_routes 5 = 18.

### 6-3. 두 목록 비교 (도시 쌍, 순서 무시) [사실]

| 쌍 | 2D | 3D |
|---|---|---|
| luoyang–yecheng | land | roads |
| luoyang–chengdu | land | roads |
| luoyang–jianye | land | roads |
| yecheng–jianye | land | roads |
| yecheng–karakorum | land | roads |
| hanseong–pyeongyang | land | roads |
| pyeongyang–karakorum | land | roads |
| hanseong–gyeongju | land | roads |
| hanseong–sabi | land | roads |
| gyeongju–sabi | land | roads |
| kyoto–osaka | land | roads |
| kyoto–edo | land | roads |
| **chengdu–jianye** | **없음** | **roads** |
| gyeongju–kyoto | sea | sea_routes |
| gyeongju–osaka | sea | sea_routes |
| sabi–kyushu | sea | sea_routes |
| sabi–jianye | sea | sea_routes |
| kyushu–osaka | sea | sea_routes |

- **3D에만 있는 것:** `chengdu–jianye` (roads) 1개.
- **2D에만 있는 것:** 없음.
- 종류(land/sea)가 엇갈리는 쌍: 없음.

### 6-4. 설정 화면 [사실]

명령: `rg -n -i "settings|options|설정|옵션" scripts/worldmap scenes ui --glob "*.gd" --glob "*.tscn"` — `ui` 폴더는 없음. 49줄, 파일 5개:

| 파일 | 내용 |
|---|---|
| `scripts/worldmap/worldmap_main.gd` 771, 3153, 3251, 3272, 3338 | `_manual_trade_action_options`(교역 OptionButton) — 설정 화면 아님 |
| `scripts/worldmap/worldmap_main.gd` 5132 | 문자열 `"미설정"` — 설정 화면 아님 |
| `scenes/battle/Battle_Production.tscn`, `scenes/battle3d/Battle3D_CutinToastHud.tscn` | `LabelSettings` 리소스 — 설정 화면 아님 |
| `scenes/debug/hero_cutin_preview.tscn` 516~579 | 디버그 미리보기 `SettingsRow` — 게임 설정 아님 |
| `scripts/worldmap/ui/worldmap_top_nav.gd:205` | `$AudioSettingsPopup.popup_centered()` |

`worldmap_top_nav.gd` 202~205행:
```gdscript
202		if menu_id == &"techtree":
203			_open_techtree_if_available()
204		elif menu_id == &"system":
205			$AudioSettingsPopup.popup_centered()
```
- [사실] `WorldMapTopNav.tscn:17` 이 `AudioSettingsPopup`(`WorldMapAudioSettings.tscn`, 루트 `PopupPanel`, 스크립트 `scripts/worldmap/ui/worldmap_audio_settings.gd`)를 인스턴스함. 그 안의 항목: `SfxEnabled`, `SfxVolume`, `DuplicateLimit`, `VideoEnabled`, `VideoVolume`, `SavedHint`, `Preview`, `Close` 버튼.
- [사실] 사용자가 고를 수 있는 설정 화면은 **월드맵 상단 메뉴 `system` → 오디오 설정 팝업 하나**가 있음(효과음·영상 소리만).
- [사실] 카메라·입력안(A/B)·그래픽·2D/3D 전환 같은 "게임 설정" 화면은 위 검색 범위에서 **없음**.
- [미확인] 검색 범위(`scripts/worldmap`, `scenes`) 밖의 루트 `.tscn`/`scripts/*.gd`는 이 명령으로 보지 않음(위 팝업은 별도 rg로 확인).

### 6-5. `WorldMap.tscn` `CityLayer` 아래 마커 13개 — `city_id`·`owner_faction_id`·`neighbors`·`route_types` [사실]

`route_types` 줄이 없으면 스크립트 기본값 `{}`(`scripts/worldmap_city_marker.gd:12`).

| tscn 줄 | 노드 이름 | city_id | display_name | owner_faction_id | neighbors | route_types |
|---|---|---|---|---|---|---|
| 766 | CityMarker_Luoyang | luoyang | 낙양 | chu | yecheng, chengdu, jianye | (없음 = {}) |
| 802 | CityMarker_Yecheng | yecheng | 업성 | wei | luoyang, jianye, karakorum | (없음 = {}) |
| 838 | CityMarker_Chengdu | chengdu | 성도 | shu | luoyang, **jianye** | (없음 = {}) |
| 874 | CityMarker_Jianye | jianye | 건업 | wu | luoyang, **chengdu**, yecheng, sabi | {sabi: sea} (882행) |
| 912 | CityMarker_Karakorum | karakorum | 카라코룸 | mongol_faction | pyeongyang, yecheng | {pyeongyang: land, yecheng: land} (920행) |
| 952 | CityMarker_Pyeongyang | pyeongyang | 평양 | goguryeo | hanseong, karakorum | (없음 = {}) |
| 987 | CityMarker_Hanseong | hanseong | 한성 | player | pyeongyang, gyeongju, sabi | (없음 = {}) |
| 1022 | CityMarker_Gyeongju | gyeongju | 경주 | silla | hanseong, sabi, kyoto, osaka | {kyoto: sea, osaka: sea} (1030행) |
| 1062 | CityMarker_Sabi | sabi | 사비 | baekje_faction | hanseong, gyeongju, kyushu, jianye | {jianye: sea, kyushu: sea} (1070행) |
| 1101 | CityMarker_Kyoto | kyoto | 교토 | oda | gyeongju, osaka, edo | {gyeongju: sea} (1109행) |
| 1139 | CityMarker_Osaka | osaka | 오사카 | toyotomi | gyeongju, kyoto, kyushu | {gyeongju: sea, kyushu: sea} (1147행) |
| 1178 | CityMarker_Kyushu | kyushu | 큐슈 | kyushu_faction | sabi, osaka | {osaka: sea, sabi: sea} (1186행) |
| 1217 | CityMarker_Edo | edo | 에도 | tokugawa | kyoto | (없음 = {}) |

- [사실] `neighbors`에는 chengdu↔jianye가 서로 들어 있으나, `RouteLayer`에 `Route_Chengdu_Jianye` 노드는 없음(6-1).
- [사실] `neighbors`의 쌍 수(양방향 하나로 셈) = 18 = 2D 도로 17 + chengdu–jianye.

### 6-6. `scripts/worldmap/map3d/` 폴더 [사실]
없음(`ls: cannot access 'scripts/worldmap/map3d': No such file or directory`). 정상.

---

## 종료 루틴
1. 정본 `git status`·가지·HEAD: 아래 push 뒤 기록.
2. 새로 만든 것: 바탕화면 `REPORT_DAY_20261102.md`, 그 사본 `agent/REPORT_DAY_20261102.md`(커밋 1개).
3. push한 것: `feature/wm3d-intake-20261101` 1개(보고서 커밋만, `[skip ci]`).
4. CI: 해당 없음(`[skip ci]`).
5. 김작이 결정할 것: ① 성도–건업 육로를 2D 게임에 추가할지 / 3D 데이터에서 뺄지(03 이후 2D·3D 도로를 맞출 때) ② GDScript 경고 원문이 필요하면 에디터 GUI 출력 패널에서 한 번 복사(CLI로는 안 나옴).
