# B3D-F1 — 3D 연결 테스트 보강 결과 (2026-10-19)

## 결과 / 범위

- 기준: `62f5b726260aa3e6134225e7e903b1098792f23a`.
- 브랜치: `test/battle3d-hardening-20261019`; S1-1 커밋을 포함하지 않는 별도 브랜치.
- 구현 커밋: 이 보고서를 포함하는 커밋. 정확한 해시는 검수 ZIP의 `evidence/FINAL_CLOSEOUT.txt` 및 최종 응답에 기록한다 (자기 해시를 커밋 내용에 넣을 수 없음).
- Level 2 로컬 검증. push/병합하지 않음. S1-1과 워크플로 호출 보존은 후속 통합 시 클코치가 처리.
- 기존 3D/전투/서비스/씬/프로젝트 파일 무변경. `scripts/battle3d/**` 14개 파일(.uid 포함)은 기준 커밋과 실제 바이트 비교 전부 일치.
- 변경: 이동 parity 테스트, contract validator; 추가: 비스듬한 클릭 테스트 및 UID, 이 보고서. 모드 테스트는 변경 없이 재실행.
- 워크플로: validator 1개와 테스트 3개 호출 추가만 (+4/-0). CI 실행/통과를 주장하지 않음.

## A — 표시 필드 계약

지시서의 14개 필드를 현재 소스 `scripts/battle3d/battle3d_unit_adapter.gd:3`와 대조한 후 테스트와 validator에 독립 상수로 작성했다. 구현 목록을 순회해 기대 목록을 생성하지 않는다. 목록의 길이/순서/원소 일치, 반환 view의 정확한 키 집합, 각 값과 deep copy 격리를 검사한다. status_effects가 빠져도 런타임 예외로 중단되지 않고 명시적인 assertion 실패와 종료 코드 1을 남긴다.

## B — 카메라 / 가시성 / 평면 민감도

소스 근거 (62f5b72의 `scripts/battle3d/lab_presentation.gd`):

- 8행: 전장 중앙 focus; 9행: 기본 yaw 0.32; 10행: 기본 zoom 60.
- 50~51행: 정사영, far 200.
- 210~213행: size=zoom, position=focus+Vector3(sin(yaw)*43,40,cos(yaw)*43), look_at(focus).
- 252행: zoom 20~70 clamp.
- `project.godot:26~27`: viewport 1920×1080. 테스트는 플랫폼별 headless 창 크기 차이를 피하도록 동일 크기의 독립 SubViewport를 사용한다.

각 셀 중심을 실제 `grid_to_world_3d`로 얻고, `unproject_position`으로 화면에 투영한 뒤 `project_ray_origin/normal`로 클릭 레이를 만든다. 실제 GLB의 Terrain/Ford 충돌을 생성하고 physics frame 2회를 진행한 후 실제 picker에 전달한다.

가시 판정은 검사 대상 picker의 결과에 의존하지 않는다. 카메라 뒤/화면 사각형 밖의 중심은 제외한다. 기존 가림 테스트와 같은 0.02 월드 단위 간격의 heightfield 전진 샘플링에서 목표 셀보다 먼저 다른 셀의 지표면을 만나면 제외한다. 셀 중심 가시성을 검사하며 셀 전체 면적의 가시성을 의미하지 않는다. 단위/나무는 기존 picker와 같이 가림 마스크 대상이 아니다. 이 9개 높은 카메라에서는 지형 가림 제외가 0건이며, 낮은 시점 가림 2건은 기존 parity 테스트가 계속 검사한다.

| yaw | zoom | 가시 셀 | 통과 | 평면 교차와 다름 | 화면 밖 | 지형 가림 |
|---:|---:|---:|---:|---:|---:|---:|
| 0.32 | 24 | 139 | 139 | 17 | 41 | 0 |
| 0.32 | 40 | 180 | 180 | 25 | 0 | 0 |
| 0.32 | 60 | 180 | 180 | 25 | 0 | 0 |
| 0.00 | 24 | 140 | 140 | 21 | 40 | 0 |
| 0.00 | 40 | 180 | 180 | 25 | 0 | 0 |
| 0.00 | 60 | 180 | 180 | 25 | 0 | 0 |
| 0.80 | 24 | 135 | 135 | 5 | 45 | 0 |
| 0.80 | 40 | 180 | 180 | 17 | 0 | 0 |
| 0.80 | 60 | 180 | 180 | 17 | 0 | 0 |

