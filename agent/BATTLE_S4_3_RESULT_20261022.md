# BATTLE S4-3 결과 — 전투 시작 설정 입구 + 적 AI 등급 + 자동 연출 대기 입구 (2026-10-23 밤샘 ③ 단계 ①)

- 작업 ID: S4-3 (엔진 단계 S). 지시문 `S4_3_BATTLE_SETUP_PORT_20261022.md`, 설계서 `DESIGN_S4_AI_LEVEL_AND_BATTLE_SETUP_20261022.md` §0·§1·§3·§3-2, 운영 `NIGHT3_STACK_20261023.md`
- 브랜치 `feature/night3-stack-20261023`(스택). 이 단계 커밋 1개: `feat(battle): add the battle start setup port, enemy AI level and auto presentation hold (S4-3)`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- 합격 판정은 하지 않는다(검수: 클코치).
- **멈춤 규칙에 걸리지 않았다**. 설계·지시와 다른 사실 없음, 기존 골든·테스트 수정 0, 월드맵·세이브 경로를 켤 필요 없음, 새 난수 0, 같은 실패 3회 없음.
- **불일치 1건(멈춤 아님, §5 결정)**: 지시문 §1-2는 "하 = 두 플래그 false, 중·상 = 두 플래그 true"다. 갱신된 설계서 §1은 세 플래그로, **하 = 책략 false·돌려쓰기 false·상한 true**다. 설계서를 따랐다(지시문이 먼저 읽으라고 한 문서이고, 상한 추가분이 지시문보다 나중 결정).

## 단계 ⓪ — 스택 기준 (이 보고서에 함께 기록)

- `origin/integration/p1-engine-core-20261019` 끝 = `406bb73a024c3a0277ac8c06b891c30bc9e96e6b` 확인.
- `git am --keep-cr NIGHT3_stack_base.patch`: 커밋 3개를 적용했다.
  - `260b746` M5-a
  - `030f208` S4-2c 돌려쓰기
  - `62af862` S4-2c 상한
- `HEAD^{tree}` = `e6f044c701e9d71eb2e94f2a05412121918c8eca` **일치**.
- 커밋 `a2c3c4b` `chore(battle3d): pin the M5-a validator to the stack's M5-a commit`: `TIP` 기본값 한 줄 → `260b746c5d38de2a229feceb4c585d2f3597187b`.
- **추가 커밋 `e835800`(지시 밖, 결정 사항)** `chore(battle): pin the S4-2c addendum validator to its implementation commit`
  - 상한 validator는 BASE가 원래 S4-2c 커밋 `e347ef4`이고 TIP 기본값이 `HEAD`였다. 스택 역사에는 `e347ef4`가 없다. 그래서 live 모드가 `e347ef4..작업트리` 사이의 통합 변경(M4-c2·M5-a)까지 범위 검사해 **실패**했다(`out of scope BATTLE_RUNTIME_REFACTOR_PLAN.md`).
  - S4-2c 돌려쓰기 validator가 이미 원래 커밋(`e347ef4`)에 고정된 방식과 같게, TIP 기본값만 원래 상한 커밋 `0dd907b`로 고정했다(한 줄).
  - 근거: 스택 사본의 diff가 원본과 **바이트 단위로 같다**.
    - `git diff e347ef4 0dd907b` == `git diff 030f208 62af862`
    - `git diff b83a402 e347ef4` == `git diff 260b746 030f208`
    - 둘 다 index 줄을 빼고 비교했다.
  - 주의: 두 S4-2c validator는 로컬에 원본 커밋 객체가 있어서 통과한다. 원본 브랜치를 푸시하지 않은 원격 CI에서는 객체가 없다. 병합 때 스택 해시로 다시 고정해야 한다(클코치 몫).
- 확인: validator 5개(`m5a_autoplay`, `skill_rotation_s4_2c`, `skill_cap_s4_2c2`, `enemy_strategy_s4_2`, `m4c2_enemy_skill`) 모두 PASS.
- 이 단계 ①의 BASE = `e835800d44a8921e63bda2168974b25a77fb398a`("⓪ 직후 커밋"으로 읽음).

## 0. 사전 확인 (엔진 직접 실행)

