기준 화면: 정본 가지 `feature/wm3d-intake-20261101`에서 `res://WorldMap.tscn`(정식 월드맵) F6 → 3D 지도로 시작(설정에서 2D로 바꿀 수 있음) → 도시 선택·내정·전투 진입(07 카메라)·전투 → **전투 후 3D 월드맵으로 복귀** → 저장/불러오기 → 턴 종료까지 한 판이 이어진다.
합격 기준: 김작 F6 — ① `WorldMap.tscn`이 3D로 열리고 HUD·도시 선택·내정·외교·턴 종료가 기존과 같다 ② 전투 후 3D 월드맵으로 돌아온다(2D로 떨어지지 않음) ③ 설정에서 2D/3D 전환과 3D 카메라 입력 방식이 바뀌고 다음 실행에도 유지된다 ④ 2D로 전환해도 기존 2D F6 전체가 그대로 통과한다 ⑤ 저장→불러오기에 3D/2D 설정이 섞여 들어가지 않는다. 자동 조건: 새·고친 테스트 통과, 정적 검증기 전체 통과(재고정 1회 포함), 올린 커밋에서 `Verify C-track refactor` 4 shard와 `Verify WorldMap3D` success. GTX 1660 실기 60fps와 최종 `main` 합류는 김작(밤).

# 지시서 — T-WM3D-08: 3D 월드맵을 정식 `WorldMap.tscn`으로 전환 (main 파일 1회 수정 + 재고정)

- 작성: 클코치, 2026-11-05 11:50 / 큐: `agent/ORDER_QUEUE.md` 순서 3번(마지막)
- 시작 HEAD: 07 코드 커밋 + 07 보고서 이후(`feature/wm3d-intake-20261101`). 07 보고서가 없거나 07 CI가 빨간색이면 시작하지 말고 PROGRESS에 "대기 중"을 적고 멈춤.
- 이 단계에서만 `scripts/worldmap/worldmap_main.gd` 수정이 허용된다(핀 검증기 재고정 포함, 1회).
- 아래 [사실]은 이전 읽기 결과이고, **1절 조사에서 실제 줄 번호로 다시 확인**한 뒤에만 작업한다. 다르면 멈춤.
  - 3D 레이어 구조: `CanvasLayer(-10) > SubViewportContainer > SubViewport > worldmap3d_eastasia.tscn`. 지금은 `WorldMap3D_Host_Test.tscn`에서 `WorldMap3DHost`가 `WorldMap`의 형제로 붙어 어댑터를 만들고 `main._camera_controller`를 `WorldMap3DCameraController`로 바꿔 끼운다.
  - 게임 로직은 2D `WorldMapCityMarker` 노드가 그대로 맡고, 3D 활성 시 2D `WorldMapRoot`는 숨긴다. HUD는 그대로.
  - 복귀: `battle_context["result_return_destination"] = "res://WorldMap.tscn"`(main ≈6516행). 지금은 호스트 테스트 장면이 아닌 일반 2D 월드맵으로 돌아간다.
  - `scripts/` 는 `worldmap3d/` 클래스를 타입·`preload`로 참조하면 안 된다(C-track이 `worldmap3d/`를 `.gdignore`, 모바일 제외). 3D는 **문자열 경로로만** 로드한다.
  - 설정 화면은 현재 `system → 오디오 설정` 팝업뿐(카메라·입력·2D/3D 설정 없음).
  - 핀: `tools/validate_worldmap_diplomacy_routing.py`, `tools/p1_exact_delta.py`(`P1_MAIN_CHECKPOINT`/`EXPECTED_P1_MAIN_DELTA`)가 `worldmap_main.gd`를 고정한다.

## 0. 규칙

