기준 화면: `feature/wm3d-warnfix-20261108`(`main` `a9e3b84` 기준)에서 Errors 탭 경고 12개→0, 그리고 `feature/wm3d-debugcheats-20261108`에서 치트 컨트롤러 경고 2개→0. 둘이 합쳐진 상태에서 F6 하면 0개. 동작 불변.
합격 기준: 31번 지시서 6절 전부 + 30번 가지 수정 후 30번 테스트(61/0)·C-track 초록.

# REPORT_WARNFIX — Godot 경고 정리 (큐 31번, 답신 1 A안) (클코드, 2026-11-08)

## 요약
- `main` 기준 경고 12개를 **0개**로 만들었습니다. 그림자 3개는 지역 이름만 바꿨고, 정수 나눗셈 9개는 그 문장에만 `@warning_ignore("integer_division")`와 이유 주석을 달았습니다. `/` 의미 변경 0, 동작 변화 0입니다.
- 30번 가지의 치트 컨트롤러 경고 2개는 답신 1 §2대로 **30번 가지에서 먼저** 고쳤습니다(`c2c6740`, CI 초록, 30번 보고서 덧붙임 `3e391b1`). 두 가지가 `main`에 합쳐지면 F6에서 0개입니다.
- 로컬 전체 검사 216개와 검증기 72개가 모두 통과했습니다. 금지 파일 변경은 0입니다. CI는 5절에 있습니다.

- 가지: `feature/wm3d-warnfix-20261108`. 시작 `origin/main` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d`. STOP 보고서 `1738d41` 위에 코드 커밋 `645ffcf5b9a7ed8aa0954428abce9c3ed5d551c1`.

## 1. 재현 방법과 개수
- 디버거 Errors 탭 경고는 실행 중인 게임이 원격 디버거로만 보낸다. 그래서 에디터 디버거 대신 수신기(임시 프로젝트, `TCPServer` + `bytes_to_var`)를 띄우고 `--remote-debug tcp://127.0.0.1:<port> --resolution 1920x1080 --quit-after 900 res://WorldMap.tscn`(창 모드)으로 돌렸다.
- 수신기 원문: `agent/evidence/warnfix_20261108/debugger_listener.gd.txt`. 매번 `CONNECTED` 줄로 연결을 확인했다.

| 가지 / 커밋 | 경고 수 | 원문 |
|---|---|---|
| 31번 시작 `a9e3b84` | 12 | `listen_before_win_warnings.txt` |
| 30번 `355688c`(김작 F6 화면과 같은 상태) | 14 | `listen_debugcheats_warnings.txt` |
| 30번 `c2c6740`(이름 2개 수정 뒤) | 12(컨트롤러 0) | `listen_debugcheats_after_rename_warnings.txt` |
| **31번 `645ffcf`(이번 수정 뒤)** | **0** | `listen_after_warnfix_warnings.txt`(0줄) |

- 전→후: **12 → 0**(31번 가지). 금지 파일 때문에 남은 경고 0, 새로 생긴 경고 0.

## 2. 조치 표 (파일:줄은 수정 전 `a9e3b84` 기준)
| # | 파일:줄 | 종류 | 조치 |
|---|---|---|---|
| 1 | `scripts/worldmap/worldmap_turn_compass.gd:147` | 그림자 `texture`(TextureRect) | 지역 변수 → `frame_texture`(147·148행, static 함수라 `self.texture` 의도 없음) |
| 2·3 | `scripts/worldmap/worldmap_turn_compass.gd:159` | 정수 나눗셈 ×2(`w / 2`, `h / 2`) | 문장 위 `# 의도된 버림: 채우기 시작 픽셀(그림 가운데, 정수 좌표)` + `@warning_ignore("integer_division")` |
| 4 | `worldmap3d/scripts/worldmap_geo.gd:196` | 정수 나눗셈 | `# 의도된 버림: 삼각형 수 = 인덱스 수 / 3(항상 나누어떨어짐)` + 주석 1줄 |
| 5 | `worldmap3d/scripts/worldmap_geo.gd:219` | 정수 나눗셈 | 같음 |
| 6 | `worldmap3d/scripts/worldmap_region_labels.gd:75` | 정수 나눗셈 | `# 의도된 버림: 샘플 간격(정수 픽셀)` + 주석 1줄 |
| 7 | `worldmap3d/scripts/worldmap_region_labels.gd:97` | 그림자 `basis`(Node3D) | 지역 변수 → `label_basis`(97·110행). 91행 `cam.global_transform.basis`는 속성 접근이라 그대로 |
| 8~11 | `worldmap3d/scripts/worldmap3d_root.gd:208·326·346·370` | 정수 나눗셈 | 삼각형 수 주석 + 주석 1줄(각 문장) |
| 12 | `worldmap3d/scripts/worldmap3d_root.gd:566` | 그림자 매개변수 `name`(Node) | → `preset_name`(566·567행). 호출처 `worldmap3d_root.gd:113`·`tools/acceptance_tests.gd:387`은 위치 인자라 변경 없음 |

- **금지 파일에 있는 경고**: 0개.
- **버그 의심**: 0개. 9개 모두 정수 결과가 맞는 계산이다(STOP 보고서 2-1절).
- **택한 해석**: 주석은 `@warning_ignore` **위**에 둔다. 주석 → 주석 1줄 → 문장 순서로, 지시서 "같은 줄 바로 위에 `@warning_ignore` + 한 줄 주석"을 따른다. 파일 전체 무시·설정 변경은 쓰지 않았다.
- diff 원문(`git diff a9e3b84 645ffcf -- scripts worldmap3d`): 4개 파일, +22 −6, 경고 줄 주변만. 서식 정리 0.

