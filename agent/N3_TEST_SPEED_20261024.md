# N3 느린 테스트 프로파일링 (2026-10-24)

- 지시: `NIGHT4_QUEUE_20261023.md` N3. **읽기와 측정만, 고치지 않는다.**
- 기준 `ba058c8a8e09f955230b5d48dd97e9de09074637`, 브랜치 `feature/night4-n3-test-speed-20261024`, 커밋 1개(이 문서만). 푸시는 `NIGHT4_SUMMARY` 참고.
- 코드 변경 0. 측정 러너는 커밋하지 않았다(zip `evidence/n3/time_tests.py`).
- 합격 판정은 하지 않는다.

## A. 측정 (Windows, 단독 실행, 이번 밤)

- 방법:
  - 기준 커밋의 분리 워크트리에서 import를 한 번 한 뒤 테스트 12개를 하나씩 돌렸다(`godot --headless --path . --script …`, CI와 같은 명령, `--fixed-fps` 없음).
  - 출력 줄마다 프로세스 시작부터의 초를 붙였다(원문 zip `evidence/n3/runs/*.log`).
  - 실행 뒤 워크트리 `git status`는 비어 있었다.
- 상위 10개는 마지막 전체 CI 실행(밤샘 ③ 끝, 144개)의 시간 순위에서 골랐다. 두 개(`skill_equivalence_shard_2`, `auto_hold_1x_seed_1`)는 경계 확인용으로 더 돌렸다.
- CI 전체 테스트 합계: 지난 전체 실행 기준 144개 3013초. 그 실행에서 아래 10개의 합은 약 625초(약 21%)다.

| 순위 | 테스트 | 이번 측정 | 지난 전체 CI | 반복 단위 | 단위당(로그 ms 또는 줄 시각 차) |
|---|---|---|---|---|---|
| 1 | `test_battle3d_skill_equivalence_shard_1` | 70.7초 | 67.3초 | 특기 케이스 10개(엔진 단독 1회 + 3D 1회) | 5.8~12.4초, 대부분 5.9~6.4초(케이스 줄 간격) |
| 2 | `test_battle_setup_port_base_parity_shard_1` | 67.7초 | 63.5초 | 시드 3개, 엔진 단독 자동 끝까지(4배속) | 21.9 / 21.9 / 22.0초(`ms=`) |
| 3 | `test_battle_setup_port_base_parity_shard_2` | 67.6초 | 63.9초 | 시드 3개 | 22.5 / 21.5 / 21.6초 |
| 4 | `test_battle_enemy_strategy_base_parity_shard_2` | 67.5초 | 66.1초 | 전투 3개(시드 1~3), 1배속 | 약 21.8초씩(케이스 줄 간격) |
| 5 | `test_battle_enemy_strategy_base_parity_shard_3` | 67.3초 | 66.2초 | 전투 3개(시드 4~6) | 약 21.7초씩 |
| 6 | `test_battle_tactic_skill_semantics_shard_1` | 63.7초 | 61.6초 | 엔진 단독 케이스 20개 | 약 3~6초(케이스 줄 간격, 예: 5.1 → 8.1 → 13.8초) |
| 7 | `test_battle3d_auto_speed` | 63.3초 | 62.5초 | 3D 자동 3회(1x/2x/4x, 3라운드 시작까지) | 33.0 / 17.2 / 9.8초(`ms=`) |
| 8 | `test_battle3d_skill_equivalence_shard_4` | 62.2초 | 57.9초 | 케이스 9개 | 6.3~8.6초 |
| 9 | `test_battle_tactic_skill_semantics_shard_2` | 61.4초 | 59.3초 | 케이스 19개 | — |
| 10 | `test_battle3d_skill_equivalence_shard_3` | 61.3초 | 56.3초 | 케이스 9개 | 6.2~7.5초 |
| (참고) | `test_battle3d_skill_equivalence_shard_2` | 59.4초 | 55.2초 | 케이스 9개 | 6.1~6.4초 |
| (참고) | `test_battle3d_auto_hold_1x_seed_1` | 54.7초 | 53.7초 | 3D 자동 1배속 1회 | 52.6초(`ms=`) |

측정에서 확인한 사실:
1. **반복 단위 시간이 거의 일정하다.** 같은 테스트 안에서 케이스·시드마다 차이가 작다(셋업 포트 21.5~22.5초, 적 책략 21.7~21.8초, 특기 동등성 대부분 5.9~6.4초). 시간은 "반복 횟수 × 한 번의 연출 시간"으로 정해진다.
2. **배속이 시간을 거의 그대로 나눈다.** `auto_speed`의 1x 33.0초 → 2x 17.2초 → 4x 9.8초. 고정 비용은 약 2초 정도로 보인다(4x가 33/4 = 8.3보다 1.5초 길다).
3. **적 책략 동등성(4·5위)은 1배속이다.** 같은 크기의 셋업 포트 동등성(2·3위)은 4배속으로 끝까지 가는데도 걸리는 시간이 비슷하다. 적 책략 동등성은 아군 행동 10번까지만 하지만 1배속이다(아래 B §2).
4. 프로세스 시작부터 첫 케이스 결과까지 약 2.5~3초(엔진 시작, import 캐시 읽기, 하니스 생성)다. 특기 동등성 첫 케이스 줄이 8.7~9.4초인데, 케이스 하나가 약 6.3초이므로 그렇다.
5. 이번 측정은 지난 전체 CI보다 테스트마다 0.6~5초 길었다. 같은 PC이고, 다른 작업은 같이 돌리지 않았다. 원인은 따로 보지 않았다.
6. **Linux(클코치 측정)에서 셋업 포트 약 100초, 특기 동등성 1번 약 106초**는 Windows의 약 1.5배다. 반복 단위가 실제 초(연출 타이머)로 정해지는 구조라면 Linux가 더 느릴 이유는 프레임 처리 비용 쪽이다. 확인은 못 했다(아래 C).

## B. 줄일 후보와 위험 (고치지 않음, 후보만)

효과가 클 것으로 보는 순서다. 근거는 A의 측정과 아래 정적 분석이다.

