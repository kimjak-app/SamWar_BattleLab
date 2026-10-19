# S1-0 — 전투 행동 → 이벤트 분리 설계 감사

- 작업일: 2026-10-19 / 작성: Codex / 검수 대기: 클코치
- 기준: `integration/p1-engine-core-20261019`의 **`62f5b726260aa3e6134225e7e903b1098792f23a`**. 최신 브랜치를 따라가지 않고 이 커밋을 고정해서 조사했다.
- 작업 브랜치: `docs/s1-0-action-event-audit-20261019`
- Plan revision: `BRP-20260919-1`; 검증 Level 1, 소스 대조와 문서 범위 검증만 수행.
- 변경 파일: 이 문서 1개. 코드·씬·테스트·validator·3D Lab·기존 문서는 변경하지 않았다. 로컬 커밋만 하며 push하지 않는다.
- 이 문서의 커밋 식별: 위 브랜치에서 `git rev-parse HEAD`; 실제 해시는 완료 메시지에 보고한다. 자기 자신의 커밋 해시를 본문에 넣어 재커밋하는 순환은 피한다.

## 결론

기존 규칙을 유지하면서 2D/3D가 같은 실행 결과를 표시하는 구조로 분리할 수 있다. 다만 현재 실행은 하나의 원자적 함수가 아니다. **이동 완료, 공격 적중, 행동 완료가 다른 시점에 상태를 변경한다.** 첫 분리에서는 그 경계를 유지한 동기식 서비스와 외부 진행 조정자를 두고, 반환된 이벤트를 화면에서 소비하는 방식을 권고한다. 모든 상태를 연출 시작 전에 한 번에 확정하는 변경은 이번 분리의 기본값으로 삼지 않는다.

핵심 발견:

1. 아군 기본 공격은 Tween을 예약한 직후 피해를 적용하고, 적 기본 공격은 0.16초 뒤 Tween 콜백에서 적용한다. 사망 정리와 행동 완료 순서도 다르다 (§A3).
2. 이동 취소는 실제 상태를 복원한다. 이동 이벤트 하나만 추가하면 취소·방향 선택·저장 경계가 누락된다 (§A1).
3. 현재 스킬 실행은 `BattleSkillResolver.build_plan` → 명령 적용이다. 예전 네 개 효과 함수는 정적 참조 검색상 정의만 남는다. **B-1H는 초기 이동/공격 실행 분리의 필수 선행 조건이 아니다** (§D).
4. 공격 후 이동은 플래그 설정·저장·초기화만 찾았고, 이를 소비하는 이동 경로는 찾지 못했다. 새 이벤트 구조가 이를 새 기능으로 활성화해서는 안 된다 (§F).
5. 책략 난수와 먼지·화살·화면 흔들림 난수가 전역 난수를 공유한다. 전투 시작 시 seed만 고정하는 것으로 분리 전후 골든 로그가 같다고 보장할 수 없다 (§E).
6. 군량 탈영, 증원, 혼란에 의한 행동 소진도 상태 변경 흐름이다. 기본 이동/공격만 옮기면 실행 엔진 분리가 끝나지 않는다.

## 읽는 법과 조사 경계

모든 줄 번호는 위 기준 커밋의 1-based 번호다. `C`는 `scripts/battle_web_import_test.gd`(실측 **15,861줄 / 864개 `func`**), `U`는 `scripts/battle_unit_state.gd`, `R`은 `scripts/battle/battle_skill_resolver.gd`, `SN`은 `scripts/battle/battle_runtime_snapshot.gd`, `M`은 `scripts/battle/battle_momentum_state.gd`를 뜻한다. 경로를 따로 쓴 인용은 해당 파일 기준이다. 범위는 함수 전체 또는 명시한 절단 후보 구간이며 반드시 전체 함수를 뜻하지는 않는다.

`scripts/battle/battle_controller.gd:1`은 C를 상속한다. 따라서 파일 이름이 test여도 아래 내용은 production 경유 실행의 감사다. **[확인]**은 소스에서 확인한 동작, **[제안]**은 새 계약, **[미확인]**은 런타임·외부 호출 등의 증거가 없는 부분이다. 실행·시각 검증은 이번 문서 작업에서 하지 않았다.

## A. 실행 흐름 인벤토리

### A1. 플레이어 이동, 방향 선택, 취소

- **입력/진입:** 버튼 연결 C1410–1446, `_input` C2457–2564. 유효 칸 클릭을 유닛 선택보다 먼저 처리(C2517–2523) → `_try_handle_valid_move_cell_click` C6267–6292 → `_try_direct_move_to_cell` C6295–6307 → `set_move_target_cell` → `play_basic_move_demo` C3198–3273. `_unhandled_input` C2567–2576은 좌/우 클릭을 실행하지 않는다.
- **판단:** intro/phase/animation/active/action-lock/has_moved 검사(C3199–3216); destination·range·path·occupied 검사(C3218–3239). 직접 클릭에는 UI 위 여부와 이동 overlay의 visible 자식 존재도 필요(C6239–6264). 후자는 엔진 규칙이 아닌 입력 허용 조건으로 남길 것.
- **상태와 연출 순서:** pending snapshot 저장(C3243, C7811–7829) → resolving/카메라/먼지 → 각 경로 구간 시작에서 `_apply_unit_movement_facing`(C3266, C15244–15254)이 실제 facing 변경 → Tween 마지막 `_finish_basic_move_demo` C3276–3306 → 좌표(C3283), has_moved(C3288), last_action(C3289–3294), ally_has_moved(C3295) → facing-select. **이동만으로 acted 등록하지 않는다.** moved_distance는 path 길이가 아니라 grid distance다.
- **방향 확정:** `_select_post_move_facing` C6473–6496 → facing/manual flag → pending snapshot 제거 → ally-turn 복귀/패널 표시. 자동 이동은 C3302–3305에서 자동 방향 선택을 호출한다.
- **취소:** 우클릭 C2467–2470 → `_handle_right_click_cancel` C7714–7718 → `_rollback_pending_ally_move` C7752–7808. snapshot의 grid/facing/has_moved/ally_has_moved와 marker 위치 복원(C7773–7788), 선택/overlay 정리. 저장 필드 목록 C7817–7828에는 **last_action이 없다**. 이를 새 rollback에서 몰래 복원하면 기존 동작과 달라진다.
- **절단:** 검증/경로 결과, 구간 facing, 최종 이동 commit, 방향 확정/rollback을 각각 상태 연산으로 정의. 입력 좌표 변환·Tween·marker·패널은 화면에 남긴다. 각 stage에는 actor_id를 고정하여 전역 active 선택 변화에 묶이지 않게 한다.

### A2. 적 이동

- **호출:** `_play_enemy_turn_demo` C7844 → `_play_enemy_ai_turn` C7848–7869 → `_play_enemy_ai_for_actor` C7872–7925 → decision reservation(C7916) → path query(C7917) → `_play_enemy_actor_path_move_then_act` C7987–8025.
- **판단:** path-clear(C7991), actor marker 존재(C7998–8003). marker가 없으면 **acted 처리 후 턴 진행**하므로 Node 부재가 규칙 결과에 영향을 준다.
- **변경/연출:** 구간 facing Tween 콜백(C8020), 최종 `_finish_enemy_actor_basic_move` C8032–8048에서 cell 변경(C8042), marker/먼지 정리 → `_play_enemy_actor_basic_attack_or_wait_after_move` C8055–8078.
- `_finish_enemy_basic_move` C8028–8029는 첫 적 유닛을 넘기는 wrapper다. 주 경로는 actor 함수다.
- **아군과 다른 점:** 적 이동 완료에는 has_moved/last_action 대입이 없다. 나중의 acted 처리(C13244–13257)가 has_moved를 true로 만든다. 아군 이동 commit을 그대로 공유하면 이동 후 공격·총병 판정이 달라질 수 있다.
- **절단:** 공통 cell/facing 연산은 재사용하되 아군/적 flags 정책을 유지. marker 부재의 기존 동작은 2D 호환 adapter에서 명시적으로 다루고 엔진은 Node를 보지 않는다.

