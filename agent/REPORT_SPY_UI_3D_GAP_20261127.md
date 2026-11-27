기준 화면: `WorldMap.tscn`(F6, 3D 월드맵) — 적 도시(평양) 클릭 → 도시 행동 메뉴 → [첩보].
합격 기준: 없음(조사 보고서만, 코드 변경 0). 고치는 일은 나중에 중앙 상단 HUD에 외교·첩보·무역을 한꺼번에 연결할 때 같이 한다(김작 11-27).

# REPORT_SPY_UI_3D_GAP — 3D 월드맵에서 [첩보]를 눌러도 '첩보 실행' 카드가 안 보이고, 메뉴가 도시 옆에 안 뜬다 (클코드, 2026-11-27)

- **됐나**: 원인 조사만 했다. 코드·시험·설정 변경 0.
- **증상(김작 F6, `feature/wm3d-spy-intel-20261127` @ `d7a9b3c`)**: 적 도시 평양을 누르고 [첩보]를 눌러도 화면이 바뀌지 않는다. 도시 행동 메뉴는 도시 옆이 아니라 화면 왼쪽 위에 뜬다.
- **결론**:
  1. '첩보 실행' 카드(정탐·민심 교란·충성도 교란·반란 조장·이간질)는 만들어지고 `visible = true`가 되지만, 카드가 들어 있는 옛 통합 창 `WorldMapUI/CityDetailPanel`을 HUD가 **늘 숨겨 둔다**.
  2. **`main` `8cc0640`에서도 똑같다** — 큐 36(P0)·37(P3) 작업 때문에 생긴 것이 아니다.
  3. 메뉴는 **숨겨진 2D 지도의 도시 표식 좌표**로 놓이므로 3D 도시 옆에 뜨지 않는다.

## 1. 재현 방법 [사실]
- 정본 폴더는 건드리지 않고, `d7a9b3c`와 `main` `8cc0640`을 각각 임시 작업 트리로 꺼내 같은 확인 스크립트(저장소에 남기지 않음)를 Godot 4.6.2 헤드리스로 돌렸다.
- 순서: 새 게임(player/한성) → 실제 `WorldMap.tscn` → 평양 2D 표식의 `city_selected` 신호를 보냄(3D 클릭과 같은 경로, 2절) → 메뉴 컨트롤러 `_on_contextual_action_pressed("spy")` 호출 → 몇 프레임 뒤 상태 기록.
- 두 커밋의 출력이 **글자 그대로 같다**:

| 항목 | `d7a9b3c` | `8cc0640` |
|---|---|---|
| 평양 2D 표식 | `visible=true`, `in_tree_visible=false`(부모 `WorldMapRoot`가 숨김) | 같음 |
| 메뉴 | `visible=true`, `position=(976.37, 224.62)`, 화면 1920×1080 | 같음 |
| [첩보] 뒤 상태 | `contextual_type=spy`, `primary_tab=diplomacy-spy`, `spy_tab=spy` | 같음 |
| `SpyActionCard` | `visible=true`, **`in_tree=false`** | 같음 |
| 카드 부모 사슬 | `WorldMap_Test / WorldMapUI[보임] / CityDetailPanel[숨김] / MarginContainer / Content / SpyActionCard[보임]` | 같음 |
| `CityDetailPanel` | 누르기 전·후 모두 `visible=false` | 같음 |

