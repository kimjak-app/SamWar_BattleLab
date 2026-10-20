# S3-1 엔진 적 턴 이벤트 기록 결과

- 작업: S3-1 엔진 적 턴 이벤트 (관찰 전용 추가)
- 기준(BASE): `a19a08d4a370b68e50ee5a8cf24513d6689b6024`. 지시문의 `d05d4f1`은 사용자 지시로 `a19a08d`로 읽었다. `d05d4f1` 위에 Godot 에디터가 `.tscn` 메타데이터 2줄만 바꾼 커밋이다.
- 브랜치: `feature/battle3d-m3-enemy-turn-20261020`. 로컬 커밋만 했고 **push·merge는 하지 않았다**.
- 구현: Claude Code (클코). **합격 판정은 하지 않는다.** 검수는 클코치가 독립적으로 한다.
- 범위: S3-1만 했다. M3(3D)는 시작하지 않았다.

## 0. 사전 확인 (지시문 §1-3)

**Q1. 기본 시나리오에서 적이 고유특기를 실제로 쓰는가? → 쓴다.**
- 확인 방법: 기본 `Battle_Main` 배치를 고치지 않고 풀오토로 6라운드를 돌리며 `_begin_auto_unique_skill_preview` 호출을 관찰했다.
- 적 특기 선택: R2 `zhang_fei_unique`, R3 `guan_yu_unique`, R4·R5·R6 `xiahou_dun_unique`. 아군 `kwon_yul_unique`도 R1·R2·R4에서 선택됐다.
- 끝나는 상태: 고유특기 미리보기 → 효과 적용 → `_finalize_unique_skill_action` → `_mark_enemy_unit_acted` → 다음 슬롯 순서로 진행된다.
- 오라클 E20에서 관우 특기가 실제로 실행되는 것을 확인했다. 아군 병력 300→251, 적 기세 8→5, 적 행동 완료.
- 이벤트: `enemy_skill_used` 다음에 `enemy_action_completed`가 기록된다. 특기 결과는 이벤트에 넣지 않았다(M4 범위). 3D는 엔진 상태를 읽어 반영해야 한다.

**Q2. `_start_new_round`에서 3D가 보여줘야 할 변화 (필드 목록)**
- 컨트롤러 값: `battle_round` +1, `battle_momentum` 양쪽(라운드 종료 보너스, E15에서는 피격·공격 반영 후 양측 +2), 보급 정산(`_settle_battle_supply_turn`), `has_pending_move_snapshot` 해제, 적 AI 예약 초기화
- 행동 잠금: `action_lock_state_service`의 ally/enemy 잠금 해제
- 유닛 필드: `has_acted`, `has_moved`, `attacked_this_turn` 등 `reset_action_flags` 대상 필드
- 쿨다운: 양쪽 고유특기 쿨다운 1 감소
- 증원: `_try_deploy_reinforce_01_pair` / `_try_deploy_city_reinforce_02_pair`로 유닛 배치가 바뀔 수 있다
- 연출: 라운드 배너
- 상태이상(혼란, `movement_down` 등)은 라운드가 아니라 **유닛이 행동할 때** 줄어든다(`_consume_strategy_status_after_unit_action`). E12·E13에서 `status_effects` 변화로 확인했다.
- 공격 버프 턴(`unique_skill_attack_buff_turns_by_unit_id`)은 이번 오라클에서 다루지 않았다(한계 참고).

**Q3. 적 이동 경로 `move_path`**
- 타입은 `Array[Vector2i]`다(`_find_enemy_move_path_for_actor`의 반환 타입).
- Tween이 `move_path[1..]`를 차례로 실행하고, 완료 콜백의 `target_cell`이 `move_path[-1]`이다. 그래서 **실행 경로와 계획 경로가 같다.**
- 경로가 바뀌는 분기는 없다. 다만 Tween 전에 끝나는 분기는 이동 자체가 없다: 경로 막힘(`_is_path_clear_for_unit`), 마커 없음.
- `ALLOW_BREAKTHROUGH_MOVE=false`이고, AI가 목적지를 정할 때와 이동 경로를 찾을 때 같은 경로 탐색을 쓴다. 그래서 `no_path`, `path_blocked`, 계획 단계의 `no_target`은 지금 규칙으로는 **스스로 도달하지 않는다**.
- 이 세 분기는 테스트 전용 seam(`SeamBattle`)으로 조회 결과 하나만 바꿔서 실행했다. 분기 본문·로그·잠금·턴 진행은 실제 코드 그대로 돈다.

**Q4. 전투 종료 시 3D 입력 차단**
- 적 공격으로 마지막 아군이 죽은 경우(E16): `_finish_enemy_actor_basic_attack`의 종료 가드가 `is_demo_animating=false`로 바꾸고 바로 return한다. 그래서 **phase가 `enemy_turn`인 채로 남고** `_return_to_ally_turn`에 도달하지 않는다.
- 아군 공격으로 적이 전멸한 경우(E17): phase는 `ally_turn`, 결과 상태는 `victory`이고 `is_demo_animating=false`다.
- `_return_to_ally_turn`의 결과 확정 분기는 `_set_phase(PHASE_ALLY_TURN)` 후 return하고 `is_demo_animating`을 건드리지 않는다.
- 결론: 3D는 `phase==ally_turn && !is_demo_animating`만으로 입력을 열면 안 된다. **`battle_ended` 이벤트 또는 `_get_battle_result_state() != ""`일 때 전체 입력을 잠가야 한다.** 승리 쪽은 phase만 보면 입력이 열려 보이므로 특히 필요하다.

