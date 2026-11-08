기준 화면: 가지 `feature/wm3d-debugcheats-20261108`(끝 `dc63ec8`, 코드는 `main` `a9e3b84`와 같음)에서 이어서, F6로 `WorldMap.tscn`을 열고(디버그 빌드) 키 3개로 치트 ①②③이 동작한다. **`worldmap_main.gd` 변경 0줄.**
합격 기준: 원 지시서 6절 자동 기준 전부(아래 정정 반영) + `worldmap_main.gd`·`tools/p1_exact_delta.py` 변경 0 + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(원 지시서 7절).

# REPORT_DEBUG_CHEATS — 디버그 치트 3개 (큐 30번, 답신 1 A안) (클코드, 2026-11-08)

## 요약
- 디버그 빌드에서만 동작하는 치트 3개를 넣었습니다: Ctrl+Shift+G = 내 도시 자원을 창고 용량(금 9999)까지 채움, Ctrl+Shift+T = 테크트리에서 고른 테크 즉시 완료(+Alt = 그 범위 전체), Ctrl+Shift+I = 첩보 없이 적 성 정보 전부 보기(켜고 끄기).
- 컨트롤러는 `WorldMap.tscn` 루트 자식 노드 1개이고, 출시 빌드에서는 `_ready`에서 스스로 지워집니다. `worldmap_main.gd`·`tools/p1_exact_delta.py`는 0줄 변경이고, 세이브 키는 하나도 늘지 않았습니다.
- 로컬 전체 검사는 모두 통과했습니다(실제 실패 0, 6절). 첫 코드 커밋은 테스트 `.uid` 미커밋으로 CI Diff check가 실패했고, `.uid`를 추가한 `0e849ee`에서 C-track 4 shard가 초록입니다(7절).

- 시작: `origin/main` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`. 코드 커밋 `5a51ebf638389b2f3c08f306ea9a7eb14cd67b4d`(STOP 보고서 `dc63ec8` 위).

## 1. 변경 파일 (답신 1 1절의 허용 목록 안)
| 파일 | 변경 |
|---|---|
| `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd` (+`.uid`) | 새 파일. 치트 3개, 키 입력, 디버그 판정 |
| `WorldMap.tscn` | `ext_resource` 1줄 + 루트 자식 노드 1개 |
| `scripts/worldmap/actions/spy_presentation_helper.gd` | 변수 1개(`debug_intel_provider: Callable`) + `get_city_intel_entry`의 앞 4줄 분기. 다른 함수·`Button.new`/`Label.new` 추가 0 |
| `tests/scripts/test_worldmap_debug_cheats.gd` | 새 테스트(61개 검사) |
| `.github/workflows/verify-c-track.yml` | 마지막 테스트 목록 끝에 1줄(전체 209개 중 idx 208 → shard 0, 기존 테스트의 shard 변화 0) |

`git diff a9e3b84 -- scripts/worldmap/worldmap_main.gd tools/p1_exact_delta.py` 원문(비어 있음):
```
```

`WorldMap.tscn` diff 원문:
```
@@ -27,6 +27,7 @@
 [ext_resource type="Script" uid="uid://buk2hh5gvlbhg" path="res://scripts/worldmap/ui/worldmap_city_interior_controller.gd" id="28_city_interior"]
 [ext_resource type="Script" uid="uid://dgk4ismn34a1n" path="res://scripts/worldmap/ui/worldmap_left_panel_grip_controller.gd" id="29_left_panel_grip"]
+[ext_resource type="Script" uid="uid://d1ai70c1jgf4g" path="res://scripts/worldmap/ui/worldmap_debug_cheats_controller.gd" id="30_debug_cheats"]
@@ -2352,3 +2353,7 @@ main_path = NodePath("..")
 [node name="WorldMapLeftPanelGripController" type="Node" parent="." unique_id=1290417733]
 script = ExtResource("29_left_panel_grip")
