# v0.68b-12b-8 Enemy Invasion Web Logic Audit

## Source Files Inspected
- `C:\dev\SamWar_web\js\core\app_state.js`
- `C:\dev\SamWar_web\js\core\world_rules.js`
- `C:\dev\SamWar_web\js\core\world_calendar.js`
- `C:\dev\SamWar_web\js\core\save_load.js`
- `C:\dev\SamWar_web\js\core\battle_state.js`
- `C:\dev\SamWar_web\js\core\battle_rules.js`
- `C:\dev\SamWar_web\js\core\battle_ai.js`
- `C:\dev\SamWar_web\js\ui\world_hud_ui.js`
- `C:\dev\SamWar_web\js\ui\world_map_ui.js`
- `C:\dev\SamWar_web\js\ui\ui_render.js`
- `C:\dev\SamWar_web\js\main.js`
- `C:\dev\SamWar_web\js\constants.js`
- Context-only Godot files inspected: `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`

## Web Call Flow
1. `world_map_ui.js` binds `[data-end-world-turn='true']` to `main.js` `onEndWorldTurn`.
2. `main.js` calls `endWorldTurn(appState)` from `app_state.js`.
3. `endWorldTurn()` applies player-side turn systems first: income, inter-faction trade income, upkeep, tax loyalty, wounded recovery, internal supply, internal troop rebalance, and trade cooldown decrement.
4. `endWorldTurn()` then calls `rollEnemyInvasion(tradeCooldownState.world.cities, ENEMY_INVASION_CHANCE)`.
5. If an invasion candidate exists, the state moves to `world.turnOwner = "enemy"`, selected city becomes the defender city, and `pendingBattleChoice` is created by `buildDefenseBattleChoice()`.
6. If no invasion is rolled, the state still moves to enemy turn but sets `world.pendingEnemyTurnResult` to a no-invasion message. The player then confirms `적군 턴 종료`, which calls `confirmEnemyTurnResult()` and advances to the next player turn.

## Enemy Turn Entry
- Entry function: `endWorldTurn(appState)` in `js/core/app_state.js`.
- Trigger: player clicks the world HUD `아군 턴 종료` button rendered by `js/ui/world_hud_ui.js`.
- Guard conditions: mode must be `world`, `world.turnOwner` must be `player`, and there must be no `pendingBattleChoice`, `pendingHeroDeployment`, `pendingHeroTransfer`, or `world.pendingEnemyTurnResult`.
- Flow is synchronous state transformation. The web UI is event-driven; no enemy world-turn timer was found for invasion selection.

## Enemy Action Selection
- The only audited world-level enemy action is a possible invasion.
- Invasion chance is `ENEMY_INVASION_CHANCE = 0.45` in `js/core/world_rules.js`.
- `rollEnemyInvasion()` returns null if there are no candidates or if the random roll is greater than or equal to the chance.
- If the roll succeeds, it randomly selects one candidate from all eligible enemy-city to player-city neighbor pairs.
- No world-level difficulty modifier, cooldown, scripted scenario target, or multiple enemy world actions per enemy turn was found in the audited source.

## Invasion Eligibility Rules
- Enemy faction definition: `isEnemyFactionId(factionId, playerFactionId = FACTION_IDS.PLAYER)` treats any non-empty faction id not equal to the player faction as enemy.
- Attacker eligibility: a city is eligible as an attacker if `isEnemyCity(attackerCity)` is true.
- Defender eligibility: a neighboring city is eligible as a defender if `isPlayerCity(defenderCity)` is true.
- Route/adjacency requirement: `getEnemyInvasionCandidates()` uses the attacker's `neighbors` array. `routeTypes` and pathfinding are not used in this selection.
- No troop threshold, resource threshold, peace/neutral relation check, naval route check, blocked route check, or city defense rating check was found in the invasion candidate selection.

## Target Selection Rules
- `getEnemyInvasionCandidates(cities)` enumerates every enemy city and every neighboring player-owned city.
- `rollEnemyInvasion()` selects one candidate by random index after the 45% chance passes.
- There is no priority for weakest city, nearest city, player capital, frontline role, city value, or hardcoded scenario target in the audited selection logic.

## Force / Roster Selection
- Invasion candidate creation only stores `attackerCityId` and `defenderCityId`.
- Actual battle force setup happens later when the player chooses manual or auto defense.
- `buildDefenseHeroDeployment()` selects defending player heroes from `getHeroIdsBySideAndLocation(defenderCity.id, playerFactionId)` and allocates troops from defender city `military.garrisonTroops`.
- `buildAutomaticFactionAllocation()` selects attacker heroes from `getHeroIdsBySideAndLocation(attackerCity.id, attackerCity.ownerFactionId)` and allocates troops from attacker city `military.garrisonTroops`.
- Hero locations are initialized from `battle_rosters.cityDefenderRosters` through `initializeHeroLocationsFromRosters()`.
- Allocation is bounded by hero command limits and available garrison troops; it does not affect invasion candidate selection.