### A3. 아군·적 기본 공격

| 흐름 | 진입 → 판단 → 변경 순서 | 연출/후속 |
|---|---|---|
| 플레이어 | `try_basic_attack` C3309 → `_enter_attack_select_mode` C3326(이동 후 공격 병종 계약 C3331) → 클릭 C2501 → `_try_attack_enemy_target_from_attack_select` C3352–3380(생존·사거리) → `play_basic_attack_demo` C3383 | C3421–3435 Tween 예약, C3437–3441 slash/발사체 실행 |
| 아군 적중 | C3443–3445 방향/부상 포함 피해 계산 → `U.apply_damage` → `_commit_basic_attack_unit_contract` C3446 → 양 진영 기세 C3447–3448 | C3449–3456 피격/수치/방어 반응. 표시 수치는 계산 피해 `attack_damage`, 실제 감소량과 다를 수 있음 |
| 아군 완료 | Tween.finished → `_finish_basic_attack_demo` C3470–3494 → acted(C3484, 상태 소진 포함) → dead cleanup(C3487) → end guard → enemy-turn | 선택/이동 snapshot/auto flags 정리, UI 갱신 |
| 적 시작 | `_play_enemy_actor_basic_attack_from_current_cell` C7932–7980: 대상 없으면 재선정, 없거나 죽었으면 acted 후 진행; 대상/actor 전역 저장, facing 갱신(C7948) | slash/발사체 후 0.16초 interval → `_enemy_reaction_hit_on`(C7966) |
| 적 적중 | C8081–8106: end guard → 저장된 대상 또는 fallback → 살아 있으면 피해(C8091) → 공격 계약(C8092) → 기세(C8093–8094) → dead cleanup(C8102) | C8095–8101 피격·숫자·방어 FX |
| 적 완료 | `_finish_enemy_actor_basic_attack` C8109–8115: **end guard 먼저**, 통과할 때 acted → `_advance_enemy_turn_or_return_to_ally` | 아군 완료와 guard/acted 순서를 동일화하지 말 것 |

- 공통 계산: C5497–5510 → `BattleCombatQueryService` 방향 판정 + `BattleDamageFormulaService.calculate_pre_wounded_damage`(해당 파일29–74) → C8540–8559 부상 배율. 배율 계산과 HP 적용은 다른 책임이다.
- 공격 계약 C5513–5531은 `attacked_this_turn`, `last_action`, 총병 `post_fire_penalty`, 공격 후 이동 플래그를 쓴다. 로그가 섞여 있으므로 숫자/상태 결과와 표시 메시지를 분리한다.
- 적 로그의 “반격”(C8106)을 새로운 counterattack 규칙 이벤트로 오해하지 말 것. 확인된 경로는 적의 기본 행동 공격이다.

### A4. 피해·부상·전멸·승패

- **피해 원시 연산:** U238–243은 요청 amount를 0 이상으로 만든 후 HP/병력을 각각 0으로 clamp하여 감소한다. 반환값은 `min(damage,current_hp_before)`이고 실제 병력 감소량과 동일하다는 보장은 없다. U234–235 생존 조건은 HP와 병력이 모두 양수.
- **회복:** U246–251은 HP/병력을 각 max까지 회복, 반환은 HP 증가량. 방어 회복 C6190–6197은 부족 HP 비율을 계산해 heal한다. 별도 wounded troop pool에서 차감하는 구현이 아니다.
- **장수 부상:** C8508–8559는 기존 registry의 wounded/status를 **읽어** 피해에 보정한다. C8478–8483은 context registry 우선, 정적 registry fallback. 감사한 공격 경로는 장수를 새로 wounded/dead로 기록하지 않는다.
- **전멸 정리:** `_cleanup_dead_units` C13782–13814: slot 순회 → 토스트 중복 집합/queue → visual/click 활성 → dead_unit_ids 신규 등록 → acted-id 제거 → 죽은 selected/strategy/pending/active 참조 정리 → 결과 표시 요청. `unit_defeated`와 장수 영구 사망은 다른 개념이다.
- **승패 판정:** C10265–10278 forced result 우선, 배치·활성·생존 아군/적 수 계산. 적0+아군>0이면 victory, 아군0이면 defeat(양쪽0 포함). 미배치 증원은 C8954–8966 필터로 제외된다.
- **종료 연출:** C10308–10327은 논리 종료를 읽고 auto/일반 toast를 차단; C10330–10347은 패배 토스트 큐가 끝날 때까지 결과 영상/토스트를 기다린다. C10115–10133이 다음 toast/결과 표시를 deferred 호출. 논리 종료와 결과 영상 완료를 구분해야 한다.
- **전략 결과 경계:** `_build_worldmap_battle_result_payload` C2845 → `_build_hero_outcomes_for_side` C2950–2971(생존/HP/병력 등) 및 C3012–3046(할당 병력 생존율, 탈영, `split_combat_losses` 결과 wounded/dead). 장수 영구 사망/포로/부상 정산의 전체 WorldMap 체인은 이번 감사 밖이며 미확인. 전투 damage마다 가상의 unit_wounded 이벤트를 만들지 않는다.
- **강제 종료:** 후퇴 버튼 C5870–5884는 context 검사 → reason/forced result=`retreat` → WorldMap 반환. 턴 제한 C11086–11092도 별도 결과 원인이다.

### A5. 행동 소진, 턴·라운드 진행

- 대기 `_end_ally_turn_by_wait` C6200–6236 → snapshot 제거/has_moved → `_mark_ally_unit_acted` → enemy-turn → 적 실행. 방어/책략/특기/기본 공격은 각자 완료 경로에서 같은 acted wrapper를 쓴다.
- `_mark_ally_unit_acted` C13216–13230 / 적 C13244–13257: B-1E service 등록 결과 `was_already_acted` 확인 → has_acted/has_moved → **첫 등록에만** `_consume_strategy_status_after_unit_action`.
- C4032–4044: burn을 먼저 피해 적용하고 상태 duration tick. 따라서 공격 대상 외에 **행동자도 완료 시 화상으로 전멸 가능**. 재등록에서 두 번 소진하지 않는다.
- 혼란/행동불능은 C3861–3866(`confusion/action_lock/fear`), 아군 C4158–4182/적 C7881–7886에서 acted와 턴 진행. `_set_phase` C5729–5732의 deferred 호출이 혼란/auto를 재진입시킨다.
- `_advance_enemy_turn_or_return_to_ally` C8122–8125는 `_return_to_ally_turn`만 호출. C8128–8135에서 양쪽 모두 소진이면 round_complete, 아군만 소진이면 enemy, 그 외 ally. “한 진영 전체가 한 번에 행동한다”는 일반 턴 모델로 바꾸지 않는다.
- `_return_to_ally_turn` C8138–8180: target/actor/pending 정리 → dead cleanup/end 확인 → next side → 필요 시 추가 적 행동 또는 새 round → 첫 사용 가능 아군 선택/ally phase/UI.
- `_start_new_round` C11079–11109: 종료 guard → 양 진영 소진 guard(강제 옵션 예외) → 30턴 제한 → round 증가 → round-end 기세 → **보급 정산** → pending 제거 → 아군 action reset → 적 reset+예약 clear → 아군 cooldown 다음 buff tick → 적 cooldown 다음 buff tick → 증원1 → 도시증원2 → 배너.
- reset은 U254–261에서 defend/attacked/post-attack/last_action도 초기화한다. 상태이상 tick과 cooldown/buff tick은 서로 다른 시점이다.
- 라운드 보급 C1583–1613은 탈영을 부대 순서대로 damage로 적용하고 cleanup을 부른다. 보급 중 전투 종료가 생긴 뒤에도 `_start_new_round`의 후속 reset/tick 문장은 계속되는 구조다. 증원 함수는 다시 종료 guard를 한다. 조기 return을 새로 넣는 것은 별도 동작 변경이다.

### A6. AI 결정 → 행동

