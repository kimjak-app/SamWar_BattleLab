# C-2 City Resource and Production Service Extraction Audit

## Baseline

- C-1 checkpoint: `dfa9f17` (`refactor(worldmap): extract city administration service`)
- C-2 starts from the clean C-1 production checkpoint.

## Ownership moved

`WorldMapCityResourceService` now owns:

- `storage` normalization, required-key population, and default storage construction
- `resource_stock` default initialization and read calculation
- capital-first player-city ordering
- city resource delta calculation and application
- aggregate player compatibility-stock calculation
- city and national multi-city payment plans and atomic plan commit
- player city-production iteration, delta application, and result aggregation

Main retains thin adapters for the established function signatures. The city-production income adapter composes existing City Administration, Supply, Domestic Tech EffectProvider, and Chancellor calculations; the resource service owns iteration and stock mutation.

## Protected boundaries

- `_apply_domestic_turn_mvp` remains the turn/session coordinator; only its existing city-production call delegates.
- M-9 deployment and M-6 T03 transaction services are unchanged and keep their existing main resource query/mutation contracts.
- T-2 ResearchService is unchanged and continues to use the same city/national payment adapters.
- Trade rules, Military rules, save, scene, and UI behavior are not owned by the resource service.

## Schema and payment contract

No key was renamed or migrated. `city_state["resource_stock"]`, `city_state["storage"]`, `_player_state["resource_stock"]`, and `_player_state["national_aggregation"]["resources"]` retain their existing meanings. The player compatibility mirror continues to be derived from owned city stocks. Payment remains validate/plan-all followed by commit-all; failed validation performs no mutation.

## Verification

- City Administration: 22/22 PASS.
- City Resource Service: 26/26 PASS.
- M-9 PlayerAttackDeployment: 39/39 PASS.
- M-6 StrategicBattleTransaction: 30/30 PASS.
- T-2 ResearchService: 35/35 PASS.
- Trade routing/controller/automation/internal transfer regressions PASS.
- Godot headless parse and `WorldMap_16x9_Test.tscn` load PASS.
- `git diff --check` PASS.

## Main reduction and remaining tails

`worldmap_main.gd`: +82 / -209 / net -127 lines for C-2. Formatting and physical HUD node ownership remain for C-3/HUD tracks. Turn/save/session coordination remains intentionally in main.
