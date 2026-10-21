# BATTLE S4-1 결과 — 책략·고유특기·증원·상태 틱 이벤트 기록 + 책략 주사위 연결점 (2026-10-21)

- 작업 ID: S4-1 Tactic Events (엔진 단계 S)
- 지시문: `S4_1_TACTIC_EVENTS_20261021.md` (클코치), 사전 감사 `M4_PRE_AUDIT_20261020.md`
- 브랜치: `feature/engine-s4-1-tactic-events-20261021` ← `origin/integration/p1-engine-core-20261019`
- 기준 커밋 확인: `git log -1` = `608cb77 docs(battle3d): pin M4-a validator …` (지시문과 일치)
- 커밋 2개: S4-1a `88d2033`, S4-1b는 이 보고서가 들어가는 커밋이다(해시는 zip의 `commit_hashes.txt`).
- 구현: 클코드 세션. **합격 판정은 하지 않는다. 푸시하지 않았다.** 코덱스 폴더(`C:\dev\SamWar_BattleLab`)는 건드리지 않았다. 3D 파일 수정 0.

---

## 0. 사전 확인 6개 (엔진 직접 실행 + 소스 확인, 새로 돌린 것)

확인 방법: BASE `608cb77` 엔진(구현 전)에서 임시 스크립트 `_tmp_s41_precheck.gd`로 직접 실행했다. 커밋에는 넣지 않았다. 원문 스크립트·로그는 zip `evidence/s41_precheck/`.

### 1. 난수 전수 목록 — 예상과 일치(규칙 영향은 책략 2곳뿐)

| 위치 | 호출 | 용도 |
|---|---|---|
| `_resolve_strategy` | `randf()` 1회 | **규칙**: 책략 성공 판정 |
| `_roll_strategy_outcome` | `randi()` 1회 | **규칙**: 결과 후보 선택 |
| `_fade_out_move_dust_for_unit`, `_spawn_battle_dust_fx`, `_play_arrow_projectile_effect`, `_get_arrow_curve_midpoint`, `_spawn_arrow_projectile`, `_spawn_arrow_impact_pin`, `_play_gunner_shot_effect`, `_spawn_gunner_impact_pop`, `_spawn_hit_spark_fx`, `_start_unique_skill_camera_shake` | `randf_range` | FX 전용(연출 위치·시간·회전) |
| `_load_random_fx_texture` | `randi()` | FX 전용(텍스처 고르기) |
| `scripts/audio/game_audio.gd` | 자기 `RandomNumberGenerator`의 `randf_range` | 효과음 피치(전역 난수와 별개) |

- `battle_skill_resolver.gd`, 적 AI 경로, 서비스들, 아이소 컨트롤러 서브클래스: **난수 없음**.
- 참고 1: FX의 `randf_range`도 **전역 난수**를 쓴다. 그래서 같은 시드라도 FX 호출 순서가 다르면 그 뒤의 규칙 판정 값이 달라질 수 있다. 오라클은 행동 직전에 `seed(n)`을 걸고, 책략 판정은 그 행동의 첫 난수라서 BASE와 새 엔진이 같은 값을 뽑는다.
- 참고 2: FX 호출은 모두 이벤트(공격·이동·특기) 때 일어나고, 프레임마다 도는 것은 없었다.
- 참고 3: basic 티어는 후보가 1개인데도 `randi() % 1`로 `randi()`를 **한 번 소비**한다. 주사위 헬퍼도 이 순서를 그대로 지킨다.
- 실행 확인: 같은 시드에서 `randf()`/`randi()`로 예측한 성공/실패·후보가 실제 결과와 모두 맞았다(티어 3개 × 시드 6개).

### 2. 고유특기 데이터 — 대체로 예상과 같음, **피해 플래그 1개 추가 발견**

- 데이터(`hero_unique_skills.json`): 특기 **44개**, `effect_type` **36종**, `target_mode` **8종**(`self_area` 14, `single_enemy` 13, `enemy_area` 8, `enemy_line` 4, `ally_area` 2, `enemy_adjacent` 1, `self_area_enemy` 1, `self` 1). 44개 모두 리졸버 플랜 생성 성공(`ok=true`).
- 기본 18×10 배치의 특기:

