# T2 "시험 세계 / 연출 군락" 분리 — 밤샘 보고 (2026-10-29, 지시서 v2)

## 결과 요약
- [사실] 관문 판정은 **S1**이다. 2단계를 진행했다.
- [사실] 끝의 전체 검사는 검증기 71 실패 0, Godot 194 실패 0이다(1,550초, 끝난 뒤 작업 트리 깨끗).
- [사실] 수정한 가지는 `exp/t2-split-20261028`(로컬만)이다. `feature/t2-forest-groves-20261028`(`6426c25`)는 건드리지 않았다.
- [사실] push, 병합, 통합 가지 수정, T3 착수는 하지 않았다. 엔진(`scripts/`)과 자료(`assets/`)도 바꾸지 않았다(diff 0파일).
- [사실] 백업 태그는 `backup/t2-pre-overnight-20261028` = `6426c25`이다.

| | HEAD | tree hash |
|---|---|---|
| 변경 전 (T2 가지) | `6426c25292c30abd24b443f46a689bd6c9495b16` | `a93b562055b15387d0b7865b4bbcef69234a0ba5` |
| 변경 후 (exp 가지, 이 보고서 직전) | `c81b6a9a59ce3f9af0a5c391461669a1a9c4f2f4` | `df7038a1772cb1204d979ade786d8de7a6a39713` |
| 이 보고서 커밋 | 커밋 후 `git log -1` 참고 | – |