| # | 후보 | 대상 | 기대 효과(추정) | 동작이 달라질 위험 |
|---|---|---|---|---|
| 1 | 적 책략 동등성을 4배속으로 | 4·5위 | 전투당 약 22초 → 6~8초(`auto_speed`의 배속 비율 기준) | 기준(골든)을 1배속으로 기록했다. 4배속에서 같은 기록이 나오는지 아직 증명 안 됨. 같은 프레임에 끝나는 타이머 순서가 바뀌면 난수 소비 순서가 바뀔 수 있다 |
| 2 | CI 명령에 `--fixed-fps` | 전부 | 연출이 실제 초가 아니라 프레임 수로 끝나 헤드리스에서 빨라짐(크기 미측정) | 프레임당 시간이 바뀌어 30프레임 안정 창이 덮는 시뮬레이션 시간이 바뀜. 3D hold/래치 해제가 프레임 단위(F2·F3 이력). NIGHT3 G-테스트는 `--fixed-fps 60`에서도 통과했다(이전 보고서) |
| 3 | 셋업 포트 동등성을 8~16배속으로 | 2·3위 | 시드당 22초 → 5~11초 | 타이머·Tween이 같은 프레임에 끝나면 순서와 난수가 바뀔 수 있음. 다이제스트 비교라 달라지면 바로 실패로 드러남 |
| 4 | 특기 동등성의 엔진 단독 기준을 골든으로 저장 | 1·8·10위 등 | 케이스당 엔진 단독 1회(약 절반) 절약 | 같은 코드에서 "엔진 단독 = 3D"를 동시에 증명하던 것이 "골든 = 3D"로 바뀜. 엔진이 바뀌면 골든 재기록이 필요 |
| 5 | 고정 대기를 상태 대기로 | 전술 의미 테스트(teardown 10프레임 + 0.1초) 등 | 작음(정적 분석 추정 5~10%) | 남은 타이머가 해제된 노드에 닿을 수 있음 |
| 6 | 샤드 더 나누기 | 전부 | **CI 전체 시간은 그대로**(CI가 파일을 하나씩 순서대로 돌림). 파일당 120초 여유만 늘어남 | 낮음 |

## C. 확인 못 한 것

- 후보 1~3을 실제로 돌려 같은 결과가 나오는지 재지 않았다(고치지 않는다는 지시).
- `--fixed-fps`에서의 시간은 재지 않았다.
- Linux가 1.5배 느린 원인.
- 특기 케이스별 컷인 경로(영상 / 정지 이미지)와 그 시간.
- 장면 생성(`Battle_Main` instantiate) 1회 시간.

---

아래는 테스트 코드를 따라가며 시간 원인을 적은 정적 분석이다(코드 기준 추정, 위 A의 측정과 숫자가 맞는지는 A 표로 확인). 파일 경로의 `T/`는 `tests/scripts/`, `S/`는 `tests/scripts/support/`, `ENG`는 `scripts/battle_web_import_test.gd`다.

## D. 정적 분석: 가장 느린 CI 테스트 10개

- 기준: BASE `ba058c8a8e09f955230b5d48dd97e9de09074637` (읽기 전용 worktree `night4/base`)
- 방법: 코드만 읽었습니다. Godot는 실행하지 않았습니다.
- 경로 표기: `tests/scripts/` 아래는 `T/`, `tests/scripts/support/` 아래는 `S/`, 엔진 `scripts/battle_web_import_test.gd`는 `ENG`로 줄여 씁니다.
- **모든 시간 배분은 코드에서 추정한 값입니다.** 측정값이 아닙니다.

## 0. 공통 사실 (모든 테스트에 해당)

### 0.1 CI 실행 방식
- CI는 파일마다 `timeout 120s godot --headless --path . --script res://...` 하나씩 **순서대로** 실행합니다 (`.github/workflows/verify-c-track.yml:153`).
- `--fixed-fps`는 쓰지 않습니다. `project.godot`에 `max_fps`나 물리 tick 설정도 없습니다.
- 그래서 headless 프레임은 제한 없이 돌고, 매 프레임 `delta`는 실제 경과 시간입니다. Tween과 타이머는 **실제 초 단위**로 끝납니다.
- 결론: 엔진 연출 시간(초)은 CPU가 빨라도 줄지 않습니다. `Engine.time_scale`이나 `--fixed-fps`로만 줄일 수 있습니다.
- job 전체 timeout은 35분입니다 (`verify-c-track.yml:15`). 테스트가 순서대로 돌기 때문에 **샤드를 더 나눠도 CI 전체 시간은 줄지 않습니다.** 파일당 120초 여유만 늘어납니다.

### 0.2 전투 1회 준비 비용 (Battle_Main)
- 엔진 전용(bare) 경로: `S/battle3d_enemy_turn_harness.gd:75-81` `open_bare` → `scripts/battle3d/battle3d_engine_host.gd:14`에서 `Battle_Main.tscn`을 instantiate합니다. `Battle_Production.tscn`은 233 KB입니다.
- 이어서 `battle3d_engine_host.gd:16-21`이 1프레임 뒤 intro를 건너뛰고, `current_phase == "ally_turn"`이 될 때까지 프레임마다 기다립니다. 그 뒤 `open_bare`가 1프레임을 더 기다립니다.
- 닫기: `S/battle3d_enemy_turn_harness.gd:83-87` `close_bare`는 free 후 1프레임을 기다립니다.
- 3D 경로: `S/battle3d_skill_harness.gd:43-50` `open_lab`가 `Battle3D_EnginePlayLab.tscn`을 instantiate합니다. lab의 기본 host를 free하고 spy host를 새로 만들기 때문에 Battle_Main도 다시 instantiate됩니다.
- lab `_ready` 비용 (`scripts/battle3d/lab_presentation.gd`):
  - `:27` 매번 `../EASTWAR_C0C3_Evidence/runtime_events.jsonl`을 WRITE로 엽니다 (디스크 IO).
  - `:30` `battlefield.glb`를 instantiate합니다.
  - `:32`, `:76` Terrain/Ford 메시에 `create_trimesh_collision()`를 호출합니다. **lab을 열 때마다** 실행됩니다.
  - `:104-108` 유닛마다 soldier glb 6개를 만듭니다. 10유닛이면 60개입니다.
  - `scripts/battle3d/battle3d_engine_play.gd:138-158` 유닛 badge와 UI를 만들고 `host.initialized`를 기다립니다.
- lab 닫기: `S/battle3d_engine_attack_harness.gd:34-39` free 후 1프레임을 기다립니다.

