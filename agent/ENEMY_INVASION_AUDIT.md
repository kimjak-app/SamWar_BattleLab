# v0.68b-12b-8 Enemy Invasion Web Logic Audit

## v0.68b-12b-23 Hero State Visual Badge Status
- Wounded/captured placeholder states are now visible in existing roster text surfaces.
- WorldMap selected-city/right city panel hero lists use runtime-merged hero data and append `[부상]`, `[포로]`, or `[사망]`.
- Battle formation panels preserve context hero status fields and show the same marker style.
- Post-battle result card hero summaries use the state marker format.
- Captured heroes are still not moved, excluded from battle, or removed from city rosters; dead remains unused by result logic.

## v0.68b-12b-22 Hero Status Placeholder Status
- Invasion battle results now apply a losing-side hero status placeholder after owner/troop changes are summarized.
- Deterministic MVP rule: first eligible losing-side hero becomes wounded, second eligible losing-side hero becomes captured, and dead remains unused.
- Captured heroes remain in their city rosters; this is status display/persistence only, not a prison or movement system.
- Post-battle result card includes a compact hero status summary line.
- Remaining deferred audit items: actual prisoner movement, prison/recruit/execution UI, wound recovery turns, death, stat-based rolls, and detailed prisoner panels.

## v0.68b-12b-21 Result Panel Status
- Invasion battle return now builds a display-only result summary after applying the battle result.
- Defender win, attacker win/city fall, retreat, and unknown paths produce separate summary titles/copy.
- The WorldMap left HUD result card shows ownership change/retention, city troop change, attacker source-city troop change, and occupation troops when present.
- Result summary is not persisted; save/load remains responsible only for actual owner/troop/hero runtime state.
- Remaining deferred audit items: prisoner/wound/death display, resource loot display, detailed combat statistics, and a full result report UI.

## v0.68b-12b-20 Casualty + Hero State Status
- Invasion battle results now apply MVP casualty math instead of only minimal troop updates.
- Defender victory keeps ownership, lowers defender city troops within clamp guards, and heavily reduces attacker source-city troops.
- Attacker victory transfers ownership, assigns occupation troops from attacker survivors/fallbacks, and reduces attacker source-city troops by the detached occupation amount.
- Hero runtime save/load now carries `status`, `wounded`, `captured`, and `dead` with old-save defaults of `normal` / `false`.
- Remaining deferred audit items: actual wound/capture/death rolls, prisoner movement, resource looting, detailed battle-power casualty formula, AI strategy recalculation, and multi-invasion queues.

## v0.68b-12b-19 Battle Result Persistence Status
- Invasion battle result owner/troop changes are now save/load participants through WorldMap city runtime overrides.
- City stationed hero ids and hero current city ids are included in runtime persistence so later BattleContext roster construction can use loaded placement state.
- Load clears pending invasion event/context and does not restore stale battle choice UI for completed results.
- Seed dictionaries remain read-only sources; loaded changes are applied to mutable runtime city/hero state.
- Deferred: wounds, capture, death, resource looting, precise casualty formulas, strategic AI recalculation, and multi-invasion queues.

## v0.68b-12b-18c Reinforcement Toast + Auto Stop Status
- False no-support reinforcement toast fixed in the battle scene: toast display now depends on a nonempty actual arriving unit list, not only on the reinforcement round check.
- Inactive/hidden WorldMap context support slots are excluded from arrival readiness and deployment, so missing support no longer produces turn-3 arrival toast copy.
- Victory/defeat finalization now blocks non-result toast queue/playback, reinforcement checks, round start, enemy action callbacks, and auto battle action entry.
- Remaining manual QA: F6 no-support invasion turn-3 toast absence, direct sample support toast preservation, immediate auto stop after result, and worldmap return.

## v0.68b-12b-18b Roster Panel + Auto Battle End Status
- Remaining sample hero leak source fixed in the battle scene formation panels: panel refresh used capacity-slot `unit_state` before context-empty metadata, so inactive support slots could still show sample 김유신/을지문덕/유비/제갈량.
- WorldMap enemy-invasion panels now hide empty/inactive context support slots and do not call sample `TEST_BATTLE_ROSTER` fallback for those cells.
- Direct battle sample fallback remains intact when no WorldMap context is present.
- Auto battle now stops at finalized victory/defeat, and deferred auto tick / ally-turn scheduling is blocked after battle end.
- Remaining manual QA: F6 백제/사비 invasion should confirm panel roster matches actual context units, no sample support cells appear, auto battle stops immediately after result, and worldmap return still works.

