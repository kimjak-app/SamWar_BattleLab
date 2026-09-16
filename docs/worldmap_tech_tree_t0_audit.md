# T-0 | 테크트리 전체 구조 감사 — Tech Tree Refactor Audit

Baseline branch: `recovery/worldmap-iso-sfx-services-20260912`
Baseline before audit: `98389d77f94778fa7dd397911203dd15a4568002` (`fix(worldmap): silence unused wounded report warning`)

## 1. 결론

현재 Domestic Tech는 기능적으로 이미 상당히 완성되어 있지만 구조적으로는 대부분이 `scripts/worldmap/worldmap_main.gd`에 남아 있다. `scripts/worldmap/domestic_tech/`에는 `domestic_tech_helpers.gd`와 README만 있으며, helper는 연구 기간/아이콘/표시용 소형 pure helper 수준이다.

따라서 다음 리팩터는 군사 M-1~M-9에서 사용한 것처럼 **Catalog/Rules → Research lifecycle → Effect provider → Presentation** 순서가 가장 안전하다.

핵심 원칙:
- 연구 데이터 정의와 pure query를 먼저 분리한다.
- active research/completed schema와 실제 비용 차감은 T-1에서 변경하지 않는다.
- `national_tech` / `city_tech` legacy progress path와 Domestic Tech MVP path를 합치지 않는다.
- UI/완료 영상/그래프는 마지막에 분리한다.

## 2. 현재 파일 경계

### `scripts/worldmap/domestic_tech/domestic_tech_helpers.gd`
현재 이미 분리된 helper:
- `get_duration_class_mvp`
- `get_duration_turns_hint_mvp`
- `get_tier_duration_turns_mvp`
- `get_scope_duration_turns_mvp`
- `format_percent_bonus_mvp`
- `get_unique_source_ids_mvp`
- `get_ui64_icon_filename_mvp`
- `get_resolved_icon_path_mvp`

이 파일은 runtime state를 소유하지 않는다.

### `worldmap_main.gd`
다음 책임이 한 파일에 함께 존재한다.
1. Tech catalog / definitions
2. prerequisites / unlock / availability rules
3. completed/unlocked/research state normalization
4. research start/progress/completion
5. research resource charge
6. economy/military/naval/national/diplomacy/spy effect lookup
7. tech-tree overlay/graph/detail inspector
8. completion video/card presentation
9. save/turn/UI orchestration

## 3. 데이터/상수 구조

`worldmap_main.gd` 상단이 직접 소유하는 주요 그룹:

- scope: `DOMESTIC_TECH_SCOPE_CITY`, `DOMESTIC_TECH_SCOPE_NATIONAL`
- UI surface/progress mode
- research container keys
- category IDs
- view state IDs
- icon root / icon filename map
- graph/layout constants
- completion video paths/layout constants
- economy safe-set
- military/defense safe-set
- naval/siege safe-set
- national policy safe-set
- diplomacy/spy safe-set
- city spy/intel safe-set

분리 원칙:
- catalog identity/category/scope constants → T-1 Catalog
- effect safe-set → T-3 Effect Provider
- icon/graph/video/layout constants → T-4 Presentation

## 4. Tech Catalog / Definition 영역

현재 `worldmap_main.gd`에 있는 정의 관련 함수:

- `_get_domestic_tech_categories_mvp`
- `_get_domestic_city_tech_definitions_mvp`
- `_get_domestic_national_tech_definitions_mvp`
- `_make_domestic_city_tech_definition_mvp`
- `_make_domestic_national_tech_definition_mvp`
- `_make_domestic_tech_definition_mvp`
- `_get_domestic_tech_duration_class_mvp`
- `_get_domestic_tech_duration_turns_hint_mvp`
- `_get_domestic_tech_tier_duration_turns_mvp`
- `_get_domestic_tech_scope_duration_turns_mvp`
- `_get_domestic_tech_definitions_mvp`
- `_get_domestic_tech_definition_mvp`
- `_get_domestic_techs_by_scope_mvp`
- `_get_domestic_techs_by_category_mvp`
- `_get_domestic_techs_by_branch_mvp`
- `_is_domestic_city_tech_mvp`
- `_is_domestic_national_tech_mvp`

이 그룹은 T-1의 가장 안전한 1차 이동 대상이다.

권장 신규 경계:
`scripts/worldmap/domestic_tech/domestic_tech_catalog.gd`

Catalog는 state/UI를 모르고 definition snapshot만 제공한다.

## 5. Eligibility / Research Rule 영역

확인된 rule/query 함수:

- `_are_domestic_tech_prerequisites_met_mvp`
- `_are_domestic_tech_national_requirements_met_mvp`
- `_are_domestic_tech_city_requirements_met_mvp`
- `_get_domestic_tech_research_duration_turns_mvp`
- `_get_domestic_tech_research_cost_balance_adjustment_mvp`
- `_get_domestic_tech_research_cost_plan_mvp`
- `_validate_domestic_tech_actual_charge_mvp`
- `_get_domestic_tech_view_state_mvp`
- `_can_start_domestic_tech_research_mvp`

주의:
- `_get_domestic_tech_view_state_mvp`는 domain eligibility와 한국어 UI label/lock reason을 동시에 만든다. 통째로 pure rules service로 옮기면 presentation 결합이 유지된다.
- `_can_start_domestic_tech_research_mvp`도 validation 외에 현재 schema/runtime facts에 의존한다.

T-1에서는 pure catalog + pure eligibility calculation을 분리하고, actual mutation/charge는 T-2에 남기는 것이 안전하다.

## 6. Runtime state ownership

현재 player-state canonical/mirror key:
- `_player_state["city_domestic_tech_completed"]`
- `_player_state["city_domestic_tech_unlocked"]`
- `_player_state["national_domestic_tech_completed"]`
- `_player_state["national_domestic_tech_unlocked"]`
- `_player_state["national_tech_research"]["active"]`

도시 runtime:
- `_city_runtime_states[city_id]["city_tech"]["research"]["active"]`
- city `city_tech.completed` mirror도 유지됨

관련 함수:
- `_normalize_domestic_tech_state_mvp`
- `_normalize_city_domestic_tech_state_map_mvp`
- `_normalize_national_domestic_tech_state_map_mvp`
- `_normalize_national_domestic_tech_research_state_mvp`
- `_normalize_city_domestic_tech_research_state_mvp`
- `_normalize_domestic_tech_research_container_mvp`
- `_normalize_domestic_tech_research_turn_value_mvp`
- `_normalize_domestic_tech_research_duration_value_mvp`
- `_sync_city_domestic_tech_completed_mirror_mvp`
- `_get_national_domestic_tech_active_research_mvp`
- `_get_city_domestic_tech_active_research_mvp`
- `_is_domestic_tech_researching_mvp`
- `_is_city_domestic_tech_completed_mvp`
- `_is_national_domestic_tech_completed_mvp`

이 state schema는 T-1에서 변경하지 않는다.

## 7. Research lifecycle / mutation 영역

현재 lifecycle 핵심:
- `_start_domestic_tech_research_mvp`
- `_advance_domestic_tech_research_for_world_turn_mvp`
- `_advance_national_tech_research_for_world_turn_mvp`
- `_advance_city_tech_research_for_world_turn_mvp`
- `_complete_national_tech_research_mvp`
- `_complete_city_tech_research_mvp`
- `_get_player_city_ids_for_domestic_tech_research_mvp`
- `_validate_domestic_tech_actual_charge_mvp`
- `_apply_domestic_tech_actual_charge_mvp`

권장 T-2:
`domestic_tech_research_service.gd`

책임:
`start → one-time charge → active research → world-turn progress → complete → completed state/mirror`

main은 버튼/status/HUD/save/turn orchestration만 유지한다.

## 8. 중요 발견: legacy tech progress와 Domestic Tech가 동시에 존재

현재 world turn 내정 처리에는 다음 세 흐름이 함께 호출된다.

- `_advance_national_tech_progress_for_world_turn()`
- `_advance_city_tech_progress_for_world_turn()`
- `_advance_domestic_tech_research_for_world_turn_mvp()`

또한 legacy state helper:
- `_ensure_national_tech_state`
- `_ensure_city_tech_state`

가 존재한다.

즉 현재는 `national_tech` / legacy `city_tech` progression과 새 Domestic Tech research lifecycle이 병존한다.

T-1/T-2에서 이를 "중복이므로 하나 삭제"라고 판단하면 위험하다. 먼저 각 caller, save schema, test contract를 보존하고 별도 시스템으로 취급해야 한다. 통합/폐기는 리팩터 완료 후 별도 migration task에서만 판단한다.

## 9. Effect Provider 영역

현재 완료 테크를 읽어 gameplay modifier를 만드는 코드도 main에 있다.

대표 함수:
- `_get_domestic_tech_city_economy_bonus_mvp`
- `_get_player_city_domestic_economy_modifier_mvp`
- `_get_domestic_tech_city_military_defense_bonus_mvp`
- `_get_domestic_tech_city_naval_siege_bonus_mvp`
- `_get_domestic_tech_national_policy_bonus_mvp`
- `_get_domestic_tech_diplomacy_spy_bonus_mvp`
- `_get_domestic_tech_city_spy_intel_bonus_mvp`
- `_get_domestic_tech_economy_turn_summary_mvp`
- `_get_domestic_tech_effect_phase1_summary_mvp`
- `_get_domestic_tech_numeric_effect_phase1_summary_mvp`
- `_get_domestic_tech_military_defense_effect_summary_mvp`
- `_get_domestic_tech_naval_siege_effect_summary_mvp`
- `_get_domestic_tech_diplomacy_spy_effect_summary_mvp`
- `_get_domestic_tech_full_effect_integration_summary_mvp`