1. **입구를 읽는 위치**
   - `_ready` 끝부분 순서: `reset_demo_state()` → `_read_worldmap_battle_context_handoff()` → `_try_restore_battle_resume_snapshot()` → **`_read_battle_setup_port()`(새 줄)** → 디버그 출력 → `_refresh_production_battle_hud("ready")`.
   - 유닛 생성·장수 데이터 적용(`_apply_hero_identity_to_unit`, `reset_demo_state` 안)이 모두 끝난 뒤이고 HUD 첫 갱신 전이다. 월드맵 핸드오프·이어하기 복원이 있었다면 그 위에 덮는다(테스트 전투에서는 둘 다 없음).
   - 병력 6필드는 `scripts/battle_unit_state.gd`의 int 필드다. 기본값은 장수 레지스트리(`_apply_hero_identity_to_unit`: allocated/initial/current/max_troops)와 유닛 초기화(hp)에서 정해진다. 기본 배치 값(실행 확인):

     | unit_id | current/max_troops | current/max_hp | allocated / initial |
     |---|---|---|---|
     | guan_yu | 100/100 | 100/100 | 115 / 115 |
     | zhang_fei | 80/80 | 80/80 | 110 / 110 |
     | xiahou_dun | 76/76 | 76/76 | 112 / 112 |
     | enemy_reinforce_01_demo | 68/68 | 68/68 | 68 / 68 |
     | enemy_reinforce_02_test_unit | 66/66 | 66/66 | 66 / 66 |

2. **반올림 규칙: 필드마다 `max(1, floor(값 × 비율))`, 0 이하 값은 그대로**
   - 피해는 `current_hp`와 `current_troops`를 같은 양만큼 줄인다(`apply_damage`). 생존 병력은 `initial_allocated_troops × current_hp / max_hp`(내림)다.
   - 그래서 6필드를 같은 비율로 줄이면 시작 시 `current_hp/max_hp = 1`이 유지된다. 생존 병력 = 줄어든 `initial_allocated_troops`로 일관된다.
   - 최소 1이라 사망 판정(`current_hp > 0 and current_troops > 0`)에 걸리지 않는다.
   - 승리 연습 0.25 결과:

     | unit_id | troops | hp | allocated | initial |
     |---|---|---|---|---|
     | guan_yu | 25/25 | 25/25 | 28 | 28 |
     | zhang_fei | 20/20 | 20/20 | 27 | 27 |
     | xiahou_dun | 19/19 | 19/19 | 28 | 28 |
     | enemy_reinforce_01_demo | 17/17 | 17/17 | 17 | 17 |
     | enemy_reinforce_02_test_unit | 16/16 | 16/16 | 16 | 16 |

3. **적 턴 시작 지점**
   - 이 엔진의 "적 턴"은 **적 행동 슬롯 하나**다. 교대 행동이라 아군 행동 1회마다(또는 아군이 다 행동한 뒤 적 차례마다) `_set_phase(PHASE_ENEMY_TURN)` → `_play_enemy_turn_demo()` → `_play_enemy_ai_turn()`이 불린다.
   - `_play_enemy_ai_turn` 맨 앞은 결과 확정 가드다. 그 뒤 `enemy_turn_started` 기록 → 행동자 선택 → `_play_enemy_ai_for_actor`(비동기 연출) → `_advance_enemy_turn_or_return_to_ally`로 이어진다.
   - 반영 지점은 **결과 가드 다음, `enemy_turn_started` 기록 바로 앞**(한 줄)이다. 이전 적 행동이 끝난 뒤에만 다음 `_play_enemy_ai_turn`이 불리므로 진행 중 행동에는 닿지 않는다.
4. **플래그 읽는 지점**(전부 행동 중 동기 판단)
   - `enemy_strategy_enabled`: L3908 적 책략 판단
   - `enemy_skill_spread_enabled`: 양보 판단, 사용 기록
   - `enemy_skill_cap_enabled`: 상한 판단, 사용 기록
   - 셋 다 적 행동자의 판단 안에서만 읽는다. 행동 도중 값이 바뀔 수 있는 경로는 "적 행동 중 `set_enemy_ai_level` 직접 반영"뿐이다. 대기 값 방식으로 막았다(테스트로 확인, 프로브 Q7).
5. **월드맵 판정 변수**: 입구를 써도 그대로다(실행 확인).
   - `worldmap_battle_context = {}`, `_get_current_battle_resume_id() == ""`
   - `_persist_battle_resume_snapshot` 호출은 매 `_set_phase`마다 들어오지만 ID가 없어 첫 줄에서 돌아간다(테스트에서 호출 수 > 0, 저장 0).
