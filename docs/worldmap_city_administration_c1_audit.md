# C-1 City Administration Service Extraction Audit

## Baseline

- Baseline checkpoint: `af0af137177cec3cc3d8e8ac8e0267a60e70bf9e`
- Branch: `recovery/worldmap-iso-sfx-services-20260912`
- Production scope: city governor assignment, governor policy, and city domestic-effect calculation only.

## Ownership moved

`WorldMapCityAdministrationService` is the canonical owner of:

- governor assignment validation and mutation-plan result
- governor policy metadata and lookup
- city policy snapshot lookup
- governor aptitude effects
- governor policy effects
- the no-valid-governor chancellor fallback calculation

The former main implementations of `_get_governor_policy_entry`, `_get_city_policy_id`, `_calculate_city_domestic_effects`, `_apply_governor_type_effect`, and `_apply_governor_policy_effect` are thin delegates. The governor-assignment callback retains UI refresh coordination while delegating validation.

## Dependency boundary

The service is `RefCounted` and accepts city, hero, chancellor, faction, and policy snapshots as arguments. It has no Node, UI, save, turn, `_player_state`, or `_city_runtime_states` dependency. Main remains responsible for reading canonical runtime state and applying the validated `governor_id` mutation.

## Protected cross-domain boundaries

- Recruitment rules and mutation remain in `MilitaryController`.
- `_transfer_stationed_hero_between_player_cities` remains the Hero/Occupation cross-domain tail in main.
- Chancellor policy ownership and national chancellor effects remain in main.
- Trade, battle, turn, save, and presentation ownership are unchanged.

## Schema preservation

No save or runtime key changed. City `governor_id`, `governor_policy_id`, stationed-hero fields, player chancellor fields, and all resource/storage schemas retain their existing contracts.

## Verification

- City Administration service: 22/22 checks PASS.
- MilitaryController: 17/17 checks PASS.
- Domestic Tech Catalog/Rules/Research/Effects/Tree/Completion regressions PASS.
- Godot headless parse PASS.
- `git diff --check` PASS.

## Main reduction and remaining tails

`worldmap_main.gd`: +30 / -94 / net -64 lines for C-1. UI refresh coordination, Hero/Occupation transfer, recruitment adapters, HUD shell, and turn/save/session orchestration remain intentionally in main.