**Q5. 풀오토(`is_full_auto_battle_enabled`)가 적 이벤트에 영향을 주는가 → 주지 않는다.**
- 코드상 근거:
  - 풀오토가 쓰이는 곳은 아군 자동 명령, 아군 특기 후 재배치 생략(`battle_production_controller._finalize_unique_skill_action`, ally 한정), 종료 시 자동전투 정지다.
  - 적 턴 함수(`_play_enemy_ai_*`)에는 풀오토 분기가 없다.
  - `record_skill`은 `side=="enemy"`일 때만 기록하므로, 풀오토 아군 특기는 적 로그에 들어가지 않는다.
- 실행 근거: Q1 풀오토 6라운드 실행에서 오류 없이 진행됐다.
- 한계: 풀오토 상태에서 이벤트 순서를 단언하는 테스트는 없다.

## 1. 변경 파일 (BASE..TIP, `git diff --numstat`, 모두 추가만 하고 삭제 0)

| 파일 | +/− |
|---|---|
| `scripts/battle_web_import_test.gd` (컨트롤러) | +17 / −0 |
| `scripts/battle/services/battle_enemy_event_log_service.gd` (+`.uid`) | +177 / −0 (신규) |
| `.github/workflows/verify-c-track.yml` | +5 / −0 |
| `tests/golden/battle_enemy_turn_baseline_v0.json` | +33286 (신규, BASE 코드에서 생성) |
| `tests/scripts/support/battle_enemy_turn_oracle_harness.gd` (+`.uid`) | +225 (신규) |
| `tests/scripts/support/battle_enemy_event_observer_battle.gd` (+`.uid`) | +13 (신규) |
| `tests/scripts/test_battle_enemy_turn_oracle_baseline.gd` / `_shard_1` / `_shard_2` (+`.uid`) | +57 / +4 / +4 (신규) |
| `tests/scripts/test_battle_enemy_turn_event_semantics.gd` (+`.uid`) | +153 (신규) |
| `tests/scripts/test_battle_enemy_event_log_service.gd` (+`.uid`) | +88 (신규) |
| `tools/validate_battle_enemy_events_s3_1.py` | +179 (신규) |
| `agent/BATTLE_ENGINE_S3_1_RESULT_20261020.md` | 이 보고서 |

`.gd.uid` 파일은 CI의 `--editor --import`가 생성하는 사이드카다. 커밋하지 않으면 CI의 마지막 단계인 clean-tree 검사가 실패하므로 함께 넣었다.

## 2. 구현

### 2-1. 서비스 `battle_enemy_event_log_service.gd`
- `extends RefCounted`이고 `class_name`은 없다. 컨트롤러가 preload로 쓴다.
- 멤버는 로그 자체의 값뿐이다: `_events`, `_sequence`, 그리고 관찰용 이동 경로 사본 `_staged_move_unit_id` / `_staged_move_path`.
- 전투 상태는 갖지 않는다. 유닛 값을 **읽기만** 한다. Node·SceneTree·Tween·signal·await는 쓰지 않는다.
- 독립 로그다. 시퀀스는 0부터 따로 세고, `battle_action_event_log` / `ally_move_event_log`와 섞지 않는다. 기존 `battle_event_log_service.gd`는 수정하지 않았다.
- 이벤트는 순수 값(int/String/bool/Array/Dictionary)만 담는다. 종류별로 필드 집합을 정확히 검사하고, 틀리면 기록하지 않는다. `export()`와 `emit()` 반환값은 deep copy다.
- `enemy_moved`는 기록 시점이 둘로 나뉜다:
  1. Tween 시작 직전에 `stage_move_path`로 경로 사본만 보관한다.
  2. `_finish_enemy_actor_basic_move`에서 `set_grid_cell` 직후 `emit_staged_move`로 기록한다.
  - 같은 유닛이고, 경로 끝 == `target_cell`이고, 경로 길이 ≥ 2일 때만 기록한다. 한 번 쓰면 비우므로 같은 finish가 두 번 불려도 중복 기록되지 않는다.
  - 이렇게 나눈 이유: `_finish_*`는 경로를 인자로 받지 않는다. 경로를 Tween 콜백에 bind하면 기존 호출을 바꾸게 되어 "기록 호출 1줄 추가만" 원칙에 어긋난다.

### 2-2. 컨트롤러 기록 줄 17개 (함수 11개, 순서·조건·타이밍 변경 없음)

| 이벤트 | 위치 |
|---|---|
| 멤버 선언 1줄 | 헤더, `ally_move_event_log` 다음 |
| `enemy_turn_started{round}` | `_play_enemy_ai_turn`, 첫 종료 가드 return 직후 |
| `enemy_actor_selected` | `_play_enemy_ai_for_actor`, `current_enemy_ai_actor_state = …` 직후 |
| `enemy_waited` ×7 | 대기·혼란·경로없음·경로막힘·대상없음 분기마다 `_mark_enemy_unit_acted` 직전. 이유값: `confused`, `no_target`(계획), `wait`(제자리 계획), `no_path`, `no_target`(제자리 공격 대상 없음), `path_blocked`, `wait`(이동 후 대기) |
| 경로 보관 / `enemy_moved` | Tween 생성 직전 / `set_grid_cell` 직후 |
| `enemy_attack_resolved` | `_enemy_reaction_hit_on`, `apply_damage` 직후 |
| `enemy_action_completed` | `_mark_enemy_unit_acted` 안, `was_already_acted == false` 블록의 마지막 |
| `enemy_skill_used` | `_try_auto_unique_skill_for_actor`, 선택 확정 직후·미리보기 전. 적일 때만 기록 |
| `round_started{round}` | `_start_new_round` 성공 경로 끝 |
| `battle_ended{result_state}` | `_handle_battle_end_guard`, `has_logged_battle_end_guard = true` 직후. 전투당 1회 |

- 공격 필드:
  - `damage_applied`는 `apply_damage` 반환값이다. HP 기준으로 상한이 걸리며 S2-2의 `attack_resolved`와 같은 정의다.
  - `raw_damage`는 공식으로 계산한 피해다.
  - `target_troops_after`와 `killed`는 피해 직후에 읽는다.