- [사실] 증거 원문은 `C:\Users\seong\AppData\Local\Temp\claude\C--Users-seong--claude-spares-spare-bg06v6\e4e6ee4e-856e-4bc5-8cb0-c35818e5b64a\scratchpad\split\`에 있다. 아래에서 `split/`로 줄여 쓴다.

## 1단계 — 읽기 전용 조사

### A. 해시 사슬 [사실, `git log --oneline --graph`]
| 순서 | 커밋 | 한 줄 |
|---|---|---|
| 1 | `f347065` | T2 첫 보고서(첫 전체 검사에서 멈춤: base_parity 2개) |
| 2 | `bda1b96` | s43 하네스에 목록 없는 자체 `open_bare`(T1 `64bbd44` cherry-pick) |
| 3 | `7d2be18` | T2 검증기 범위에 s43 하네스 추가 |
| 4 | `5a51e53` | 보고서: s43 고침 뒤 전체 검사 통과 |
| 5 | `e0c91e2` | 기본 군락 C4b |
| 6 | `23e3ea3` | 옛 C1 칸을 고정한 시험 2개의 좌표 이동 |
| 7 | `0d3f297` | T2 검증기: C4b 고정, 언덕→숲 허용, `23e3ea3`에 고정 |
| 8 | `6426c25` | 보고서: C4b, 전체 검사 실패 3에서 멈춤 |

- [사실] **`bda1b96`은 `5a51e53`의 앞이다.**
- [사실] 보고서와 어긋나는 점: 10-28 밤샘 지시서는 "현재 `f347065` 위"라고 했다. 하지만 시작할 때 가지 끝은 이미 `5a51e53`이었고, ①(s43 고침)도 들어 있었다.
- [사실] `23e3ea3..6426c25`의 변경은 `git diff --stat` 기준 `tools/validate_t2_forest_groves.py`(+7/−3)와 T2 보고서(+51)뿐이다. `scripts`·`assets`·`tests` 변경은 0이다(`split/addendum/1_23e3ea3_to_6426c25.txt`). 그래서 P4 = `23e3ea3`의 동작은 `6426c25`와 같다.

### B. 기준선과 효과 분리
- [사실] 기준선 P2 = `5a51e53`이다. 실제 커밋(`bda1b96` 포함, 군락 C1)이라 합성하지 않았다.
- [사실] P1 = `f347065`, P3 = `e0c91e2`, P4 = `23e3ea3`이다.

**P1–P4 매트릭스** [사실, `split/matrix/`, 짧은 경로 `C:\dev\t2p`에서 Godot 하나씩]
| 지점 | base_parity 1 | base_parity 2 | scenario_defeat | ally_roster_actor |
|---|---|---|---|---|
| P1 `f347065` (s43 고침 없음, C1) | 실패 (seed_1 ally_move_event_log ≠ BASE) | 실패 (seed_4 …) | 통과 | 통과 |
| P2 `5a51e53` (기준선) | 통과 | 통과 | 통과 ×3 | 통과 ×3 |
| P3 `e0c91e2` (+C4b) | 통과 | 통과 | 실패 (defeat at round 8) | 실패 (정도전 카드) |
| P4 `23e3ea3` (+좌표 이동) | 통과 | 통과 | 실패 ×3 | 실패 ×3 |

- [사실] P1→P2: `open_bare` 고침이 base_parity 1·2를 고친다.
- [사실] P2→P3: C4b가 scenario_defeat와 ally_roster_actor를 깬다.
- [사실] P3→P4: 시험 좌표 이동은 네 시험에 영향이 없다.

**전체 검사**
- [사실] P2는 검증기 71 중 실패 1, Godot 194 실패 0이다(`split/P2_ci_full.txt`). 동등성 17개는 모두 통과했다.
- [사실] 실패한 검증기 하나는 `validate_battle_enemy_strategy_s4_2.py`이다. 원인은 조사용 worktree 경로(137자)가 Windows 경로 길이를 넘은 것이다. 원문은 `fatal: failed to stat '04ce32d…:scripts/worldmap/domestic_tech/domestic_tech_completion_presentation_controller.gd': Filename too long`이다(`split/addendum/3a_long_path_FAIL_…log`).
- [사실] 같은 커밋 `5a51e53`을 짧은 경로 `C:\dev\t2p`(10자)에서 다시 돌리면 `PASS`, `exit=0`이다(`split/addendum/3b_short_path_PASS_…log`). 그래서 기준선의 실패는 0으로 판정했다.
- [사실] P4의 전체 검사는 `0d3f297`(P4 + 검증기 고정)에서 돌린 10-28 결과이다. Godot 실패는 3이다: scenario_defeat, reinforce_default_rounds, ally_roster_actor.

**골든·기대값이 기록된 당시의 막힌 칸** [사실, `git log`/`blame`, `split/addendum/2_goldens.md`]
- 막힌 칸은 T1 `2ccb801`(10-27)에서 엔진에, `898ca6f`(10-27)에서 엔진 단독 기준에 처음 들어갔다.
- 아래 기대값은 모두 그 전에, 막힌 칸 없이 기록되었다.
  - scenario_defeat `battle_round == 6`: `81fdc43`(10-23).
  - reinforce_default_rounds "round 3: all ten units shown": `22f4fac`(10-22).
  - BASE 골든 `tests/golden/battle_setup_port_base_v0.json`: `06e9db0`/`5b45c18`(10-23).
  - 나머지 15개는 저장된 골든이 없다. 같은 시드의 3D 실행과 엔진 단독 실행을 비교한다(10-20~23 작성).
- auto 하네스가 검증된 당시의 설정: M5-a `651ac37`(10-22)은 막힌 칸이 없었다. T1(옛 숲 24칸)과 T2 C1에서도 같은 기대값으로 통과했다.

### C. 실패 재현 분리 [사실]
- 단독 3회: P2는 scenario_defeat 3/3, ally_roster_actor 3/3 통과이다. P4는 둘 다 3/3 실패이다(실패 문구가 매번 같다).
  - scenario_defeat 실패: 기대 6라운드 패배, 실제 8라운드이다.
  - ally_roster_actor 실패: 매 프레임 확인에서 정도전 카드가 보인다(447–451 프레임 등).
- 원인 분리(P4 트리, `terrain_types.json`만 바꿈):

| 변형 | scenario_defeat | ally_roster_actor | reinforce_default_rounds |
|---|---|---|---|
| (a) 왼쪽 군락만 (x4–6 y1–2) | 실패 | 실패 | 실패 |
| (b) 오른쪽 군락만 (x11–13 y7–8) | 통과 | 통과 | 통과 |
| (c) C4b에서 언덕 5칸 뺌 | 실패 | 실패 | 실패 |

- [사실] 엔진 단독 조사(대기만, 시드 1): 관우가 2라운드에 C1에서는 (10,2)→(6,2)로 오고, C4b에서는 (7,3)으로 온다. 그 뒤 적의 위치와 피해 순서가 달라져 패배가 6라운드에서 8라운드로 바뀐다(`t2/evidence/cause/`).
- [사실] 단독 실행에서도 재현되므로 병렬 부하는 원인이 아니다.

### D. 언덕 5칸 [사실]
- 군락은 칸의 **지형 종류를 바꾼다**. `terrain_types.json`(`e0c91e2`)에서 (4,1),(5,1),(4,2),(13,7),(13,8)이 `hill` → `forest`가 되었다.
- 그 종류를 읽는 곳:
  - `lab_heightfield.gd:69-73` `terrain()`이 JSON 문자열을 그대로 돌려준다.
  - `terrain_board_builder.gd:214`(칸 종류를 읽음)와 `:227`(바닥 질감)이 그 문자열을 쓴다.
  - `battle3d_engine_play.gd:723-729` `forest_cells()`가 `"forest"`만 모아 `:288`에서 `set_blocked_cells`로 넘긴다.
- 엔진(`scripts/battle*`)은 지형 종류를 모른다. 막힌 칸 목록만 받는다(`"hill"`을 찾으면 0건).
- 땅 높이는 heightfield에서 오므로 바뀌지 않는다.
- 검증기를 "언덕 → 숲 허용"으로 고친 전후 diff(`23e3ea3..0d3f297`):
  - 판 칸 규칙을 `forest <-> plain`에서 `forest <-> plain` 또는 `hill -> forest`로 넓혔다.
  - 기본 군락이 정확히 C4b 12칸인지 확인하는 `assert`를 넣었다.
  - 좌표를 옮긴 시험의 지운 줄 한도를 6에서 10으로 늘렸다.
  - `TIP`을 `1e13012`에서 `23e3ea3`으로 바꿨다.
- (c)의 결과로 언덕→숲이 원인이라는 판정(S3)은 아니다.

### E. auto 하네스 [사실]
- 막힌 칸 목록은 상수가 아니다. `battle3d_blocked_reference.gd:8-14`가 `lab_heightfield`로 `terrain_types.json`을 읽어 숲 칸을 모은다. 그래서 기본 군락이 바뀌면 같이 바뀐다.
- 그 목록을 넘기는 곳은 7개 하네스의 `open_bare`이다: auto `:44`, skill `:56`, enemy_turn `:80`, option `:49`, reinforce `:42`, strategy `:53`, wait `:44`.
- s43 하네스는 자체 `open_bare`를 두어 목록을 넘기지 않는다(`bda1b96`, `battle_setup_s43_harness.gd:31-38`).
- 3D 랩 쪽: `lab_presentation.gd:19` `var board = Board.new()`가 instantiate 때 보드를 만들고, `_ready`가 나무와 막힌 칸을 그 보드에서 만든다.
- 분리에 필요한 최소 수정 지점은 랩을 만드는 하네스 9곳, 시나리오 셸 `create_lab` 1곳, 엔진 단독 기준 1곳이다. 예상 변경은 한 줄씩, 15줄 안팎이었다. 실제 diff는 아래 2단계에 있다.

### F. 단일 출처 [사실]
- 3D 나무는 `terrain_board_builder.gd:1063-1068`이 보드의 숲 칸(`board_ref.terrain`)에서 군락을 만든다.
- 막힌 칸은 `battle3d_engine_play.gd:723-729`가 같은 보드(`board.terrain`)에서 모은다.
- 둘 다 `board.terrain_cells`를 본다. 출처는 하나이다.

### G. T3 범위 현황 (C4b, 코드 수정 없음) [사실, `split/G_t3_paths_on_C4b.log`]
| 길 | 호출 | 결과 |
|---|---|---|
| 전진 | (7,2)에서 쓰러진 (5,2) 쪽으로 | (6,2) **숲으로 들어감** |
| 후퇴(아군) | (8,1)에서 2칸 | (6,1) **숲으로 들어감** |
| 후퇴(적) | (10,7)에서 1칸 | (11,7) **숲으로 들어감** |
| 재배치 후보 | (5,3), 범위 3 | 24칸 중 **숲 6칸 포함** |
| 증원 도착 | 표식 칸 4개 | 모두 막히지 않음. 가장 가까운 군락까지 7–8칸 |

- [사실] **T2 통과는 모든 이동이 안전하다는 뜻이 아니다.** 전진·후퇴·재배치·증원은 T3 미검증 범위이다.

## 관문 판정 [사실]
- G0을 충족한다: P2 전체 검사 통과(경로 길이 검증기는 짧은 경로에서 통과), base_parity 1·2 통과, 동등성 17개 통과.
- 실패는 C4b에서만 재현된다(P2·(b)에서는 통과, P3·P4·(a)·(c)에서는 실패).
- 원인은 왼쪽 군락의 위치와, 하네스가 기본 군락을 그대로 읽는 결합이다.
- 그래서 **S1**로 판정했다.

## 2단계 — 최소 수정 (`exp/t2-split-20261028`)
| 커밋 | 내용 |
|---|---|
| `e7a8a55` | 시험 세계 고정. 새 보조 `tests/scripts/support/battle3d_test_world.gd`(C1). 하네스 9곳의 랩 생성 줄을 감쌌다. 시나리오 셸 `create_lab`에 `test_world` 깃발(기본 true)을 두었다. 엔진 단독 기준 보드에 한 줄을 넣었다. T1 3D 시험과 `block7_defaults`는 `h.test_world = false`(각 한 줄) |
| `13af603` | T2 군락 시험: 강·여울 칸 아님, 모든 판 칸 도달 가능, 엔진 이동 탐색 경로 = 시험 탐색 경로 |
| `7945838` | 새 보조 파일의 `.uid` |
| `c81b6a9` | T2 검증기: 분리 범위(하네스마다 시험 세계 한 줄만, 시험 세계 = C1, 제외 두 줄), `7945838`에 고정 |

- [사실] diff는 17파일, +109/−13이다. `scripts/`·`assets/`는 0파일이다. 골든·고정 자료·기대값은 바꾸지 않았다.
- [사실] 하네스 한 곳의 실제 변경은 다음과 같다(나머지 8곳도 같은 꼴):
  `lab = preload("res://tests/scripts/support/battle3d_test_world.gd").lab(load("res://scenes/battle3d/Battle3D_EnginePlayLab.tscn").instantiate()) # T2 split: the test world (C1 groves)`