| 부대 | 특기 | effect_type | target_mode | 기세 |
|---|---|---|---|---|
| yi_sunsin (아군) | yi_sun_sin_unique | aoe_damage_debuff | enemy_area | 4 |
| jeong_dojeon (아군) | jeong_do_jeon_unique | team_buff | self_area | 3 |
| gwon_yul (아군) | kwon_yul_unique | guard_aura | self_area | 3 |
| guan_yu (적) | guan_yu_unique | line_damage | enemy_line | 3 |
| zhang_fei (적) | zhang_fei_unique | fear_aoe | self_area_enemy | 3 |
| xiahou_dun (적) | xiahou_dun_unique | charge_damage | single_enemy | 2 |
| 증원 부대 4개 | 없음 | | | |

- 플랜 명령 종류(44개 합계): `damage` 31, `status` 149, `momentum` 26, `heal` 2, `cleanse` 2, `move` 1.
- 피해 플래그(`damage` 명령의 `status_id`): `advance_on_kill`(cheok_jun_gyeong), `ignore_defense`(nobunaga). **추가로 `deterministic_followup`(lu_bu)이 있다**(감사 목록에 없음). 컨트롤러는 이 플래그를 일반 피해처럼 처리한다(방향 보정 적용). 이벤트에는 플래그를 `status_id`로 그대로 남긴다.
- 사용되지 않는 옛 적용 함수 4개(`_apply_unique_skill_cannon_aoe` 등)는 호출하는 곳이 없어 기록을 넣지 않았다.
- `cooldown_turns`: **44개 특기 모두 쿨다운 값이 없다(0)**. 그래서 `skill_finished.cooldown_turns`는 지금 데이터에서는 항상 0이다(§8 P9).

### 3. 특기 실행 흐름의 확정 시점 — 예상과 일치, 적 `enemy_skill_used`는 "시도"임을 실행으로 확인

- `_begin_unique_skill_sequence`: 플랜 생성 → 실패면 `_handle_unique_skill_commit_failure` → `battle_momentum.spend` → 실패면 같은 실패 처리 → **여기서부터 확정**(`pending_unique_skill_plan` 설정, 연출, 타이머 후 `_apply_unique_skill_effect_if_valid` → `_finalize_unique_skill_action`). `skill_cast`는 spend 성공 바로 다음 줄에 기록한다.
- 확정 뒤에도 효과가 없을 수 있는 경로: 연출 중 시전자가 죽으면 `_apply_unique_skill_effect_if_valid`가 효과를 건너뛴다(기세는 이미 소비됨). 이때는 `skill_cast`와 `skill_finished`만 남고 `skill_effect`는 없다.
- 실행 확인(수동, 아군): 대상 선택 단계에 들어간 뒤 기세를 0으로 만들면 → 거절, `presenting=false`, 계획 비움, 대상 병력 그대로.
- 실행 확인(적 자동): `enemy_skill_used`가 기록된 직후(미리보기 0.42초 동안) 적 기세를 비우면 → 적 이벤트는 `[enemy_turn_started, enemy_actor_selected, enemy_skill_used, enemy_action_completed]`이고 아군 병력은 그대로다. 즉 `enemy_skill_used`는 확정 전 **시도** 기록이다. `skill_cast`는 확정에만 남으므로 이 경우 남지 않는다.
- 추가 발견: 수동 특기는 버튼 단계(`_can_use_unique_skill`)에서 이미 기세를 확인한다. 그래서 "확정 실패"가 실제로 일어나는 것은 **자기대상 특기의 미리보기(0.42초) 중 기세가 바뀌는 경우**뿐이다. `K_commit_failure` 시나리오는 이 경로를 쓴다.

### 4. 증원 — 예상과 일치

- 기본 배치(fixture 없음, 아군 대기만):
  - 라운드 2: `reinforce_01` 아군 `ally_reinforce_01_demo`가 (3,9), 적 `enemy_reinforce_01_demo`가 (14,1)에 도착. 각 1부대.
  - 라운드 3: `city_reinforce_02`(슬롯 메타 `arrival_round`) 아군 `ally_reinforce_02_test_unit`이 (1,7), 적 `enemy_reinforce_02_test_unit`이 (16,3)에 도착. 각 1부대.
