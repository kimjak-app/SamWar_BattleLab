# WorldMap Spy Controller extraction audit

Baseline: `90cfe4343977cd70ed9e512ec3a3b35c2f41bd71`

## Production ownership

`WorldMapMain -> WorldMapActionCoordinator -> WorldMapSpyController -> WorldMapSpyActionService`

- `WorldMapSpyController` is the only `SpyActionService` instance owner.
- The Coordinator receives the Controller and preserves the generic begin/cancel/presentation/complete/execute contract.
- The Service production adapter is the Controller, never `worldmap_main.gd`.
- `WorldMapSpyPresentationHelper` owns Spy-only display strings and state summaries; main retains Node construction, signal wiring, and thin presentation application.

## Caller/callee classification

### Controller / state adapter

- target/city/faction lookup adapters
- live player-state and city-runtime-state replacement
- city intel normalization/recording
- Spy validation/execute/turn lifecycle facade
- generic resource, city state, hero, and technology adapters
- Diplomacy relation/alliance query and command boundary

### Service / Spy rules

- action definitions, validation, costs, cooldowns, success/detection probability
- gather-info visibility and payload rules
- public-support and loyalty disruption mutations
- revolt instigation mutation and duration tick
- wedge target/counterpart selection, eligibility, probability, cost, and result
- failed/success result dictionaries and last-result storage

### Presentation helper

- intel visibility/known-field levels and labels
- action candidates, validation status, policy state, hints
- recent action result and wedge result formatting
- Spy technology modifier display
- cooldown and world-turn Spy summaries

### Main thin bridges retained

- `_ensure_spy_controller`, `_ensure_spy_presenter`: scene-owned construction/configuration
- `_apply_spy_action`: generic Coordinator execute entry
- `_validate_spy_action`: UI compatibility query
- `_normalize_city_intel_registry`: generic save/load compatibility query
- `_advance_spy_cooldown_for_world_turn`, `_advance_revolt_instigation_for_world_turn`: generic turn entry
- presentation wrapper functions: existing UI call-site compatibility only
- `_on_spy_action_pressed`, card/button creation and refresh: scene Node wiring and video lifecycle

### Cross-domain boundaries retained

- Diplomacy owns relation/alliance dictionaries and mutations. Spy calls `apply_spy_relation_delta` and `break_alliance_for_spy_wedge` on `DiplomacyController`; Spy Service does not mutate diplomacy containers.
- City/worldmap owns generic city records, loyalty, public support, troops, hero registry, and resource stock containers. Controller adapters read/write them for Spy execution.
- Technology/economy data generation remains in its existing domain; Spy interprets only Spy modifiers.
- Trade, Military, Battle handoff, and presentation video controller are unchanged.
- Enemy strategic `spy_pressure` candidate scoring remains in the AI strategic-action layer as a display/selection boundary; it does not execute Spy actions or mutate Spy state.

## Removed from main

The legacy dispatcher, general Spy four-action validation/calculation/mutation implementations, wedge selection/execution/alliance-break implementation, probability modifiers, city-intel recording implementation, and Spy-only formatting bodies were removed. No caller-zero production legacy implementation remains.
