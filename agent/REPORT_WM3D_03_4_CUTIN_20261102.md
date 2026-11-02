기준 화면: 없음(보이는 화면 변화 0). 읽기 전용 조사이고 게임 코드·테스트·워크플로는 수정하지 않았다.
합격 기준: 김작이 이 보고서만 읽고 "컷인 테스트가 왜 실패했고 무엇을 고쳐야 하는지"를 판단할 수 있다. 증명되지 않은 원인은 "[미확인]"으로 적는다.

① 원인 판정: C-track shard 0 실패는 oracle 테스트가 아니라 **`test_battle3d_cutin_result_toast.gd` 153행 검사**(컷인 길이 ≥ 3.95초)다[사실]. 가설 A(느린 러너)는 **아님**: 실패한 두 번은 오히려 **가장 빠른 러너**였다(프레임 속도 약 69~102fps, 통과 run은 약 32fps). 로컬에서 CPU를 눌러 느리게 하면 측정값은 4.6~5.8초 → 5.2~8.6초로 **길어졌다**. 가설 C(`1e90b97` 영향)는 **아님**(경로 없음, 같은 실패가 10-30 `26a12d4`에도 있었음). 가설 B(측정·스케줄 구조)는 **[추정] 맞음**: 측정 시작이 컷인을 켠 프레임보다 한 프레임 늦고, 스케줄 트윈은 만든 프레임의 delta를 바로 받는다. 빠른 러너에서는 "다음 이벤트를 기다리는 여유"가 거의 없어 이 어긋남이 그대로 드러난다. 다만 어긋남의 크기(최대 약 0.07초)를 코드만으로 다 설명하지는 못했다(일부 [미확인]).
② 추천 수정 방향(1개): **테스트의 측정 시작을 HUD 자신의 시각 `hud.cutin_started_msec`(컷인을 켠 바로 그 호출에서 기록, `battle3d_cutin_toast_hud.gd` 154행)로 바꾼다.** 이유: 스케줄과 같은 지점에서 재므로 한 프레임 늦은 시작 문제가 없어지고, 테스트 의도("실제 4초 이상 보인다")와 기준(4.0 − 0.05)은 그대로 둘 수 있다. 오차만 키우는 방법보다 원인 쪽을 고친다.
③ 김작이 할 일: 고칠지·어느 방향으로 고칠지 결정(별도 지시서). 이번에 고친 것 없음.

택한 해석: ① 지시서 0-4대로 앞 조사(`REPORT_WM3D_03_4_CI_SHARD0`, 올리지 않은 상태였음)를 이 보고서에 합쳐 새 파일 1개만 올림. ② 앞 보고서(`REPORT_WM3D_03_4_20261102.md`)의 "oracle 테스트가 실패" 부분은 **틀렸음**: `gh run view --log`가 로그를 잘라서 보여 준 것(아래 1절)이었다. 여기서 정정함. ③ 2-4(프레임 상한 확인)는 2-2·2-3 결과가 "프레임이 거칠어서"를 가리키지 않아(반대 방향) 하지 않음. ④ 로컬 측정은 같은 PC에서 하나씩 차례로 돌림(동시 실행 없음).

---

## 1. CI 로그 [사실]

### 1-0. 로그 끊김 판단 (앞 조사 정정)

- attempt 1 shard 0 job `125285368133` 원본 로그(`gh api …/actions/jobs/125285368133/logs`)는 **25,776줄**. 앞 보고서가 쓴 `gh run view --log --job` 출력은 **3,573줄**로, 12:51:19 뒤가 잘려 있었다.
- 원본에는 12:51:19~13:04:44 사이에 shard 0 테스트 27개의 출력이 모두 있음(다음 표). 그래서 빈 구간은 **실제 무출력이 아니라 `gh run view` 출력의 누락**이다.
- 같은 방식으로 직전 성공 run `41435623340` shard 0 원본은 27,583줄이고 `[CUTIN] checks=16 failures=[]`가 있다.
- 실패 줄과 종료 줄 원문(attempt 1):

```
2026-11-02T13:04:44.6485627Z [M3] FAIL at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.952, 3.954, 3.929, 3.951, 3.937]
2026-11-02T13:04:44.7010897Z [CUTIN] checks=16 failures=["at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.952, 3.954, 3.929, 3.951, 3.937]"]
2026-11-02T13:04:44.8529948Z ##[error]Process completed with exit code 1.
```

- attempt 2(job `125300148841`, 25,750줄)도 같은 검사로 실패: `[CUTIN] checks=16 failures=["… [3.942, 3.977, 3.959, 3.956, 3.934]"]` → `2026-11-02T13:37:08.8025524Z ##[error]Process completed with exit code 1.`
- 원본 로그에서 `exit code`·`##[error]`·`Process completed`는 위 1줄씩뿐(attempt 1: 25760행, attempt 2: 25734행).

