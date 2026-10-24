# HUD 블록 3·4·5 새 읽기 제안서 (2026-10-24)

- 기준 커밋: `2b08270` (브랜치 `feature/hud-read-proposals-20261024`)
- 문서만, 코드 변경 0
- 결정은 김작
- 작성: 읽기 전용 하위 작업이 초안을 쓰고, 클코드가 핵심 사실을 다시 확인했다(준비 아이콘 = `_can_use_unique_skill`과 같은 판정 C:3648, 초상 읽기의 `load()`·캐시 쓰기 C:8902-8909). 브랜치 끝 해시는 커밋이 자기 해시를 담을 수 없어서 zip `commit_info.txt`와 `NIGHT7_SUMMARY`에 적는다.
- 방법: 정적 읽기와 grep만 했다. Godot는 실행하지 않았다. [사실]
- 표기: 줄마다 **[사실]**(코드 그대로) / **[추정]**(추론)으로 나눈다.
- 줄 번호 약어:
  - C = `scripts/battle_web_import_test.gd` (16,175줄. H1 기준 `dccb306`과 줄 번호가 같다. `2b08270`은 문서만 더했다 [사실])
  - PC = `scripts/battle/battle_production_controller.gd`
  - EP = `scripts/battle3d/battle3d_engine_play.gd` (1,465줄)
  - LP = `scripts/battle3d/lab_presentation.gd`, SH = `scripts/battle3d/battle3d_scenario_shell.gd`
  - RB = `scripts/battle/presentation/production/battle_roster_hud_controller.gd`
  - CA = `scripts/battle/presentation/production/battle_current_actor_hud_controller.gd`
  - RP = `scripts/battle/presentation/production/battle_roster_presentation_controller.gd`
  - US = `scripts/battle_unit_state.gd`
  - REG = `scripts/worldmap/hero_design_data_registry.gd` (엔진 밖 정적 데이터)

## 0. 먼저 알아 둘 사실

1. 랩의 엔진은 2D `Battle_Main.tscn` 전체다. `battle3d_engine_host.gd:14`가 이 씬을 SubViewport 안에 만든다. [사실]
   - 그래서 엔진 안의 2D HUD 보조 노드(RB, CA)도 함께 들어 있다. RB는 `_process`(RB:16-17)에서, CA도 매 프레임 아래 함수들을 이미 부른다. [사실: 코드]
   - SubViewport는 `UPDATE_DISABLED`(host:7)라 그리기만 멈춘다. `_process`는 돈다고 본다. [추정: 실행 확인 없음]
   - 뜻: 아래 새 읽기 후보 함수는 **지금도 엔진 안에서 매 프레임 불리고 있다.** 랩이 같은 함수를 부르면 새 종류의 부작용이 생기지 않는다. [추정]
2. 엔진 쓰기 15개는 `tests/scripts/support/battle3d_option_harness.gd:7-9`의 `FIFTEEN` 목록이다. 아래 후보는 그 목록에 하나도 없다. 후보 함수 본문은 그 15개를 부르지 않는다. [사실: 본문 읽음]
3. 랩이 지금 읽는 엔진 값(EP grep) [사실]:
   - `engine.call` 읽기 12개: `_is_unit_state_available_for_battle_slot`, `_get_alive_enemy_units`, `is_unit_in_attack_range`, `_can_use_strategy`, `_get_strategy_targets`, `_get_strategy_success_rate`, `_get_unique_skill_for_unit`, `_get_unique_skill_valid_targets`, `_can_use_unique_skill`, `_should_unique_skill_resolve_without_manual_target`, `get_enemy_ai_level`, `get_pending_enemy_ai_level`.
   - `engine.get` 읽기 12개: `current_phase`, `is_demo_animating`, `active_unit_state`, `all_battle_unit_states`, `battle_action_event_log`, `ally_move_event_log`, `battle_grid_controller`, `enemy_action_event_log`, `tactic_event_log`, `battle_momentum`, `is_manual_unique_skill_preview_pending`, `is_full_auto_battle_enabled`. (`auto_presentation_hold`도 EP:1432에서 읽는다.)
   - 유닛 필드: `Adapter.to_view`의 14필드(`battle3d_unit_adapter.gd:3`)와 `unit.is_defending`(EP:414, M4-a 승인).
4. 검증기 제약 [사실]:
   - `tools/validate_battle3d_m5c_option_panel.py:36-40`은 EP의 `engine.call`/`engine.get` 이름 집합이 **정확히 같은지** 본다(:104, :108). FORBIDDEN 정규식(:41-44)에 `worldmap`, `result_toast`, `result_video`가 들어 있다.
   - 이 검증기들은 고정 커밋(BASE..TIP)을 읽는다. 환경 변수로 `HEAD`를 주지 않으면 새 변경에 반응하지 않는다(:15, :67-68).
   - `tools/validate_battle3d_contract.py:6-10`과 `tests/scripts/test_battle3d_movement_parity.gd:7`은 `VIEW_FIELDS` 14개를 정확히 비교한다. 이 검증기는 작업 트리 파일을 바로 읽는다(:7). → **Adapter에 필드를 더하면 바로 깨진다.**
   - GDScript 테스트에는 읽기 목록을 검사하는 곳이 없다(grep `reads`/`READS` 결과 로그 커서 문장뿐). 지문 비교(`battle_state_fingerprint_service.gd:4`)는 유닛 상태만 본다.
5. 권하는 감싸기 방식(모든 후보 공통) [추정]:
   - 새 읽기는 EP 안의 랩 함수 하나씩으로만 둔다(예: `hud_portrait(unit_id)`). 2D HUD 쪽은 엔진을 직접 보지 않고 이 랩 함수만 부른다(상단 HUD 방식과 같음).
   - 반환은 값 복사(String·int·bool) 또는 `duplicate(true)`한 Array/Dictionary로 한다. `BattleUnitState` 객체는 넘기지 않고 `unit_id` 문자열로 바꿔 넘긴다.
   - 텍스처는 공유 Resource다. 복사하지 않고 그대로 쓰되 랩은 텍스처를 바꾸지 않는다. 유닛별로 랩 쪽 사전에 한 번만 받아 둔다(매 프레임 호출하지 않음).
   - EP에 두면 기존 검증기 방식(집합 비교)으로 새 읽기를 셀 수 있다. 다른 파일에 두면 지금 검증기가 못 본다.

---

## 블록 3 적군 로스터 (EnemyRosterHud)

노드: `BattleUI/ProductionHudRoot/EnemyRosterHud`(P:5089), 70노드, 1595..1865 × 156..680. 슬롯 5개 `Slot01·Slot02·Slot03·Reinforce01·Reinforce02`(RB:9). 슬롯마다 `Portrait`, `NameLabel`, `HpLabel`, `TroopIconRect`, `TroopTypeLabel`, `StatusLabel`, `UniqueSkillReadyIcon`이 보인다(RB:50-56). 옆 배너 `EnemyRosterSideBanner`, 접힘 초상 `EnemyRosterPortraitOnlyLayer`(RP:189-216). [사실: 부록 A]

### (a) 값 표

