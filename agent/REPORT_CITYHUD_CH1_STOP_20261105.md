기준 화면: 없음(보이는 화면 변화 0). 성 안 건물 그림 90장 반입 + 로드 헬퍼(CH-1). 작업 가지 `feature/wm3d-cityhud-20261105`(시작점 `9160baf`), 정본 가지 push 없음.
합격 기준: 지시서 `agent/ORDER_CITYHUD_CH1_ASSETS_20261105.md` 맨 위 ①~④. 이 보고서는 **멈춤 보고**다(지시서 1절 4번 멈춤 조건).

# 멈춤 보고 — CITYHUD CH-1

## 진행 기록 (정본 `PROGRESS_WM3D.md` 대신 여기에 쓴다, 큐 9절)
- 2026-11-05 — 큐 7번 시작 → 지시서 1절 4번 조건으로 **멈춤**. 코드 커밋 없음. 이 보고서만 `[skip ci]`로 이 가지에 올린다.
- 큐 6번(M7-0)은 완료: 가지 `feature/wm3d-m7prep-20261105`, 코드 `add66d5`, 보고서 `62abaad`(`agent/REPORT_M7_0_20261105.md`).
- 다음 할 일: 큐 5절 대기 — `origin/feature/wm3d-orders-20261105`에 답신(`agent/ORDER_CITYHUD_CH1_REPLY_<번호>.md` 등)이 오면 그대로 이어간다.
- 멈춘 이유: Godot import가 `.import` 90개 **외에** `city_buildings_manifest.csv.import` 1개를 만들었다(아래 1절).

## 1. 멈춘 이유 [사실]
- 지시서 1절 4번: "생성된 `.import` 90개 외에 **다른 파일이 바뀌면** … 멈추고 보고". 4절 목록에도 `city_buildings_manifest.csv`의 `.import`는 없다.
- `godot --headless --editor --path . --import`(Godot 4.6.2, CI와 같은 명령) 결과, 새 파일은 PNG 90 + `bld_*.png.import` 90 + `city_buildings_manifest.csv` + **`city_buildings_manifest.csv.import`** + 헬퍼·테스트와 각 `.uid`. 기존 파일 변경은 0(기존 `.import`·`project.godot` 그대로).
- 원인: Godot는 `.csv`를 기본으로 **번역 파일**로 import한다. 생성된 `.import` 원문 일부:
  ```
  importer="csv_translation"
  type="Translation"
  dest_files=["res://assets/worldmap/city_buildings/city_buildings_manifest.kind.translation", … 7개 …]
  ```
  이때 소스 폴더에 `city_buildings_manifest.{kind,group,name,region,size,bytes,md5}.translation` 7개가 생긴다(`.gitignore`의 `*.translation`이라 git에는 안 보임).
- 이 `.csv.import`를 커밋하지 않으면 CI의 import 단계가 같은 파일을 만들어 `verify-worldmap3d.yml`의 `Diff check`(`test -z "$(git status --short)"`)와 C-track의 트리 검사가 빨개진다[추정]. 커밋하려면 4절 목록 밖이다. 그래서 어느 쪽도 지시서 안에서는 할 수 없다.
- 레포의 다른 CSV는 `agent/`(`agent/.gdignore`가 있어 Godot가 무시)에만 있어 이 문제가 없었다.

## 2. 멈추기 전까지 한 것 (모두 지시서 범위 안, 커밋 안 함)
| # | 항목 | 결과(원문/수치) |
|---|---|---|
| 1 | 복사 전 원본 검증 (`Desktop\EASTWAR_CityBuildings_Plan_20261102\phase2_buildings\manifest.csv` `kind=game` 90행) | 90/90 md5·바이트·크기(PNG 헤더) 일치, 90/90 RGBA(color type 6), 합계 2,626,681 B. 관청 3행의 `file`은 `anchors/bld_life_office_*.png`지만 `anchors/` 폴더는 없고 파일은 폴더 맨 위(지시서·감사와 같음) → 파일명으로 대조 |
| 2 | 복사 후 레포 안 검증 | `repo pngs 90 md5 ok 90 of 90` |
| 3 | `city_buildings_manifest.csv` | 원본 열 이름 그대로(`file,kind,group,name_ko,region,size_px,bytes,md5`), game 90행 + 머리줄 = 91줄. 행 값도 원본 그대로(관청 3행의 `anchors/` 표기 유지 — 테스트는 파일명 부분만 쓴다). BOM 없이 UTF-8 |
| 4 | 새 테스트, 헬퍼 없을 때 | `ERROR: [CITY_BUILDING_ASSETS_FAIL] helper script exists` / `[CITY_BUILDING_ASSETS] checks=1 failures=["helper script exists"]`, 종료 1 |
| 5 | 새 테스트, 헬퍼 + import 뒤 | `[CITY_BUILDING_ASSETS] checks=481 failures=[]`, 종료 0, 오류 줄 0 |
| 6 | VRAM 대략(압축 전 가로×세로×4 합계) | 8,306,688 B ≈ 7.9 MiB (90장 전부). 한 지역 30장은 약 1/3 |