### 1-1. 실패·통과 run의 컷인 측정값 (shard 0, `[CUTIN] 3D cut-ins (caster, start frame, end frame, real s)=` 원문에서)

| run (attempt) | 커밋 | 결과 | 측정값 5개 (초) | 최소 | 최대 | 첫 컷인 프레임 수 / 초 → fps |
|---|---|---|---|---|---|---|
| 41447864206 (1) | `1e90b97` | **FAIL** | 3.952, 3.954, 3.929, 3.951, 3.937 | 3.929 | 3.954 | 403 / 3.952 → 약 102 |
| 41447864206 (2) | `1e90b97` | **FAIL** | 3.942, 3.977, 3.959, 3.956, 3.934 | 3.934 | 3.977 | 272 / 3.942 → 약 69 |
| 41435623340 | `37f7f0d` | 통과 | 4.278, 4.392, 4.339, 4.285, 4.191 | 4.191 | 4.392 | 135 / 4.278 → 약 32 |
| 41426918702 | `2dacaa9` | 통과 | 4.206, 4.422, 4.39, 4.34, 4.252 | 4.206 | 4.422 | 126 / 4.206 → 약 30 |
| 41381822288 | `74cebe4` | 통과(shard 0) | 4.289, 4.474, 4.371, 4.298, 4.225 | 4.225 | 4.474 | 125 / 4.289 → 약 29 |
| 41378943190 | `4b415cd` | 통과 | 3.976, 4.079, 4.076, 4.049, 4.022 | **3.976** | 4.079 | 186 / 3.976 → 약 47 |
| 41361883442 | `6c806f2` | 통과 | 4.295, 4.435, 4.374, 4.324, 4.236 | 4.236 | 4.435 | 127 / 4.295 → 약 30 |
| 41317008432 | `5bf2f2d` | 통과 | 4.282, 4.458, 4.367, 4.327, 4.246 | 4.246 | 4.458 | 129 / 4.282 → 약 30 |
| 41309095016 이전 4건 | `8877dfe`·`0bd8730`·`66e8ae1`·`8be8435` | 통과 | shard 0 로그에 `[CUTIN]` 줄 없음 | — | — | [미확인](그때 shard 배정이 달랐거나 다른 shard에서 돎) |
| 41076067042 (10-30, 다른 가지) | `26a12d4` | **FAIL**(shard 3) | 3.958, 3.974, 3.971, 3.958, 3.93 (그때 기준 4.01) | 3.93 | 3.974 | — |

- 통과 6건의 최솟값은 3.976~4.246, 보통 4.19~4.47. 3.95 기준과의 여유가 가장 작았던 것은 `4b415cd`(3.976, fps 약 47).
- 실패 attempt 1 `[CUTIN] speed x4.0 Engine.time_scale=4.0 casts …` 줄 앞부분 원문: `[["gwon_yul", "kwon_yul_unique", 50, 1.042], ["zhang_fei", "zhang_fei_unique", 12, 0.121], ["gwon_yul", "kwon_yul_unique", 24, 1.072], ["zhang_fei", "zhang_fei_unique", 5, 0.125], …` (통과 `37f7f0d`: `[["gwon_yul", "kwon_yul_unique", 10, 1.327], ["zhang_fei", "zhang_fei_unique", 3, 0.13], …` — 같은 시간에 프레임이 약 3~5배 많음).

### 1-2. shard 0 단계 소요 시간 (step 9 "C-track Godot tests")

| run | 커밋 | step 9 시작~끝 | 소요 | 결과 |
|---|---|---|---|---|
| 41447864206 attempt 1 | `1e90b97` | 12:51:06 ~ 13:04:44 | 13분 38초 | failure(33번째 테스트에서 멈춤, 뒤 10개 미실행) |
| 41447864206 attempt 2 | `1e90b97` | 13:23:11 ~ 13:37:08 | 13분 57초 | failure(같음) |
| 41435623340 | `37f7f0d` | 11:19:49 ~ 11:38:02 | 18분 13초 | success(43개 전부) |
| 41426918702 | `2dacaa9` | 10:14:39 ~ 10:32:54 | 18분 15초 | success |
| 41381822288 | `74cebe4` | 03:14:44 ~ 03:33:06 | 18분 22초 | success |
| 41378943190 | `4b415cd` | 02:41:52 ~ 02:58:16 | 16분 24초 | success |
| 41361883442 | `6c806f2` | 23:25:55 ~ 23:44:30 | 18분 35초 | success |

- 같은 33개 테스트까지 걸린 시간 비교: 실패 attempt 1은 oracle_shard_2 시작(12:51:11)~cutin 시작(13:03:55) **12분 44초**, 통과 `37f7f0d`는 11:19:55~11:35:26 **15분 31초**. 실패 run의 러너가 약 18% 빨랐다[사실]. 컴퓨터가 느려진 것이 아니라 빨라졌다.

### 1-3. shard 0 순서 (oracle_shard_2 다음에 도는 테스트)

