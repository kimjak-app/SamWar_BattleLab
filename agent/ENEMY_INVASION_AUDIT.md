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

## Recommended Godot Implementation Plan

### v0.68b-12b-9 Enemy Invasion Event MVP
- Add an enemy-turn event roll using web rules: 45% chance, candidates from enemy-owned city neighbors that are player-owned.
- Create a visible pending invasion event/log/status only.
- Select and highlight the defending city if safe.
- Do not create `BattleContext`, do not transition to battle, do not change ownership, and do not move heroes or troops.
- Add save/load/reset behavior for either clearing or explicitly preserving the pending event; prefer clearing on load unless a dedicated pending-event restore is implemented.

### v0.68b-12b-10 Enemy Invasion BattleContext Bridge
- Convert a pending invasion event into a defense battle choice structure similar to web `pendingBattleChoice`.
- Prepare `BattleContext` fields: `type`, `attackerCityId`, `defenderCityId`, `controlMode`.
- Add minimal manual/auto choice UI if the Godot HUD has a safe place for it.
- Do not apply final ownership results in this task.

### v0.68b-12b-11 Enemy Invasion Result / Ownership Apply
- Apply a returned defense battle result to city ownership, troop state, and hero faction/location state.
- Preserve web behavior where losing a defense transfers the city to the attacker faction and winning defense returns surviving/wounded troops.
- Add save/load support for the resulting city ownership and troop state.

### v0.68b-12b-12 Enemy Invasion QA / Save-Load Stabilization
- Verify repeated turn cycles, pending event handling, reset/load behavior, no duplicate invasion rolls, and no battle handoff unless explicitly selected.

## Deferred Risks
- Web invasion candidate selection ignores troop thresholds, route type, diplomacy, and city strength. Porting it exactly may feel abrupt if Godot UI lacks a player response layer.
- Web save/load intentionally clears pending invasion/battle state. Godot should not persist pending invasion state unless a clear restore design is added.
- BattleContext bridge depends on the future worldmap-to-battle contract and should not bypass `BATTLE_CONTEXT_CONTRACT.md`.
- City ownership mutation must wait until the battle return path is stable; applying ownership during enemy turn event creation would diverge from the web flow.