+
+[node name="WorldMapDebugCheatsController" type="Node" parent="." unique_id=1509427733]
+script = ExtResource("30_debug_cheats")
+main_path = NodePath("..")
```
- `unique_id=1509427733`은 장면 안에서 중복 0(`grep` 확인). 노드 수·`unique_id`를 세는 검사는 `tools/`에 없었다(2절 18개가 노드 추가 뒤에도 같은 줄로 통과).

## 2. `WorldMap.tscn`을 읽는 검사 — 노드 추가 전후 (답신 1 2절)
- `tools/`에서 `WorldMap.tscn`을 참조하는 검증기 **18개**(`validate_battle3d_*` 13 + `validate_p1b1~4` + `validate_p1b_16x9_functional_parity`): 전·후 모두 PASS, **결과 줄이 글자 하나 다르지 않다**(`diff` 0). 원문은 `agent/evidence/debugcheats_20261108/scene_validators_before.txt`·`_after.txt`. 예:
  - `tools/validate_p1b1_worldmap_visual_baseline.py rc=0 :: P-1B-1 WorldMap visual baseline static validation: PASS`
  - `tools/validate_p1b_16x9_functional_parity.py rc=0 :: P-1B 16:9 functional parity validation: PASS (real-tech exception enforced)`
  - `tools/validate_battle3d_contract.py rc=0 :: BATTLE3D_CONTRACT PASS: 14-field ordered view contract, ...`
- 테스트(전 = 노드 추가 전 작업 폴더, 후 = 노드 추가 뒤 전체 검사):

| 테스트 | 전 | 후 |
|---|---|---|
| `test_worldmap3d_host.gd` | `[WORLDMAP3D_HOST] PASS: 58 checks, 0 failures` | 같음 |
| `test_worldmap3d_production.gd` | `[WM3D_PRODUCTION] checks=28 failures=[]` | 같음 |
| `test_worldmap_city_interior_window.gd` | `[CITY_INTERIOR] checks=125 failures=[]` | 같음 |
| `test_worldmap_left_panel_grip.gd` | `[LEFT_PANEL_GRIP] checks=28 failures=[]` | 같음 |
| `test_worldmap_spy_controller_extraction.gd` | `[SPY_CONTROLLER] PASS: 49 checks, 0 failures` | 같음 |

- [사실] "전" 묶음은 장면 노드를 붙이기 전에 돌렸다. 마지막 스파이 테스트가 도는 중에 `spy_presentation_helper.gd`를 고쳤으므로, 그 한 줄은 전/후 경계가 정확하지 않다. "후" 결과는 고친 뒤 전체 검사의 값이다.

## 3. 원 지시서 2절 [미확인] 4건 결과
1. **키 충돌** [사실]: `scripts/worldmap/` 안에 `KEY_G`·`KEY_T`·`KEY_I` 사용 0건(새 컨트롤러 제외). 테스트 6번이 이것을 정규식 검사로 고정했다. `project.godot`에 `[input]` 절 없음. → **Ctrl+Shift+G / T / I**.
2. **테크트리가 열린 상태의 키 입력** [사실, 테스트로 확인]: 테크트리를 연 상태에서 `root.push_input`으로 Ctrl+Shift+T를 넣으면 컨트롤러의 `_unhandled_key_input`이 받아 테크가 완료된다(테스트 3번 `"Ctrl+Shift+T with the overlay open completes agri_double_cropping (key reached the controller)"` 통과). main의 `_unhandled_input`이 모든 입력을 먹기 **전**에 받는다. `_input`은 쓰지 않았다.
3. **테크 전체 목록의 공개 수단** [사실]: `domestic_tech_catalog.gd`의 `get_city_definitions()` / `get_national_definitions()` / `get_definition()`. 선택은 트리 컨트롤러의 공개 함수 `get_selection()`.
4. **턴 진행 중 용량으로 깎이는지** [사실, 정적 확인]: `WAREHOUSE_CAPACITY`를 읽는 곳은 HUD 문구 2곳뿐이고, `turn`·`economy_city`·`orchestration`에 `capacity` 0건. 턴을 실제로 넘겨 본 측정은 하지 않았다([미확인] → F6 1번 뒤 김작 관찰 바람).

## 4. 구현 요약과 택한 해석
- **활성 판정**: `enabled_override`(-1 = `OS.is_debug_build()`, 0 = 끔, 1 = 켬)를 주입할 수 있게 분리. 꺼져 있으면 `_ready`에서 `queue_free()`하고 main 참조도 잡지 않는다. 모든 공개 함수는 `is_active()`가 거짓이면 `{"reason": "inactive"}`를 돌려주고 아무것도 하지 않는다.
- **① 자원**: 내 도시마다 `WAREHOUSE_CAPACITY` 값을 ⓐ 도시 `resource_stock`(`_wounded_recovery_mutation("set_city_resource_amount", ...)`)과 ⓑ 도시 `storage`(`_set_city_storage`)에 넣고, `_rebuild_occupation_runtime_indexes_mvp()`로 ⓒ를 다시 모은다. 그다음 좌측 국고, 선택한 내 도시 패널, (열려 있으면) 테크트리를 다시 그린다. 상태 줄: `[디버그] 자원 채움: 내 도시 N곳, 창고 용량 값(금 9999)`.
  - **택한 해석**: 소유 도시 목록은 `_get_national_payment_city_ids_mvp()`에 `CITY_HUD_DATA` 중 내 소유인 도시를 더한 것이다. 이 함수는 런타임 상태가 아직 없는 도시를 빠뜨려서(장면을 바로 열면 빈 목록), 재집계와 같은 기준(`_get_city_owner_id_for_battle_context`)으로 보충했다.
- **② 테크**: `mark_completed_from_normalize(scope, city_id, tech_id)` + 도시면 `sync_city_completed_mirror(city_id)`. 진행 중 연구 슬롯은 건드리지 않고 자원도 빼지 않는다. 화면 갱신은 정상 턴 완료와 같은 경로(`_decorate_domestic_tech_event_list_mvp` → `_refresh_domestic_tech_tree_overlay_mvp` → `_refresh_domestic_tech_effect_display_surfaces_mvp({"completed": ...})` → `_refresh_worldmap_tech_badge_summary_if_present`).
  - **택한 해석**: 완료 연출 카드는 **생략**했다(시험 중 화면을 막지 않게).
  - **택한 해석**: Ctrl+Shift+Alt+T(범위 전체)는 **구현했고**, 진행 중인 테크는 건너뛴다. 기존 정규화(`_normalize_research_container_result` 531~532행)가 완료된 테크의 연구 슬롯을 비우므로, 그대로 두면 "진행 중 연구 보존"이 깨진다. 단일 치트로 **지금 연구 중인 그 테크**를 고르면 기존 규칙대로 슬롯이 비는데, 이것은 정상 동작으로 본다.
- **③ 첩보**: 프레젠터 변수 `debug_intel_provider`(Callable, 기본 비어 있음 = 꺼짐)를 플래그로 썼다. 켜면 컨트롤러가 내 도시가 아닌 도시에 대해 6필드 entry를 읽을 때 만들어 준다(`turn`, `fields`, `estimated=false`, `payload` = 스파이 서비스의 `_build_spy_info_payload` 실제 값). `city_intel`에는 쓰지 않는다. 켜고 끌 때 선택 도시 패널을 다시 그린다.
  - **택한 해석**: 지시서의 "플래그 변수 1개"를 bool 대신 Callable 1개로 했다. 스파이 서비스 내부 호출을 프레젠터가 아니라 컨트롤러 안에만 두려는 선택이고, 프레젠터 변경은 5줄로 그대로다.
  - 답신 1 3절: `_adapter`는 **비어 있을 때만** `spy_controller`로 채운다(테스트 4번에서 빈 경우 채움, 있으면 유지, 정상 `validate_spy_action` 결과 불변을 확인).

## 5. 관찰
- 새 게임(조선/한성) 시작 시 내 도시는 한성 1곳이라 나라 합계 = 용량 값(금 9999)과 같다. 도시가 둘 이상이면 나라 합계는 `9999 × 도시 수`처럼 용량을 넘어 보인다(지시서대로 자르지 않음). HUD의 `N / 9999` 문구도 그대로 넘는다.
- 턴 후 재고 변화는 측정하지 않았다(3절 4번 [미확인]).
- 치트 테스트 로그 끝의 `ObjectDB instances leaked at exit` / `2 resources still in use at exit`는 같은 실행의 `test_worldmap_spy_controller_extraction` 로그에도 있는 종료 줄이고, 결과(종료 코드 0)와 무관하다.

## 6. 로컬 검증 결과 (Godot 4.6.2 headless, 테스트마다 임시 `APPDATA`, 3개 병렬)
- 새 테스트: `[DEBUG_CHEATS] checks=61 failures=[]` (원 지시서 6절 1~6번 + 세이브 키 집합 비교 + 답신 1 3절 `_adapter` 검사 + 4절 정정된 5번 "`_ready`가 `queue_free()` → 이후 입력 무동작").
- 세이브 형식: 치트 ①②③ 전후 `_player_state` 키 집합이 같다(`"save format: _player_state key set unchanged by the cheats ([])"` 통과).
- C-track 목록 209개 + `test_worldmap3d_*.gd` 8개 = **217개 전부 rc=0**(`agent/evidence/debugcheats_20261108/full_tests.txt`).
  - `ci_worldmap3d_scene_load.gd`는 제 목록에 잘못 들어가 "File not found"가 났다. 이 파일은 저장소에 없고, CI도 `no scene-load script yet`로 건너뛴다(`verify-worldmap3d.yml` 46행). 테스트 수에서 뺐다.
- 검증기 72개: 커밋 전에는 71 PASS + `validate_worldmap_trade_phase2_extraction.py` 1개 실패(`FAIL: UI/scene restoration or modification detected`).
  - 이 검사는 **커밋 안 된** 변경(`git diff HEAD --name-only`)에 `.tscn`·`/ui/`가 있는지만 본다. 커밋 `5a51ebf` 뒤 다시 돌리니 `PASS: WorldMap Trade Phase 2 extraction boundaries`. 검사 파일·허용 오차는 건드리지 않았다.
  - 주요 줄 원문:
    - `tools/validate_worldmap_main_integrity.py rc=0 :: PASS: WorldMap main integrity guard (14108 main lines, 15608 orchestration lines, 1083 main functions, all sentinels present).`
    - `tools/validate_worldmap_diplomacy_routing.py rc=0 :: PASS: diplomacy routing guard + exact C-1/C-2/C-3/M-5/M-FINAL-A/M-FINAL-B + WorldMap warning-cleanup checkpoint bridge; historical T-4 guard preserved`
    - `tools/validate_worldmap_spy_controller_extraction.py rc=0 :: PASS: Spy Controller/Service/Presenter ownership; Diplomacy boundary explicit; manual Trade service/presenter and Military/Battle frozen`
- `git diff --check a9e3b84 5a51ebf`: 출력 없음.

## 7. CI
**첫 코드 커밋 `5a51ebf` — 실패(원인: 새 테스트의 `.gd.uid` 미커밋)**
- `Verify C-track refactor` run `42473247825`: shard 0 `128708739696`, 1 `128708739827`, 2 `128708739842`, 3 `128708739883` 모두 **failure**. 4개 모두 실패한 단계는 마지막 "Diff check" 하나다(테스트 단계는 전부 success):
  ```
  Working tree is not clean after verification:
  ?? tests/scripts/test_worldmap_debug_cheats.gd.uid
  ##[error]Process completed with exit code 1.
  ```
  - 같은 실행 shard 0의 새 테스트 줄 원문: `[DEBUG_CHEATS] checks=61 failures=[]`.
  - [사실] 테스트 파일을 로컬 import **뒤에** 만들었고 `--script` 실행으로는 `.uid`가 생기지 않아 커밋에서 빠졌다. CI의 `--import`가 이 파일을 만들어 작업 트리가 더러워졌다. 김작 지적으로 확인.
- `Verify WorldMap3D` run `42473247807`: 실행 결론은 **success**지만 작업 `128708739898`은 failure다(워크플로가 `continue-on-error: true`라 실행은 초록으로 표시). 단계별로는 Import(3D 포함)·WorldMap3D tests·scene load가 success이고, "Diff check"(`git diff --check && test -z "$(git status --short)"`)만 failure.
  - [추정] 이 워크플로는 status 내용을 출력하지 않는다. 같은 커밋의 C-track이 같은 `.uid`로 실패했으므로 원인은 같다고 본다.

**수정 커밋 `0e849ee49398b0f26ecc480496b74758a095f017`**: Godot import로 만든 `tests/scripts/test_worldmap_debug_cheats.gd.uid`(`uid://cy2apq4xy4764`) 1개만 추가했고 코드 변경은 0이다. import는 이 파일 외에 아무것도 바꾸지 않았다.
- `Verify C-track refactor` run `42475007954`: **success** — shard 0 `128714258802`, 1 `128714259070`, 2 `128714259016`, 3 `128714259042` 모두 success. 재실행이 아니라 새 커밋에서 새로 돈 실행이다.
- `Verify WorldMap3D`: `0e849ee`는 경로 조건(`.uid` 파일은 대상 아님)에 걸리지 않아 **트리거되지 않았다**. `gh` 쓰기 명령(수동 실행)은 큐 6절이 금지한다. 대신 같은 검사를 로컬에서 재현했다: `0e849ee`에서 `--headless --editor --path . --import`(3D 포함) → `git diff --check` 종료 코드 0, `git status --short` 비어 있음(커밋 전 보고서 파일만 제외). WorldMap3D 테스트 8개는 6절 전체 검사에서 모두 rc=0.
- 재발 방지: 새 `.gd`를 만들면 import 후 `.gd.uid`를 같은 커밋에 넣는 것을 코드 커밋 전 점검 항목으로 기록했다.