- 적 actor 선택 C13278–13286: 고정 후보 순서 → active/deployed/alive → B-1E first_unacted.
- C7872–7925의 우선순위: 혼란 소진 → 즉시 처치 가능한 기본공격 → 고가치 특기 → 일반 decision plan → 공격/대기/예약+이동. 이동 뒤 C8055–8078에서는 처치 공격 → 고가치 특기 → 일반 공격 → fallback 특기 → 대기.
- 대상 C12780–12801: 거리 기준 preferred target. C12851–12874는 preferred/공격 가능/거리/slot 순서 정렬.
- `_build_enemy_ai_target_action_plan_for_actor` C12903–13011: 현재 공격 가능 → reachable cells 순회(path clear+예약) → MOVE_ATTACK/engagement/approach/WAIT. `_should_replace_enemy_ai_decision_plan` C12877–12900의 비교 순서: priority → preferred → distance → path length → slot.
- 전체 대상 비교 `_get_enemy_ai_decision_plan_for_actor` C13014 이후에서 candidate별 plan을 평가한다. engagement C14842–14902는 후보 목적지까지 긴 경로를 구해 이동력만큼 잘라 step을 선택하고 예약을 확인한다. 동률 시 기존 순회 순서도 보존해야 한다.
- 예약 기록 C12830–12834는 B-1F service, 적 round reset C13264–13268에서 clear. 예약은 실행을 끝낸 결과가 아니라 이동 계획 선택 직후에도 바뀐다(C7916–7921: 경로 실패 전 예약).
- 공격 점수 C13369–13408은 처치/사거리/손실 HP/거리/방향/slot, 동점에는 먼저 만난 후보 유지. 특기 후보는 C4394–4416과 R180 이후 score_plan을 경유한다.
- 아군 자동전투도 누락하면 안 된다: C13587–13617 tick → C13706–13735 처치 공격/고가치 특기/공격/이동/fallback 특기/대기. C13415–13429는 경로를 얻기 위해 active_unit_state/side를 임시 변경하고 복구한다. 순수 AI 추출 때 actor를 명시적 인자로 바꿔야 하는 결합점이다.
- 연출/입력/호출 scheduling은 컨트롤러에 남기고 결정 함수는 ID·순서가 고정된 후보·grid·예약 snapshot을 받는다. AI 선택 규칙을 개선하거나 전체 대상으로 재정렬하는 변경은 포함하지 않는다.

### A7. 공격 후 이동, 후퇴, 특기 이동/피해

- 공격 후 이동: C5529–5531 설정, U55–56/109–110/259–260/339–340/362–363 선언·설정·reset·저장·복원. 저장소 `.gd` 전체 검색에서 **소비/차감/실행 지점 없음**. 현 기본 공격 완료는 acted 처리한다. 동적 외부 호출까지 없다는 증명은 아니며 실행 UX는 미확인.
- 특기 준비: 수동 C4374–4391, 자동 C4394–4434 → `_begin_unique_skill_sequence` C4437–4500 → R129–177 build_plan → 성공 시 기세 spend(C4457) → pending plan → cut-in. cooldown은 여기서 설정하지 않고 완료(C5653)에서 설정한다.
- registry cut-in: signal C4573 또는 token fallback C4577 → C4588–4603에서 execution을 먼저 비운 후 apply→finalize. legacy route는 C4499–4500 두 timer. `_apply_unique_skill_effect_if_valid` C5024–5031은 caster alive와 presenting flag를 읽는다.
- 적용: C5194–5204 → `_apply_resolver_skill_plan` C5232–5316. **plan.commands 배열 순서**로 damage/heal/status/cleanse/momentum/move 실행. 대상 없거나 죽은 경우 skip 조건이 명령 종류별로 다름(예: cleanse는 null만 검사).
- damage C5252–5259: ignore_defense는 amount 그대로, 그 외 방향/방어 보정(공격자 wounded 보정 false); advance_on_kill이면 피해 직후 전진. status C5275–5283: 자신에게 적용하면 +1턴, 적 status_resist면 -1턴, 0이면 skip. cleanse C5319–5336은 정해진 목록에서 첫 상태 하나 제거.
- 전진 C5339–5346: target 방향 우세 축 한 칸(x 동률 우선), bounds/destination 확인 후 **cell만 변경**. facing/has_moved/last_action 쓰지 않는다.
- 후퇴 C5349–5370: ally는 -x, enemy는 +x, distance 최소1. 목적지만 검사, 중간 path-clear 검사는 없다. marker를 옮긴 뒤 cell 변경. 아군 marker 동기화가 인자 unit 대신 현재 selected ally helper를 쓰는 점은 §F의 의심 지점.
- resolver R267–330은 ordered command 생성, single_burst는 deterministic_followup, movement_charge는 retreat+counter_up; 양수 damage command가 있으면 적 기세 -2 명령을 끝에 넣는다. **계획의 damage 명령 존재와 실제 applied>0을 같은 조건으로 통합하지 말 것.**
- 예전 `_apply_unique_skill_cannon_aoe` C5377–5396, `_apply_unique_skill_ally_attack_buff` C5399–5410, `_apply_unique_skill_self_defense_single` C5413–5432, `_apply_unique_skill_single_damage_adjacent_shake` C5435–5460도 별도 피해/attack·defense mutation을 갖는다. `.gd/.tscn/.tres` 검색상 정의만 확인. 현재 dispatcher는 이 네 함수가 아니라 resolver 경로다. 삭제/재연결은 하지 않는다.
- 완료 C5639–5671: 연출 정리 → pending 제거 → cooldown → consumes_action에 따라 acted → cleanup → 결과 또는 다음 진영. consumes_action=false라도 현재 후속 진영 진행은 별도 분기로 유지된다.

### A8. 방어·상태·기세와 보조 변경 흐름

| 흐름 | 변경/판단 | 연출/범위 |
|---|---|---|
| 방어 | C6134–6187: is_defending=true, last_action=defend, 회복, acted(화상/tick), cleanup, 적 턴 | guard SFX·방어/회복 텍스트·HUD |
| 책략 | C3817–3854: 성공률→전역 randf, 성공 시 C3786 randi pool 선택→상태 적용→acted→cleanup→적 턴 | 카메라·성공/실패 텍스트. 실패도 행동 소모 |
| 일반 상태 | U282–290: turns=max(기존,신규), magnitude는 신규 값; turns<=0 제거. U293–313 tick | badge 목록은 상태 raw dictionary와 분리 |
| 기세 | 기본 공격 C6507–6515는 실제 HP applied>0일 때 공격자 gain/반대편 received-hit loss; 특기 spend C4457, 명령 C5295–5305, round C11094 | M의 gain/lose/spend/round 로직 재사용; M119–128 기존 event ring은 40개로 잘리므로 전체 전투 골든 로그로 부적합 |
| 옛 버프 | C5589–5636: attack bonus/turns 덮어쓰기, defense max 저장, attack 만료 시 양수 bonus만 attack에서 차감; 방어 만료 없음 | tick 후 formation/status refresh. 일반 U.status_effects와 다른 저장소 |
| 증원 | C9000–9052, C9129–9190: 배치 metadata, marker→cell, has_acted/has_moved=false, round2/도시 arrival 조건 | 카메라·배너·visible. spawn cell은 지금 씬에서 유래 |
| reset/복원/초기화 | C3049 이후 reset, C6605–6661 restore, C11759–11779 marker→cell, C11782–11806 QA preset, C8633 identity 보정 | 전투 행동 이벤트와 구분할 초기 snapshot 경계. QA를 실제 명령으로 옮기지 않음 |

위 인벤토리는 8개 요청 흐름 외에도 supply/retreat/deployment/reset/restore/facing을 포함한다. mutation 검색은 §G 명령으로 직접 쓰기와 주요 상태 API를 역추적했다. 정규식 검색은 동적 `call`/Dictionary 별칭/외부 subclass 전체 실행의 완전성 증명이 아니므로 G3 독립 검수는 여전히 필요하다.

