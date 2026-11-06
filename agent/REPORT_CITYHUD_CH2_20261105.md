기준 화면: 정본이 아닌 작업 가지 `feature/wm3d-cityhud-20261105`(코드 커밋 `ffb8778`)에서 `res://WorldMap.tscn` F6 → 내 도시를 클릭하면 도시 패널이 갱신되고 성 안 창(빈 틀, "도시 이름 — 성 안", 닫기 버튼, 안내 글)이 열린다. 적 도시·카라코룸·대상 고르는 중·전투 진입 연출 중·모달이 열린 동안에는 열리지 않는다.
합격 기준: 지시서 `agent/ORDER_CITYHUD_CH2_WINDOW_20261105.md` — 새 테스트 + CI 등록 통과, `worldmap_main.gd` 변경 0줄, 변경 경로가 5절 목록 안, C-track 4 shard success. 김작 F6는 CH-4 뒤 한 번에.

# 보고서 — CITYHUD CH-2: 성 안 창 틀과 열기 조건 (main 0줄)

## 요약 (3줄)
1. 됐나: 됐다. 컨트롤러 노드 1개를 `WorldMap.tscn` 루트 자식으로 붙였다(main 0줄, `worldmap3d/` 0줄). 새 테스트 `checks=73 failures=[]`, 검증기 72/72(커밋 뒤 깨끗한 트리), CI는 아래 표.
2. 코드 커밋 `ffb8778`(tree `041cedf355077a77818bff412417546650ca9bae`), 가지 `feature/wm3d-cityhud-20261105`, 원격 해시 = 로컬 HEAD.
3. 막힌 것: ① 2D 카메라 WASD 차단은 목록 밖 파일이 필요해서 못 했다(아래 "막힌 것"). ② "성 안 보기" 버튼은 headless로 빈 자리를 확정할 수 없어 만들지 않았다(좌표 후보만). ③ 이 가지의 roundtrip 테스트는 시작점부터 깨져 있다(6번 수리가 m7prep 가지에만 있음, CH-2와 무관 — 기준 커밋에서 같은 결과로 확인).

## 진행 기록 (정본 `PROGRESS_WM3D.md` 대신 여기에 쓴다, 큐 9절)
- 2026-11-05 — 큐 9번 시작(가지 끝 `ef509c1` 확인) → 1절 읽기 전용 조사 → 구현 → 로컬 검증 → 코드 커밋 `ffb8778` push → CI.
- 마지막 코드 커밋: `ffb8778` / 이 보고서: `agent/REPORT_CITYHUD_CH2_20261105.md` / CI: 아래 4절.
- 다음 할 일: 큐 10번 `ORDER_MERGE_MAIN_20261105.md`.

## 택한 해석
- [사실] 지시서의 "`_on_city_marker_selected`(1395행)"은 지금 정본에서 1395행이 `_connect_city_markers`이고 `_on_city_marker_selected`는 1405행이다. 이름과 역할은 같아서 진행했다(행 번호만 다름).
- [사실] `_pending_invasion_*`(803~806)는 상태값이 아니라 UI 위젯이다. 대신 상태 함수 `_has_pending_invasion_event_mvp()`(main:6679)를 조건으로 썼다.
- 더 엄격한 쪽으로 조건을 늘렸다: 턴 단계(플레이어 차례가 아니면 거부), 대기 중인 전투 문맥, 종국 결과, 기술 완료 카드, 도움말 창, 무역 주문/내부 이송 패널, T05 결과 연출.
- 창 밖(투명 막) 클릭은 닫지 않는다(지시서 2-2). Esc는 창이 열려 있을 때만 먹는다.
- 입력 차단은 기존 3D 카메라 컨트롤러의 `input_blocked`(불리언 하나)만 쓴다. 새 메커니즘을 만들지 않았다.
- 붙이는 자리: 호스트가 만드는 방식보다 `WorldMap.tscn` 노드 1개(ext_resource 1 + 노드 1)가 변경이 작아서 그쪽을 택했다(호스트·호스트 테스트 무변경).
- 컨트롤러는 main 메타(`wm_city_interior_controller`)로 한 main에 하나만 붙는다(테스트 장면이 WorldMap을 인스턴스해도 중복 연결 없음).

## 1. 읽기 전용 확인

### 1-1. "대상 고르는 중"·열기 거부 조건 완전 목록 [사실, 정본 main 확인]
| 종류 | main 이름 | 거부 이유 문자열 | 근거 |
|---|---|---|---|
| 상태 bool | `_contextual_worldmap_action_pending` | `busy:_contextual_worldmap_action_pending` | 지시서 후보 |
| 문자열 | `_pending_diplomacy_action_id` | `busy:…` | 지시서 후보 |
| 문자열 | `_pending_spy_action_id` | `busy:…` | 지시서 후보 |
| 문자열 | `_pending_trade_action_id` | `busy:…` | 지시서 후보 |
| 노드 visible | `_player_attack_deployment_panel` | `busy:…` | 지시서 후보 |
| 함수 true | `_has_pending_invasion_event_mvp()` | `busy:…` | `_pending_invasion_*` 대신(위젯이라서) |
| 함수 비어있지 않음 | `_get_pending_battle_context_mvp()` | `busy:…` | 추가 |
| 상태 bool | `_enemy_turn_mvp_pending` | `busy:…` | 지시서 후보 |
| 상태 bool | `_domestic_turn_apply_pending` | `busy:…` | 지시서 후보 |
| 턴 단계 | `_player_state.turn_phase`(`_normalize_turn_phase`) | `busy:_player_state` | 추가 |
| 그림 없음 | `WorldMapCityBuildingAssets.region_style_for_region_key` | `no_art` | 지시서 조건 3 |
| 전투 진입 연출 | `_ensure_camera_controller().is_battle_entry_handoff_in_progress()` | `battle_entry_handoff` | 지시서 조건 4 |
| 모달 | `_is_domestic_tech_tree_overlay_open_mvp()` | `modal:…` | 지시서 조건 5 |
| 모달 | `_is_domestic_tech_completion_card_visible()` | `modal:…` | 추가 |
| 모달 | `_has_terminal_korea_outcome_mvp()` | `modal:…` | 추가 |
| 모달 | `_manual_trade_order_panel` / `_internal_trade_transfer_panel` / `_t05_outcome_presentation_root` (visible) | `modal:…` | 추가 |
| 모달 | 도움말 창 `_ensure_shared_ui_controller().is_help_modal_visible()` | `modal:_ensure_shared_ui_controller` | 추가 |