- 근거: `.github/workflows/verify-c-track.yml` step 9(162~346행)는 `index=$(cat "$RUNNER_TEMP/ci_test_index" 2>/dev/null || echo 0)`(338행). step 9가 이 파일을 쓰는 첫 단계라 시작 오프셋은 0. 목록 170개 중 `index % 4 == 0`인 43개가 shard 0. oracle_shard_2는 index 20(6번째), cutin은 index 128(33번째).
- 실패 attempt 1에서 실제로 돈 순서(원본 로그 `=====` 줄)와 위 계산이 33번째까지 같음. 직전 성공 run의 앞 40개와도 같음.
- 로컬 `1e90b97`에서 oracle_shard_2 다음 37개를 같은 순서로 `timeout 300s`로 하나씩 실행:

| index | 테스트 | 종료 코드 | 시간(초) | 마지막 결과 줄(앞부분) |
|---|---|---|---|---|
| 24 | test_battle_enemy_turn_oracle_shard_1 | 0 | 37 | `[ENEMY_TURN_ORACLE] checks=64 failures=[]` |
| 28 | test_battle_tactic_oracle_shard_1 | 0 | 35 | `[TACTIC_ORACLE] checks=60 failures=[]` |
| 32 | test_battle_tactic_dice_hook | 0 | 34 | `[TACTIC_DICE_HOOK] checks=96 failures=[]` |
| 36 | test_battle_enemy_strategy_base_parity_shard_1 | 0 | 37 | `checks=21 failures=[]` |
| 40 | test_battle_enemy_rules_ally_parity_shard_2 | 0 | 44 | `checks=67 failures=[]` |
| 44 | test_battle_enemy_skill_spread_base_parity | 0 | 27 | `checks=11 failures=[]` |
| 48 | test_battle_setup_port_base_parity_shard_1 | 0 | 69 | `checks=36 failures=[]` |
| 52 | test_battle_enemy_ai_level_mid_default | 0 | 39 | `checks=4 failures=[]` |
| 56 | test_battle_ally_move_state_service | 0 | 1 | `PASS: 25 checks, 0 failures` |
| 60 | test_battle3d_engine_attack_shard_2 | 0 | 19 | `checks=1543 failures=[]` |
| 64 | test_battle3d_enemy_turn_equivalence_shard_1 | 0 | 64 | `checks=147 failures=[]` |
| 68 | test_battle3d_enemy_turn_default_layout | 0 | 7 | `checks=68 failures=[]` |
| 72 | test_battle3d_defend_equivalence | 0 | 52 | `checks=248 … failures=[]` |
| 76 | test_battle3d_strategy_default_round | 0 | 35 | `checks=47 failures=[]` |
| 80 | test_battle3d_reinforce_blocking | 0 | 9 | `checks=31 failures=[]` |
| 84 | test_battle3d_skill_equivalence_shard_3 | 0 | 82 | `[M4C1_SKILL_EQUIVALENCE] …`(rc 0) |
| 88 | test_battle3d_skill_mixed_log | 0 | 11 | `checks=14 failures=[]` |
| 92 | test_battle3d_auto_equivalence_seed_1 | 0 | 54 | `checks=70 … failures=[]` |
| 96 | test_battle3d_auto_stop_rejections | 0 | 27 | `checks=61 failures=[]` |
| 100 | test_battle3d_auto_hold_1x_seed_1 | 0 | 57 | `checks=24 failures=[]` |
| 104 | test_battle3d_scenario_start | 0 | 12 | `checks=24 failures=[]` |
| 108 | test_battle3d_scenario_victory_seed_2 | 0 | 62 | `checks=12 failures=[]` |
| 112 | test_battle3d_enemy_strategy_replay | 0 | 14 | `checks=35 failures=[]` |
| 116 | test_battle3d_top_hud | 0 | 58 | `checks=27 failures=[]` |
| 120 | test_battle3d_enemy_roster | 0 | 54 | `checks=39 failures=[]` |
| 124 | test_battle3d_acted_ally_click | 0 | 18 | `checks=7 failures=[]` |
| **128** | **test_battle3d_cutin_result_toast** | 0 | 70 | `[CUTIN] checks=16 failures=[]` |
| 132 | test_battle3d_oblique_click | 0 | 12 | `PASS: 1522 checks, 0 failures` |
| 136 | test_battle3d_block7_board_data | 0 | 0 | `PASS: 13 checks, 0 failures` |
| 140 | test_battle3d_look12_tree_height | 0 | 1 | `PASS: 3 checks, 0 failures` |
| 144 | test_battle3d_edge_scroll_gates | 0 | 9 | `checks=14 failures=[]` |
| 148 | test_battle3d_block46_facing_ground | 0 | 7 | `checks=4 failures=[]` |
| 152 | test_battle3d_block46b_panel_avoid | 0 | 10 | `checks=3 failures=[]` |
| 156 | test_battle3d_block46d_panel_sweep | 0 | 22 | `checks=5 failures=[]` |
| 160 | test_battle3d_block6a_panel_body_gap | 0 | 22 | `checks=5 failures=[]` |
| 164 | test_battle_t1_enemy_ai_blocked | 0 | 29 | `PASS: 3 checks, 0 failures` |
| 168 | test_single_side_exhaustion_turn_order | 0 | 4 | `[ONE_SIDE_EXHAUSTION_TURN] PASS` |