### 0.3 oracle 경로 teardown
- `S/battle_enemy_turn_oracle_harness.gd:213-215` `_teardown`: **고정 10프레임 + `create_timer(.1)`** 을 기다립니다. tactic semantics와 enemy strategy parity가 케이스마다 이 비용을 냅니다.

### 0.4 settle 창 (30 안정 프레임)
- `S/battle3d_wait_harness.gd:50-56` `settle_bare`: 최대 4000프레임, **30프레임 연속 안정**이면 끝납니다.
- `S/battle3d_wait_harness.gd:58-66` `settle_lab`: 같은 30프레임 창입니다. 매 프레임 `_observe_frame`과 probe를 부릅니다.
- `S/battle_tactic_oracle_harness.gd:86-94` `settle`: 30프레임 창입니다. 한도는 프레임이 아니라 **벽시계 30초** (`Time.get_ticks_msec`)입니다.
- `S/battle_enemy_strategy_oracle_harness.gd:59-67` `settle_enemy`: 30프레임 창, 최대 3000프레임입니다.
- 30프레임 비용은 프레임 시간 × 30입니다. 프레임이 3~10 ms라면 0.1~0.3초입니다 (추정).

### 0.5 엔진 연출 타이머 (실제 초)
- 수동 대상 특기 미리보기: `ENG:3729` 0.42초 (`ENG:52`).
- 자동 해결 특기 미리보기: `ENG:4706` 0.42초 (`ENG:51`).
- 특기 연출 (`ENG:4761-4779`):
  - 정적 toast 경로: 효과 적용 0.47초 (`ENG:183`) 뒤, 총 1.22초에 마무리 (`ENG:184-185`).
  - specialty 영상 컷인 경로: 1.38초 뒤 적용, 총 2.13초 (`ENG:303`, `ENG:4766-4767`).
  - registry 영상 경로: `ENG:4843` 영상 신호가 없으면 **4.6초 fallback** (`ENG:53`).
- 화살/총병 연출은 `randf_range`로 길이를 정합니다 (`ENG:10928-10929`, `ENG:11028`).
- 엔진 안에 `await get_tree().process_frame`은 0개입니다. 엔진 진행은 타이머와 Tween으로만 움직입니다.
- 타이머 체인은 고리마다 최대 1프레임 늦게 이어집니다. 그래서 프레임이 느린 머신에서는 시간이 조금 더 듭니다. Linux가 Windows보다 1.5~1.6배 느린 이유의 일부일 수 있습니다 (확인 못 함).

### 0.6 RNG
- 엔진의 `randf/randi` 호출은 31곳입니다. 모두 행동이나 이펙트가 생길 때 호출됩니다. 엔진 `_process`(`ENG:2244-2251`)에는 RNG가 없습니다.
- 그래서 RNG 소비 횟수는 프레임 수가 아니라 이벤트 수에 묶여 있습니다 (코드 근거).
- 하지만 같은 프레임에서 타이머 둘이 끝나면 콜백 순서가 바뀔 수 있습니다. 화살 연출 길이는 RNG 값에 따라 달라집니다. 그래서 `time_scale`을 올리거나 프레임 간격을 바꾸면 이론상 순서 위험이 있습니다.
- 정황 증거: setup_port의 BASE digest(`tests/golden/battle_setup_port_base_v0.json`)는 Windows와 Linux 양쪽에서 4x로 통과합니다. 두 환경의 프레임 속도가 다른데도 통과하므로, 4x에서는 프레임 속도에 의존하지 않는다는 근거가 됩니다. `test_battle3d_auto_speed.gd`도 1x/2x/4x에서 2·3라운드 시작이 같은지 확인합니다.

### 0.7 harness 생성 비용 (프로세스당 한 번)
- `S/battle3d_engine_attack_harness.gd:7`: harness를 `.new()`할 때 `battle_attack_baseline_v0.json`(1.48 MB)을 파싱합니다. **skill_equivalence, auto_speed, setup_port는 이 golden을 쓰지 않습니다.** 이 harness 체인을 상속해서 함께 로드될 뿐입니다.
- `S/battle3d_enemy_turn_harness.gd:12` `EnemyOracle.new()`, `S/battle3d_skill_harness.gd:15` `TacticOracle.new()`도 생성합니다.
- `S/battle_tactic_oracle_harness.gd:34-42` `skill_for_effect`와 `skill_by_id`는 호출할 때마다 `hero_unique_skills.json`(17 KB)을 다시 파싱합니다. 비용은 작습니다.

---

## 1. test_battle3d_skill_equivalence_shard_1.gd (Windows 67.3초, checks 2946)

### 구조
- `T/test_battle3d_skill_equivalence_shard_1.gd:4` → `slice(0,10)`, **케이스 10개**입니다. 다른 샤드는 9개입니다 (shard_2 `slice(10,19)`, shard_3 `slice(19,28)`, shard_4 `slice(28,37)`).
- 상속: `T/test_battle3d_skill_equivalence.gd:1` → `T/test_battle3d_enemy_turn_equivalence.gd` (SceneTree).
- harness 체인: `S/battle3d_skill_harness.gd` → `strategy` → `defend` → `wait` → `enemy_turn` → `engine_attack` → `battle_attack_oracle`.
- 케이스: `K_adjacent_aoe` … `K_encirclement_debuff`, 즉 effect_type 순서의 앞 10개입니다 (`S/battle_tactic_oracle_harness.gd:12-19`).

### 케이스당 흐름 (`T/test_battle3d_skill_equivalence.gd:52-76`)
1. `:54` `run_skill_direct` (`S/battle3d_skill_harness.gd:94-109`): 엔진 전용 기준 실행입니다.
   - `open_bare`(Battle_Main 1회) → fixture → 1프레임 → 특기 명령 → `settle_bare`(`:104`) → `close_bare`.
2. `:55` `run_skill_3d` (`S/battle3d_skill_harness.gd:131-161`): 3D 실행입니다.
   - `open_lab`(lab + Battle_Main 1회) → fixture → 1프레임 → 클릭/버튼 → `settle_lab(..., skill_display_probe)`(`:154`) → 1프레임 → `final_state`.
3. `:66` `close_lab`를 부릅니다.
4. 실제 전투 진행: 아군 특기 1회 → 남은 적 `units[5]`의 슬롯 1회 → 라운드 전환 → ally_turn 순서입니다. 같은 진행을 **엔진 전용 1회, 3D 1회** 합니다.

