# Domestic Tech Gameplay Effect Integration Map

## v0.70-98 Domestic Tech Complete Lock

Domestic Tech first-pass gameplay integration is complete and locked at v0.70-98. This pass adds no new gameplay system; it records the completion boundary for the v0.70-92 through v0.70-98 route.

### Completed Scope

- Research cost actual charge.
- Research progress/completion.
- Economy / City effect integration.
- Defense / Battle effect integration.
- Diplomacy / Spy effect integration.
- Naval / Siege unlock integration.
- Enemy baseline separation.
- Full F6 QA PASS-ready with no blocker in v0.70-97.

### Actual Connection Results

- Economy / City:
  - PLAYER national/city completed tech modifiers are connected.
  - City tech remains same-city only.
  - Enemy city uses baseline only.
- Defense / Battle:
  - PLAYER defense/battle completed tech modifiers are connected.
  - BattleContext schema remains unchanged.
  - Battle data preparation hook is used.
  - Enemy uses baseline only.
- Diplomacy / Spy:
  - PLAYER diplomacy/spy completed tech modifiers are connected.
  - Relation, success, detection, and intel visibility hooks are connected.
  - Enemy uses baseline/resistance only.
- Naval / Siege:
  - PLAYER naval/siege unlock helpers are connected.
  - Attack/deployment eligibility hooks are connected.
  - No automatic ship/siege generation exists.
  - Enemy uses baseline only.

### Completion Lock Rules

Domestic Tech first-pass implementation is complete at v0.70-98.

Future Domestic Tech changes are allowed only for:
- Clear bug fixes found after v0.70-98.
- Numeric balance adjustments.
- UI display reinforcement.
- A separately scoped second-pass large system.

Forbidden after this lock:
- Reopening the completed route for endless expansion.
- Immediately attaching labor/policy implementation.
- Immediately attaching enemy research.
- Immediately attaching ship/siege production storage.
- Immediately attaching AI research.
- Urgently expanding save schema under the Domestic Tech name.

### Next Direction

Move out of Domestic Tech first-pass work. Any large expansion must be planned as a separate system/version rather than appended to this route.

## v0.70-97 Full Gameplay F6 QA

This pass verifies the v0.70-93 through v0.70-96 Domestic Tech gameplay effect integrations as a combined F6 QA gate. No new gameplay system was added.

### QA Summary

- Research Flow: PASS-ready by code grep and headless load. Start-time actual charge, active research payload keys, progress, and completion flow remain intact.
- Economy / City: PASS-ready. PLAYER completed national/city economy helpers remain connected to summary and income hooks; city effects remain same-city only.
- Defense / Battle: PASS-ready. PLAYER defense/battle helpers remain connected to city summary and roster stat preparation without BattleContext or troop-count mutation.
- Diplomacy / Spy: PASS-ready. PLAYER diplomacy/spy helpers remain connected to relation/success/detection/intel-safe hooks; enemy baseline remains resistance-only.
- Naval / Siege: PASS-ready. PLAYER unlock helpers remain connected to attack/deployment eligibility and summary; no ship/siege count or storage was added.
- Enemy Baseline / No Enemy Research: PASS-ready. Enemy helpers remain read-only baseline/resistance helpers and do not store active/completed research or cost state.
- Preservation: PASS by `git diff --check`, schema/count/storage grep, and scene/asset/import diff checks.
- Godot Output: PASS by headless project, worldmap scene, and battle scene load.

### Blocker Status

- Blocker: none found.
- `v0.70-98 Domestic Tech Complete Lock` is allowed as the next route step.

### Preservation

- Save/load schema changed: false.
- Active payload schema changed: false.
- Actual charge logic changed: false.
- Food group order changed: false, still `rice -> barley -> seafood`.
- BattleContext schema changed: false.
- Pending invasion schema changed: false.
- Battle formula changed after v0.70-94: false.
- Diplomacy formula changed after v0.70-95: false.
- Spy formula changed after v0.70-95: false.
- Naval/siege production system added: false.
- Ship count mutation added: false.
- Siege count mutation added: false.
- Ship/siege persistent storage added: false.
- Enemy research implemented: false.
- Enemy completed tech storage added: false.
- Assets/imports/scenes changed: false.

### Next Version

`v0.70-98 Domestic Tech Complete Lock` must lock the completed Domestic Tech gameplay effect route after confirming this QA gate remains blocker-free.

## v0.70-96 Naval / Siege Unlock Integration