1. 시작 전 `git status` 깨끗, 07 완료 확인. 아니면 멈춤.
2. **한 번에 한 줄도 임의로 넓히지 않는다.** 수정 가능 경로는 5절 목록뿐. 목록 밖은 멈춤.
3. `worldmap_main.gd`는 **필요한 최소 줄만**, 그 diff를 보고서에 전부 싣는다. 수정 직후 핀 검증기가 실패하는 것은 정상이며, 그 수정에서 재고정까지 **같은 커밋 안에서** 끝낸다(검증기를 약화·삭제하지 말고 체크포인트/기대 delta 값만 갱신, 갱신 근거를 보고서에 표로).
4. 큐 6절 규칙(`feature/wm3d-*`만 push, force 금지, `gh` 읽기만, 코드 → CI → 보고서 `[skip ci]`, 진행 기록 갱신)을 따른다. 보고서: `agent/REPORT_WM3D_08_20261105.md`.
5. **2D 모드가 완전히 살아 있어야 한다.** 3D 레이어가 없거나(파일 없음·모바일·로드 실패) 설정이 2D면 지금과 100% 같은 동작(`WorldMap.tscn` 그대로). 3D 실패가 게임 진행을 막으면 안 된다.
6. 시간이 오래 걸리거나 위험하면 7절 "하위 단계 순서"에서 **앞 단계까지만 커밋**하고 나머지는 보고서에 "미완/이유"로 남긴다. 반쯤 된 상태를 합격으로 쓰지 않는다.

## 1. 먼저 읽기 전용 조사 (보고서 표)

1. `WorldMap3D_Host_Test.tscn`·`worldmap_3d_host.gd`가 하는 일 전부(노드 구성, 어댑터 생성 시점, 컨트롤러 교체, 3D 켜기/끄기, 2D 숨김, 입력 처리). 이것을 `WorldMap.tscn`에서 어떻게 재현할지 최소안.
2. `WorldMap.tscn`의 루트 구조와 `worldmap_main.gd`의 `_ready`(어디서 `_camera_controller`가 만들어지는지, `_ensure_camera_controller` ≈1173행, 호스트 훅을 낄 지점). **main 안에 넣어야 하는 줄이 정말 필요한지** — 호스트 노드가 `WorldMap` 장면의 자식 또는 형제로 들어가 main 수정 없이 동작 가능한지 먼저 판단. 불필요하면 main 수정 0(이 경우 재고정 없음, 이유 보고).
3. `result_return_destination`(≈6516행)이 쓰이는 모든 곳. 복귀 목적지를 `WorldMap.tscn`에 3D 레이어가 들어가면 자동으로 해결되는지(같은 장면이므로 그대로 3D가 다시 만들어짐) 확인. 안 되면 필요한 최소 수정.
4. 저장/불러오기: `WorldMap.tscn`이 로드될 때 3D 레이어가 어떤 순서로 생기고, 불러온 게임 상태(도시 소유 등)가 3D 색에 반영되는지(05의 색 일치 + 호스트의 갱신 연결 유지). 설정(2D/3D, 카메라 방식)은 **저장 파일이 아닌 사용자 설정**에 둔다 — 기존 사용자 설정 저장소(오디오 설정이 쓰는 곳)가 무엇인지 확인.
5. 설정 화면: `system → 오디오 설정` 팝업 코드 위치, 항목 추가에 필요한 최소 수정 위치.
6. `.github/workflows/verify-c-track.yml`·`verify-worldmap3d.yml`이 `WorldMap.tscn` 변경으로 어떤 테스트를 실행하는지, `worldmap3d/` `.gdignore` 처리와 새 코드가 충돌하지 않는지.
7. 모바일 제외: `export_presets.cfg`가 없으므로 만들지는 않는다. 대신 문서(`docs/WORLDMAP3D_EXPORT_NOTES.md` — 5절 목록 참고)에 "모바일 내보내기는 `worldmap3d/**` 제외 필터, 코드는 `ResourceLoader.exists`로 3D 없으면 2D" 원칙만 기록.

## 2. 구현 (하위 단계 순서 — 위에서부터 커밋 가능한 단위로)

### 2-A. 3D 레이어를 정식 `WorldMap.tscn`에서 켜기
- `WorldMap.tscn`(또는 main이 로드하는 방식 중 1절 2번에서 정한 최소안)에 호스트(`WorldMap3DHost` 또는 그 정식 이름의 노드)를 포함. 호스트가 없으면 완전 2D. 3D 리소스가 없거나 로드 실패 시 호스트가 스스로 꺼지고 2D 유지(경고만).
- main이 호스트 클래스를 타입으로 알면 안 된다. 호스트가 main을 알고 붙는 현재 방향을 유지.
- 설정이 2D면 호스트는 3D를 만들지도 않는다(VRAM 절약).

