기준 화면: 새 가지 `feature/wm3d-warnfix-20261108`(시작: `origin/main` `a9e3b84229f63286bbdc784d78826b0e2cdb792d`)에서 Godot 4.6.2로 프로젝트를 열고 F6로 `WorldMap.tscn`을 돌린 뒤, 하단 디버거 **Errors 탭의 경고 14개(그림자 5 + 정수 나눗셈 9)가 0개**가 된다. 게임 동작·화면은 그대로.
합격 기준: 6절 자동 기준 전부 + **동작 변화 0**(기존 테스트·검증기 변경 없이 통과) + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(7절). **이번에는 코드 변경 0으로 멈춘다.**

# REPORT_WARNFIX_STOP — `main`에서는 경고가 12개다. 나머지 2개는 30번 컨트롤러에 있다 (클코드, 2026-11-08, 큐 31번)

- **됐나**: 안 됐다. 코드 커밋 0, 이 보고서와 증거만 올렸다.
- **가지**: `feature/wm3d-warnfix-20261108` = `origin/main` `a9e3b84` + 이 보고서 커밋 1개(`[skip ci]`). `main` 푸시 없음.
- **막힌 것**: 지시서 1절 "재현이 안 되면(14개와 다르면) 실제 개수와 이유를 적고 멈춘다".
  - 시작점 `a9e3b84`에서는 경고가 **12개**다.
  - 김작 화면의 14개는 큐 30번 가지 `feature/wm3d-debugcheats-20261108`(`355688c`)에서 **정확히** 재현된다.
  - 차이 2개는 30번에서 클코드가 새로 만든 `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd`에서 나온다. 이 파일은 지시서 첫머리가 "건드리지 않는다"고 정했고, 31번 가지(`main` 시작)에는 아예 없다.
  - [추정] 김작이 20:59에 F6를 눌렀을 때 정본 작업 폴더가 30번 가지로 체크아웃돼 있었다(30번 종료 시 그 가지로 체크아웃해 두라는 규칙대로).

## 1. 재현 방법 [사실]
- 디버거 Errors 탭의 경고는 실행 중인 게임이 **원격 디버거로만** 보낸다(헤드리스 로그에는 0줄). 그래서 에디터 디버거를 대신하는 작은 수신기(임시 프로젝트의 `TCPServer` + `bytes_to_var`, 원문 `agent/evidence/warnfix_20261108/debugger_listener.gd.txt`)를 띄웠다.
- 실행 명령: `Godot_v4.6.2-stable_win64_console.exe --path . --remote-debug tcp://127.0.0.1:<port> --resolution 1920x1080 --quit-after 900 res://WorldMap.tscn`(창 모드, F6와 같은 장면).
- 수신기는 디버거의 `"error"` 메시지(경고 플래그 포함)를 그대로 한 줄씩 적었다. 저장소 밖 임시 폴더에서 돌렸고 저장소에 남긴 코드는 없다(증거 텍스트만).

| 실행 | 경고 수 | 원문 |
|---|---|---|
| `a9e3b84`(31번 시작점), 창 모드 | **12** | `agent/evidence/warnfix_20261108/listen_before_win_warnings.txt` |
| `a9e3b84`, 헤드리스 | 12(같은 목록) | `listen_before_warnings.txt` |
| `355688c`(30번 가지 끝), 창 모드 | **14** = 위 12 + 아래 2 | `listen_debugcheats_warnings.txt` |

## 2. 경고 목록과 분류 (코드 읽기, 수정 0)
### 2-1. `main`(`a9e3b84`)에 있는 12개 — 모두 1단계 허용 대상, 금지 파일 0
| # | 파일:줄 | 종류 | 내용 | 의도 판정 → 2단계 조치안 |
|---|---|---|---|---|
| 1 | `scripts/worldmap/worldmap_turn_compass.gd:147` | 그림자 `texture`(TextureRect) | `static func get_frame_hole()` 안의 지역 `var texture := load(FRAME_TEXTURE_PATH) as Texture2D` | static 함수라 `self.texture`를 쓸 수 없다 → 의도는 지역값. 이름만 `frame_texture` |
| 2·3 | `scripts/worldmap/worldmap_turn_compass.gd:159` (같은 줄 2개) | 정수 나눗셈 | `Vector2i(w / 2, h / 2)` — 채우기 시작 픽셀(그림 가운데) | 픽셀 좌표라 버림이 의도 → `@warning_ignore("integer_division")` 한 줄 |
| 4 | `worldmap3d/scripts/worldmap_geo.gd:196` | 정수 나눗셈 | `tris0 += idx0.size() / 3` | 삼각형 수 = 인덱스 수 / 3(항상 3의 배수) → 의도 |
| 5 | `worldmap3d/scripts/worldmap_geo.gd:219` | 정수 나눗셈 | `"tris": idx0.size() / 3` | 같음 → 의도 |
| 6 | `worldmap3d/scripts/worldmap_region_labels.gd:75` | 정수 나눗셈 | `var step := maxi(1, w / 384)` | 샘플 간격(픽셀 정수) → 의도 |
| 7 | `worldmap3d/scripts/worldmap_region_labels.gd:97` | 그림자 `basis`(Node3D) | `var basis := Basis(right, up_dir, ...)` | 바로 아래에서 지역값으로만 씀(라벨 회전) → 이름만 `label_basis` |
| 8 | `worldmap3d/scripts/worldmap3d_root.gd:208` | 정수 나눗셈 | `stats.terrain_tris = mesh.surface_get_array_index_len(0) / 3` | 삼각형 수 → 의도 |
| 9 | `worldmap3d/scripts/worldmap3d_root.gd:326` | 정수 나눗셈 | `stats.river_tris = ... / 3` | 같음 → 의도 |
| 10 | `worldmap3d/scripts/worldmap3d_root.gd:346` | 정수 나눗셈 | `stats.road_tris = ... / 3` | 같음 → 의도 |
| 11 | `worldmap3d/scripts/worldmap3d_root.gd:370` | 정수 나눗셈 | `stats.sea_route_tris = ... / 3` | 같음 → 의도 |
| 12 | `worldmap3d/scripts/worldmap3d_root.gd:566` | 그림자 매개변수 `name`(Node) | `func set_fill_preset(name: String)` → `cfg.fill_preset(name)` | 노드 이름을 쓰려던 코드 아님 → 이름만 `preset_name`. 호출처 3곳(113행, `tools/acceptance_tests.gd:387`, 4행 주석) 모두 위치 인자라 영향 없음 |