- [사실] 고정된 보드는 `5a51e53`의 `terrain_types.json` 400칸과 차이가 0이다(`split/test_world_equals_P2.log`). 지운 C4b 칸은 높이에 따라 언덕/평지로 돌아가고, 다른 칸과 높이는 그대로이다.
- [사실] 3D 나무와 막힌 칸은 여전히 같은 보드 하나를 본다. 고정은 그 보드에 쓴다.
- [사실] T2 시험(C4b 주입 = 파일 그대로, C1·C4는 보조 파일로)은 40 checks, 실패 0이다. 확인하는 것:
  - 막힌 칸이 의도한 12칸이고 18×10 안에 있다.
  - 강·여울 칸이 아니다(옛 fixture로 확인).
  - 고정 장면 칸과 겹치지 않는다.
  - 시작·증원 도착 칸에서 2칸 이상 떨어져 있다.
  - 기본값은 가장자리 칸이 없다.
  - 이순신 시작 칸에서 나머지 168칸에 모두 닿는다.
  - 엔진의 `find_move_path`로 이순신 (3,8) ↔ 관우 (14,2) 두 방향이 모두 17걸음 = 시험 탐색 17걸음이고, 숲을 밟지 않는다.
- [사실] 숲 칸 직접 클릭 거부는 C4b에서 T1 3D 시험이 확인한다(제외 덕분에 C4b로 돈다). 손 넘긴 숲 칸은 (6,1),(5,1),(6,2)이고, (6,1) 클릭은 거부, (8,0) 이동은 허용이었다.
- [사실] 변이(`split/mutations/`), 매번 되돌렸다:
  - X4 왼쪽 군락을 맨 위 가장자리로(x4–6 y0–1): T2 시험이 **잡음**. 두 확인이 실패했다(넘긴 칸 ≠ C4b, 가장자리 (4,0),(5,0),(6,0)).
  - M 시험 세계 고정을 끔: scenario_defeat가 **잡음**(defeat at round 8).