This pass connects Naval / Siege Domestic Tech effects to actual PLAYER unlock helpers, city summary/preview, and existing player attack/deployment eligibility. It also adds ENEMY naval/siege baseline helpers that are not a research system.

### Implemented Hooks

- Completed PLAYER city naval lookup now has unlock contract helpers:
  - `_get_player_naval_unlock_modifier_mvp(city_id)`
  - `_is_player_ship_unlocked_by_domestic_tech_mvp(ship_id, city_id)`
- Completed PLAYER city/national siege lookup now has unlock contract helpers:
  - `_get_player_siege_unlock_modifier_mvp(city_id)`
  - `_is_player_siege_unlocked_by_domestic_tech_mvp(siege_id, city_id)`
- Actual action/eligibility hooks now run through:
  - `_get_player_naval_siege_attack_unlock_block_reason_mvp(source_city_id, target_city_id)`
  - `_get_player_attack_block_reason(target_city_id)`
  - `_validate_player_attack_deployment(deployment)`
  - `_build_player_attack_deployment_payload(source_city_id, target_city_id, mode)`
  - `_build_defense_deployment_payload(event, mode)`
- Existing UI/preview text now reads the same unlock contract through:
  - `_format_domestic_tech_city_naval_siege_bonus_lines_mvp(city_id)`
  - city detail rating summary
  - Domestic Tech inspector selected-city naval/siege summary
- ENEMY naval/siege baseline is provided by:
  - `_get_enemy_naval_baseline_mvp(city)`
  - `_get_enemy_siege_baseline_mvp(city)`

### PLAYER Effect Contract

- PLAYER city naval/siege unlocks read `_player_state["city_domestic_tech_completed"][city_id]` through completed city lookup.
- City effects are same-city only.
- National siege support reads PLAYER national completed tech only for existing national ids such as `nation_logistics_system`, `nation_expedition_system`, `nation_military_reform`, and `nation_weapon_factory`.
- Naval unlock currently gates sea/coastal attack eligibility when the source city lacks completed warship unlock.
- Siege unlock currently gates fortress/high-defense attack eligibility when the source city lacks completed siege unit unlock.
- Deployment payloads carry read-only preview dictionaries for naval/siege unlock state; no pending invasion schema or BattleContext schema was extended.
- No ship, siege weapon, or troop count is created by completed research.

### ENEMY Baseline Contract

- ENEMY does not have active research.
- ENEMY does not have completed tech storage.
- ENEMY does not pay research cost.
- ENEMY receives no PLAYER completed-tech effect.
- `_get_enemy_naval_baseline_mvp(city)` returns only side-effect-free coastal/resource/commerce baseline metadata.
- `_get_enemy_siege_baseline_mvp(city)` returns only side-effect-free defense/garrison/fortress baseline metadata.
- Unknown or insufficient-intel cities remain masked.

### Preservation

- Save/load schema changed: false.
- Active payload schema changed: false.
- Actual charge logic changed: false.
- Food group order changed: false, still `rice -> barley -> seafood`.
- BattleContext schema changed: false.
- Pending invasion schema changed: false.
- Battle formula changed after v0.70-94: false.
- Diplomacy formula changed after v0.70-95: false.
- Spy formula changed after v0.70-95: false.
- Ship count mutation added: false.
- Siege count mutation added: false.
- Ship/siege persistent storage added: false.
- Enemy research implemented: false.
- Enemy completed tech storage added: false.
- Assets/imports/scenes changed: false.

### Next Version

`v0.70-97 Full Gameplay F6 QA` must verify the full seven-step Domestic Tech gameplay effect route, including economy/city, defense/battle, diplomacy/spy, naval/siege unlocks, enemy baselines, actual charge preservation, and no forbidden schema/count mutations.

## v0.70-95 Diplomacy / Spy Effect Integration

This pass connects Diplomacy / Spy Domestic Tech effects to actual PLAYER diplomacy relation/success modifiers, spy success/detection/intel visibility modifiers, and the existing action preview paths. It also adds ENEMY diplomacy/spy baseline helpers that are not a research system.

### Implemented Hooks

- Completed PLAYER national diplomacy lookup now has modifier contract helpers:
  - `_has_completed_national_domestic_tech_mvp(tech_id)`
  - `_get_player_diplomacy_tech_modifier_mvp()`
  - `_get_modified_diplomacy_relation_delta_mvp(base_delta, action_id, target_faction_id)`
  - `_get_modified_diplomacy_success_chance_mvp(base_chance, action_id, target_faction_id)`