## B. 규칙 / 연출 / 혼합 분류 및 절단점

| 대상 | 분류 | 절단할 구간과 소유권 |
|---|---|---|
| U238–317, M의 수치 연산, B-1B/C/D 서비스 | 순수 규칙/상태 연산 | 기존 소유자 재사용. 중복 계산 서비스 만들지 않음 |
| R129–177, R267–330 | 순수 계획 생성 | 명령을 실행된 이벤트로 부르지 않음. 실제 적용 시 after를 기록 |
| C3198–3273 이동 시작 | 혼합 | C3199–3239의 UI gate와 규칙 검증을 분리; C3241–3273 연출, C3243 snapshot은 상태 책임 |
| C3276–3306 이동 완료 | 혼합 | C3283/3288–3295 상태 commit; marker/guide/dust/phase UI는 controller |
| C7752–7829 취소/저장 | 혼합 | cell/facing/flags snapshot과 복원은 상태; marker 좌표는 2D adapter |
| C3383–3456, C8081–8106 적중 | 혼합 | C3443–3448 / C8088–8094 수치·공격 계약·기세; FX와 dead cleanup 호출 시점은 처음에는 그대로 |
| C5513–5531 공격 계약 | 혼합 | flags/status 쓰기와 log 분리. skill·자동 이동 기능을 새로 연결하지 않음 |
| C5232–5316 특기 명령 적용 | 혼합 | commands 순회/skip/상태 쓰기는 실행 service; target anchor/FX/표시 문구는 반환 결과 소비 |
| C5349–5370 후퇴 | 혼합 | bounds/destination/cell은 규칙, C5358–5368 marker는 표시 |
| C6134–6197 방어 | 혼합 | C6165–6167 및 C6193–6197 수치/방어 상태, C6176 행동 소진; UI/SFX 분리 |
| C3830–3843 책략 / C4032–4044 상태 소진 | 혼합 | 성공률/roll/상태·화상/tick는 규칙, 텍스트/refresh는 표시 |
| C13216–13268 acted/reset | 혼합 | B-1E 등록+flags+1회 tick 묶음, 로그와 active selection cache 분리 |
| C8128–8180, C11079–11109 턴 | 혼합 | side 결정/round·supply·tick·deploy 순서 보존; 화면 phase와 scheduling 분리 |
| C13782–13814 dead cleanup | 혼합 | dead registry/acted-id 정리는 규칙, 선택 해제/토스트/visible는 표시; 둘의 기존 interleave를 추적 |
| C10265–10278 승패 | 규칙(입력 adapter 의존) | active/deployed/alive와 forced reason을 값으로 전달 |
| C10330–10347 결과 표시 | 연출 중심의 혼합 | 논리 결과 조회와 toast queue 대기는 별개. battle_ended를 영상 완료 시점으로 늦추지 않음 |
| C12780–13078, C13369–13474, C14842–14902 AI | 규칙 중심/일부 혼합 | 후보·grid·예약은 데이터 인자, active 임시변경 제거는 별도 parity 필요 |
| C10404 이후 toast/FX, C4980·5010 await | 연출 | 서비스에 이동하지 않음. 전역 난수 사용은 §E 별도 경계 |

### 비동기/Node/난수 결합 표

| 근거 | 상태 순서에 주는 영향 | 분리 시 보존/대안 |
|---|---|---|
| C3266/3273, C8020/8025 Tween callback | facing은 구간 시작, cell은 끝 | 서비스는 synchronous stage 연산; 외부 coordinator가 같은 지점에 호출 |
| C3435 vs C3445 | 아군 HP 적용은 finished 이전, acted는 finished 뒤 | 적중과 완료를 분리 |
| C7966/7980 | 적 적중은 지연 콜백, 완료 guard 뒤 acted | actor/target/token을 고정하고 중복 완료 금지 |
| C3601, C4428 preview timer | 특기 commit 자체가 preview 후 발생 | preview는 값 미변경 표시, commit은 현재 gate 유지 |
| C4499–4500 legacy timer / C4573–4603 signal+fallback | 효과 적용과 cooldown/acted 완료 | 순서 및 1회성 토큰 보존. reset/종료 이후 stale callback은 별도 시험 |
| C5025–5028 | alive/presenting flag가 효과 적용 허용 | alive는 규칙, presenting의 취소 의미는 coordinator의 명시적 stage 상태로 전달 |
| C5729–5734 deferred+save | UI phase 설정이 혼란 소진/auto/저장을 촉발 | 논리 turn/입력 phase/영속화 port 분리, 같은 호출 checkpoint 유지 |
| C6246–6263 overlay visible / C7998–8003 marker null | 클릭 실행 허용 / 적 행동 소모 | UI gating을 규칙에 넣지 않음. 기존 2D fallback은 명시적 compatibility adapter |
| C9013–9015/9039–9041/11759–11779 | 씬 marker가 논리 좌표의 입력 | 출전 adapter에서 cell fixture를 한 번 전달. 3D mesh 좌표를 규칙으로 역주입 금지 |
| C10337, C10130–10133 | 결과 발표가 패배 토스트 큐를 기다림 | engine result 확정과 presentation drain을 구분 |
| C3786/3831 | 책략의 전역 RNG 결과가 규칙 결정 | roll 입력 기록·재생 권고. seed 보장 범위는 §E |
| C10475–11062 | 먼지/화살/총탄/스파크/카메라/랜덤 FX 선택도 전역 RNG 사용 | FX를 끄기만 해도 후속 책략 난수 소비열이 달라질 수 있음 |
| `scripts/audio/game_audio.gd:34,43,95,109` | 별도 `_rng`·real-time SFX 간격 | 게임 규칙 RNG와 별도; 오디오 타이밍은 골든 수치 로그에서 제외 |
| C2974–2976, C4639/5125/10093–10121 | result ID 및 연출 시간 로그에 실시간 포함 | 값 비교 시 시간/ID 정규화; ID 재생 계약은 별도 |
| C6164/5537, `scripts/ui/cutin/hero_cutin_presentation.gd:74` | guard/skill 오디오와 컷인 | service는 의미 키만 반환; Node/audio/resource 로드 금지 |

## C. 이벤트 규격 제안 (미구현)

### C1. 책임과 공통 형식

서비스는 `RefCounted`, Node/await/Tween/SceneTree/audio/ResourceLoader를 사용하지 않는다. 기존 query 서비스가 grid 인자를 받는 구조는 재사용하되 **논리 grid API만** 쓰고 grid_to_world/marker에 의존하지 않는다. SceneTree 밖에서 기존 grid를 만들 수 있는 것과 grid 자체가 RefCounted라는 주장은 다르다.

권고 반환 형태: `{ok, rejection_reason, action_id, stage, state_version_before, state_version_after, events: Array[Dictionary], continuation}`. 성공한 상태 변경의 결과만 이벤트로 기록한다. 거절은 rejected 결과이며 기세·cooldown·acted를 임의 소비하지 않는다(적 스킬 실패의 acted 같은 기존 wrapper 정책은 명시적으로 후속 stage에 남긴다).

모든 이벤트 공통: `schema_version`, `battle_id`, `action_id`, `event_id`, `sequence`(전투 내 단조 증가), `round`, `initiative_slot`, `stage`, `actor_id`(없으면 빈 값), `cause_event_id`, `cause_kind`, `command_index`(특기 명령/다중 타격), `state_version`. 좌표는 정수 `[x,y]`, 방향은 기존 right/left/up/down. JSON 직렬화 가능한 deep-copy 값만 전달하며 `BattleUnitState` 참조/Texture/Node/Vector3를 담지 않는다.

초기 unit view snapshot: unit_id/hero_id/slot_id/side/display_name/unit_type/visual_key/portrait_key/footprint/domain, grid_cell/facing, current/max HP·troops, allocated/initial_allocated_troops, status_effects, defending/action flags, active/deployed. 3D 높이·병사 표시 수·진형 배치는 화면 정책이다. 병력 1과 병사 모델 1을 동일시하지 않는다.

