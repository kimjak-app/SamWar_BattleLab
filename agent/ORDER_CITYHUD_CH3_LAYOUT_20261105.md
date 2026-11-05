기준 화면: `feature/wm3d-cityhud-20261105`(CH-2 위에 이어서 커밋)에서 `res://WorldMap.tscn`을 열고 내 도시(한성·평양·건업·에도·교토)를 눌렀을 때 성 안 창이 참고 그림(`reference/<city>_interior_noshadow_v2.png`)과 같은 배치로 그려진다. 나머지 도시는 CH-2 임시 격자. 이 단계는 건물을 테크와 연동하지 않는다(CH-4).
합격 기준: 아래 원문 7절 자동 기준 1~9(클코치 보정 반영) + 그림 비교 10번(2px 이내) + CI success. 김작 F6는 CH-4 뒤에 한 번에 한다.

# 지시서 — CH-3: 성 안 건물을 제자리에 놓기 (클코치 보정판)

- 원문 작성: 록비서(Grok), 2026-11-05 22:40(KST 표기, 김작이 전달). 클코치 검수·보정: 2026-11-05 22:35 기준 대화 시각. **아래 "클코치 보정"이 원문과 다르면 보정이 우선한다.**
- 김작 확정 [사실, 11-05 22:26]: D1~D7 모두 록비서 추천대로(D5는 "교체"). 대상은 5성만.

## 클코치 보정 (원문보다 우선)
### 검수한 사실 [사실, 클코치가 zip을 직접 열어 확인]
- `city_layouts.json`: 성 5개, 항목 수 한성 30(19+11) / 평양 28(19+9) / 건업 29(20+9) / 에도 29(21+8) / 교토 31(26+5). 원문 표와 일치. `ay` 오름차순, `ax == x+w/2`, `ay == y+h` 어긋남 0. 교토 `compare_only` 1, `coastal_only` 7. 배경 5장 모두 1280×768 RGB. 민가 14장 + 배경 5장 + JSON = 20파일, CSV 없음.
- 민가(`decoration`) 항목의 `building_key`는 건물 30키가 **아니라** 민가 이름(`deco_minga_*`)이다 → 원문 7절 기준 2("모든 `building_key`가 30키 안")는 **`kind == building`인 항목에만** 적용한다. 민가는 `texture`가 가리키는 `res://` 경로가 `ResourceLoader.exists`인지로 확인한다.
- 레포 도시 id는 `hanseong`·`pyeongyang`·`jianye`·`edo`·`kyoto`(main에서 확인). v2 PNG 24장은 레포의 같은 이름 24장과 **크기·색 형식이 모두 같다**(확인함) → 코드 변경 없음.