총 1,494개 셀-카메라 조합 통과. 평면 교차와 다른 조합은 177개이며, 카메라별 최소 N=5개(범위 5~25)다. 177은 중복 제거한 고유 셀 수가 아니라 조합 수다. 각 조합별 가시 셀>0 및 평면과 다른 셀>0을 테스트 자체에서 요구한다.

## 음성 프로브 재현

별도 로컬 clone에서만 변조했다. 실행 중인 작업 복사본은 변조하지 않았다. 별도 복사본의 원본 파일도 프로브 후 복원했다. 대조군 parity/validator/oblique는 모두 exit 0. 아래 변조는 각각 원래 파일에서 독립적으로 적용했다.

| 변조 | parity 테스트 | validator | oblique 테스트 |
|---|---|---|---|
| VIEW_FIELDS에서 status_effects 제거 | exit 1 / 31 실패 | exit 1 | 해당 없음 |
| VIEW_FIELDS 끝에 current_hp 추가 | exit 1 / 16 실패 | exit 1 | 해당 없음 |
| VIEW_FIELDS의 unit_id와 side 순서 교환 | exit 1 / 1 실패 | exit 1 | 해당 없음 |
| picker 본문을 y=0 교차로 대체 | 해당 없음 | 해당 없음 | exit 1 / 177 실패 |
| 기존 picker를 내부 함수로 옮기고 반환 Vector2i의 x,y를 교환 | 해당 없음 | 해당 없음 | exit 1 / 1,411 실패 |

평면 변조: t=-origin.y/direction.y, point=origin+direction*t, heightfield.cell_at(point)를 반환하며 음수 t/평행/범위 밖 처리를 유지한다. 좌표 뒤바꿈은 기존 함수를 `_original_world_to_grid_from_ray`로 이름만 바꾸고 원래 API가 Vector2i(cell.y,cell.x)를 반환하도록 감쌌다. 모두 정상 컴파일 후 assertion으로 실패했으며 구문 오류로 실패한 것이 아니다. 복원 후 oblique exit 0을 확인했다.

## 실행 결과 / 한계

Godot 4.6.2 stable 및 Python 3.14. 실제 실행한 최종 결과:

- movement parity: 66,148 checks, 0 failures; 15 시나리오; 수직 클릭 540건 및 가림 2건 유지.
- oblique: 1,522 checks, 0 failures; 클릭 1,494건.
- modes: 20 checks, 0 failures.
- contract validator: PASS.
- headless import: exit 0. 기존 전투 씬 간 UID duplicate 경고 2개가 출력됨 (전체 원문 아래). 해당 씬은 무변경이며 이 작업에서 UID를 고치지 않았다.
- 테스트가 드러낸 실제 3D 동작 버그: 이번 범위에서는 발견되지 않음.
- 미실행: GUI 수동 클릭, 다른 해상도/모든 연속 yaw·zoom·pan 조합, 원격 CI, 전체 전투/월드맵 회귀. 고정 9개 조합의 셀 중심 클릭 검증이며 픽셀 렌더 검증은 아니다.
- 범위 검증과 `git diff --check` 완료 후 로컬 커밋. 최종 clean 상태는 외부 closeout 원문에 기록.

## 재실행 명령

```text
godot --headless --editor --path . --import
godot --headless --path . --script tests/scripts/test_battle3d_movement_parity.gd
godot --headless --path . --script tests/scripts/test_battle3d_modes.gd
godot --headless --path . --script tests/scripts/test_battle3d_oblique_click.gd
python tools/validate_battle3d_contract.py
git diff --check 62f5b72..HEAD
git diff --name-status 62f5b72..HEAD
```

## 출력 원문

아래는 각 명령의 stdout/stderr 전체 내용이다 (줄바꿈만 텍스트 문서 형식으로 정규화). 최종 실행 로그 및 프로브 원본 바이트는 검수 ZIP의 evidence에도 포함한다.