6. **지표**: 5부대 모두 일관된다.
   - 병력 6필드는 위 표와 같다.
   - HUD 어댑터(`BattleHudStateAdapter.build`)의 적 명단 `current_troops/max_troops`가 줄어든 hp와 같다(25/25, 20/20, 19/19).
   - 생존 병력(`_calculate_unit_surviving_allocated_troops`)이 줄어든 `initial_allocated_troops`(28/27/28/17/16)와 같다.
   - 증원 01을 배치(라운드 2, `_try_deploy_reinforce_01_pair`)한 뒤에도 17/17 그대로다.

## 0-2. 연출 대기 입구 사전 확인

1. **`_tick_full_auto_battle_if_needed` 흐름**
   - 가드 순서(새 hold 게이트 다음): 자동 꺼짐 → 결과 확정 → `is_demo_animating` → `ally_turn` 아님 → 스텝 한도 → 아군/적 없음 → 활성 유닛 없음/아군 아님 → 행동 가능 아님. 그다음 `auto_battle_step_count += 1; _run_auto_action_for_active_ally_once()`.
   - 호출처는 3곳이다.
     - `_set_phase`: `ally_turn`이고 자동 on·연출 아님·결과 아님이면 `call_deferred`
     - `_set_full_auto_battle_enabled(true)`: `call_deferred`
     - 새 `set_auto_presentation_hold(false)`: 조건부 `call_deferred`
   - **두 번 불려도 안전**: 첫 호출의 행동이 같은 호출 안에서 `is_demo_animating = true`(이동·공격·특기)를 켜거나, 대기면 단계가 `enemy_turn`으로 바뀐다. 그래서 두 번째 호출은 가드에서 돌아간다.
   - 실행 확인: hold로 막은 뒤 같은 상태에서 틱 2번 → 스텝 1(테스트 마지막 케이스).
2. **해제 때 재호출이 필요한 이유**
   - 막힌 틱은 이미 소비된 `call_deferred`다. 그 뒤 엔진은 아군 턴에 머물러 단계 변경(`_set_phase`)도, 연출 완료도 일어나지 않는다. 그래서 다시 부를 곳이 없다.
   - 실행 확인: 해제를 1회 부르면 틱 1회·스텝 1회다. 재호출을 지운 변조(Q2)에서는 자동이 멈춘 채로 남는다.
3. **자동 중 행동 사이 간격, 적 턴 경로**
   - 엔진 자동의 한 스텝은 틱 1회다. 기본 배치 첫 스텝은 **이동만** 하고, 같은 장수의 공격·대기는 **다음 틱**이다(실행: 스텝 1 뒤 이동 로그 3줄, 적 로그 0).
   - 적 턴은 `_end_ally_turn_by_wait`·공격 완료 등 엔진 내부 경로에서 바로 시작된다. hold 게이트(자동 틱)를 지나지 않는다. hold 중 수동 대기 뒤에도 적 슬롯이 그대로 재생됐다(테스트).

## 1. 변경

| 파일 | 변경 | 내용 |
|---|---|---|
| `scripts/battle_web_import_test.gd` | +97 | 멤버 4개·상수 2개, `_ready` 한 줄, 새 함수 8개, 적 턴 시작 한 줄, 자동 틱 게이트 2줄 |
| `scripts/battle/services/battle_setup_rules_service.gd` | 신규 | 순수 규칙: 비율 유효성, 필드 축소, 등급 유효성, 등급 → 플래그 |
| `tests/scripts/support/battle_setup_s43_harness.gd` | 신규 | M5-a 자동 하니스 확장 + 관찰자 엔진(무시 로그·persist 호출·적 턴 시작 플래그·틱 수) |
| `tests/golden/battle_setup_port_base_v0.json` | **신규** 골든 | BASE(`e835800`) 워크트리에서 생성한 전자동 6시드 다이제스트 |
| 테스트 7개 | 신규 | §2 |
| `tools/validate_battle_setup_port_s4_3.py` | 신규 | BASE `e835800`, TIP 기본 `HEAD`(`S4_3_SCOPE_TIP`) |
| `.github/workflows/verify-c-track.yml` | +7 | validator 1 + 테스트 6 |
| `agent/BATTLE_S4_3_RESULT_20261022.md` | 신규 | 이 보고서 |