### 프레임마다 하는 일 (3D)
- `S/battle3d_enemy_turn_harness.gd:216-222` `_observe_frame`: lab 자식 노드를 전부 훑고, 프레임 기록 dict를 하나 추가합니다.
- `S/battle3d_skill_harness.gd:111-129` `skill_display_probe`: 자식 노드를 다시 훑고 `lab._sync_views()`를 부릅니다(`:116`). 이어서 `strategy_display_probe`(`S/battle3d_strategy_harness.gd:89-105`)가 바쁘지 않으면 `_sync_views()`를 **한 번 더** 부릅니다(`:96`).
- 그래서 3D 경로는 프레임당 GDScript 비용이 bare 경로보다 큽니다. 30프레임 창도 더 오래 걸립니다.

### 고정 대기
- settle 창 30프레임 × 2 (bare, 3D).
- open/close 사이 1프레임 대기가 여러 번 (`open_bare`, `close_bare`, `close_lab`, `run_skill_*` 안의 `await tree.process_frame`).
- 고정 N프레임 루프는 없습니다.

### 시간 배분 추정 (코드 기준)
- 67.3초 / 10케이스 = **케이스당 약 6.7초**입니다.
- 경로당 내역 (추정):
  - Battle_Main instantiate + intro 대기: 0.3~0.8초 (확인 못 함).
  - 특기 미리보기 0.42초 (자동 해결 모드도 0.42초) + 특기 연출 1.22초 또는 2.13초. registry 영상이면 최대 4.6초.
  - 적 슬롯 1회 (이동/공격 Tween): 약 1~2초 (추정).
  - 30프레임 창: 0.1~0.3초.
- 3D 경로는 여기에 lab `_ready`(glb, trimesh collision, soldier 60개)와 프레임당 probe 비용이 더해집니다.
- 대략적인 비율: 엔진 전용 기준 실행 약 40~45%, 3D 실행 약 55~60%. 그 안에서 엔진 연출 실제 초가 가장 큰 덩어리입니다 (추정 50~65%). 다음이 scene instantiate입니다 (추정 15~25%).
- shard_1이 가장 느린 이유는 케이스가 10개이기 때문입니다 (나머지는 9개). 케이스당 시간은 비슷합니다 (shard_3 6.3초, shard_4 6.4초).

### 줄일 후보
- 엔진 전용 기준 실행을 golden으로 캐시 (위험 아래 표 참고).
- `Engine.time_scale` 올리기 (3D와 엔진 전용 양쪽 모두에 적용).
- `--fixed-fps`.
- 샤드 균형: 37케이스를 9/9/9/10이 아니라 5샤드로 나누기. 파일당 여유만 늘고 CI 전체 시간은 그대로입니다.
- probe에서 `_sync_views()`가 두 번 불리는 것을 한 번으로 줄이기 (효과는 작음).
- 이 테스트가 쓰지 않는 1.48 MB golden 파싱(`S/battle3d_engine_attack_harness.gd:7`)을 늦게 로드하기 (프로세스당 1회, 효과는 작음).

---

## 2. test_battle_enemy_strategy_base_parity_shard_3.gd (66.2초, checks 4)
## 3. test_battle_enemy_strategy_base_parity_shard_2.gd (66.1초, checks 4)

두 샤드는 구조가 같아서 함께 씁니다.

### 구조
- `T/test_battle_enemy_strategy_base_parity.gd:11-14` 라벨은 23개입니다 (전략 시나리오 17개 + `BATTLE_seed_1..6`).
- shard_2는 `slice(17,20)` = **BATTLE_seed_1, 2, 3**입니다. shard_3은 `slice(20,23)` = **BATTLE_seed_4, 5, 6**입니다. shard_1은 시나리오 17개입니다 (`slice(0,17)`).
- 그래서 shard_2와 shard_3은 **전투 3회씩**만 합니다. checks가 4인 이유입니다. 비교는 케이스별이 아니라 마지막에 golden 하나로 합니다 (`:58-66`).

### 전투 1회 흐름 (`S/battle_enemy_strategy_oracle_harness.gd:140-167`)
- `:144` `_new_battle` (`:45-52`): Battle_Main을 instantiate하고 1프레임 뒤 intro를 건너뜁니다.
- `:146` 아군이 idle이 될 때까지 최대 600프레임 기다립니다 (조건이 맞으면 바로 빠짐).
- `:150` `seed(seed_value)`.
- `:152-163` **아군 행동 10회** (`BATTLE_ALLY_ACTIONS`, `:25`). 매번 `_run_auto_action_for_active_ally_once`(`:157`)를 부르고, `settle_enemy`(`:162`, 30프레임 창)로 엔진이 돌리는 적 슬롯까지 기다립니다.
- `:166` `_teardown`: 10프레임 + 0.1초.
- **`Engine.time_scale`을 바꾸지 않습니다. 1x 실제 시간으로 돕니다.** golden도 BASE에서 1x로 기록했습니다 (`:39` repeat, `--update-golden`).
- 엔진 전용 실행 3회, 3D 실행 0회입니다. 기준값은 이미 golden입니다 (`tests/golden/battle_enemy_strategy_base_v0.json`, 2.0 MB).

### 끝부분 비용
- `:61` 2.0 MB golden을 파싱합니다.
- `:63` 케이스 필터 → `:65` `JSON.parse_string(JSON.stringify(captured))` 왕복 → `fingerprint.diff`. 1초 미만으로 추정합니다.

### 시간 배분 추정
- 66초 / 3전투 = **전투당 약 22초**입니다.
- 전투당: 아군 행동 10회 + 적 슬롯 약 10회 (교대) + 라운드 전환 2~3회를 1x로 진행합니다. 행동 하나에 약 1~2초입니다 (공격/이동 Tween, 화살 연출, 특기 연출 1.2~2.1초).
- 30프레임 창 10회 ≈ 1~3초 (추정).
- Battle_Main + intro + teardown ≈ 1초 (추정).
- **엔진 연출 실제 초가 약 85~90%**입니다 (추정).

### 줄일 후보
- `Engine.time_scale = 4` (setup_port처럼). 가장 효과가 큽니다. 위험은 golden을 1x로 기록했다는 점입니다.
- `--fixed-fps`.
- 샤드 나누기 (전투당 1파일). 파일당 여유만 생깁니다.