- 순서: `_start_new_round`에서 `_try_deploy_reinforce_01_pair` → `_try_deploy_city_reinforce_02_pair` → `_show_round_start_banner` → `round_started`(S3-1). 즉 **증원 → `round_started`**.
- 도착 시 필드: 셀 = 마커 위치, `has_acted=false`, `has_moved=false`, 정원 슬롯 메타 `is_deployed=true`. 병력(64/68, 62/66)은 그대로.

### 5. 상태 틱 — 예상과 일치

- 위치: `_mark_ally_unit_acted` / `_mark_enemy_unit_acted`에서 **처음 행동 완료로 등록될 때만**(`not was_already_acted`) `_consume_strategy_status_after_unit_action`을 부른다. 즉 아군·적 각자 **자기 행동 직후**다.
- 상태가 하나도 없으면 바로 return한다(틱 없음, 이벤트 없음).
- 화상: 살아 있고 `burn`이 있으면 피해 `max(floor(magnitude/2), 4)`를 `apply_damage`로 준다(HP와 병력 둘 다).
- 이어서 `tick_status_effects()`가 모든 상태의 턴을 1 줄이고, 0 이하가 된 상태를 지운다.
- 실행 확인: 아군 burn(magnitude 12, 2턴) + shake(1턴) → 대기 직후 HP 300→294, shake 만료, burn 1턴 남음. 적 burn(magnitude 0, 1턴) → 자기 슬롯 후 HP 300→296(최소 4), burn 만료.

### 6. 책략 사용자 — 예상과 일치

- 책략 진입 경로는 `_on_strategy_button_pressed`(2D 버튼) → `_enter_strategy_target_select_mode(active_unit_state)` 하나뿐이다.
- `_can_use_strategy`는 `side == "ally"`, 전자동 아님, 미행동, 혼란 아님, 지력 ≥ 80을 요구한다.
- 적 AI 경로에는 책략 호출이 없다.
- 아군 자동 행동(`_run_auto_action_for_active_ally_once`)은 공격·특기·이동·대기만 쓰고 책략은 쓰지 않는다. 전자동 중에는 `_can_use_strategy`가 false다.

**판단**: 설계를 바꿔야 할 사실은 없다고 보고 구현을 진행했다. 감사와 다른 점(`deterministic_followup` 플래그, 확정 실패가 나는 실제 경로, 쿨다운 0)은 이벤트 형태를 바꾸지 않는다.

---

## 1. 기능 상태

| 항목 | 상태 | 근거 |
|---|---|---|
| 새 독립 로그 `tactic_event_log` | 동작 | 서비스 테스트. 기존 3개 로그와 별도 순번 |
| `strategy_cast` | 동작 | 의미 테스트(8케이스), 훅 테스트 |
| `status_tick` | 동작 | 의미 테스트(책략 대상, T1 아군·적) |
| `skill_cast` / `skill_effect` / `skill_finished` | 동작 | 특기 의미 테스트 39케이스(effect_type 36종 + 아군 자동·적 자동·처치 후 전진) |
| `reinforcement_arrived` | 동작 | 의미 테스트 R1(라운드 2·3, 4부대) |
| 책략 주사위 연결점 `strategy_roll_override` | 동작(테스트 전용) | 훅 테스트: 강제 성공/실패/후보, 훅 없음 == BASE 동등 훅 |
| 기존 동작 불변 | BASE와 같음 | 50 시나리오 골든(BASE 생성) 일치 |
| 3D 연결 | 없음(범위 밖) | validator: 3D 파일 diff 0, 소비자 없음 |

## 2. UI 상태

해당 없음(엔진 단계). 2D·3D 화면 변경 없음.

## 3. 실제 조작 증거 (로그 발췌, 새로 돌린 것)