- **버그 의심: 0개.** 9개 모두 정수 결과가 맞는 계산이다(`/ 3`은 항상 나누어떨어지고, `/ 2`·`/ 384`는 픽셀 정수).
- **금지 파일에 있는 경고: 0개**(`worldmap_main.gd`·`battle_settlement_applier.gd`에는 없음).
- 지시서 1절 후보와 비교: `texture`(147)·`basis`(97)·`set_fill_preset(name)`(566) 3개는 맞다. `tools/acceptance_tests.gd`의 `_grab(name)`·`_grab_next_frame(name)`은 WorldMap F6에서 로드되지 않아 경고 목록에 없다.

### 2-2. 30번 가지에만 있는 2개 — 31번 수정 금지 파일
| # | 파일:줄 (`355688c`) | 종류 | 내용 | 원인 |
|---|---|---|---|---|
| 13 | `scripts/worldmap/ui/worldmap_debug_cheats_controller.gd:250` | 그림자 `owner`(Node) | `build_revealed_intel_entry` 안의 `var owner := str(main.call("_get_city_owner_faction_id_for_trade_display", city_id))` | 30번에서 클코드가 만든 코드. Node 기반 파일에 Node 속성 이름을 지역 변수로 썼다 |
| 14 | 같은 파일 `:291` | 그림자 매개변수 `name`(Node) | `func _get_main_constant(name: String, fallback: Variant)` | 같음 |

- 지시서 1절의 "`owner`를 Node 기반에서 못 찾았다", "`name` 두 번째를 못 찾았다"가 바로 이 2개다.
- 30번 테스트·CI는 경고를 검사하지 않아서 이 경고를 잡지 못했다(동작은 정상, 61/0).

## 3. 클코치에게 필요한 판단
- **A (클코드 권장)**:
  - 31번은 `main`의 12개만 지시서대로 정리한다(2-1 표의 조치안, 예상 전→후 12 → 0).
  - 30번 컨트롤러의 2개는 **30번 가지에서** 이름 두 개만 바꿔 고친다(`owner` → `owner_faction_id`, `name` → `constant_name`). 동작 불변이고, 코드 커밋 1 + CI + 30번 보고서에 덧붙임 1이다.
  - 두 가지가 모두 `main`에 들어가면 김작 F6에서 0개가 된다. 30번 가지 수정은 지시서 범위 밖이라 답신으로 허용이 필요하다.
- **B**: 31번 허용 목록에 30번 컨트롤러를 넣고 31번 가지에서 함께 고친다. 31번 가지에는 그 파일이 없어서 30번 가지 위에서 시작해야 하고, 두 단계가 엮이므로 권하지 않는다.
- **C**: 31번은 12개만 하고, 30번의 2개는 나중에(30번 F6·`main` 합류 때) 따로 정한다. 그때까지는 F6에 2개가 남는다.

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-warnfix-20261108`(코드는 `main` `a9e3b84`와 같음), 이 보고서 커밋 뒤 `git status` 깨끗. 재현을 위해 30번 가지를 잠깐 체크아웃했다가 되돌렸다(파일 변경 없음).
2. 새로 생긴 것: 가지 `feature/wm3d-warnfix-20261108`, 증거 폴더 `agent/evidence/warnfix_20261108/`(기존 `agent/evidence/` 아래). worktree·태그 0, 삭제 예정 0. 임시 수신기 프로젝트는 저장소 밖 임시 폴더에만 있다.
3. 푸시: 이 가지에 보고서 커밋 1개(`[skip ci]`)만. `main`·30번 가지·다른 가지 푸시 없음.
4. CI: 실행 0(코드 커밋 없음).
5. 김작/클코치가 결정할 것: 3절 A/B/C. 답신(`agent/ORDER_WARNFIX_REPLY_1_20261108.md` 등)이 오면 이 가지에서 잇는다. 30번 F6 확인과는 독립.