### C2. 이벤트별 필드와 양 화면의 소비

| 이벤트 | 추가 필수 필드 | 2D / 3D에 필요한 이유 |
|---|---|---|
| `action_started` / `action_completed` | action_kind, actor_id, target_ids, stage, flags_before/after, completion_reason | 입력 lock/animation lifecycle; complete와 turn-end를 혼동하지 않음 |
| `unit_moved` | unit_id, from/to, path(시작 포함), movement_kind(normal/retreat/advance), path_validated, facing_before/after, step_facings, flags_before/after, last_action_before/after, provisional_id | 2D 이동·먼지와 3D 높이 보간. 후퇴는 중간 경로 미검증을 명시, 실제 경로가 없으면 endpoints만 제공 |
| `facing_changed` | unit_id, from/to, reason(step/manual/target), path_step_index | 이동 중 수평 방향만 바꾸는 현 동작과 수동 4방향 재현. 단순 facing_after만으로 부족 |
| `move_confirmed` / `move_reverted` | provisional_id, unit_id, restored_fields, before/after, original_action_id | 방향 확정/우클릭 취소. rollback의 last_action 미복원까지 정확히 표현 |
| `unit_attacked` | attack_id, attacker/target_id, cells/facings_at_hit, unit_types, angle_type, attack_kind, base_damage, calculated_damage, hp_applied, troop_delta, defender_was_defending, damage_event_id | 공격 요약/방향·투사체·방어 반응. 같은 피해를 이 이벤트와 damaged에서 이중 적용하지 않음 |
| `unit_damaged` | attack_id(optional), target/source_id, cause, requested_damage, hp_applied, hp_before/after/max, troops_before/after/max, alive_before/after, display_amount, display_amount_kind | HP와 병력이 다를 수 있음. 기본공격 숫자는 calculated, 특기는 applied 등 기존 표시 차이 보존. burn/supply도 표현 |
| `unit_healed` | unit/source_id, cause, requested_amount, hp/troops before/after/max, hp_recovered, display_amount | 방어 회복/특기 회복과 병사 표시 증가. wounded pool를 지어내지 않음 |
| `unit_wounded` | **예약만**: unit/hero_id, wound_kind, before/after, source | 현재 전투 피해 흐름에 장수 부상 확정 write가 없으므로 발행 금지. 향후 정산 port 증거 확보 후 규격 확정 |
| `unit_defeated` | unit_id, side, cell/facing, final_hp/troops, cause_id, hero/portrait/display identity, first_detection | 시체/부대 소멸과 전투이탈 토스트. 영구 장수 사망을 의미하지 않음; 중복 cleanup에 중복 발행 금지 |
| `status_changed` | unit_id, status_id, old_raw/new_raw, turns/magnitude before/after, reason(apply/tick/cleanse/expire), source_id | legacy int와 dictionary 모두 보존. 상태 배지·색·3D 표식 |
| `defense_changed`, `action_flags_changed`, `stat_changed` | unit_id, fields before/after, reason, source_id | 방어/reset/옛 attack·defense buff 만료. status와 별개 수치를 빠뜨리지 않음 |
| `momentum_changed` | side, before/after, requested_delta, actual_delta, reason, source_id | cap/clamp·gain/spend 차이, HUD. 기존 40-entry ring과 별도 전량 수집 |
| `skill_used` / `skill_resolved` | skill_id, hero/caster_id, target_ids(순서), effect_type/archetype, resolver_version, effective_cost, stage, effect_summary | 컷인 시작은 사용 확정, 피해/상태는 이후 실제 결과. target_ids/효과 순서로 3D 다중 대상 연출 |
| `cooldown_changed` | cooldown_key(hero_id), old/new_remaining, reason, caster_unit_id | unit_id로 키를 잘못 바꾸지 않음 |
| `strategy_resolved` | caster/target_id, success_rate, roll_value, outcome_roll/index, outcome_id, success | 실패 연출도 필요. 실패에서는 outcome roll 미소비를 기록 |
| `ai_decision`(진단 선택) | actor/target_id, destination, action_reason, reservation changes, ordered candidate IDs | 실제 행동 이벤트와 구분; 동점/예약 parity 검증용 |
| `turn_started` / `turn_ended` | side, actor_id(optional), round, initiative_slot, reason, next_side | 현 번갈아 행동 slot 의미. UI facing/target select phase를 새 turn으로 세지 않음 |
| `round_started` / `round_ended` | previous/new_round, reason, action reset IDs | cooldown/supply/deployment의 실제 sequence를 따름; 아래 C3 참고 |
| `unit_deployed`, `supply_changed` | unit snapshot+slot/entry_rule/arrival_round; supply side before/after+deserters | 증원/탈영을 보여줄 정보. 수치는 기존 supply port 결과 사용 |
| `battle_ended` | result, reason, round, survivor IDs, final-state version, result_id | 논리 결과를 한 번 발표. WorldMap 영속 정산은 외부 owner 유지 |

발사체 위치/픽셀 offset/3D 지형 높이는 snapshot cell과 각 renderer의 projection으로 얻는다. `visual_key/attack_fx_profile/move_fx_profile` 등 표시 metadata는 unit snapshot에 함께 제공하거나 ID로 읽는 고정 catalog에서 얻는다. 컷인·토스트 로컬라이즈 문자열/리소스는 renderer registry가 hero/skill/cause로 선택한다. 기존 2D 특수 연출의 완전한 재현은 이벤트 필드 설계만으로 증명하지 못하며 S1 단계마다 시각 검증이 필요하다.

### C3. 발생 순서와 진행 방식

**상태를 바꾼 순서와 이벤트 sequence를 일치**시킨다. 여러 명령 결과를 종류별로 재정렬하지 않는다. 요약 `unit_attacked`는 적중 계산 결과를 참조하는 비변경 이벤트이고, 상태 갱신의 유일한 payload는 `unit_damaged` 등 before/after다. 화면은 엔진 상태를 다시 변경하지 않는다.

호환 stage 제안:

- 이동: prepare(검증/경로/취소 snapshot) → 각 step의 facing 적용 → finish(cell/flags/last_action, unit_moved) → manual confirm 또는 revert. 경로 재생 시작에 필요한 plan은 **명령의 preview/continuation 데이터**이며 아직 발생하지 않은 unit_moved라고 기록하지 않는다.
- 아군 기본공격: prepare → hit(피해→공격 flags/status→조건부 양 진영 기세) → 기존 finished 지점에서 acted→burn→status tick→cleanup→result 또는 enemy slot. 적은 prepare/방향→기존 hit callback에서 damage/flags/기세/cleanup→finished에서 end guard→acted/후속을 유지한다. 결과 종료 뒤 완료 쓰기 여부도 양쪽 현 동작을 각각 보존한다.
- 특기: plan 검증→기세 spend→skill_used→외부 cut-in→ordered commands 적용(advance_on_kill은 해당 damage 직후)→cleanup→finalize cooldown→선택적 acted/화상/tick→cleanup→후속. signal/fallback의 동일 token 중복을 거절한다. 기존 legacy timer 순서 경계도 비교한다.
- round: 현재 round 증가가 momentum/supply보다 먼저다. `round_started(stage=state_increment)`를 그 위치에 발행하고 마지막에는 `round_started`를 다시 발행하지 않고 별도 continuation의 `round_ready`로 입력 허용을 알린다. `round_ended`는 이전 라운드의 소진 사실이며 수치 변경이 없는 메타 이벤트로 증가 직전에 기록한다. supply 중 terminal이 생겨도 현재 후속 쓰기를 삭제하지 말고 같은 batch에서 기록; terminal 이후 신규 명령 금지와 이미 시작된 batch 완료를 구별한다.
- 결과 토스트 큐가 논리 종료보다 늦게 끝나도 `battle_ended`를 재발행하지 않는다. 화면은 presentation queue를 끝내고 결과를 표시한다. cutoff로 toast 생략되는 현 정책은 renderer 담당.