## v0.68b-12b-18a Reinforcement Fallback Leak + Toast Layer Status
- Root cause confirmed and fixed in the battle scene: the 유비/제갈량 leak was `TEST_BATTLE_ROSTER` fallback in context slot fill, not the WorldMap same-faction/2-hop filter.
- For `enemy_invasion` / WorldMap context battles, empty support slots are now deactivated instead of filled with sample roster heroes.
- 사비/백제 context still skips 성도/촉 heroes by faction rule; missing support should remain empty.
- Toast layering hotfix: `RoundToastRoot` now has explicit high z order, and facing indicators are hidden during round/reinforcement/unique-skill toast playback and restored afterward.
- Remaining manual QA: F6 사비/백제 invasion support leak check, empty slot visibility, toast arrow suppression/restoration, auto battle, and worldmap return.

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
- This historical handoff has been superseded. Current stable baseline is `v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`.
- User-reported F6 runtime visual check is working normally, and the pending invasion choice UI is acceptable for the current MVP.
- Active worldmap scene is root-level `WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` may not exist.
- Runtime save path is `user://worldmap_left_panel_state.json`.
- `agent/LOCAL_ENV.md` and `.godot/` remain ignored local files and must not be committed.
- Pending invasion event and pending battle context are not persisted on save/load, and load/reset clear both according to the web audit policy.
- Battle scene handoff, battle result return, and bounded runtime ownership/troop apply are complete; persistence, resource loss, and detailed casualty handling remain deferred.
- Right city info panel cleanup, hero portrait binding, BattleContext bridge, and safe battle scene handoff are complete.

## v0.68b-12b-10a Right City Panel Cleanup Status
- Implemented in `scripts/worldmap_city_info_panel.gd` with pending invasion state supplied from `scripts/worldmap_test.gd`; root `WorldMap_Test.tscn` initial right-panel fallback text was also cleaned.
- The right selected-city panel now reads existing seed data for city name, owner/nation/region, population, gold, food, resource ratings, troops, defense, public support/order, commerce, agriculture, taesu/governor, and stationed heroes.
- Pending invasion state remains display-only: the defender city shows `침공 대상 도시 · 방어전 준비 중`, and the attacker city shows `침공 출발 도시`.
- Still missing by design: defense deployment, auto defense resolution, battle result return, city ownership updates, troop losses, and resolved world ownership persistence.

## v0.68b-12b-11 BattleContext Bridge Status
- Implemented in `scripts/worldmap_test.gd`; root `WorldMap_Test.tscn`, `scripts/worldmap_city_info_panel.gd`, and `scripts/worldmap_hero_portrait_helper.gd` were inspected but not modified for this bridge.
- Godot now converts `_player_state.pending_invasion_event` into runtime-only `_player_state.pending_battle_context` when the player clicks `수동 방어` or `자동 방어`.
- The context shape includes `type: defense`, `source: enemy_invasion`, `mode`, attacker/defender city ids and names, turn numbers, owner ids, troop totals, stationed hero ids, and governor ids from existing marker/HUD seed data.
- Validation requires a pending defense event, known attacker and defender city ids, an enemy-owned attacker, and a player-owned defender. Invalid input fails safely and does not create a context.
- Save/load/reset policy follows the web audit: pending invasion event and pending battle context are excluded from saves and cleared during load/reset normalization.
- Still missing by design: defense hero deployment, auto battle resolution, battle result return, city ownership updates, troop/resource losses, and resolved world ownership persistence.

## v0.68b-12b-12 Battle Scene Handoff Status
- Implemented in `scripts/worldmap_test.gd` and `scripts/battle_web_import_test.gd`.
- Selected battle scene: `Battle_Fullscreen_Test.tscn`.
- Handoff strategy is runtime-only Godot `Engine` metadata under `samwar_worldmap_battle_context`; no save file, repo runtime file, autoload, or project setting was added.
- Manual and auto defense now prepare the full pending battle context, store a deep copy for handoff, and transition to `res://Battle_Fullscreen_Test.tscn`.
- The battle controller reads and clears the handoff context on startup, stores local `worldmap_battle_context`, and logs attacker city, defender city, and mode.
- Direct battle scene launch without context is preserved and falls back to the existing test battle setup.
- Still missing by design: battle result return, city ownership updates, troop/resource losses, hero movement/capture, defense deployment UI, and auto battle resolution.