- Actual diplomacy hooks now run through:
  - `_validate_diplomacy_action(action_id, target_city_id)`
  - `_calculate_alliance_acceptance_chance(target_faction_id, resource_package, duration_turns)`
  - `_calculate_military_support_acceptance_chance(target_faction_id)`
  - `_calculate_tribute_relation_gain(target_faction)`
- Completed PLAYER spy lookup now has modifier contract helpers:
  - `_get_player_spy_tech_modifier_mvp(city_id)`
  - `_get_modified_spy_success_chance_mvp(target_city_id, base_chance, action_id)`
  - `_get_modified_spy_detection_chance_mvp(target_city_id, base_detection)`
  - `_get_modified_spy_visibility_level_mvp(target_city_id, political_aptitude)`
- Actual spy hooks now run through:
  - `_can_gather_spy_info(target_city_id)`
  - `_can_disrupt_city_public_support(target_city_id)`
  - `_can_disrupt_city_loyalty(target_city_id)`
  - `_can_instigate_revolt(target_city_id)`
  - `_get_spy_wedge_success_chance(target_city_id, counterpart_faction_id)`
  - `_calculate_spy_wedge_detection_chance(target_city_id)`
- Existing UI/preview text now reads the same modifier contract through:
  - `_format_diplomacy_policy_display_for_ui(city_marker)`
  - `_format_spy_visibility_summary_for_ui(city_marker)`
  - `_format_spy_action_policy_display_for_ui(city_marker)`
  - `_format_player_diplomacy_tech_modifier_summary_mvp(target_faction_id)`
  - `_format_player_spy_tech_modifier_summary_mvp(target_city_id)`
- ENEMY diplomacy/spy baseline is provided by:
  - `_get_enemy_diplomacy_baseline_mvp(target_force_id)`
  - `_get_enemy_spy_resistance_baseline_mvp(city)`
  - `_get_enemy_city_intel_resistance_baseline_mvp(city)`

### PLAYER Effect Contract

- PLAYER diplomacy effects read `_player_state["national_domestic_tech_completed"]` through completed national lookup.
- PLAYER spy effects also read completed national lookup.
- Current city-scope spy/admin safe set remains empty, so same-city-only city spy effect is preserved as zero-effect; no new city tech storage or city schema key was introduced.
- Relation schema is not extended.
- Spy action/result payload schema is not extended.
- Existing previews and actual calculation inputs read the same modifier helpers to avoid double-application drift.

### ENEMY Baseline Contract

- ENEMY does not have active research.
- ENEMY does not have completed tech storage.
- ENEMY does not pay research cost.
- ENEMY receives no PLAYER completed-tech effect.
- `_get_enemy_diplomacy_baseline_mvp(target_force_id)` returns side-effect-free faction baseline resistance only.
- `_get_enemy_spy_resistance_baseline_mvp(city)` and `_get_enemy_city_intel_resistance_baseline_mvp(city)` return only baseline/resistance metadata.
- Unknown or insufficient-intel city baseline remains masked.

### Preservation

- Save/load schema changed: false.
- Active payload schema changed: false.
- Actual charge logic changed: false.
- Food group order changed: false, still `rice -> barley -> seafood`.
- BattleContext schema changed: false.
- Pending invasion schema changed: false.
- Battle formula changed after v0.70-94: false.
- Naval/siege production implemented: false.
- Enemy research implemented: false.
- Enemy completed tech storage added: false.
- Troop/ship/siege count mutation added: false.
- Assets/imports/scenes changed: false.

### Next Version

`v0.70-96 Naval / Siege Unlock Integration` must connect completed PLAYER naval/siege research to production/action/formation eligibility hooks without auto-generating ships or siege units, without adding enemy research, and without changing save schema.

## v0.70-94 Defense / Battle Effect Integration

This pass connects Defense / Battle Domestic Tech effects to actual PLAYER defense modifier helpers, selected city defense summary, and the existing battle roster stat preparation path. It also adds ENEMY defense/battle baseline helpers that are not a research system.

### Implemented Hooks

- Completed PLAYER city defense tech lookup now has modifier contract helpers:
  - `_has_completed_city_domestic_tech_mvp(city_id, tech_id)`
  - `_get_player_city_defense_modifier_mvp(city_id)`
  - `_get_player_city_battle_modifier_mvp(city_id)`
- Completed PLAYER national military lookup now has battle modifier helpers:
  - `_has_completed_national_domestic_tech_mvp(tech_id)`
  - `_get_player_national_battle_modifier_mvp()`
  - `_get_player_battle_tech_modifier_mvp(scope, city_id)`