| 값 | 2D 출처 (file:line) | 2D 노드 | 랩이 이미 가짐 | 엔진 기존 함수(랩이 이미 읽음) | 새 읽기 필요 |
|---|---|---|---|---|---|
| 슬롯 순서·진영 | `_get_all_unit_states_in_slot_order` C:14307 (RB:26) | 슬롯 5개 | `queries.alive_units`(EP:138-139, `all_battle_unit_states` 순서). `display_values[id].side`(EP:335) **즉시** | `all_battle_unit_states` | **아니오.** `all_battle_unit_states`는 C:9061-9075에서 같은 10칸 순서로 쌓는다(null만 뺌) [사실] |
| 슬롯 표시 여부 | 어댑터 `_is_unit_state_active_by_capacity_slot` C:9247 | 슬롯 `visible` | `views[id].visible` = `_is_unit_state_available_for_battle_slot`(EP:337) **즉시**. 이 함수는 alive + active + deployed를 함께 본다(C:9256-9264) | `_is_unit_state_available_for_battle_slot` | 보류 후보 **N9**: "활성인데 아직 배치 안 됨"(지원군 대기)과 "전멸"을 나누려면 필요 |
| 장수 이름 | `unit.display_name` (RB:67), US:19 | `NameLabel` | **없음**. 랩은 `unit_id`만 쓴다("guan_yu" 등) | — | **N1** `display_name` 필드 |
| 병력 현재/최대 | `current_troops`/`max_troops` (RB:69) | `HpLabel` "병력 %d / %d" | `display_values` 14필드(EP:10, EP:335) **즉시** | — | 아니오 |
| 초상 | `_get_closeup_portrait_texture_for_unit` C:7603 (RB:71) | `Portrait`(64×64), 접힘 초상은 이것을 복사(RP:347-350) | 없음 | — | **N2** |
| 병종 아이콘 | `_get_troop_icon_texture_for_visual_key("", unit)` C:7557 (RB:73) | `TroopIconRect`(40×40) | 없음 | — | **N3** |
| 병종명 | `unit_type` + RB 로컬 표(RB:91-98) | `TroopTypeLabel` | `display_values[id].unit_type` **즉시** | — | 아니오. 표 5줄은 랩에 그대로 옮기면 된다 |
| 상태 요약 | `_get_formation_status_summary_text` C:4216 → C:4166 (RB:78) | `StatusLabel` (빈 글이면 숨김) | 일부: `status_display`(EP:38, EP:1045) **재생 후**. 글 모양이 다르다(EP:1049-1056 "동요 2턴") | — | **N4**. 2D는 "⚠ 동요 2턴 · 공/방 -10%" 같은 글과 "외 N"을 쓰고(C:4072-4078, 4177), 방어·특기 버프 항목(C:4079-4098)도 넣는다. 버프는 `status_effects`에 없다 [사실] |
| 고유특기 준비 아이콘 | `_is_unique_skill_ready_for_formation_guide` C:7483 (RB:82) | `UniqueSkillReadyIcon` | — | `_can_use_unique_skill` (EP:1122) | **아니오.** 아래 설명 |
| 현재 행동자 금색 테두리 | `_get_production_roster_current_actor` C:16020 → 적 턴 `current_enemy_ai_actor_state`, 아군 단계 `active_unit_state` | 슬롯 `panel` 스타일(C:16068-16073), 접힘 초상 테두리(RP:352) | 적: `enemy_actor_id`(EP:110, EP:818) **재생 후**. 아군: `selected`(EP:351) **즉시** | `active_unit_state` | 아니오 |
| 다음 적 행동자 미리보기 테두리 | `_get_production_roster_next_enemy_actor` C:16032 → C:13587 | 위와 같은 금색 테두리(C:16059-16065) | 없음 | — | 보류 후보 **N8** |
| 전멸·미배치 회색 | `is_alive()`, `_is_unit_state_deployed_by_capacity_slot` C:9238 (RP:382-389) | 접힘 초상 `modulate` | `current_troops`(즉시)로 전멸은 알 수 있다 [추정] | — | N9와 같은 문제(배치 여부) |
| 옆 배너·접기 | RP:219-228, 펄스 C:6020 | `EnemyRosterSideBanner` | 해당 없음(표현 전용) | — | 아니오. 엔진 쓰기·읽기 없음 [사실: 부록 A §A4] |

**고유특기 준비 아이콘 = 기존 읽기와 같다 [사실]**:
- C:7483-7488: 쿨다운이 0보다 크면 false, 아니면 `_can_use_unique_skill(unit)`을 돌려준다.
- `_can_use_unique_skill` 안에서도 같은 쿨다운 검사를 한다(C:3648).
- 그래서 두 함수의 결과는 항상 같다. 랩은 `_can_use_unique_skill`을 이미 읽는다(EP:1122).
- 또 `_can_use_unique_skill`은 `unit_state.side != "ally"`이면 false다(C:3640). **적군 카드의 준비 아이콘은 2D에서도 항상 숨겨진다.** 아군 카드도 지금 행동 중인 아군 하나에만 켜진다(C:3642).
- 결론: 블록 3에는 준비 아이콘 새 읽기가 필요 없다. H1 문서 2-2의 "새 읽기 1개"는 고친다.

### (b) 새 읽기 후보

#### N1 `display_name` (유닛 필드)
- 위치: US:19 `var display_name: String = ""`. 엔진 함수가 아니라 랩이 이미 들고 있는 `BattleUnitState` 객체의 필드다(EP:138-139). [사실]
- 인자·반환: 없음 → `String`.
- 부작용: 없음. 평범한 속성이다(US:19에 setter 없음). 난수·캐시·load·시그널 없음. [사실]
- 감싸기: `func hud_display_name(unit_id) -> String: return String(queries.find_unit(unit_id).display_name)`. String은 값으로 복사된다. **`Adapter.VIEW_FIELDS`에는 넣지 않는다**(0-4절: 계약 검증기와 parity 테스트가 깨짐). [사실: 검증기 / 추정: 함수 모양]
- 15개 쓰기와 무관한 이유: 필드 읽기뿐이다. 이벤트 로그·phase·기세를 건드리지 않는다. [사실]
- 이 필드는 블록 4-1, 블록 5(퇴각 토스트)에서도 같은 함수로 쓴다.

#### N2 `_get_closeup_portrait_texture_for_unit`
- 위치: C:7603-7605. [사실]
- 인자·반환: `(unit_state: BattleUnitState) -> Texture2D`. [사실]
- 본문 경로 [사실]:
  - `_get_hero_id_for_unit_state` C:8769 (슬롯 메타 사전 `get`, 상수 `TEST_BATTLE_ROSTER` C:498) → `_get_hero_registry_entry` C:8780 (사전 `get`)
  - → `_resolve_hero_portrait_texture` C:2170 → `_resolve_hero_portrait_path` C:2160 (`ResourceLoader.exists`)
  - → `_load_texture_or_null` C:8899.
- 부작용 [사실]:
  - **load() 있음**: C:8906 `var loaded_resource := load(path)`.
  - **캐시 채움 있음**: C:8909 `hero_identity_texture_cache[path] = texture`. 이 사전은 C:948에 선언되고 C:8902-8909에서만 쓰인다(grep). 다른 규칙이 이 사전을 읽지 않는다.
  - 상태 변경 그 밖에 없음. 난수 없음. 시그널 없음.
  - 대체 경로: 경로가 없으면 `UNKNOWN_HERO_PORTRAIT_FALLBACK_PATH` = `res://assets/web_battle/unit_tokens/unit_blue_battlefield.png`(C:161, C:2165).
- 감싸기: 랩에 `hud_portraits := {}`를 두고 `unit_id`마다 한 번만 부른다. 텍스처는 복사하지 않고 읽기 전용으로 쓴다. [추정]
- 15개 쓰기와 무관한 이유: 캐시 사전 하나만 바뀐다. 이 사전은 유닛·턴·기세·이벤트 로그와 연결이 없다. RB:71이 엔진 안에서 같은 호출을 매 프레임 이미 한다. [사실: 코드 / 추정: 매 프레임 실행]

#### N3 `_get_troop_icon_texture_for_visual_key`
- 위치: C:7557-7570. [사실]
- 인자·반환: `(visual_key: String, unit_state: BattleUnitState = null) -> Texture2D`. 로스터는 `("", unit)`으로 부른다(RB:73). [사실]
- 본문 경로 [사실]:
  - 유닛이 있으면 `_get_visual_token_texture_for_unit(unit, _get_unit_facing(unit))` C:12477 → `_get_visual_token_paths_for_unit` C:12427(상수 `UNIT_VISUAL_TOKEN_PATHS` 조회) → `_load_optional_texture` C:12450 → `_try_load_texture_or_null` C:12444.
  - 없으면 `_get_troop_icon_texture_from_token_paths` C:7573, 대체 키 C:7583-7600.
- 부작용 [사실]:
  - **load() 있음**: C:12447 `return load(path) as Texture2D`. 엔진 사전 캐시는 없다(Godot 자원 캐시만).
  - 상태 변경 없음. 난수 없음. 시그널 없음.
  - **방향(facing)에 따라 다른 텍스처**를 준다(C:12486-12493).
- 감싸기: `hud_troop_icon(unit_id)`. 랩 사전에 `[unit_id, facing]` 키로 받아 둔다. `display_values[id].facing`이 바뀔 때만 다시 부른다. [추정]
- 15개 쓰기와 무관한 이유: 읽기와 load뿐이다. RB:73이 엔진 안에서 이미 매 프레임 부른다. [사실: 코드 / 추정: 매 프레임 실행]