---

## 4. test_battle_setup_port_base_parity_shard_2.gd (63.9초, checks 36)
## 5. test_battle_setup_port_base_parity_shard_1.gd (63.5초, checks 36)

### 구조
- shard_1은 seeds `[1,2,3]`, shard_2는 `[4,5,6]`입니다 (각 샤드 파일 `:4`).
- `T/test_battle_setup_port_base_parity.gd:97-111`: seed마다 `run_auto_direct(self, seed, 4.0)`(`:100`)를 부르고 digest를 golden과 비교합니다.
- golden은 4.6 KB짜리 digest입니다 (`:95`). 엔진 전용 기준은 **이미 golden으로 캐시되어 있습니다**.
- harness: `S/battle_setup_s43_harness.gd` → `S/battle3d_auto_harness.gd` → skill … → engine_attack. 그래서 1.48 MB attack golden 파싱(0.7절)도 함께 일어납니다.

### 전투 1회 흐름 (`S/battle3d_auto_harness.gd:65-80`)
- `open_bare`: Battle_Main 1회.
- `Engine.time_scale = 4.0`(`:69`) → `seed` → `_toggle_full_auto_battle` → 결과가 나올 때까지 최대 60000프레임 기다립니다 (`:72-74`).
- **끝난 뒤 고정 60프레임**을 기다립니다 (`:75-76`).
- `close_bare`.
- **전체 자동전투 끝까지, 4x, 엔진 전용 3회**입니다. 3D 실행은 없습니다.
- 자동전투 단계 상한: 80~200 (`ENG:130-132`).
- 매 라운드 시작마다 spy가 `randf()`를 1회 소비하며 snapshot을 찍습니다 (`S/battle3d_auto_harness.gd:19-23`). golden이 같은 지점에서 기록되었기 때문에 결과는 같습니다.

### 시간 배분 추정
- 63.5초 / 3 = **seed당 약 21초**입니다. 4x 기준이므로 1x 게임 시간으로는 약 80초 분량입니다 (추정).
- 고정 60프레임 ≈ 0.2~0.6초, Battle_Main ≈ 0.5~1초 (추정).
- **엔진 연출 시간(4x로 줄인 뒤)이 약 90%**입니다 (추정).
- Linux에서 약 100초인 것은 Windows보다 1.6배 느린 것입니다. 순수 실제 초라면 OS와 상관없이 같아야 합니다. 그래서 프레임마다 생기는 지연(0.5절, 타이머 체인)이나 CPU 비용이 적지 않다고 봅니다 (확인 못 함).

### 줄일 후보
- `time_scale`을 8x나 16x로 올리기. 이 테스트는 digest를 비교하므로, 올렸을 때 통과하면 바로 검증이 됩니다.
- `--fixed-fps`.
- 끝난 뒤 60프레임을 상태 기반 대기로 바꾸기 (효과는 작음).
- 샤드 3개로 나누기 (seed 2개씩).

---

## 6. test_battle3d_auto_speed.gd (62.5초, checks 20)

### 구조 (`T/test_battle3d_auto_speed.gd`)
- `:15-28`: lab을 한 번 열고 속도 버튼 순환과 닫기 복원을 확인합니다. 전투는 하지 않습니다.
- `:31-38`: `run_auto_3d(self, 1, presses, 3)` **3회**를 1x, 2x, 4x로 실행합니다. 매번 `close_lab`을 합니다.
- `S/battle3d_auto_harness.gd:96-123` `run_auto_3d`: `open_lab` → 속도 버튼 → seed → 자동 시작 → 프레임마다 `_observe_frame` + `auto_display_probe`. **3라운드 snapshot이 생기면 바로 멈춥니다** (`:111`, stop_round > 0이면 3D 재생이 끝나기를 기다리지 않음). stop_round > 0이므로 끝 60프레임 대기는 없습니다.
- 3D 실행 3회, 엔진 전용 실행 0회입니다. 1x 실행 자체가 기준입니다.
- 엔진 속도는 3D가 정합니다. lab이 연출하는 동안 hold를 걸고 (`scripts/battle3d/battle3d_engine_play.gd:1415-1435`), 엔진은 hold 동안 자동 tick을 하지 않습니다 (`ENG:13897`). F2 latch가 매 단계 hold를 다시 겁니다 (`ENG:13929`, `ENG:1606-1614`). 그래서 진행 속도는 lab 재생 속도(`presentation_speed` 8칸/초, `enemy_hold_seconds` 0.35초)와 엔진 연출 속도로 정해집니다.

### 시간 배분 추정
- 1, 2라운드를 완전히 진행하는 데 1x 게임 시간 T가 걸린다고 두겠습니다. 그러면 1x + 2x + 4x ≈ 1.75T + 오버헤드 3회입니다.
- 오버헤드는 lab + Battle_Main 열기/닫기, 회당 약 1~2초로 추정합니다. 처음 버튼 확인 단계도 약 1~2초입니다.
- 62.5초에서 역산하면 T ≈ 32~34초입니다. **1x ≈ 33초(약 53%), 2x ≈ 17초(약 27%), 4x ≈ 9초(약 14%), 나머지 약 6%**입니다 (추정).
- 고정 프레임 대기는 거의 없습니다. 시간은 3D 재생 속도에 묶여 있습니다.

### 줄일 후보
- `--fixed-fps`: 1x 실행도 CPU 속도로 돌게 됩니다.
- stop_round를 3에서 2로 낮추기: 약 절반이 됩니다. 대신 커버리지가 줄어듭니다 (2라운드 전체 진행과 3라운드 시작 비교가 빠짐).
- 1x 기준을 엔진 전용 golden으로 바꾸는 것은 맞지 않습니다. 이 테스트가 증명하려는 것은 "3D에서 속도를 바꿔도 같다"입니다.

---

## 7. test_battle_tactic_skill_semantics_shard_1.gd (61.6초, checks 664)
## 8. test_battle_tactic_skill_semantics_shard_2.gd (59.3초, checks 603)

