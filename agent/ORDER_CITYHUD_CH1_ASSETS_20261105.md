기준 화면: 없음(보이는 화면 변화 0). 성 안 건물 그림 90장을 레포에 반입하고 로드 코드를 만든다. 아직 화면에는 아무것도 연결하지 않는다. 작업 가지는 **새 가지 `feature/wm3d-cityhud-20261105`**(시작점 `9160baf`)이고 정본 가지에는 push하지 않는다.
합격 기준: ① `assets/worldmap/city_buildings/`에 PNG 90 + `.import` 90이 들어 있고 `manifest.csv` md5·크기와 90장 모두 일치한다 ② 로드 헬퍼와 새 테스트가 90장을 모두 로드해 크기·투명(RGBA)을 확인하고, 없는 파일은 폴백한다 ③ 변경 경로가 아래 4절 목록 안이다 ④ 올린 커밋에서 `Verify C-track refactor` 4 shard와 `Verify WorldMap3D` success. 김작은 보고서와 CI만 본다(F6 없음).

# 지시서 — CITYHUD CH-1: 성 안 건물 2.5D 그림 90장 반입 + 로드 헬퍼

- 작성: 클코치, 2026-11-05 16:25 / 근거: `agent/REPORT_AUDIT_CITYHUD_20261105.md`(1-5, 3절 CH-1, Q1~Q8). 김작 11-05 15:57 "지금 정할 것 정해서 일 시키자. 밤에 합류 전에 중간 단계로".
- **김작 위임 결정(클코치 정리, 15:57)**: Q1 창 열기 = "성 안 보기" 버튼(후속 CH-2), Q2 = **새 폴더 `assets/worldmap/city_buildings/`와 새 `.import` 90개 생성을 허가**(기존 `.import`는 수정 금지), Q3 항구→무역항은 같은 슬롯 교체·조선소는 별도 슬롯(후속), Q4 카라코룸(몽골)은 그림 세트가 없으므로 허드창을 열지 않음(후속). 이번 지시서는 **그림 반입과 로드 헬퍼까지만**.
- 원본 위치 [사실, 감사 보고서]: 김작 PC `C:\Users\seong\Desktop\EASTWAR_CityBuildings_Plan_20261102\phase2_buildings\`(압축 푼 폴더, `manifest.csv` 포함)와 같은 이름의 `.zip`. 게임용 PNG 90장(`bld_<…>_<kr|cn|jp>.png`, RGBA 투명, 합계 약 2.6 MB), 관청 3장은 폴더 맨 위(`anchors/` 경로 표기와 다름) — md5 90/90 일치를 클코드가 확인함.

## 0. 규칙
1. 시작 전 `git status` 깨끗, `git fetch origin`, `git switch -c feature/wm3d-cityhud-20261105 9160baf`(원격 정본 가지가 `9160baf`인지 확인; 아니면 멈춤). push 대상은 이 새 가지뿐(`feature/wm3d-*` 범위, 김작 11-01 사전 승인). 정본 가지·`main`·`integration/*`·`work/*`·열린 PR 가지 push 금지, force·삭제 금지, `gh` 읽기만.
2. 수정·추가 경로는 4절 목록이 전부. 새 폴더는 `assets/worldmap/city_buildings/` **하나만**(김작 허가). 그 밖의 새 폴더 금지. 기존 `.import`·`assets/ui/tech_icons*`·`agent/WORLDMAP_RULES.md` 수정 금지. 규칙 문구(`WORLDMAP_RULES.md:230` 등)가 새 `.import` 생성을 막는다고 읽히면 멈추고 보고.
3. `scripts/worldmap/worldmap_main.gd`·`WorldMap.tscn`·`worldmap3d/` 수정 금지. `scripts/` 쪽 코드는 `worldmap3d/` 클래스를 타입·`preload`로 참조하지 않는다.
4. **zip/폴더 전체나 `master`·`raw` zip을 레포에 넣지 않는다.** 게임용 PNG 90장만. 용량 큰 파일(예: `*_master_raw.zip` 약 29 MB ×5) 커밋 금지.
5. 코드 커밋 → CI → 보고서 커밋(`[skip ci]`) 순서. 보고서 `agent/REPORT_CITYHUD_CH1_20261105.md`는 새 가지에만(정본 `PROGRESS_WM3D.md` 수정 금지).
6. [사실]과 다르면 추정하지 말고 멈추고 보고(`agent/REPORT_CITYHUD_CH1_STOP_20261105.md`). 원본 폴더가 없거나 md5가 하나라도 다르면 멈춤.

## 1. 반입할 것
1. 원본 `phase2_buildings/manifest.csv`의 `kind=game` 90행을 기준으로, 90장의 md5·크기를 **복사 전에** 원본에서 검증(불일치 0).
2. 복사: `assets/worldmap/city_buildings/bld_<…>_<kr|cn|jp>.png` 90장(파일명 그대로). 복사 후 레포 안 파일 md5를 다시 `manifest.csv`와 대조.
3. 같은 폴더에 `manifest.csv` 중 **game 90행만** 뽑은 `city_buildings_manifest.csv`를 둔다(원본 180행 manifest 전체는 넣지 않음. 열 이름 유지).
4. Godot로 프로젝트를 import해 새 `.import` 90개가 생기게 한다(Godot 4.6.2, 기존 import 설정 변경 금지). 생성된 `.import` 90개 외에 **다른 파일이 바뀌면**(예: 기존 `.import`, `project.godot`, `.godot` 밖의 파일) 멈추고 보고.

## 2. 로드 헬퍼 (`scripts/worldmap/ui/worldmap_city_building_assets.gd`, 새 파일)
- `class_name WorldMapCityBuildingAssets extends RefCounted`(정적 함수 위주).
- `static func texture_path(building_key: String, region_style: String) -> String`: `res://assets/worldmap/city_buildings/bld_<building_key>_<kr|cn|jp>.png`. `building_key`는 파일명에서 `bld_`와 `_<지역>.png`를 뺀 부분(예 `commerce_street_market`, `life_office`). `region_style`이 `kr/cn/jp`가 아니면 빈 문자열.
- `static func has_texture(building_key, region_style) -> bool`: `ResourceLoader.exists`.
- `static func load_texture(building_key, region_style) -> Texture2D`: 없으면 null(경고 대신 조용히 null, 호출 쪽이 폴백).
- `static func all_building_keys() -> PackedStringArray`: 30개 키(감사 보고서 1-3의 파일명 표와 일치: 상업 5, 군사 1, 성곽 7, 들판 5, 해안 7, 생활 5).
- `static func region_style_for_region_key(region_key: String) -> String`: `korean_peninsula`→`kr`, `china_mainland`→`cn`, `japanese_archipelago`→`jp`, 그 밖(예 `northern_steppe`)은 빈 문자열(= 그림 없음, 카라코룸은 창을 열지 않음). 이 표는 코드 상수로 한 곳에.
- 도시 id 하드코딩 금지(지역 키만 사용). 카탈로그·테크 id 연결은 이번에 하지 않는다(후속 CH-4).

## 3. 새 테스트 `tests/scripts/test_worldmap_city_building_assets.gd`
(`scripts/` 하위가 아니라 기존 `tests/scripts/` 규칙대로. `verify-c-track.yml`·`verify-worldmap3d.yml`이 이 테스트를 **자동으로 돌리는지** 확인하고, 안 돌면 보고서에 적는다. 워크플로 수정은 이번 범위 밖.)
- 키 30개 × 지역 3 = 90개 경로가 모두 `has_texture`, `load_texture`가 null이 아님.
- 모든 텍스처가 알파 채널을 가지고(`Image.get_format`/`has_alpha`) 크기가 manifest의 `size_px`와 일치.
- 알 수 없는 키·지역은 빈 경로·`has_texture=false`·`load_texture=null`, 예외·오류 줄 0.
- `region_style_for_region_key` 표 4개 + 알 수 없는 값.
- 결과 줄 `[CITY_BUILDING_ASSETS] checks=N failures=[]` 형식.
- 고치기 전(헬퍼 없음) 실패하는 것을 한 번 확인한 기록.

## 4. 수정·추가 가능 경로 (이 목록이 전부)
1. `assets/worldmap/city_buildings/bld_*.png` (90)
2. `assets/worldmap/city_buildings/bld_*.png.import` (90)
3. `assets/worldmap/city_buildings/city_buildings_manifest.csv`
4. `scripts/worldmap/ui/worldmap_city_building_assets.gd` (+ `.uid`)
5. `tests/scripts/test_worldmap_city_building_assets.gd` (+ `.uid`)
6. `agent/REPORT_CITYHUD_CH1_20261105.md` (보고서 커밋)

## 5. 로컬 검증 (결과 줄 원문을 표로)
1. 복사 전 원본 90장 md5·크기 검증 결과, 복사 후 레포 안 90장 재검증.
2. 새 테스트 통과, 헬퍼 없는 상태에서 실패했던 기록.
3. 정적 검증기 72개 전체(`.tscn`·핀 변경 없음, 커밋 뒤 깨끗한 트리 `validators=72 pass=72 fail=0`).
4. 기존 3D·월드맵 테스트 변화 없음(어댑터 56·카메라 61·외부 입력 20·호스트 58·색 57·길 121·프로덕션 28·메모리 프로브 37), `WorldMap.tscn`·`WorldMap3D_Host_Test.tscn` `--quit-after 5` 오류 0.
5. `git status --short`이 4절 목록 안(파일 수 합계 약 184±), `git diff --stat`에 `worldmap_main.gd`·`WorldMap.tscn`·`worldmap3d/` 0, 합계 크기(PNG 약 2.6 MB) 보고.
6. VRAM 대략: 90장의 가로×세로×4바이트 합계를 계산해 보고(압축 전 기준, 허드창이 열릴 때만 로드할 것이므로 상시 메모리가 아님을 전제로).

## 6. 커밋·push·CI
1. 커밋 1: `feat(worldmap): import the 90 city-building 2.5D images and a loader helper (CITY-HUD CH-1, not wired into any screen)`
2. `git push origin feature/wm3d-cityhud-20261105`(새 가지 최초 push), 원격 해시 = 로컬 HEAD.
3. `gh run watch`(읽기)로 두 workflow 확인(컷인 예외는 큐 4절 1번). 실패하면 고치지 말고 읽기 전용 조사 후 멈춤 보고.
4. 보고서 커밋(`[skip ci]`) 같은 새 가지에 push.

## 7. 보고서
맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약, "택한 해석", 5절 결과 표, diff(코드·CSV 앞부분), 워크플로가 새 테스트를 도는지, 약한 에셋 8개는 **반입은 하되 후속 교체 후보**로만 기록(파일명 유지로 교체 시 코드 변경 0), CI 표, 막힌 것, 종료 루틴 5줄. 김작이 정할 것: Q5~Q8(남은 질문)의 현재 상태 한 줄.

## 8. 하지 않는 것
- 허드창·"성 안 보기" 버튼·`WorldMap.tscn`·main 수정, 건물 슬롯·좌표 데이터, 테크 연결, 약한 에셋 재작업, master/raw zip 반입, 생활 5종 새 테크 추가, 정본 가지 push, 재실행으로 때우기.
