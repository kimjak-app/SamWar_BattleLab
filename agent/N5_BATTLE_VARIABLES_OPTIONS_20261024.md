# N5 전투 변수 확장 결정 준비 (2026-10-24)

- 기준 커밋: `ba058c8a8e09f955230b5d48dd97e9de09074637` (ba058c8, "docs(battle): record the G0 const removal checks in the NIGHT3 test-gap report")
- 옵션 정리만, 구현 0
- 합격 판정·결정은 하지 않는다
- 조사 방법: 읽기 전용 worktree에서 grep과 read만 했다. Godot는 실행하지 않았다.
- 경로 표기: 모든 경로는 저장소 루트 기준이다. 줄 번호는 위 기준 커밋 기준이다.

---

## 0. 주장 사실 검증

### (1) "엔진에 지형 효과가 없다. '산지 110%'는 자리표시 문구일 뿐이다."

**판정: 대체로 맞다. 단, 세부 표현은 조금 다르다.**

- 2D 엔진(전투 규칙)에는 지형 규칙이 없다.
  - 데미지 공식에 지형 항이 없다. `scripts/battle/services/battle_damage_formula_service.gd:29-74`는 방향, 병종, 상태효과, 방어만 곱한다.
  - 이동력에도 지형이 없다. `scripts/battle/services/battle_movement_query_service.gd:12-20`은 `move_range`와 `mobility_up`/`movement_down`만 본다.
  - `scripts/battle_web_import_test.gd`에서 terrain/지형/산지 grep 결과가 0건이다.
  - `data/`에서 terrain/지형/산지/weather/날씨 grep 결과가 0건이다.
- "산지 110%"라는 문자열은 코드와 씬에 없다. 기획 문서에만 있다.
  - `docs/T08_BATTLE_UI_IMPLEMENTATION_MASTER_PLAN.md:235` `### 9-3. 지형 보정 표시 ("산지 110%")`
- 씬에 있는 것은 "산지"라는 편집기 기본 문구와 "효과 미구현" 라벨이다.
  - `scenes/battle/ui/CurrentActorInfoHud.tscn:546` `text = "지형 이미지"`
  - `scenes/battle/ui/CurrentActorInfoHud.tscn:559` `text = "산지"`
  - `scenes/battle/ui/CurrentActorInfoHud.tscn:563-572` `TerrainEffectLabel`, `visible = false`, `text = "효과 미구현"`
  - `scenes/battle/Battle_Production.tscn:5816` `TerrainPlaceholderLabel`, `visible = false`
- 실행 중에는 HUD가 이 문구를 "평지 / 방어 0% / 이동 0%"로 덮어쓴다.
  - `scripts/battle/presentation/production/battle_current_actor_hud_controller.gd:17-19` 기본값 상수
  - 같은 파일 `:349-368` `_sync_terrain()`이 `worldmap_battle_context`의 `terrain_name`, `terrain_defense_text`, `terrain_move_text`를 읽는다. 값이 없으면 기본값을 쓴다.
  - 월드맵은 이 키들을 넘기지 않는다. `scripts/worldmap/worldmap_main.gd:6511-6534`의 `battle_context`에 terrain 키가 없다.
- 3D 쪽에는 "랩 전용" 지형 분류가 있다. 엔진 규칙이 아니다.
  - `scripts/battle3d/lab_heightfield.gd:52-58` `terrain(c)`가 river/ford/forest/hill/plain을 돌려준다.
  - `scripts/battle3d/lab_demo_port.gd:25,34` 랩 데모에서만 river 칸을 막는다.
  - `scripts/battle3d/lab_presentation.gd:202` 안내 문구 "Terrain rules are LAB ONLY."
  - `scripts/battle3d/battle3d_connect_lab.gd:8,87-95` river 칸 표시(주석)만 한다.
  - `scripts/battle3d/lab_heightfield.gd:47` 주석 "not a gameplay terrain rule".

### (2) "유일한 무작위는 책략 주사위 `_strategy_roll_success`, `_strategy_roll_pool_index`다."

**판정: 전투 결과를 바꾸는 무작위로는 맞다. "유일한 무작위 호출"로는 틀리다.**

- 전투 규칙의 무작위는 두 곳뿐이다.
  - `scripts/battle_web_import_test.gd:3917-3920` `_strategy_roll_success` → `randf() <= success_rate`
  - `scripts/battle_web_import_test.gd:3923-3926` `_strategy_roll_pool_index` → `randi() % pool_size`
  - 호출부: `:3990` 성공 판정, `:3914` 결과 풀 선택.