37개 모두 rc=0, 합계 1,144초. index 132~168(10개)은 CI attempt 1·2에서 cutin 실패로 **돌지 않은** 것들이다.

### 1-4. attempt 1 shard 0 원본 로그 마지막 100줄 (색 코드 제거)

<details><summary>펼치기</summary>

```
2026-11-02T13:04:32.7287584Z ALLY MOVED grid_cell: (6, 2) target_cell: (6, 2)
2026-11-02T13:04:32.7314804Z ENTER FACING SELECT
2026-11-02T13:04:32.7328951Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:32.7355434Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:32.7755231Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:33.0180403Z [ENEMY_TURN_START] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:33.0538400Z [ENEMY_AI_DECISION] actor_slot=enemy_reinforce_02 actor=제갈량 preferred_target=ally_main_01/이순신 final_target=ally_main_01/이순신 dest=(10, 3) reason=ENGAGE action=ENGAGE wait_reason=
2026-11-02T13:04:33.1006652Z [ENEMY_TURN] round=5 actor=enemy_reinforce_02_test_unit acted remaining=0
2026-11-02T13:04:33.1095776Z [ALLY_TURN_RETURN] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:33.1523134Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:33.3870237Z [ROLLBACK] snapshot stored unit=정도전 cell=(5, 4)
2026-11-02T13:04:33.4843831Z [MOVE_FINISH] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:33.4844175Z ALLY MOVED grid_cell: (7, 3) target_cell: (7, 3)
2026-11-02T13:04:33.4871483Z ENTER FACING SELECT
2026-11-02T13:04:33.4885590Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:33.4911752Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:33.5330329Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:33.8836416Z [CUTIN_TRACE] request runtime_caster_id=jeong_dojeon raw_skill_owner_id=jeong_do_jeon canonical_caster_id=jeong_do_jeon canonical_skill_owner_id=jeong_do_jeon skill_id=jeong_do_jeon_unique
2026-11-02T13:04:33.8837053Z [CUTIN_TRACE] registry_hit=true
2026-11-02T13:04:33.9212463Z [CUTIN_TRACE] selected_mode=video video_path=res://assets/ui/cutin/videos/jeong_do_jeon__gaehyeongnyeong__cutin_bg_theora_q8_1280x720.ogv video_resource=VideoStreamTheora presentation_node=/root/@Node@2/Battle3D_EnginePlayLab/@SubViewport@410/Battle_Main/HeroCutinOverlay/HeroCutinViewport/HeroCutinPresentation presentation_method=play_cutin stream_assigned=true play_ca
2026-11-02T13:04:33.9214348Z [HERO_CUTIN] route=registry_video hero_id=jeong_do_jeon skill_id=jeong_do_jeon_unique video=res://assets/ui/cutin/videos/jeong_do_jeon__gaehyeongnyeong__cutin_bg_theora_q8_1280x720.ogv title=res://assets/ui/cutin/titles/jeong_do_jeon__gaehyeongnyeong__title.png token=5
2026-11-02T13:04:34.9255085Z [HERO_CUTIN] complete source=signal hero=jeong_do_jeon skill=jeong_do_jeon_unique
2026-11-02T13:04:34.9255477Z [UNIQUE_CUTIN] EFFECT_APPLY elapsed=10.781
2026-11-02T13:04:34.9784542Z [ENEMY_TURN_START] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:34.9991669Z [ALLY_TURN_RETURN] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:35.1027767Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:37.9511453Z [ROLLBACK] snapshot stored unit=권율 cell=(4, 1)
2026-11-02T13:04:38.0249288Z [MOVE_FINISH] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.0249689Z ALLY MOVED grid_cell: (7, 1) target_cell: (7, 1)
2026-11-02T13:04:38.0277246Z ENTER FACING SELECT
2026-11-02T13:04:38.0291946Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:38.0348494Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:38.0845415Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:38.3406830Z [ENEMY_TURN_START] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.3616306Z [ALLY_TURN_RETURN] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.4167851Z [ROLLBACK] snapshot stored unit=김유신 cell=(5, 3)
2026-11-02T13:04:38.4315894Z [MOVE_FINISH] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.4316231Z ALLY MOVED grid_cell: (6, 3) target_cell: (6, 3)
2026-11-02T13:04:38.4343037Z ENTER FACING SELECT
2026-11-02T13:04:38.4357147Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:38.4413298Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:38.5086134Z [ENEMY_TURN_START] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.5276925Z [ALLY_TURN_RETURN] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.5786817Z [ROLLBACK] snapshot stored unit=을지문덕 cell=(2, 4)
2026-11-02T13:04:38.6113226Z [MOVE_FINISH] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.6113829Z ALLY MOVED grid_cell: (3, 3) target_cell: (3, 3)
2026-11-02T13:04:38.6140288Z ENTER FACING SELECT
2026-11-02T13:04:38.6154256Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:38.6210403Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:38.6746622Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:38.8024428Z [ENEMY_TURN_START] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.8380879Z [ALLY_TURN_RETURN] ally=(6, 2) enemy=(6, 2) dist=0 ally_range=3 enemy_range=1
2026-11-02T13:04:38.8439342Z [BATTLE_TOAST_PLAY] tag=round_start text=BATTLE 6 texture=round_toast_ink_war_01.png queue_remaining=0
2026-11-02T13:04:38.9663139Z [ROLLBACK] snapshot stored unit=이순신 cell=(6, 2)
2026-11-02T13:04:39.0439742Z [MOVE_FINISH] ally=(8, 2) enemy=(6, 2) dist=2 ally_range=3 enemy_range=1
2026-11-02T13:04:39.0440092Z ALLY MOVED grid_cell: (8, 2) target_cell: (8, 2)
2026-11-02T13:04:39.0467338Z ENTER FACING SELECT
2026-11-02T13:04:39.0481558Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:39.0537030Z SHOW FACING ARROW PANEL visible=true pos=(0.0, 0.0) size=(1280.0, 720.0)
2026-11-02T13:04:39.1042489Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:39.3342100Z [CUTIN_TRACE] request runtime_caster_id=yi_sunsin raw_skill_owner_id=yi_sun_sin canonical_caster_id=yi_sun_sin canonical_skill_owner_id=yi_sun_sin skill_id=yi_sun_sin_unique
2026-11-02T13:04:39.3342715Z [CUTIN_TRACE] registry_hit=true
2026-11-02T13:04:39.3770939Z [CUTIN_TRACE] selected_mode=video video_path=res://assets/ui/cutin/videos/yi_sun_sin__hagikjin__cutin_bg_theora_q8_1280x720.ogv video_resource=VideoStreamTheora presentation_node=/root/@Node@2/Battle3D_EnginePlayLab/@SubViewport@410/Battle_Main/HeroCutinOverlay/HeroCutinViewport/HeroCutinPresentation presentation_method=play_cutin stream_assigned=true play_called=true 
2026-11-02T13:04:39.3772217Z [HERO_CUTIN] route=registry_video hero_id=yi_sun_sin skill_id=yi_sun_sin_unique video=res://assets/ui/cutin/videos/yi_sun_sin__hagikjin__cutin_bg_theora_q8_1280x720.ogv title=res://assets/ui/cutin/titles/yi_sun_sin__hagikjin__title.png token=6
2026-11-02T13:04:40.3827466Z [HERO_CUTIN] complete source=signal hero=yi_sun_sin skill=yi_sun_sin_unique
2026-11-02T13:04:40.3827827Z [UNIQUE_CUTIN] EFFECT_APPLY elapsed=16.238
2026-11-02T13:04:40.3984598Z [AUTO_BATTLE_STOP] reason=battle result finalized
2026-11-02T13:04:40.3984975Z [AUTO_BATTLE_STOP] source=result_toast reason=battle_result_finalized state=victory
2026-11-02T13:04:40.3985396Z [BATTLE_END] source=result_toast state=victory ally_alive=5 enemy_alive=0
2026-11-02T13:04:40.4828132Z [DefeatToast] SHOW unit=제갈량 side=enemy t=45029 hold_ms=1200 queue_remaining=0
2026-11-02T13:04:40.5015643Z [D5_CAMERA_HANDOFF] focused active ally after automatic turn return
2026-11-02T13:04:40.6849371Z [DefeatToast] HOLD_DONE unit=제갈량 t=45231 elapsed=202ms
2026-11-02T13:04:40.7345814Z [DefeatToast] HIDE unit=제갈량 t=45281 elapsed=252ms
2026-11-02T13:04:40.7347637Z [BATTLE_RESULT_VIDEO_LOAD] path=res://assets/ui/result/videos/victory_result_theora_q8_1920x.ogv file_exists=true resource_loader_exists=true load_null=false class=VideoStreamTheora is_video_stream=true
2026-11-02T13:04:40.7484638Z [BATTLE_RESULT_VIDEO] play state=victory path=res://assets/ui/result/videos/victory_result_theora_q8_1920x.ogv
2026-11-02T13:04:40.7485127Z [BATTLE_RESULT] state=victory ally_alive=5 enemy_alive=0
2026-11-02T13:04:41.7727356Z [BATTLE_RESULT_VIDEO] complete source=finished_signal state=victory
2026-11-02T13:04:41.7756626Z [BATTLE_TOAST_PLAY] tag=result_victory text=승리! texture=battle_result_victory.png queue_remaining=0
2026-11-02T13:04:44.6485627Z [M3] FAIL at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.952, 3.954, 3.929, 3.951, 3.937]
2026-11-02T13:04:44.6486896Z [CUTIN] speed x4.0 Engine.time_scale=4.0 casts (caster, skill, frames to first effect, real s)=[["gwon_yul", "kwon_yul_unique", 50, 1.042], ["zhang_fei", "zhang_fei_unique", 12, 0.121], ["gwon_yul", "kwon_yul_unique", 24, 1.072], ["zhang_fei", "zhang_fei_unique", 5, 0.125], ["yi_sunsin", "yi_sun_sin_unique", 21, 1.065], ["jeong_dojeon", "jeong_do_jeon_unique", 42, 1.08
2026-11-02T13:04:44.6488066Z [CUTIN] 3D cut-ins (caster, start frame, end frame, real s)=[["gwon_yul", 242, 645, 3.952], ["gwon_yul", 837, 1051, 3.954], ["yi_sunsin", 1257, 1615, 3.929], ["jeong_dojeon", 1936, 2365, 3.951], ["yi_sunsin", 2464, 2786, 3.937]] routes=[["gwon_yul", "video"], ["zhang_fei", "still"], ["gwon_yul", "video"], ["zhang_fei", "still"], ["yi_sunsin", "video"], ["jeong_dojeon",
2026-11-02T13:04:44.6490338Z [CUTIN] toasts=[{ "tag": "round_start", "text": "BATTLE 1" }, { "tag": "reinforcement_arrival", "text": "지원군 도착!" }, { "tag": "round_start", "text": "BATTLE 2" }, { "tag": "reinforcement_arrival", "text": "지원군 도착!" }, { "tag": "round_start", "text": "BATTLE 3" }, { "tag": "round_start", "text": "BATTLE 4" }, { "tag": "round_start", "text": "BATTLE 5
2026-11-02T13:04:44.7010897Z [CUTIN] checks=16 failures=["at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.952, 3.954, 3.929, 3.951, 3.937]"]
2026-11-02T13:04:44.8529948Z ##[error]Process completed with exit code 1.
2026-11-02T13:04:44.8631028Z Post job cleanup.
2026-11-02T13:04:44.9168503Z [command]/usr/bin/git version
2026-11-02T13:04:44.9229414Z git version 2.56.0
2026-11-02T13:04:44.9250871Z Temporarily overriding HOME='/home/runner/work/_temp/e2f9424f-ae87-4cef-9610-9a8637b2bc7a' before making global git config changes
2026-11-02T13:04:44.9251531Z Adding repository directory to the temporary git global config as a safe directory
2026-11-02T13:04:44.9254191Z [command]/usr/bin/git config --global --add safe.directory /home/runner/work/SamWar_BattleLab/SamWar_BattleLab
2026-11-02T13:04:44.9284192Z [command]/usr/bin/git config --local --name-only --get-regexp core\.sshCommand
2026-11-02T13:04:44.9311270Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'core\.sshCommand' && git config --local --unset-all 'core.sshCommand' || :"
2026-11-02T13:04:44.9502019Z [command]/usr/bin/git config --local --name-only --get-regexp http\.https\:\/\/github\.com\/\.extraheader
2026-11-02T13:04:44.9526522Z http.https://github.com/.extraheader
2026-11-02T13:04:44.9531244Z [command]/usr/bin/git config --local --unset-all http.https://github.com/.extraheader
2026-11-02T13:04:44.9564003Z [command]/usr/bin/git submodule foreach --recursive sh -c "git config --local --name-only --get-regexp 'http\.https\:\/\/github\.com\/\.extraheader' && git config --local --unset-all 'http.https://github.com/.extraheader' || :"
2026-11-02T13:04:44.9764574Z [command]/usr/bin/git config --local --name-only --get-regexp ^includeIf\.gitdir:
2026-11-02T13:04:44.9801284Z [command]/usr/bin/git submodule foreach --recursive git config --local --show-origin --name-only --get-regexp remote.origin.url
2026-11-02T13:04:45.0097993Z Cleaning up orphan processes
2026-11-02T13:04:45.0328214Z ##[warning]Node.js 20 is deprecated. The following actions target Node.js 20 but are being forced to run on Node.js 24: actions/checkout@v4. For more information see: https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/
```

