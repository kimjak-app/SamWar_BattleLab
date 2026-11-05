기준 화면: 정본 가지 `feature/wm3d-intake-20261101`에서 `res://WorldMap3D_Host_Test.tscn`(3D) F6 → 새 게임 → 아군 도시에서 적 도시를 공격해 전투로 들어가는 순간. 3D 카메라가 두 도시 사이 72% 지점으로 다가간 뒤 기존 2D 전투(`Battle_Main.tscn`)로 넘어간다. (전투가 끝난 뒤 돌아오는 화면은 08에서 정식 연결한다 — 지금은 일반 2D `WorldMap.tscn`으로 돌아오는 것이 정상.)
합격 기준: 김작 F6 — ① 공격 시 3D 카메라가 접근하고(툭 끊기지 않음) 전투로 넘어간다 ② 접근 중 Space·Enter·Esc·왼쪽 클릭으로 건너뛰기가 되고 전투가 **한 번만** 시작된다 ③ 접근 중 다른 도시를 클릭해도 아무 일도 없다. 자동 조건: 새·고친 테스트 통과, 올린 커밋에서 `Verify C-track refactor` 4 shard와 `Verify WorldMap3D` success. 메모리 측정값(VRAM)은 김작 PC에서만 나오므로 합격 조건이 아니라 **측정 도구가 동작하는지**만 본다.

# 지시서 — T-WM3D-07: 3D 월드맵의 전투 진입 카메라 + 메모리 측정 도구 (메인 파일 수정 없음)

- 작성: 클코치, 2026-11-05 11:30 / 큐: `agent/ORDER_QUEUE.md` 순서 2번
- 시작 HEAD: `5f573a7` 또는 그 이후(`feature/wm3d-intake-20261101`).
- 범위 결정([사실]은 원격 `5f573a7` 대조, 결정은 큐 7절): 3D 전투 연결(M7)은 이번에 하지 않는다. **2D 전투 `Battle_Main.tscn`으로 들어가는 연출과 메모리 측정 도구만.**
- 근거([사실]):
  - 공격 → `worldmap_main.gd:6897` `_start_worldmap_battle_entry_camera_handoff(source_city_id, target_city_id, continue)`가 `_build_worldmap_battle_entry_focus`(6969~)로 **두 도시 2D 마커 위치의 72% 지점**(`source.lerp(target, 0.72)`)을 만들어 `_ensure_camera_controller().start_battle_entry_handoff(focus_position, continue_callable)`에 넘기고, 끝나면 `_change_scene_to_battle_with_context`(6900)가 `change_scene_to_file("res://scenes/battle/Battle_Main.tscn")`을 부른다. 장면 전환이므로 월드맵 장면 전체(3D 레이어 포함)가 해제된다.
  - 3D 컨트롤러(`scripts/worldmap/map3d/worldmap_3d_camera_controller.gd` 69~101행)에는 이미 `start_battle_entry_handoff`/`skip_battle_entry_handoff`가 구현되어 있으나, 넘어온 `focus_position`을 **2D 월드 좌표인 채로 3D 지면 좌표(km)로 쓰고 있어** 틀리다. 그래서 03-4 호스트가 `skip_battle_entry_camera = true`로 꺼 두었다(`worldmap_3d_host.gd` `_replace_camera_controller`, 주석 "the 3D handoff comes with T-WM3D-07").
  - 어댑터 `focus_for_2d_position`(138~145행)은 **마커 위치와 정확히 같은 2D 좌표**만 도시로 되돌린다(72% 지점은 못 찾는다).
  - 전투 종료 후 복귀 경로는 `battle_context["result_return_destination"] = "res://WorldMap.tscn"`(`worldmap_main.gd:6516`)이라 07 단계의 호스트 테스트 장면에서는 일반 2D 월드맵으로 돌아온다. 3D 복귀는 08(`WorldMap.tscn`에 3D 레이어를 넣은 뒤)에서 한다.
  - 계획서 §4-1: VRAM 측정 항목은 `RENDER_VIDEO_MEM_USED`·`RENDER_TEXTURE_MEM_USED`·`RENDER_BUFFER_MEM_USED`(MB), 추가로 `OBJECT_COUNT`·`OBJECT_RESOURCE_COUNT`, 저장은 `user://wm3d_mem_log.csv`. 헤드리스에서는 이 모니터 값이 0일 수 있다.

