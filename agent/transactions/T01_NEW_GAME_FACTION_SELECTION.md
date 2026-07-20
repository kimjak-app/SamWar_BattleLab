# T01 NEW GAME FACTION SELECTION

Status: `COMPLETE` (confirmed on the `v0.74-02-hotfix6` baseline).

## Implementation Record

- Entry scene: `res://NewGameFactionSelect.tscn`; it provides four start choices and a disabled-without-save Continue action.
- Single player-role source: autoload `res://scripts/game_session.gd` (`GameSession.player_faction_id`). Existing registry IDs are preserved: `player`/한성, `goguryeo`/평양, `silla`/경주, `baekje_faction`/사비.
- WorldMap consumes the selected faction once, creates runtime overrides from the existing city/hero registries, assigns the other three Korea factions as AI, selects the matching capital city, and derives player checks from the session faction ID.
- Save schema is backward compatible: root `game_session` stores scenario, player faction, start city, and AI IDs; old saves fall back to the legacy Hanseong (`player`) role.
- National research remains in `player_state`; city research remains in each serialized city runtime state. The selected player nation/capital is now the scope used by the WorldMap UI and player checks.
- Automated verification: no remaining `PLAYER_FACTION_ID` in `worldmap_main.gd`; project/editor parse, new entry scene, WorldMap, and Battle_Land headless loads pass.
- Manual QA remains required for F6 selection clicks, visual layout, save/load interaction, and battle-preparation UI for each faction.

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

PASS: all four faction selections, WorldMap ownership/role presentation, first-turn entry, save/load round trip, and Battle/WorldMap entry were included in the integrated F5 completion QA.

## Completion Decision

`COMPLETE`. The four-faction session/start contract is the locked baseline for T03 and later Korea MVP transactions.