### 2-B. 전투 후 3D 월드맵 복귀
- 1절 3번 결과대로. 같은 장면(`WorldMap.tscn`)으로 돌아오면 2-A의 호스트가 다시 만들어지므로 3D 복귀가 자동. 복귀 직후 도시 소유색·턴 상태가 반영되는지 테스트.
- 07의 메모리 프로브 `world_ready_after_return`(`mark_pending_return` 인터페이스)을 호스트의 `map_ready`에서 읽어 기록하도록 연결. 3D 재구성 시간(복귀 후 `map_ready`까지 ms)도 같은 CSV에 기록.

### 2-C. 설정: 2D/3D 전환 + 3D 카메라 입력 방식(A/B)
- 설정 화면(오디오 팝업이 열리는 곳)에 항목 2개 추가: ① 월드맵 표시 2D/3D(기본 3D, 3D 리소스가 없으면 2D로 고정 표시) ② 3D 카메라 입력 방식 A/B. A/B가 무엇인지는 현재 `worldmap_3d_camera_controller.gd`·`worldmap_camera.gd`·`input` 코드의 **실제 구현**에서 확인해 이름과 설명을 붙이고(없는 방식을 지어내지 말고), 구현이 하나뿐이면 그 사실을 보고하고 2-C의 ②는 만들지 않는다.
- 저장은 사용자 설정(1절 4번). 게임 저장 파일에는 넣지 않는다. 저장→불러오기 테스트로 확인.
- 바꾼 뒤 적용은 "다음 월드맵 진입부터" 또는 즉시 중 1절 조사로 안전한 쪽만(즉시 전환이 어렵다면 안내 문구).

### 2-D. 2D 전환 경로 전체 검증
- 설정을 2D로 한 `WorldMap.tscn`에서 기존 2D F6 흐름이 변하지 않는지 자동 테스트로(기존 `WorldMap.tscn` 로드 테스트 3개 + 기존 C-track 전부).

### 2-E. (마지막) 3D 카메라 컨트롤러와 2D 컨트롤러 분리 — 김작 의견: 분리
- 큐 규칙대로 **마지막 하위 단계**. `WorldMap3DCameraController`가 2D `WorldMapCameraController`를 상속하는 구조를 끊을 때의 영향 범위를 먼저 파일·줄로 표로 만든다(공용 메서드, main이 호출하는 이름, 테스트).
- 위험이 작고(변경 파일 5절 목록 안, 기존 3D 테스트 전부 통과) 시간이 합리적이면 분리해 커밋. 아니면 **하지 말고** "비용 큼, 이유, 필요한 파일 목록"을 보고서에 적고 미완으로 남김(이 경우도 합격에 영향 없음).

### 2-F. 문서
- `docs/WORLDMAP3D_EXPORT_NOTES.md`(새) — 모바일 제외 원칙, 3D 폴백, 저장 파일과 사용자 설정 구분. `docs/CREDITS.md`가 있으면 지도 데이터(ETOPO 2022 등) 표기 확인만 하고 없으면 "없음"으로 보고(만들지 말 것 — 릴리스 체크리스트에서 별도 결정).

## 3. 테스트 (모두 `tests/scripts/test_worldmap3d_*.gd` 또는 기존 이름 규칙, 결과 줄 원문 보고)

1. 정식 `WorldMap.tscn`에서 3D 모드: 호스트 생성, 어댑터 도시 13개, 컨트롤러 교체, 2D `WorldMapRoot` 숨김, HUD 노드 존재.
2. 설정 2D: 호스트가 3D를 만들지 않음, `WorldMapRoot` 보임, 기존 카메라 컨트롤러 유지.
3. 3D 리소스 없음 시뮬레이션(경로 존재 검사를 대체하는 플래그 등 테스트 가능한 방법): 2D로 폴백하고 오류 없음.
4. 복귀: 전투 컨텍스트를 만들고 월드맵을 다시 로드(실제 전투 장면을 돌리지 말고 복귀 처리 경로만)했을 때 3D 레이어가 다시 생기고 도시 소유색이 컨텍스트 결과를 반영.
5. 설정 저장/불러오기: 사용자 설정이 게임 저장 파일에 들어가지 않음, 재시작 후 유지.
6. 핀 재고정 후 `validate_worldmap_diplomacy_routing.py`·`p1_exact_delta.py` 포함 정적 검증기 전부 통과(수정 전 실패하는 것을 한 번 확인한 기록 포함).
7. 기존 3D 테스트 전부, 기존 C-track 로컬 대표 테스트, `--quit-after 5`로 `WorldMap.tscn`·`WorldMap3D_Host_Test.tscn` 오류 줄 0.