## v0.68b-12b-13 Battle Roster Context Apply Status
- Implemented in `scripts/battle_web_import_test.gd` only.
- WorldMap-launched defense battles now adapt the existing `Battle_Fullscreen_Test.tscn` capacity slots from handoff context instead of creating a new battle scene or roster engine.
- Defender governor/stationed hero ids map to ally slots; attacker governor/stationed hero ids map to enemy slots.
- Current compatible web/Godot hero ids resolve through a compact map, including `yi_sun_sin` -> `yi_sunsin`, `jeong_do_jeon` -> `jeong_dojeon`, and `kim_yu_sin` -> `gim_yusin`.
- Missing context, empty hero arrays, unknown hero ids, and missing governors safely fall back to the existing `TEST_BATTLE_ROSTER`.
- Direct battle scene launch remains unchanged when no `samwar_worldmap_battle_context` metadata exists.
- City troop/garrison scaling remains deferred; this patch applies identity/metadata and concise battle log feedback only.
- Still missing by design: battle result return, city ownership updates, troop/resource losses, hero movement/capture, defense deployment UI, and auto battle resolution.

## v0.68b-12b-14 Battle Result Return Status
- Implemented in `scripts/battle_web_import_test.gd` and `scripts/worldmap_test.gd`.
- Battle result return uses separate runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_result`.
- Battle payload shape includes source, type `defense_result`, mode, result `victory`/`defeat`, winner `defender`/`attacker`, attacker/defender city ids and names, and turn number.
- WorldMap-launched battles show a runtime `월드맵으로 돌아가기` button after victory/defeat; pressing it stores the payload and transitions to root `WorldMap_Test.tscn`.
- WorldMap reads and clears the payload on startup, shows a defense result status, clears pending invasion event and pending battle context, hides the pending choice card, and refreshes panels.
- Direct `Battle_Fullscreen_Test.tscn` launch remains unchanged when no WorldMap context exists.
- Superseded by `v0.68b-12b-15` for bounded runtime ownership/troop application.

## v0.68b-12b-15 Invasion Result Ownership Troop Apply Status
- Implemented in `scripts/worldmap_test.gd` and `scripts/battle_web_import_test.gd`.
- Battle result payloads now include attacker/defender owner ids, starting troop counts, and deployed survivor troop totals.
- WorldMap result handling accepts result/winner/is_player_win variants and treats unknown values as safe no-ownership-change outcomes.
- Defense victory preserves target-city ownership, clears pending invasion/context, refreshes UI, and applies minimal nonnegative troop reductions when current/payload troop data exists.
- Defense defeat transfers the target city to the attacker owner using existing `owner` / `nation` city fields plus `WorldMapCityMarker.owner_faction_id`, updates `_player_state.owned_city_ids`, applies safe occupation troops, clears pending state, and refreshes marker/right panel/world HUD.
- Retreat/cancel/aborted/unknown results clear pending invasion safely and never change ownership.
- Still missing by design: hero capture, hero city movement, resource losses/looting, detailed casualty calculation, defense deployment UI, auto battle resolution, AI strategy recalculation, multi-invasion queue, and save/load persistence expansion for resolved city ownership/troops.

## v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix Status
- Implemented in `scripts/worldmap_test.gd`.
- Cause: result apply wrote `troops`, `owner`, and `nation` directly into `CITY_HUD_DATA` seed city dictionaries, which can be read-only in Godot.
- Fix: runtime result changes now use `_city_runtime_states`; source city dictionaries are deep-copied with `duplicate(true)`, mutated as runtime state, and served through `_get_city_hud_entry()`.
- The right `CityInfoPanel` receives a merged seed + runtime city data map so changed ownership/troops display without mutating seed data.
- Warning cleanup: unused attacker-city-name parameter is now `_attacker_city_name`.
- Verification passed: `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: live F6 manual invasion return path still needs exact click-through confirmation for the original crash report.

## v0.68b-12b-16 Hero Battle Data + Unique Skill Contract Status
- Implemented in `scripts/worldmap_test.gd` and `scripts/battle_web_import_test.gd`.
- WorldMap defense BattleContext now carries actual city hero battle copies in `defender_heroes` and `attacker_heroes`, alongside the existing hero-id arrays for compatibility.
- Each copied hero includes combat fields, one `portrait_path`, one separate `cutin_path`, and required unique-skill fields.
- Battle runtime registers context hero/skill data into runtime registries before roster assignment, then falls back to the existing sample roster when data is missing or unsupported.
- Portrait contract is 512-source only; 128 battle slots should downscale from `portrait_path`. No split `portrait_128_path` / `portrait_512_path` fields were introduced.
- Existing 128 folders were not deleted, no bulk images were moved or added, and cutin image binding remains future work.
- Save/load persistence for hero battle contract data remains unimplemented by design.