- 그러나 같은 컨트롤러가 연출(FX)에서도 **같은 전역 RNG**를 쓴다.
  - `scripts/battle_web_import_test.gd:10782-10783, 10894-10900, 10921-10942, 10971, 11008, 11025-11028, 11047-11048, 11127-11148, 11203, 11361` `randf_range(...)`
  - `scripts/battle_web_import_test.gd:11369` `_load_random_fx_texture()` → `randi() % paths.size()`
  - 주의: `_load_random_fx_texture()`는 `battle_fx_root` 확인(`:11376`)보다 **먼저** `randi()`를 뽑는다. 그래서 FX 노드가 없는 헤드리스 실행에서도 전역 RNG가 소비될 수 있다. 예: `_spawn_attack_slash_fx` `:11166-11168`.
  - 공격 처리 순서도 FX가 먼저다. `:3561-3567`에서 slash/arrow/gunner FX 호출 뒤에 데미지를 계산한다.
  - 결론: 같은 seed라도 "주사위 전에 FX가 몇 번 뽑혔는가"에 따라 책략 결과가 바뀐다. 지금은 2D 직행 실행과 3D 실행이 같은 엔진 코드를 같은 순서로 돌리므로 맞아떨어진다.
- 전투 밖 무작위(참고):
  - `scripts/worldmap/actions/spy_action_service.gd:342-343, 540-541, 701-702, 861-862, 1169-1170, 1249-1250` `randi() % 100 + 1`. 단 `forced_roll` 주입 인자가 있다.
  - `scripts/worldmap/worldmap_main.gd:5399, 5403` `randf()`, `randi()`. 단 `roll_value`, `candidate_index` 주입 인자가 있다.
  - `scripts/audio/game_audio.gd:34, 109` 자체 `RandomNumberGenerator` 인스턴스. 전역 RNG와 분리돼 있다.
  - `scripts/battle_singijeon_test.gd:21, 140-141` 자체 `RandomNumberGenerator` 인스턴스(화면 흔들림).
- `scripts/battle3d/`에는 무작위 호출이 0건이다. `data/`, `scenes/`도 0건이다.
- `pick_random`, `shuffle`, `randfn`, `randi_range`는 scripts/data/scenes 전체에서 0건이다.

### (3) "시드 고정 장치가 없다."

**판정: 게임 코드 기준으로 맞다.**

- `scripts/`, `data/`, `scenes/`에서 `seed(` 0건이다. 전투 seed 값, 전투 전용 RNG, RNG 상태 저장(`state`) 모두 없다.
- 대신 있는 것은 "주입 훅"이다. seed 고정과는 다르다.
  - `scripts/battle_web_import_test.gd:883` `var strategy_roll_override: Callable` ("Test-only dice hook (S4-1); game code never sets it.")
  - 월드맵 `forced_roll`, `roll_value` 인자(위 (2) 참조).
- seed 고정은 전부 테스트 쪽에서 전역 `seed(n)`을 불러서 한다(아래 0-1).

### 0-1. 기존 테스트가 무작위를 다루는 방식

- 전역 `seed(n)` 호출: `tests/` 안 22개 파일.
  - 3D 자동전투 동등성: `tests/scripts/support/battle3d_auto_harness.gd:70`(엔진 직행), `:104`(3D). 두 실행 모두 `seed(seed_value)` 후 자동전투를 돌려 비교한다.
  - 비교 대상에 **다음 난수 값**이 들어간다. `battle3d_auto_harness.gd:19-23` 라운드 시작 스냅샷에 `"next_randf": randf()`.
  - 이 하네스를 쓰는 seed별 테스트: `test_battle3d_auto_equivalence_seed_{1,2,3}.gd`, `test_battle3d_auto_hold_seed_{1,2,3}.gd`, `test_battle3d_auto_hold_1x_seed_{1,2,3}.gd`, `test_battle3d_scenario_victory_seed_{1,2,3}.gd`. 본체: `tests/scripts/test_battle3d_auto_equivalence.gd:14-47`.
  - 그 밖의 `seed(1)`: `test_battle3d_auto_hold_release.gd:30,45,68`, `test_battle3d_option_ai_level_auto.gd:17,31`, `test_battle3d_scenario_defeat.gd:19`, `test_battle3d_scenario_gaps.gd:46`, `support/battle3d_auto_hold_harness.gd:59`, `support/battle3d_scenario_harness.gd:84`, `support/battle_setup_s43_harness.gd:134`.
- 시드 탐색: `tests/scripts/support/battle_tactic_oracle_harness.gd:53-60` `find_strategy_seed()`는 "seed 직후 첫 `randf()`/`randi()`가 책략 주사위"라고 가정한다. `:163`에서 `seed(spec.case_seed)`.
  - 골든에 그 seed가 박혀 있다: `tests/golden/battle_tactic_baseline_v0.json:1696, 3393, 5054, 6757, 8454` `"case_seed": 1/2/1/4/2`.