## 4. 로컬 검증·CI

1. 06·07과 같은 표 형식으로 로컬 결과 원문. `git status --short`가 5절 목록 안인지, `git diff --check`.
2. 커밋 분리: (a) 코드 커밋 1개(핀 재고정 포함), 필요하면 하위 단계별 추가 커밋 — 단 **main을 건드리는 커밋은 재고정과 같은 커밋**, 각 커밋 push 후 CI 확인. (b) 보고서 `[skip ci]`.
3. `Verify C-track refactor`(4 shard)·`Verify WorldMap3D` 결과와 단계, 첫 컷인 fps 줄을 보고(큐 4절 예외 규칙). 실패하면 고치지 말고 큐 4·5절 절차.

## 5. 수정·추가 가능 경로 (이 목록이 전부 — 1절 조사 후 불필요한 것은 건드리지 않아도 됨)

1. `WorldMap.tscn`
2. `scripts/worldmap/worldmap_main.gd` (1절 2번이 "필요"라고 증명한 최소 줄만)
3. `scripts/worldmap/map3d/*.gd`(+`.uid`) — 호스트·어댑터·컨트롤러·프로브
4. 설정 화면 스크립트 1~2개(1절 5번에서 확인한 실제 파일만)
5. 사용자 설정 저장 코드(1절 4번에서 확인한 실제 파일만)
6. `tools/validate_worldmap_diplomacy_routing.py`, `tools/p1_exact_delta.py` (체크포인트/기대 delta 값 갱신만)
7. `tests/scripts/test_worldmap3d_*.gd`(+`.uid`) 및 기존 `WorldMap.tscn` 관련 테스트 중 1절/3절이 요구한 것만
8. `.github/workflows/verify-worldmap3d.yml` (paths 필터 보강이 필요할 때만)
9. `docs/WORLDMAP3D_EXPORT_NOTES.md` (새)

목록 밖이 필요하면 멈추고 보고.

## 6. 보고서 (`agent/REPORT_WM3D_08_20261105.md`)

1. 맨 위 "기준 화면 / 합격 기준" 두 줄, 3줄 요약, "택한 해석", 1절 조사 표, 하위 단계별 완료/미완 표, 로컬 결과 표, main diff 전체와 재고정 근거 표, CI 표, 막힌 것.
2. **김작 F6 안내(그대로 옮길 것):** ① `WorldMap.tscn` F6 → 3D로 열림, HUD·도시 클릭·내정·외교 정상 ② 전투 진입 → 접근 연출 → 전투 → 3D 월드맵 복귀(복귀 후 소유색·턴 정상) ③ 설정에서 2D로 전환 → 다음 진입에 2D, 기존 2D 한 판 정상 ④ 저장→불러오기, 턴 종료 ⑤ 카메라 입력 방식 전환(구현된 경우) ⑥ GTX 1660 실기 60fps(`tools/perf_bench` 또는 직접 플레이) ⑦ `user://wm3d_mem_log.csv`에 전투 3회 반복 기록.
3. `main` 합류 전 점검 요약(합류는 김작 승인): 변경 파일 수, 핀 재고정 여부, 남은 미완.
4. 종료 루틴 5줄(큐 8절 형식).

## 7. 멈춤 조건

- 1절 사실과 코드가 다름, main 수정이 둘 이상의 의미 있는 덩어리로 커짐, 핀 재고정이 값 갱신 이상(검증기 로직 변경)을 요구함, CI 실패 원인이 지시 범위 밖, 목록 밖 파일 필요, 2D 모드 회귀 발견 → 멈추고 `PROGRESS`와 `agent/STOP_WM3D_08_<n>.md`에 사실만 기록.

## 8. 하지 않는 것

- 3D 전투 연결(M7), 09 북쪽 디오라마, 새 에셋 도입, `export_presets.cfg` 생성, `main`/보호 가지 push, 검증기 약화, 2D 동작 변경, 컷인 테스트 손대기, 재실행으로 때우기.