</details>

## 2. 코드·로컬 조사

### 2-1. 측정 방식과 스케줄 [사실, 파일·줄]

- **스케줄:** `scripts/ui/cutin/hero_cutin_presentation.gd` 12행 `@export var full_video_duration := 4.01`, 76~80행 `_root_tween = create_tween()` … `_root_tween.tween_interval(full_video_duration / _playback_speed)` → `tween_callback(_finish_cutin)`. 177~180행 `_finish_cutin`에서 `cutin_finished.emit()`.
- **배속 보정:** `scripts/battle3d/battle3d_scenario_shell.gd` 483행 `cutin_hud.play_cutin(entry, 1.0 / Engine.time_scale)` → `battle3d_cutin_toast_hud.gd` 140~155행 `presentation.set_playback_speed(speed)`, `presentation.play_cutin()`, `cutin_playing = true`, `cutin_started_msec = Time.get_ticks_msec()`(154행). x4에서 트윈 길이 4.01 / 0.25 = 16.04 "엔진 시간"초 = 4.01 실제 초(엔진 시간이 4배로 흐름).
- **컷인 끝:** 쉘 465~469행 — `cutin_tween_done`(=`cutin_finished` 받음, HUD 86행) **그리고** (다음 기술 이벤트 도착 또는 `cutin_seconds() > 8.0`)일 때 `end_cutin()` → `cutin_playing = false`. 즉 컷인은 스케줄 4.01초 + "다음 이벤트를 기다린 시간"만큼 보인다.
- **누가 언제 부르나:** 시작·끝 모두 쉘의 `_refresh_cutin_toasts()`(452행)인데, 이것은 `battle3d_top_hud.gd` 16~17행 `_process`에서 `refresh.call()`로 불린다(`process_priority = 100`, 즉 그 프레임의 노드 처리 끝 무렵).
- **테스트 측정:** `tests/scripts/test_battle3d_cutin_result_toast.gd` 113~114행 `for i in range(200000): await process_frame` — `process_frame`은 프레임 **시작**에 온다. 127행 `var playing: bool = hud.cutin_playing`, 128~130행 처음 true를 본 프레임에 `cut_msec = Time.get_ticks_msec()`, 137행 처음 false를 본 프레임에 `(Time.get_ticks_msec() - cut_msec) / 1000.0`. 22~23행 주석: "frame to frame … can undershoot the 4.01 s schedule by about a frame or two", `CUTIN_SPAN_TOLERANCE_SEC := 0.05`.
- **판단 — 측정값이 4.0보다 짧아질 수 있는 구조가 있는가: 있다.**
  - [사실] 시작은 컷인을 켠 프레임 N의 **다음** 프레임 N+1 시작에서 잰다(켠 뒤 프레임 N의 남은 처리 시간이 빠짐). 끝도 끈 프레임의 다음 프레임 시작에서 재서 이 부분은 서로 상쇄될 수 있다.
  - [추정] Godot는 노드 `_process` 뒤에 트윈을 진행하므로, 프레임 N에서 만든 트윈은 그 프레임의 delta를 곧바로 받는다. 이 몫만큼 스케줄이 실제보다 일찍 끝날 수 있다(1프레임: 102fps면 약 0.01초, 32fps면 약 0.03초). 이것만으로는 실패값의 부족분(최대 약 0.07초)을 다 설명하지 못한다. 컷인을 켠 프레임의 영상·그림 로드(`ResourceLoader.load`, HUD 144~145행) 시간이 트윈 delta에는 들어가고 테스트 측정에는 안 들어가는 경우가 나머지일 수 있으나 **[미확인]**(로드 시간을 재는 출력이 없음).
  - [사실] 끝 조건에 "다음 이벤트 기다림"이 더해지므로, 느린 러너(프레임이 길수록 다음 이벤트까지 실제 시간이 길어짐)에서는 측정값이 4.2~4.5초로 넉넉하고, 빠른 러너에서는 이 여유가 거의 0이 되어 위 부족분이 그대로 보인다[추정, 아래 2-2·2-3과 1-1 fps가 같은 방향].