- 적 책략 오라클: `support/battle_enemy_strategy_oracle_harness.gd:119-122, 150, 206` (주사위 override + `seed(ACTION_SEED)`).
- "RNG 안 건드림" 관찰자: `support/battle_enemy_skill_cap_observer_battle.gd:10-15`, `support/battle_enemy_skill_spread_observer_battle.gd:9-13`. 판정 함수 앞뒤로 seed를 다시 걸고 `randf()`가 같은지 본다. 판정 함수가 난수를 뽑으면 실패한다.
- 주사위 override 사용: `support/battle3d_strategy_harness.gd:67`, `support/battle3d_enemy_strategy_harness.gd:29`, `support/battle_enemy_strategy_oracle_harness.gd:119`, `support/battle_tactic_oracle_harness.gd:100`, `test_battle3d_reinforce_mixed_log.gd:34`, `test_battle3d_skill_mixed_log.gd:22`, `test_battle3d_strategy_default_round.gd:38,66`, `test_battle3d_strategy_mixed_log.gd:23`, `test_battle3d_strategy_rejections.gd:41`.
- 골든 8개: `tests/golden/` 아래 `battle3d_m3_start_v0`, `battle_attack_baseline_v0`, `battle_enemy_skill_spread_base_v0`, `battle_enemy_strategy_base_v0`, `battle_enemy_turn_baseline_v0`, `battle_move_baseline_v0`, `battle_setup_port_base_v0`, `battle_tactic_baseline_v0`(.json). 공격 골든은 유닛 40필드(`current_hp`, `current_troops` 등)를 기록한다.

### 0-2. 무작위를 금지하는 검증기(tools/)

- `RANDOM =` 정규식을 가진 검증기 5개. 형태: `\b(randf|randi|randf_range|randi_range|randfn|RandomNumberGenerator)\b|\bseed\s*\(|\bshuffle\s*\(|pick_random`
  - `tools/validate_battle3d_m5b_scenario.py:36, 89` 3D 시나리오 셸 전체에 무작위 금지.
  - `tools/validate_battle_enemy_strategy_s4_2.py:52, 186, 202` 추가 함수와 규칙 서비스에 무작위 금지.
  - `tools/validate_battle_setup_port_s4_3.py:32, 97, 130` 설정 포트 서비스와 추가 함수에 무작위 금지.
  - `tools/validate_battle_skill_cap_s4_2c2.py:30, 93, 128`
  - `tools/validate_battle_skill_rotation_s4_2c.py:30, 88, 118`
- 3D 파일에 무작위/규칙 토큰 금지(인라인 정규식):
  - `tools/validate_battle3d_m4b_strategy.py:57, 129-130, 145` (`strategy_roll_override` 언급도 금지)
  - `tools/validate_battle3d_m4c1_skill.py:82, 162-163`
  - `tools/validate_battle3d_m4c2_enemy_skill.py:85`
  - `tools/validate_battle3d_m4e_enemy_strategy.py:103`
  - `tools/validate_battle3d_m5a_autoplay.py:96`, `tools/validate_battle3d_m5a2_auto_hold.py:98`, `tools/validate_battle3d_m5c_option_panel.py:99`
- 주사위 모양 고정:
  - `tools/validate_battle_tactic_events_s4_1.py:43-48` 두 주사위 함수 본문을 글자 그대로 비교한다.
  - 같은 파일 `:175-177` 커밋 범위 안에서 `randf()`/`randi()`/`randf_range(`/`randi_range(` 개수가 변하지 않았는지 본다. 주사위는 헬퍼 안에서만 굴려야 한다.
  - 주의: 이 검증기들이 고정 커밋 범위를 보는지, 현재 HEAD도 보는지는 이번에 끝까지 확인하지 않았다. **확인 필요.**

---

## 1. 지형 효과

### 1-1. 지금 있는 것

- 엔진 규칙: 없음. 데미지(`battle_damage_formula_service.gd:29-74`), 이동(`battle_movement_query_service.gd:12-20`), 적 경로(`battle_web_import_test.gd:15065` `_get_enemy_reachable_paths`) 어디에도 지형 항이 없다.
- 표시 틀: 있음. HUD `TerrainArea`(`CurrentActorInfoHud.tscn:509-572`), 동기화 함수(`battle_current_actor_hud_controller.gd:349-368`), 아이콘 1개(`:16` `terrain_plain.png`).
- 데이터 경로: 있음. `worldmap_battle_context`(`battle_web_import_test.gd:913`, 읽기 `:1504-`)가 dict로 들어온다. 지형 키는 아직 아무도 채우지 않는다.
- 3D 랩: 칸별 분류 함수(`lab_heightfield.gd:52-58`)는 있다. 엔진과 연결돼 있지 않다.

