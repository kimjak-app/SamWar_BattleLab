# T01 NEW GAME FACTION SELECTION

Status: active runtime transaction specification. This documentation task does **not** implement runtime behavior.

## Goal

Let the player start the Korea MVP by selecting Hanseong, Pyongyang, Gyeongju, or Sabi as the starting faction, then enter the WorldMap first turn with one player nation and three AI nations.

## Player Flow

1. Start a new Korea MVP game.
2. See the four selectable factions/cities.
3. Choose one faction.
4. Validate the selection and initialize the session.
5. Assign the chosen nation as player and the other three as AI.
6. Enter the first WorldMap turn with clear feedback.

## State Boundaries

Start: scenario is selected but no player nation is committed. End: scenario, player nation, AI nation roles, capitals/selected city, general placement, resources, research, and first-turn state are initialized and saved. The current Hanseong-fixed assumption must be removed only through this transaction. Exact nation IDs, generals, resources, and tech values require audit; do not invent them.

## Tech And Persistence

Record the Korea MVP active tech set, initial progress/completion state, UI state, and applicable national/city ownership after the required audit. Save/load must restore scenario ID, player nation, AI roles, city ownership, generals, resources, research state, selected city, and transaction/session state.

## Failure Handling

Invalid or unavailable selection must not partially initialize a session. Show a clear failure state, preserve the selection screen or safely return to it, and avoid corrupting save data.

## Protect

Preserve the existing `Battle_Land` engine, Battle/WorldMap handoff contract, WorldMap city/hero registry authority, existing technology data, and scene-authored layout rules.

## Expected Impact

Likely entry points include `scripts/worldmap/worldmap_main.gd`, `WorldMap.tscn`, and the existing WorldMap save/load modules; exact implementation paths and ownership are `Needs Runtime Audit`. Changes may include directly required session/scenario/save/UI code and tests. No unrelated refactor, battle replacement, asset change, or tech-value change is allowed.

## Acceptance Tests

- Each of Hanseong, Pyongyang, Gyeongju, and Sabi can be selected once as player.
- The selected nation is player; exactly the remaining three are AI.
- No Hanseong-only player decision remains in the new-game path.
- Capitals/selection, generals, resources, and research initialize from audited sources.
- First WorldMap turn loads; save/load preserves the selected faction and roles.
- Invalid selection has no partial state mutation.

## Manual QA

Run the above flow separately for all four factions. Confirm readable selection feedback, correct WorldMap ownership/role presentation, first-turn entry, save/load round trip, and no Battle/WorldMap regression.

## Completion Decision

Complete only after acceptance tests and integrated QA pass in a runtime implementation task, with results recorded here. Until then: `Not Yet Implemented`.