### 구조
- `T/test_battle_tactic_skill_semantics.gd:8-12` 라벨은 39개입니다 (`K_` + effect_type 36개, `K_ally_auto_skill`, `K_enemy_auto_skill`, `K_advance_on_kill`).
- shard_1은 `slice(0,20)` = 20개, shard_2는 `slice(20)` = 19개입니다.
- 상속: SceneTree 하나뿐입니다. harness는 `S/battle_tactic_oracle_harness.gd` → `S/battle_enemy_turn_oracle_harness.gd`이고, observer battle은 `S/battle_tactic_observer_battle.gd`입니다.
- **엔진 전용 실행만 합니다.** 3D도, golden도 없습니다. 의미 검사만 합니다.

### 케이스당 흐름 (`S/battle_tactic_oracle_harness.gd:96-176`)
- `:97-102` Battle_Main instantiate → 1프레임 → intro 건너뛰기.
- `:127-157` fixture.
- `:161` 1프레임.
- `:164` `_act`: 특기 버튼 → 대상 선택 (`:208-215`).
- `:166` `settle`: 30프레임 창, 벽시계 30초 한도.
- `:175` `_teardown`: 10프레임 + 0.1초.
- 실제 진행: 특기 1회(미리보기 0.42초 + 연출 1.22~2.13초) → 적 `units[5]` 슬롯 → 라운드 전환. 3D 테스트의 "엔진 전용" 절반과 거의 같은 내용입니다.
- shard_2에는 `K_enemy_auto_skill`(적 guan_yu 특기, 영상 경로일 수 있음)과 `K_advance_on_kill`이 들어 있습니다.

### 시간 배분 추정
- 61.6 / 20 ≈ 3.1초, 59.3 / 19 ≈ 3.1초입니다. **케이스당 약 3.1초**입니다.
- 엔진 연출 실제 초 약 2~2.5초 (65~80%), Battle_Main + intro 약 0.3~0.6초, settle 창 + teardown(10프레임 + 0.1초) 약 0.2~0.4초입니다 (추정).
- 이 테스트의 케이스당 시간은 skill_equivalence의 "엔진 전용" 절반과 비슷할 것으로 봅니다. 이는 skill_equivalence에서 엔진 전용 쪽을 약 3초로 잡은 추정과 맞습니다.

### 줄일 후보
- `time_scale` 올리기 / `--fixed-fps`.
- teardown 10프레임 + 0.1초를 상태 기반으로 바꾸기 (케이스당 약 0.15~0.2초, 약 5%).
- skill_equivalence와 겹치는 부분 정리: 같은 36개 effect_type을 엔진 전용으로 두 테스트가 각각 돌립니다 (skill_equivalence의 direct 경로, 이 테스트). 다만 검사하는 내용은 다릅니다 (write 순서/상태 동등 vs 이벤트 의미). 그래서 한 실행 결과를 두 검사에 함께 쓰는 방법은 구조를 바꿔야 합니다.

---

## 9. test_battle3d_skill_equivalence_shard_4.gd (57.9초, checks 2429)
## 10. test_battle3d_skill_equivalence_shard_3.gd (56.3초, checks 2445)

- 구조는 1절과 같습니다. 각각 **케이스 9개**입니다.
- shard_3 = `slice(19,28)`: `K_rally_restore` … `K_team_buff`. `K_rally_restore`와 `K_retreat_counter`는 fixture 분기가 있습니다 (`S/battle3d_skill_harness.gd:74-81`).
- shard_4 = `slice(28,37)`: `K_team_command` … `K_trap_aoe` + **`X_enemy_skill_in_slot`**. X 케이스는 적이 guan_yu 특기를 씁니다 (`:70-73`). registry 영상 경로라면 최대 4.6초 fallback을 탈 수 있습니다 (`ENG:4843`).
- 케이스당 시간: 57.9/9 ≈ 6.4초, 56.3/9 ≈ 6.3초. 시간 배분과 줄일 후보는 1절과 같습니다.

---

## 11. 요약 표

| test | 주요 시간 원인 | 추정 비중 | 줄일 후보 | 위험 |
|---|---|---|---|---|
| skill_equivalence_shard_1 | 10케이스 × (엔진 전용 1회 + 3D 1회). 특기 연출 실제 초(0.42 + 1.22~2.13초), 적 슬롯 1회, lab/Battle_Main instantiate 2회 | 연출 50~65%, instantiate 15~25%, settle/프레임 probe 10~20% | direct를 golden 캐시, time_scale↑, `--fixed-fps`, 5샤드 | golden 캐시: 동시 동등성 증명이 사라짐. time_scale/fps: 같은 프레임 콜백 순서 |
| enemy_strategy_parity_shard_3 | seed 4~6 전투 3회 × 아군 행동 10회, **1x** | 연출 85~90% | `time_scale = 4`, `--fixed-fps`, 전투당 1파일 | golden을 1x로 기록함. 4x에서 같은지 아직 증명 안 됨 |
| enemy_strategy_parity_shard_2 | seed 1~3, 위와 같음 | 같음 | 같음 | 같음 |
| setup_port_parity_shard_2 | seed 4~6 자동전투 끝까지 × 3, 4x 엔진 전용 | 연출(4x) ~90%, 끝 60프레임과 open/close ~10% | 8x/16x, `--fixed-fps`, 3샤드 | 프레임당 delta가 커져 타이머와 Tween이 같은 프레임에 끝나면 RNG와 순서가 바뀔 수 있음. digest 비교라 바로 검출됨 |
| setup_port_parity_shard_1 | seed 1~3, 위와 같음 | 같음 | 같음 | 같음 |
| auto_speed | 3D 자동 3회 (1x/2x/4x)로 3라운드 시작까지, 3D hold가 속도를 정함 | 1x ~53%, 2x ~27%, 4x ~14% | `--fixed-fps`, stop_round 3→2 | fps: hold/latch 해제 시점이 프레임 단위(F2). stop_round↓: 커버리지 감소 |
| tactic_skill_semantics_shard_1 | 20케이스 × Battle_Main + 특기 연출 + 적 슬롯, teardown 10프레임 + 0.1초 | 연출 65~80%, instantiate 10~20%, settle+teardown 5~10% | time_scale↑, `--fixed-fps`, teardown 상태 대기 | settle 창의 시뮬레이션 시간이 바뀜. teardown 단축 시 남은 타이머가 free된 노드에 닿음 |
| tactic_skill_semantics_shard_2 | 19케이스, 적 자동 특기 포함 | 같음 | 같음 | 같음 |
| skill_equivalence_shard_4 | 9케이스, `X_enemy_skill_in_slot` 영상 경로 가능 | shard_1과 같음 | shard_1과 같음 | shard_1과 같음 |
| skill_equivalence_shard_3 | 9케이스 | shard_1과 같음 | shard_1과 같음 | shard_1과 같음 |