- 새 엔진에서 오라클 시나리오 12개를 돌려 `tactic_event_log`를 그대로 출력했다. 원문은 zip `evidence/s41_event_excerpts/tactic_events_excerpt.txt`, 덤프 스크립트는 같은 폴더(커밋 안 함).
- 발췌(필드 일부 생략 없이 원문 그대로, `schema_version`/`sequence`는 줄였다):
  - **책략 성공**(S1, 지력 80, 시드 1): `strategy_cast{caster:yi_sunsin, target:guan_yu, success_rate:0.65, success:true, status_id:shake, turns:1, turns_after:1}` → 대상 자기 행동 후 `status_tick{guan_yu, burn_damage:0, expired:[shake], remaining:{}}`
  - **책략 실패**(S2, 시드 2): `strategy_cast{success:false, status_id:"", turns:0}`
  - **master 후보 1**(S7): `strategy_cast{status_id:shake, turns:3, turns_after:3}` → `status_tick{remaining:{shake:2}}`
  - **화상 틱**(T1): `status_tick{yi_sunsin, burn_damage:6, expired:[shake], remaining:{burn:1}}`, `status_tick{guan_yu, burn_damage:4, expired:[burn]}`
  - **처치 후 전진**(cheok_jun_gyeong): `skill_cast{line_damage, enemy_line, momentum_cost:2}` → `skill_effect{damage, amount:5, status_id:advance_on_kill, killed:true, from_cell:[8,4], to_cell:[9,4]}` → `skill_effect{momentum, target_id:enemy, amount:-2}` → `skill_finished{cooldown_turns:0}`
  - **후퇴 이동**(shimazu, self): `skill_effect{move, target_id:yi_sunsin, from_cell:[8,4], to_cell:[7,4]}` → `skill_effect{status, counter_up, turns:2}`
  - **회복·정화**(heukchi, ally_area): `heal 24` → `cleanse burn` → `status defense_up` (아군 2부대 각각)
  - **아군 자동**(yi_sunsin aoe): `skill_cast{momentum_cost:4}` → 피해 46/33/33 → 상태 6건 → 기세 -2 → `skill_finished`
  - **적 자동**(guan_yu): `skill_cast{side:enemy, target_id:yi_sunsin}` → 피해 49·49 → 기세 아군 -2 → `skill_finished`. 적 로그에도 `enemy_skill_used`가 그대로 남는다.
  - **확정 실패**(xiang_yu, 미리보기 중 기세 0): 전술 로그 **비어 있음**
  - **증원**(기본 배치): `reinforcement_arrived` 4건 — 라운드 2 `reinforce_01` (3,9)·(14,1), 라운드 3 `city_reinforce_02` (1,7)·(16,3). 적 로그 `round_started` 2·3은 각각 그 뒤에 나온다.

## 4. 남은 연결

- M4-b(책략 3D), M4-c(특기 3D, 적 특기 재생 확장), M4-d(증원 표시)에서 이 로그를 읽는다. 지금은 소비자가 없다(validator 검사).
- 이어하기 스냅샷(B-1H 버프 유실), 강·지형 규칙은 범위 밖이라 건드리지 않았다.

---

## 5. 변경 파일

`CONTROLLER_DELTA: +36 -2; recording lines 20 in 7 functions; header lines 2; dice helpers 2`

| 파일 | 커밋 | 변경 | 내용 |
|---|---|---|---|
| `scripts/battle_web_import_test.gd` | a+b | +36 −2 | 헤더 2줄(로그 멤버, 훅 멤버), 주사위 헬퍼 2개(12줄), 주사위 호출 2줄 교체, 기록 20줄(함수 7개) |
| `scripts/battle/services/battle_tactic_event_log_service.gd` (+uid) | a, b에서 확장 | 신규 | 관찰 전용 서비스 |
| `tests/golden/battle_tactic_baseline_v0.json` | a, b에서 재생성 | 신규 | BASE `608cb77`에서 생성(§7) |
| `tests/scripts/support/battle_tactic_oracle_harness.gd` (+uid) | a, b에서 수정 | 신규 | 50 시나리오 |
| `tests/scripts/support/battle_tactic_observer_battle.gd` (+uid) | a, b에서 확장 | 신규 | 투명 관찰자 |
| `tests/scripts/test_battle_tactic_*.gd` 11개 (+uid) | a 9개, b 3개 추가 | 신규 | 서비스·오라클(본체+4샤드)·훅·의미·특기 의미(본체+2샤드) |
| `tools/validate_battle_tactic_events_s4_1.py` | b | 신규 | |
| `.github/workflows/verify-c-track.yml` | a +7, b +3 | 추가만 | validator 1개, 테스트 9개 |
| `agent/BATTLE_S4_1_RESULT_20261021.md` | b | 신규 | 이 보고서 |