## 2. 원인
### 2-1. 카드가 안 보임 — `CityDetailPanel`이 HUD에 늘 숨겨져 있다 [사실]
- [첩보] → `worldmap_city_action_controller.gd:210~220` `_on_contextual_action_pressed("spy")` → `worldmap_main.gd:2259` `open_contextual_worldmap_action("spy", 도시)`: 통합 창을 펼치고(`_set_unified_city_panel_collapsed(false)`), 위 탭을 '외교·첩보', 아래 탭을 '첩보'로 바꾸고 `_refresh_unified_panel_content()`.
- 그 결과 `worldmap_main.gd:3803~3814` `_show_unified_diplomacy_spy_content` → `4280~4310` `_refresh_spy_action_card`가 카드를 채우고 `_spy_action_card.visible = true`(4290행).
- 그런데 카드는 `worldmap_main.gd:4242`에서 `city_detail_content_container`(= `WorldMapUI/CityDetailPanel/MarginContainer/Content`)에 붙는다.
- `scripts/worldmap/ui/worldmap_hud_presentation_controller.gd:27~32` `WORLD_UI_ALWAYS_HIDDEN = ["WorldTitlePanel", "CityDetailPanel", "DiplomacySpyPanel", "InstructionLabel"]`를 71~74행이 설치 때 한 번 `visible = false`로 만든다. 이 컨트롤러는 `WorldMap.tscn`에만 있고, 그 뒤 `CityDetailPanel`을 다시 보이게 하는 코드는 저장소 어디에도 없다(`city_detail_panel.visible`/`show()` 쓰기 0건). 통합 창 접기·펼치기(`_set_unified_city_panel_collapsed`, 14064행)는 창 안의 자식만 켜고 끈다.
- 이 목록은 `d807ed6`(P-1B-2, 2026-09-19 "add production WorldMap HUD presentation controller")에서 들어왔다. 3D 월드맵·큐 36·37보다 앞선다.
- 같은 창 안에 외교 카드(`_diplomacy_action_card`)도 있으므로 **[외교]도 같은 이유로 안 보일 것**이다[추정 — 재현은 [첩보]만 했다]. [무역]은 수동 교역 창 경로가 달라 확인하지 않았다[미확인].

### 2-2. 메뉴가 3D 도시 옆에 안 뜸 — 숨겨진 2D 지도 좌표를 쓴다 [사실]
- 3D 지도 클릭은 `scripts/worldmap/map3d/worldmap_3d_adapter.gd:91~100`에서 **2D 표식의** `city_selected`를 대신 보낸다("2D 클릭과 같은 신호").
- 메뉴 컨트롤러는 그 2D 표식의 캔버스 좌표로 자리를 잡는다: `worldmap_city_action_controller.gd:172` `_selected_marker.get_global_transform_with_canvas().origin` → 178~181행에서 표식 위 54px, 화면 가장자리 8px 안으로 끌어당김.
- 3D 모드에서는 2D 지도(`WorldMapRoot`)가 숨겨져 있어(1절 표) 이 좌표는 3D 화면의 도시 자리와 관계가 없다. 헤드리스 재현에서는 (976, 224)였다.
- [추정] F6 화면에서는 2D 좌표가 화면 밖으로 나가고, 8px 끌어당김 때문에 (8, 8) = 왼쪽 위에 붙는다. 확인하려면 F6에서 그 좌표를 한 번 출력하면 된다.
- 참고(고칠 때 재료): 3D 쪽에는 카메라(`worldmap3d/scripts/worldmap3d_root.gd`의 `camera`)와 3D 도시 표식(`markers[cid]`, `_place_city` 460행)이 있어 `camera.unproject_position(...)`으로 화면 좌표를 얻을 수 있다.

### 2-3. 시험이 못 잡은 이유 [사실]
- 정탐·외교 라우팅 시험(`test_worldmap_spy_routing.gd`, `test_worldmap_diplomacy_routing.gd`)은 HUD 표시 컨트롤러가 없는 `WorldMap_16x9_Test.tscn`에서 돌고, 숨겨진 버튼도 `pressed.emit()`으로 직접 누른다. 그래서 "화면에 실제로 보이는가"(`is_visible_in_tree`)는 어느 시험도 보지 않는다.

## 3. 결정 (김작 11-27)
- **지금은 고치지 않는다.** 첩보 카드 표시와 메뉴 위치는 나중에 **중앙 상단 HUD에 외교·첩보·무역을 한꺼번에 연결할 때** 같이 한다.
- 그때 함께 볼 것: ① 카드가 들어갈 자리(지금은 숨겨진 `CityDetailPanel` 안) ② 메뉴 위치를 3D 카메라 투영으로 ③ 실제 `WorldMap.tscn`에서 카드가 `is_visible_in_tree()`이고 메뉴가 도시 근처인지 보는 시험 ④ [외교]·[무역]도 같은 확인.

## 4. 이 보고서가 바꾼 것
- 파일 1개(이 보고서)만, `[skip ci]`. 정본 폴더의 작업 트리와 체크아웃은 그대로(김작 F6 중). 커밋은 정본 폴더 작업 트리를 건드리지 않는 방식(임시 인덱스 + `commit-tree`)으로 만들어 `feature/wm3d-spy-intel-20261127`에만 올렸다.