- City defense display and summary now read the same modifier contract through:
  - `_get_domestic_tech_city_defense_display_value_mvp(city_id, city_data)`
  - `_format_city_defense_battle_modifier_summary_mvp(city_id, city_data)`
  - `_format_domestic_tech_city_military_defense_bonus_lines_mvp(city_id, city_data)`
- Battle setup now applies PLAYER completed battle tech at the existing roster stat preparation point:
  - `_get_hero_battle_data_for_battle_context(hero_id, fallback_city_id)`
  - `_apply_domestic_battle_tech_modifier_to_hero_data_mvp(battle_data, city_id)`
- ENEMY city defense/battle baseline is provided by:
  - `_get_enemy_city_defense_baseline_mvp(city)`
  - `_get_enemy_battle_baseline_modifier_mvp(city, role)`

### PLAYER Effect Contract

- PLAYER national battle effects read `_player_state["national_domestic_tech_completed"]` through completed national lookup.
- PLAYER city defense/battle effects read `_player_state["city_domestic_tech_completed"][city_id]` through completed city lookup.
- City effects are same-city only.
- BattleContext schema is not extended. The hook adjusts existing hero roster `attack` / `defense` values before the context is returned.
- Troop, ship, and siege counts are not mutated.
- Battle result formula is not rewritten; only the existing input stats receive small completed-tech modifiers.

### ENEMY Baseline Contract

- ENEMY does not have active research.
- ENEMY does not have completed tech storage.
- ENEMY does not pay research cost.
- ENEMY receives no PLAYER completed-tech effect.
- `_get_enemy_city_defense_baseline_mvp(city)` returns only a side-effect-free baseline from city grade and revealed intel.
- `_get_enemy_battle_baseline_modifier_mvp(city, role)` returns baseline modifier metadata only; it is not enemy research.
- Unknown or insufficient-intel cities remain masked.

### Preservation

- Save/load schema changed: false.
- Active payload schema changed: false.
- Actual charge logic changed: false.
- Food group order changed: false, still `rice -> barley -> seafood`.
- BattleContext schema changed: false.
- Pending invasion schema changed: false.
- Diplomacy/spy formulas changed: false.
- Naval/siege production implemented: false.
- Enemy research implemented: false.
- Enemy completed tech storage added: false.
- Troop/ship/siege count mutation added: false.
- Assets/imports/scenes changed: false.

### Next Version

`v0.70-95 Diplomacy / Spy Effect Integration` must connect completed PLAYER diplomacy/spy research to existing diplomacy relation/success and spy success/intel-safe modifier hooks without adding enemy research, changing save schema, or rewriting formulas.

## v0.70-93 Economy / City Effect Integration

This pass connects Economy / City Domestic Tech effects to actual PLAYER economy modifier helpers, existing turn income calculation, city detail summary, and national warehouse summary. It also adds an ENEMY city baseline helper that is not a research system.

### Implemented Hooks

- Completed PLAYER city economy tech lookup now has wrapper contract helpers:
  - `_has_completed_city_domestic_tech_mvp(city_id, tech_id)`
  - `_get_player_city_domestic_economy_modifier_mvp(city_id)`
- Completed PLAYER national economy/admin lookup now has wrapper contract helpers:
  - `_has_completed_national_domestic_tech_mvp(tech_id)`
  - `_get_national_domestic_economy_modifier_mvp()`
- Same-city city effects remain connected to actual turn income through:
  - `_calculate_player_domestic_income_delta`
  - `_apply_domestic_tech_city_economy_bonus_to_income_mvp`
- City detail resource tab summary now reads the same modifier contract through:
  - `_get_city_economy_tech_modifier_summary_mvp(city_id)`
  - `_format_city_economy_tech_modifier_summary_mvp(city_id)`
- National warehouse summary now reads national economy modifier through:
  - `_format_national_domestic_economy_modifier_summary_mvp()`
  - `_format_warehouse_summary(policy_id)`
- ENEMY city baseline is provided by:
  - `_get_enemy_city_economy_baseline_mvp(city)`

### PLAYER Effect Contract

- PLAYER national effects read `_player_state["national_domestic_tech_completed"]` through completed national lookup.
- PLAYER city effects read `_player_state["city_domestic_tech_completed"][city_id]` through completed city lookup.
- City effects are same-city only.
- National tax/economy effects apply only to PLAYER economy summary and PLAYER-owned city income calculation.
- The actual income hook remains the existing turn income path; no separate duplicate resource generation pass was added.

### ENEMY Baseline Contract