## 12. 줄일 후보 상세와 위험

### A. `--fixed-fps N` (CI 명령줄에서만 바꿈)
- 효과: `delta`가 1/N초로 고정되고 실제 시간과 맞추지 않습니다. 연출 1초가 N프레임이 됩니다. 프레임이 빠르면 실제 시간이 크게 줄어듭니다. 10개 테스트 모두에 적용됩니다. 연출 비중이 큰 parity 계열에서 효과가 가장 클 것으로 봅니다.
- 위험:
  - 30프레임 settle 창이 시뮬레이션 시간 30/N초가 됩니다. 지금은 실제로 0.1~0.3초입니다. N=60이면 0.5초로 **더 길어집니다**. 그 사이에 끝나는 늦은 타이머가 snapshot 전에 실행될 수 있습니다. 1x로 기록한 golden(enemy_strategy의 `settled` checkpoint, `battle_log_lines`)과 달라질 수 있습니다.
  - 프레임 간격이 바뀌면 같은 프레임에서 끝나는 타이머와 Tween 쌍이 달라집니다 (0.6절). RNG 순서가 바뀔 수 있습니다.
  - auto 3D의 hold/latch는 lab `_process`에서 프레임마다 풀립니다. F2 버그는 "한 단계가 같은 프레임 안에서 끝나는" 경우였습니다. 프레임 간격이 바뀌면 이 경로가 나오는 빈도가 바뀝니다.
  - N이 작고 time_scale이 높으면 `_observe_frame`이 경로 칸을 건너뛸 수 있습니다. 그러면 "3D view passes path cells in order" 검사(`T/test_battle3d_enemy_turn_equivalence.gd:36-43`)가 실패할 수 있습니다. 8칸/초 × 4x / 60fps ≈ 프레임당 0.53칸이라 지금 조건에서는 괜찮습니다.
  - `S/battle_tactic_oracle_harness.gd:88`의 벽시계 30초 한도는 오히려 여유가 생깁니다.
  - `S/battle3d_wait_harness.gd`의 4000프레임 같은 프레임 한도는 시뮬레이션 시간 기준으로 바뀝니다 (60fps면 약 66초). 지금보다 여유가 늘어납니다.

### B. `Engine.time_scale` 올리기
- enemy_strategy parity: 1x → 4x. 전투당 약 22초에서 약 6~7초가 될 것으로 추정합니다.
- setup_port: 4x → 8x/16x.
- tactic semantics, skill_equivalence: 케이스마다 4x.
- 위험:
  - 프레임당 delta가 커집니다. 여러 타이머가 한 프레임에 끝나면 콜백 순서가 실제 시간 순서와 달라질 수 있습니다. 화살 연출 길이는 RNG 값이라 순서가 seed에 따라 달라집니다.
  - 4x까지는 증거가 있습니다 (setup_port golden이 Windows와 Linux에서 통과, auto_speed 1x/2x/4x 비교). 8x 이상과, 1x로 기록한 enemy_strategy golden에 대해서는 증거가 없습니다.
  - skill_equivalence의 3D 쪽은 hold/latch 경로를 지납니다. 특기 연출과 적 재생이 한 프레임에 겹치면 F2 같은 시점 문제가 다시 나올 수 있습니다.
  - `time_scale`을 바꾼 뒤 1.0으로 되돌리지 않으면 다음 단계로 새어 나갑니다. auto harness는 되돌립니다 (`S/battle3d_auto_harness.gd:77`).

### C. 엔진 전용 기준을 golden으로 캐시 (skill_equivalence)
- 효과: 케이스당 bare 실행이 빠집니다. 추정으로 약 40~45%가 줄어듭니다.
- 위험:
  - 이 테스트는 "같은 코드에서 3D == 엔진 직접"을 증명합니다. golden으로 바꾸면 엔진을 바꿀 때마다 golden을 다시 만들어야 합니다. 3D가 틀린 것인지 엔진이 바뀐 것인지 구분할 수 없게 됩니다.
  - `direct.writes`는 spy 호출 순서이고, `final_state`에는 40필드, controller, 로그 3개가 들어갑니다. 모두 직렬화해야 합니다. float 텍스트가 플랫폼마다 다르므로 setup_port처럼 IEEE 비트 digest가 필요합니다 (`S/battle_setup_s43_harness.gd:12-29`).

### D. bare 엔진 하나를 여러 케이스에서 재사용
- 효과: Battle_Main instantiate와 intro 대기가 케이스당 한 번씩 빠집니다. 추정 10~20%.
- 위험: 높습니다. 로그, momentum, round, cooldown, 상태 효과, AI 예약, 플래그 같은 엔진 상태를 완전히 초기화해야 합니다. 하나라도 남으면 다음 케이스가 오염됩니다. 동등성 테스트에서는 양쪽(bare, lab)에 같은 오염이 들어가 버그가 가려질 수도 있습니다.

### E. 고정 대기 줄이기
- 대상: settle 30프레임 창, teardown 10프레임 + 0.1초 (`S/battle_enemy_turn_oracle_harness.gd:214-215`), auto 끝 60프레임 (`S/battle3d_auto_harness.gd:76`), close 뒤 1프레임.
- 효과: 작습니다. 케이스당 0.1~0.4초로 전체의 약 5~10%입니다 (추정).
- 위험:
  - 30프레임 창은 call_deferred 사이나 적 슬롯 사이처럼 잠깐 settled처럼 보이는 순간을 걸러 줍니다. 줄이면 전환 중간에 snapshot을 찍을 수 있습니다.
  - F3처럼 "프레임 수"를 "상태 대기"로 바꾸는 방식이 더 안전합니다. 예: 타이머/Tween 수가 0이고, `is_demo_animating`과 `is_unique_skill_presenting`이 false이고, phase가 ally_turn인 상태.
  - teardown의 0.1초는 남은 타이머 콜백이 free된 노드를 건드리지 않게 하는 여유일 수 있습니다. 근거는 확인 못 했습니다.