- [사실] 도시 클릭이 "대상 지정"으로 쓰이는 별도 모드는 없다. 마커 클릭마다 `cancel_contextual_worldmap_action`이 contextual·pending 값을 지운다(`city_action_controller.gd:125-126`). 그래서 컨트롤러는 main 처리 **뒤**(`CONNECT_DEFERRED`)에 위 값을 읽는다.
- [사실] 조건에 넣지 않았지만 전체 화면 STOP 막이 있어 클릭이 마커까지 가지 않는 것: T03 연출, 행동 연출 오버레이, 외교 코디네이터, 턴 요약 팝업, 오디오 설정 팝업.
- 테스트는 위 이름과 그 밖에 쓰는 `_city_markers_by_id`·`_camera_controller`·`_is_city_owned_by_player_mvp`·`_ensure_camera_controller`·`_normalize_turn_phase`가 main에 존재하는지 검사한다.

### 1-2. 도시 클릭 처리 순서 [사실]
- 2D 마커 클릭과 3D 어댑터가 넘기는 선택이 같은 `city_selected` 신호를 낸다. main은 `_connect_city_markers`에서 즉시 연결, 컨트롤러는 `CONNECT_DEFERRED`로 연결 → main 처리 뒤에 실행된다.
- 검증: 테스트에서 클릭 직후 main의 `selected_city_id`가 이미 바뀌어 있고(main이 먼저 처리), 창이 열리는 것을 확인. 마커당 연결 1개(중복 0).

### 1-3. 붙이는 자리 [사실]
- `WorldMap.tscn` 루트 자식 노드 `WorldMapCityInteriorController`(`main_path = ".."`). 루트 자식은 main보다 먼저 `_ready`가 불리므로 `await main.ready` 뒤 마커를 연결한다(호스트 방식).
- 다른 장면 영향: `WorldMap3D_Host_Test.tscn`·`WorldMap_16x9_Test.tscn`·`WorldMap_UI_Test.tscn`은 WorldMap을 통해 같은 노드가 들어간다. 장면 로드 오류는 기준 커밋과 같다(6절).

### 1-4. 입력 차단 수단 [사실]
- 3D: `WorldMap3DCameraController.input_blocked`(키보드 축 차단, 기존). main은 이 값을 쓰지 않는다. 컨트롤러가 열 때 true, 닫을 때·`_exit_tree`에서 false(불리언 하나, 어느 컨트롤러에 걸었는지 기억).
- 마우스: 창 뒤 전체 화면 `Control`(`MOUSE_FILTER_STOP`)이 GUI 단계에서 클릭·휠을 먹는다 → `_unhandled_input`의 지도 입력에 가지 않는다.
- 2D 키(WASD): 2D 컨트롤러에는 차단 플래그가 없고 `_is_keyboard_camera_blocked`는 LineEdit/TextEdit 포커스일 때만 true → **막힌 것**(아래).

### 1-5. 레이어와 빈 자리 [사실]
- 쓰이는 `CanvasLayer.layer`: -10, 1, 35, 40(TopNav), 60(테크트리 오버레이), 80, 90, 100. 새 창은 **50**(빈 값, 감사 제안 45~55 안).
- "성 안 보기" 버튼: 패널들이 끌어서 옮길 수 있고 headless로 실제 화면의 빈 자리를 확정할 수 없어 **만들지 않았다**. 좌표 후보 [추정]: 왼쪽 패널 아래(x 48~368, y > 약 740) 또는 화면 아래 가운데.

### 1-6. Esc 사용처 [사실]
| 위치 | 하는 일 |
|---|---|
| `worldmap_main.gd:1068-1121` `_input` | 전투 진입 건너뛰기, 테크트리 오버레이·도움말 창 닫기 등 |
| 행동 연출 오버레이(70-76) | 연출 건너뛰기 |
| 턴 요약 팝업(101-114) | 팝업 닫기 |
| 오디오 설정(113-116) | 창 닫기 |
| worldmap3d 테스트 HUD | 입력칸 포커스 해제 |
- 새 컨트롤러는 루트 자식이라 `_input`이 main보다 먼저 불린다. 창이 열려 있을 때만 Esc를 먹고(`set_input_as_handled`), 닫힌 상태의 Esc는 그대로 main에 간다(테스트: 닫힌 상태 Esc로 main이 도움말 창을 닫음).

## 2. 새 테스트가 확인하는 것
`tests/scripts/test_worldmap_city_interior_window.gd` — 실제 `WorldMap.tscn`, `host.set_map_view_3d(false)`로 2D.
- main 이름 존재, 마커당 지연 연결 1개
- 한성 클릭 → 열림·main이 먼저 처리·제목 "한성 — 성 안"; 같은 도시 재클릭 → `already_open`(창 1개); 적 도시 → `not_own_city`; 경주로 갱신
- 닫기 버튼, Esc(`root.push_input`)로 닫힘; 닫힌 상태 Esc는 main에 도달
- 가짜 3D 카메라 컨트롤러로 차단/해제, 전투 진입 연출 중 → `battle_entry_handoff`
- 카라코룸(내 도시로 설정) → `no_art`
- 1-1 표의 모든 플래그·문자열·패널·턴 단계·모달·도움말 조건을 하나씩 켜서 거부, 끄면 다시 열림
- main 스냅샷(`selected_city_id`·선택/출발 도시 키) 불변
- `_exit_tree`에서 차단 해제·메타 제거

