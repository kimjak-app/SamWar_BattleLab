# T-3 | Domestic Tech Effect Provider Extraction

## Baseline

- Branch: `recovery/worldmap-iso-sfx-services-20260912`
- T-2 lifecycle baseline: `852d5b058c6e681973a53ccc927017ff45235051`
- V-1 validator baseline: `8ff25d0d73d3ff733a7ab9218df856b44b1cf031`
- Start state: local/origin `0/0`, clean working tree
- Start `worldmap_main.gd`: 18,574 lines

## Provider boundary

`scripts/worldmap/domestic_tech/domestic_tech_effect_provider.gd` is a `RefCounted` pure effect provider. It receives only `DomesticTechCatalog` through `configure(catalog)`. Completed national/city snapshots, city ownership and owned-city IDs are explicit method arguments. It has no world-map host, player/city runtime state, scene node, UI, save, audio or research-mutation dependency.

## Moved safe sets

- city economy safe categories and effect map
- city military/defense safe branches and effect map
- national battle effect map
- national policy effect map
- naval/siege safe branches and effect map
- diplomacy/spy effect map
- intentionally empty city spy/intel effect map

The Catalog remains the canonical source for tech identity, scope, category, branch and definition/effect metadata. The Provider owns only the approved gameplay mapping and aggregation rules.

## Moved effect calculations

- city economy bonus and player-city economy modifier
- national economy modifier
- city military/defense bonus and defense modifier
- city/national/combined battle modifier
- city naval/siege bonus
- naval and siege unlock capability maps and queries
- national policy bonus
- national diplomacy/spy bonus
- city spy/intel bonus
- empty result shapes, source-ID uniqueness and effect-data predicates

Existing main signatures remain thin compatibility wrappers that gather completed snapshots/ownership and delegate.

## Stacking and scope rules

- Numeric effect values remain additive.
- Duplicate completed IDs apply once because the Provider iterates the canonical safe set and emits unique source IDs.
- Naval/siege capability flags aggregate with boolean OR.
- City effects require a non-empty player-owned city and use only that city's completed snapshot.
- National policy, battle and diplomacy/spy effects use only the national completed snapshot and apply globally to the player.
- Combined battle modifiers add national and same-city values; cavalry charge retains the existing `0.08` city clamp.
- Unknown tech/effect keys and malformed numeric values are ignored safely.
- Enemy cities and researching-but-not-completed tech receive no Domestic Tech effect.

## Summary ownership

The Provider now owns economy-turn aggregation, phase-one effect counts, policy/numeric/military/naval/diplomacy summary slices, full integration summary and the integration-map contract. Korean presentation strings, tooltips and completion-card lines remain in main; presentation code queries exact Provider mappings instead of owning safe sets.

## Consumer boundaries

Economy turn, battle context/military, deployment, diplomacy, spy and city-detail consumers keep their existing main wrapper calls. Diplomacy/Spy controllers and services were not redesigned. Battle, settlement, deployment and trade services were not modified.

## Unchanged areas

- `domestic_tech_research_service.gd`: unchanged
- research start, charge, active state, normalization, progress, completion and mirrors: unchanged
- Tech Tree overlay, graph, selection, inspector, icon cache, completion queue/video/card/SFX: unchanged
- save/runtime schema and legacy `national_tech` / `city_tech` progression: unchanged

## Verification

- New Provider test: 34 checks, 0 failures
- T-1 Catalog: 19/19
- T-1 Rules: 17/17
- T-2 ResearchService: 35/35
- Discovered WorldMap runtime tests: 27/27 scripts pass
- Provider forbidden dependency scan: 0 matches
- Project parse and `WorldMap_16x9_Test.tscn` load: pass

Historical validators reject the intentional T-3 main reduction/wrappers until an exact T-3 checkpoint is available. Per the V-1 policy, validator recognition is committed separately and must compare changed function bodies to the immutable T-3 checkpoint.

## Line reduction

- `worldmap_main.gd`: 18,574 -> 17,393
- T-3 net reduction: 1,181 lines
- T-0 baseline 19,275 -> 17,393: cumulative net reduction 1,882 lines

## T-4 presentation candidates

- `_ensure_domestic_tech_tree_button_mvp`
- `_open_domestic_tech_tree_overlay_mvp`
- `_close_domestic_tech_tree_overlay_mvp`
- `_ensure_domestic_tech_tree_overlay_mvp`
- `_refresh_domestic_tech_tree_overlay_mvp`
- `_build_domestic_tech_detail_inspector_mvp`
- `_refresh_domestic_tech_detail_inspector_mvp`
- `_route_domestic_tech_detail_region_mvp`
- `_build_domestic_tech_graph_canvas_mvp`
- `_get_domestic_tech_graph_positions_mvp`
- `_add_domestic_tech_graph_branch_labels_mvp`
- `_add_domestic_tech_graph_lines_mvp`
- `_build_domestic_tech_graph_node_mvp`
- `_build_domestic_tech_compact_node_mvp`
- `_set_selected_domestic_tech_for_inspector_mvp`
- `_add_domestic_tech_icon_mvp`
- `_ensure_domestic_tech_completion_presentation_overlay`
- `_enqueue_domestic_tech_completion_presentations_mvp`
- `_play_next_domestic_tech_completion_presentation`
- `_play_domestic_tech_completion_video_mvp`
- `_show_domestic_tech_completion_card_mvp`
- `_finish_domestic_tech_completion_presentation_item_mvp`