## 0. 규칙

1. 시작 전 `git status` 깨끗, `git log -1`이 `5f573a7` 이후인지 확인. 아니면 멈춤.
2. **`scripts/worldmap/worldmap_main.gd` 수정 금지**(08 전까지 pinned). 2D 카메라 컨트롤러(`scripts/worldmap/camera/worldmap_camera_controller.gd`)도 수정 금지.
3. 수정·추가 파일은 **아래 5절의 경로뿐**. 새 폴더 금지(`scripts/worldmap/map3d/`는 이미 있음). 목록 밖을 고쳐야 하면 멈춤.
4. 규칙 나머지는 큐 6절(push 가지, `gh` 읽기만, 코드 커밋 → CI → 보고서 `[skip ci]`)과 같다. 보고서: `agent/REPORT_WM3D_07_20261105.md`. 진행 기록 `agent/PROGRESS_WM3D.md`도 큐 3절대로 갱신(`[skip ci]` 별도 커밋).
5. 지시서의 [사실]과 실제 코드가 다르면 추정하지 말고 멈추고 보고.

## 1. 먼저 읽기 전용으로 확인 (결과를 보고서 표로)

1. `worldmap_main.gd`의 `_build_worldmap_battle_entry_focus`(6969~)가 72%를 만드는 줄과, `start_battle_entry_handoff`를 부르는 곳이 **이 한 곳뿐인지**(`rg`). 72% 상수가 main 안에서 어디에 있는지(이름·줄).
2. 3D 컨트롤러의 `BATTLE_ENTRY_PAN_SEC`·`HOLD_SEC`(상속값)와 3D 카메라 `smoothing`(7.0)으로 0.7초 안에 목표에 충분히 접근하는지(카메라가 `set_view(..., false)`로 부드럽게 이동하는 시간을 코드로 계산: 지수 평활 `smoothing 7` → 0.7초면 목표까지 남는 비율 `exp(-7·0.7)`). 접근이 모자라면 대기 시간을 몇 초로 늘릴지 제안만(상수는 3D 컨트롤러 안에서만 정함).
3. 전투 장면 쪽: `Battle_Main.tscn`이 열린 직후 월드맵 장면이 이미 해제되는지(`change_scene_to_file`의 동작은 현재 장면을 다음 프레임에 삭제). 호스트(`WorldMap3D_Host_Test` 루트)도 같이 해제되는지 — 호스트가 `main`의 형제 노드라 같이 사라진다는 것을 코드·Godot 동작으로 확인하고 보고.
4. 메모리 모니터: `Performance.get_monitor`에 쓸 상수 이름(`Performance.RENDER_VIDEO_MEM_USED` 등)이 Godot 4.6.2에 있는지(로컬 Godot로 한 줄 스크립트로 확인), 헤드리스에서 값이 0인지.

## 2. 3D 전투 진입 카메라

### 2-1. 어댑터: 2D 위치 → 3D 지면 좌표 확장 (`worldmap_3d_adapter.gd`)
- 기존 `focus_for_2d_position`은 그대로 두고(정확히 마커 위치인 경우), **새 함수** `focus_for_blend_2d(pos2d: Vector2, t: float = 0.72, fallback: Vector2 = Vector2.ZERO) -> Vector2`를 추가한다: `markers_by_id`의 모든 순서쌍 (a, b)에 대해 `marker_a.global_position.lerp(marker_b.global_position, t)`가 `pos2d`와 **0.5px 이내**이면 `focus_for_city(a).lerp(focus_for_city(b), t)`를 돌려준다(3D 좌표 `marker_xz` 사용). 후보가 둘 이상이면 오차가 가장 작은 것. 없으면 기존 `focus_for_2d_position`으로 되돌리고(정확히 마커 위치), 그것도 없으면 `fallback`.
- 도시 13개 → 순서쌍 156개라 비용은 무시해도 된다. 3D에 도시가 없으면(마커는 있는데 `marker_xz`에 id가 없음) 그 쌍은 건너뛴다.