### 2-2. 로컬 5회 (부하 없음, `1e90b97`, 6코어 PC)

| 회 | 측정값 5개 (초) | 최소 | `checks=` | 시간 |
|---|---|---|---|---|
| 1 | 4.732, 4.662, 5.165, 4.745, 5.024 | 4.662 | `checks=16 failures=[]` | 67초 |
| 2 | 4.628, 4.708, 4.802, 4.82, 5.019 | 4.628 | `checks=16 failures=[]` | 67초 |
| 3 | 4.738, 4.685, 4.781, 4.915, 5.06 | 4.685 | `checks=16 failures=[]` | 67초 |
| 4 | 4.658, 4.676, 4.943, 4.777, 5.101 | 4.658 | `checks=16 failures=[]` | 67초 |
| 5 | 4.931, 4.922, 5.49, 4.731, 5.771 | 4.731 | `checks=16 failures=[]` | 74초 |

로컬 프레임 속도: 첫 컷인 약 182프레임 / 4.73초 → 약 38fps.

### 2-3. 로컬 부하 5회 (`yes > /dev/null` 6개 = 코어 수, 끝난 뒤 모두 종료 확인 `yes left: 0`)

| 회 | 측정값 5개 (초) | 최소 | `checks=` | 시간 |
|---|---|---|---|---|
| 1 | 6.268, 5.465, 7.055, 7.62, 8.553 | 5.465 | `checks=16 failures=[]` | 111초 |
| 2 | 5.566, 5.988, 5.824, 5.196, 6.681 | 5.196 | `checks=16 failures=[]` | 89초 |
| 3 | 5.65, 5.781, 6.155, 6.09, 7.362 | 5.65 | `checks=16 failures=[]` | 92초 |
| 4 | 5.76, 5.564, 6.801, 6.663, 6.076 | 5.564 | `checks=16 failures=[]` | 98초 |
| 5 | 7.093, 6.312, 7.589, 5.698, 6.31 | 5.698 | `checks=16 failures=[]` | 92초 |