### 1-2. 옵션

**옵션 T-A. 표시만 연결 (규칙 0)**
- 내용: 월드맵이나 설정 포트가 `terrain_name` 등을 넘기면 HUD에 보여준다. 숫자는 규칙과 무관하다.
- 손대는 곳
  - 엔진: 없음. 월드맵 `battle_context` 조립(`worldmap_main.gd:6511-6534`)에 키만 추가.
  - 3D: 없음.
  - 테스트: HUD 표시 확인 1개 정도.
- 위험
  - 골든: 영향 없음(유닛·컨트롤러 필드 불변).
  - 동등성: 영향 없음.
  - RNG: 영향 없음.
  - 표시 숫자와 실제 규칙이 달라 보일 위험이 있다(“방어 10%”라고 써도 효과 없음).
- 되돌리기: 아주 쉽다. 키를 빼면 기본값으로 돌아간다.

**옵션 T-B. 전장 단위 지형 1종 (전투 전체에 하나)**
- 내용: 전투마다 지형 하나(예: 평지/산지/숲/강변)를 정한다. 데미지 공식에 배율 하나를 곱한다. 이동은 손대지 않거나 전원 ±1만 한다.
- 손대는 곳
  - 엔진: `battle_damage_formula_service.gd`에 지형 배율 항 1개. 지형 값의 출처(`worldmap_battle_context` 또는 설정 포트 `BATTLE_SETUP_META_KEY`, `battle_web_import_test.gd:895, 1526`). 필요하면 `battle_movement_query_service.gd:12-20`.
  - 3D: 표시만. 규칙 계산은 3D에 두면 안 된다(검증기 `validate_battle3d_m4b_strategy.py:145` 등이 규칙 토큰을 막는다).
  - 테스트: 공식 단위 테스트, 지형 지정 전투 1~2개.
- 위험
  - 골든: 기본값을 "평지 = 배율 1.0"으로 두면 불변. 기본값을 바꾸면 공격·적턴·자동 골든 전부 다시 찍어야 한다.
  - 동등성: 2D와 3D가 같은 엔진을 돌리므로 같게 유지된다.
  - RNG: 영향 없음(결정론).
  - 공식 서비스는 순수 함수다. 지형 값을 인자로 넘겨야 순수성이 유지된다.
- 되돌리기: 쉽다. 배율 항 하나와 입력 경로 하나만 빼면 된다.

**옵션 T-C. 칸 단위 지형 (지형 지도)**
- 내용: 18x10 칸마다 지형을 둔다. 이동 비용, 방어 보정, 통행 불가를 칸별로 적용한다.
- 손대는 곳
  - 엔진: 이동 범위 계산(`_collect_move_range_cells` `battle_web_import_test.gd:11477`), 적 경로(`:15065`), 자동전투 AI 평가(`:13648-13657`), 데미지 공식, 상태 지문(`battle_state_fingerprint_service.gd`)에 지형 데이터 추가 여부.
  - 3D: 지금 `lab_heightfield.gd:52-58`의 분류를 엔진 지도와 맞춰야 한다. 3D가 스스로 판정하면 검증기 위반이다. 엔진에서 읽어 와야 한다.
  - 데이터: `data/`에 지도 파일 신설.
  - 테스트: 이동 골든(`battle_move_baseline_v0.json`), 적턴 골든, 자동 동등성, 3D 이동 어댑터 테스트.
- 위험
  - 골든: 기본 지도가 "전부 평지"면 이론상 불변이다. 그래도 경로 탐색 코드를 고치면 동점 처리 순서가 바뀌어 이동·적턴 골든이 흔들릴 수 있다.
  - 동등성: AI 경로가 바뀌면 seed별 결과가 전부 바뀐다. 2D=3D 동등성 자체는 유지되지만 기준값을 다시 확인해야 한다.
  - RNG: 직접 영향은 없다. 다만 행동 순서가 바뀌면 FX 호출 횟수가 바뀌고, 그 뒤 책략 주사위 결과가 바뀐다(0의 (2) 참조).
- 되돌리기: 어렵다. 이동·AI·3D·데이터에 걸쳐 퍼진다.

### 1-3. 추천

- **추천: T-B (전장 단위 1종, 기본값 평지=1.0)**. 표시 틀과 데이터 경로가 이미 있고, RNG와 골든을 건드리지 않는다. T-C는 3D 지형 지도와 엔진 지도를 하나로 정한 뒤에 따로 검토한다.
- 이 추천은 결정이 아니다.

