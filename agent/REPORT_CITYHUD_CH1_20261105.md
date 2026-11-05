기준 화면: 없음(보이는 화면 변화 0). 성 안 건물 그림 90장 반입 + 로드 헬퍼(CH-1), 어느 화면에도 아직 연결하지 않음. 작업 가지 `feature/wm3d-cityhud-20261105`(시작점 `9160baf`), 정본 가지 push 없음.
합격 기준: 지시서 `agent/ORDER_CITYHUD_CH1_ASSETS_20261105.md` 맨 위 ①~④ + 답신 `agent/ORDER_CITYHUD_CH1_REPLY_1_20261105.md`(B안, 목록 밖 파일이 생기지 않음).

# 보고서 — CITYHUD CH-1 (멈춤 → 답신 1 B안으로 해결)

## 진행 기록 (정본 `PROGRESS_WM3D.md` 대신 여기에 쓴다, 큐 9절)
- 2026-11-05 — 큐 7번 시작 → `city_buildings_manifest.csv.import` 생성으로 멈춤(멈춤 보고서 `07fd05a`, `agent/REPORT_CITYHUD_CH1_STOP_20261105.md`, 지우지 않음).
- 2026-11-05 — 답신 1(B안: 매니페스트를 `.txt`로) 수신 → stash 복원 → 이름 변경·재import·검증 → 코드 커밋 `e391737` push → C-track success.
- 마지막 코드 커밋: `e391737` / 이 보고서: `agent/REPORT_CITYHUD_CH1_20261105.md` / CI: `Verify C-track refactor` run `42009149755` success, `Verify WorldMap3D` 실행 안 됨(경로 조건).
- 다음 할 일: 큐 8번(`ORDER_M7_0B_LIFECYCLE_TEST_20261105.md`)은 김작 지시를 받고 시작(이번 지시 범위는 6~7번).

## 1. 경위 [사실]
- 멈춘 이유: Godot 4.6.2는 `.csv`를 번역 파일로 import해 `city_buildings_manifest.csv.import`(목록 밖)와 무시되는 `*.translation` 7개를 만들었다.
- 답신 1 결정: B안 — 파일명을 `city_buildings_manifest.txt`로, 내용(CSV 텍스트, 열 이름·game 90행)은 그대로.
- 한 일:
  1. `git stash pop` — 충돌 없음(stash `4416600` 소비).
  2. `city_buildings_manifest.csv` → `city_buildings_manifest.txt` 이름 변경. 멈춤 때 생긴 `city_buildings_manifest.csv.import`와 `city_buildings_manifest.*.translation` 7개는 추적되지 않는 생성물이고 원본 csv가 없어져 쓸모가 없으므로 지웠다(git 대상 아님).
  3. 테스트의 `MANIFEST_PATH`를 `.txt`로. 읽기는 원래부터 `FileAccess.open` + `get_csv_line`(리소스 로드 아님).
  4. 답신의 "접두사 있음/없음 같은 결과" 검사를 하나 더했다(4개 지역 키에 대해 bare와 `region.`+key의 결과가 같은지 한 검사).

## 2. 확인 의무 — `.txt`에 대한 `.import`가 생기지 않는가 [사실]
`godot --headless --editor --path . --import` 다시 실행(종료 0) 뒤 폴더:
```
city_buildings_manifest.txt
png=90 import=90 other_import=0
```
`git status --short --untracked-files=all` (bld_* 제외) 원문:
```
?? assets/worldmap/city_buildings/city_buildings_manifest.txt
?? scripts/worldmap/ui/worldmap_city_building_assets.gd
?? scripts/worldmap/ui/worldmap_city_building_assets.gd.uid
?? tests/scripts/test_worldmap_city_building_assets.gd
?? tests/scripts/test_worldmap_city_building_assets.gd.uid
```
무시 파일(`!!`)도 이 폴더에 0개. → B안 성공, C안으로 바꾸지 않았다.