### 원문에 없던 구멍 2개
1. **D5(24장 덮어쓰기)는 `city_buildings_manifest.txt`의 `bytes`·`md5`를 낡게 만든다**(매니페스트 8열: `file,kind,group,name_ko,region,size_px,bytes,md5`). 덮어쓴 24장의 `bytes`·`md5`를 같은 커밋에서 새 값으로 고친다(나머지 66행·머리글 불변). CH-1 테스트 482는 크기만 확인해 그대로 통과해야 하며, 통과해도 매니페스트 갱신은 필수다. `.import`는 Godot가 다시 쓰면 그 변경만 허용(다른 PNG의 `.import` 변경 금지).
2. **입력 위치**: 김작 PC 바탕화면 `C:\Users\seong\Desktop\EASTWAR_CityHUD_CH3_20261105\`(압축 푼 폴더. CH-1과 같은 방식). 없으면 **멈추고** 보고(김작에게 zip을 풀어 달라고 요청). 레포에 넣는 것은 `repo_ready/` 20파일 + `v2_png_24/` 24장뿐. `reference/`(약 40 MB)·`backgrounds/`·`build_ch3.py`·`*.csv`·`_check.json`·`README_KO.md`·zip은 레포에 넣지 않는다.

### 그 밖
- 가지·순서: `feature/wm3d-cityhud-20261105`에 이어서 커밋(CH-2 보고서 커밋 위). 시작 시 원격 끝이 CH-2 보고서 커밋이 아니면 멈춤(원문 0절 1번과 같음). 푸시는 이 가지뿐.
- 커밋을 셋으로 나눈다: ① D5 그림 24장 + 매니페스트 갱신 ② 배치표·배경·민가 + 레이아웃 도우미 + 컨트롤러 + 테스트 + CI 한 줄 ③ 보고서(`[skip ci]`).
- 그림 비교(원문 10번)의 기준은 D5 교체 후이므로 **`reference/<city_id>_interior_noshadow_v2.png`** 로 한다.
- 해안 판정은 main의 `_is_city_coastal_for_city_tech` 읽기만(main 0줄). 해안 판정 함수를 부를 수 없으면 멈추고 보고(데이터를 복사해 쓰지 않는다).
- 확인 질문 없이 진행(큐 10절). 목록 밖 수정이 필요하면 멈추고 `agent/REPORT_CITYHUD_CH3_STOP_20261105.md`. 배치표 좌표는 이상해 보여도 고치지 않는다.
- 실행 PC 화면이 없는 환경이면 그림 비교(10번)만 "[미확인, 화면 없는 환경]"으로 두고 나머지를 진행한다.

---
# 원문 (록비서 초안, 위 보정 적용 전)
# CH-3 지시문 (클코치 → 클코드): 성 안 건물을 제자리에 놓기

- 작성: 록비서, 2026-11-05 22:40 (KST). 클코치가 다듬어서 클코드에게 넘겨 주세요.
- 기준: 레포 `kimjak-app/SamWar_BattleLab`, 가지 `feature/wm3d-cityhud-20261105`, 원격 끝 `ef509c1`(CH-1 보고서 커밋, 19:37 KST)에서 읽기만 해서 확인했습니다. 이 시점에 **CH-2는 아직 push되지 않았습니다.** 그래서 CH-2 쪽 이름은 `agent/ORDER_CITYHUD_CH2_WINDOW_20261105.md`(가지 `feature/wm3d-orders-20261105`)에 적힌 계획 이름을 썼습니다. CH-2 보고서가 올라오면 이름을 한 번 맞춰 주세요.
- 함께 주는 것: 이 폴더 전체(`EASTWAR_CityHUD_CH3_20261105.zip`). 레포에 넣을 파일은 `repo_ready/` 안에 레포 경로 그대로 들어 있습니다.

## 0. 범위와 시작 조건
1. CH-3만 합니다. CH-2(창 틀, 열기 조건, 닫기, 입력 차단)가 이 가지에 push되고 CI가 통과한 다음에 시작합니다. 시작할 때 원격 끝이 CH-2 보고서 커밋인지 확인하고, 아니면 멈추고 보고합니다.
2. CH-3에서 하는 일은 하나입니다. **CH-2의 임시 격자 대신, 배치표 좌표로 배경과 건물·민가를 그립니다.**
3. 대상은 5개 성뿐입니다(김작님 확정).

| 레포 city_id | 이름 | 그림 세트 | 배치표 |
|---|---|---|---|
| `hanseong` | 한성 | kr | 건물 19 + 민가 11 |
| `pyeongyang` | 평양 | kr | 건물 19 + 민가 9 |
| `jianye` | 건업 | cn | 건물 20 + 민가 9 |
| `edo` | 에도 | jp | 건물 21 + 민가 8 |
| `kyoto` | 교토 | jp (해안) | 건물 26(해안 7 포함) + 민가 5 |

4. 그 밖의 8개 도시(경주·사비·낙양·업성·성도·오사카·큐슈·카라코룸)는 배치표가 없습니다. 이 도시들은 **CH-2 임시 격자를 그대로 씁니다.** 카라코룸(몽골)은 CH-2에서 정한 대로 창이 열리지 않으며 그대로 둡니다. 몽골 세트(게르, 목책, 초원)는 나중에 따로 만듭니다(김작님 확정).
5. 테크 완료에 따라 건물을 켜고 끄는 일은 CH-4입니다. CH-3에서는 배치표에 있는 것을 **전부** 그립니다. 참고 그림과 같아지는지 보려는 것입니다.
   - CH-4가 먼저 들어가 있다면 표시 조건은 CH-4 것을 그대로 둡니다. 좌표만 배치표에서 가져오고, 테스트용으로 "전부 표시" 옵션을 하나 둡니다.

## 1. 확인된 레포 사실 (ef509c1 기준)
- 그림 90장: `res://assets/worldmap/city_buildings/bld_<키>_<kr|cn|jp>.png`(폴더 안에 하위 폴더 없음). 관청도 원본에서는 `anchors/` 아래였지만 레포에서는 같은 폴더에 있습니다.
- 로드 헬퍼: `scripts/worldmap/ui/worldmap_city_building_assets.gd`(`WorldMapCityBuildingAssets`)
  - `texture_path(key, style)`, `load_texture(key, style)`(없으면 null), `region_style_for_region_key()` 함수가 있습니다.
  - 건물 키 30개는 `BUILDING_KEYS`입니다. 배치표의 `building_key`는 이 30개와 **글자까지 같습니다**(`id_mapping.csv`). 맞지 않는 키는 0개입니다.