- [사실] 부하를 주면 측정값은 **길어졌고**(최소 4.63 → 5.20) 3.95 아래로 내려간 적 없음. 프레임 속도는 약 15fps(첫 컷인 96프레임 / 6.27초).
- 2-5: `git diff` 빈 출력(수정 0). 이 보고서 외 새 파일 없음.

## 3. 판정

| 가설 | 증거 | 판정 | 고치는 방향 후보 |
|---|---|---|---|
| A. 러너가 느려 프레임이 거칠어져 측정값이 짧게 나옴 | 1-1: 실패 run이 가장 빠른 프레임(69~102fps), 통과 run 29~47fps. 1-2: 실패 run의 step 9가 약 18% 빨랐음. 2-3: 부하를 주면 오히려 길어짐 | **아님**(방향이 반대: 빠를수록 짧게 나옴) | 해당 없음. "오차를 넉넉히"는 원인을 덮을 뿐이라 추천하지 않음 |
| B. 측정·스케줄 구조의 어긋남 | 2-1: 측정 시작이 한 프레임 늦음, 트윈이 만든 프레임의 delta를 바로 받음, 끝 조건의 "다음 이벤트 기다림"이 느린 러너에서만 여유를 만듦. 1-1: fps가 높을수록 최솟값이 3.95에 가까움(47fps 3.976, 69fps 3.934, 102fps 3.929) | **[추정] 맞음**(부족분 크기의 일부는 [미확인]). 사용자가 보는 실제 컷인이 짧은지는 [미확인]이지만, 부족분은 최대 약 0.07초(4.01 기준 2% 이내) | **추천:** 테스트의 시작 시각을 `hud.cutin_started_msec`(HUD 154행, 컷인을 켠 바로 그 호출)로 바꾸고 끝은 지금처럼 관찰. 이유: 스케줄과 같은 지점에서 재서 한 프레임 늦은 시작이 없어지고 기준 4.0 − 0.05를 그대로 둘 수 있음. 다른 후보: 실제 시간 대신 트윈 스케줄 값(`full_video_duration / _playback_speed × Engine.time_scale` = 4.01)을 직접 검사하고 실제 시간 검사는 "1초대가 아님"(배속 보정 누락 잡기) 정도로 넓힘 |
| C. `1e90b97` 변경의 영향 | `1e90b97` 9경로: `WorldMap3D_Host_Test.tscn`, `scripts/worldmap/map3d/` 3파일(+uid), 3D 테스트 3개(+uid). 전투·컷인 코드와 이 테스트는 변경 0. 이 테스트는 월드맵·map3d를 읽지 않음. 같은 모양의 실패가 10-30 `26a12d4`(다른 가지)에도 있었고, `4b415cd`(11-02 02:40)도 3.976으로 기준에 0.026초 차이였음 | **아님** | 해당 없음 |