## 3. 로컬 검증 (결과 줄 원문)
| # | 항목 | 결과 |
|---|---|---|
| 1 | 원본 대조(멈춤 전) | 90/90 md5·바이트·크기·RGBA 일치, 합계 2,626,681 B |
| 2 | 레포 안 PNG ↔ `.txt` 매니페스트 md5(stash 복원 뒤 재확인) | `rows 90 md5 ok 90 bom False` |
| 3 | 새 테스트, 헬퍼 없을 때(멈춤 전) | `[CITY_BUILDING_ASSETS] checks=1 failures=["helper script exists"]`, 종료 1 |
| 4 | 새 테스트, 최종 | `[CITY_BUILDING_ASSETS] checks=482 failures=[]`, 종료 0 |
| 5 | 정적 검증기 | `validators=72 pass=72 fail=0` |
| 6 | 3D 테스트 8종 | adapter 56 / camera_controller 61 / camera_external_input 20 / color_parity 57 / host 58 / mem_probe 37 / production 28 / roads 121 — 모두 실패 0, 종료 0(이전과 같음) |
| 7 | 장면 로드 `--quit-after 5` | `WorldMap.tscn exit=0 errors=0`, `WorldMap3D_Host_Test.tscn exit=0 errors=0` |
| 8 | `git diff --cached --check` | 출력 없음 |
| 9 | VRAM 대략(압축 전 가로×세로×4) | 8,306,688 B ≈ 7.9 MiB(90장), 한 지역 30장은 약 1/3 |

검사 482개가 센 것: 헬퍼 존재 1 + 매니페스트 90행 1 + 키 30개 1 + 키 그룹 1 + (90장 × 경로·존재·로드·크기·알파 등) + 90장 로드 합계 1 + 모르는 입력 5종 × 3 = 15 + 지역 표 11 + 접두사 동등 1. 멈춤 전 481에서 접두사 동등 검사 1개가 늘었다.

## 4. CI [사실]
| workflow | run | 결과 |
|---|---|---|
| Verify C-track refactor | `42009149755` (커밋 `e391737`) | success — shard 0 `127183414197`, shard 1 `127183414399`, shard 2 `127183413711`, shard 3 `127183414136` |
| Verify WorldMap3D | — | **실행 안 됨**: `paths` 필터에 `assets/`·`scripts/worldmap/ui/`·`tests/scripts/test_worldmap_city_*`가 없다. 같은 3D 테스트 8종을 로컬로 돌린 결과는 3절 6번 |

- 새 테스트는 CI에서 돌지 않는다[사실]: `verify-c-track.yml`의 테스트 목록은 파일명을 하나씩 적은 고정 목록이고(`:167-169` 근처 `test_worldmap_city_*_extraction.gd` 등) 이 테스트가 없다. `verify-worldmap3d.yml`은 `test_worldmap3d_*.gd`만 돈다. 워크플로 수정은 지시서 목록 밖이라 하지 않았다 → 김작·클코치 결정 거리(아래 6절).

## 5. 바뀐 파일 (지시서 4절 + 답신 1 대체 경로 안)
- `assets/worldmap/city_buildings/bld_*.png` 90 + `bld_*.png.import` 90
- `assets/worldmap/city_buildings/city_buildings_manifest.txt` (답신 1이 4절 3번을 대체)
- `scripts/worldmap/ui/worldmap_city_building_assets.gd` + `.uid`
- `tests/scripts/test_worldmap_city_building_assets.gd` + `.uid`
- 합계 185 파일, +3857 줄. 기존 파일 변경 0. `worldmap_main.gd`·`WorldMap.tscn`·`worldmap3d/`·`lab_presentation.gd` 손대지 않음.

## 6. 김작·클코치가 정할 것
1. 새 테스트를 CI에 넣을지(`verify-c-track.yml` 목록에 한 줄 추가) — 다음 지시서에서.
2. 큐 8번(M7-0b) 시작 지시.

## 7. 종료 루틴
1. 정본 `C:\dev\SamWar_BattleLab_cc`, 가지 `feature/wm3d-cityhud-20261105`, HEAD = `e391737` + 이 보고서 커밋. 작업 트리 깨끗. stash 없음.
2. push: `feature/wm3d-cityhud-20261105`만(`07fd05a..e391737`, 이 보고서), force 없음. 정본 가지 `feature/wm3d-intake-20261101`은 원격 `ab9b739` 그대로.
3. `gh`는 읽기만(`run list`/`run watch`/`run view`).