- [사실] `23e3ea3`은 그대로 두었다. 되돌리는 방안: 그 두 시험(`block7_old_play_area`, `test_battle_blocked_cells` 4번)은 연출 기본값(JSON = C4b)을 직접 읽는다. 되돌리기만 하면 다시 실패한다. 되돌리려면 그 좌표를 `battle3d_t2_groves.gd`의 `COMBOS[DEFAULT]`에서 읽게 바꿔야 한다(이번 밤 범위 밖이라 하지 않음).

## 3단계 — 검증 (각 통과 기준 따로)
| 항목 | 결과 | 근거 |
|---|---|---|
| ① BASE 동등성 base_parity 1·2 | [사실] 통과 | `split/S3_ci_full/` |
| ② 동등성 17개 / auto 골든 | [사실] 17/17 통과. scenario_defeat, reinforce_default_rounds, ally_roster_actor 포함 | 같음 |
| ③ T2 군락 차단·우회·도달 시험 | [사실] 40 checks 실패 0, T1 3D/서비스/적 AI 통과 | 같음, `split/s2_run2/` |
| ④ 검증기 71 / Godot 194 | [사실] 실패 0, 부하 시간 초과 0, 1,550초, 끝난 뒤 작업 트리 깨끗 | `split/S3_ci_full.txt` |
| ⑤ 캡처 | [사실] 7장. C4b/C1/C4 줌 30 같은 장면 + 줌 42, C4b 이순신 선택 | `split/captures/` |