---

## 2. 날씨

### 2-1. 지금 있는 것

- 없음. scripts/data/scenes에서 weather/날씨 0건.
- 월드맵에는 계절성 민심 처리만 있다(`worldmap_main.gd:911, 5281, 11337` `seasonal_loyalty`). 전투로 넘어가는 계절·월 값은 없다.
- 넘길 통로는 지형과 같다: `worldmap_battle_context`, 설정 포트.

### 2-2. 옵션

**옵션 W-A. 날씨 없음 유지 (또는 이름만 표시)**
- 손대는 곳: 없음. 표시를 원하면 HUD 문구 1줄.
- 위험: 없음.
- 되돌리기: 해당 없음.

**옵션 W-B. 전투 시작 시 정해진 날씨 1종 (전투 중 불변, 무작위 없음)**
- 내용: 월드맵 월/계절 또는 시나리오가 날씨를 정해 넘긴다. 예: 비 → 조총 배율 감소, 안개 → 궁병 사거리 -1, 눈 → 이동 -1. 값은 결정론이다.
- 손대는 곳
  - 엔진: 데미지 공식 배율 1개, 사거리/이동 질의 서비스 1~2곳, 필요하면 책략 성공률(`battle_web_import_test.gd:3903-3907`).
  - 3D: 표시만(아이콘, 문구). 규칙은 엔진.
  - 테스트: 날씨 지정 전투 1~2개, 공식 단위 테스트.
- 위험
  - 골든: 기본값 "맑음 = 효과 0"이면 불변.
  - 동등성: 유지.
  - RNG: 영향 없음.
  - 조총 사전 사격 보너스(`battle_damage_formula_service.gd:36-40`)와 겹치는 규칙이 생기므로 곱하는 순서를 정해야 한다.
- 되돌리기: 쉽다.

**옵션 W-C. 라운드마다 바뀌는 무작위 날씨**
- 내용: 라운드 시작에 확률로 날씨가 바뀐다.
- 손대는 곳
  - 엔진: `_start_new_round` 근처에 무작위 추첨. 날씨 상태를 지문·로그에 추가.
  - 3D: 날씨 전환 표시.
  - 테스트: 거의 전부.
- 위험
  - 전역 `randf()`로 뽑으면 라운드마다 난수 1개가 더 소비된다. seed별 결과가 전부 바뀐다. `next_randf` 스냅샷(`battle3d_auto_harness.gd:23`)과 seed 골든(`battle_tactic_baseline_v0.json`의 `case_seed`)이 깨진다.
  - `find_strategy_seed()`(`battle_tactic_oracle_harness.gd:53-60`)의 가정이 깨질 수 있다.
  - "RNG 안 건드림" 관찰자는 판정 함수 안만 보므로 직접 걸리지는 않는다. 하지만 하네스 기준값은 바뀐다.
  - 전용 RNG(4장 옵션 S-B)가 먼저 있어야 안전하다.
- 되돌리기: 어렵다. 골든 재기록을 다시 되돌려야 한다.

### 2-3. 추천

- **추천: W-B (시작 시 고정, 무작위 없음, 기본 맑음=효과 0)**. W-C는 4장의 시드 장치가 생긴 뒤에만 검토한다.
- 이 추천은 결정이 아니다.

---

## 3. 데미지 편차

### 3-1. 지금 있는 것

- 데미지는 완전 결정론이다.
  - 기본값: `battle_web_import_test.gd:17-18` `DEMO_DAMAGE := 12.0`, `ENEMY_DEMO_DAMAGE := 8.0`. 자동전투는 `:13648` `_get_auto_damage_for_actor`.
  - 공식: `battle_damage_formula_service.gd:29-74`. 배율을 곱한 뒤 `maxi(1, int(round(...)))`.
  - 진입점 하나: `battle_web_import_test.gd:5794-5799` `_get_directional_attack_damage` → 공식 → 부상 보정.
- 같은 함수가 "실제 적용"과 "예측"에 함께 쓰인다.
  - 실제 적용: `:3567`(아군 공격), `:5532`, `:5707`, `:5729`(고유기), `:8390`(적 공격).
  - 예측: `:4467` `projected_damage`(인자 `false, false`), `:13657` 자동전투 AI 목표 평가.
- 주의: 진입점에 편차를 넣으면 예측과 AI 평가에서도 난수가 뽑힌다. AI가 후보를 몇 개 보느냐에 따라 난수 소비량이 달라진다.

### 3-2. 옵션

**옵션 D-A. 편차 없음 유지**
- 손대는 곳: 없음.
- 위험: 없음. 같은 상황이면 항상 같은 숫자다. 예측 표시와 실제가 항상 같다.
- 되돌리기: 해당 없음.