## v0.68b-12b-16b Hero Placement Data Patch Status
- Implemented in `scripts/worldmap_test.gd`.
- Five additional key heroes are now battle-contract ready for WorldMap invasion BattleContext: 유비, 권율, 척준경, 여포, and 하후돈.
- Placement changes affect the city defender roster source used by invasion BattleContext: 성도 includes 유비, 한성 includes 권율, 평양 includes 척준경, 낙양 includes 여포, and 업성 includes 하후돈.
- 척준경 was moved out of 한성 and into 평양, avoiding duplicate city placement.
- The patch keeps result handling, ownership apply, troop apply, save/load, capture/wounds, resource loss, and cutin presentation unchanged.

## v0.68b-12b-17 Actual Hero Portrait Binding Status
- Implemented in `scripts/battle_web_import_test.gd`.
- WorldMap-launched defense battles now prefer `worldmap_context_hero_registry` portrait data over sample `HERO_REGISTRY` data, preserving actual BattleContext `portrait_path` values for overlapping hero ids.
- Battle portrait Sprite2D slots load the single 512-source `portrait_path` through a ResourceLoader-safe resolver and scale it to the existing 128 target size.
- Missing portraits use a named common unknown portrait fallback instead of a specific sample hero portrait.
- Unique-skill lookup now prefers WorldMap context skill data, so context `skill_name` drives the unique-skill toast text; missing skill toast/cutin assets use a common skill fallback icon.
- Still missing by design: full cutin presentation, save/load persistence for hero battle data, hero capture/wounds/death, hero city movement, resource looting, and defense deployment UI.

## v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix Status
- Implemented in `scripts/battle_web_import_test.gd`.
- Battlefield portrait badges now scale 512-source portraits to the previous engine display baseline of about `41px`, matching old `128x128` battlefield portraits at scene scale `0.32`.
- `portrait_path` remains the only portrait source; no 128 images or split portrait fields were added.
- Generated `장수명 전법` names are now fallback-only. Known heroes can reuse existing sample unique-skill registry names and cutin paths when WorldMap context data lacks explicit skill names or dedicated cutin assets.
- The existing unique-skill toast frame/animation path is preserved where dedicated assets exist; common fallback icon remains only for missing assets.
- Still missing by design: full cutin presentation, save/load persistence for hero battle data, hero capture/wounds/death, hero city movement, resource looting, and defense deployment UI.

## v0.68b-12b-18 Invasion Reinforcement Source Rule Status
- Implemented in `scripts/worldmap_test.gd` and `scripts/battle_web_import_test.gd`.
- Cause addressed: BattleContext used city rosters, but battle-side context slot fill fell back to sample `TEST_BATTLE_ROSTER` for missing support slots, allowing distant sample heroes to appear.
- Main attacker/defender rosters now use the attacker/defender source city stationed heroes first.
- Support candidates are restricted to same-faction or explicit-ally cities within direct/2-hop MVP adjacency; no 3-hop or full-hero-pool search is used.
- Empty context slots are deactivated in the battle scene, so missing nearby reinforcements stay missing instead of pulling distant sample heroes.
- Static 평양 -> 한성 check excludes 성도 from the 2-hop candidate set; 성도 유비/제갈량 are not eligible as ordinary support heroes.
- Still missing by design: Save/Load persistence for resolved roster state, wounds/capture, hero movement, resource looting, and precise strategic AI.

## Recommended Godot Implementation Plan

### v0.68b-12b-15 Enemy Invasion Ownership / Troop Apply
- Complete at bounded MVP runtime scope.
- Follow-up: decide whether resolved city ownership/troop changes should be persisted through save/load.
- Follow-up: F6-verify manual victory, defeat, retreat/cancel, and unknown result branches through the full UI flow.

## Deferred Risks
- Web invasion candidate selection ignores troop thresholds, route type, diplomacy, and city strength. Porting it exactly may feel abrupt if Godot UI lacks a player response layer.
- Web save/load intentionally clears pending invasion/battle state. Godot should not persist pending invasion state unless a clear restore design is added.
- BattleContext bridge depends on the future worldmap-to-battle contract and should not bypass `BATTLE_CONTEXT_CONTRACT.md`.
- City ownership mutation must wait until the battle return path is stable; applying ownership during enemy turn event creation would diverge from the web flow.