- `unit_defeated`는 새로 만들지 않았다. 기존 `_cleanup_dead_units`가 `battle_action_event_log`에 남기는 이벤트를 그대로 쓴다.

## 3. 테스트

### 3-1. 적 턴 오라클 (20케이스, BASE에서 golden 생성)
- 진입 경로: 컨트롤러가 아군 슬롯 뒤에 스스로 부르는 `_play_enemy_turn_demo()`를 그대로 호출한다. E17만 실제 아군 공격 요청으로 진입한다.
- Tween·타이머는 건너뛰지 않는다. `ally_turn`(또는 결과 확정) + `!is_demo_animating` 상태가 30프레임 연속 유지되면 끝난 것으로 본다.
- 케이스:
  - 병종 5종 × 공격/접근: E1~E10
  - E11 즉사(전투는 계속)
  - E12 대기(`movement_down` 때문에 유효 이동력 0)
  - E13 혼란
  - E14 경로 없음(seam)
  - E15 마지막 적이 행동한 뒤 라운드 완료
  - E16 아군 전멸 → 패배
  - E17 적 전멸 → 승리
  - E18 경로 막힘(seam)
  - E19 대상 없음(seam)
  - E20 적 고유특기
- golden 내용: 케이스마다 start / `enemy_turn_requested` / settled 세 시점 × 유닛 10명 × 40필드 + 컨트롤러 상태 12개(phase, 애니메이션, 라운드, 기세, 양쪽 행동 잠금, 사망 목록, 결과 상태 등) + **아군 로그 두 개(시작 시점과 끝 시점 export)**.
- golden에는 적 이벤트를 넣지 않는다. 적 로그는 BASE에 없기 때문이다.
- 각 케이스를 두 번 돌려 결정성을 확인하고 golden과 비교한다.
- CI에서는 10+10 샤드로 나눴다. 단일 실행이 61초여서 120초 제한 안이지만, 여유를 두려고 S2-2처럼 나눴다.
- 동작 보존 증명:
  1. 엔진 코드를 바꾸기 전(`scripts/`가 BASE와 동일한 상태)에 `--update-golden`으로 생성했다. 121 checks, exit 0, sha `a3795131…`.
  2. 같은 BASE에서 비교 모드로 다시 돌렸다. 124 checks, exit 0.
  3. 기록 줄을 넣은 뒤 비교했다. 124 checks, exit 0.
  4. **최종 하니스 그대로 별도 worktree에서 BASE 엔진(컨트롤러를 BASE로 되돌리고 서비스 삭제)으로 다시 생성했더니 커밋된 golden과 바이트 동일했다**(`cmp` 일치, sha `a3795131b8d2c525f7c096683d98b543410c01a130930783961dab671d9887f7`).
- 독립성: golden에 BASE 시점의 `battle_action_event_log` / `ally_move_event_log` export가 들어 있다. 기록을 추가한 뒤에도 sequence·개수·내용이 같다는 것이 golden 비교로 함께 확인된다. 기존 공격 이벤트 parity(213)와 이동 이벤트 parity도 다시 통과했다.

### 3-2. 이벤트 의미 테스트 (`test_battle_enemy_turn_event_semantics`, 525 checks)
- 케이스마다 이벤트 종류 순서를 그대로 비교하고, 고유 sequence가 0..n-1인지 본다.
- `enemy_moved`
  - `path[0]`과 `from`이 이동 전 셀이다.
  - `path[-1]`과 `to`가 최종 `grid_cell`이다.
  - 길이 ≤ 유효 이동력+1이다.
  - 각 걸음이 맨해튼 거리 1이다.
- `enemy_attack_resolved`
  - `damage_applied`가 시작 병력에서 `target_troops_after`를 뺀 값이다. 즉사 E11은 raw 8, applied 5, 병력 5→0.
  - `target_troops_after`가 엔진의 최종 병력과 같다.
  - `killed`가 엔진의 사망 판정과 `dead_unit_ids`에 맞는다.
- 즉사: 관찰 서브클래스가 `_enemy_reaction_hit_on` **안**에서 보면 `enemy_attack_resolved`와 기존 `unit_defeated`가 같은 호출 안에 이미 있다. 중복은 0이다.
- 횟수: 적 행동마다 `enemy_actor_selected` 1, `enemy_action_completed` 1. 예외는 E16(종료 가드 조기 return → completed 0, 규칙대로)과 E17(적 행동 없음)이다. `battle_ended`는 정확히 1회다.
- `export()` 결과를 밖에서 고쳐도 로그는 변하지 않는다. 이미 행동한 적에게 `_mark_enemy_unit_acted`를 다시 불러도 새 이벤트가 생기지 않는다.
- 아군 로그 두 개에는 적 이벤트 종류가 0개다.
- golden 비교(상태 + 아군 로그)도 이 테스트에서 함께 다시 한다.

### 3-3. 서비스 단위 테스트 (37 checks)
- 9종 정상 기록
- 잘못된 kind·reason·빈 id·필드 초과·타입 오류·Object 참조 거부 10종
- null 유닛 거부
- 아군 특기는 기록하지 않음
- 보관 경로는 한 번만 소비, 다른 유닛 거부, 목적지 불일치 거부, 1칸 경로 거부
- export와 반환값 deep copy
- 기록이 유닛 값을 바꾸지 않음
- `clear()` 후 sequence 초기화