**옵션 D-B. 전역 `randf()`로 ±N% 편차**
- 내용: 실제 적용 지점에서만 `randf_range(1-N, 1+N)`를 곱한다.
- 손대는 곳
  - 엔진: 실제 적용 5곳(`:3567, :5532, :5707, :5729, :8390`) 또는 새 "적용 전용" 래퍼. 예측(`:4467`)과 AI(`:13657`)는 빼야 한다.
  - 3D: 없음(엔진 이벤트의 데미지를 그대로 표시).
  - 테스트: 공격 골든, 적턴 골든, 고유기 골든, 자동 동등성 기준값 전부.
- 위험
  - 골든: `battle_attack_baseline_v0.json`, `battle_enemy_turn_baseline_v0.json` 등의 `current_hp`/`current_troops`가 바뀐다. 재기록 필요.
  - 동등성: 공격마다 난수 1개가 더 소비된다. 그 뒤 책략 주사위와 FX 결과가 전부 밀린다. seed 1/2/3의 전투 흐름 자체가 바뀐다. 2D=3D 비교는 여전히 같을 수 있지만 `next_randf` 포함 모든 기준이 새로 정해진다.
  - `find_strategy_seed()`와 `case_seed` 골든: 책략 전에 공격이 있는 사례는 깨진다.
  - 검증기: `validate_battle_tactic_events_s4_1.py:175-177`(난수 호출 개수 불변)이 현재도 돌면 걸린다. **확인 필요.** 새 함수에 대해 `RANDOM` 금지 검증기가 있으면 그 범위 밖에 둬야 한다.
  - 예측 표시와 실제 값이 달라진다. UI 문구를 "약 12"처럼 바꿔야 한다.
- 되돌리기: 코드는 쉽다. 골든 재기록까지 되돌려야 하므로 실제로는 중간.

**옵션 D-C. 전용 RNG로 편차 + 끄는 깃발 (기본 꺼짐)**
- 내용: 엔진에 전투 전용 `RandomNumberGenerator`를 두고 편차만 여기서 뽑는다. 기본은 편차 0(깃발 꺼짐). 테스트용 override 훅을 `strategy_roll_override`(`:883`)와 같은 모양으로 둔다.
- 손대는 곳
  - 엔진: RNG 인스턴스 1개, 적용 래퍼 1개, 깃발 1개. 4장 S-B와 겹친다.
  - 3D: 없음. 3D에 `RandomNumberGenerator`를 두면 3D 검증기(`validate_battle3d_m5a_autoplay.py:96` 등) 위반이므로 엔진에만 둔다.
  - 테스트: 깃발 켠 전투 몇 개, 깃발 꺼짐 = 기존과 동일 확인.
- 위험
  - 골든: 깃발 꺼짐이면 불변.
  - 동등성: 전역 RNG를 건드리지 않으므로 기존 seed 흐름이 유지된다.
  - 깃발을 켜면 전용 RNG의 seed를 어떻게 정하느냐가 문제다(4장).
  - 깃발 기본값 패턴은 이미 있다: `validate_battle_setup_port_s4_3.py` 근처 `enemy_strategy_enabled` 등 `:= false` 확인.
- 되돌리기: 쉽다. 깃발을 끄면 원래대로다.

**옵션 D-D. 결정론적 "편차" (해시 기반, 난수 없음)**
- 내용: (공격자 id, 대상 id, 라운드, 행동 번호)의 해시로 0.9~1.1 같은 값을 만든다. 같은 상황이면 항상 같은 값이다. 선례: `battle_web_import_test.gd:10461` `unit_id.hash()`.
- 손대는 곳: 엔진 공식 입력 1개, 행동 번호 카운터. 3D 없음.
- 위험
  - RNG: 영향 없음. `RANDOM` 정규식에도 안 걸린다.
  - 골든: 켜면 데미지가 바뀌므로 재기록. 깃발로 끄면 불변.
  - 플레이어가 같은 행동을 되풀이하면 같은 결과가 나와 "편차" 느낌이 약하다. 저장/불러오기 후 재시도로 결과를 바꿀 수 없다(장점일 수도 있다).
- 되돌리기: 쉽다.

### 3-3. 추천

- **추천: D-C (전용 RNG, 기본 꺼짐)**. 기존 seed 흐름을 지키면서 나중에 켤 수 있다. 4장 S-B와 같이 묶어야 의미가 있다. 무작위를 아예 피하고 싶다면 D-D가 대안이다.
- 어떤 옵션이든 "예측(`:4467`, `:13657`)에서는 뽑지 않는다"를 고정 조건으로 둔다.
- 이 추천은 결정이 아니다.