- 컨트롤러에서 기존 줄을 바꾼 것은 지시문 §4의 주사위 2줄뿐이다:
  - `if randf() <= success_rate:` → `if _strategy_roll_success(success_rate):`
  - `return pool[randi() % pool.size()]…` → `return pool[_strategy_roll_pool_index(pool.size())]…`
- 헬퍼는 훅이 비어 있으면 원래 식 그대로 `randf() <= success_rate`, `randi() % pool_size`를 같은 순서로 호출한다.
- 기록 20줄의 함수별 위치:
  - `_resolve_strategy` 2줄(성공·실패 분기 끝, `_mark_ally_unit_acted` 앞)
  - `_consume_strategy_status_after_unit_action` 2줄(틱 전 stage, 틱 후 emit)
  - `_begin_unique_skill_sequence` 1줄(spend 성공 직후)
  - `_apply_resolver_skill_plan` 10줄(명령별 적용 직후. 셀·상태를 비교해야 하는 피해·정화·이동은 stage 줄을 바로 앞에 둠)
  - `_finalize_unique_skill_action` 1줄(쿨다운 설정 직후)
  - `_try_deploy_reinforce_01_pair` 2줄, `_try_deploy_city_reinforce_02_pair` 2줄(각 배치 성공 if 안)
- 3D·기존 서비스·기존 테스트·하니스·골든·pinned validator·2D/월드맵 진입 코드: 수정 없음.

## 6. 이벤트 사양 (구현된 형태와 지시문 대비 차이)

| kind | 필드 |
|---|---|
| `strategy_cast` | caster_id, target_id, success_rate, success, status_id, turns, **turns_after** |
| `status_tick` | unit_id, burn_damage, expired, remaining |
| `skill_cast` | caster_id, side, skill_id, effect_type, target_mode, target_id, momentum_cost |
| `skill_effect` | caster_id, **effect_kind**, target_id, amount, status_id, turns, **turns_after**, killed, from_cell, to_cell |
| `skill_finished` | caster_id, cooldown_turns |
| `reinforcement_arrived` | unit_id, side, cell, round, source |

공통: `schema_version`(0), `sequence`(이 로그만의 순번), `kind`. 모든 값은 JSON 기본형이고, 잘못된 필드 조합은 서비스가 거부한다.

지시문과 다른 점과 이유:
1. **`skill_effect.kind` → `effect_kind`**: 이벤트의 `kind`(이벤트 종류, S3-1과 같은 봉투)와 이름이 겹친다. 그래서 이름만 바꿨고 값(`damage/heal/status/cleanse/momentum/move`)은 지시문과 같다. 필드를 뺀 것은 아니다.
2. **`turns_after` 추가**(strategy_cast, skill_effect): `apply_status_effect`는 기존 턴과 새 턴 중 **긴 쪽**을 남긴다. 그래서 "이번에 건 턴(`turns`)"과 "적용 후 실제 남은 턴(`turns_after`)"이 다를 수 있어 둘 다 남긴다.
3. **`momentum` 효과**: `target_id`에 기세가 바뀐 진영(`ally`/`enemy`)을 넣고, `amount`는 부호가 있다(획득 +, 흡수 −). 셀은 `[]`.
4. **`damage` 효과**: `status_id`에 피해 플래그(`advance_on_kill`/`ignore_defense`/`deterministic_followup`/"")를 넣는다. `from_cell`/`to_cell`은 **시전자** 셀이다. 처치 후 전진이 있으면 두 값이 다르다.
5. **`heal`/`status`/`cleanse`**: `from_cell`=`to_cell`=대상 셀이다. `cleanse`의 `status_id`는 실제로 지운 상태이고 `amount`는 0이다. `status`의 `amount`는 상태 강도(magnitude)다.
6. **`skill_finished.cooldown_turns`**: 쿨다운을 설정한 직후 엔진이 돌려주는 남은 쿨다운이다(실제 적용 값).
7. **`skill_cast.target_id`**: 자기대상 모드는 엔진이 시전자를 대상으로 쓰므로 시전자 ID가 들어간다.
8. **증원 기록 위치**: 지시문은 `_deploy_reinforce_unit`/`_deploy_city_reinforcement_unit` 성공 직후였다. `source`를 아는 곳이 호출부라서 호출부의 `if _deploy_…(unit):` 안(성공 직후)에 넣었다. `round_started`보다 앞이라는 것은 같다.
9. 무효 명령(피해 0, 회복 0, 턴 0 상태, 정화할 것 없음, 기세 변화 0, 이동 실패)은 기록하지 않는다.