### 3-4. validator `tools/validate_battle_enemy_events_s3_1.py`
- `BASE=a19a08d`, 범위 끝은 `S3_1_SCOPE_TIP`(기본 `HEAD`=라이브 작업 트리).
  - **최종 커밋은 자기 자신의 해시를 소스에 넣을 수 없어서 기본값을 `HEAD`로 두었다.** 병합 후 TIP 재고정은 지시문대로 클코치에게 맡긴다.
  - 재고정 전에도 `S3_1_SCOPE_TIP=<커밋해시>`로 고정 범위를 검증할 수 있다.
- 검사 항목:
  - 허용 파일 화이트리스트(수정 2, 신규 21)
  - 기존 golden 두 개의 sha 불변
  - 컨트롤러 numstat 삭제 0, 기록 줄을 빼면 BASE와 바이트 동일, 함수별 기록 줄 정확 일치, 핵심 8곳의 바로 앞 줄 일치, 기록 줄에 대입 없음
  - 서비스: `extends RefCounted`, 금지 API 없음, 멤버 4개 정확, 유닛 필드 쓰기·변경 메서드 호출 없음, 이벤트 9종 정확
  - CI에 정확히 5줄 추가
  - 샤드 분할 정확, golden의 `base_commit` 일치, 케이스 순서 일치, 10×40 필드
  - `git diff --check`

## 4. 새로 돌린 것 / 이전 증거 재사용

### 4-1. 새로 돌린 것 (이번 세션, 실행 원문은 zip `evidence/`)

**전체 CI 로컬 재현 1회.** `.github/workflows/verify-c-track.yml`의 목록을 파싱해 같은 명령으로 돌렸다(Windows, Godot 4.6.2 console, 단계당 120초 제한).
- 시작 상태: WIP 커밋 `d051730`, `.godot`를 지우고 새로 import한 뒤 실행했다.
- **106개 단계 모두 exit 0.** 내역:
  - 정적 validator 33개 (기존 32 + 신규 1)
  - Godot 테스트 68개 (기존 64 + 신규 4)
  - 씬 로드 3개 (WorldMap / Battle_Main / Imjin ISO)
  - `--editor --quit-after 2` 1개
  - `git diff --check` 1개
- 실행 후 `git status --short`는 비어 있었다. 단계 시간 합계는 492.8초다.
- 신규 테스트 결과:
  - 적 이벤트 서비스: 37 checks, 0.53초
  - 적 턴 오라클 샤드 1: 64 checks, 35.04초
  - 적 턴 오라클 샤드 2: 64 checks, 26.79초
  - 이벤트 의미: 525 checks, 31.58초
- 주요 기존 테스트 결과:
  - 공격 오라클 샤드: 128 / 106 checks
  - 공격 이벤트 parity: 213
  - 3D 공격 샤드: 1122 / 1123 / 1115
  - 3D 공격 거절: 110, 동기화: 364
  - 3D 이동 통합: 144
- 단계별 전체 표는 §6에 있다.

그 밖에 새로 돌린 것:
- 변조 프로브 6개와 대조군(§5)
- golden 재생성 비교 3회(§3-1의 1·2·4)
- 개발 중 개별 실행: 오라클 전체, 의미 테스트, 서비스 테스트, 기존 validator 32개

### 4-2. 이전 증거 재사용
- **없다.** 기존 테스트도 이전 보고서 수치를 옮겨 적지 않았다. 위 CI 재현에서 전부 다시 실행했다.
- 원격 GitHub Actions는 push를 하지 않았으므로 **실행되지 않았다**. Linux 환경은 확인하지 않았다.

### 4-3. 무효 처리한 실행 (환경 크래시, 숨기지 않음)
- 첫 번째 CI 시도: `.godot`를 지우고 실행한 import가 **signal 11(Segmentation fault, exit 139)**로 중단됐다.
  - 시점: 23초, `NotoSerifKR-Black.otf` 재import 도중
  - 클래스 캐시 파일은 생겼지만 `.ctex` 일부가 만들어지지 않았다.
- 그 상태에서 전투 씬 테스트들이 리소스 로드 실패 → `Could not resolve class "BattleIsoProductionController"` parse error → 120초 타임아웃이 됐다(공격 오라클 샤드 1·2, 공격 parity, 적 오라클 샤드 1 등).
- 코드와 무관한 import 미완료 상태이므로 그 실행을 중단하고 결과 전체를 무효로 했다.
- 재현 조건: `rm -rf .godot` 직후 `--headless --editor --import`를 처음 돌릴 때.
- 재시도: 같은 명령을 다시 돌리자 1회 만에 exit 0으로 import가 완료됐다(`imported/` 904개). §4-1은 그 뒤 처음부터 다시 돌린 결과다.
- 프로브용 worktree의 첫 import는 exit 0이었다.
- 무효 실행 로그는 zip `evidence/ci_attempt1_invalid_import_crash/`에 있다.

## 5. 변조 프로브 (원문)

방법:
- 별도 worktree(WIP `d051730`과 같은 내용)에서 한 번에 변조 하나만 적용하고 `finally`에서 원래 바이트로 복구했다. 러너는 zip `evidence/run_probes.py`다.
- 변조마다 validator(라이브)와, 그 변조가 영향을 주는 Godot 테스트 케이스 1개를 돌렸다.
- **6개 모두 Godot 테스트가 exit 1이었다. parse/compile 오류 없이 단언 실패로 잡혔다.** validator는 P3(서비스 내부의 path 조작)를 통과시켰다. 이 경우는 의미 테스트가 잡는다.
- 대조군(변조 없음)은 모두 exit 0이었다.