### 2-2. 3D 컨트롤러: 변환 함수 연결 (`worldmap_3d_camera_controller.gd`)
- `var focus_converter := Callable()` 추가(주석: 2D 위치 → 3D 지면 좌표; host가 어댑터 함수를 연결). `start_battle_entry_handoff`에서 `focus_position`을 `focus_converter.call(focus_position)`로 바꿔 쓰되, **converter가 유효하지 않으면 지금처럼 카메라 연출 없이 `continue_callable.call()` 후 false**(안전한 기본, 3D 좌표를 오해하지 않도록). `skip_battle_entry_camera`는 남겨 둔다(true면 연출 건너뜀, 테스트·긴급용). 대기 시간(`BATTLE_ENTRY_PAN_SEC + HOLD_SEC`)은 1절 2번 결과로 모자랄 때만 3D 컨트롤러 안의 상수로 늘린다.
- `skip_battle_entry_handoff`의 목표 위치도 변환된 3D 좌표를 쓰게 한다(`_battle_entry_handoff_target_position`에 변환값 저장).

### 2-3. 호스트: 연결 (`worldmap_3d_host.gd`)
- `_replace_camera_controller`에서 `controller.skip_battle_entry_camera = true`를 **지우고** `controller.focus_converter = Callable(self, "_focus_for_battle_entry")`를 연결한다. `_focus_for_battle_entry(pos2d: Vector2) -> Vector2`는 어댑터 `focus_for_blend_2d(pos2d, 0.72, <변환 실패 표시>)`를 부르되, **실패하면** 빈 값 대신 `Vector2.INF`를 돌려주고 3D 컨트롤러가 `INF`면 연출을 건너뛰고 `continue_callable.call()`(전투는 그대로 진행되어야 한다 — 연출 실패가 전투 진입을 막으면 안 됨).
- 72% 상수는 main의 값과 같아야 하므로 호스트에 `const BATTLE_ENTRY_BLEND := 0.72`로 두고, 호스트 테스트가 `main.call("_build_worldmap_battle_entry_focus", source, target)`의 실제 결과로 변환이 맞는지 검증한다(main이 비율을 바꾸면 테스트가 크게 실패).

## 3. 메모리 측정 도구 (`scripts/worldmap/map3d/worldmap_3d_mem_probe.gd`, 새 파일)

- `class_name WorldMap3DMemProbe extends RefCounted`. 장면 전환을 넘어 살아남아야 하므로 `Engine.set_meta("wm3d_mem_probe", probe)`로 붙잡는다(autoload·새 폴더 금지).
- `sample(label: String) -> Dictionary`: `Time.get_unix_time_from_system`, `label`, `video_mb`, `texture_mb`, `buffer_mb`(각 `Performance.get_monitor(...) / 1048576.0`), `object_count`, `object_resource_count`, 현재 장면 이름. 이를 `user://wm3d_mem_log.csv`에 한 줄 추가(파일이 없으면 헤더 포함 생성). 저장 실패는 `push_warning`만(게임을 멈추지 않음).
- 호스트가 아래 시점에 호출(3D 모드일 때만, 호스트에 `@export var mem_probe_enabled := true`):
  1. `map_ready`: 3D 레이어 생성 + 2프레임 뒤
  2. `before_battle`: `main.tree_exiting` 시그널(전투 장면 전환 직전, 3D 레이어가 아직 해제되지 않은 시점). `main`이 `change_scene`으로 나가므로 호스트가 `main.tree_exiting.connect`로 건다.
  3. `battle_ready_plus_60f`: 전투 장면이 올라온 뒤 60프레임. 호스트가 이미 해제되므로 **`get_tree().create_timer` 대신 프로브 객체가 `Engine.get_main_loop()`의 `process_frame`을 60번 센 뒤** 기록한다(콜백은 프로브의 메서드 — 장면 전환 후에도 프로브가 `Engine` 메타로 살아 있어야 함. 이 방식이 동작하는지 1절 3번 확인과 함께 로컬 테스트로 증명).
  4. `world_ready_after_return`: 복귀 후 `map_ready`는 08에서 `WorldMap.tscn` 안의 3D 레이어가 켜질 때 같은 프로브(`Engine` 메타의 `wm3d_mem_pending_return`)를 읽어 기록하게 **인터페이스만 준비**한다: 프로브에 `mark_pending_return()`을 만들어 `before_battle`에서 호출. 07에서는 복귀가 2D라 4번은 기록되지 않는 것이 정상이며 보고서에 그렇게 적는다.