#### N4 `_get_formation_status_summary_text`
- 위치: C:4216-4217 → `_get_unit_status_summary_text_compact` C:4166-4177 → `_get_unit_status_display_entries`(엔진이 PC 인스턴스라 PC:310 덮어쓰기 → `super` C:4061). [사실]
- 인자·반환: `(unit_state: BattleUnitState) -> String`. [사실]
- 부작용 [사실]:
  - 없음. 새 `PackedStringArray`와 새 Array를 만들 뿐이다.
  - 읽는 것: `status_effects`(`has_status_effect`/`get_status_turns` US:264-272), `is_defending`, 버프 사전 `unique_skill_attack_buff_turns_by_unit_id`/`..._bonus_by_unit_id`(C:5865-5867), `unique_skill_defense_buff_bonus_by_unit_id`(C:5888). 모두 `.get`이다.
  - 이름 변환 `BattleUITextFormatHelper.format_unique_skill_status_display_name`(helper:102-103)은 상수 사전 `get`이다.
  - PC:314 `inherited_entry.duplicate(true)`로 복사한 뒤 고친다. 원본을 바꾸지 않는다.
  - 난수·load·캐시·시그널 없음.
- 감싸기: `hud_status_summary(unit_id) -> String`. **재생 중에는 새로 읽지 않는다.** `status_display`와 같은 규칙(EP:1045 `if not _enemy_presentation_busy()`)으로 랩 사전에 넣고, 재생 중에는 마지막 값을 보인다. [추정]
- 15개 쓰기와 무관한 이유: 순수 계산이다. RB:78이 이미 매 프레임 부른다. [사실]

#### N8 `_get_production_roster_next_enemy_actor` (보류 후보)
- 위치: C:16032-16038 → `_get_next_available_enemy_ai_actor` C:13587-13595. [사실]
- 인자·반환: `() -> BattleUnitState` (아군 단계가 아니면 null, C:16036-16037). [사실]
- 부작용 [사실]:
  - 없음. 후보 5명을 `_is_unit_state_available_for_battle_slot`로 거르고 `action_lock_state_service.first_unacted`(service:65-69, `has_unit_acted` 읽기)로 고른다.
  - 함수 주석도 "never reserves, consumes, or changes turn state"라고 적는다(C:16033-16035).
  - 난수·load·캐시·시그널 없음.
- 감싸기: `hud_next_enemy_id() -> String`. 객체 대신 `unit_id`만 돌려준다. [추정]
- 15개 쓰기와 무관한 이유: 적 AI 선택 함수를 "미리 보기"로만 부른다. 결과를 저장하지 않는다. [사실]
- 보류 이유: 2D에서도 현재 행동자와 같은 금색이라 구분이 안 된다(C:16068-16073). 3D에는 적 행동자용 빨간 고리(`actor_ring` EP:354)가 따로 있다. [사실/추정]

#### N9 `_is_unit_state_active_by_capacity_slot` (보류 후보)
- 위치: C:9247-9253 → `_get_capacity_slot_id_for_unit_state` C:9124, `_is_capacity_slot_active` C:9024-9027. [사실]
- 인자·반환: `(unit_state) -> bool`. [사실]
- 부작용: 없음. 슬롯 메타 사전(`capacity_slot_metadata_registry`) `get`뿐이다(C:9011). [사실]
- 감싸기: `hud_slot_active(unit_id) -> bool`. [추정]
- 15개 쓰기와 무관한 이유: 사전 읽기뿐이다. [사실]
- 보류 이유: 랩은 이미 `_is_unit_state_available_for_battle_slot`를 읽는다. 차이는 "지원군 대기 슬롯을 회색 카드로 보일지"뿐이다. [추정]

### (c) 승인하지 않을 때

| 후보 | 대체 | 잃는 것 |
|---|---|---|
| N1 이름 | `unit_id` 글자를 그대로 보인다 | "관우" 대신 "guan_yu". 지원군은 "enemy_reinforce_01_demo"처럼 보인다(C:11784 이하 기본 부대 정의) [사실] |
| N2 초상 | 진영별 고정 그림(예: 2D 기본 대체 그림 경로를 랩 상수로) | 장수 얼굴. 모든 카드가 같은 그림 [추정] |
| N3 병종 아이콘 | `unit_type`으로 랩이 정한 그림 표(보병·기병…) | 2D 토큰 그림과 방향 반영. 국가별 그림(`korea_archer` 등) [추정] |
| N4 상태 요약 | `status_display`(재생 후) + 랩 `STATUS_TEXT`(EP:40-45)로 만든 글 | 2D와 같은 글 모양, 방어·특기 버프 항목, "외 N" 줄임 [사실: 차이 / 추정: 화면] |
| N8 | 테두리는 현재 행동자만 | 아군 단계에서 "다음 적" 미리보기 |
| N9 | `available`로만 카드 표시 | 대기 중 지원군 카드 회색 표시 |

### (d) 테스트 영향·위험·작업량

- 기존 테스트 영향 [추정]: 0. 랩 노드(`roster_label`, `action_badges`)는 그대로 두면 그 테스트(3파일, 9파일)는 영향이 없다.
- `test_battle3d_top_hud.gd`의 `other_ui_rects`(33-42행)는 셸 레이어의 보이는 최상위 Control도 센다. 적 로스터 1595..1865 × 156..680은 랩 글자 두 줄(770..1143 × 126..157, 890..1024 × 159..183)과 겹치지 않는다. [사실: 숫자 / 추정: 테스트 통과]
- 1280×800 테스트에서는 1595 이후가 화면 밖이다. 표시만 영향이고 테스트 대상은 아니다. [추정]
- 검증기: 고정 범위라 깨지지 않는다. 새 블록 검증기가 READ_CALLS에 N2·N3·N4를 더해야 한다. [사실: 0-4 / 추정: 필요]
- 위험:
  - N2·N3의 load()가 처음 한 번 프레임을 늦출 수 있다(텍스처 크기에 따름). [추정]
  - N4를 재생 중에 바로 읽으면 적 재생보다 상태가 먼저 보인다. 위 캐시 규칙으로 막는다. [추정]
  - N3 방향 텍스처는 `display_values`(즉시) 기준이라 적 이동 재생 중 최종 방향이 먼저 보일 수 있다. [추정]
- 작업량 [추정]: 씬 복사(적 로스터 70노드 + 배너) 1개, 셸 연결, 랩 읽기 함수 3~4개. 코드 150~250줄, 새 테스트 1~2개, 새 검증기 1개.

---

## 블록 4-1 아군 로스터 + 현재 행동 장수

노드:
- `AllyRosterHud`(P:4444) 54..324 × 150..674. 슬롯 구조는 블록 3과 같다. [사실]
- `CurrentActorInfoHud`(CAH, CA:45-48이 붙임) 451..1463 × 825..1045. 대상은 `active_unit_state` 하나뿐이다(CA:159). [사실]

### (a) 값 표

아군 로스터 값은 블록 3 표와 같다(이름 N1, 초상 N2, 병종 아이콘 N3, 상태 요약 N4, 준비 아이콘 = 기존 `_can_use_unique_skill`). 차이만 적는다.