## 7. 테스트 (CI 편입)

| 테스트 | 내용 | checks | 초(CI 재현, 커밋 2) |
|---|---|---|---|
| `test_battle_tactic_event_log_service` | 스키마 검증, 깊은 복사, 독립 순번, stage 1회 소비, 유닛 쓰기 없음, **기록이 난수를 소비하지 않음** | 15 | 0.53 |
| `test_battle_tactic_oracle_shard_1~4` | **BASE 대비 동등성** 50 시나리오(13/13/13/11): 유닛 40필드×10, 컨트롤러 12값, 기존 로그 3개, 체크포인트 3개(start/acted/settled) | 60/68/68/48 | 33.5/41.4/41.7/38.7 |
| `test_battle_tactic_dice_hook` | 훅으로 티어별 성공·실패·후보 강제(8경로), 훅 호출 순서(성공 시에만 후보), 훅 없음 == BASE 동등 훅(5케이스) | 96 | 31.9 |
| `test_battle_tactic_event_semantics` | 책략 8, 화상 틱, 확정 실패, 증원: 이벤트 == 기록 순간 상태, 순서 | 188 | 26.7 |
| `test_battle_tactic_skill_semantics_shard_1~2` | 특기 39케이스: skill_cast는 확정 때만(기세 소비량 == momentum_cost), 효과 amount == HP·기세 변화, killed == 생존 여부, move/전진 셀, 상태 턴, 명령 순서, cast→effect→finished 연속 | 664/603 | 64.8/62.6 |

시나리오 50개:
- 책략 8: basic/advanced/master × 성공·실패, advanced·master 후보 0·1(시드 탐색으로 유도)
- 특기 36: effect_type마다 하나씩(데이터 순서 첫 특기), 아군 수동 시전. 자기대상 3모드(`self`/`self_area_enemy`/`enemy_adjacent`)는 버튼 → 미리보기 → 자동 발동
- 특기 추가 4: 아군 자동(`_run_auto_action_for_active_ally_once`), 적 자동(적 턴), 처치 후 전진, 확정 실패
- 상태 틱 1: 아군 화상+동요, 적 화상
- 증원 1: 기본 배치 fixture 없이 라운드 3까지 대기만

명령 종류 6개(`damage/heal/status/cleanse/momentum/move`)가 모두 의미 테스트에서 실제로 나왔다.

- **골든**: `tests/golden/battle_tactic_baseline_v0.json`은 **BASE `608cb77` 워크트리**(기록 코드 없음)에서 `--update-golden`으로 생성했다. 케이스마다 2회 실행해 결정성을 확인했고 457 checks였다.
  - 커밋 1의 골든도 같은 방식으로 BASE에서 생성했다.
  - **커밋 2에서 골든을 다시 생성했다.** 이유: ① `K_rally_restore`의 아군이 풀 HP라 `heal`이 한 번도 나오지 않아 아군을 부상 상태로 바꿨다. ② `K_commit_failure`가 버튼 단계에서 거절돼 확정 실패 경로에 닿지 않아 자기대상 특기 + 미리보기 중 기세 0으로 바꿨다.
  - 두 골든의 차이는 이 두 케이스뿐이다(나머지 48개 바이트 동일, 비교 스크립트로 확인).
  - 생성 로그는 zip `evidence/s41_golden_generation/`.
- 기존 골든 4개(attack/move/enemy_turn/m3_start): 바이트 불변(validator SHA-256).
- 독립성: 기존 로그 3개의 소비자(M1~M4-a 3D 코드·테스트)를 수정 없이 전체 CI에서 통과했다. 새 로그 때문에 깨진 기존 테스트는 없다.

## 8. validator `tools/validate_battle_tactic_events_s4_1.py`