- 3회 반복·`user://` 경로 안내는 김작 F6 안내(8절)에 넣는다. 헤드리스에서 값이 0이면 테스트는 "값이 숫자이고 CSV 형식이 맞다"만 검사한다.

## 4. 새·고친 테스트

모두 `tests/scripts/test_worldmap3d_*.gd`(3D CI가 자동 실행). 결과 줄 원문을 보고.
1. `test_worldmap3d_adapter.gd`: `focus_for_blend_2d` — 임의의 두 도시 순서쌍에서 72% 지점을 넣으면 3D 쪽도 같은 비율 지점이 나온다(13개 도시 전 쌍에서 오차 ≤ 0.001km), 정확히 마커 위치면 그 도시, 어느 쪽도 아니면 fallback, 0.5px 초과로 어긋나면 fallback. 기존 48검사 유지.
2. `test_worldmap3d_camera_controller.gd`: converter가 연결된 상태에서 `start_battle_entry_handoff` → 카메라 목표가 변환된 좌표, 진행 중 플래그 true, 끝나면 `continue_callable`이 **정확히 1번** 호출, `skip_battle_entry_handoff` 후에도 1번만, converter 무효·`INF`면 즉시 continue(연출 없음). 기존 50검사 유지.
3. `test_worldmap3d_host.gd`: 실제 `WorldMap3D_Host_Test.tscn`에서 `main.call("_build_worldmap_battle_entry_focus", ...)`의 결과를 호스트 변환에 넣으면 3D 좌표가 두 도시의 3D 좌표를 0.72로 보간한 값과 같다(도시 쌍 여러 개). 3D 모드의 컨트롤러가 `skip_battle_entry_camera == false`이고 converter가 연결됨. 핸드오프 진행 중 `set_map_view_3d(false)`가 여전히 false를 돌려준다(기존 동작). 기존 38검사 중 `skip_battle_entry_camera`를 true로 기대하던 검사는 새 동작으로 고쳐 쓴다(바뀐 검사 목록을 보고).
4. `tests/scripts/test_worldmap3d_mem_probe.gd`(새): `sample` 반환 키·타입, CSV 헤더·행 추가(`user://` 임시 경로 사용, 끝나면 지움), 저장 경로가 쓰기 불가일 때 예외 없이 경고만, 프레임 대기 콜백이 장면 전환 후에도 도는지(가능하면 `change_scene_to_packed`로 빈 장면 2개를 오가며 증명, 헤드리스에서 어려우면 그 이유와 대신 한 검사를 보고).

## 5. 수정·추가 경로 (이 목록이 전부)

1. `scripts/worldmap/map3d/worldmap_3d_adapter.gd`
2. `scripts/worldmap/map3d/worldmap_3d_camera_controller.gd`
3. `scripts/worldmap/map3d/worldmap_3d_host.gd`
4. `scripts/worldmap/map3d/worldmap_3d_mem_probe.gd`
5. `scripts/worldmap/map3d/worldmap_3d_mem_probe.gd.uid`
6. `tests/scripts/test_worldmap3d_adapter.gd`
7. `tests/scripts/test_worldmap3d_camera_controller.gd`
8. `tests/scripts/test_worldmap3d_host.gd`
9. `tests/scripts/test_worldmap3d_mem_probe.gd`
10. `tests/scripts/test_worldmap3d_mem_probe.gd.uid`