- ENEMY does not have active research.
- ENEMY does not have completed tech storage.
- ENEMY does not pay research cost.
- ENEMY receives no PLAYER completed-tech effect.
- `_get_enemy_city_economy_baseline_mvp(city)` returns only a side-effect-free baseline from city grade and revealed intel.
- Unknown or insufficient-intel cities remain masked.

### Preservation

- Save/load schema changed: false.
- Active payload schema changed: false.
- Actual charge logic changed: false.
- Food group order changed: false, still `rice -> barley -> seafood`.
- BattleContext schema changed: false.
- Pending invasion schema changed: false.
- Battle/diplomacy/spy formulas changed: false.
- Naval/siege production implemented: false.
- Enemy research implemented: false.
- Enemy completed tech storage added: false.
- Assets/imports/scenes changed: false.

### Next Version

`v0.70-94 Defense / Battle Effect Integration` must connect completed PLAYER defense/battle research to city defense and battle-safe modifier hooks without changing pending invasion schema, BattleContext schema, troop counts, or battle result formulas.

## v0.70-92 Domestic Tech Gameplay Effect Integration Map

현재 Domestic Tech는 연구 시작/진행/완료/비용 차감은 가능하다.
하지만 1차 완료 기준은 연구 완료 효과가 실제 게임 상태/계산/해금에 연결되는 것이다.
v0.70-92는 그 연결 지도를 확정한다.

This pass is an integration map, not a bulk implementation pass. It records code-level candidate hooks, lookup contracts, safe connection shape, and forbidden mutation areas for v0.70-93 through v0.70-98.

## Current Code State

- Safe sets exist in `scripts/worldmap_test.gd`: Economy, Military/Defense, National Policy, Naval/Siege Display, Diplomacy/Spy Display, and Full Effect Integration Summary.
- Completed PLAYER national Domestic Tech storage: `_player_state["national_domestic_tech_completed"]`.
- Completed PLAYER city Domestic Tech storage: `_player_state["city_domestic_tech_completed"][city_id]`.
- Active national research payload: `_player_state["national_tech_research"]["active"]`.
- Active city research payload: `city_data["city_tech"]["research"]["active"]`.
- Active payload keys are locked: `tech_id`, `started_turn`, `remaining_turns`, `duration_turns`.
- Tech definition structure includes `id`, `tree_scope`, `category`, `branch`, `tier`, `rarity`, `prerequisites`, `required_national_techs`, `special_requirements`, `cost`, `effect_type`, `effect_value`, `effect_description`, `unlocks_city_techs`, and `enhances_city_techs`.
- Effect summary helpers include `_get_domestic_tech_city_economy_bonus_mvp`, `_get_domestic_tech_city_military_defense_bonus_mvp`, `_get_domestic_tech_city_naval_siege_bonus_mvp`, `_get_domestic_tech_national_policy_bonus_mvp`, `_get_domestic_tech_diplomacy_spy_bonus_mvp`, `_get_domestic_tech_full_effect_integration_summary_mvp`, and `_get_domestic_tech_gameplay_effect_integration_map_summary_mvp`.
- Cost/duration helpers include `_build_domestic_tech_actual_charge_plan_mvp`, `_validate_domestic_tech_actual_charge_mvp`, `_apply_domestic_tech_actual_charge_mvp`, `_get_domestic_tech_research_duration_turns_mvp`, `_get_domestic_tech_scope_duration_turns_mvp`, and `_get_domestic_tech_tier_duration_turns_mvp`.

## Integration Priority Table