**엔진 공개 함수**
- `set_enemy_ai_level(level) -> bool`
  - `"low"|"mid"|"high"`가 아니면 false이고 상태는 그대로다.
  - 맞으면 대기 값 `_pending_enemy_ai_level`에 넣는다.
  - 이미 적용된 값과 같으면 대기 값을 비운다.
- `get_enemy_ai_level() -> String`: 기본 `"low"`
- `get_pending_enemy_ai_level() -> String`: 없으면 `""`
- `set_auto_presentation_hold(hold: bool) -> void`: true → false로 바뀔 때만, 자동 on·`ally_turn`·연출 아님이면 `call_deferred("_tick_full_auto_battle_if_needed")`

**내부**
- `_read_battle_setup_port()`: 메타 `samwar_battle_setup`을 읽고 지운다. `unit_overrides`를 적용하고, `enemy_ai_level`이 유효하면 대기에 넣은 뒤 **즉시 반영**한다(첫 아군 턴 전).
- `_apply_battle_setup_unit_override(id, override)`: 6필드를 함께 줄인다.
- `_log_battle_setup_ignored(reason)`: `[BATTLE_SETUP] ignored: …` 한 줄
- `_apply_pending_enemy_ai_level()`: 대기 값이 있으면 등급 확정 → 세 플래그 설정 → 대기 비움 → `[ENEMY_AI_LEVEL]` 한 줄
- 등급 → 플래그(서비스 `flags_for_ai_level`):

  | 등급 | 책략 | 돌려쓰기 | 상한 |
  |---|---|---|---|
  | low | false | false | **true** |
  | mid | true | true | true |
  | high | true | true | true (S4-4 전까지 mid와 동일) |

- `enemy_ai_level_applied`: 한 번도 반영되지 않았으면 false다. 그동안 플래그를 건드리지 않는다. 그래서 기본 게임(설정 없음)은 지금과 같다.

## 2. 테스트 (모두 CI 편입)

| 파일 | 내용 | checks | 시간 |
|---|---|---|---|
| `test_battle_setup_port_base_parity_shard_1/2` | 키 없음, hold 기본 false. 엔진 전자동 4x, 시드 1~3 / 4~6. 최종 유닛·컨트롤러·로그 4개·라운드 시작 스냅샷(다음 난수 포함)·쓰기 순서를 BASE 다이제스트와 비교 | 36 / 36 | CI 표 |
| `test_battle_setup_port_s4_3` | 키 없음/빈 값/잘못된 형식, 승리 연습 0.25(6필드·생존 병력·HUD·나머지 필드 불변·증원 도착), 1.0, 아군 0.5, 경계 8종 무시+로그, 등급 즉시 반영/무시, 두 번째 전투 잔여 없음, 월드맵·이어하기 없음 | 58 | |
| `test_battle_enemy_ai_level_s4_3` | 기본 low·플래그 미변경 / 잘못된 값 6종 / 아군 턴 설정 → 다음 적 턴 반영(그 적 행동 전체가 새 플래그) / 같은 값 / low 복귀(상한만) / high = mid / 적 행동 중 설정 → 그 행동은 옛 플래그·결과 동일, 다음 적 턴 반영 / 미설정 시 테스트가 쓴 플래그 보존 | 19 | |
| `test_battle_enemy_ai_level_mid_default` | 시작 입구 `mid` vs 세 플래그 직접 쓰기, 전자동 4x 시드 1. 다이제스트 전부 같음 | 4 | |
| `test_battle_auto_presentation_hold_s4_3` | 기본 false / hold로 시작 → 행동·로그·난수 0 / 해제 1회 → 틱 1·스텝 1 / 두 번째 해제 → 추가 없음 / 자동 중 hold → 진행 중 스텝 끝, 다음 틱 없음 / hold 중 자동 중지 → 수동 정상, 적 슬롯 재생 / 자동 꺼짐 → 해제 무영향 / 같은 상태 틱 2번 → 스텝 1 | 12 | |