## 3. 로컬 검증 (결과 줄 원문)
| 항목 | 결과 |
|---|---|
| 새 테스트, 고치기 전(노드 없음) | `[CITY_INTERIOR] checks=3 failures=["controller node exists in WorldMap.tscn"]` exit=1 |
| 새 테스트, 고친 뒤 | `[CITY_INTERIOR] checks=73 failures=[]` exit=0 (로컬 약 15초) |
| 변조 시험(`_pending_trade_action_id` 조건·차단 호출 제거) | exit=1, 실패 3개 → 원본 복원, 동일 확인 |
| CH-1 테스트 | `[CITY_BUILDING_ASSETS] checks=482 failures=[]` exit=0 (약 1초) |
| 검증기, 작업 트리 | `validators=72 pass=71 fail=1` — `validate_worldmap_trade_phase2_extraction.py: FAIL: UI/scene restoration or modification detected`(지시서가 말한 알려진 구조) |
| 검증기, 커밋 뒤 깨끗한 트리 | `validators=72 pass=72 fail=0` |
| `test_worldmap_diplomacy_routing` | `[DIPLOMACY_ROUTING] PASS: 172 checks, 0 failures` exit=0 — 기준 커밋 `ef509c1`에서도 172(지시서의 131은 옛 값) |
| `test_worldmap_battle_main_roundtrip_settlement` | 8 PASS 뒤 `SCRIPT ERROR: Invalid call. Nonexistent 'bool' constructor.`(테스트 82행, 없어진 `_worldmap_battle_entry_handoff_in_progress` 읽기) → 끝나지 않음. **기준 커밋 `ef509c1`에서도 똑같다**(8 PASS, 같은 오류). 6번 수리(`add66d5`)는 m7prep 가지에만 있다. CI 목록에 없는 테스트 |
| 3D 테스트 8종 | adapter 56/0, camera_controller 61/0, camera_external_input 20/0, color_parity 57/0, host 58/0, mem_probe 37/0, production 28/0, roads 121/0 (모두 exit 0) |
| 장면 `--quit-after 5` | WorldMap 오류 0, WorldMap3D_Host_Test 0, WorldMap_UI_Test 0, WorldMap_16x9_Test 1(`1 resources still in use at exit` — 기준 커밋에서도 같은 줄) |
| `git diff --check` | 출력 없음 |
| `worldmap_main.gd`·`worldmap3d/` | 변경 0 |

## 4. CI [사실]
| 워크플로 | run | 결과 | job |
|---|---|---|---|
| Verify C-track refactor | `42039750164` | success | shard 0 `127287133031` success / shard 1 `127287133089` success / shard 2 `127287133110` success / shard 3 `127287133128` success |
| Verify WorldMap3D | `42039750217` | success | worldmap3d `127287134091` success (`WorldMap.tscn` 변경으로 경로 조건에 걸려 실행됨) |

- 새 테스트가 CI에서 실제로 돌았다(job 로그 원문): shard 2 `[CITY_BUILDING_ASSETS] checks=482 failures=[]`, shard 3 `[CITY_INTERIOR] checks=73 failures=[]`.
- 목록 위치: "Diplomacy Trade Spy" 목록 끝에 두 줄 추가 → 공통 인덱스 198·199 → `index % 4`로 shard 2·3(추가 전 198개, shard 2·3이 각 49개로 가장 가벼운 쪽). 로컬 소요 1초·15초로 `timeout 300s` 안. 컷인 예외 관찰 없음.

## 5. 바뀐 파일 (5절 목록 안)
```
 .github/workflows/verify-c-track.yml               |   2 +
 WorldMap.tscn                                      |   5 +
 .../ui/worldmap_city_interior_controller.gd        | 284 +++++++++++++++++++++
 .../ui/worldmap_city_interior_controller.gd.uid    |   1 +
 .../scripts/test_worldmap_city_interior_window.gd  | 251 ++++++++++++++++++
 .../test_worldmap_city_interior_window.gd.uid      |   1 +
 6 files changed, 544 insertions(+)
```

## 6. 막힌 것
1. **2D 카메라 WASD 차단**: 2D 카메라 컨트롤러(`scripts/worldmap/camera/worldmap_camera_controller.gd`)에 차단 플래그가 없다. 막으려면 이 파일(목록 밖)에 `input_blocked`를 두어야 한다. 제안: 3D 쪽 플래그를 2D 기본 클래스로 올리기(3D는 상속). 지금 2D에서 창이 열려 있어도 WASD로 지도가 움직인다(클릭·휠은 막힘). 클코치 판단 필요.
2. **"성 안 보기" 버튼**: 만들지 않음(1-5).
3. 2D/3D 전환으로 3D 컨트롤러가 바뀌는 경우: 전환 버튼이 있는 TopNav(40)가 창(50) 아래라 창이 열린 동안에는 전환할 수 없다.

## 7. 김작 F6 안내 (CH-4 뒤 한 번에)
① 한성 클릭 → 창 열림·도시 패널 갱신 ② 적 도시·카라코룸 클릭 → 안 열림 ③ 외교·무역 대상 고르는 중 클릭 → 안 열림 ④ 열린 동안 지도 클릭·휠·(3D) WASD 무반응 — 2D WASD는 6절 1번 때문에 움직인다 ⑤ 닫기·Esc 후 정상 ⑥ 2D 설정에서도 같음.