## 3. 금지 파일·범위
- `git diff a9e3b84 -- scripts/worldmap/worldmap_main.gd scripts/worldmap/military/battle_settlement_applier.gd tools/p1_exact_delta.py project.godot`: **0줄**.
- 변경 파일 4개는 모두 STOP 보고서 2-1 표의 파일이다. 새 파일·새 폴더·새 `.uid` 0. 30번 파일(`spy_presentation_helper.gd`·`WorldMap.tscn`·치트 컨트롤러)은 이 가지에서 건드리지 않았다.

## 4. 자동 기준 결과 (지시서 6절) (로컬, Godot 4.6.2 headless, 테스트마다 임시 `APPDATA`, 3개 병렬)
- 검증기 72개(C-track 목록) **전부 PASS**(`agent/evidence/warnfix_20261108/full_validators.txt`). 이번 변경은 `.tscn`·`/ui/`를 건드리지 않아 trade phase2 검증기도 커밋 전부터 PASS였다. 원문:
  - `tools/validate_worldmap_main_integrity.py rc=0 :: PASS: WorldMap main integrity guard (14108 main lines, 15608 orchestration lines, 1083 main functions, all sentinels present).`
  - `tools/validate_worldmap_diplomacy_routing.py rc=0 :: PASS: diplomacy routing guard + exact C-1/C-2/C-3/M-5/M-FINAL-A/M-FINAL-B + WorldMap warning-cleanup checkpoint bridge; historical T-4 guard preserved`
- Godot 테스트: 이 가지의 C-track 목록 208개 + `test_worldmap3d_*.gd` 8개 = **216개 전부 rc=0**(`full_tests.txt`). 지시서가 짚은 것:
  - `test_worldmap_turn_button_daynight` `[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]` / `test_worldmap_turn_compass_seam` `[TURN_SEAM] checks=18 failures=[]`
  - `test_worldmap3d_host` `PASS: 58 checks, 0 failures` / `test_worldmap3d_production` `checks=28 failures=[]` / `test_worldmap3d_roads` `checks=121 failures=[]` / `adapter` 56/0 / `camera_controller` 61/0 / `camera_external_input` 20/0 / `color_parity` 57/0 / `mem_probe` 37/0
  - [사실] 실행 목록을 30번 가지의 CI 파일에서 뽑아서 `test_worldmap_debug_cheats.gd`가 한 줄 끼어 "File not found"가 났다. 이 가지에는 그 파일이 없고 CI 목록에도 없으므로(이 가지 목록 208개) 수에서 뺐다.
- 기존 테스트·검증기 파일 변경 0. `git diff --check a9e3b84 645ffcf` 출력 없음.

## 5. CI (코드 커밋 `645ffcf`)
- `Verify C-track refactor` run `42488036136`: **success** — shard 0 `128754104361`, 1 `128754104292`, 2 `128754104199`, 3 `128754104003`. 실패 단계 0(Diff check 포함). 로그 원문: `[TURN_BUTTON_DAYNIGHT] checks=43 failures=[]`, `[TURN_SEAM] checks=18 failures=[]`.
- `Verify WorldMap3D` run `42488036103`: **success**, 작업 `128754104204`도 success(Diff check 포함 실패 단계 0). 로그 원문: `[WORLDMAP3D_HOST] PASS: 58 checks, 0 failures`, `[WM3D_PRODUCTION] checks=28 failures=[]`, `[WM3D_ROADS] checks=121 failures=[]`.
- 재실행 없음. `[CUTIN]` 관련 실패 줄 없음.

## 6. 김작 F6 체크리스트 (지시서 7절 그대로)
1. Godot에서 프로젝트를 열고 `WorldMap.tscn` F6 → 하단 디버거 **Errors 탭이 0개**(또는 지시서가 적은 남은 개수와 같음).
2. 턴 나침반(턴 종료 버튼) 모양·하늘 원이 전과 같음.
3. 3D 월드맵의 지역 이름 라벨 위치·방향이 전과 같음, 채움 프리셋 바꾸기가 전과 같이 동작.
- 참고: 이 가지(31번)에서 F6를 누르면 0개, 30번 가지에서 누르면 12개(이 가지의 수정이 아직 없음)다. 둘 다 `main`에 들어간 뒤 0개가 최종 확인이다(답신 1 §4).

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 끝낼 때 답신 1 §3대로 **30번 가지 `feature/wm3d-debugcheats-20261108`로 체크아웃**해 둔다. `git status` 깨끗.
2. 새로 생긴 것: 가지 `feature/wm3d-warnfix-20261108`(STOP 때 생성), 증거 폴더 `agent/evidence/warnfix_20261108/`. worktree·태그 0, 삭제 예정 0. 디버거 수신기는 저장소 밖 임시 폴더에만 있다.
3. 푸시:
   - 31번 가지: `1738d41`(STOP) → `645ffcf`(코드) → 이 보고서(`[skip ci]`).
   - 30번 가지: `c2c6740`(코드) → `3e391b1`(보고서 덧붙임). `main` 푸시 없음.
4. CI: 5절. 30번 `c2c6740`은 C-track run `42484972498` 4 shard success.
5. 김작이 결정할 것: F6 체크리스트(30번 8절, 31번 8절) 합격/불합격, 30·31번 `main` 합류 여부와 순서.