목록 밖이 `git status --short`에 나오면 멈추고 보고.

## 6. 로컬 검증 (매번 `godot --headless --path . --script …`, 결과 줄 원문을 표로)

1. 4절 테스트를 **코드 변경 전**(테스트만 먼저 작성)에 돌려 새 동작을 단언하는 검사가 실패하는지 확인 → 변경 후 `failures=[]`.
2. 기존 3D 테스트 전부(`tests/scripts/test_worldmap3d_*.gd`) 변화 없음(어댑터 48+, 카메라 50+, 외부 입력 20, 호스트 38±, 색 일치 57, 길 일치 06 보고서의 개수).
3. 정적 검증기 72개 전체(특히 pinned-main: `validate_worldmap_diplomacy_routing.py`), `git diff --stat`에 `worldmap_main.gd` 변경 0.
4. `res://WorldMap3D_Host_Test.tscn`·`res://WorldMap.tscn` `--quit-after 5` 오류 줄 0.
5. 기존 `WorldMap.tscn` 로드 테스트 3개(06 보고서와 같은 표)가 고치기 전/후 같음.
6. 1절 조사 표.

## 7. 커밋·push·CI

1. 커밋 1: `feat(worldmap): 3D battle-entry camera and memory probe, main untouched (T-WM3D-07)`
2. `git push origin feature/wm3d-intake-20261101`, 원격 해시 = 로컬 HEAD.
3. `gh run watch`로 `Verify C-track refactor`(4 shard)와 `Verify WorldMap3D` 결과·단계, shard 0 컷인 줄과 첫 컷인 fps를 항상 보고(큐 4절 예외 규칙 참고). 실패하면 고치지 말고 큐 4·5절 절차(원인 읽기 전용 조사 → 멈춤 보고).
4. 보고서 커밋(`[skip ci]`), `PROGRESS_WM3D.md` 갱신.

## 8. 보고서 (`agent/REPORT_WM3D_07_20261105.md`)

1. 맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약.
2. "택한 해석" 줄, 1절 조사 표, 6절 결과 표, 바뀐 검사 목록, diff(코드 전체), CI 표.
3. 막힌 것(없으면 "없음").
4. **김작 F6 안내(그대로 옮길 것):** ① `res://WorldMap3D_Host_Test.tscn` F6 → 새 게임 → 아군 도시에서 인접 적 도시 공격 → 3D 카메라가 두 도시 사이로 접근하다가 전투로 넘어가는지 ② 접근 중 Space·Enter·Esc·왼쪽 클릭으로 건너뛰기 → 전투가 한 번만 시작되는지 ③ 접근 중 다른 도시를 클릭하거나 휠·WASD를 눌러도 아무 일이 없는지 ④ 전투 후 일반 2D 월드맵으로 돌아오는 것은 정상(08에서 3D 복귀) ⑤ **(선택)** 전투 진입을 3번 반복한 뒤 `user://wm3d_mem_log.csv`(Godot 메뉴 `프로젝트 > 사용자 데이터 폴더 열기`)를 열어 `video_mb`가 숫자로 찍혔는지 알려줄 것.
5. 종료 루틴 5줄(큐 8절과 같은 형식).

## 9. 하지 않는 것

- `worldmap_main.gd`·2D 카메라 컨트롤러·`Battle_Main.tscn`·전투 쪽 코드 수정, 3D 전투 연결(M7), 복귀 장면 변경(`result_return_destination`), autoload 추가, 연출 시간을 F6 없이 임의로 크게 바꾸기(1절 2번의 계산 근거가 있을 때만), 컷인 테스트 수정(관찰만), 재실행으로 때우기, 08 작업.