| 값 | 2D 출처 (file:line) | 2D 노드 | 랩이 이미 가짐 | 엔진 기존 함수(랩이 이미 읽음) | 새 읽기 필요 |
|---|---|---|---|---|---|
| 로스터 준비 아이콘 | C:7483 (= `_can_use_unique_skill`) | `AllyRosterHud/SlotNN/UniqueSkillReadyIcon` | — | `_can_use_unique_skill` EP:1122 | 아니오 |
| 접힘 초상 클릭 → 아군 선택 | RP:231-240 `_select_ally_unit` | `AllyRosterPortraitOnlyLayer` | 랩 쓰기 #1 `_select_ally_unit`(EP:450) | — | 아니오(쓰기는 기존 15개 안). 랩 함수가 필요하면 새 랩 함수만 [추정] |
| 대상 유닛 | `active_unit_state` C:950 (CA:159) | 전체 | `selected`(EP:351) **즉시** | `active_unit_state` | 아니오 |
| 이름 | `display_name` (CA:177) | `InfoArea/NameLabel` | 없음 | — | **N1** |
| 병종명 | REG `get_battle_profile(hero_id).unit_type` 우선(CA:166, 178-181) | `InfoArea/TroopClassLabel` | `display_values.unit_type` **즉시** | — | 2D와 같게 하려면 **N6** + REG. 아니면 0 |
| 병력 | `current_hp`/`max_hp` (CA:182) | `InfoArea/TroopRow/TroopsLabel` | `current_troops`/`max_troops` **즉시** | — | 아니오. `apply_damage`가 hp와 troops를 같은 양만큼 줄인다(US:238-242) [사실]. 값이 다를 가능성은 [추정] 낮음 |
| 지휘/무력/지력 | REG `get_base_stats(hero_id).stats` 우선, 없으면 `unit.leadership`/`martial`/`intelligence`(CA:185-190) | `InfoArea/StatsRow/CommandStat/Value` "지휘 %d", `MightStat/Value` "무력 %d", `IntellectStat/Value` "지력 %d" | 없음 | — | **N6** + REG(엔진 밖). 대체로 **N10**(`martial`·`intelligence` 필드). `leadership` 필드는 `BattleUnitState`에 없다(US:13-56 grep) [사실] |
| 고유특기 이름·설명 | REG `get_unique_skill_for_hero` 우선, 없으면 `unique_skill_definition`(CA:167, 171-195) | `InfoArea/UniqueTraitArea/UniqueTraitLabel`, `UniqueTraitSummaryLabel` | — | `_get_unique_skill_for_unit`(EP:1117) → `name`/`description`(resolver:64-78) | 런타임 정의로 충분하면 0. REG와 같게 하려면 N6 |
| 초상 | `res://assets/heroes/portraits/current_actor/<country>/<country>_<hero_id>.png`(CA:256, 270), 실패 시 N2(CA:202-203) | `PortraitSlot`(런타임 `BoundPortrait`) | 없음 | — | **N6**(경로 규칙) 또는 **N2**(대체) |
| 병종 아이콘 | `_get_troop_icon_texture_for_visual_key("<country>_<unit_type>", null)` 후 `("", unit)`(CA:208-216) | `InfoArea/TroopRow/TroopTypeIconSlot`(`BoundTroopTypeIcon`) | 없음 | — | **N3** |
| 특기 사용 가능 배지 | `_can_use_unique_skill(unit)`(CA:293-296), 펄스 | `BoundUniqueSkillReadyBadge`(573..657 × 807..891) | — | `_can_use_unique_skill` | 아니오 |
| 상태 행 1~5 | `_get_unit_status_display_entries`(PC:310 → C:4061), "부상" 제외 최대 5개(CA:301-327) | `StatusArea/StatusRow01..05/Label` + 툴팁 | 일부 `status_display` **재생 후** | — | **N5** |
| 지형 | `worldmap_battle_context`, 없으면 "평지"/"방어 0%"/"이동 0%"(CA:17-19, 349-368) | `TerrainArea/TerrainNameLabel`, `TerrainEffectLabel` | 해당 없음 | — | 아니오. 랩은 월드맵 문맥이 없다고 본다 [추정]. 기본 글을 랩 상수로 둔다. EP에 `worldmap` 글자를 쓰면 m5c FORBIDDEN에 걸린다 [사실] |

### (b) 새 읽기 후보

N1·N2·N3은 블록 3과 같다. 새로 나오는 것만 적는다.

#### N5 `_get_unit_status_display_entries`
- 위치: PC:310-324 (덮어쓰기) → C:4061-4141. [사실]
- 인자·반환: `(unit_state: BattleUnitState) -> Array[Dictionary]`. 항목은 `{"id","badge","summary"}`. [사실]
- 부작용 [사실]:
  - 없음. N4와 같은 읽기다. PC:314 `inherited_entry.duplicate(true)`로 새 사전을 만든다.
  - 난수·load·캐시·시그널 없음.
- 감싸기: `hud_status_entries(unit_id) -> Array`. 돌려주기 전에 `.duplicate(true)`. 재생 중 캐시 규칙은 N4와 같다. [추정]
- 15개 쓰기와 무관한 이유: 순수 계산이다. CA:303-304와 SL:83-86이 엔진 안에서 이미 매 프레임 부른다. [사실]

#### N6 `_get_hero_id_for_unit_state`
- 위치: C:8769-8777. [사실]
- 인자·반환: `(unit_state: BattleUnitState) -> String`. [사실]
- 부작용 [사실]:
  - 없음. `_get_capacity_slot_id_for_unit_state` C:9124(상수 비교), `_get_capacity_slot_metadata` C:9008-9011(사전 `get`), `_get_test_battle_roster_hero_id` C:8758-8759(상수 `TEST_BATTLE_ROSTER` `get`).
  - 난수·load·캐시·시그널 없음.
- 감싸기: `hud_hero_id(unit_id) -> String`. [추정]
- 왜 `unit_id`로 대신할 수 없나 [사실]:
  - 기본 부대 `unit_id`는 "gwon_yul", "ally_reinforce_01_demo" 등이다(C:11784 이하). `TEST_BATTLE_ROSTER`의 hero_id는 "kwon_yul", "gim_yusin"이다(C:498-509). 서로 다르다.
- 15개 쓰기와 무관한 이유: 사전·상수 읽기뿐이다. CA:242-243이 이미 매 프레임 부른다. [사실]
- 따라오는 엔진 밖 의존: REG(`hero_design_data_registry.gd`) [사실]
  - `get_base_stats`/`get_battle_profile`/`get_unique_skill_for_hero`(REG:57-97)는 `duplicate(true)`로 돌려준다.
  - 첫 호출 때 `ensure_loaded`(REG:23-51)가 JSON 7개를 `FileAccess`로 읽어 **정적 변수 캐시**에 넣는다(REG:13-21, 155-167). 엔진 상태는 아니다. load()·난수·시그널 없음.
  - CA의 별칭표(CA:21-26, 예 "gwon_yul"→"kwon_yul")도 함께 옮겨야 같은 값이 나온다. [추정]
  - REG 경로에 `worldmap` 글자가 있다. EP에서 preload하면 m5c FORBIDDEN(:41)에 걸린다. 별도 파일에 두거나 새 검증기에서 예외로 해야 한다. [사실: 정규식 / 추정: 해결 방법]

#### N10 `martial`·`intelligence` (유닛 필드, 보류 후보)
- 위치: US:41 `intelligence`, US:42 `martial`. [사실]
- 부작용: 없음(평범한 속성). [사실]
- 감싸기: `hud_stats(unit_id) -> Dictionary`(새 사전). [추정]
- 15개 쓰기와 무관한 이유: 필드 읽기뿐. [사실]
- 보류 이유: CA는 REG 값을 먼저 쓴다(CA:185-187). 필드 값은 대체값일 뿐이다. 지휘는 필드가 없다. N6+REG가 승인되면 필요 없다. [사실/추정]

### (c) 승인하지 않을 때

| 후보 | 대체 | 잃는 것 |
|---|---|---|
| N1 | `unit_id` 글자 | 장수 한글 이름 |
| N2 / N6(초상) | 진영별 고정 그림 | 현재 행동 장수 얼굴 |
| N3 | `unit_type` 그림 표 | 국가별 병종 그림 |
| N5 | `status_display`(재생 후) + `STATUS_TEXT`로 행 5개 | 2D 글 모양, 방어·특기 버프 행, 행 툴팁 |
| N6 + REG(능력치) | 능력치 행에 "-" 표시(CA:226-228의 빈 값 글과 같음) | **지휘/무력/지력 숫자 전부** |
| N10 | N6+REG와 함께 없으면 "-" | 무력·지력 대체값 |

### (d) 테스트 영향·위험·작업량

- 겹침(H1 2-4) [사실]: 아군 로스터는 랩 정보 상자(270×55), 방향 버튼(270×31), 공격(130×38), 대기(110×38), 방어(10×38)와 겹친다. 블록 4-2와 같은 단계에서 랩 UI를 가려야 겹침이 풀린다.
- 기존 테스트 영향 [추정]:
  - 랩 `info`를 숨겨도 `_refresh_info`(EP:406-410)는 보임 여부를 보지 않고 글을 쓴다. `info` 글 테스트(3파일)는 그대로 돈다.
  - SH:137-147은 `info` 패널의 `get_global_rect()`로 글자 두 줄 왼쪽 한계를 정한다. 숨겨도 사각형은 남아 같은 값이 나온다고 본다. `test_battle3d_top_hud`의 위치 검사는 영향이 적다.
  - `other_ui_rects`는 보이는 Control만 센다. 새 2D 현재 행동 장수(451..1463 × 825..1045)와 아군 로스터(54..324 × 150..674)는 글자 두 줄과 겹치지 않는다. [사실: 숫자]