- **중 등급 = S4-2c 측정 일치**: `enemy_skills = [장비, 하후돈, 장비, 관우, 하후돈, 하후돈, 하후돈]`, 장비 2·관우 1·하후돈 4, 라운드 8 패배다. S4-2c 추가분 측정의 "상한+돌려쓰기" 전자동 행과 **순서·횟수·결과가 같다**.
- BASE 골든 생성: `e835800` 분리 워크트리에 새 하니스·동등성 테스트 두 파일만 복사해 `--write=`로 기록했다(생성 로그 zip `evidence/s43_base_golden.log`). 6시드 다이제스트는 서로 모두 다르다(시드가 실제로 반영됨). 결과는 모두 라운드 11 패배.

## 3. 변조 프로브 (15개, 연출 대기 2개 포함)

- 방식: 엔진·서비스에 변조를 1개씩 적용하고 S4-3 validator와 해당 테스트를 돌린 뒤 원래 바이트로 복원했다(`cmp` 확인 `RESTORED_OK`).
- 러너 `evidence/run_s43_probes.py`, 결과 `evidence/s43_probes_run1/`

| # | 변조 | validator | 테스트 | 잡은 테스트 |
|---|---|---|---|---|
| Q1 | 자동 틱 hold 게이트 제거 | 잡음 | 잡음 | hold |
| Q2 | 해제 때 재호출 제거 | 잡음 | 잡음 | hold |
| Q3 | 키 없는데 읽음(빈 메타 읽기) | 잡음 | 잡음 | 입구(키 없음 = 로그 0) |
| Q4 | 6필드 중 `max_hp` 누락 | **못 잡음** | 잡음 | 입구 |
| Q5 | 범위 밖(≤2.0) 적용 | **못 잡음** | 잡음 | 입구 |
| Q6 | 월드맵 경로 켜짐(`worldmap_battle_context` 설정) | 잡음 | 잡음 | 입구 |
| Q7 | 등급 즉시 반영(적 턴 중에도) | 잡음 | 잡음 | 등급 |
| Q8 | low인데 세 플래그 true | 잡음 | 잡음 | 등급, 입구 |
| Q9 | 메타를 지우지 않음 | 잡음 | 잡음 | 입구 |
| Q10 | 잘못된 값이 대기 값을 바꿈 | 잡음 | 잡음 | 등급 |
| Q11 | 아군 비율 적용 누락(적만 찾음) | **못 잡음** | 잡음 | 입구 |
| Q12 | 반영 뒤 대기 값 남음 | **못 잡음** | 잡음 | 등급 |
| Q13 | 적 턴 시작에서 반영 안 함 | 잡음 | 잡음 | 등급 |
| Q14 | 내림 대신 올림 | 잡음 | 잡음 | 입구 |
| Q15 | 등급 미설정인데 상한 플래그 씀 | **못 잡음** | 잡음 | 등급(BASE 동등성 shard 1은 못 잡음) |

- 테스트는 15개 모두 잡았다. validator는 10개를 잡았다.
- **못 잡는 것(숨기지 않음)**:
  - Q4·Q5·Q11·Q12·Q15는 validator가 문구를 고정하지 않은 부분(필드 목록 상수, 비교 상수, 대상 찾기 조건, 대기 비우기 줄, 미설정 분기)이다. 테스트만 잡는다.
  - Q15는 BASE 동등성으로도 못 잡는다. 기본 배치 전자동에서는 상한이 켜져도 발동하지 않는다(S4-2c 추가분 측정 "상한만 = off").
- **부수 영향(복원함)**: Q6은 월드맵 경로를 켜는 변조라 실제로 `user://battle_runtime_resume.json`(Godot 사용자 데이터, 테스트가 쓰는 이어하기 파일)을 덮어썼다. 프로브 전에 백업해 두었고, 끝난 뒤 원래 바이트로 되돌렸다(`cmp` 확인).
- 대조군: validator, 입구·등급·hold 테스트 모두 exit 0.

## 4. 전체 CI 로컬 재현

- 최종 코드(커밋 직전 작업 트리, 이 보고서 파일만 빠짐) 기준이다.
- 순서: `--headless --editor --import`(exit 0) → `verify-c-track.yml` 목록 그대로 실행(러너 `run_ci.py`, S4-2c와 같음)
- **179단계 모두 exit 0**(합계 약 2,509초):
  - validator **46** = 스택 ⓪ 45 + S4-3 1
  - Godot 테스트 **128** = 스택 ⓪ 122 + S4-3 6
  - 씬 로드 3개, `--editor --quit-after 2`, `git diff --check`
