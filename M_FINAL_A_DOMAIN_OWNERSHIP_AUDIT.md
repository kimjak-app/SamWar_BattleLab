# M-FINAL-A | Domain Constant Ownership & Trade Formula Audit

Baseline branch: `recovery/worldmap-iso-sfx-services-20260912`

Audit baseline HEAD: `1af0e5df4ec6e39e27d16208e197e52a7610a553`

Latest baseline CI at audit time: `Verify C-track refactor` run `35231902400` — success.

## Goal

Close the WorldMap refactor without creating another oversized constants module.

Rules:

- `worldmap_main.gd` remains a scene-level coordinator / wiring hub.
- Domain rules, action IDs, tuning values, cooldowns, penalties, and result enums belong to the existing domain Controller/Service that owns the behavior.
- Main may retain compatibility aliases when current UI/coordinator call sites still depend on the old names.
- Scene-boundary constants stay in main.
- No balance, save-schema, AI, battle settlement, turn-order, UI text, or signal-lifecycle changes.

## Audit Result

### 1. Trade

#### Move / canonicalize

`TradeController` already owns:

- `TRADE_CONTROL_MODE_CHANCELLOR`
- `TRADE_CONTROL_MODE_MANUAL`

Main should change its duplicate literals to aliases:

```gdscript
const TRADE_CONTROL_MODE_CHANCELLOR := TradeControllerScript.TRADE_CONTROL_MODE_CHANCELLOR
const TRADE_CONTROL_MODE_MANUAL := TradeControllerScript.TRADE_CONTROL_MODE_MANUAL
```

The following trade-domain values are still owned as literals by main and should move to `TradeController` or the existing trade domain owner, with main retaining aliases only while needed:

- `RELATION_TRADE_MULTIPLIER`
- `TRADE_ROUTE_CAP`
- `TRADE_GLOBAL_DAMPENER`
- `TRADE_FOOD_FACTOR`

`TRADE_SUSPENSION_TURNS` is declaration-only in current main and can be removed if a repository-wide current-branch search confirms no live consumer.

#### Formula duplication confirmed

Current main has two independent implementations of the same relation multiplier concept:

1. `_get_trade_relation_multiplier_for_ui(source_faction_id, target_faction_id)`
   - relation status lookup
   - `RELATION_TRADE_MULTIPLIER`
   - trade-agreement bonus

2. `_calculate_trade_route_value(city_a, city_b)`
   - repeats relation status lookup
   - repeats `RELATION_TRADE_MULTIPLIER`
   - repeats trade-agreement bonus
   - then applies loyalty multiplier and `TRADE_GLOBAL_DAMPENER`

This is the real formula dedup target.

Recommended final shape:

- Add one canonical Trade-domain function, preferably on `TradeController`, e.g. `get_relation_multiplier_for_factions(source_faction_id, target_faction_id)`.
- The function owns relation-status base multiplier + agreement bonus.
- Main `_get_trade_relation_multiplier_for_ui()` becomes a thin compatibility wrapper to that function.
- `_calculate_trade_route_value()` calls the same canonical function instead of rebuilding the multiplier.
- Preserve exact arithmetic, float conversion, defaults, and bonus order.

Do not rename or redesign unrelated route calculations in M-FINAL-A.

### 2. Spy

`SpyActionService` is already the canonical owner of:

- `SPY_ACTION_GATHER_INFO`
- `SPY_ACTION_PUBLIC_SUPPORT_DISRUPT`
- `SPY_ACTION_LOYALTY_DISRUPT`
- `SPY_ACTION_REVOLT_INSTIGATE`
- `SPY_ACTION_WEDGE`
- `SPY_COOLDOWN_TURNS`
- all spy action costs
- all spy cooldown constants
- all detected-relation penalties
- revolt duration

Current main still uses the five action IDs in UI/presentation code, so those names should remain only as aliases to the Spy domain owner.

Recommended final shape:

- Expose the five public action-ID aliases from `SpyController` to `SpyActionService`, or have main alias directly to the service if that is cleaner with existing preload conventions.
- Remove all main-side spy cost/cooldown/penalty literals that are declaration-only.
- Do not duplicate those literals in `SpyController`.

### 3. Diplomacy

`DiplomacyActionService` is already the canonical behavioral owner of:

- relation statuses
- default/min/max relation score
- diplomacy action IDs
- alliance acceptance threshold
- trade-agreement multiplier bonus
- action costs/durations

`DiplomacyController` currently still duplicates several literals that already exist in `DiplomacyActionService`.