- 위험:
  - REG 의존이 검증기 FORBIDDEN과 부딪친다(위 N6). [사실]
  - 적 턴에 `active_unit_state`가 무엇인지는 H1에서도 미확인이다. 2D와 같은 소스(`selected`)라 동작은 같다. [추정]
- 작업량 [추정]: 씬 2개 복사(아군 로스터 70노드, CurrentActorInfoHud 55노드 + 런타임 아이콘 7개), 랩 읽기 함수 2~3개 추가(N5, N6, 블록 3 것 재사용), REG·별칭 읽기 파일 1개. 코드 300~450줄, 새 테스트 2개, 새 검증기 1개. 블록 4-2와 같은 단계로 묶을지는 김작 결정.

---

## 블록 4-2 부대 명령 패널 + 방향 선택

노드:
- `BattleUI/FloatingAllyCommandPanel`(P:3451) 6노드. 버튼 5개: `FloatingBasicAttackButton`(기본공격), `FloatingUniqueSkillButton`(고유특기), `FloatingTacticsButton`(책략), `FloatingMoveButton`(글자 "방어"), `FloatingWaitButton`(대기). 위치는 행동 유닛 옆(C:6267). [사실]
- 방향: `FacingSelectionPanel`(P:3776), `FacingArrowPanel`(P:3824). [사실]

### (a) 값 표

| 값 | 2D 출처 (file:line) | 2D 노드 | 랩이 이미 가짐 | 엔진 기존 함수(랩이 이미 읽음) | 새 읽기 필요 |
|---|---|---|---|---|---|
| 패널 표시 | `_should_show_floating_ally_command_panel` C:6198-6219: `is_floating_ally_command_panel_requested`, 대상 선택 모드 아님, 결과 미확정, 연출 아님, 자동 아님, `ally_turn`, 아군 행동자 있음 | 패널 `visible` | `selected`, `battle_result`, `_enemy_presentation_busy()`(EP:527) | `current_phase`, `is_demo_animating`, `is_full_auto_battle_enabled`, `active_unit_state`, `_is_unit_state_available_for_battle_slot` | 보류 후보 **N11** (`is_floating_ally_command_panel_requested` C:956) |
| 기본공격·방어·대기 활성 | `ally_turn` + 연출 아님 + `_is_active_ally_action_available()`(C:6229-6241, C:14051) | 버튼 `disabled` | 랩 `attack_button.disabled`(EP:357), `_wait_block_reason`/`_defend_block_reason`(EP:530-549) **즉시** | 위 속성들 | 아니오. 2D 버튼은 랩 버튼과 같은 규칙을 쓴다 [추정 권장] |
| 고유특기 활성 | `ally_turn` + `_can_use_unique_skill`(C:6244) | `FloatingUniqueSkillButton.disabled` | `_skill_block_reason`(EP:1111-1123) | `_can_use_unique_skill` | 아니오 |
| 특기명 | `skill_data.name`(C:6248) | 같은 버튼 글자 앞부분 | `_skill_name` 방식(EP:1198-1202) | `_get_unique_skill_for_unit`(resolver:70이 `name` 채움) | 아니오 |
| **비용 글자 "특기명 · 기세 N"** | `_get_effective_unique_skill_cost` C:5486 (C:6246-6250) | `FloatingUniqueSkillButton` 글자 | 원래 비용 `skill.momentum_cost`만(EP:1120) | `_get_unique_skill_for_unit` | **N7** |
| 특기 툴팁 "설명\n공용 기세 %d/%d · 소비 %d" | `description`, `battle_momentum.get_value("ally")`, `MAX_MOMENTUM`(=10, `battle_momentum_state.gd:6`), 비용(C:6251-6256) | `FloatingUniqueSkillButton.tooltip_text` | 설명·기세 읽기 있음 | `_get_unique_skill_for_unit`, `battle_momentum` | 비용 부분만 **N7** |
| 책략 활성 | `can_issue` + `_can_use_strategy`(C:6261) | `FloatingTacticsButton.disabled` | `_strategy_block_reason`(EP:874-880) | `_can_use_strategy`, `_get_strategy_targets` | 아니오 |
| 책략 툴팁 "지력 80 이상 필요" | `intelligence < STRATEGY_BASIC_INTELLIGENCE`(80, C:85; C:6263-6264) | `FloatingTacticsButton.tooltip_text` | 랩 툴팁 "책략 불가 · 엔진 조건(지력·혼란·행동 여부)…"(EP:878) | `_can_use_strategy` | 2D 글 그대로면 **N10**(`intelligence`). 랩 툴팁을 쓰면 0 |
| 그 밖 툴팁 | 방어 "" (C:6239). 기본공격·대기는 쓰지 않음 | — | 랩 툴팁(EP:358-369, 거절 사유) | — | 아니오 |
| 방향 선택 표시 | `current_phase == facing_select` | `FacingSelectionPanel`, `FacingArrowPanel` | `facing_ui.visible`(EP:349) **즉시** | `current_phase` | 아니오 |
| 방향 결정 | `_select_post_move_facing` C:6755 | 화살표 4개 | 랩 쓰기 #3 `confirm_facing`(EP:472/477) | — | 아니오(쓰기는 15개 안) |
| 현재 방향 | `unit_state.facing` | 화살표 강조 [추정] | `display_values.facing` **즉시** | — | 아니오 |

버튼 → 랩 함수 (H1 2-3, 모두 기존 쓰기 15개 안) [사실]: 기본공격 → `request_attack`(EP:602), 고유특기 → `request_skill`(EP:1125), 책략 → `request_strategy`(EP:882), 방어 → `request_defend`(EP:576), 대기 → `request_wait`(EP:551), 방향 → `confirm_facing(dir)`(EP:472).

**차이 한 가지 [사실]**: 랩 대기·방어 사유(EP:536-549)는 혼란을 보지 않는다. 엔진 `_is_active_ally_action_available`(C:14051-14060)은 `_is_unit_confused`(혼란·행동 봉쇄·공포, C:4053-4058)도 본다. 그래서 혼란 부대에서 2D 패널은 꺼지고 랩 버튼은 켜질 수 있다. 엔진이 다시 검사하므로 결과는 같다(EP:537 주석). 화면만 다르다. [추정: 화면]

### (b) 새 읽기 후보

#### N7 `_get_effective_unique_skill_cost`
- 위치: C:5486-5490. [사실]
- 인자·반환: `(caster_state: BattleUnitState, skill_data: Dictionary) -> int`. [사실]
- 본문 [사실]:
  - `var cost := maxi(int(skill_data.get("momentum_cost", 0)), 0)`
  - `if caster_state != null and caster_state.has_status_effect("skill_cost_up"):` → `cost += maxi(caster_state.get_status_magnitude("skill_cost_up", 1), 1)`
  - `return mini(cost, BattleMomentumStateScript.MAX_MOMENTUM)`
- 부작용: 없음. 난수·load·캐시·시그널 없음. [사실]
- 감싸기: `hud_skill_cost(unit_id) -> int`. 안에서 `_get_unique_skill_for_unit` 결과를 그대로 넘긴다(이미 복사본, resolver:65 `duplicate(true)`). [사실/추정]
- 15개 쓰기와 무관한 이유: 정수 계산뿐이다. 기세를 쓰지 않는다(`spend` 없음). [사실]
- 덧붙임: 랩 `_skill_block_reason`(EP:1120)은 원래 비용으로 기세 부족을 판단한다. `skill_cost_up`이 걸리면 엔진 `_has_valid_unique_skill_action`(C:4426, 유효 비용 사용)과 판단이 달라진다. 이 읽기를 승인하면 랩 사유 글도 맞출 수 있다. [사실: 코드 / 추정: 손볼 범위]