- 도시 id: `WorldMap.tscn`의 `city_id`와 `scripts/worldmap_city_marker.gd`를 썼습니다. **평양은 레포에서 `pyeongyang`입니다.** 원본 폴더 이름은 `pyongyang`이라 배치표에서 레포 id로 바꿔 두었습니다.
- 해안 도시는 교토와 큐슈 두 곳뿐입니다. 판정은 main의 `_is_city_coastal_for_city_tech`(`CITY_HUD_DATA`의 `type`에 coastal/port/maritime가 들어 있는지)가 합니다. 근거는 `REPORT_AUDIT_CITYHUD_20261105.md` 1-4입니다.
- `.csv`를 `res://`에 두면 Godot 4.6.2가 번역 파일로 가져옵니다(CH-1 멈춤 사례). **레포에는 JSON만 넣고, CSV는 넣지 않습니다.**

## 2. 레포에 넣을 파일 (`repo_ready/assets/worldmap/city_buildings/`, 20개)
- `city_layouts.json`: 5성 배치표, city_id를 키로 둔 표
- `interior_bg_<city_id>.png` 5장: 배경, 1280×768 RGB
- `deco_minga_*_<kr|cn|jp>.png` 14장: 민가 장식(kr 6, cn 4, jp 4)
- 넣는 곳은 CH-1이 허가받은 폴더입니다(새 폴더 없음, 결정 D2). PNG 19장에 `.import`가 19개 생깁니다.
  - 가져오기 설정은 CH-1 그림과 같게 합니다(`compress/mode=0`, 밉맵 끔).
- 결정 D5가 "교체"로 확정되었으므로 `v2_png_24/`의 PNG 24장으로 같은 이름 파일을 덮어씁니다. 이름과 크기가 같아서 코드는 바뀌지 않습니다. 이 작업은 따로 커밋합니다.

## 3. 좌표 규칙 (이것만 지키면 됩니다)
- 캔버스는 1280×768 px이고, 원점은 **왼쪽 위**입니다. y는 아래로 갈수록 커집니다.
- `ax, ay`는 그림의 **발 자리(하단 중앙)** 입니다.
  - 그리는 사각형: 왼쪽 위 `(ax - w/2, ay - h)`, 크기 `(w, h)`
  - `w, h`는 원본 크기(`src_w, src_h`)에 `scale` 1.25를 곱한 값입니다. 배치표에 이미 계산되어 있습니다. `x, y`도 같은 사각형의 왼쪽 위라서 그대로 써도 됩니다.