- [사실] 목록이 비면 2D가 바뀌지 않는지: 이번 단계에서 엔진과 자료는 0파일 변경이다. 막힌 칸 없이 여는 엔진 단독 BASE 시험(base_parity 1·2)도 통과한다.
- [사실] 캡처 수치(`t2b_capture_metrics.json`): 줌 30 같은 장면에서 세 조합 모두 프레임 16.68 ms(수직 동기 상한), 그린 삼각형 191,370, 드로우콜 541이다. 이순신 선택 장면은 199,314 / 524이다. 그린 이동 범위 안에 숲 칸은 없다(이순신 (3,8)).

## [미확인]으로 남은 항목
1. [미확인] GitHub CI 결과(푸시 안 함).
2. [미확인] 김작 F6 확인: C4b가 숲으로 읽히는지, 유닛을 가리지 않는지(캡처 01, 07).
3. [미확인] 하네스를 거치지 않는 3D 시험 5개(`test_battle3d_enemy_turn_manual`, `engine_attack_manual`, `engine_move_integration`, `option_strategy_gaps`, `measure_dice_rng_draws`)는 고정하지 않고 C4b로 돈다. CI 목록에 있는 `engine_move_integration`, `option_strategy_gaps`는 전체 검사에서 통과했다. 나머지 3개(`enemy_turn_manual`, `engine_attack_manual`, `measure_dice_rng_draws`)는 CI 목록에 없어서 돌리지 않았다. 이 시험들도 시험 세계로 묶어야 하는지는 정하지 않았다.
4. [미확인] 시험 세계를 C1로 둔 해석: 기대값은 "막힌 칸 없음"으로 기록되었고 C1에서 마지막으로 통과했다. "검증 당시 설정"을 C1로 읽었고, "막힌 칸 없음"으로 읽을 수도 있다.
5. [미확인] T3 경로(전진·후퇴·재배치)는 C4b에서 숲으로 들어갈 수 있다(G). 실제 전투에서 그 상황이 나오는지는 재지 않았다.

## 김작이 정할 것 (지시서 §7)
1. 군락 조합 최종 확정(C1 / C4 / C4b).
2. 언덕 위 군락 허용 여부.
3. exp 가지를 T2 가지에 넣을지, 그리고 푸시("푸시해줘" 이후).
4. T3 착수.