Category | Example Techs | Current Status | Target Gameplay Hook | Candidate Functions | Next Version | Risk
--- | --- | --- | --- | --- | --- | ---
Economy/City | 농업, 상업, 수산 | completed/display and limited income bonus | city economy/resource summary and turn income | `_calculate_player_domestic_income_delta`, `_calculate_city_domestic_income`, `_apply_domestic_tech_city_economy_bonus_to_income_mvp`, `_apply_resource_delta`, `_format_city_storage_summary`, `_format_warehouse_summary` | v0.70-93 | low/medium
Defense | 성벽강화, 해자, 망루 | completed/display | city defense modifier and city detail defense summary | `_get_domestic_tech_city_defense_display_value_mvp`, `_format_domestic_tech_city_military_defense_bonus_lines_mvp`, `_validate_pending_invasion_event_for_battle_context` | v0.70-94 | medium
Battle | 보병훈련, 궁병훈련, 기병훈련 | completed/display | BattleContext-adjacent modifier summary or roster stat modifier | `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context`, `_get_hero_battle_data_for_battle_context`, `_apply_troop_allocation_to_roster` | v0.70-94 | medium/high
Diplomacy | 외교체계, 동맹체계 | completed/display | diplomacy success/relation modifier | `_validate_diplomacy_action`, `_apply_diplomacy_action`, `_calculate_alliance_acceptance_chance`, `_calculate_military_support_acceptance_chance` | v0.70-95 | medium
Spy | 첩보체계, 첩보조직 | completed/display | spy success/intel modifier | `_validate_spy_action`, `_get_spy_info_success_chance`, `_calculate_spy_detection_chance`, `_get_spy_info_visibility_level`, `_roll_spy_info_result`, `_get_spy_wedge_success_chance` | v0.70-95 | medium
Naval | 조선소, 판옥선, 거북선 | completed/display | production/action unlock | `_get_domestic_tech_city_naval_siege_bonus_mvp`, `_get_domestic_tech_unlock_relation_status_mvp`, `_build_player_attack_deployment_payload`, `_validate_player_attack_deployment` | v0.70-96 | medium
Siege | 공성병기, 화포 | completed/display | siege action/formation unlock | `_get_domestic_tech_city_naval_siege_bonus_mvp`, `_format_domestic_tech_city_naval_siege_bonus_lines_mvp`, `_build_player_attack_deployment_payload`, `_build_battle_context_from_pending_invasion` | v0.70-96 | medium

## Economy / City Effect Integration Map

Target tech groups:
- Agriculture: `agri_tool_upgrade`, `agri_irrigation`, `agri_reservoir`, `agri_double_cropping`, `agri_granary_zone`.
- Commerce: `commerce_street_market`, `commerce_permanent_market`, `commerce_grand_market`, `commerce_mint`, `commerce_port`.
- Fishery: `fish_village`, `fish_coastal_fishing`, `fish_fleet`, `fish_dried_supply_base`.
- National economy/admin: `nation_tax_reform`, `nation_currency_unification`, `nation_national_economy`, `nation_monopoly_system`, `nation_national_monopoly`, `nation_local_administration`.

Candidate hooks:
- City resource generation: `_calculate_city_domestic_income`, `_calculate_player_domestic_income_delta`.
- Existing Domestic Tech income pass: `_apply_domestic_tech_city_economy_bonus_to_income_mvp`.
- National tax/economy modifier: `_get_domestic_tech_national_policy_bonus_mvp`, `_apply_domestic_tech_city_economy_bonus_to_income_mvp`.
- National resource update: `_apply_resource_delta`.
- City storage display and state: `_get_city_storage`, `_set_city_storage`, `_format_city_storage_summary`.
- National economy summary: `_format_player_resource_summary`, `_format_warehouse_summary`, `_format_domestic_apply_summary`.
- Turn advance resource logic: `_apply_domestic_turn_mvp`.

Connection target data:
- PLAYER national `resource_stock`: `rice`, `barley`, `seafood`, `gold`.
- PLAYER city `storage`: `rice`, `barley`, `seafood`, `gold`, and other `RESOURCE_DISPLAY_ORDER` keys.
- City seed/source values: `resource_seed`, `domestic_seed`, `yield_seed`, `population_rating`, `commerce_rating`.

Scope:
- PLAYER-only: yes.
- City-only: city agriculture/fishery/commerce effects must use the completed same-city lookup.
- National-only: national economy/admin effects should use completed national lookup and then affect PLAYER national summary or all PLAYER-owned city income only.

v0.70-93 priority:
1. Keep existing `resource_stock`/`storage` schema.
2. First connect safe city income and city/national summaries.
3. Extend actual resource generation only through existing turn income functions.
4. Do not touch actual charge logic or food deduction order.

Risk:
- Medium if connecting directly to resource generation because income totals affect real stock.
- Low if first pass is summary-only or extends already existing `_apply_domestic_tech_city_economy_bonus_to_income_mvp`.

## Defense / Battle Effect Integration Map

Defense target techs:
- `mil_wall_upgrade`, `mil_moat`, `mil_double_moat`, `mil_watchtower`, `mil_beacon`, `mil_beacon_network`, `mil_iron_gate`, `mil_iron_fortress`, `mil_barracks`, `nation_military_training_order`, `nation_military_reform`.

Battle target techs:
- `mil_infantry_training`, `mil_elite_infantry`, `mil_heavy_infantry`, `mil_archer_training`, `mil_elite_archer`, `mil_singijeon`, `mil_cavalry_training`, `mil_light_cavalry`, `mil_cavalry_charge_tactics`, `nation_standing_army`, `nation_logistics_system`, `nation_expedition_system`.