## 막힌 것

- 부족분(최대 약 0.07초) 중 한 프레임 몫을 넘는 부분의 원인 — 컷인을 켠 프레임의 로드 시간인지 — 은 출력이 없어 [미확인]. 확인하려면 테스트에 `hud.cutin_started_msec`와 관찰 시작 시각의 차이를 찍는 임시 출력이 필요하나, 수정 금지라 하지 않음.
- GitHub 러너의 fps가 왜 run마다 3배까지 다른지(러너 기종 차이 등)는 [미확인].

## 종료 루틴

1. 정본: 가지 `feature/wm3d-intake-20261101`, 조사 시작 HEAD `bd34b30`, 이 보고서 커밋 뒤 `git status --short` 빈 출력. 코드·테스트·워크플로 수정 0.
2. 새로 만든 것: 이 보고서 1개. 로그는 scratchpad의 `s0_a1_raw.log`·`s0_a2_raw.log`·`s0_prev_raw.log`·`s0local/`·`cutin/`(정본 밖).
3. push한 것: 이 보고서 커밋 1개(`[skip ci]`).
4. CI: `[skip ci]`라 없음. 참고: `1e90b97`의 C-track run `41447864206`은 attempt 1·2 모두 shard 0 컷인 검사로 failure, `Verify WorldMap3D`는 success.
5. 김작이 결정할 것: 컷인 테스트를 고칠지·어느 방향(추천: 측정 시작을 `hud.cutin_started_msec`로)으로 고칠지. 그때까지 `1e90b97` 이후 커밋의 C-track은 빠른 러너가 걸리면 같은 이유로 실패할 수 있음[추정].