## BattleContext / Battle Handoff
- `buildDefenseBattleChoice()` creates a defense `pendingBattleChoice` with:
  - `type: "defense"`
  - `originCityId` / `originCityName` from the attacker city
  - `targetCityId` / `targetCityName` from the defender city
  - labels `적군이 침공했습니다!`, `직접 방어`, and `자동 방어`
  - `battleContext: { type: "defense", attackerCityId, defenderCityId }`
- `ui_render.js` renders a defense-choice modal from `pendingBattleChoice`.
- `world_map_ui.js` routes the manual/auto choice to `main.js`.
- For manual defense, `main.js` first calls `openDefenseHeroDeployment()` so the player can choose defending heroes/troops.
- For auto defense, `main.js` calls `startBattle(state, cityId, { autoBattleEnabled: true })` directly.
- `startBattle()` creates a battle state with `createInitialBattleState()` and sets `mode: "battle"`. It also deducts allocated troops from the participating source cities before battle starts.

## City Ownership / Result Handling
- No city ownership changes when invasion is merely rolled. Ownership changes only after defense battle retreat or battle return.
- `retreatFromBattle()` immediately gives the defending city to the attacker faction for defense battles and converts stationed city heroes to the conqueror faction.
- `returnFromBattle()` for defense battles:
  - If the defense is lost, it transfers the defender city to the attacker faction, clears captured city garrison, returns enemy survivor/wounded troop outcomes, optionally moves player wounded to a nearest player-owned neighbor, and converts city heroes to the conqueror faction.
  - If the defense is won, it returns defending survivors/wounded to the defender city and returns enemy wounded to the enemy source city.
- `advanceWorldTurn()` returns the game to player turn after defense battle resolution.

## UI / Log Feedback
- No-invasion enemy turn feedback uses `world.pendingEnemyTurnResult.message`: `적군은 이번 턴 움직이지 않았습니다.`
- World HUD shows `아군 턴 종료` during player turn and `적군 턴 종료` when a pending no-invasion enemy result exists.
- Defense invasion feedback is a modal/choice panel with `적군이 침공했습니다!`, attacker city, defender city, and manual/auto defense buttons.
- Battle startup logs either the defense battle opening line or normal attack opening line in `createInitialBattleState()`.

## Save / Load Interaction
- Web save uses localStorage through `save_load.js`.
- `createSaveSnapshot()` forces `mode: "world"`, serializes world/city/hero state, but forces `world.turnOwner` to player and `world.pendingEnemyTurnResult` to null.
- `createSaveSnapshot()` does not persist `pendingBattleChoice`, `pendingHeroDeployment`, `pendingHeroTransfer`, or active `battle`.
- `normalizeWorldOnlyState()` also restores `mode: "world"`, clears battle/pending choices, forces `turnOwner` to player, and clears pending enemy result.
- Loading a save does not resume a pending invasion choice or battle. It returns to a normalized player-turn world state.

## Current Godot Gap Analysis
- Godot already has a world turn loop in `scripts/worldmap_test.gd`: player phase, enemy placeholder phase, return to player phase, turn/calendar advancement, domestic apply, save/load/reset, and a documented `_run_enemy_turn_mvp()` hook.
- Godot seed data already has enough static inputs for an initial candidate audit path: `CITY_HUD_DATA.owner`, `CITY_HUD_DATA.owner_faction_id`-style metadata where present, `neighbors`, `stationed_hero_ids`, `governor_id`, and troop/resource seed values.
- Godot does not yet have a runtime enemy invasion event model, pending battle choice UI, battle-choice modal, defense hero deployment state, enemy troop allocation, battle context creation, battle scene handoff, battle result return, city ownership mutation, city hero conversion, or pending invasion save/reset rules.
- Godot current save/load persists the left-panel `_player_state`; it does not persist runtime world city ownership or pending invasion events because those systems do not exist yet.
- The risky step is jumping directly from `_run_enemy_turn_mvp()` to battle scene transition. The web flow has an explicit pending choice and deployment bridge before battle starts, so Godot should preserve that separation.