- S4-3 테스트 시간:

  | 테스트 | 시간 |
  |---|---|
  | validator | 5.1초 |
  | BASE 동등성 shard 1 / 2 | 63.3초 / 63.3초 |
  | 입구 | 14.5초 |
  | 등급 | 9.2초 |
  | 중 등급 연결 | 36.4초 |
  | hold | 6.4초 |

- 가장 긴 파일은 기존 `test_battle3d_skill_equivalence_shard_1`(67.2초)이다. M5-a 자동 동등성 3개(43.9~44.0초)는 그대로 통과했다.
- 실행 전후 `git status`가 같다. 원문: zip `evidence/s43_ci_full_run/`.

## 5. 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| 등급 → 플래그 | 설계서 §1(하 = 상한만 true) | 지시문 §1-2(두 플래그)보다 설계서 갱신본이 나중. 설계서가 상한을 "모든 등급"에 넣음 |
| 한 번도 설정 안 됐을 때 | `get_enemy_ai_level()`은 `"low"`, 플래그는 그대로(false 3개) | 설계서 "등급이 한 번도 설정되지 않았으면 플래그를 건드리지 않는다" + 기본 low. 그래서 "low로 표시되지만 상한은 꺼짐"인 상태가 존재한다(기본값 켜기는 별도 커밋, 김작 결정) |
| `set_enemy_ai_level` 인자 타입 | `Variant`(설계 표기는 `String`) | 시작 입구에서 숫자·null이 와도 예외 없이 false. 3D는 문자열만 보냄 |
| 같은 값 재설정 | 적용된 값과 같으면 대기 값 비움(true 반환) | "다음 적 턴부터 적용" 표시가 불필요하게 남지 않게. 미적용 상태의 `"low"`는 대기에 들어감(상한 적용) |
| "적 턴 시작" | `_play_enemy_ai_turn`의 결과 가드 다음(적 행동 슬롯마다) | 엔진 구조상 적 턴 = 적 슬롯. 진행 중 행동이 끝난 뒤에만 다음 슬롯 시작 |
| 시작 입구 등급 | 대기 → 즉시 반영(`_read_battle_setup_port` 안) | 설계서 "첫 아군 턴 전 즉시 적용" |
| 입구 읽는 위치 | 이어하기 복원 뒤, HUD 첫 갱신 전 | 유닛·장수 데이터가 모두 정해진 뒤. 월드맵 함수와 분리 |
| 반올림 | 필드별 내림, 양수는 최소 1 | 사망 판정·생존 병력 계산과 일관(§0-2) |
| 증원 유닛 | 시작 때 배치되지 않은 증원도 `unit_id`로 찾아 줄임 | 유닛 상태는 처음부터 있고, 배치 때 병력을 다시 정하지 않음(실행 확인) |
| 무시 로그 | `print` 한 줄(별도 함수 `_log_battle_setup_ignored`) | 전투 로그(`battle_log_lines`)는 상태 일부라 건드리지 않음. 함수로 분리해 테스트가 셈 |
| 보고서 이름 | `BATTLE_S4_3_RESULT_20261022.md`(지시문 §5 이름), zip은 `S4_3_REVIEW_20261023.zip` | 단계 지시문의 이름과 밤샘 규칙의 zip 날짜를 함께 따름 |
| BASE 동등성 시드 | 6개(전자동 4x), 2개 파일로 나눔 | "시드 6". 시드당 약 21~24초라 한 파일 120초 한도를 넘음 |
| hold 중 "진행 중 행동" | 엔진 자동 스텝(틱) 단위 | 엔진의 자동 행동은 이동과 그 뒤 공격·대기가 서로 다른 틱이다. 이동 뒤 hold면 같은 장수의 다음 동작도 기다린다(설계서 "막는 자리는 자동 틱 한 곳" 그대로) |

## 6. 남은 것

- 3D는 이 단계에서 수정하지 않았다(M5-a2에서 hold 사용).
- 상 등급 계획형(S4-4), 옵션창(M5-c), 등급의 스냅샷 저장은 범위 밖이다.
- 스택의 S4-2c validator 두 개는 원본 커밋 객체에 기대고 있다(⓪ 참고).
- 사람이 직접 한 플레이는 없다(엔진 실행 로그만).