#### N11 `is_floating_ally_command_panel_requested` (보류 후보)
- 위치: C:956 `var is_floating_ally_command_panel_requested := false`. 쓰는 곳 C:3769, 3821, 3962, 4744, 5507, 6272, 6444, 6773, 8027, 14526. [사실]
- 인자·반환: 속성 → `bool`. [사실]
- 부작용: 없음(속성 읽기). [사실]
- 감싸기: `hud_command_panel_requested() -> bool`. [추정]
- 15개 쓰기와 무관한 이유: 읽기만 한다. 값은 엔진이 쓰기 명령 처리 중에 스스로 바꾼다. [사실]
- 보류 이유: 랩은 지금도 "행동자 있음 + `ally_turn` + 재생 아님"으로 버튼을 켠다. 2D와 같은 열림·닫힘 시점이 필요할 때만 쓴다. [추정]

(N10 `intelligence`는 블록 4-1 절 참조. 4-2에서는 책략 툴팁 글자 하나에만 쓰인다.)

### (c) 승인하지 않을 때

| 후보 | 대체 | 잃는 것 |
|---|---|---|
| N7 | `skill.momentum_cost`(기존 읽기)로 "특기명 · 기세 N" | `skill_cost_up`(기세 비용 증가) 상태일 때 숫자가 실제보다 작다. 이때만 다르다 [사실] |
| N11 | 랩 규칙으로 패널 표시 | 2D와 같은 열림 시점(대상 선택 취소 뒤 등) [추정] |
| N10 | 랩 툴팁(거절 사유) 그대로 | "지력 80 이상 필요" 문구 |

### (d) 테스트 영향·위험·작업량

- 기존 테스트 영향 [추정]: 랩 버튼 노드를 남기면 0.
  - 버튼 테스트는 `pressed.emit()`을 쓴다. 위치와 무관하다(부록 B TASK 2). [사실]
  - 툴팁 테스트는 랩 버튼의 `tooltip_text`를 읽는다. 랩 버튼을 지우지 않고 숨기기만 하면 글은 계속 갱신된다(EP:358-369는 보임 여부를 보지 않음). [사실: 코드]
  - `facing_ui`는 자식 버튼을 글("방향 left")로 찾아 누른다(10파일). 노드를 남기면 영향 없다. [사실/추정]
- 위험:
  - 2D 패널은 유닛 옆으로 움직인다(C:6267 → `_position_floating_ally_command_panel` C:6292). 3D에서는 카메라 투영 좌표가 필요하다. 이 위치 계산 본문은 이번에 읽지 않았다. [사실: 위치 / 미확인: 본문]
  - 혼란 차이(위)로 2D 패널과 랩 버튼의 활성 상태가 다를 수 있다. [추정]
- 작업량 [추정]: 패널 6노드 + 방향 패널 11노드 복사, 3D 투영 위치, 랩 읽기 1개(N7). 코드 150~250줄, 새 테스트 1~2개.

---

## 블록 5 결과 화면·토스트·컷인

노드: `RoundToastRoot`(P:3505), `UniqueSkillToastRoot`(P:3540), `EnemyRetreatToastLayer`/`EnemyRetreatToastRoot`(P:6419), `ResultOverlay`(P:6503), `CutinOverlay`(P:6468), `HeroCutinOverlay`(P:6538), `SkillCutinLayer`(P:3862), `WorldMapResultReturnButton`(C:2889-2908, 월드맵 전용). [사실: 부록 A]

### (a) 값 표 (토스트 5개 + 컷인)

| 토스트 | 2D 값과 출처 (file:line) | 2D 노드 | 3D 랩에 비슷한 글이 있나 (file:line, 시점) | 엔진 기존 함수(랩이 이미 읽음) | 새 읽기 필요 |
|---|---|---|---|---|---|
| T-a 라운드 | "BATTLE %d"(C:10473), 숫자 `battle_round`. 호출 `_start_new_round` C:11416 → `_show_round_start_banner` C:10465. 이벤트 `round_started {round}` C:11417. 그림 `round_toast_ink_war_01.png`(부록 A T1) | `RoundToastRoot` | **있음**: `current_round`(EP:115, EP:815·839) + 상태 줄 "라운드 %d"(EP:841, `_enemy_text`) **재생 후**. `turn_label` "라운드 N · …"(EP:390) | `enemy_action_event_log` | 아니오 |
| T-b 지원군 도착 | 글 상수 "지원군 도착!"(C:165), 그림 `reinforcement_arrival_toast_01.png`(C:164). `_show_reinforcement_arrival_toast(round, units)` C:10476, 라운드당 1번 | `RoundToastRoot` | **있음**: `reinforcement_arrived`(tactic 로그, EP:980-985) → `_present_arrival` EP:1080: 상태 줄 "지원군 도착 · 아군/적군 · id"(EP:1089), Label3D `arrival_label` "지원군 도착"(EP:1096-1105, 2초). **재생 후**(그 라운드 `round_started` 재생까지 붙잡음, EP:981-983, 1076-1078) | `tactic_event_log` | 아니오. 2D는 라운드당 1장, 랩은 부대마다 1개라 묶기만 다르다 [사실] |
| T-c 장수 퇴각/전멸 | 이름 `display_name`, 대사 `_get_defeat_retreat_line` C:10453, 초상 `_get_retreat_toast_portrait_texture` C:10442, 진영 색(C:10377-10380). 묶음 `_make_defeat_retreat_toast_snapshot` C:10310-10319. 트리거 `_cleanup_dead_units` C:14102-14106, 한 번에 최대 3개(C:347), 넘으면 로그 "%s 전투이탈"(C:14108). 이벤트 `unit_defeated {unit_id}` C:14114 | `EnemyRetreatToastRoot`(RP가 화면 가운데 740..1180 × 488..592로) | **일부**: `unit_defeated` → 전투 기록 "격파 · id"(EP:689-690) **수신 시**(재생 전). 적 공격 `killed`(EP:746 요약은 수신 시), 특기 피해 `killed` → `skill_label` "−N\n격파"(EP:1224). 퇴각 토스트 같은 화면 글은 **없음** | `battle_action_event_log` | **N1**(이름), 보류 **N13**(대사), 초상은 **N2** 재사용(N14는 불필요) |
| T-d 고유특기 | 이름 `skill_data.name`, 토스트 글 `toast_text` "%s!"(resolver:70-71). 그림 `cutin_image_path` 또는 대체(C:5445-5450). `_show_unique_skill_toast_over_unit` C:5313(영상 컷인 없을 때) | `UniqueSkillToastRoot` | **있음**: `skill_cast` → `_skill_name`(EP:1198-1202) → Label3D `skill_label`(EP:1212, EP:1256-1271) + 상태 줄 "특기 · id · 이름 (기세 −N)"(EP:1213). 적은 `enemy_skill_label`(EP:1265), "적 특기 사용: skill_id"(EP:831) **재생 후** | `_get_unique_skill_for_unit`, `tactic_event_log` | 이름은 아니오. 그림은 `_get_unique_skill_for_unit` 결과의 `cutin_image_path` 키(있을 때)로 가능 [추정] |
| T-e 결과 | "승리!"/"패배"(C:367-368), 그림 `battle_result_victory.png`/`battle_result_defeat.png`(C:365-366), 영상 `victory_result_theora_q8_1920x.ogv`/`defeat_result_theora_q8_1920x.ogv`(C:371-372). `_try_show_battle_result_toast_if_needed` C:10637 → 영상 → `_show_battle_result_toast` C:10492. 퇴각 토스트가 끝나야 나온다(C:10644) | `ResultOverlay`, `RoundToastRoot` | **있음**: `battle_result`(EP:116, EP:774) **수신 시**, `result_overlay` "승리"/"패배"(EP:845-846) **재생 후**, 셸 `result_label` "승리/패배 · 라운드 N · 생존 아군 K부대"(SH:155) 재생 끝난 뒤 | `enemy_action_event_log`(`battle_ended {result_state}` C:10627) | 아니오 |
| 결과 이유 | `battle_result_reason` C:918: "elimination"(기본), "turn_limit"(C:11394), "retreat"(C:6162, RP:172) | **2D 화면 노드 없음.** 쓰는 곳은 월드맵 결과 payload(C:2988)뿐. 복귀 버튼 글은 이유가 아니라 결과 상태로 정한다(C:2918-2924) | 없음 | — | 2D 대응으로는 불필요(**N12**) |
| 컷인 | 영웅 컷인 `_play_committed_hero_cutin` C:4782: hero_id(C:4790) + `KoreaMvpHeroCutinRegistry.find_entry`(C:4800) → `video_path`, `skill_title_texture_path`(C:4814-4815). 특기 영상 컷인 C:4895, 아군만(C:5014) | `HeroCutinOverlay`, `SkillCutinLayer`, `CutinOverlay` | 없음 | — | 보류: **N6** + 컷인 레지스트리(엔진 밖) |