- 그리는 순서: 성마다 `items` 배열 순서대로 그립니다. 이 순서는 `z` 0부터 오름차순이고, `ay` 오름차순(같으면 `ax`)과 같습니다.
  - Control로 그리면 자식으로 추가하는 순서가 곧 그리는 순서입니다. Node2D로 그리면 `z_index = z` 또는 y-sort를 씁니다.
- 창의 그림 영역이 1280×768이 아닐 때:
  - `k = min(W/1280, H/768)`, `off = ((W - 1280k)/2, (H - 768k)/2)`
  - 화면 위치는 `off + (ax, ay)·k`, 크기는 `(w, h)·k`입니다. 배경도 같은 `k`로 그립니다(비율 유지, 남는 곳은 여백).
  - 가장 쉬운 방법: 1280×768 크기 `Control`(이름 예: `InteriorCanvas`) 하나에 좌표를 그대로 넣고, 그 Control의 `scale = Vector2(k, k)`, `position = off`로 맞춥니다.
- `flip_h`가 true이면 좌우를 뒤집습니다(지금 5성은 모두 false입니다).
- 텍스처 필터는 선형으로 둡니다. 건물 노드는 `mouse_filter = IGNORE`로 둡니다(CH-3에는 건물 클릭이 없습니다).
- 잘림: 에도 민가(z 28)는 아래로 32px, 교토 민가(z 25)는 오른쪽으로 32px 캔버스 밖으로 나갑니다. 참고 그림도 똑같이 잘려 있으니, 캔버스 영역에서 잘라(`clip_contents`) 그대로 둡니다(결정 D7).

## 4. 항목 종류별 처리
| 종류(`kind` / `draw_as` 등) | 처리 |
|---|---|
| `building`, `sprite` | `WorldMapCityBuildingAssets.load_texture(building_key, region_style)`로 불러와 그립니다. null이면 그 칸을 건너뛰고 오류를 내지 않습니다. |
| `building`, `overlay_piece`(성벽 강화·해자·이중 해자) | 지금은 성마다 **1조각씩만** 정해진 자리에 있습니다. 일반 그림과 똑같이 그립니다. 둘레 전체를 반복해서 까는 일은 이번 범위가 아닙니다. |
| `slot_candidates`가 있는 항목(시장, 교토 무역항) | 같은 자리에 들어가는 후보 목록입니다. 앞에 있을수록 높은 단계입니다. CH-3에서는 배치표에 적힌 그림(대형시장, 무역항)을 그립니다. CH-4가 "완료된 가장 높은 단계 하나"를 고를 때 이 목록을 씁니다. 노점시장·상설시장(128px)도 같은 발 자리를 씁니다. |
| `compare_only: true`(교토 항구 1개) | 원래 비교용으로 따로 놓은 그림입니다. **그리지 않습니다**(결정 D4). |
| `coastal_only: true`(교토 해안 7종) | 그 도시가 해안일 때만 그립니다. 교토는 해안이라 켜지고, 다른 4성에는 이 항목이 없습니다. 해안 판정은 main 값을 읽기만 합니다(main 쓰기 금지). |
| `decoration`(민가) | `texture`의 `res://` 경로에서 바로 불러옵니다. 테크와 상관없이 늘 그립니다. |
| 배경 | `background` 경로를 캔버스 맨 아래에 1280×768로 그립니다. |
| `slots_inactive` | 정보용입니다(해자가 없는 이유 등). 그리지 않습니다. |

- 이번에 그리지 않는 것: 철옹성(`mil_iron_fortress`, 배치표에 자리가 없음), 바닥 그림자(결정 D6).

