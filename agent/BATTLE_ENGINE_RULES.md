# BATTLE ENGINE RULES

## Role
- Defines battle engine responsibility boundaries.
- Protects the current stable `5v5` battle loop while preparing for external `BattleContext` input.

## Core Direction
- The battle engine executes battle rules.
- The battle engine consumes prepared roster and scenario data.
- The battle engine does not choose heroes.
- The battle engine does not own worldmap state.
- The battle engine should eventually receive all roster, map, terrain, and battle-type inputs through `BattleContext`.

## Owned By Battle Engine
- Battle presentation and animation.
- Turn order and action resolution.
- Movement, attack, damage, facing, and status resolution.
- Strategy command execution.
- Defend command execution.
- Unique skill execution after skill metadata is resolved.
- Reinforcement deployment timing during the active battle.
- Battle UI flow, target selection, command panel behavior, and toast playback.
- Battle result calculation.

## Not Owned By Battle Engine
- Which heroes are assigned to a region, city, army, or fleet.
- Which armies collide on the worldmap.
- Which encounter starts a battle.
- Which battle type applies to a worldmap location.
- Which `map_variant_id` is selected from region rules.
- Long-term worldmap troop, supply, ownership, or hero location mutation.

## Current MVP Guard
- Current stable target:
  - `5v5`
  - reinforcement rounds
  - strategy
  - defend
  - unique skill
- Preserve current `5v5` actor / target parity.
- Preserve current `3 main + 2 reinforce` per side until the roster contract expands.
- Preserve current reinforcement deploy timing.
- Preserve current damage / move / attack formulas unless a task explicitly changes them.
- Preserve direct move-click, right-click cancel, floating panel, post-move panel reopen, active ally pulse, and toast queue behavior.

## Future Input Adapter
- A future adapter may convert `BattleContext.roster` to the current internal unit state setup.
- The adapter should be the boundary between external contract data and existing battle scripts.
- Existing demo data can remain as fallback until external context is wired.
- Current `TEST_BATTLE_ROSTER` style data is MVP structure and is expected to be replaced by `BattleContext` input.
- Future battle-type-specific battlefield map variants should be selected from `BattleContext.map_variant_id`.
- Adapter work should be treated as architecture-sensitive and at least `MEDIUM`; use `COMPLEX` if it changes scene startup, unit state creation, or battle flow.

## Result Boundary
- Battle engine may produce a future `BattleResult` object.
- Worldmap should consume `BattleResult` and decide ownership, retreat, casualty, capture, supply, and strategic consequences.
- Battle engine should not directly apply persistent worldmap consequences.

## Regression Guard
- Any marker / slot / unit visual source changes require regression review.
- Any roster or hero identity change requires `hero_id` and skill lookup verification.
- Any BattleContext adapter must keep current scene load and full-auto smoke path stable.