## 8. diff 전체 (`git show ffb8778`)
```diff
diff --git a/.github/workflows/verify-c-track.yml b/.github/workflows/verify-c-track.yml
index 8525b22..bcc2554 100644
--- a/.github/workflows/verify-c-track.yml
+++ b/.github/workflows/verify-c-track.yml
@@ -410,6 +410,8 @@ jobs:
             tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd
             tests/scripts/test_worldmap_spy_routing.gd
             tests/scripts/test_worldmap_spy_controller_extraction.gd
+            tests/scripts/test_worldmap_city_building_assets.gd
+            tests/scripts/test_worldmap_city_interior_window.gd
           )
           index=$(cat "$RUNNER_TEMP/ci_test_index" 2>/dev/null || echo 0)
           for test_script in "${tests[@]}"; do
diff --git a/WorldMap.tscn b/WorldMap.tscn
index 10d104d..944623e 100644
--- a/WorldMap.tscn
+++ b/WorldMap.tscn
@@ -25,6 +25,7 @@
 [ext_resource type="Script" uid="uid://8u164ks1duu8" path="res://scripts/worldmap/ui/worldmap_turn_summary_controller.gd" id="25_turn_summary"]
 [ext_resource type="Script" uid="uid://cwuec8hllnb4l" path="res://scripts/worldmap/ui/worldmap_character_speech_controller.gd" id="26_character_speech"]
 [ext_resource type="Script" uid="uid://b0b5t7tlst25s" path="res://scripts/worldmap/map3d/worldmap_3d_host.gd" id="27_worldmap3d_host"]
+[ext_resource type="Script" uid="uid://buk2hh5gvlbhg" path="res://scripts/worldmap/ui/worldmap_city_interior_controller.gd" id="28_city_interior"]

 [sub_resource type="AtlasTexture" id="AtlasTexture_worldmap_v2_a1"]
 atlas = ExtResource("2_worldmap_v2_master")
@@ -2343,3 +2344,7 @@ text = "새 게임"
 [node name="WorldMap3DHost" type="Node" parent="." unique_id=1726110508]
 script = ExtResource("27_worldmap3d_host")
 main_path = NodePath("..")
+
+[node name="WorldMapCityInteriorController" type="Node" parent="." unique_id=1843906217]
+script = ExtResource("28_city_interior")
+main_path = NodePath("..")
diff --git a/scripts/worldmap/ui/worldmap_city_interior_controller.gd b/scripts/worldmap/ui/worldmap_city_interior_controller.gd
new file mode 100644
index 0000000..d5795e3
--- /dev/null
+++ b/scripts/worldmap/ui/worldmap_city_interior_controller.gd
@@ -0,0 +1,284 @@
+class_name WorldMapCityInteriorController
+extends Node
+
+## CITY-HUD CH-2: the city interior window frame. Attached outside worldmap_main.gd as a root child of WorldMap.tscn
+## (like WorldMap3DHost). Listens to every city marker's `city_selected` (2D click and the 3D adapter's forwarded
+## pick emit the same signal) with CONNECT_DEFERRED, so main's own handler has already run. Opens only for the
+## player's own city when no target / turn / modal state is active; otherwise records why in last_reject_reason.
+## Reads main state only (get()/call()), never writes it. Main is held as a plain Node; no WorldMap3D* classes are named.
+## The window is built in code; building art goes in later steps (CH-3/CH-4).
+
+const MAIN_META := "wm_city_interior_controller"
+const WINDOW_LAYER := 50   # free between TopNav (40) and the tech tree overlay (60)
+const TURN_PHASE_PLAYER := "player"
+const WINDOW_SIZE := Vector2(960, 600)
+const PLACEHOLDER_TEXT := "건물 그림은 다음 단계에서 연결됩니다"
+const BUILDING_ASSETS_PATH := "res://scripts/worldmap/ui/worldmap_city_building_assets.gd"
+
+## Checked in this order after "own city". [kind, main member name]. Kinds: flag = bool true blocks,
+## text = non-empty String blocks, visible = node visible blocks, method_true = call() true blocks,
+## method_nonempty = call() non-empty Dictionary blocks, turn_phase = _player_state.turn_phase is not the player phase.
+const BUSY_GUARDS := [
+	["flag", "_contextual_worldmap_action_pending"],
+	["text", "_pending_diplomacy_action_id"],
+	["text", "_pending_spy_action_id"],
+	["text", "_pending_trade_action_id"],
+	["visible", "_player_attack_deployment_panel"],
+	["method_true", "_has_pending_invasion_event_mvp"],
+	["method_nonempty", "_get_pending_battle_context_mvp"],
+	["flag", "_enemy_turn_mvp_pending"],
+	["flag", "_domestic_turn_apply_pending"],
+	["turn_phase", "_player_state"],
+]
+const MODAL_GUARDS := [
+	["method_true", "_is_domestic_tech_tree_overlay_open_mvp"],
+	["method_true", "_is_domestic_tech_completion_card_visible"],
+	["method_true", "_has_terminal_korea_outcome_mvp"],
+	["visible", "_manual_trade_order_panel"],
+	["visible", "_internal_trade_transfer_panel"],
+	["visible", "_t05_outcome_presentation_root"],
+	["help_modal", "_ensure_shared_ui_controller"],
+]
+## Other main members this controller relies on (the test checks they still exist).
+const MAIN_MEMBERS := [
+	"_city_markers_by_id", "_camera_controller", "_is_city_owned_by_player_mvp", "_ensure_camera_controller",
+	"_normalize_turn_phase",
+]
+
+@export var main_path: NodePath = NodePath("..")
+
+var main: Node = null
+var last_reject_reason := ""
+var _open_city_id := ""
+var _connected_markers: Array = []
+var _blocked_camera_controller: Object = null   # the one controller whose input_blocked we set (one boolean, no count)
+var _layer: CanvasLayer = null
+var _title_label: Label = null
+var _close_button: Button = null
+var _building_assets: Script = null
+
+
+func _ready() -> void:
+	var m := get_node_or_null(main_path)
+	if m == null or not m.has_method("_is_city_owned_by_player_mvp"):
+		return
+	var owner_node = m.get_meta(MAIN_META) if m.has_meta(MAIN_META) else null
+	if owner_node != null and is_instance_valid(owner_node) and owner_node != self:
+		return   # another controller already serves this main
+	m.set_meta(MAIN_META, self)
+	main = m
+	if ResourceLoader.exists(BUILDING_ASSETS_PATH):
+		_building_assets = load(BUILDING_ASSETS_PATH)
+	if not main.is_node_ready():   # root child: main._ready builds the markers after us
+		await main.ready
+	_connect_markers()
+
+
+func _exit_tree() -> void:
+	_unblock_camera_input()
+	if main != null and is_instance_valid(main) and main.has_meta(MAIN_META) and main.get_meta(MAIN_META) == self:
+		main.remove_meta(MAIN_META)
+
+
+func is_open() -> bool:
+	return not _open_city_id.is_empty()
+
+
+func get_open_city_id() -> String:
+	return _open_city_id
+
+
+func get_title_text() -> String:
+	return _title_label.text if _title_label != null else ""
+
+
+func get_close_button() -> Button:
+	return _close_button
+
+
+func get_connected_marker_count() -> int:
+	return _connected_markers.size()
+
+
+## Tries to open (or retarget) the window for city_id. Returns true when the window shows that city afterwards.
+func try_open(city_id: String) -> bool:
+	var reason := get_reject_reason(city_id)
+	last_reject_reason = reason
+	if not reason.is_empty():
+		return false
+	_open_city_id = city_id
+	_ensure_window()
+	_title_label.text = "%s — 성 안" % _city_display_name(city_id)
+	_layer.visible = true
+	_block_camera_input()
+	return true
+
+
+## "" = may open. Checks in order: own city, busy/target state, building art, battle-entry handoff, modals.
+func get_reject_reason(city_id: String) -> String:
+	if main == null or not is_instance_valid(main):
+		return "no_main"
+	if city_id.is_empty() or not bool(main.call("_is_city_owned_by_player_mvp", city_id)):
+		return "not_own_city"
+	if is_open() and city_id == _open_city_id:
+		return "already_open"
+	for guard in BUSY_GUARDS:
+		if _guard_active(guard):
+			return "busy:%s" % guard[1]
+	if _region_style(city_id).is_empty():
+		return "no_art"
+	var camera_controller = main.call("_ensure_camera_controller")
+	if camera_controller != null and camera_controller.is_battle_entry_handoff_in_progress():
+		return "battle_entry_handoff"
+	for guard in MODAL_GUARDS:
+		if _guard_active(guard):
+			return "modal:%s" % guard[1]
+	return ""
+
+
+func close() -> void:
+	if not is_open():
+		return
+	_open_city_id = ""
+	if _layer != null:
+		_layer.visible = false
+	_unblock_camera_input()
+
+
+func _input(event: InputEvent) -> void:
+	if not is_open():
+		return
+	var key := event as InputEventKey
+	if event.is_action_pressed("ui_cancel") or (key != null and key.pressed and not key.echo and key.keycode == KEY_ESCAPE):
+		close()
+		get_viewport().set_input_as_handled()
+
+
+func _connect_markers() -> void:
+	var markers = main.get("_city_markers_by_id")
+	if not markers is Dictionary:
+		return
+	for marker in (markers as Dictionary).values():
+		if marker == null or not is_instance_valid(marker) or not marker.has_signal("city_selected"):
+			continue
+		var callable := Callable(self, "_on_city_selected")
+		if not marker.is_connected("city_selected", callable):
+			marker.connect("city_selected", callable, CONNECT_DEFERRED)
+			_connected_markers.append(marker)
+
+
+func _on_city_selected(marker: Node) -> void:
+	if marker == null or not is_instance_valid(marker):
+		return
+	try_open(str(marker.get("city_id")))
+
+
+func _guard_active(guard: Array) -> bool:
+	var kind: String = guard[0]
+	var member: String = guard[1]
+	match kind:
+		"flag":
+			return bool(main.get(member))
+		"text":
+			return not str(main.get(member)).is_empty()
+		"visible":
+			var node = main.get(member)
+			return node != null and is_instance_valid(node) and node is CanvasItem and (node as CanvasItem).visible
+		"method_true":
+			return bool(main.call(member))
+		"method_nonempty":
+			var value = main.call(member)
+			return value is Dictionary and not (value as Dictionary).is_empty()
+		"turn_phase":
+			var state = main.get(member)
+			var phase := str((state as Dictionary).get("turn_phase", TURN_PHASE_PLAYER)) if state is Dictionary else TURN_PHASE_PLAYER
+			return str(main.call("_normalize_turn_phase", phase)) != TURN_PHASE_PLAYER
+		"help_modal":
+			var shared_ui = main.call(member)
+			return shared_ui != null and shared_ui.has_method("is_help_modal_visible") and bool(shared_ui.is_help_modal_visible())
+	return false
+
+
+func _region_style(city_id: String) -> String:
+	if _building_assets == null:
+		return ""
+	var marker = _marker_for(city_id)
+	var region_key := str(marker.get("region_id")) if marker != null else ""
+	return str(_building_assets.region_style_for_region_key(region_key))
+
+
+func _city_display_name(city_id: String) -> String:
+	var marker = _marker_for(city_id)
+	var display_name := str(marker.get("display_name")) if marker != null else ""
+	return display_name if not display_name.is_empty() else city_id
+
+
+func _marker_for(city_id: String) -> Node:
+	var markers = main.get("_city_markers_by_id")
+	if markers is Dictionary:
+		var marker = (markers as Dictionary).get(city_id, null)
+		if marker is Node and is_instance_valid(marker):
+			return marker
+	return null
+
+
+## Existing mechanism only: the 3D camera controller's input_blocked flag (keyboard axes). Mouse wheel / drag / picks
+## never reach the map because the full-screen blocker below eats them in the GUI stage. The 2D camera controller has
+## no such flag, so 2D keyboard panning is not blocked here (see the CH-2 report).
+func _block_camera_input() -> void:
+	var camera_controller = main.get("_camera_controller")
+	if camera_controller == _blocked_camera_controller:
+		return
+	_unblock_camera_input()
+	if camera_controller != null and is_instance_valid(camera_controller) and "input_blocked" in camera_controller:
+		camera_controller.set("input_blocked", true)
+		_blocked_camera_controller = camera_controller
+
+
+func _unblock_camera_input() -> void:
+	if _blocked_camera_controller != null and is_instance_valid(_blocked_camera_controller):
+		_blocked_camera_controller.set("input_blocked", false)
+	_blocked_camera_controller = null
+
+
+func _ensure_window() -> void:
+	if _layer != null:
+		return
+	_layer = CanvasLayer.new()
+	_layer.name = "CityInteriorCanvas"
+	_layer.layer = WINDOW_LAYER
+	_layer.visible = false
+	add_child(_layer)
+	var blocker := Control.new()
+	blocker.name = "InputBlocker"
+	blocker.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
+	blocker.mouse_filter = Control.MOUSE_FILTER_STOP   # clicks outside the window do nothing (and never reach the map)
+	_layer.add_child(blocker)
+	var panel := PanelContainer.new()
+	panel.name = "Window"
+	panel.set_anchors_preset(Control.PRESET_CENTER)
+	panel.offset_left = -WINDOW_SIZE.x * 0.5
+	panel.offset_top = -WINDOW_SIZE.y * 0.5
+	panel.offset_right = WINDOW_SIZE.x * 0.5
+	panel.offset_bottom = WINDOW_SIZE.y * 0.5
+	blocker.add_child(panel)
+	var column := VBoxContainer.new()
+	panel.add_child(column)
+	var header := HBoxContainer.new()
+	column.add_child(header)
+	_title_label = Label.new()
+	_title_label.name = "TitleLabel"
+	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
+	header.add_child(_title_label)
+	_close_button = Button.new()
+	_close_button.name = "CloseButton"
+	_close_button.text = "닫기"
+	_close_button.pressed.connect(close)
+	header.add_child(_close_button)
+	var body := Label.new()
+	body.name = "PlaceholderLabel"
+	body.text = PLACEHOLDER_TEXT
+	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
+	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
+	body.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
+	column.add_child(body)
diff --git a/scripts/worldmap/ui/worldmap_city_interior_controller.gd.uid b/scripts/worldmap/ui/worldmap_city_interior_controller.gd.uid
new file mode 100644
index 0000000..700eef4
--- /dev/null
+++ b/scripts/worldmap/ui/worldmap_city_interior_controller.gd.uid
@@ -0,0 +1 @@
+uid://buk2hh5gvlbhg
diff --git a/tests/scripts/test_worldmap_city_interior_window.gd b/tests/scripts/test_worldmap_city_interior_window.gd
new file mode 100644
index 0000000..d086975
--- /dev/null
+++ b/tests/scripts/test_worldmap_city_interior_window.gd
@@ -0,0 +1,251 @@
+extends SceneTree
+
+# CITY-HUD CH-2: the city interior window frame (scripts/worldmap/ui/worldmap_city_interior_controller.gd), attached
+# to WorldMap.tscn as a root child outside worldmap_main.gd. Runs on the real WorldMap.tscn in the 2D map view.
+# 1. open-condition table (own / enemy / Karakorum no_art / every busy guard / battle-entry handoff / modals)
+# 2. main state unchanged by the controller   3. close button + Esc (Esc consumed only while open)
+# 4. 3D camera input_blocked set while open, cleared on close and on _exit_tree
+# 5. the main member names the controller relies on still exist   6. one connection per marker, one window, retarget
+
+const WORLDMAP_SCENE_PATH := "res://WorldMap.tscn"
+const CONTROLLER_NODE := "WorldMapCityInteriorController"
+const CAMERA_3D_CONTROLLER_PATH := "res://scripts/worldmap/map3d/worldmap_3d_camera_controller.gd"
+const OWN_CITY := "hanseong"
+const SECOND_CITY := "gyeongju"
+const ENEMY_CITY := "pyeongyang"
+const NO_ART_CITY := "karakorum"
+
+var _checks := 0
+var _failures: Array[String] = []
+
+
+func _initialize() -> void:
+	call_deferred("_run")
+
+
+func _run() -> void:
+	_expect(change_scene_to_file(WORLDMAP_SCENE_PATH) == OK, "WorldMap scene transition starts")
+	for i in 4:
+		await process_frame
+	var worldmap := current_scene
+	_expect(worldmap != null and worldmap.scene_file_path == WORLDMAP_SCENE_PATH, "WorldMap scene loaded")
+	if worldmap == null:
+		_finish()
+		return
+	var host := worldmap.get_node_or_null("WorldMap3DHost")
+	if host != null and bool(host.get("active")):
+		host.call("set_map_view_3d", false)   # 2D map view baseline (does not write the settings file)
+		await process_frame
+	print("[CITY_INTERIOR] map view: %s" % ("3d" if host != null and bool(host.get("active")) else "2d"))
+	var ctl := worldmap.get_node_or_null(CONTROLLER_NODE)
+	_expect(ctl != null, "controller node exists in WorldMap.tscn")
+	if ctl == null:
+		_finish()
+		return
+	_expect(ctl.get("main") == worldmap, "controller found main")
+
+	# 5. main members the controller reads still exist
+	var members: Array = []
+	for guard in ctl.BUSY_GUARDS + ctl.MODAL_GUARDS:
+		members.append(guard[1])
+	members.append_array(ctl.MAIN_MEMBERS)
+	for member in members:
+		_expect((member in worldmap) or worldmap.has_method(member), "main member exists: %s" % member)
+
+	# 6. exactly one deferred connection per marker
+	var markers: Dictionary = worldmap.get("_city_markers_by_id")
+	var bad_connections: Array[String] = []
+	for city_id in markers:
+		var count := 0
+		for connection in (markers[city_id] as Node).get_signal_connection_list("city_selected"):
+			var callable: Callable = connection["callable"]
+			if callable.get_object() == ctl:
+				count += 1
+				if (int(connection["flags"]) & CONNECT_DEFERRED) == 0:
+					bad_connections.append("%s not deferred" % city_id)
+		if count != 1:
+			bad_connections.append("%s x%d" % [city_id, count])
+	_expect(not markers.is_empty() and bad_connections.is_empty(), "one deferred connection per marker %s" % str(bad_connections))
+	_expect(int(ctl.call("get_connected_marker_count")) == markers.size(), "controller connected every marker")
+	for city_id in [OWN_CITY, SECOND_CITY, ENEMY_CITY, NO_ART_CITY]:
+		_expect(markers.has(city_id), "marker exists: %s" % city_id)
+	if not (markers.has(OWN_CITY) and markers.has(SECOND_CITY) and markers.has(ENEMY_CITY) and markers.has(NO_ART_CITY)):
+		_finish()
+		return
+	var player_faction := str(worldmap.call("_get_current_player_faction_id"))
+	_expect(bool(worldmap.call("_is_city_owned_by_player_mvp", OWN_CITY)), "%s starts player-owned" % OWN_CITY)
+
+	# 1a. own city click (real signal path, main handles first)
+	await _click(markers[OWN_CITY])
+	_expect(bool(ctl.call("is_open")) and str(ctl.call("get_open_city_id")) == OWN_CITY, "own city click opens the window")
+	_expect(str(ctl.get("last_reject_reason")) == "", "own city: no reject reason")
+	_expect(str(worldmap.get("selected_city_id")) == OWN_CITY, "main processed the click (selected_city_id)")
+	var display_name := str(markers[OWN_CITY].get("display_name"))
+	_expect(str(ctl.call("get_title_text")) == "%s — 성 안" % display_name, "title shows the city name")
+
+	# 6. same city again: still one window, not reopened
+	await _click(markers[OWN_CITY])
+	_expect(bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == "already_open", "same city again -> already_open")
+	_expect(_count_layers(ctl) == 1, "one window layer")
+	ctl.call("close")
+
+	# 1b. enemy city click (real signal path)
+	await _click(markers[ENEMY_CITY])
+	_expect(not bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == "not_own_city", "enemy city click -> not_own_city")
+
+	# 2. main state snapshot after main's own click handling; no more clicks below, only controller operations
+	var player_state: Dictionary = worldmap.get("_player_state")
+	var snapshot := [str(worldmap.get("selected_city_id")), str(player_state.get("selected_city_id", "")), str(player_state.get("origin_city_id", ""))]
+
+	# 6. another own city: content retargets
+	ctl.call("try_open", OWN_CITY)
+	var second_owner := str(markers[SECOND_CITY].get("owner_faction_id"))
+	markers[SECOND_CITY].set("owner_faction_id", player_faction)
+	_expect(bool(ctl.call("try_open", SECOND_CITY)) and str(ctl.call("get_open_city_id")) == SECOND_CITY, "another own city retargets the open window")
+	_expect(str(ctl.call("get_title_text")).begins_with(str(markers[SECOND_CITY].get("display_name"))), "title retargets")
+	_expect(_count_layers(ctl) == 1, "still one window layer after retarget")
+	markers[SECOND_CITY].set("owner_faction_id", second_owner)
+
+	# 3. close button
+	(ctl.call("get_close_button") as Button).pressed.emit()
+	_expect(not bool(ctl.call("is_open")), "close button closes")
+	# 3. Esc while open closes (through the viewport input pipeline)
+	ctl.call("try_open", OWN_CITY)
+	root.push_input(_esc())
+	await process_frame
+	_expect(not bool(ctl.call("is_open")), "Esc closes the open window")
+	# Esc while closed: not consumed by the controller -> main's own Esc handler (help modal) still gets it
+	var help_modal: Control = worldmap.call("_ensure_shared_ui_controller").call("ensure_help_modal")
+	_expect(help_modal != null, "help modal available")
+	if help_modal != null:
+		help_modal.visible = true
+		root.push_input(_esc())
+		await process_frame
+		_expect(not help_modal.visible, "Esc while closed reaches main (help modal closed by main)")
+	_expect(not bool(ctl.call("is_open")), "Esc while closed keeps it closed")
+
+	# 4. 3D camera input block (fake 3D camera controller swapped in, no camera attached)
+	var original_camera_controller = worldmap.get("_camera_controller")
+	if "input_blocked" in original_camera_controller:
+		ctl.call("try_open", OWN_CITY)
+		_expect(bool(original_camera_controller.get("input_blocked")), "real 3D camera controller blocked while open")
+		ctl.call("close")
+		_expect(not bool(original_camera_controller.get("input_blocked")), "real 3D camera controller unblocked after close")
+	var fake_3d: Node = load(CAMERA_3D_CONTROLLER_PATH).new()
+	worldmap.set("_camera_controller", fake_3d)
+	ctl.call("try_open", OWN_CITY)
+	_expect(bool(fake_3d.get("input_blocked")), "3D camera input blocked while open")
+	ctl.call("close")
+	_expect(not bool(fake_3d.get("input_blocked")), "3D camera input unblocked after close")
+	fake_3d.set("_battle_entry_handoff_in_progress", true)
+	_expect_reject(ctl, OWN_CITY, "battle_entry_handoff", "battle-entry handoff")
+	fake_3d.set("_battle_entry_handoff_in_progress", false)
+	worldmap.set("_camera_controller", original_camera_controller)
+
+	# 1c. reject table
+	var karakorum_owner := str(markers[NO_ART_CITY].get("owner_faction_id"))
+	markers[NO_ART_CITY].set("owner_faction_id", player_faction)
+	_expect_reject(ctl, NO_ART_CITY, "no_art", "Karakorum as own city")
+	markers[NO_ART_CITY].set("owner_faction_id", karakorum_owner)
+
+	for setting in [
+		["_contextual_worldmap_action_pending", true], ["_pending_diplomacy_action_id", "test"],
+		["_pending_spy_action_id", "test"], ["_pending_trade_action_id", "test"],
+		["_enemy_turn_mvp_pending", true], ["_domestic_turn_apply_pending", true],
+	]:
+		var before = worldmap.get(setting[0])
+		worldmap.set(setting[0], setting[1])
+		_expect_reject(ctl, OWN_CITY, "busy:%s" % setting[0], setting[0])
+		worldmap.set(setting[0], before)
+	for state_case in [
+		["pending_invasion_event", {"event_id": "test"}, "busy:_has_pending_invasion_event_mvp"],
+		["pending_battle_context", {"transaction_id": "test"}, "busy:_get_pending_battle_context_mvp"],
+		["turn_phase", "enemy", "busy:_player_state"],
+		["game_outcome", {"status": "victory"}, "modal:_has_terminal_korea_outcome_mvp"],
+	]:
+		var had := player_state.has(state_case[0])
+		var before = player_state.get(state_case[0])
+		player_state[state_case[0]] = state_case[1]
+		_expect_reject(ctl, OWN_CITY, state_case[2], "_player_state.%s" % state_case[0])
+		if had:
+			player_state[state_case[0]] = before
+		else:
+			player_state.erase(state_case[0])
+	for panel_member in ["_player_attack_deployment_panel", "_manual_trade_order_panel", "_internal_trade_transfer_panel", "_t05_outcome_presentation_root"]:
+		var before = worldmap.get(panel_member)
+		var fake_panel: Control = PanelContainer.new() if panel_member != "_t05_outcome_presentation_root" else Control.new()
+		fake_panel.visible = true
+		worldmap.set(panel_member, fake_panel)
+		var prefix := "busy:" if panel_member == "_player_attack_deployment_panel" else "modal:"
+		_expect_reject(ctl, OWN_CITY, prefix + panel_member, "%s visible" % panel_member)
+		worldmap.set(panel_member, before)
+		fake_panel.free()
+	worldmap.call("_open_domestic_tech_tree_overlay_mvp")
+	await process_frame
+	_expect_reject(ctl, OWN_CITY, "modal:_is_domestic_tech_tree_overlay_open_mvp", "tech tree overlay open")
+	worldmap.call("_close_domestic_tech_tree_overlay_mvp")
+	await process_frame
+	if help_modal != null:
+		help_modal.visible = true
+		_expect_reject(ctl, OWN_CITY, "modal:_ensure_shared_ui_controller", "help modal visible")
+		help_modal.visible = false
+	_expect(bool(ctl.call("try_open", OWN_CITY)), "opens again once every guard is cleared")
+	ctl.call("close")
+
+	# 2. main unchanged by all controller operations
+	player_state = worldmap.get("_player_state")
+	var after := [str(worldmap.get("selected_city_id")), str(player_state.get("selected_city_id", "")), str(player_state.get("origin_city_id", ""))]
+	_expect(after == snapshot, "main selection state unchanged by the controller %s -> %s" % [str(snapshot), str(after)])
+
+	# 4. _exit_tree releases the block
+	worldmap.set("_camera_controller", fake_3d)
+	ctl.call("try_open", OWN_CITY)
+	_expect(bool(fake_3d.get("input_blocked")), "blocked before scene removal")
+	worldmap.remove_child(ctl)
+	_expect(not bool(fake_3d.get("input_blocked")), "_exit_tree releases the 3D camera input block")
+	_expect(not worldmap.has_meta("wm_city_interior_controller"), "_exit_tree releases the main claim")
+	worldmap.set("_camera_controller", original_camera_controller)
+	ctl.free()
+	fake_3d.free()
+	_finish()
+
+
+func _click(marker: Node) -> void:
+	marker.emit_signal("city_selected", marker)
+	await process_frame
+	await process_frame
+
+
+func _esc() -> InputEventKey:
+	var event := InputEventKey.new()
+	event.pressed = true
+	event.keycode = KEY_ESCAPE
+	return event
+
+
+func _count_layers(ctl: Node) -> int:
+	var count := 0
+	for child in ctl.get_children():
+		if child is CanvasLayer:
+			count += 1
+	return count
+
+
+func _expect_reject(ctl: Node, city_id: String, reason: String, label: String) -> void:
+	var opened := bool(ctl.call("try_open", city_id))
+	_expect(not opened and not bool(ctl.call("is_open")) and str(ctl.get("last_reject_reason")) == reason,
+		"%s -> %s (got %s)" % [label, reason, str(ctl.get("last_reject_reason"))])
+	if opened:
+		ctl.call("close")
+
+
+func _expect(condition: bool, label: String) -> void:
+	_checks += 1
+	if not condition:
+		_failures.append(label)
+		push_error("[CITY_INTERIOR_FAIL] %s" % label)
+
+
+func _finish() -> void:
+	print("[CITY_INTERIOR] checks=%d failures=%s" % [_checks, str(_failures)])
+	quit(0 if _failures.is_empty() else 1)
diff --git a/tests/scripts/test_worldmap_city_interior_window.gd.uid b/tests/scripts/test_worldmap_city_interior_window.gd.uid
new file mode 100644
index 0000000..4be7ffa
--- /dev/null
+++ b/tests/scripts/test_worldmap_city_interior_window.gd.uid
@@ -0,0 +1 @@
+uid://bwt6stdxproml
```

## 9. 종료 루틴
1. 코드 커밋 `ffb8778` push, 원격 = 로컬.
2. CI: 4절.
3. 보고서 커밋 `[skip ci]`, 이 가지에만.
4. 정본 가지·`main`·`PROGRESS_WM3D.md` 손대지 않음.
5. 다음: 큐 10번 `ORDER_MERGE_MAIN_20261105.md`.