서비스 안에서 화면 완료를 기다리지 않는다. 외부 coordinator가 기존 Tween/timer/signal 지점에서 `advance(action_id, expected_stage)`를 동기 호출한다. 테스트 runner는 같은 stage를 즉시 진행한다. stage 검증/중복 거절의 상태는 RefCounted action session에 두고, Node signal은 화면/조정자 내부에서만 사용한다. 이것은 이행 설계이며 전투 전체를 즉시 resolve하는 모델로의 변경은 별도 승인·동작 검증 대상이다.

| 전달 방식 | 장점 | 위험 | 권고 |
|---|---|---|---|
| 반환 리스트 | 호출 시점/순서/골든 비교/오류 범위 명확 | 다단계 행동을 명시해야 함 | **서비스 기본 계약으로 채택** |
| 시그널 | 화면 연결 편리 | 재진입·구독 순서·중간 상태 관찰, 누락된 listener | 엔진 내부에 사용하지 않고 바깥 adapter에서만 선택 |
| 엔진 보유 큐 | 다중 consumer/재생 가능 | drain 소유권·중복·누락·snapshot 의무 추가 | 초기에는 보류. coordinator가 반환 batch를 표시 큐에 넣는 것은 허용 |

## D. 분리 순서 제안

아래는 구현 승인이 아니라 후속 작업안이다. 각 행은 독립 커밋/검증 단위다. 동일한 상태 연산을 2D/3D에서 중복 실행하는 shadow mode는 금지하고, 비교 시 **분리된 clone fixture**를 쓴다. rollback은 해당 작업 커밋을 별도 revert하여 기존 wrapper 경로로 되돌리는 방식이며 사용자 작업 reset/stash는 하지 않는다.

| 조각 | 옮길 것 / 컨트롤러에 남길 것 | 의존 | 위험도 | 검증 / 롤백 |
|---|---|---|---|---|
| S1-1 | stage·event schema와 관찰 checkpoint, 별도 clone 비교 fixture. 실제 실행 owner는 유지 | S1-0 검수 | Level 1(관찰만); 실행 훅 영향 시2 | 기록 유무로 상태 동일, ID/순서·깊은 복사 / 관찰 커밋 revert |
| S1-2 | 아군 이동 검증/finish/facing/rollback 상태 연산. Tween·클릭·overlay는 유지 | 1, 기존 B-1B/C/E | Level 2 | 우회/장애물/범위/확정/취소/last_action·snapshot·각 단계 방향 parity / 아군 wrapper revert |
| S1-3 | 적 이동 상태 연산, 아군과 다른 flags 보존. marker fallback/AI 선택은 유지 | 2 | Level 2 | 이동 후 has_moved/총병/marker 누락/예약 실패/대기 / 적 wrapper revert |
| S1-4 | 피해·회복 적용 결과, wounded 배율 입력 port. FX/정산 registry lookup은 adapter | 1, B-1D | Level 2 | overkill/HP≠troops/0/회복 cap/부상 보정, 표시 amount 차이 / 적용 wrapper revert |
| S1-5 | acted+일회 burn/tick, 방어·대기 상태 연산. phase scheduling/UI 유지 | 4, B-1E | Level 2 | 중복 acted/화상 사망/방어 회복/혼란 skip/상태 int·dict / lifecycle wrapper revert |
| S1-6 | 기본 공격 hit와 unit contract·기세 결과. prepare/finished 위치·cleanup 호출은 유지 | 4–5, B-1C/D/E | Level 2 | 아군/적 hit 시점·gunner status·후방·기세cap·terminal guard 비교 / 공격 wrapper revert |
| S1-7 | dead registry/acted erase/승패 판정. 선택/visible/toast/WorldMap 반환 유지 | 5–6 | Level 2 | 첫 사망/중복 cleanup/양쪽0/미배치 증원/다중 사망 토스트 순서 / cleanup wrapper revert |
| S1-8 | 책략의 roll 입력·성공/실패 적용, 일반 상태 변경 결과. 문구/카메라 유지 | 5, RNG 결정 승인 | Level 2 | 같은 기록 roll로 성공/실패/상태 덮어쓰기/화상·연출 RNG 간섭 비교 / 책략 wrapper revert |
| S1-9a | resolver commands 적용 중 damage/heal/status/cleanse/momentum. 컷인/commit/finalize 유지 | 4–7, 기존 R | Level 2 | 명령 배열/중복 대상/죽은 대상 skip/자기+1/status_resist/실제0피해시기세 / 명령 wrapper revert |
| S1-9b | resolver retreat/advance 상태 연산. marker는 presentation | 2–3,9a | Level 2 | 경계/점유/중간 장애물/전진 축 동률/비선택 ally / 이동 명령 wrapper revert |
| S1-9c | skill commit/spend/cooldown/finalize stage. timers/signal은 외부 coordinator | 9a–b, B-1G | Level 3 | 실패·중복signal+fallback·취소·전멸·consumes_action=false·연속 특기, 2D 실제 컷인 / stage 연결 revert |
| S1-10a | AI 대상/점수/이동계획 순수화. 실행 선택 순서와 예약 commit은 유지 | 3,6, 기존 B-1F/R | Level 2 | 동점·후보순서·막힘·engagement·처치/스킬 우선·예약 parity / AI wrappers revert |
| S1-10b | AI action dispatch와 양측 소진/다음 slot 결정. 실제 scheduling은 coordinator | 5–7,9c,10a | Level 3 | 5v5/혼란/한쪽 조기소진/auto safety/선택 유닛 제거 / dispatch revert |
| S1-11a | round reset/cooldown/buff tick·기세. supply/deploy 호출 port는 기존 순서 | 10b; B-1H는 아래 조건 | Level 3 | round2/30턴/버프 만료/방어 reset/기세 순서; 미분리 port가 있어 완전 엔진 완료 아님 / round wrapper revert |
| S1-11b | 증원 배치 데이터·보급 결과 적용 port. marker→cell 초기 adapter/WorldMap 정산 유지 | 7,11a | Level 3 | 탈영 중 종료/미배치/도시 arrival/empty arrival·snapshot roundtrip / supply/deploy 경계 revert |
| S1-12 | 새 실행 port를 3D에 연결, 2D renderer 소비 경로 검증. WorldMap 진입 교체는 별도 | 관련 실행 조각+최종 gate | Level 3 | 같은 initial snapshot+commands로 2D/3D 최종 상태·event trace 동일; camera/select/move 실제 확인 / 새 연결 revert |

S1-2~3 통과 후에는 별도 작은 3D 이동 실행 실험을 할 수 있지만, 공격/턴/스킬까지 연결된 엔진이라고 부르지 않는다. S1-12는 전체 연결의 검증 지점이다. S1-9a/9b/9c와 10a/10b, 11a/11b는 각각 별도 브리프로 발행한다.

### B-1H의 위치

**판정: 독립적인 상태 저장소 추출. 초기 S1 이동/공격의 필수 선행 조건이 아니며 보류 가능.** C959–961의 세 dictionary와 C5589–5636의 연산이 범위다. 현재 resolver의 버프는 U.status_effects 명령이고(R333–365), 예전 direct attack/defense 변경 함수의 정적 호출은 발견하지 못했다. 그렇다고 옛 저장소를 dead code로 단정하지 않는다. getter는 UI/AI에서 계속 읽고 tick/reset도 살아 있다.

권고 순서: S1-1 관찰 기준 확보 → 필요 시 **별도 B-1H**로 세 dictionary만 추출 → S1-11a에서 facade를 사용. B-1H를 보류하면 S1-11a는 기존 buff tick callback port를 유지하며 완전한 Node 독립 round service 완료로 보지 않는다. 추후 port 해소가 필요하다. 스냅샷에 버프를 추가하는 변경은 B-1H에도 S1 분리에도 끼워 넣지 않는다.

## E. 2D 동작 불변 검증 전략

### E1. 무엇을 비교할 것인가