헬퍼(`scripts/worldmap/ui/worldmap_city_building_assets.gd`)는 지시서 2절의 다섯 함수 그대로다. 택한 해석 1개: 실제 도시 데이터의 `region_key`는 `"region.korean_peninsula"`처럼 **`region.` 접두사가 붙어 있다**(`worldmap_main.gd:598-610`, 값 4종 `region.korean_peninsula`·`region.china_mainland`·`region.japanese_archipelago`·`region.northern_steppe`). 그래서 `region_style_for_region_key`는 접두사가 있든 없든 받는다(`trim_prefix("region.")`). 표 자체는 지시서의 4개 그대로다.

보관 [사실]: 위 작업은 지우지 않고 `git stash`에 넣었다 — `stash@{0}: On feature/wm3d-cityhud-20261105: CH-1 work (90 PNG + 90 .import + manifest + helper + test), stopped on csv.import`. 답신이 오면 `git stash pop`으로 그대로 이어간다. 생성된 `*.translation` 7개는 git이 무시하는 생성물이라 폴더에 남아 있다(삭제하지 않음).

## 3. 고치는 안 (클코치·김작 결정)
| 안 | 내용 | 바뀌는 것 | 비고 |
|---|---|---|---|
| **A (추천)** | `city_buildings_manifest.csv.import`를 `importer="keep"`(Godot 4의 "Keep File (exported as is)")으로 커밋 | 4절 목록에 `.csv.import` 1개 추가 | 파일명·열 이름 지시서 그대로. 번역 파일 생성 없음. `FileAccess`로 그대로 읽힌다[추정 — 적용 후 로컬·CI로 확인 필요] |
| B | 매니페스트 확장자를 Godot가 import하지 않는 것으로(예: `city_buildings_manifest.txt`) | 파일명 1개 변경 | `.import` 추가 0. CSV 내용·열 이름은 그대로 |
| C | 레포 안 매니페스트를 빼고, 크기 기대값을 테스트 코드 상수로 | 목록 3번 삭제 | 원본과의 대조 근거가 레포에 남지 않음 |

## 4. 그 밖에 확인한 것
- 원격 정본 가지는 `9160baf`가 아니라 그 위 `ab9b739`(감사 보고서 2커밋, 문서만)다. 지시서가 이 감사 보고서를 근거로 인용하므로 지시서가 정한 시작점 `9160baf`에서 가지를 만들었다(6번과 같은 해석).
- `WORLDMAP_RULES.md:230`(v0.70-79 절)의 `.import` 잠금은 "modify, move, delete, regenerate, or reimport … any `.import` file"로, 해당 절의 작업 단위(pass) 잠금이다. 새 `.import` 생성은 김작 Q2 허가로 진행 가능하다고 읽었다. 이 문구 때문에 멈춘 것은 아니다.
- 새 테스트를 워크플로가 자동으로 도는지 [사실]: `verify-worldmap3d.yml`은 `test_worldmap3d_*.gd`만 돌리고 `paths` 필터에도 `assets/`·`scripts/worldmap/ui/`가 없다. C-track에서 이 테스트가 도는지는 커밋 후 확인할 예정이었다(미확인).

## 5. 종료 루틴
1. 정본 `C:\dev\SamWar_BattleLab_cc`, 가지 `feature/wm3d-cityhud-20261105`, HEAD = `9160baf` + 이 보고서 커밋. 작업 트리는 stash 후 깨끗(무시되는 `*.translation` 7개만 남음).
2. 새로 만든 것: 가지 `feature/wm3d-cityhud-20261105`, 이 보고서, stash 1개.
3. push한 것: 이 보고서 커밋(`[skip ci]`)만 — `feature/wm3d-cityhud-20261105`, force 없음. 정본 가지 push 없음.
4. CI: 코드 커밋 없음(보고서 `[skip ci]`).
5. 김작·클코치가 정할 것: 3절 A/B/C 중 하나(추천 A). 답신이 오면 stash를 되살려 이어서 검증·커밋·CI까지 간다.