권장 T-3:
`domestic_tech_effect_service.gd`

이 service는 completed-tech snapshot + context를 받아 modifier를 제공하고 economy/military/diplomacy/spy가 query하는 구조가 적절하다.

## 10. Presentation 영역

현재 main이 직접 소유:
- tech-tree button
- overlay
- graph node/line layout
- selection state
- detail inspector
- research action button/hint
- icon texture cache
- completion presentation queue
- completion video player
- completion result card

대표 함수:
- `_ensure_domestic_tech_tree_button_mvp`
- `_open_domestic_tech_tree_overlay_mvp`
- `_close_domestic_tech_tree_overlay_mvp`
- `_refresh_domestic_tech_tree_overlay_mvp`
- `_get_domestic_tech_graph_positions_mvp`
- `_get_domestic_tech_graph_canvas_size_mvp`
- `_get_domestic_tech_graph_line_color_mvp`
- `_refresh_domestic_tech_detail_inspector_mvp`
- `_ensure_domestic_tech_completion_presentation_overlay`
- `_show_domestic_tech_completion_card_mvp`
- `_on_domestic_tech_completion_confirm_pressed`
- `_finish_domestic_tech_completion_presentation_item_mvp`
- `_hide_domestic_tech_completion_presentation_overlay`
- `_make_domestic_tech_completion_presentation_item_mvp`
- `_get_domestic_tech_completion_video_path_mvp`

권장 T-4:
Node 기반 `domestic_tech_presentation_controller.gd` + 필요한 pure formatter.

T-4 이전에 UI node를 옮기지 않는다.

## 11. T-1 exact move list

T-1 제목 권장:
**T-1 | 테크 카탈로그·연구 규칙 분리 — Tech Catalog & Research Rules Extraction**

### T-1A Catalog 이동 후보
- `_get_domestic_tech_categories_mvp`
- `_get_domestic_city_tech_definitions_mvp`
- `_get_domestic_national_tech_definitions_mvp`
- `_make_domestic_city_tech_definition_mvp`
- `_make_domestic_national_tech_definition_mvp`
- `_make_domestic_tech_definition_mvp`
- `_get_domestic_tech_duration_class_mvp`
- `_get_domestic_tech_duration_turns_hint_mvp`
- `_get_domestic_tech_tier_duration_turns_mvp`
- `_get_domestic_tech_scope_duration_turns_mvp`
- `_get_domestic_tech_definitions_mvp`
- `_get_domestic_tech_definition_mvp`
- `_get_domestic_techs_by_scope_mvp`
- `_get_domestic_techs_by_category_mvp`
- `_get_domestic_techs_by_branch_mvp`
- `_is_domestic_city_tech_mvp`
- `_is_domestic_national_tech_mvp`

### T-1B Rules 이동/분리 후보
- `_are_domestic_tech_prerequisites_met_mvp`
- `_are_domestic_tech_national_requirements_met_mvp`
- `_are_domestic_tech_city_requirements_met_mvp`
- `_get_domestic_tech_research_duration_turns_mvp`
- `_get_domestic_tech_research_cost_balance_adjustment_mvp`
- `_get_domestic_tech_research_cost_plan_mvp`

`_get_domestic_tech_view_state_mvp`와 `_can_start_domestic_tech_research_mvp`는 T-1에서 먼저 감사하여 pure rule 부분만 분리한다. UI message와 mutation/state ownership까지 한 번에 옮기지 않는다.

### T-1에서 이동하지 않을 것
- `_start_domestic_tech_research_mvp`
- `_advance_domestic_tech_research_for_world_turn_mvp`
- `_advance_national_tech_research_for_world_turn_mvp`
- `_advance_city_tech_research_for_world_turn_mvp`
- `_complete_national_tech_research_mvp`
- `_complete_city_tech_research_mvp`
- `_apply_domestic_tech_actual_charge_mvp`
- completion presentation/graph/overlay 함수군
- effect safe-set 계산 함수군

## 12. 권장 전체 순서

- T-0: audit (this document)
- T-1: Catalog + pure Research Rules
- T-2: Research state/lifecycle/charge/completion
- T-3: Completed-tech Effect Provider
- T-4: Tech Tree + Completion Presentation
- T-5: 최종 tail audit가 필요할 때만 수행

T-4 완료 후 `worldmap_main.gd`는 Tech Tree에서도 coordinator 역할만 남기는 것이 목표다.