Candidate hooks:
- Defense summary: `_get_domestic_tech_city_defense_display_value_mvp`, `_format_domestic_tech_city_military_defense_bonus_lines_mvp`.
- Invasion validation/preparation: `_validate_pending_invasion_event_for_battle_context`, `_prepare_pending_invasion_battle_context`, `_build_defense_deployment_payload`.
- Battle setup: `_build_battle_context_from_pending_invasion`, `_build_player_attack_battle_context`.
- Roster/stat summary: `_get_hero_battle_data_for_battle_context`, `_build_invasion_side_roster_for_battle_context`, `_apply_troop_allocation_to_roster`.

Safe modifier structure:
- Do not change BattleContext schema in v0.70-94 unless a separate contract update is approved.
- Preferred first pass: calculate modifiers locally before battle handoff and apply only to hero battle data fields already consumed by battle scene, or expose read-only summary fields for UI.
- Safer structure if later approved: `domestic_tech_modifiers = {"attack_percent": 0.0, "defense_percent": 0.0, "unit_type_bonus": {}, "city_defense_percent": 0.0}`.

Do not touch:
- Troop count mutation.
- Pending invasion schema.
- BattleContext schema.
- Battle result formula.
- Existing pre-decrement and allocation accounting.

v0.70-94 priority:
1. Defense city detail summary and city defense display.
2. Minimal defense modifier for same-city PLAYER defender only.
3. Battle modifier summary or bounded stat modifier for PLAYER completed tech only.

Risk:
- Medium for defense summary.
- Medium/high for battle because it can change combat outcomes and battle data contracts.

## Diplomacy / Spy Effect Integration Map

Diplomacy target techs:
- `nation_envoy`, `nation_diplomacy_system`, `nation_alliance_system`, `nation_world_diplomacy`, `nation_tribute_system`, `nation_tribute_network`, `nation_bureaucracy`, `nation_centralization`, `nation_anti_corruption`.

Spy target techs:
- `nation_intelligence_system`, `nation_intelligence_org`, `nation_inspection_system`, `nation_anti_corruption`, wedge/relation disruption candidates, enemy city intel visibility candidates.

Candidate hooks:
- Diplomacy validation: `_validate_diplomacy_action`.
- Diplomacy relation mutation: `_apply_diplomacy_action`, `_adjust_faction_relation_score`.
- Alliance chance: `_calculate_alliance_acceptance_chance`, `_propose_alliance`.
- Military support chance: `_calculate_military_support_acceptance_chance`, `_request_military_support`.
- Tribute: `_can_send_tribute`, `_calculate_tribute_relation_gain`, `_send_tribute`.
- Spy validation: `_validate_spy_action`, `_can_gather_spy_info`, `_can_disrupt_city_public_support`, `_can_disrupt_city_loyalty`, `_can_instigate_revolt`, `_can_wedge_faction_relation`.
- Spy success/detection: `_get_spy_info_success_chance`, `_calculate_spy_detection_chance`, `_roll_spy_info_result`, `_roll_spy_public_support_disrupt_result`, `_roll_spy_loyalty_disrupt_result`, `_roll_spy_revolt_instigation_result`, `_get_spy_wedge_success_chance`, `_roll_spy_wedge_city_result`.
- Intel visibility: `_get_spy_info_visibility_level`, `_build_spy_info_payload`, `_record_city_intel_from_spy_result`, `_format_spy_visibility_summary_for_ui`, `_format_spy_known_info_summary_for_ui`.

Scope:
- PLAYER-only completed national tech.
- Enemy research/effect remains unimplemented.
- Enemy/unknown no-display is preserved: UI functions may show only allowed intel fields already revealed by `city_intel`.

v0.70-95 priority:
1. Add small completed-tech modifier to diplomacy success or relation delta.
2. Add small completed-tech modifier to spy success/detection.
3. Keep action validation gates intact.
4. Do not reveal extra enemy data except through existing spy result payload flow.

Risk:
- Medium because relation, cooldown, cost, and intel systems are already live.

## Naval / Siege Unlock Integration Map

Naval target techs:
- `commerce_port`, `commerce_shipyard`, `naval_training`, `naval_warship_building`, `naval_panokseon`, `naval_turtle_ship`, `naval_crane_wing_formation`, `naval_fire_ship`, `naval_cannon_mount`.