### (b) 새 읽기 후보

N1(이름), N2(초상), N6(hero_id)은 앞 절과 같다. 블록 5에서 새로 보는 것:

#### N13 `_get_defeat_retreat_line` (보류 후보)
- 위치: C:10453-10462. 대사 표 `ENEMY_RETREAT_TOAST_LINES` 5줄(C:348-354), `ALLY_DEFEAT_TOAST_LINES` 5줄(C:355-361). [사실]
- 인자·반환: `(unit_state: BattleUnitState) -> String`. [사실]
- 부작용 [사실]:
  - 없음. 줄 고르기는 `absi(unit_state.unit_id.hash()) % lines.size()`(C:10461)다. **난수가 아니라 해시**라 같은 부대는 늘 같은 줄이다.
  - load·캐시·시그널 없음.
- 감싸기: `hud_defeat_line(unit_id) -> String`. [추정]
- 15개 쓰기와 무관한 이유: 상수 표에서 고르기만 한다. [사실]
- 보류 이유: 연출 대사다. 랩이 같은 10줄을 따로 가져도 되지만 그러면 엔진 데이터를 복제한다. 김작 판단. [추정]

#### N14 `_get_retreat_toast_portrait_texture` (불필요)
- 위치: C:10442-10450. [사실]
- 부작용 [사실]: `_load_unique_skill_texture` C:5458-5470을 거쳐 **load()**(C:5465)와 **캐시 채움** `unique_skill_texture_cache[path] = texture`(C:5468)가 있다. 마지막 대체는 N3(C:10450).
- 불필요 이유: 같은 장수 초상을 N2로 이미 받는다. 우선순위만 다르다(N14는 `battlefield_portrait_path` 먼저, N2는 `portrait_path` 먼저, C:2161). [사실]

#### N12 `battle_result_reason` (불필요)
- 위치: C:918 속성 → `String`. 부작용 없음(속성 읽기). [사실]
- 불필요 이유: 2D HUD가 이 값을 화면에 쓰지 않는다(grep: C:2988 payload, 설정 C:6162·11394, RP:172뿐). [사실]
- 랩에서 나올 수 있는 값은 "elimination"과 "turn_limit"뿐이라고 본다. "retreat"는 월드맵 공격전에서만 생긴다(C:6152-6166, H1 2-1). [추정]
- 30라운드 판정(`BATTLE_MAX_TURNS` = 30, `expedition_supply_calculator.gd:10`)은 랩이 `current_round`로도 짐작할 수 있다. [추정]

**부르면 안 되는 함수 [사실]**:
- `_handle_battle_end_guard` C:10614-10634: 토스트 큐를 비우고(C:10618), 자동전투를 멈추고(C:10620), `battle_ended`를 기록한다(C:10627).
- `_try_show_battle_result_toast_if_needed` C:10637-10655: `has_battle_result_toast_shown`을 바꾸고 영상을 튼다.
- `_play_committed_hero_cutin` C:4782: 넘긴 `skill_data`를 고친다(C:4805 `skill_data["cutin_image_path"] = …`)고 연출을 시작한다.
- 이 셋은 "읽기"가 아니다. 결과 화면·컷인은 이미 있는 이벤트(`battle_ended`, `skill_cast`)만으로 만든다.
- `_get_battle_result_state` C:10571-10580 자체는 부작용이 없다. 다만 랩은 `battle_result`로 이미 같은 값을 가진다. 불필요.

### (c) 승인하지 않을 때

| 후보 | 대체 | 잃는 것 |
|---|---|---|
| N1 (T-c) | `unit_id` 글자 | 퇴각 토스트의 한글 이름 |
| N13 (T-c) | 랩 고정 문구 한 줄(예: "후퇴한다!") 또는 대사 없음 | 부대별 대사 5종 |
| N2 (T-c) | 초상 없이 이름·진영 색만 | 얼굴 |
| N6 + 컷인 레지스트리 | 컷인 없이 T-d 토스트(특기 이름)만 | 영웅 컷인 영상·특기 제목 그림 |
| N12 | 이유 표시 없음(2D와 같음) | 없음 |

### (d) 테스트 영향·위험·작업량

- 기존 테스트 영향 [추정]:
  - `result_overlay`(9파일, 보임·글)와 셸 `result_panel`(6파일)·`result_label`(4파일)을 남기면 0.
  - 2D 결과 화면을 위에 덮으면서 랩 `result_overlay`를 `visible=false`로 하면 그 9파일이 깨질 수 있다. 숨기지 않고 앞에 그리기만 하는 방식이 안전하다.
  - `arrival_label`을 읽는 테스트는 0개, `skill_label` 2개, `enemy_skill_label` 1개(부록 B). Label3D를 남기면 0.
  - `test_battle3d_top_hud`의 `other_ui_rects`는 `result_overlay`만 뺀다(33-42행). 새 토스트가 보이는 순간 셸 레이어 최상위에 있으면 겹침 검사에 잡힐 수 있다. 토스트 사각형 550..1370 × 300..720(부록 A T1)은 글자 두 줄(y 126..183)과 겹치지 않는다. [사실: 숫자]
- 위험:
  - 시점: `unit_defeated`는 수신 시라 적 턴 재생보다 먼저 온다(EP:299, 682-692). 퇴각 토스트는 재생된 `enemy_attack_resolved.killed`·특기 `killed`에 맞춰야 한다. [사실: 코드 / 추정: 화면]
  - 2D 결과 토스트는 퇴각 토스트가 끝난 뒤 나온다(C:10644). 랩도 같은 순서를 지켜야 한다. [사실]
  - 결과 영상 2개(`.ogv`)와 컷인 영상은 자원 크기가 크다. 복사 범위 결정이 필요하다. [추정]
  - FORBIDDEN 정규식에 `result_toast`·`result_video`가 있다(m5c:41-44). EP 안 식별자 이름을 피해야 한다. [사실]
- 작업량 [추정]: 토스트 큐(우선순위, 결과 확정 시 비결과 토스트 막기: C:10510-10537, 10587-10611 규칙 복제), 토스트 4종 + 결과 화면, 컷인은 따로. 코드 250~400줄(컷인 빼고), 새 테스트 2~3개.

---

## 값 → 블록·노드 위치표 (요청 항목)

| 항목 | 블록 | 2D 노드 | 필요한 읽기 |
|---|---|---|---|
| 초상 | 3 | `EnemyRosterHud/{Slot01,Slot02,Slot03,Reinforce01,Reinforce02}/Portrait`, 접힘 `EnemyRosterPortraitOnlyLayer` | N2 |
| 초상 | 4-1 | `AllyRosterHud/SlotNN/Portrait`, `AllyRosterPortraitOnlyLayer`, `CurrentActorInfoHud/PortraitSlot`(`BoundPortrait`) | N2 (+ 현재 행동 장수 전용 그림은 N6) |
| 초상 | 5 | `EnemyRetreatToastRoot`의 초상(`enemy_retreat_portrait`, C:10372-10374) | N2 재사용 |
| 병종 아이콘 | 3 | `EnemyRosterHud/SlotNN/TroopIconRect` | N3 |
| 병종 아이콘 | 4-1 | `AllyRosterHud/SlotNN/TroopIconRect`, `CurrentActorInfoHud/InfoArea/TroopRow/TroopTypeIconSlot`(`BoundTroopTypeIcon`) | N3 |
| 고유특기 준비 아이콘 | 3 | `EnemyRosterHud/SlotNN/UniqueSkillReadyIcon` (적은 2D에서도 항상 숨김, C:3640) | 없음(기존 `_can_use_unique_skill`) |
| 고유특기 준비 아이콘 | 4-1 | `AllyRosterHud/SlotNN/UniqueSkillReadyIcon`, `CurrentActorInfoHud/BoundUniqueSkillReadyBadge` | 없음(기존 `_can_use_unique_skill`) |
| 지휘/무력/지력 | 4-1 | `CurrentActorInfoHud/InfoArea/StatsRow/CommandStat/Value`, `MightStat/Value`, `IntellectStat/Value` | N6 + REG (대체 N10) |
| 비용 글자 | 4-2 | `FloatingAllyCommandPanel/FloatingUniqueSkillButton` 글자 "%s · 기세 %d"와 툴팁 "… · 소비 %d" | N7 |
| 결과 이유 | 5 | **없음**(2D 화면에 표시하지 않음). 월드맵 payload `result_reason`(C:2988)뿐 | N12(불필요) |