새 서비스 결과를 자기 자신과 비교하지 않는다. 기준 C의 기존 wrapper를 **oracle**로 삼고, 독립적으로 복제한 초기 상태에서 새 서비스 결과와 stage별 비교한다. 다음을 함께 기록한다.

- 명령(입력 actor/target/cell/facing), 거절 사유, stage 순서, rule RNG 입력/소비 수.
- 전체 unit runtime + attack/defense/allocated + capacity active/deployed, acted-id, cooldown, 세 legacy buff dictionary, reservations, dead IDs, momentum, supply, round/논리 side/결과.
- phase/selection/pending move/cutin token 같은 coordinator checkpoint. engine state와 별도 trace로 저장하되 차이를 숨기지 않음.
- canonical event 배열의 **배열 순서는 유지**하고 dictionary key만 정규화. 임의 timestamp/노드 인스턴스ID/픽셀·카메라값/로컬 경로는 수치 골든에서 제외. cell/facing/실제 수치는 제외 금지.
- 기존 `serialize_battle_runtime`만으로 전체 상태를 비교했다고 하지 않는다. attack/defense, buff registry, AI reservations 등 누락 필드가 있다.

필수 fixture: 우회/막힌 이동/방향 확정/우클릭 취소; ally/enemy 이동 flags 차이; 각 병종·정면/측후방·부상·방어·overkill; burn 자기 전멸; 상태 재적용/만료/cleanse; 비용 부족·스킬 다중타격·컷인 중단·중복 callback; 공격 후 이동 플래그 **미소비 현상**; AI 동률/예약; 3+2 증원; 양측·한측 소진; round30; 보급 탈영 중 종료; 저장/복원.

### E2. seed 고정의 한계와 대안

**[확인]** 규칙 random 호출은 감사한 C에서 책략 C3786/3831. FX도 같은 파일에서 전역 randf/randi 계열을 많이 사용한다. R과 B-1 서비스 검색에서는 해당 random 호출이 없었다. 오디오 자체 pitch는 별도 RNG를 쓴다.

**[추론]** seed 고정 + 동일 엔진/리소스/모든 호출 순서를 유지한 run은 재현 가능성을 높이지만, FX를 옮기거나 headless에서 생략하면 규칙 난수열까지 바뀔 수 있다. Tween callback 순서·reset·cut-in fallback도 seed로 고정되지 않는다. 따라서 “seed만 같으면 골든 전체가 반드시 동일”을 승인 기준으로 삼지 않는다.

**[권고]** S1-1에서는 기존 책략 roll의 값·호출 종류·호출 순번을 관찰한다. 추출 비교에서는 동일 roll tape를 주입해 연산을 비교하고 소비 수까지 일치시킨다. 초기 production adapter는 기존 전역 RNG 호출 위치·횟수를 유지한다. 별도 rule RNG 도입은 재현성 개선이지만 과거 seed 결과가 달라지는 계약 변경이므로 별도 결정/검증으로 분리한다. FX의 난수 소비를 fake로 고정 개수 복제하는 우회는 쓰지 않는다.

기존 코드에 전체 action event logger가 이미 있다는 증거는 없다. M의 ring은 기세만, 최대40개다. 골든 파일 및 관찰 fixture는 **후속 S1-1에서 만들 제안**이며 이번 감사에서 생성/실행하지 않았다.

### E3. headless 범위와 GameAudio 전제

실행 브리프의 “GameAudio 때문에 `--script`에서 Battle_Main 로드가 막혀 있다”는 설명은 **항상 성립하는 사실로 확인되지 않았다**. 기준 소스에는 이미 다음이 있다.

- `tests/scripts/test_battle_movement_query_service.gd:11–23`: `_initialize`에서 `call_deferred("_run")`; 86–118에서 Battle_Main을 동적 load/instantiate, root에 추가하고 process_frame 후 wrapper parity; 123 이후 GameAudio fixture 종료 처리.
- `tests/scripts/test_battle_damage_formula_service.gd:115–143`에도 scene wrapper parity/audio 정리.
- `.github/workflows/verify-c-track.yml`은 class-cache import, 기존 `--headless --path . --script` tests, Battle_Main 임시 load script(208–226)를 정의한다. 임시 파일은 저장소에 상시 존재하지 않는다.

따라서 **순수 RefCounted 계산/상태 테스트는 headless 우선**, 기존 SceneTree fixture 패턴을 재사용하는 wrapper 테스트는 bootstrap/오토로드/로드 시점 구분 후 검증하는 것이 맞다. static preload/초기화 단계 로드와 deferred dynamic load를 같은 실패로 취급하지 않는다. 이번 기준에서 실제 실행 성공/실패는 **미검증**이다. 이 문서 작업을 위해 새 test 파일이나 임시 scene-load 파일을 만들지 않았다.

기존 재현 명령(실행 권고, 이번에 실행한 것으로 보고하지 않음):

```powershell
godot --headless --editor --path . --import
godot --headless --path . --script res://tests/scripts/test_battle_movement_query_service.gd
godot --headless --path . --script res://tests/scripts/test_battle_combat_query_service.gd
godot --headless --path . --script res://tests/scripts/test_battle_damage_formula_service.gd
godot --headless --path . --script res://tests/scripts/test_battle_action_lock_state_service.gd
godot --headless --path . --script res://tests/scripts/test_battle_enemy_ai_reservation_state_service.gd
godot --headless --path . --script res://tests/scripts/test_battle_unique_skill_cooldown_state_service.gd
```

전체 전투 scripted replay의 headless 완주는 현재 코드 검색만으로 입증되지 않았다. 우선 경계별 wrapper oracle, 다음 일반 scene runner에서 스크립트된 전투와 real frame presentation smoke. 만약 bootstrap 문제가 재현되면 순수 service fixture와 UI 실행 fixture를 분리하고 실패 로그를 남긴다. GameAudio 전역을 제거하거나 가짜 성공으로 치환하지 않는다. 영상/음향/입력/병사 배치의 시각적 동일성은 headless 수치 로그로 증명하지 못하므로 실제 2D/3D 렌더 검증이 필요하다.

## F. 위험·미정·김작 결정 사항

### F1. 저장/이어하기 영향 (해결하지 않음)

- C6575–6599는 phase ally/enemy만 저장; pending 이동/facing-select/컷인 stage는 스키마에 없다. C5729–5734는 deferred 행동보다 앞서 save를 호출할 수 있다. 새 stage/queue를 추가하면서 저장 호출을 앞당기거나 늦추면 재실행/누락 위험.
- U324–340은 status_effects와 post-attack flags는 저장하지만 attack/defense·옛 buff dictionary는 저장하지 않는다. C6593 cooldowns는 hero 키 service export; C6627 그대로 restore. B-1H 저장 추가 금지와 구분한다.
- C6588–6599에는 AI 예약, pending_unique_skill_plan, RNG state, event sequence/소비 cursor가 없다. 전체 이벤트 재생/중간 행동 resume를 지원한다고 약속할 수 없다.
- SN30–58 restore는 unit을 순서대로 복원한 뒤 실패할 수도 있어 트랜잭션 복원과 같지 않다. schema 변경/원자성 수정은 별도 작업.
- 전멸 논리 registry와 토스트 shown 집합은 다른 수명이다. 복원 후 표현 재생 정책을 바꾸지 말 것. WorldMap 결과의 실시간 result_id(C2976)와 새 event/action ID의 멱등성은 별도 계약 필요.

### F2. 의도 확인 전 고치지 않을 지점