Siege target techs:
- `mil_siege_unit`, `mil_siege_engine`, `nation_military_reform`, `nation_logistics_system`, `nation_expedition_system`, `nation_weapon_standardization`, `nation_weapon_factory`.

Candidate hooks:
- Unlock summary: `_get_domestic_tech_unlock_relation_status_mvp`.
- Display-safe naval/siege data: `_get_domestic_tech_city_naval_siege_bonus_mvp`, `_format_domestic_tech_city_naval_siege_bonus_lines_mvp`.
- City action availability: `_refresh_city_info_attack_action_state`, `_get_player_attack_block_reason`, `_can_player_attack_city`.
- Formation/deployment eligibility: `_build_player_attack_deployment_payload`, `_validate_player_attack_deployment`, `_build_defense_deployment_payload`, `_validate_defense_deployment`.
- Battle setup siege/naval branch later: `_build_player_attack_battle_context`, `_build_battle_context_from_pending_invasion`.

Unlock policy:
- Research completion must not auto-create ships or siege weapons.
- First connection is production/formation/action eligibility only.
- Use computed unlock flags from completed tech lookup; do not persist new ship/siege counts in v0.70-96.
- Save schema remains unchanged.

v0.70-96 priority:
1. City-level production/action eligibility flags based on same-city completed tech.
2. Naval/coastal/siege action availability summaries.
3. Deployment/formation gating if an existing action needs it.

Risk:
- Medium because there is no full ship/siege inventory system yet.

## Completed Tech Lookup Contract

Current confirmed helpers:
- `_is_national_domestic_tech_completed_mvp(tech_id: String) -> bool`.
- `_is_city_domestic_tech_completed_mvp(city_id: String, tech_id: String) -> bool`.
- `_normalize_national_domestic_tech_state_map_mvp(raw_state: Variant) -> Dictionary`.
- `_normalize_city_domestic_tech_state_map_mvp(raw_state: Variant) -> Dictionary`.

Storage contract:
- National completed tech lookup reads `_player_state["national_domestic_tech_completed"]`.
- City completed tech lookup reads `_player_state["city_domestic_tech_completed"][city_id]`.
- City tech mirrors into `city_data["city_tech"]["completed"]`, but the Domestic Tech completed map is the safer primary source.
- Same-city only: city effects apply only to the city id used for the lookup.
- Selected PLAYER city completed lookup must use selected city id and `_is_city_owned_by_player_mvp`.
- Enemy/unknown city: no effect, no research, no detailed display.

Recommended helper candidates for v0.70-93:
```gdscript
_has_completed_national_domestic_tech_mvp(tech_id: String) -> bool
_has_completed_city_domestic_tech_mvp(city_id: String, tech_id: String) -> bool
_get_completed_domestic_tech_effect_modifiers_mvp(scope: String, city_id: String = "") -> Dictionary
```

Implementation rule:
- Helpers must be side-effect-free unless they are existing normalize/complete paths.
- Do not change save schema.
- Do not change active payload schema.

## Seven-Step Completion Route Lock

Domestic Tech now finishes only through this route:

```text
v0.70-92 Domestic Tech Gameplay Effect Integration Map
v0.70-93 Economy / City Effect Integration
v0.70-94 Defense / Battle Effect Integration
v0.70-95 Diplomacy / Spy Effect Integration
v0.70-96 Naval / Siege Unlock Integration
v0.70-97 Full Gameplay F6 QA
v0.70-98 Domestic Tech Complete Lock
```

Locks:
- Do not work outside this Domestic Tech route.
- Labor/policy actual implementation is not part of this route.
- Do not design new resources.
- Do not do standalone UI polish.
- Do not do standalone QA record repetition.
- Every follow-up must be judged by actual gameplay effect connection.

## Preservation

- actual charge gameplay logic changed: false.
- gold deduction changed: false.
- food group deduction changed: false.
- food group order changed: false, still `rice -> barley -> seafood`.
- affordability validation logic changed: false.
- active research creation logic changed: false.
- active research payload schema changed: false.
- save/load schema changed: false.
- paid cost state changed: false.
- cancel/refund changed: false.
- per-turn charge changed: false.
- completion charge changed: false.
- cost/duration/effect balance values changed: false.
- UI behavior changed: false.
- BattleContext schema changed: false.
- pending invasion schema changed: false.
- battle formula changed: false.
- diplomacy formula changed: false.
- spy formula changed: false.
- market/trade formula changed: false.
- city_intel formula changed: false.
- enemy research/effect added: false.
- assets/import changed: false.
- scene files changed: false.