## 5. 고칠 파일 (목록 밖이 필요하면 멈추고 보고)
1. `assets/worldmap/city_buildings/`에 2절의 파일 20개와 `.import` 19개를 추가합니다(D5가 "교체"이면 PNG 24장을 덮어씁니다).
2. 새 파일 `scripts/worldmap/ui/worldmap_city_interior_layouts.gd`(+`.uid`), `class_name WorldMapCityInteriorLayouts`:
   - `has_layout(city_id) -> bool`
   - `get_layout(city_id) -> Dictionary`(없으면 `{}`)
   - `items_for_city(city_id, is_coastal: bool) -> Array`: `compare_only` 항목을 빼고, 해안이 아니면 `coastal_only` 항목도 뺍니다. 순서는 그대로 둡니다.
   - `canvas_transform(area_size) -> {k, off}`
   - 파일은 `FileAccess.get_file_as_string` + `JSON.parse_string`으로 한 번만 읽고 담아 둡니다.
3. CH-2 컨트롤러 `scripts/worldmap/ui/worldmap_city_interior_controller.gd`:
   - 창이 열릴 때 `has_layout`이 true이면 배치표로 그리고, false이면 기존 임시 격자로 그립니다.
   - 다른 도시로 바뀌면 이전 그림 노드를 지우고 다시 그립니다.
   - 창을 닫으면 텍스처 참조를 놓습니다.
4. 새 테스트 `tests/scripts/test_worldmap_city_interior_layouts.gd`(+`.uid`)를 추가합니다. 결과 줄은 `[CITY_INTERIOR_LAYOUT] checks=N failures=[]` 형식입니다.
5. `.github/workflows/verify-c-track.yml`: CH-2에서 쓴 방식대로 새 테스트 한 줄만 추가합니다.
6. 보고서 `agent/REPORT_CITYHUD_CH3_20261105.md`(`[skip ci]` 커밋)

## 6. 바꾸지 않는 것
- `scripts/worldmap/worldmap_main.gd`(0줄), `worldmap3d/` 전부, CH-2의 열기 조건·닫기·Esc·입력 차단·레이어 번호, `WorldMapCityBuildingAssets`의 키와 경로, CH-1 그림(D5 교체만 예외)
- 배치표 좌표: 이상해 보여도 고치지 말고 보고서에 적습니다. 좌표 수정은 록비서 쪽에서 새 버전으로 냅니다.
- 3D 월드맵 화면, 기존 HUD 위치, 테크 데이터
- 정본 가지 push, force push, 새 가지 만들기

## 7. 합격 기준
**자동(CI, 헤드리스)**
1. JSON을 읽을 수 있고 성이 정확히 5개입니다. 성마다 건물·민가 수가 1절 표와 같습니다(19+11, 19+9, 20+9, 21+8, 26+5).
2. 모든 `building_key`가 `WorldMapCityBuildingAssets.BUILDING_KEYS` 안에 있고, 그림·배경·민가가 모두 `ResourceLoader.exists`로 확인됩니다.
3. 성마다 `ay`가 줄지 않는 순서이고, `ax == x + w/2`, `ay == y + h`, `w == round(src_w·1.25)`입니다.
4. 창을 실제로 열었을 때 그려지는 노드 수가 맞습니다. 교토는 30개(건물 25, 항구 비교본 제외 + 민가 5)이고, 나머지 4성은 배치표 수 그대로입니다. 노드마다 `k = 1`에서 왼쪽 위가 `(ax - w/2, ay - h)`와 1px 이내입니다.
5. 창 크기를 하나 더 바꿔서(예: 960×576, k = 0.75) 위치가 공식대로 1px 이내인지 봅니다.
6. 배치표가 없는 도시(`gyeongju` 하나와, 테스트에서 내 도시로 설정한 `karakorum`): 카라코룸은 CH-2 규칙대로 열리지 않습니다(`no_art`). 경주는 임시 격자로 열립니다.
7. 해안이 아닌 성에서 `coastal_only` 항목이 그려지지 않습니다. 교토는 해안 7종이 그려집니다.
8. 닫기·Esc를 누르면 월드맵으로 돌아오고, 입력 차단이 풀립니다(CH-2 검사가 계속 통과).
9. CH-1 테스트 482, CH-2 테스트, 정적 검증기 72/72, 3D 테스트 8종이 모두 그대로 통과합니다. C-track 4 shard가 success입니다.