---

## 읽기 총목록

| block | 이름 | 부작용 | 추천 승인 여부 | 이유 |
|---|---|---|---|---|
| 3, 4-1, 5 | N1 `display_name` (US:19, 필드) | 없음 | 추천 | 장수 이름을 보일 유일한 길. 필드 읽기. `VIEW_FIELDS`는 건드리지 않는다 |
| 3, 4-1, 5 | N2 `_get_closeup_portrait_texture_for_unit` (C:7603) | load()(C:8906) + 엔진 캐시 사전 쓰기(`hero_identity_texture_cache`, C:8909). 난수·시그널 없음 | 추천 | 엔진 안 RB:71이 이미 매 프레임 같은 호출. 캐시는 다른 규칙과 무관. 랩은 유닛당 1회만 |
| 3, 4-1 | N3 `_get_troop_icon_texture_for_visual_key` (C:7557) | load()(C:12447). 엔진 사전 없음. 방향 따라 결과 다름 | 추천 | RB:73·CA:213-215가 이미 부름. 대체 그림 표는 2D 그림과 다름 |
| 3 | N4 `_get_formation_status_summary_text` (C:4216) | 없음 | 추천 | 버프 항목은 `status_effects`에 없어 랩이 만들 수 없음. 재생 중 캐시 규칙 필요 |
| 4-1 | N5 `_get_unit_status_display_entries` (PC:310 → C:4061) | 없음(PC:314 복사) | 추천 | 상태 행 5개를 2D와 같게. N4와 같은 근원 |
| 4-1 (5 컷인) | N6 `_get_hero_id_for_unit_state` (C:8769) | 없음 | 추천(4-1) / 컷인 용도는 보류 | 능력치·현재 행동 초상에 필요. `unit_id`와 hero_id가 다름(C:498-509 대 C:11784 이하) |
| 4-2 | N7 `_get_effective_unique_skill_cost` (C:5486) | 없음 | 추천 | `skill_cost_up`일 때 비용 글자가 틀리지 않게. 정수 계산뿐 |
| 3 | N8 `_get_production_roster_next_enemy_actor` (C:16032) | 없음 | 보류 | 현재 행동자와 같은 금색이라 효과 작음. 3D에 적 고리 있음 |
| 3, 4-1 | N9 `_is_unit_state_active_by_capacity_slot` (C:9247) | 없음 | 보류 | 기존 `available` 읽기로 대부분 됨. 지원군 대기 회색 표시만 |
| 4-1, 4-2 | N10 `martial`·`intelligence` (US:41-42, 필드) | 없음 | 보류 | N6+REG가 승인되면 대체값일 뿐. 지휘 필드는 없음 |
| 4-2 | N11 `is_floating_ally_command_panel_requested` (C:956) | 없음 | 보류 | 랩 규칙으로 패널 표시 가능. 같은 열림 시점이 꼭 필요할 때만 |
| 5 | N12 `battle_result_reason` (C:918) | 없음 | 불필요 | 2D 화면에 쓰는 곳 없음 |
| 5 | N13 `_get_defeat_retreat_line` (C:10453) | 없음(해시 선택, 난수 아님) | 보류 | 연출 대사. 랩 복제 대 읽기는 김작 판단 |
| 5 | N14 `_get_retreat_toast_portrait_texture` (C:10442) | load()(C:5465) + 캐시 사전 쓰기(`unique_skill_texture_cache`, C:5468) | 불필요 | N2로 대신 |
| 3, 4-1 | `_is_unique_skill_ready_for_formation_guide` (C:7483) | 없음 | 불필요 | `_can_use_unique_skill`(이미 읽음)과 결과가 늘 같다(C:3648) |
| 3, 4-1 | `_get_all_unit_states_in_slot_order` (C:14307) | 없음 | 불필요 | `all_battle_unit_states`(이미 읽음)가 같은 순서(C:9061-9075) |
| 4-2 | `_is_active_ally_action_available` (C:14051) | 없음 | 불필요 | 랩 거절 사유로 대신. 혼란 차이는 화면만(엔진이 다시 검사) |
| 5 | `_get_battle_result_state` (C:10571) | 없음 | 불필요 | 랩 `battle_result`(EP:774)가 같은 값 |
| (엔진 밖) 4-1 | REG `get_base_stats`/`get_battle_profile`/`get_unique_skill_for_hero` (REG:57-97) | 첫 호출 때 JSON 7개 읽어 정적 캐시(REG:23-51). 엔진 상태 아님 | 추천(N6과 함께) | 지휘/무력/지력의 출처. 경로에 `worldmap`이 있어 EP 밖에 둬야 함 |
| (엔진 밖) 5 | `KoreaMvpHeroCutinRegistry` (`scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd`) | JSON 읽어 정적 캐시(:59-67) | 보류 | 컷인 영상 범위가 정해진 뒤 |

부작용 요약 [사실]: 난수를 쓰는 후보는 없다(C의 `randf`/`randi`는 책략 판정 C:3920·3926과 연출 효과에만 있다). 시그널·이벤트 로그 기록을 하는 후보도 없다. load()가 있는 것은 N2·N3·N14, 엔진 캐시 사전을 채우는 것은 N2·N14뿐이다.

## 김작이 정할 것

1. 블록 3 새 읽기 N1·N2·N3·N4를 승인할지.
2. 블록 4-1 새 읽기 N5·N6과 REG(엔진 밖 데이터) 사용을 승인할지. 승인하지 않으면 지휘/무력/지력은 "-"로 나온다.
3. 블록 4-2 새 읽기 N7(유효 비용)을 승인할지. 승인하면 랩 특기 거절 사유(EP:1120)의 비용 기준도 같이 맞출지.
4. 블록 5 퇴각 토스트에 N1·N2를 쓸지, 대사 N13을 읽을지(또는 랩 고정 문구), 컷인(N6 + 컷인 레지스트리)을 이번에 할지 미룰지.
5. 보류 후보 N8(다음 적 미리보기), N9(지원군 대기 회색), N10(필드 능력치), N11(패널 요청 플래그)을 넣을지.
6. 새 읽기를 둘 곳: EP 안 랩 함수(기존 검증기 방식으로 셈) / 별도 읽기 파일(REG의 `worldmap` 경로 때문에 필요할 수 있음, 새 검증기가 그 파일도 봐야 함).
7. 재생 중 상태 글(N4·N5) 갱신 규칙: `status_display`처럼 재생이 끝난 뒤에만 바꿀지, 즉시 바꿀지.
8. 블록 4-1과 4-2를 한 단계로 할지 둘로 나눌지(겹침이 함께 풀려야 함, H1 2-6 5번).
9. 결과 화면을 덮을 때 랩 `result_overlay`를 숨길지(테스트 9파일 영향) / 남겨 두고 위에 그릴지.
10. H1 문서 2-2의 "고유특기 준비 아이콘 새 읽기 1개", "결과 이유 새 읽기"를 이 제안서 결론(둘 다 불필요)으로 고칠지.

## 미확인

- 엔진 SubViewport 안에서 RB·CA `_process`가 실제로 도는지(실행하지 않음).
- `_position_floating_ally_command_panel`의 위치 계산(블록 4-2 3D 투영에 필요)은 읽지 않았다.
- 랩 시나리오("기본 배치", "승리 연습")에서 슬롯 메타 `assigned_hero_id`가 채워지는지. 비면 N6은 `TEST_BATTLE_ROSTER` 값을 준다(C:8777).
- 기본 부대 정의의 스킬 정의에 `cutin_image_path` 키가 있는지.
- 첫 라운드 "BATTLE 1" 토스트가 랩(인트로 건너뜀, host:18)에서도 나오는지.