### F. 샤드 더 나누기
- 효과: 파일당 120초 여유만 늘어납니다. CI는 순서대로 돌기 때문에 **전체 시간은 그대로이거나, 프로세스 시작 비용만큼 늘어납니다** (Godot 부팅, 스크립트 컴파일, 1.48 MB golden 파싱).
- 위험: 동작 변화는 없습니다. Linux에서 skill_equivalence_shard_1이 약 106초라서 120초에 가깝습니다. 이 점에서는 의미가 있습니다.

### G. 기타 작은 후보
- 상속 때문에 함께 로드되는 attack golden 1.48 MB를 쓰는 테스트에서만 로드하기 (`S/battle3d_engine_attack_harness.gd:7`). 동작 위험은 없습니다. 효과는 프로세스당 1회라 작습니다.
- `skill_display_probe`가 `_sync_views()`를 두 번 부르는 것을 한 번으로 줄이기. probe는 표시 검사에 쓰이므로 검사 시점이 바뀌지 않게 해야 합니다.
- lab의 `create_trimesh_collision()`(`lab_presentation.gd:76`)을 열 때마다 하는 비용. 테스트에서 끄면 클릭 unproject 같은 다른 경로에 영향이 있을 수 있습니다. 확인 못 했습니다.

## 13. 런타임 측정 제안 (추정 검증용)

### 이미 로그에서 grep할 수 있는 것
| 테스트 | grep 패턴 | 내용 |
|---|---|---|
| skill_equivalence | `[M4C1_SKILL_CASE]` … ` ms=` | 케이스당 direct + 3D + close_lab 합계 (`T/test_battle3d_skill_equivalence.gd:75`) |
| skill_equivalence | `[M4C1_SKILL_EQUIVALENCE]` | checks, display_checks, momentum_checks |
| enemy_strategy parity | `[ENEMY_STRATEGY_BASE_PARITY_CASE]` … ` ms=` | 전투당 시간 (`T/test_battle_enemy_strategy_base_parity.gd:48`) |
| setup_port parity | `[SETUP_BASE_PARITY] seed_N` … ` ms=` | seed당 시간, result, round (`T/test_battle_setup_port_base_parity.gd:111`) |
| auto_speed | `[M5A_SPEED_CASE]` … `x ms=` | 속도별 시간과 `next_randf` (`T/test_battle3d_auto_speed.gd:37`). 처음 버튼 확인 단계는 빠져 있음 |
| tactic semantics | `[TACTIC_SKILL_SEMANTICS_CASE]` | **ms 없음**. 케이스 수만 셀 수 있음 |
| 엔진 공통 | `[HERO_CUTIN] route=` | 특기 연출 경로 (registry_video / legacy_static / legacy_fallback / static_fallback). 4.6초 fallback 여부를 가르는 데 필요 |
| 엔진 공통 | `[BATTLE_INTRO_CAMERA] complete` | Battle_Main 생성 횟수를 셀 수 있음 |
| 엔진 공통 | `[AUTO_BATTLE_STOP]`, `[ENEMY_AI_LEVEL] round=` | 자동전투 종료 이유와 라운드 수 |

- 코드 수정 없이: Godot `--print-fps`를 붙이면 headless 프레임 속도를 초마다 찍습니다. Windows와 Linux의 프레임 속도를 비교할 수 있습니다.
- 프로세스 전체 벽시계에서 `ms=` 합을 빼면 부팅, 컴파일, golden 파싱, 종료 비용이 나옵니다.

### 단계별로 재야 할 것 (`Time.get_ticks_usec()`와 `Engine.get_process_frames()`를 함께)
1. harness `.new()` (golden 파싱 포함).
2. `open_bare`: instantiate + `add_child`(`_ready`) 따로, `host.initialized`까지(intro 대기) 따로.
3. `open_lab`: instantiate, `add_child`(lab `_ready`: glb, trimesh, soldier 60개), `ready_for_input`까지.
4. 명령 → 처음 settled가 된 시점 (= 엔진 연출 실제 초). 그 뒤 30프레임 창 (= 고정 대기 비용). 두 값을 나눠서 찍습니다.
5. `close_bare` / `close_lab` / `_teardown` (10프레임 + 0.1초).
6. 자동전투: 결과까지 ms와 프레임 수, `auto_battle_step_count`, 라운드 수, 끝 60프레임.
7. enemy_strategy BATTLE: 아군 행동 10회 각각의 ms와 프레임 수.
8. 3D settle 동안 프레임당 평균 ms. bare settle과 비교하면 probe 비용이 보입니다.
9. 특기 케이스마다 `[HERO_CUTIN] route`와 연출 시간을 함께 기록합니다.

## 14. 확인 못 한 것
- Battle_Main, lab instantiate의 실제 ms. 코드만 봐서는 알 수 없습니다.
- headless 프레임 속도 (Windows, Linux). 30프레임 창과 타이머 체인 지연의 실제 크기가 이 값에 달려 있습니다.
- Linux가 1.5~1.6배 느린 원인. 연출이 실제 초라면 OS와 상관없어야 하므로, CPU 비용(프레임 처리, instantiate, 영상 디코딩, stdout 출력)이 큰 것으로 보입니다. 하지만 어느 것이 큰지는 확인 못 했습니다.
- 케이스별 특기 연출 경로 (정적 1.22초 / specialty 영상 2.13초 / registry 영상 최대 4.6초). 특히 `X_enemy_skill_in_slot`과 `K_enemy_auto_skill`.
- 적 슬롯 하나, 라운드 전환 하나(라운드 toast 포함)가 몇 초인지. Tween 길이를 다 따라가지 않았습니다.
- 자동전투 한 판의 라운드 수와 단계 수.
- `time_scale` 8x 이상, 또는 `--fixed-fps`에서 golden과 digest가 같게 나오는지. 실행해 봐야 압니다.
- teardown의 `create_timer(.1)`가 왜 필요한지 (주석 없음).
- 엔진이 찍는 print 양과 그 stdout 비용. Windows 콘솔에서는 클 수 있습니다.
- lab `_ready`가 매번 `runtime_events.jsonl`을 WRITE로 여는 IO 비용 (`lab_presentation.gd:27`).
- F2/F3 이력의 자세한 내용. 코드 주석(`ENG:1606-1614`, `ENG:13929`, `battle3d_engine_play.gd:1424-1435`)과 요청에 적힌 설명만 근거로 썼습니다.