| 지점 | 확인한 현상 / 불확실성 |
|---|---|
| C3289–3294 vs C7773–7778/7817–7828 | 취소에서 last_action 미복원, moved_distance는 우회 path 길이 아님. 의도 미확인 |
| C8042 vs C3288–3295 | 적 이동은 has_moved/last_action 미기록. 총병/이동 후 공격에 영향 가능, 임의 대칭화 금지 |
| C5530–5531 / 전체 검색 | 공격 후 이동 플래그 소비 없음. UX 완성 여부 미확인, 자동 활성화 금지 |
| C5352–5357 | 후퇴는 side 고정 x방향·목적지만 검사. 경유 칸 충돌 검사를 추가하면 행동 변화 |
| C5360–5361 | 인자 unit과 selected ally가 다를 때 marker 불일치 가능. 실제 재현 미확인 |
| C5346 | 전진은 cell만 변경. marker/facing 동기화의 실제 화면 결과 미확인 |
| C5377–5460 / R dispatcher | 옛 효과 함수는 정적 caller 없음. 런타임 동적/외부 subclass까지 미사용 확정 못함 |
| C5589–5636 | 옛 defense max merge/무기한, attack 만료·양수 bonus만 복원. 의도 미확인, B-1H 여섯 비대칭 유지 |
| C3484–3488 vs C8110–8115 | terminal에서 acted/burn 소진이 양측 비대칭. 통일 금지 |
| C11097 이후 | supply로 종료되어도 같은 round 함수의 reset/tick 계속. 새 조기 return 금지 |
| C10270–10273 | 양쪽 전멸은 defeat, 미배치 증원은 생존 집계에서 제외. 바꾸지 않음 |
| C5654–5671 | consumes_action=false라도 다음 진영 흐름 진행. 임의로 계속 행동하도록 변경 금지 |
| U238–251 / C3445–3452 | hp applied·troop 감소·표시 숫자가 서로 다를 수 있음. 한 damage 필드로 축약 금지 |
| C5295–5305 / R328–329 | 스킬 계획에 damage 있으면 기세 감소 명령 생성, 실제 hit0과 조건 다름. 기본공격 정책으로 통일 금지 |

### F3. 김작에게 필요한 선택 (후속 구현 전)

1. **첫 실행 연결 범위:** (A) 이동+취소+방향부터, (B) 공격/턴까지 동시. **A 권고**. S1-2~3에서 검증 가능한 경계 확보 후 다음 단계 진행.
2. **상태 적용 시점:** (A) 기존 prepare/hit/finish 경계 유지, (B) 행동 시작 때 전체 resolve. **A 권고**. B는 저장/화상/종료/AI 관찰 시점까지 달라질 수 있어 별도 기능 변경이다.
3. **B-1H:** (A) 관찰 기준 후 별도 추출, (B) 보류하고 round에 기존 port 유지. **A 권고**, 단 S1-2의 착수 조건은 아니다. 현재 활성 resolver buff와 옛 dictionary를 합치지 않는다.
4. **난수 재현:** (A) 기존 호출 유지+roll tape parity, (B) 즉시 전용 seeded rule RNG 도입. **A 권고**. B는 이후 독립 변경으로 승인받는다.
5. **기존 비대칭/누락:** (A) 분리 중 그대로 고정하고 별도 이슈, (B) 분리와 함께 수정. **A 권고**. 공격 후 이동/버프 저장 개선 여부는 별도 작업에서 결정한다.

위 추천은 설계 제안이며 사용자 승인으로 기록하지 않았다. 감사 완료를 막는 질문은 아니고 후속 구현 브리프에서 선택하면 된다.

### F4. 확인하지 못한 부분

- 실제 플레이에서 모든 특기 종류·옛 효과 함수가 호출되는지, 동적 외부 caller 여부.
- 현재 기준의 GameAudio/bootstrap 오류 재현, headless 전체 scripted battle 완주.
- Tween/timer/frame 경합 및 cut-in reset/fallback 중복의 모든 런타임 경로.
- 전진/후퇴 시 marker 불일치의 실제 2D 화면 재현.
- 전체 WorldMap 영구 장수 부상·사망·포로 정산 체인 및 모든 subclass override의 실행 parity.
- 제안 이벤트만으로 모든 2D 컷인/FX가 완전히 재현되는지와 3D 병사 단위 연출. 구현 후 검증 사항.
- §F2 각 비대칭의 기획 의도. 현재 버그라고 단정하지 않았다.

## G. 재현 가능한 탐색/검증 기록

독립 로컬 복제본에서 기준 커밋으로 브랜치를 생성했다. 원본 저장소와 이전 3D checkout은 수정하지 않았다. 기준 branch 이름이 아닌 커밋을 직접 사용했다.

```powershell
git rev-parse HEAD
git status --short --branch
rg -n '^func ' scripts/battle_web_import_test.gd
rg -n '(await |\.connect\(|tween_callback|call_deferred|randf|randi|Time\.)' scripts/battle_web_import_test.gd
rg -n '(apply_damage|\.heal\(|apply_status_effect|tick_status_effects|reset_action_flags|set_grid_cell|has_acted\s*=|has_moved\s*=|is_defending\s*=|battle_momentum\.)' scripts/battle_web_import_test.gd
rg -n '(post_attack_move_available|remaining_post_attack_move)' --glob '*.gd'
rg -n '_apply_unique_skill_(cannon_aoe|ally_attack_buff|self_defense_single|single_damage_adjacent_shake)' --glob '*.gd' --glob '*.tscn' --glob '*.tres'
rg -n '(randf|randi|randomize|seed\(|RandomNumberGenerator)' scripts/battle_web_import_test.gd scripts/battle/battle_skill_resolver.gd scripts/battle/services
rg -n '(GameAudio|Battle_Main|call_deferred)' tests/scripts/test_battle_movement_query_service.gd tests/scripts/test_battle_damage_formula_service.gd .github/workflows
```

줄 번호가 있는 본문은 PowerShell의 `$s=Get-Content <path>; for($i=<start>;$i -le <end>;$i++){ '{0}: {1}' -f $i,$s[$i-1] }`로 읽었다(0-based 배열에 1-based 줄 번호 부여). 추가로 Python 표준 라이브러리 인라인 검색으로 상태 쓰기를 함수명에 대응시켰다. 별도 코드/테스트 파일은 만들지 않았다.

검수자가 코드와 대조하기 쉬운 사실 표(무작위 G2 검수의 대체가 아닌 자체 근거 목록):

| ID | 사실 | 기준 근거 |
|---|---|---|
| V01 | 아군 이동 cell은 finish에서 쓴다 | C3283 |
| V02 | 아군 이동 has_moved=true | C3288 |
| V03 | 아군 공격 피해는 finished callback 본문이 아니다 | C3435,3445 |
| V04 | 적 피해는 hit callback | C7966,8091 |
| V05 | action registration 중복 여부로 status 소비 차단 | C13223–13230 |
| V06 | burn 후 tick | C4039,4042 |
| V07 | 특기 spend는 cut-in보다 앞 | C4457,4475 |
| V08 | cooldown은 finalize에서 설정 | C5653 |
| V09 | caster 자기 status에 1턴 추가 | C5277–5278 |
| V10 | 후퇴 방향은 side 기준 x축 | C5352 |
| V11 | round 보급 뒤 action reset | C11097,11100–11101 |
| V12 | snapshot에는 cooldown 키가 있다 | C6593,6627 |
| V13 | HP와 troop는 별도로 감소 | U241–242 |
| V14 | 양쪽0이면 defeat 조건에 들어감 | C10270–10273 |
| V15 | 결과 표시가 패배 toast queue를 기다림 | C10337–10338 |
| V16 | phase에서 혼란 소비 deferred | C5730 |
| V17 | 기존 headless fixture는 deferred run | test_battle_movement_query_service.gd:11–12 |
| V18 | 초기/증원 좌표는 marker에서 옴 | C9015,9041,11761 |

최종 Level 1 소스 검증 결과 원문:

```text
AUDIT_EVIDENCE PASS: 18 claims / 27 exact-line anchors
AUDIT_REFERENCE_BOUNDS PASS
AUDIT_SECTIONS PASS: A-G
```

이는 본문의 사실·참조 검증이며 게임 테스트 PASS가 아니다. `git diff --check`와 기준 커밋 이후 변경 파일이 이 새 문서 1개인지도 최종 확인한다. 기존 테스트/CI/Godot 실행은 이번 문서 변경에 불필요하여 수행하지 않으며 PASS로 표기하지 않는다. G2/G3/G4의 클코치 독립 검수는 아직 수행되지 않았다.
