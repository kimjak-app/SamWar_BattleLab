# T-1 | Domestic Tech Catalog & Research Rules Extraction

## Baseline

- Branch: `recovery/worldmap-iso-sfx-services-20260912`
- Start HEAD / origin HEAD: `cb568ace7c619d41e9a89db0ad7d5e399eb36a3f`
- Ahead/behind: `0/0`
- Start working tree: clean
- T-0 audit: `docs/worldmap_tech_tree_t0_audit.md`
- Baseline `worldmap_main.gd`: 19,275 lines

## Extracted catalog

`scripts/worldmap/domestic_tech/domestic_tech_catalog.gd` owns the 53 city definitions, 32 national definitions, eight category definitions, scope/category/branch identity, definition builders and lookup/filter helpers. It reuses `DomesticTechHelperLib` for duration metadata. Definition `icon_path` remains catalog metadata; the UI64 fallback filename map and icon resolution remain in presentation code.

Moved implementations:

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

The same functions remain in main as compatibility wrappers only.

## Extracted research rules

`scripts/worldmap/domestic_tech/domestic_tech_research_rules.gd` owns:

- prerequisite evaluation from completed-tech snapshots
- required-national-tech evaluation
- city requirement evaluation through the narrow `is_city_coastal` query
- research duration calculation
- research cost balance adjustment
- research cost plan calculation
- pure eligibility state/reason-code/missing-ID calculation

Moved implementations:

- `_are_domestic_tech_prerequisites_met_mvp`
- `_are_domestic_tech_national_requirements_met_mvp`
- `_are_domestic_tech_city_requirements_met_mvp`
- `_get_domestic_tech_research_duration_turns_mvp`
- `_get_domestic_tech_research_cost_balance_adjustment_mvp`
- `_get_domestic_tech_research_cost_plan_mvp`

`_get_domestic_tech_view_state_mvp` now gathers runtime snapshots, calls the pure eligibility result and adapts reason codes to the existing Korean UI labels. `_can_start_domestic_tech_research_mvp` remains in main because it coordinates active research, actual charge validation and presentation messages.

## Dependencies

Catalog dependencies:

- `RefCounted`
- `DomesticTechHelperLib`
- no runtime state, Node, UI, save or scene dependency

Rules dependencies:

- explicit definition/completed-state arguments
- optional narrow world-fact `Callable(query_id, args)`; current contract only uses `is_city_coastal`
- `DomesticTechHelperLib` for tier-duration fallback
- no host configuration, player/city state access, mutation, UI, save or scene dependency

## Intentionally retained in main

- research start, active state, actual charge validation/application
- world-turn progression and completion mutation
- state normalization and completed/unlocked mirrors
- all effect safe sets and completed-tech effect lookup
- Tech Tree overlay/graph/detail UI and completion video/card/SFX
- save/HUD/world-turn orchestration

Lifecycle functions explicitly retained include `_start_domestic_tech_research_mvp`, `_advance_domestic_tech_research_for_world_turn_mvp`, `_advance_national_tech_research_for_world_turn_mvp`, `_advance_city_tech_research_for_world_turn_mvp`, `_complete_national_tech_research_mvp`, `_complete_city_tech_research_mvp`, `_validate_domestic_tech_actual_charge_mvp` and `_apply_domestic_tech_actual_charge_mvp`.

## Legacy coexistence and schema

- Legacy `_player_state["national_tech"]` progression: unchanged
- Legacy city `city_tech` progression: unchanged
- Domestic Tech progression: unchanged
- No flow was removed, merged or renamed.
- Save/runtime schema: unchanged

## Verification

- New catalog extraction test: 19 checks, 0 failures (including main-wrapper parity and Tech Tree overlay open)
- New research-rules extraction test: 17 checks, 0 failures
- Godot project headless parse: pass
- `WorldMap_16x9_Test.tscn` headless parse: pass
- Existing worldmap regression scripts discovered by repository search: 22 pass, 0 fail
- Existing applicable worldmap static validators: 13 pass
- `git diff --check`: pass
- Forbidden-string scan in both new services: 0 matches

Three historical extraction validators are not applicable as T-1 gates: `validate_worldmap_diplomacy_routing.py` intentionally rejects any later change to `_get_domestic_tech_categories_mvp`; the deployment and T03 presentation validators compare `battle_settlement_applier.gd` to pre-AF-1 commits and reject the already committed `_report` rename. The validators were not relaxed or edited; the corresponding runtime regression scripts pass.

## Main reduction and T-2

- `worldmap_main.gd`: 19,275 -> 19,063 lines
- Net reduction: 212 lines

T-2 can extract research state/lifecycle/charge/completion while preserving both legacy tech flows and the current save schema. The pure catalog/rules boundaries are now available to that service.