## v0.68b-12b-9 Godot Event MVP Status
- Implemented in `scripts/worldmap_test.gd` only; root `WorldMap_Test.tscn` was not modified.
- Godot now rolls `ENEMY_INVASION_CHANCE = 0.45` once during the existing enemy-turn placeholder path.
- Candidate pairs use scene-authored `WorldMapCityMarker.owner_faction_id` and `WorldMapCityMarker.neighbors`: attacker must be enemy-owned, defender must be neighboring and player-owned.
- On success, Godot creates `_player_state.pending_invasion_event` with `type: defense`, `attacker_city_id`, `defender_city_id`, source, and turn number.
- The defender city is selected and the left world status text shows the pending invasion.
- Save serialization excludes pending invasion state; load/reset clear it, and load normalizes enemy-phase saves back to player turn, following the audited web save/load policy.
- Still missing by design: pending choice UI/card, manual/auto defense controls, BattleContext bridge, defense deployment, battle handoff, battle result return, city ownership updates, and save/load persistence for resolved world ownership state.

## v0.68b-12b-10 Godot Choice UI MVP Status
- Implemented in `scripts/worldmap_test.gd` only; root `WorldMap_Test.tscn` was inspected but not modified.
- Godot now renders a runtime `PendingInvasionChoiceCard` from `_player_state.pending_invasion_event`.
- The card mirrors the web defense choice surface at MVP scope: `Enemy Invasion`, `적군 침공 발생`, attacker city, defender city, `방어전을 준비하십시오.`, `수동 방어`, and `자동 방어`.
- Manual and auto defense buttons are connected only to safe placeholder status messages and keep the pending event intact.
- `아군 턴 종료` is disabled/blocked while a pending invasion event exists, preventing duplicate invasion event stacking.
- Save/load/reset policy remains unchanged: pending invasion state is excluded from saves and cleared by load/reset, so the card hides after normalization.
- Still missing by design: defense deployment, battle-prep payload creation, battle handoff, auto battle resolution, battle result return, city ownership updates, troop losses, and resolved world ownership persistence.

## v0.68b-12b-10.5 Session Handoff Status
- Current stable baseline for the next session is `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP` at commit `6d3616339e5d555127c5f4eb5eb91160d362aa2e`.
- User-reported F6 runtime visual check is working normally, and the pending invasion choice UI is acceptable for the current MVP.
- Active worldmap scene is root-level `WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` may not exist.
- Runtime save path is `user://worldmap_left_panel_state.json`.
- `agent/LOCAL_ENV.md` and `.godot/` remain ignored local files and must not be committed.
- Pending invasion event is not persisted on save/load, and load/reset clear it according to the web audit policy.
- BattleContext generation and battle scene handoff remain intentionally deferred.
- Before implementing battle handoff, the next session should first clean up right city info panel readability and bind existing hero portrait assets.

## Recommended Godot Implementation Plan

### v0.68b-12b-10a Right City Info Panel Web Parity Cleanup
- Clean up the right city information panel before battle handoff work.
- Make selected/defender city owner, nation, region, resources, troops, governor, and stationed hero data readable without raw debug text.

### v0.68b-12b-10b Hero Portrait Asset Binding MVP
- Bind existing hero portrait assets where available.
- Keep `?` fallback for missing portraits.
- Prefer shared lookup for chancellor card, stationed hero list, right city info panel, and future pending invasion choice hero display.

### v0.68b-12b-11 Enemy Invasion BattleContext Bridge
After the two cleanup tasks above, convert a pending invasion event into a defense battle choice structure similar to web `pendingBattleChoice`.
- Prepare safe battle context data from `type`, `attackerCityId`, `defenderCityId`, and selected control mode.
- Reuse the existing `수동 방어` / `자동 방어` choice UI from `v0.68b-12b-10`.
- Do not apply final ownership results in this task.

### v0.68b-12b-12 Enemy Invasion Battle Scene Handoff MVP
- Transition from WorldMap to the Godot battle scene and pass battle context safely.
- Do not apply final ownership/troop/resource results in this task.

### v0.68b-12b-13 Battle Result Return MVP
- Return from battle scene to worldmap with a result payload.
- Keep city ownership/troop/resource application deferred to the next task.

### v0.68b-12b-14 Enemy Invasion Ownership / Troop Apply
- Apply a returned defense battle result to city ownership, troop state, and hero faction/location state.
- Preserve web behavior where losing a defense transfers the city to the attacker faction and winning defense returns surviving/wounded troops.
- Add save/load support for the resulting city ownership and troop state.

## Deferred Risks
- Web invasion candidate selection ignores troop thresholds, route type, diplomacy, and city strength. Porting it exactly may feel abrupt if Godot UI lacks a player response layer.
- Web save/load intentionally clears pending invasion/battle state. Godot should not persist pending invasion state unless a clear restore design is added.
- BattleContext bridge depends on the future worldmap-to-battle contract and should not bypass `BATTLE_CONTEXT_CONTRACT.md`.
- City ownership mutation must wait until the battle return path is stable; applying ownership during enemy turn event creation would diverge from the web flow.