재현용 변조 내용(정확한 문자열 치환은 `run_probes.py`의 `PROBES`):
- **P1** (요청 1): 컨트롤러의 `enemy_action_event_log.emit_staged_move(...)` 줄을 삭제
- **P2** (요청 2): `_mark_enemy_unit_acted`의 `record_unit("enemy_action_completed", …)` 줄을 두 번 기록
- **P3** (요청 3): 서비스 `emit_staged_move`에서 `path[-1]`을 x+1로 바꾸고, 검사를 통과하도록 `to_cell`도 같이 맞춤
- **P4** (요청 4): `record_attack(…, attack_damage, applied_attack_damage, …)` → `(…, attack_damage, attack_damage, …)`, 즉 raw 값을 기록
- **P5** (추가): 공격 기록을 `apply_damage` 앞으로 옮김(raw 값 사용)
- **P6** (추가): 서비스 `record_unit`이 `unit.facing = "up"`을 씀 → 상태 쓰기

### (원문)

### P1_enemy_moved_line_deleted

변조 파일: `scripts/battle_web_import_test.gd`

`validate_battle_enemy_events_s3_1.py` → exit=1, 0.61초
```text
AssertionError: ('recording line count', 16)
```
`test_battle_enemy_turn_event_semantics.gd --case=E2_infantry_approach` → exit=1, 4.04초, parse_error=False
```text
[ENEMY_EVENTS] checks=28 failures=["E2_infantry_approach event order [\"enemy_turn_started\", \"enemy_actor_selected\", \"enemy_attack_resolved\", \"enemy_action_completed\"]"]
[ENEMY_EVENTS] FAIL E2_infantry_approach event order ["enemy_turn_started", "enemy_actor_selected", "enemy_attack_resolved", "enemy_action_completed"]
```

### P2_completion_recorded_twice

변조 파일: `scripts/battle_web_import_test.gd`

`validate_battle_enemy_events_s3_1.py` → exit=1, 0.58초
```text
AssertionError: ('recording line count', 18)
```
`test_battle_enemy_turn_event_semantics.gd --case=E1_infantry_attack` → exit=1, 3.68초, parse_error=False
```text
[ENEMY_EVENTS] checks=30 failures=["E1_infantry_attack event order [\"enemy_turn_started\", \"enemy_actor_selected\", \"enemy_attack_resolved\", \"enemy_action_completed\", \"enemy_action_completed\"]", "E1_infantry_attack one completion per action"]
[ENEMY_EVENTS] FAIL E1_infantry_attack event order ["enemy_turn_started", "enemy_actor_selected", "enemy_attack_resolved", "enemy_action_completed", "enemy_action_completed"]
[ENEMY_EVENTS] FAIL E1_infantry_attack one completion per action
```

### P3_path_last_cell_wrong

변조 파일: `scripts/battle/services/battle_enemy_event_log_service.gd`

`validate_battle_enemy_events_s3_1.py` → exit=0, 0.81초
```text
S3_1_ENEMY_EVENTS PASS: base=a19a08d scope=HEAD; 21 paths; 17 additive controller lines in 11 functions; observation-only service; existing goldens unchanged; 20 oracle cases (10+10 shards)
```
`test_battle_enemy_turn_event_semantics.gd --case=E2_infantry_approach` → exit=1, 4.05초, parse_error=False
```text
[ENEMY_EVENTS] checks=36 failures=["E2_infantry_approach path ends at final grid_cell", "E2_infantry_approach orthogonal step 3"]
[ENEMY_EVENTS] FAIL E2_infantry_approach path ends at final grid_cell
[ENEMY_EVENTS] FAIL E2_infantry_approach orthogonal step 3
```

### P4_damage_applied_uses_raw

변조 파일: `scripts/battle_web_import_test.gd`

`validate_battle_enemy_events_s3_1.py` → exit=1, 0.64초
```text
AssertionError: ('recording lines in _enemy_reaction_hit_on', ['\t\tenemy_action_event_log.record_attack(current_enemy_ai_actor_state, target_state, attack_damage, attack_damage, attack_angle_type)'])
```
`test_battle_enemy_turn_event_semantics.gd --case=E11_lethal_target` → exit=1, 3.69초, parse_error=False
```text
[ENEMY_EVENTS] checks=29 failures=["E11_lethal_target damage_applied equals troop loss"]
[ENEMY_EVENTS] FAIL E11_lethal_target damage_applied equals troop loss
```

### P5_attack_recorded_before_apply_damage

변조 파일: `scripts/battle_web_import_test.gd`

`validate_battle_enemy_events_s3_1.py` → exit=1, 0.62초
```text
AssertionError: ('recording lines in _enemy_reaction_hit_on', ['\t\tenemy_action_event_log.record_attack(current_enemy_ai_actor_state, target_state, attack_damage, attack_damage, attack_angle_type)'])
```
`test_battle_enemy_turn_event_semantics.gd --case=E1_infantry_attack` → exit=1, 3.57초, parse_error=False
```text
[ENEMY_EVENTS] checks=28 failures=["E1_infantry_attack damage_applied equals troop loss", "E1_infantry_attack troops after equals engine"]
[ENEMY_EVENTS] FAIL E1_infantry_attack damage_applied equals troop loss
[ENEMY_EVENTS] FAIL E1_infantry_attack troops after equals engine
```

### P6_service_writes_unit_state

변조 파일: `scripts/battle/services/battle_enemy_event_log_service.gd`

`validate_battle_enemy_events_s3_1.py` → exit=1, 0.64초
```text
AssertionError: service writes no unit field
```
`test_battle_enemy_turn_oracle_baseline.gd --case=E1_infantry_attack` → exit=1, 4.42초, parse_error=False
```text
[ENEMY_TURN_ORACLE] checks=10 failures=["golden parity [\"units.scenarios\"]"]
[ENEMY_TURN_ORACLE] FAIL golden parity ["units.scenarios"]
```

### 대조군 (변조 없음, 같은 worktree)