### import

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[   0% ] [90m[1mfirst_scan_filesystem[22m | Started Project initialization (5 steps)[39m[0m
[   0% ] [90m[1mfirst_scan_filesystem[22m | Scanning file structure...[39m[0m
[  16% ] [90m[1mfirst_scan_filesystem[22m | Loading global class names...[39m[0m
[  33% ] [90m[1mfirst_scan_filesystem[22m | Verifying GDExtensions...[39m[0m
[  50% ] [90m[1mfirst_scan_filesystem[22m | Creating autoload scripts...[39m[0m
[  66% ] [90m[1mfirst_scan_filesystem[22m | Initializing plugins...[39m[0m
[  83% ] [90m[1mfirst_scan_filesystem[22m | Starting file scan...[39m[0m
[92m[ DONE ][39m [1mfirst_scan_filesystem[22m
[0m
WARNING: UID duplicate detected between res://tests/scenes/Battle_UI_Production_Test.tscn and res://_incoming/Battle_Land_BEFORE_T08_BACKUP.tscn.
   at: _process_file_system (editor/file_system/editor_file_system.cpp:1377)
WARNING: UID duplicate detected between res://Battle_Land.tscn and res://tests/scenes/Battle_UI_Production_Test.tscn.
   at: _process_file_system (editor/file_system/editor_file_system.cpp:1377)
[   0% ] [90m[1mupdate_scripts_classes[22m | Started Registering global classes... (2 steps)[39m[0m
[   0% ] [90m[1mupdate_scripts_classes[22m | [39m[0m
[  33% ] [90m[1mupdate_scripts_classes[22m | [39m[0m
[92m[ DONE ][39m [1mupdate_scripts_classes[22m
[0m
[   0% ] [90m[1mloading_editor_layout[22m | Started Loading editor (5 steps)[39m[0m
[   0% ] [90m[1mloading_editor_layout[22m | Loading editor layout...[39m[0m
[  16% ] [90m[1mloading_editor_layout[22m | Loading docks...[39m[0m
[92m[ DONE ][39m [1mloading_editor_layout[22m
[0m
```

### test_battle3d_movement_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

SCENARIO PASS empty_infantry budget=3
SCENARIO PASS empty_cavalry budget=4
SCENARIO PASS empty_archer budget=3
SCENARIO PASS empty_gunner budget=2
SCENARIO PASS empty_mounted_archer budget=4
SCENARIO PASS blockers_false budget=3
SCENARIO PASS blockers_true budget=3
SCENARIO PASS edge_(0, 0) budget=3
SCENARIO PASS edge_(17, 9) budget=3
SCENARIO PASS edge_(0, 5) budget=3
SCENARIO PASS edge_(17, 0) budget=3
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
SCENARIO PASS status_{ "movement_down": 2 } budget=2
SCENARIO PASS zero_budget budget=0
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] PASS: 66148 checks, 0 failures; scenarios=15; visible_rays=540
```

### test_battle3d_modes

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

{"event":"ready","grid":"18x10 square","milliseconds":530,"renderer":"gl_compatibility","units":4}
{"event":"move_accepted","milliseconds":548,"steps":2,"unit_id":"lab_ally_01"}
[BATTLE3D_MODES] PASS: 20 checks, 0 failures
```

### test_battle3d_oblique_click

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[OBLIQUE_CAMERA] yaw=0.32 zoom=24 visible=139 passed=139 flat_different=17 outside=41 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=24 visible=140 passed=140 flat_different=21 outside=40 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=24 visible=135 passed=135 flat_different=5 outside=45 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=40 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=60 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[BATTLE3D_OBLIQUE] PASS: 1522 checks, 0 failures; cameras=9; visible=1494; flat_different=177
```

### validate_battle3d_contract

```text
BATTLE3D_CONTRACT PASS: 14-field ordered view contract, projection inheritance, engine query ownership, resources, 18x10 metadata
```

### control_movement_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

SCENARIO PASS empty_infantry budget=3
SCENARIO PASS empty_cavalry budget=4
SCENARIO PASS empty_archer budget=3
SCENARIO PASS empty_gunner budget=2
SCENARIO PASS empty_mounted_archer budget=4
SCENARIO PASS blockers_false budget=3
SCENARIO PASS blockers_true budget=3
SCENARIO PASS edge_(0, 0) budget=3
SCENARIO PASS edge_(17, 9) budget=3
SCENARIO PASS edge_(0, 5) budget=3
SCENARIO PASS edge_(17, 0) budget=3
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
SCENARIO PASS status_{ "movement_down": 2 } budget=2
SCENARIO PASS zero_budget budget=0
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] PASS: 66148 checks, 0 failures; scenarios=15; visible_rays=540
```

### control_validator

```text
BATTLE3D_CONTRACT PASS: 14-field ordered view contract, projection inheritance, engine query ownership, resources, 18x10 metadata
```

### control_oblique_click

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[OBLIQUE_CAMERA] yaw=0.32 zoom=24 visible=139 passed=139 flat_different=17 outside=41 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=24 visible=140 passed=140 flat_different=21 outside=40 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=24 visible=135 passed=135 flat_different=5 outside=45 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=40 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=60 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[BATTLE3D_OBLIQUE] PASS: 1522 checks, 0 failures; cameras=9; visible=1494; flat_different=177
```

### missing_status_movement_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

FAIL: VIEW_FIELDS exact size/order/elements
FAIL: empty_infantry exact view key set
FAIL: empty_infantry field status_effects
SCENARIO PASS empty_infantry budget=3
FAIL: empty_cavalry exact view key set
FAIL: empty_cavalry field status_effects
SCENARIO PASS empty_cavalry budget=4
FAIL: empty_archer exact view key set
FAIL: empty_archer field status_effects
SCENARIO PASS empty_archer budget=3
FAIL: empty_gunner exact view key set
FAIL: empty_gunner field status_effects
SCENARIO PASS empty_gunner budget=2
FAIL: empty_mounted_archer exact view key set
FAIL: empty_mounted_archer field status_effects
SCENARIO PASS empty_mounted_archer budget=4
FAIL: blockers_false exact view key set
FAIL: blockers_false field status_effects
SCENARIO PASS blockers_false budget=3
FAIL: blockers_true exact view key set
FAIL: blockers_true field status_effects
SCENARIO PASS blockers_true budget=3
FAIL: edge_(0, 0) exact view key set
FAIL: edge_(0, 0) field status_effects
SCENARIO PASS edge_(0, 0) budget=3
FAIL: edge_(17, 9) exact view key set
FAIL: edge_(17, 9) field status_effects
SCENARIO PASS edge_(17, 9) budget=3
FAIL: edge_(0, 5) exact view key set
FAIL: edge_(0, 5) field status_effects
SCENARIO PASS edge_(0, 5) budget=3
FAIL: edge_(17, 0) exact view key set
FAIL: edge_(17, 0) field status_effects
SCENARIO PASS edge_(17, 0) budget=3
FAIL: status_{ "mobility_up": 2 } exact view key set
FAIL: status_{ "mobility_up": 2 } field status_effects
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
FAIL: status_{ "movement_down": 2 } exact view key set
FAIL: status_{ "movement_down": 2 } field status_effects
SCENARIO PASS status_{ "movement_down": 2 } budget=2
FAIL: zero_budget exact view key set
FAIL: zero_budget field status_effects
SCENARIO PASS zero_budget budget=0
FAIL: enclosed exact view key set
FAIL: enclosed field status_effects
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] FAIL: 66148 checks, 31 failures; scenarios=15; visible_rays=540
```

### missing_status_validator

```text
Traceback (most recent call last):
  File "C:\Users\seong\.codex\.chatgpt-projects\g-p-6a0731363ec48191860bdb1bbc62ede5\B3D_F1_NegativeProbe\tools\validate_battle3d_contract.py", line 10, in <module>
    assert json.loads(match.group(1)) == EXPECTED_VIEW_FIELDS, 'VIEW_FIELDS exact size/order/elements mismatch'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: VIEW_FIELDS exact size/order/elements mismatch
```

### extra_field_movement_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

FAIL: VIEW_FIELDS exact size/order/elements
FAIL: empty_infantry exact view key set
SCENARIO PASS empty_infantry budget=3
FAIL: empty_cavalry exact view key set
SCENARIO PASS empty_cavalry budget=4
FAIL: empty_archer exact view key set
SCENARIO PASS empty_archer budget=3
FAIL: empty_gunner exact view key set
SCENARIO PASS empty_gunner budget=2
FAIL: empty_mounted_archer exact view key set
SCENARIO PASS empty_mounted_archer budget=4
FAIL: blockers_false exact view key set
SCENARIO PASS blockers_false budget=3
FAIL: blockers_true exact view key set
SCENARIO PASS blockers_true budget=3
FAIL: edge_(0, 0) exact view key set
SCENARIO PASS edge_(0, 0) budget=3
FAIL: edge_(17, 9) exact view key set
SCENARIO PASS edge_(17, 9) budget=3
FAIL: edge_(0, 5) exact view key set
SCENARIO PASS edge_(0, 5) budget=3
FAIL: edge_(17, 0) exact view key set
SCENARIO PASS edge_(17, 0) budget=3
FAIL: status_{ "mobility_up": 2 } exact view key set
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
FAIL: status_{ "movement_down": 2 } exact view key set
SCENARIO PASS status_{ "movement_down": 2 } budget=2
FAIL: zero_budget exact view key set
SCENARIO PASS zero_budget budget=0
FAIL: enclosed exact view key set
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] FAIL: 66148 checks, 16 failures; scenarios=15; visible_rays=540
```

### extra_field_validator

```text
Traceback (most recent call last):
  File "C:\Users\seong\.codex\.chatgpt-projects\g-p-6a0731363ec48191860bdb1bbc62ede5\B3D_F1_NegativeProbe\tools\validate_battle3d_contract.py", line 10, in <module>
    assert json.loads(match.group(1)) == EXPECTED_VIEW_FIELDS, 'VIEW_FIELDS exact size/order/elements mismatch'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: VIEW_FIELDS exact size/order/elements mismatch
```

### reordered_fields_movement_parity

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

FAIL: VIEW_FIELDS exact size/order/elements
SCENARIO PASS empty_infantry budget=3
SCENARIO PASS empty_cavalry budget=4
SCENARIO PASS empty_archer budget=3
SCENARIO PASS empty_gunner budget=2
SCENARIO PASS empty_mounted_archer budget=4
SCENARIO PASS blockers_false budget=3
SCENARIO PASS blockers_true budget=3
SCENARIO PASS edge_(0, 0) budget=3
SCENARIO PASS edge_(17, 9) budget=3
SCENARIO PASS edge_(0, 5) budget=3
SCENARIO PASS edge_(17, 0) budget=3
SCENARIO PASS status_{ "mobility_up": 2 } budget=4
SCENARIO PASS status_{ "movement_down": 2 } budget=2
SCENARIO PASS zero_budget budget=0
SCENARIO PASS enclosed budget=3
[BATTLE3D_PARITY] FAIL: 66148 checks, 1 failures; scenarios=15; visible_rays=540
```

### reordered_fields_validator

```text
Traceback (most recent call last):
  File "C:\Users\seong\.codex\.chatgpt-projects\g-p-6a0731363ec48191860bdb1bbc62ede5\B3D_F1_NegativeProbe\tools\validate_battle3d_contract.py", line 10, in <module>
    assert json.loads(match.group(1)) == EXPECTED_VIEW_FIELDS, 'VIEW_FIELDS exact size/order/elements mismatch'
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
AssertionError: VIEW_FIELDS exact size/order/elements mismatch
```

### flat_plane_oblique_click

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

FAIL: oblique yaw=0.32 zoom=24 cell=(1, 2) got=(1, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 2) got=(2, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 3) got=(2, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 2) got=(3, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 3) got=(3, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 1) got=(4, 0)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 2) got=(4, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 1) got=(5, 0)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 7) got=(13, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 8) got=(13, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 9) got=(13, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 7) got=(14, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 8) got=(14, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 9) got=(14, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 7) got=(15, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 8) got=(15, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 9) got=(15, 8)
[OBLIQUE_CAMERA] yaw=0.32 zoom=24 visible=139 passed=122 flat_different=17 outside=41 occluded=0
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 1) got=(0, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 1) got=(1, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 2) got=(1, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 1) got=(2, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 2) got=(2, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 3) got=(2, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 1) got=(3, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 2) got=(3, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 3) got=(3, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 1) got=(4, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 2) got=(4, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 1) got=(5, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 7) got=(13, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 8) got=(13, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 9) got=(13, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 7) got=(14, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 8) got=(14, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 9) got=(14, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 7) got=(15, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 8) got=(15, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 9) got=(15, 8)
[OBLIQUE_CAMERA] yaw=0.32 zoom=40 visible=180 passed=155 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 1) got=(0, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 1) got=(1, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 2) got=(1, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 1) got=(2, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 2) got=(2, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 3) got=(2, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 1) got=(3, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 2) got=(3, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 3) got=(3, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 0) got=(-1, -1)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 1) got=(4, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 2) got=(4, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 1) got=(5, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 7) got=(13, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 8) got=(13, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 9) got=(13, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 7) got=(14, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 8) got=(14, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 9) got=(14, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 7) got=(15, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 8) got=(15, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 9) got=(15, 8)
[OBLIQUE_CAMERA] yaw=0.32 zoom=60 visible=180 passed=155 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 1) got=(2, 0)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 2) got=(2, 1)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 3) got=(2, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 1) got=(3, 0)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 2) got=(3, 1)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 3) got=(3, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 1) got=(4, 0)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 2) got=(4, 1)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 1) got=(5, 0)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 7) got=(13, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 8) got=(13, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 9) got=(13, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 7) got=(14, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 8) got=(14, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 9) got=(14, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 7) got=(15, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 8) got=(15, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 9) got=(15, 8)
[OBLIQUE_CAMERA] yaw=0.00 zoom=24 visible=140 passed=119 flat_different=21 outside=40 occluded=0
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 1) got=(0, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 1) got=(1, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 2) got=(1, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 1) got=(2, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 2) got=(2, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 3) got=(2, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 1) got=(3, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 2) got=(3, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 3) got=(3, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 1) got=(4, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 2) got=(4, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 1) got=(5, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 7) got=(13, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 8) got=(13, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 9) got=(13, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 7) got=(14, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 8) got=(14, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 9) got=(14, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 7) got=(15, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 8) got=(15, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 9) got=(15, 8)
[OBLIQUE_CAMERA] yaw=0.00 zoom=40 visible=180 passed=155 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 1) got=(0, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 1) got=(1, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 2) got=(1, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 1) got=(2, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 2) got=(2, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 3) got=(2, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 1) got=(3, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 2) got=(3, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 3) got=(3, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 0) got=(-1, -1)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 1) got=(4, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 2) got=(4, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 1) got=(5, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 7) got=(13, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 8) got=(13, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 9) got=(13, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 7) got=(14, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 8) got=(14, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 9) got=(14, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 7) got=(15, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 8) got=(15, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 9) got=(15, 8)
[OBLIQUE_CAMERA] yaw=0.00 zoom=60 visible=180 passed=155 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 2) got=(3, 1)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 8) got=(12, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 7) got=(13, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 8) got=(13, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 7) got=(14, 6)
[OBLIQUE_CAMERA] yaw=0.80 zoom=24 visible=135 passed=130 flat_different=5 outside=45 occluded=0
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 0) got=(-1, -1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 1) got=(0, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 2) got=(0, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 1) got=(1, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 2) got=(1, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 1) got=(2, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 2) got=(2, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 1) got=(3, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 2) got=(3, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 8) got=(12, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 7) got=(13, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 8) got=(13, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 9) got=(13, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 7) got=(14, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 8) got=(14, 7)
[OBLIQUE_CAMERA] yaw=0.80 zoom=40 visible=180 passed=163 flat_different=17 outside=0 occluded=0
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 0) got=(-1, -1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 1) got=(0, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 2) got=(0, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 0) got=(-1, -1)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 1) got=(1, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 2) got=(1, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 0) got=(-1, -1)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 1) got=(2, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 2) got=(2, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 1) got=(3, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 2) got=(3, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 8) got=(12, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 7) got=(13, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 8) got=(13, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 9) got=(13, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 7) got=(14, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 8) got=(14, 7)
[OBLIQUE_CAMERA] yaw=0.80 zoom=60 visible=180 passed=163 flat_different=17 outside=0 occluded=0
[BATTLE3D_OBLIQUE] FAIL: 1522 checks, 177 failures; cameras=9; visible=1494; flat_different=177
```

### swapped_xz_oblique_click

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

FAIL: oblique yaw=0.32 zoom=24 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.32 zoom=24 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.32 zoom=24 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.32 zoom=24 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.32 zoom=24 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.32 zoom=24 cell=(17, 8) got=(8, 17)
[OBLIQUE_CAMERA] yaw=0.32 zoom=24 visible=139 passed=8 flat_different=17 outside=41 occluded=0
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 1) got=(1, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 2) got=(2, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 3) got=(3, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 4) got=(4, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 5) got=(5, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 7) got=(7, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 8) got=(8, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(0, 9) got=(9, 0)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 0) got=(0, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 8) got=(8, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(1, 9) got=(9, 1)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 0) got=(0, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 1) got=(1, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(16, 9) got=(9, 16)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 0) got=(0, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 1) got=(1, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 2) got=(2, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 4) got=(4, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 5) got=(5, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 6) got=(6, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 7) got=(7, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 8) got=(8, 17)
FAIL: oblique yaw=0.32 zoom=40 cell=(17, 9) got=(9, 17)
[OBLIQUE_CAMERA] yaw=0.32 zoom=40 visible=180 passed=10 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 1) got=(1, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 2) got=(2, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 3) got=(3, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 4) got=(4, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 5) got=(5, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 7) got=(7, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 8) got=(8, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(0, 9) got=(9, 0)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 0) got=(0, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 8) got=(8, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(1, 9) got=(9, 1)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 0) got=(0, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 1) got=(1, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(16, 9) got=(9, 16)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 0) got=(0, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 1) got=(1, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 2) got=(2, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 4) got=(4, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 5) got=(5, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 6) got=(6, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 7) got=(7, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 8) got=(8, 17)
FAIL: oblique yaw=0.32 zoom=60 cell=(17, 9) got=(9, 17)
[OBLIQUE_CAMERA] yaw=0.32 zoom=60 visible=180 passed=10 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.00 zoom=24 cell=(15, 9) got=(9, 15)
[OBLIQUE_CAMERA] yaw=0.00 zoom=24 visible=140 passed=8 flat_different=21 outside=40 occluded=0
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 1) got=(1, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 2) got=(2, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 3) got=(3, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 4) got=(4, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 5) got=(5, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 7) got=(7, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 8) got=(8, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(0, 9) got=(9, 0)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 0) got=(0, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 8) got=(8, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(1, 9) got=(9, 1)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 0) got=(0, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 1) got=(1, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(16, 9) got=(9, 16)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 0) got=(0, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 1) got=(1, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 2) got=(2, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 4) got=(4, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 5) got=(5, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 6) got=(6, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 7) got=(7, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 8) got=(8, 17)
FAIL: oblique yaw=0.00 zoom=40 cell=(17, 9) got=(9, 17)
[OBLIQUE_CAMERA] yaw=0.00 zoom=40 visible=180 passed=10 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 1) got=(1, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 2) got=(2, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 3) got=(3, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 4) got=(4, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 5) got=(5, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 7) got=(7, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 8) got=(8, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(0, 9) got=(9, 0)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 0) got=(0, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 8) got=(8, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(1, 9) got=(9, 1)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 0) got=(0, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 1) got=(1, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(16, 9) got=(9, 16)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 0) got=(0, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 1) got=(1, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 2) got=(2, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 4) got=(4, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 5) got=(5, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 6) got=(6, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 7) got=(7, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 8) got=(8, 17)
FAIL: oblique yaw=0.00 zoom=60 cell=(17, 9) got=(9, 17)
[OBLIQUE_CAMERA] yaw=0.00 zoom=60 visible=180 passed=10 flat_different=25 outside=0 occluded=0
FAIL: oblique yaw=0.80 zoom=24 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.80 zoom=24 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.80 zoom=24 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.80 zoom=24 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.80 zoom=24 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.80 zoom=24 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.80 zoom=24 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.80 zoom=24 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.80 zoom=24 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.80 zoom=24 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.80 zoom=24 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.80 zoom=24 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.80 zoom=24 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.80 zoom=24 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.80 zoom=24 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.80 zoom=24 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.80 zoom=24 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.80 zoom=24 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.80 zoom=24 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.80 zoom=24 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.80 zoom=24 cell=(17, 4) got=(4, 17)
[OBLIQUE_CAMERA] yaw=0.80 zoom=24 visible=135 passed=7 flat_different=5 outside=45 occluded=0
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 1) got=(1, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 2) got=(2, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 3) got=(3, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 4) got=(4, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 5) got=(5, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 7) got=(7, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 8) got=(8, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(0, 9) got=(9, 0)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 0) got=(0, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 8) got=(8, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(1, 9) got=(9, 1)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 0) got=(0, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 1) got=(1, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(16, 9) got=(9, 16)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 0) got=(0, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 1) got=(1, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 2) got=(2, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 4) got=(4, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 5) got=(5, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 6) got=(6, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 7) got=(7, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 8) got=(8, 17)
FAIL: oblique yaw=0.80 zoom=40 cell=(17, 9) got=(9, 17)
[OBLIQUE_CAMERA] yaw=0.80 zoom=40 visible=180 passed=10 flat_different=17 outside=0 occluded=0
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 1) got=(1, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 2) got=(2, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 3) got=(3, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 4) got=(4, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 5) got=(5, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 6) got=(6, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 7) got=(7, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 8) got=(8, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(0, 9) got=(9, 0)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 0) got=(0, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 2) got=(2, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 3) got=(3, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 4) got=(4, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 5) got=(5, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 6) got=(6, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 7) got=(7, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 8) got=(8, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(1, 9) got=(9, 1)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 0) got=(0, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 1) got=(1, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 3) got=(3, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 4) got=(4, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 5) got=(5, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 6) got=(6, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 7) got=(7, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 8) got=(8, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(2, 9) got=(9, 2)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 0) got=(0, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 1) got=(1, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 2) got=(2, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 4) got=(4, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 5) got=(5, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 6) got=(6, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 7) got=(7, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 8) got=(8, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(3, 9) got=(9, 3)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 0) got=(0, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 1) got=(1, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 2) got=(2, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 3) got=(3, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 5) got=(5, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 6) got=(6, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 7) got=(7, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 8) got=(8, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(4, 9) got=(9, 4)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 0) got=(0, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 1) got=(1, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 2) got=(2, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 3) got=(3, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 4) got=(4, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 6) got=(6, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 7) got=(7, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 8) got=(8, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(5, 9) got=(9, 5)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 0) got=(0, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 1) got=(1, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 2) got=(2, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 3) got=(3, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 4) got=(4, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 5) got=(5, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 7) got=(7, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 8) got=(8, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(6, 9) got=(9, 6)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 0) got=(0, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 1) got=(1, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 2) got=(2, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 3) got=(3, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 4) got=(4, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 5) got=(5, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 6) got=(6, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 8) got=(8, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(7, 9) got=(9, 7)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 0) got=(0, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 1) got=(1, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 2) got=(2, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 3) got=(3, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 4) got=(4, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 5) got=(5, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 6) got=(6, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 7) got=(7, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(8, 9) got=(9, 8)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 0) got=(0, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 1) got=(1, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 2) got=(2, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 3) got=(3, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 4) got=(4, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 5) got=(5, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 6) got=(6, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 7) got=(7, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(9, 8) got=(8, 9)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 0) got=(0, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 1) got=(1, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 2) got=(2, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 3) got=(3, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 4) got=(4, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 5) got=(5, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 6) got=(6, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 7) got=(7, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 8) got=(8, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(10, 9) got=(9, 10)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 0) got=(0, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 1) got=(1, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 2) got=(2, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 3) got=(3, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 4) got=(4, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 5) got=(5, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 6) got=(6, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 7) got=(7, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 8) got=(8, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(11, 9) got=(9, 11)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 0) got=(0, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 1) got=(1, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 2) got=(2, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 3) got=(3, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 4) got=(4, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 5) got=(5, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 6) got=(6, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 7) got=(7, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 8) got=(8, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(12, 9) got=(9, 12)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 0) got=(0, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 1) got=(1, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 2) got=(2, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 3) got=(3, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 4) got=(4, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 5) got=(5, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 6) got=(6, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 7) got=(7, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 8) got=(8, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(13, 9) got=(9, 13)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 0) got=(0, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 1) got=(1, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 2) got=(2, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 3) got=(3, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 4) got=(4, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 5) got=(5, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 6) got=(6, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 7) got=(7, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 8) got=(8, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(14, 9) got=(9, 14)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 0) got=(0, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 1) got=(1, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 2) got=(2, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 3) got=(3, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 4) got=(4, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 5) got=(5, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 6) got=(6, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 7) got=(7, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 8) got=(8, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(15, 9) got=(9, 15)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 0) got=(0, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 1) got=(1, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 2) got=(2, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 3) got=(3, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 4) got=(4, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 5) got=(5, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 6) got=(6, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 7) got=(7, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 8) got=(8, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(16, 9) got=(9, 16)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 0) got=(0, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 1) got=(1, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 2) got=(2, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 3) got=(3, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 4) got=(4, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 5) got=(5, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 6) got=(6, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 7) got=(7, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 8) got=(8, 17)
FAIL: oblique yaw=0.80 zoom=60 cell=(17, 9) got=(9, 17)
[OBLIQUE_CAMERA] yaw=0.80 zoom=60 visible=180 passed=10 flat_different=17 outside=0 occluded=0
[BATTLE3D_OBLIQUE] FAIL: 1522 checks, 1411 failures; cameras=9; visible=1494; flat_different=177
```

### restored_oblique_click

```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[OBLIQUE_CAMERA] yaw=0.32 zoom=24 visible=139 passed=139 flat_different=17 outside=41 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.32 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=24 visible=140 passed=140 flat_different=21 outside=40 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=40 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.00 zoom=60 visible=180 passed=180 flat_different=25 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=24 visible=135 passed=135 flat_different=5 outside=45 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=40 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[OBLIQUE_CAMERA] yaw=0.80 zoom=60 visible=180 passed=180 flat_different=17 outside=0 occluded=0
[BATTLE3D_OBLIQUE] PASS: 1522 checks, 0 failures; cameras=9; visible=1494; flat_different=177
```

## 기준 대비 경로 변경 원문

커밋 예정 tree 기준이며 최종 커밋과 동일한 경로 목록:

```text
M	.github/workflows/verify-c-track.yml
A	agent/BATTLE3D_F1_RESULT_20261019.md
M	tests/scripts/test_battle3d_movement_parity.gd
A	tests/scripts/test_battle3d_oblique_click.gd
A	tests/scripts/test_battle3d_oblique_click.gd.uid
M	tools/validate_battle3d_contract.py
```