## 8. 김작 F6 체크리스트 (원 지시서 7절 그대로)
1. 새 게임 시작 → Ctrl+Shift+G → 좌측 국고 금이 9999 근처로, 한성 도시창 '금전'도 9999.
2. 테크트리에서 도시 테크 하나 선택 → "연구 시작" 가능(자원 부족 안 뜸) → 시작해도 정상 진행.
3. 다른 테크를 선택하고 Ctrl+Shift+T → 즉시 완료 표시, 선행 안 채워도 됨. (CH-4 가지가 합쳐진 빌드라면 성 안 건물 점등까지 — 이 가지에는 CH-4가 없으므로 이 항목은 CH-4 쪽에서 확인.)
4. 적 도시 선택 → 정보 "미확인/잠김" → Ctrl+Shift+I → 병력·자원·민심·충성도·태수·기술 전부 값으로 표시 → 다시 Ctrl+Shift+I → 원래대로.
5. 저장 후 불러오기 → 치트로 채운 자원은 그대로(정상 데이터), ③의 합성 정보는 사라짐.
- 출시 빌드 비활성은 자동 테스트(6절 5번)로 갈음. 별도 export 확인은 하지 않는다.

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-debugcheats-20261108`, 이 보고서 커밋 뒤 `git status` 깨끗.
2. 새로 생긴 것: 가지 `feature/wm3d-debugcheats-20261108`(앞선 STOP 보고서 때 생성), 증거 폴더 `agent/evidence/debugcheats_20261108/`(기존 `agent/evidence/` 아래, 단계별 폴더 관례). worktree·태그 0, 삭제 예정 0.
3. 푸시: 이 가지에 `dc63ec8`(STOP 보고서) → `5a51ebf`(코드) → `0e849ee`(테스트 `.uid`) → 이 보고서 커밋(`[skip ci]`). `main`·다른 가지 푸시 없음. 로컬 = 원격.
4. CI: 최종 코드 커밋 `0e849ee`에서 C-track 4 shard success. `Verify WorldMap3D`는 `5a51ebf`에서 Diff check만 실패(`.uid`, continue-on-error), `0e849ee`에서는 트리거되지 않아 로컬 재현으로 대신했다(7절).
5. 김작이 결정할 것: F6 체크리스트 1~5 합격/불합격, 이 가지의 `main` 합류 여부와 시기(CH-4와 같이 합칠지).