`test_battle_enemy_turn_event_semantics.gd --case=E11_lethal_target` → exit=0
```text
[ENEMY_EVENTS] checks=29 failures=[]
```
`test_battle_enemy_turn_event_semantics.gd --case=E1_infantry_attack` → exit=0
```text
[ENEMY_EVENTS] checks=28 failures=[]
```
`test_battle_enemy_turn_event_semantics.gd --case=E2_infantry_approach` → exit=0
```text
[ENEMY_EVENTS] checks=36 failures=[]
```
`test_battle_enemy_turn_oracle_baseline.gd --case=E1_infantry_attack` → exit=0
```text
[ENEMY_TURN_ORACLE] checks=10 failures=[]
```
`validate_battle_enemy_events_s3_1.py` → exit=0
```text
S3_1_ENEMY_EVENTS PASS: base=a19a08d scope=HEAD; 21 paths; 17 additive controller lines in 11 functions; observation-only service; existing goldens unchanged; 20 oracle cases (10+10 shards)
```

## 6. 전체 CI 로컬 재현 단계별 결과 (새로 돌린 것, 106단계)

| # | 단계 | exit | 초 | checks |
|---:|---|---:|---:|---:|
| 1 | `tools/validate_worldmap_main_integrity.py` | 0 | 0.12 | - |
| 2 | `tools/validate_worldmap_diplomacy_controller_extraction.py` | 0 | 1.12 | - |
| 3 | `tools/validate_worldmap_diplomacy_routing.py` | 0 | 2.95 | - |
| 4 | `tools/validate_worldmap_diplomacy_service_separation.py` | 0 | 0.62 | - |
| 5 | `tools/validate_worldmap_trade_routing.py` | 0 | 0.51 | - |
| 6 | `tools/validate_worldmap_trade_controller_extraction.py` | 0 | 0.53 | - |
| 7 | `tools/validate_worldmap_trade_phase2_extraction.py` | 0 | 0.41 | - |
| 8 | `tools/validate_worldmap_spy_routing.py` | 0 | 0.69 | - |
| 9 | `tools/validate_worldmap_spy_controller_extraction.py` | 0 | 0.67 | - |
| 10 | `tools/validate_worldmap_battle_settlement_applier_extraction.py` | 0 | 0.21 | - |
| 11 | `tools/validate_worldmap_t03_strategic_battle_transaction_extraction.py` | 0 | 0.21 | - |
| 12 | `tools/validate_worldmap_t03_battle_presentation_extraction.py` | 0 | 0.59 | - |
| 13 | `tools/validate_worldmap_player_attack_deployment_service_extraction.py` | 0 | 0.71 | - |
| 14 | `tools/validate_worldmap_wounded_recovery_service_extraction.py` | 0 | 0.2 | - |
| 15 | `tools/validate_worldmap_to_battle_input_lifecycle.py` | 0 | 0.1 | - |
| 16 | `tools/validate_b0b_battle_production_skeleton.py` | 0 | 0.1 | - |
| 17 | `tools/validate_b0c_battle_iso_promotion.py` | 0 | 0.1 | - |
| 18 | `tools/validate_b1b_battle_movement_query_service.py` | 0 | 0.25 | - |
| 19 | `tools/validate_b1c_battle_combat_query_service.py` | 0 | 0.19 | - |
| 20 | `tools/validate_b1d_battle_damage_formula_service.py` | 0 | 0.18 | - |
| 21 | `tools/validate_b1e_battle_action_lock_state_service.py` | 0 | 0.3 | - |
| 22 | `tools/validate_b1f_battle_enemy_ai_reservation_state_service.py` | 0 | 0.21 | - |
| 23 | `tools/validate_b1g_battle_unique_skill_cooldown_state_service.py` | 0 | 0.2 | - |
| 24 | `tools/validate_battle_s1_1_observation_baseline.py` | 0 | 0.81 | - |
| 25 | `tools/validate_battle_s2_1_attack_baseline.py` | 0 | 0.57 | - |
| 26 | `tools/validate_battle_s2_2_attack_state_service.py` | 0 | 2.2 | - |
| 27 | `tools/validate_battle_enemy_events_s3_1.py` | 0 | 0.73 | - |
| 28 | `tools/validate_battle_s1_2_ally_move_state_service.py` | 0 | 1.44 | - |
| 29 | `tools/validate_battle3d_m1b_engine_move.py` | 0 | 0.6 | - |
| 30 | `tools/validate_battle3d_m2_engine_attack.py` | 0 | 3.07 | - |
| 31 | `tools/validate_battle3d_contract.py` | 0 | 0.12 | - |
| 32 | `tools/validate_alternating_battle_action_order.py` | 0 | 0.12 | - |
| 33 | `tools/validate_single_side_exhaustion_turn_order.py` | 0 | 0.11 | - |
| 34 | `tests/scripts/test_worldmap_city_administration_service_extraction.gd` | 0 | 0.44 | - |
| 35 | `tests/scripts/test_worldmap_city_resource_service_extraction.gd` | 0 | 0.42 | - |
| 36 | `tests/scripts/test_worldmap_city_detail_presentation_extraction.gd` | 0 | 0.43 | - |
| 37 | `tests/scripts/test_worldmap_camera_controller_extraction.gd` | 0 | 0.42 | - |
| 38 | `tests/scripts/test_worldmap_hud_controller_extraction.gd` | 0 | 0.52 | - |
| 39 | `tests/scripts/test_worldmap_shared_ui_controller_extraction.gd` | 0 | 0.43 | - |
| 40 | `tests/scripts/test_world_calendar_service_extraction.gd` | 0 | 0.42 | - |
| 41 | `tests/scripts/test_world_turn_economy_service_extraction.gd` | 0 | 0.42 | - |
| 42 | `tests/scripts/test_world_turn_state_service_extraction.gd` | 0 | 0.43 | - |
| 43 | `tests/scripts/test_worldmap_turn_controller_extraction.gd` | 0 | 0.43 | - |
| 44 | `tests/scripts/test_battle_movement_query_service.gd` | 0 | 3.49 | - |
| 45 | `tests/scripts/test_battle_combat_query_service.gd` | 0 | 3.49 | - |
| 46 | `tests/scripts/test_battle_damage_formula_service.gd` | 0 | 3.5 | - |
| 47 | `tests/scripts/test_battle_action_lock_state_service.gd` | 0 | 3.49 | - |
| 48 | `tests/scripts/test_battle_enemy_ai_reservation_state_service.gd` | 0 | 3.48 | - |
| 49 | `tests/scripts/test_battle_unique_skill_cooldown_state_service.gd` | 0 | 3.49 | - |
| 50 | `tests/scripts/test_battle_event_log_service.gd` | 0 | 0.42 | - |
| 51 | `tests/scripts/test_battle_state_fingerprint_service.gd` | 0 | 0.52 | - |
| 52 | `tests/scripts/test_battle_attack_oracle_shard_1.gd` | 0 | 39.86 | 128 |
| 53 | `tests/scripts/test_battle_attack_oracle_shard_2.gd` | 0 | 31.51 | 106 |
| 54 | `tests/scripts/test_battle_attack_state_service.gd` | 0 | 0.52 | 70 |
| 55 | `tests/scripts/test_battle_attack_event_parity.gd` | 0 | 35.5 | 213 |
| 56 | `tests/scripts/test_battle_enemy_event_log_service.gd` | 0 | 0.53 | 37 |
| 57 | `tests/scripts/test_battle_enemy_turn_oracle_shard_1.gd` | 0 | 35.04 | 64 |
| 58 | `tests/scripts/test_battle_enemy_turn_oracle_shard_2.gd` | 0 | 26.79 | 64 |
| 59 | `tests/scripts/test_battle_enemy_turn_event_semantics.gd` | 0 | 31.58 | 525 |
| 60 | `tests/scripts/test_battle_move_oracle_baseline.gd` | 0 | 20.94 | - |
| 61 | `tests/scripts/test_battle_ally_move_state_service.gd` | 0 | 0.55 | - |
| 62 | `tests/scripts/test_battle_ally_move_event_parity.gd` | 0 | 7.43 | - |
| 63 | `tests/scripts/test_battle3d_engine_move_integration.gd` | 0 | 7.1 | 144 |
| 64 | `tests/scripts/test_battle3d_engine_attack_shard_1.gd` | 0 | 10.18 | 1122 |
| 65 | `tests/scripts/test_battle3d_engine_attack_shard_2.gd` | 0 | 10.67 | 1123 |
| 66 | `tests/scripts/test_battle3d_engine_attack_shard_3.gd` | 0 | 10.49 | 1115 |
| 67 | `tests/scripts/test_battle3d_engine_attack_rejections.gd` | 0 | 9.98 | 110 |
| 68 | `tests/scripts/test_battle3d_engine_attack_sync.gd` | 0 | 10.1 | 364 |
| 69 | `tests/scripts/test_battle3d_movement_parity.gd` | 0 | 1.63 | - |
| 70 | `tests/scripts/test_battle3d_modes.gd` | 0 | 0.72 | - |
| 71 | `tests/scripts/test_battle3d_oblique_click.gd` | 0 | 6.72 | - |
| 72 | `tests/scripts/alternating_battle_action_order_test.gd` | 0 | 0.43 | - |
| 73 | `tests/scripts/test_single_side_exhaustion_turn_order.gd` | 0 | 3.12 | - |
| 74 | `tests/scripts/test_worldmap_domestic_tech_catalog_extraction.gd` | 0 | 6.36 | - |
| 75 | `tests/scripts/test_worldmap_domestic_tech_research_rules_extraction.gd` | 0 | 0.52 | - |
| 76 | `tests/scripts/test_worldmap_domestic_tech_research_service_extraction.gd` | 0 | 0.8 | - |
| 77 | `tests/scripts/test_worldmap_domestic_tech_effect_provider_extraction.gd` | 0 | 0.52 | - |
| 78 | `tests/scripts/test_worldmap_domestic_tech_tree_presentation_extraction.gd` | 0 | 1.82 | - |
| 79 | `tests/scripts/test_worldmap_domestic_tech_completion_presentation_extraction.gd` | 0 | 0.86 | - |
| 80 | `tests/scripts/test_worldmap_military_controller_extraction.gd` | 0 | 4.91 | - |
| 81 | `tests/scripts/test_worldmap_enemy_warfare_service_extraction.gd` | 0 | 4.96 | - |
| 82 | `tests/scripts/test_worldmap_battle_context_service_extraction.gd` | 0 | 5.06 | - |
| 83 | `tests/scripts/test_worldmap_battle_result_service_extraction.gd` | 0 | 5.15 | - |
| 84 | `tests/scripts/test_worldmap_battle_settlement_applier_extraction.gd` | 0 | 0.43 | - |
| 85 | `tests/scripts/test_worldmap_t03_strategic_battle_transaction_extraction.gd` | 0 | 0.54 | - |
| 86 | `tests/scripts/test_worldmap_t03_battle_presentation_extraction.gd` | 0 | 0.68 | - |
| 87 | `tests/scripts/test_worldmap_player_attack_deployment_service_extraction.gd` | 0 | 0.54 | - |
| 88 | `tests/scripts/test_worldmap_troop_rebalance_service_extraction.gd` | 0 | 0.52 | - |
| 89 | `tests/scripts/test_worldmap_wounded_recovery_service_extraction.gd` | 0 | 0.42 | - |
| 90 | `tests/scripts/test_worldmap_diplomacy_routing.gd` | 0 | 19.41 | - |
| 91 | `tests/scripts/test_worldmap_diplomacy_controller_extraction.gd` | 0 | 0.89 | - |
| 92 | `tests/scripts/test_worldmap_diplomacy_validation_extraction.gd` | 0 | 5.0 | - |
| 93 | `tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd` | 0 | 4.97 | - |
| 94 | `tests/scripts/test_worldmap_diplomacy_state_extraction.gd` | 0 | 4.89 | - |
| 95 | `tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd` | 0 | 5.0 | - |
| 96 | `tests/scripts/test_worldmap_trade_routing.gd` | 0 | 16.65 | - |
| 97 | `tests/scripts/test_worldmap_trade_controller_extraction.gd` | 0 | 4.9 | - |
| 98 | `tests/scripts/test_worldmap_trade_automation_extraction.gd` | 0 | 5.15 | - |
| 99 | `tests/scripts/test_worldmap_internal_trade_transfer_extraction.gd` | 0 | 5.01 | - |
| 100 | `tests/scripts/test_worldmap_spy_routing.gd` | 0 | 19.92 | - |
| 101 | `tests/scripts/test_worldmap_spy_controller_extraction.gd` | 0 | 5.52 | - |
| 102 | `CI_WORLDMAP_LOAD` | 0 | 2.94 | - |
| 103 | `CI_BATTLE_MAIN_LOAD` | 0 | 2.1 | - |
| 104 | `CI_IMJIN_ISO_LOAD` | 0 | 2.77 | - |
| 105 | `editor_quit_after_2` | 0 | 4.99 | - |
| 106 | `git diff --check` | 0 | 0 | - |