- BASE `608cb77d0d99e9cbefbfecd9ee0f02eb51b6a296`, TIP 기본 `HEAD`(`S4_1_SCOPE_TIP`로 고정). 기존 pinned validator는 수정하지 않았다.
- 검사 항목:
  - 변경 파일 화이트리스트, 3D 파일 diff 0, 기존 골든 4개 SHA-256
  - **컨트롤러**: 기록 줄·헤더 2줄·주사위 헬퍼 2개를 빼고 주사위 2줄을 되돌리면 BASE와 바이트 단위로 같다. 추가로 다음을 확인한다:
    - 새 함수는 헬퍼 2개뿐이고 본문이 고정돼 있다
    - 함수별 기록 줄이 정확히 일치한다
    - 기록 줄이 정해진 앞·뒤 줄 사이에 있다
    - 기록 줄에 난수·await·타이머·대입이 없다
    - `randf()`/`randi()`/`randf_range(` 개수가 BASE와 같다
    - 책략 난수는 헬퍼 안에만 있다
    - 기존 로그 사용 횟수가 변하지 않았다
    - 삭제 줄은 2줄이다
    - **보고서의 `CONTROLLER_DELTA` 줄과 같은 수치다**
  - **훅**: 컨트롤러는 선언만 하고 대입하지 않는다. `tests/` 밖(컨트롤러·validator 제외)에서는 `strategy_roll_override`를 언급하지 않는다.
  - **소비자**: 서비스 파일 말고 `tactic_event_log`를 쓰는 파일이 `tests/` 밖에 없다(3D 소비자 없음).
  - **서비스**: `RefCounted`이고 씬·타이머·await·시그널·난수·`Callable`이 없다. 멤버는 4개로 고정이고, 유닛 필드 쓰기와 유닛 변경 메서드 호출이 없다. 이벤트 종류 6개가 정확하고 export는 깊은 복사다.
  - **CI**: 워크플로가 BASE + 정해진 10줄과 정확히 같다.
  - **오라클**: effect_type 목록이 데이터와 같다(36종). 샤드 분할이 정확하다. 골든 `base_commit`이 BASE다. 케이스 순서가 하니스와 같다. 골든 키, 체크포인트 3개, 유닛 40필드, 컨트롤러 12값, 기존 로그 3개를 확인한다.
- `S4_1_SCOPE_TIP=<커밋2>` 고정 모드 실행 결과는 zip `evidence/s41_validator_pinned.txt`.

## 9. 변조 프로브 (새로 돌린 것, 10개)

- 방식: 컨트롤러 또는 서비스에 변조를 1개씩 적용하고 validator와 Godot 테스트를 돌린 뒤, 원래 바이트로 복원했다(`finally`, 복원 후 `cmp`로 확인).
- 러너는 zip `evidence/run_s41_probes.py`(치환 문자열 원문 포함), 결과는 `evidence/s41_probes/probes.json`과 각 로그.
- Godot 실패는 모두 parse/compile 오류 없이 단언 실패였다.

| 지시문 §5-8 항목 | 프로브 | validator | Godot 테스트 |
|---|---|---|---|
| 책략 성공 여부를 반대로 기록 | P1 | exit 1 (기록 줄 불일치) | exit 1 (의미: 성공 플래그·대상 상태) |
| 특기 이벤트를 확정 전에 기록 | P2 (spend 앞 → 플랜 검사 앞으로 이동) | exit 1 (기록 위치) | exit 1 (의미: 확정 실패인데 skill_cast) |
| 효과 amount에 요청값 기록 | P3 (`applied` → `amount`) | exit 1 (기록 줄 불일치) | exit 1 (특기 의미: HP 변화 ≠ 기록) |
| 증원 이벤트를 `round_started` 뒤로 | P4 | exit 1 (기록 줄 수) | exit 1 (의미: 배치 호출 밖 기록, 순서) |
| 이벤트 기록이 난수를 소비 | P5 (서비스 `record_strategy_cast`에 `randf()`) | exit 1 (서비스 난수 금지) | 서비스 테스트 **exit 1** / 오라클 shard 1 **exit 0(못 잡음)** |
| 훅이 비어 있어도 난수 순서 바뀜 | P6 (헬퍼에 `randi()` 추가) | exit 1 (헬퍼 본문) | exit 1 (오라클: 골든 불일치) |
| 서비스가 유닛 상태를 씀 | P7 (`target.intelligence -= 1`) | exit 1 (서비스 쓰기) | exit 1 (오라클: 골든 불일치) |
| 상태 틱 이벤트 누락 | P8 | exit 1 (기록 줄 수) | exit 1 (의미: 틱 이벤트 없음) |
| (추가) skill_finished를 쿨다운 설정 전에 기록 | P9 | exit 1 (기록 위치) | **exit 0 (못 잡음)** |
| (추가) 게임 코드에서 훅 설정 | P10 | exit 1 (헬퍼 본문) | exit 1 (오라클: 강제 성공으로 골든 불일치) |