---

## 4. 시드 고정 장치 (결정론 RNG)

### 4-1. 지금 있는 것

- 게임 코드에 seed 장치가 없다(0의 (3)).
- 전투 규칙 난수(책략 주사위 2곳)와 FX 난수(약 30곳)가 **같은 전역 RNG**를 함께 쓴다(0의 (2)).
- 테스트는 전역 `seed(n)` + 주사위 override 두 가지로 재현성을 만든다(0-1).
- 재현성 기준이 "엔진 코드 순서 전체"에 묶여 있다. FX 함수 하나에 `randf_range`를 추가해도 seed별 책략 결과가 바뀐다.

### 4-2. 옵션

**옵션 S-A. 현상 유지 (테스트가 전역 seed)**
- 손대는 곳: 없음.
- 위험
  - 지금 테스트는 통과한다.
  - FX 수정만으로 seed 골든과 `find_strategy_seed()` 결과가 바뀔 수 있다. 원인 추적이 어렵다.
  - 게임 안에서 "같은 전투 다시 하기", 리플레이, 저장 중 난수 상태 복원이 불가능하다.
- 되돌리기: 해당 없음.

**옵션 S-B. 전투 전용 RNG 1개 + 전투 seed 입력**
- 내용: 엔진에 `battle_rng: RandomNumberGenerator`를 둔다. 책략 주사위 두 함수만 이 RNG를 쓴다. seed는 설정 포트(`BATTLE_SETUP_META_KEY`, `:895, 1526`)나 `worldmap_battle_context`로 받는다. 없으면 시간 기반으로 정하고 로그에 남긴다. FX는 전역 RNG에 그대로 둔다.
- 손대는 곳
  - 엔진: `_strategy_roll_success`, `_strategy_roll_pool_index`(`:3917-3926`) 두 줄, RNG 변수, seed 입력 1곳.
  - 3D: 없음. 3D 하네스가 seed를 넘길 통로만 필요(설정 포트 사용 시 3D 코드 변경 0 가능).
  - 테스트: 전역 `seed(n)` 22개 파일의 의미가 바뀐다. `battle3d_auto_harness.gd:23` `next_randf`는 전역 값을 보므로 의미가 줄어든다(전용 RNG 상태로 바꿀지 결정 필요).
- 위험
  - 골든: 책략이 나오는 seed 사례의 결과가 바뀔 수 있다. `battle_tactic_baseline_v0.json`의 `case_seed` 사례, `battle_enemy_strategy_base_v0.json` 재확인 필요. override를 쓰는 사례는 영향 없음.
  - 동등성: 2D=3D는 같은 seed를 넘기면 계속 같다. 단 기준 흐름이 바뀌므로 seed 1/2/3 결과를 새로 확인해야 한다.
  - 검증기: `validate_battle_tactic_events_s4_1.py:43-48`이 주사위 본문을 글자 그대로 본다. 현재 HEAD에도 적용되면 실패한다. **확인 필요.**
  - `find_strategy_seed()`는 전역 RNG 기준이라 새로 써야 한다.
- 되돌리기: 코드는 쉽다(두 줄). 골든·하네스 갱신까지 합치면 중간.

**옵션 S-C. 도메인별 RNG 스트림 + 상태 저장**
- 내용: 전투 seed 하나에서 여러 RNG를 파생한다(책략, 데미지 편차, 날씨, FX). 각 RNG의 `state`를 스냅샷·저장에 넣는다.
- 손대는 곳
  - 엔진: S-B + FX 30곳을 FX RNG로 교체 + 지문 서비스(`battle_state_fingerprint_service.gd`)에 RNG 상태.
  - 3D: 없음.
  - 테스트: S-B의 전부 + 지문 비교 테스트.
- 위험
  - FX를 전역에서 빼는 순간 "FX가 먼저 뽑던 난수"가 사라진다. 전역 seed 기준 모든 책략 결과가 바뀐다. seed 골든 전부 재확인.
  - 장점: 이후 편차·날씨를 넣어도 서로의 순서를 흔들지 않는다. 리플레이와 저장 복원이 가능해진다.
- 되돌리기: 어렵다. 파일 전반에 퍼진다.

**옵션 S-D. FX만 전역에서 분리 (규칙 RNG는 그대로)**
- 내용: FX 30곳을 별도 `RandomNumberGenerator`로 옮긴다. 전역 RNG는 사실상 "규칙 전용"이 된다. seed 입력은 아직 안 만든다.
- 손대는 곳: 엔진 FX 함수들(`:10782-11369`). 3D 없음. 테스트 기준값.
- 위험
  - 헤드리스에서도 FX 난수가 뽑히고 있었다면(`_load_random_fx_texture` `:11369`) seed별 책략 결과가 바뀐다. 실제로 몇 번 뽑히는지는 실행해 봐야 안다. **확인 필요.**
  - 바뀌지 않는다면 골든 영향 0. 이후 S-B로 가기 쉬워진다.