## 7. 알려진 한계·미커버 영역

- **실행 경로 seam**: 경로 없음·경로 막힘·계획 단계 대상 없음은 지금 규칙으로 도달하지 않는다. 그래서 테스트 전용 서브클래스가 조회 하나만 바꿔서 실행했다. 실제 플레이에서 이 이벤트가 나오는 것은 관찰하지 못했다.
- **마커 없음 분기**: `_play_enemy_actor_path_move_then_act`에서 `actor_marker == null`일 때는 `enemy_waited`를 기록하지 않는다. 지시문의 reason 목록에 맞는 값이 없어서 새 이유값을 만들지 않았다. 이 경우 3D에는 `selected → completed`만 남는다. 운영 씬에서는 도달하지 않는 방어 분기로 보이지만 증명하지는 않았다.
- **행동할 적이 없음**: `_play_enemy_ai_turn`의 "행동 가능한 적군 없음" 분기는 `enemy_turn_started` 뒤에 actor 이벤트 없이 다음 슬롯으로 간다. 오라클 케이스로 만들지 않았다.
- **종료 시 완료 이벤트 없음**: 적 행동으로 전투가 끝나면(E16) `enemy_action_completed`가 없다. 지시문의 "종료 가드 조기 return 시 기록 안 함" 규칙 그대로다. M3는 `battle_ended`로 그 행동을 마감해야 한다.
- **`enemy_turn_started`의 단위**: 적 턴 전체가 아니라 **적 슬롯 1개마다** 기록된다. 교대 진행 구조라서 `_play_enemy_ai_turn`이 슬롯마다 불리기 때문이다. 아군이 모두 행동한 뒤 적이 연달아 행동하면 `started`가 여러 번 나온다. 오라클은 슬롯 1개만 다룬다.
- **적 특기**: `enemy_skill_used`는 선택 시점에 기록된다. 이후 커밋이 실패해도(`_handle_unique_skill_commit_failure`: 기세 부족, resolver 거절) 이벤트는 남고, 뒤이어 `completed`가 온다. 실패 경로는 테스트하지 않았다. 특기 효과(피해·버프)에는 이벤트가 없다. `consumes_action=false`인 특기의 경로도 테스트하지 않았다.
- **쿨다운·버프 틱**: 라운드 틱에서 특기 쿨다운과 공격 버프 턴이 줄어드는지는 오라클 범위가 아니다. 이벤트 필드에도 넣지 않았다.
- **`damage_applied` 정의**: HP 상한 기준이다(S2-2와 같음). 테스트 fixture는 HP == 병력이라 병력 감소량과 같다. HP와 병력이 다르면 병력 감소량과 어긋날 수 있다. 병력의 진실값은 `target_troops_after`다.
- **로그 초기화**: `reset_demo_state`에서 `has_logged_battle_end_guard`는 초기화되지만 적 로그는 초기화되지 않는다(기존 두 로그와 같은 정책). 같은 씬에서 재시작하면 `battle_ended`가 다시 기록될 수 있다. resume 저장 형식에 로그는 포함되지 않는다.
- **범위 밖 기존 동작 (수정하지 않음, 보고만 함)**: E8에서 적 **총병이 이동한 뒤 같은 행동 안에서 공격**한다. 병종 규칙 `can_attack_after_move=false`와 맞지 않는다. 적 AI 판단 로직은 S3-1 금지 범위라 BASE 동작 그대로 golden에 담았다.
- **풀오토**: 풀오토 상태에서 적 이벤트 순서를 단언하는 테스트는 없다(Q5 참고).
- **validator가 못 잡는 변조**: 서비스 안에서 경로나 값을 바꾸는 변조(P3)는 validator를 통과한다. Godot 의미 테스트가 잡는다.
- **환경**: Windows 로컬에서만 확인했다. Linux와 원격 CI는 확인하지 않았다. 기존 테스트들의 종료 시 `ObjectDB instances leaked` 경고는 이전 보고서와 같은 상태이고, 이번에 건드리지 않았다.

## 8. 커밋·증거

- 작업 중 전원 차단에 대비해 WIP 커밋 두 개(`75defe3`, `d051730`)로 보존했다. 마지막에 BASE 위 **커밋 1개로 squash**했다.
- 최종 해시는 자기 자신을 이 문서에 넣을 수 없어서 zip의 `GIT_FINAL.txt`에 적는다.
- push하지 않았다. M3는 클코치 검수 후 시작한다.