**그림 비교(클코드 PC, 화면 있는 실행, 결과만 보고서에)**
10. 5성 각각 `k = 1`로 캔버스를 캡처해서 `reference/<city_id>_interior_noshadow_repo.png`와 비교합니다.
    - 건물마다 위치 차이가 2px 이내여야 합니다. 눈으로 겹쳐 보거나 픽셀 평균 차이로 확인합니다.
    - 비교 기준 그림:
      - `_noshadow_repo`: 지금 레포에 있는 그림(24장은 v1)으로 만든 그림입니다. D5에서 교체했다면 `_noshadow_v2`와 비교합니다.
      - `_interior.png`: 원래 참고 그림입니다. 바닥 그림자가 들어 있어서 조금 다르게 보이는 것이 정상입니다.

**김작님 F6**: CH-2 지시서대로 CH-4 뒤에 한 번에 봅니다. 그때 볼 항목은 "5성 각각 참고 그림처럼 보이는지, 다른 도시는 격자인지, 닫으면 월드맵으로 돌아오는지"입니다.

## 8. 김작님이 먼저 정할 것 (괄호 안이 록비서 추천 기본값)
- **확정** 대상은 5성만입니다. 카라코룸과 배치표가 없는 도시는 CH-2 임시 격자를 씁니다(카라코룸은 창이 열리지 않음). 몽골 세트(게르, 목책, 초원)는 나중에 따로 만듭니다.
> **김작님 확정 (2026-11-05 22:26 KST): D1~D7 모두 괄호 안 추천대로 진행합니다.** D5는 "교체"입니다.

- **D1** 5개 배치표를 게임 속 같은 이름 도시에 붙입니다(한성·평양·건업·에도·교토). 나머지 7개 kr/cn/jp 도시에 같은 지역 배치표를 빌려 쓸지 정해야 합니다. (빌려 쓰지 않고 격자 유지. 빌려 쓸 경우 후보: 경주·사비 → 한성, 낙양·업성·성도 → 건업, 오사카 → 에도, 큐슈 → 교토)
- **D2** 새 파일 20개(+`.import` 19개)를 CH-1 폴더 `assets/worldmap/city_buildings/`에 같이 둘지 정해야 합니다. (같이 둠. 새 폴더를 만들지 않습니다)
- **D3** 성 밖에 놓은 건물을 그대로 둘지 정해야 합니다. 건업 대상단(서문 밖 다리 앞), 에도 대상단·조폐소(다리 건너 성하 마을), 에도 창고·대장간(남동 해자 밖), 각 성의 들판 5종(성 밖)이 해당합니다. (그대로 둠. 성 안이 좁아서 일부러 밖에 둔 것입니다)
- **D4** 교토 항구와 무역항을 같은 자리에서 바꿔 쓸지 정해야 합니다. (같은 자리, 무역항 발 자리 (672, 736)에서 완료된 높은 단계 하나만 표시. 따로 둔 항구 비교본은 쓰지 않음. 조선소는 자기 자리 유지)
- **D5** 레포의 그림 24장이 v1이라 참고 그림(v2)과 다릅니다. v2로 바꿀지 정해야 합니다. (바꿈, CH-3 안에서 따로 커밋. 이름과 크기가 같아 코드는 그대로입니다)
- **D6** 참고 그림의 바닥 그림자를 넣을지 정해야 합니다. (CH-3에서는 넣지 않고, 나중에 외형 단계에서 넣음)
- **D7** 캔버스 밖으로 32px 잘리는 민가 2채(에도·교토)를 그대로 둘지 정해야 합니다. (그대로 둠. 참고 그림과 같음)