Before changing main, first make `DiplomacyController` aliases point at `DiplomacyActionService` for:

- relation status values / relation map
- `DIPLOMACY_SCORE_MIN`
- `DIPLOMACY_SCORE_MAX`
- `DIPLOMACY_DEFAULT_SCORE`
- `DIPLOMACY_ACTION_ENVOY`
- `DIPLOMACY_ACTION_TRIBUTE`
- `DIPLOMACY_ACTION_TRADE_AGREEMENT`
- `DIPLOMACY_ACTION_RESTORE_RELATIONS`
- `DIPLOMACY_ACTION_ALLIANCE_PROPOSAL`

Main still uses relation score/status constants in enemy diplomacy, military-support, and coordinator logic, so do not delete those names from main yet. Convert them to `DiplomacyControllerScript.*` aliases.

The five diplomacy action IDs are still used by main UI; convert to aliases rather than deleting call-site names in this closeout.

### 4. Battle

`BattleResultService` already owns:

- `RESULT_DEFENDER_WIN`
- `RESULT_ATTACKER_WIN`
- `RESULT_RETREAT`
- `RESULT_UNKNOWN`

Main's equivalent names are still used by battle-return orchestration. Keep compatibility names but change literals to aliases:

```gdscript
const INVASION_RESULT_DEFENDER_WIN := BattleResultServiceScript.RESULT_DEFENDER_WIN
const INVASION_RESULT_ATTACKER_WIN := BattleResultServiceScript.RESULT_ATTACKER_WIN
const INVASION_RESULT_RETREAT := BattleResultServiceScript.RESULT_RETREAT
const INVASION_RESULT_UNKNOWN := BattleResultServiceScript.RESULT_UNKNOWN
```

Keep in main:

- `WORLDMAP_BATTLE_CONTEXT_META_KEY`
- `WORLDMAP_BATTLE_RESULT_META_KEY`
- `WORLDMAP_BATTLE_SCENE_PATH`

These are scene-handoff boundary constants.

Do not force-move the remaining invasion/casualty/occupation constants in this pass unless an existing Battle service is already the clear canonical owner and the change is a pure alias.

### 5. Turn

`WorldMapTurnController` already owns:

- `PHASE_PLAYER`
- `PHASE_ENEMY`

Main still uses `TURN_PHASE_PLAYER` / `TURN_PHASE_ENEMY` broadly for saved/default state and coordinator guards. Keep the main names for compatibility, but change them to:

```gdscript
const TURN_PHASE_PLAYER := WorldMapTurnControllerScript.PHASE_PLAYER
const TURN_PHASE_ENEMY := WorldMapTurnControllerScript.PHASE_ENEMY
```

This is a pure ownership cleanup; no turn logic change.

### 6. Keep in main for M-FINAL-A

Do not extract merely to reduce line count:

- WorldMap scene paths and meta keys
- top-level UI layout constants still owned by the WorldMap scene
- save-path boundary constant
- global WorldMap coordinator constants without an already-established owner
- Hero/Occupation global index/cache/victory coordinator logic
- Domestic Tech compatibility bridges that are still live
- invasion/battle constants whose owner is not already unambiguous

## Patch Order

1. `DiplomacyController`: replace duplicated service-owned literals with aliases.
2. `SpyController`: expose only the public action IDs needed by main, aliased from `SpyActionService`.
3. `TradeController`: make trade-domain constants canonical and add one relation-multiplier function.
4. `worldmap_main.gd`: convert live duplicate constants to aliases; delete declaration-only Spy/Trade leftovers; route both trade relation calculations through the canonical Trade function.
5. `worldmap_main.gd`: alias Battle result IDs and Turn phase IDs.
6. Update validators only where they assert old literal ownership; strengthen them to require canonical aliases/delegation rather than weakening checks.
7. Run focused tests, parse/load, all static validators, and full `Verify C-track refactor` workflow.

## Explicit Non-Goals

- no new `worldmap_constants.gd`
- no balance tuning
- no save migration
- no UI redesign
- no AI redesign
- no battle settlement redesign
- no Hero/Occupation extraction
- no Domestic Tech bridge removal
- no mass rename
- no line-count target

## Completion Gate

M-FINAL-A is complete only when:

- no duplicated domain literals remain in main for the audited groups unless intentionally documented
- trade relation multiplier has one canonical implementation
- existing UI/coordinator names still work through aliases/wrappers
- project parses and WorldMap loads
- all existing focused regression tests pass
- static validators pass
- GitHub Actions `Verify C-track refactor` is green