- **P5**: 기록은 규칙 판정 뒤에 일어나서, 소비된 난수가 이후 FX에만 영향을 준다. 그래서 오라클은 이 변조를 못 잡는다. 서비스 단위 테스트(시드 고정 후 기록 → 다음 난수 비교)가 잡는다.
- **P9**: 데이터의 44개 특기가 모두 쿨다운 0이다. 그래서 설정 전에 읽어도 값이 같아 테스트가 못 잡는다. validator(위치 검사)만 잡는다.
- 대조군(변조 없음): validator, 의미, 특기 의미(처치 후 전진), 오라클 shard 1, 서비스 모두 exit 0.

## 10. 전체 CI 로컬 재현 (새로 돌린 것, 커밋마다 1회)

두 번 모두 순서는 같다: `.godot` 삭제 → `--headless --editor --import`(1회 만에 exit 0, signal 11 없음) → `verify-c-track.yml` 목록 그대로 실행. 러너는 M3-b·M4-a와 같은 `run_ci.py`다.

| 시점 | import | 단계 | validator | Godot 테스트 | 실패 | 합계 |
|---|---|---|---|---|---|---|
| 커밋 1 직전(S4-1a 코드) | 41초 | 127 | **36** | **86** (79 + 7) | 0 | 약 1,021초 |
| 커밋 2 직전(S4-1b 코드, 보고서만 자리표시) | 40초 | 130 | **37** (36 + 1) | **88** (79 + 9) | 0 | 약 1,208초 |

- 단계에는 위 두 항목 외에 씬 로드 3개, `--editor --quit-after 2`, `git diff --check`가 들어 있다.
- 실행 후 `git status`에는 이번 변경 파일만 있었다. 로그·`results.json`·`status_after.txt`는 zip `evidence/s41_ci_commit1/`, `evidence/s41_ci_commit2/`.
- CI 러너 `checks` 열은 마지막 `checks=` 숫자를 잡으므로 위 §7 표와 같다.

## 11. 새로 돌린 것 / 재사용

- **새로 돌린 것(이 세션)**:
  - 사전 확인 스크립트 1개(+디버그 1회)
  - BASE 워크트리 import 1회, 골든 생성 4회(1회차 이후 하니스 수정 때마다 다시 생성. 최종본만 커밋)
  - 신규 테스트 개발 실행, 이벤트 덤프 1회
  - 변조 프로브 1회(10개)
  - 전체 CI 재현 2회(커밋마다)
  - 커밋 후 validator 고정 모드 1회
- **재사용(코드)**: S3-1 오라클 하니스(SeamBattle, controller_state, `_setup_unit`, teardown), S3-1 서비스 구조와 validator 구조, M3-b/M4-a CI 러너 `run_ci.py`(변경 없음).
- 이전 보고서의 결과 수치는 재사용하지 않았다.

## 12. 남은 위험 / 기록할 점

- **골든 재생성(커밋 2)**: 커밋 1과 커밋 2의 골든이 2케이스 다르다(§7). 두 커밋 모두 각자의 골든으로 전체 CI를 통과했다. 이분 탐색 시 각 커밋은 자기 골든과 짝이 맞는다.
- **FX도 전역 난수를 쓴다**: 앞으로 FX 호출이 규칙 판정 **앞으로** 오도록 연출을 바꾸면, 같은 시드의 책략 결과가 바뀐다. 이것은 지금 코드에서도 같은 성질이고 이번 변경과 무관하다. 오라클은 행동 직전에 시드를 다시 걸어 영향을 받지 않는다.
- **훅의 우회 가능성**: 훅은 컨트롤러의 공개 멤버라 테스트 밖 코드가 설정할 수 있다. 지금은 validator가 `tests/` 밖의 사용을 막는다.
- P5(오라클 경로)와 P9는 테스트로 못 잡고 validator(와 P5는 서비스 테스트)만 잡는다.
- 오라클 4샤드 + 특기 의미 2샤드가 CI 시간을 약 5분 늘렸다(각 파일 120초 제한 안).