- 되돌리기: 쉽다(FX 국소).

### 4-3. 추천

- **추천: S-B (전투 전용 RNG 1개, 주사위만 이동)**. 영향 범위가 두 함수로 작다. 편차(D-C)와 날씨(W-C)가 나중에 같은 장치를 쓸 수 있다. 진행한다면 골든·하네스 갱신을 같은 슬라이스로 묶고, 그 슬라이스에서는 규칙을 바꾸지 않는다.
- S-D는 S-B 앞에 두는 "예비 단계"로 쓸 수 있다. FX 난수가 헤드리스에서 실제로 소비되는지 먼저 측정하면 S-B의 골든 영향 크기를 미리 알 수 있다.
- 이 추천은 결정이 아니다.

---

## 5. 네 주제를 함께 볼 때 순서상 주의

- 무작위가 없는 옵션(T-A, T-B, W-B, D-D)은 RNG와 seed 골든에 영향이 없다. 순서와 무관하게 넣을 수 있다.
- 무작위가 있는 옵션(D-B, D-C 켬, W-C)은 시드 장치(S-B 또는 S-C)가 먼저 있어야 안전하다.
- 전역 RNG에 난수 하나를 추가하면 그 뒤 모든 seed 결과가 밀린다. 영향 테스트: 자동 동등성·자동 홀드·시나리오 승리 seed 1/2/3(12개), `seed(1)` 단독 테스트들, 책략 오라클(`case_seed`), 적 책략 오라클.
- 규칙 계산은 엔진에만 둔다. 3D 파일에 난수나 규칙 토큰이 들어가면 3D 검증기 7개 이상이 실패한다(0-2).
- 예측(`:4467`)과 AI 평가(`:13657`)는 난수를 뽑지 않아야 한다.

---

## 김작이 정해야 할 것

1. **지형 범위**: 표시만(T-A) / 전장 단위 1종(T-B) / 칸 단위 지도(T-C) 중 무엇으로 시작할지.
2. **지형 값의 출처**: 월드맵 `worldmap_battle_context`로 받을지, 전투 설정 포트(`samwar_battle_setup`)로 받을지, 시나리오 데이터 파일을 새로 둘지.
3. **지형 효과 종류와 숫자**: 방어 배율만인지, 이동까지인지. 기획 문서의 "산지 110%"가 공격 배율인지 방어 배율인지 뜻을 정할지.
4. **3D 랩 지형(`lab_heightfield.gd`의 river/ford/forest/hill)을 엔진 규칙으로 승격할지**, 아니면 랩 전용으로 계속 둘지.
5. **날씨 도입 여부와 방식**: 없음(W-A) / 시작 시 고정(W-B) / 라운드별 무작위(W-C).
6. **날씨 효과 목록**: 어느 병종·행동에 어떤 숫자로 걸지(조총, 궁병 사거리, 이동, 책략 성공률).
7. **데미지 편차 도입 여부와 방식**: 없음(D-A) / 전역 RNG(D-B) / 전용 RNG+깃발(D-C) / 해시 결정론(D-D). 도입한다면 폭(±N%).
8. **예측 표시 정책**: 편차가 생기면 공격 전 예측 숫자를 범위로 보여줄지, 평균값으로 보여줄지.
9. **시드 장치 도입 여부와 범위**: 현상 유지(S-A) / 전투 전용 RNG(S-B) / 도메인별 스트림(S-C) / FX 분리 먼저(S-D).
10. **전투 seed의 출처**: 설정 포트로 받을지, 월드맵이 줄지, 없을 때 시간 기반으로 정하고 로그에 남길지.
11. **골든 재기록 허용 여부**: 시드 장치나 편차를 넣으면 seed 기반 골든(`battle_tactic_baseline_v0.json` 등)과 자동 동등성 기준이 바뀔 수 있다. 재기록을 한 슬라이스로 묶어 허용할지.
12. **기존 검증기 처리**: `validate_battle_tactic_events_s4_1.py`(주사위 본문 고정, 난수 개수 불변)와 `RANDOM` 금지 검증기들이 새 변경에도 적용되는지 확인하고, 적용된다면 갱신을 허용할지.
13. **진행 순서**: 무작위 없는 항목(지형·고정 날씨)을 먼저 할지, 시드 장치를 먼저 깔지.
