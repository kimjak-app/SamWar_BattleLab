# v0.68b-12b-30 Invasion Attack Web Parity Gap Audit

Baseline: `v0.68b-12b-29A Web-Parity Troop Allocation Wounded Queue Import` / `b2fc653c08718a6ed9f54ecd59df0a302e1008b7`

Scope: docs-only audit. No gameplay, UI, or battle logic was changed.

## Files Inspected

### Web
- `C:\dev\SamWar_web\js\core\world_rules.js`
- `C:\dev\SamWar_web\js\core\app_state.js`
- `C:\dev\SamWar_web\js\core\battle_state.js`
- `C:\dev\SamWar_web\js\core\save_load.js`
- `C:\dev\SamWar_web\js\ui\selected_city_ui.js`
- `C:\dev\SamWar_web\js\ui\ui_render.js`
- `C:\dev\SamWar_web\js\ui\world_map_ui.js`
- `C:\dev\SamWar_web\js\ui\hero_transfer_ui.js`
- `C:\dev\SamWar_web\js\ui\military_ui.js`
- `C:\dev\SamWar_web\js\main.js`

### Godot
- `scripts/worldmap_test.gd`
- `scripts/worldmap_city_info_panel.gd`
- `scripts/player_attack_deployment_panel.gd`
- `scripts/battle_web_import_test.gd`
- `scripts/battle_unit_state.gd`
- `agent/WORLDMAP_RULES.md`
- `agent/CURRENT_STATE.md`
- `agent/NEXT_TASKS.md`
- `agent/HANDOFF_TO_CODEX.md`
- `agent/CHANGELOG.md`
- `agent/SESSION_LOG.md`

## Player Attack

### Attack Eligibility / Source City

- Web status:
  - `buildAttackBattleChoice()` chooses current valid `selection.originCityId` first, then `getAttackSourceCity()` (`app_state.js:962-993`).
  - UI only opens attack choice when `canEndTurn && canAttackCity(...)` (`ui_render.js:324-333`).
- Godot status:
  - `_start_player_attack_battle()` gates through `_get_player_attack_block_reason()` and `_find_player_attack_source_city()` (`worldmap_test.gd:1806-1819`).
  - City panel emits `attack_requested(city_id)` and has enable/disable state (`worldmap_city_info_panel.gd:7`, `122`, `558`).
- Gap:
  - Direct-neighbor source selection is largely parity.
  - Godot uses MVP city ownership helpers and blocks pending invasion/event states; web uses `mode`, `turnOwner`, `pendingBattleChoice`, `pendingHeroDeployment`, `pendingHeroTransfer`, and `pendingEnemyTurnResult`.
- Risk:
  - Low. Attack launch rules are close enough for current MVP, but exact web mode-state parity should be revisited once Godot adds more pending flows.
- Recommended patch:
  - Keep as-is unless new pending world actions are added.
- Priority:
  - P2

### Hero Deployment UI

- Web status:
  - Attack/defense deployment uses candidates with `commandRank`, `commandLabel`, and `commandLimit` (`app_state.js:161-168`, `hero_transfer_ui.js:40-84`).
  - Default allocation uses command limits and available garrison (`app_state.js:183-222`).
  - Allocation clamp also respects command limit and remaining garrison (`app_state.js:246-272`).
- Godot status:
  - `PlayerAttackDeploymentPanel` displays source/target, garrison, supply, hero rows, state badge, stats, and `SpinBox` allocation (`player_attack_deployment_panel.gd:29-120`, `136-205`).
  - Captured/dead are excluded by deployable hero helpers; wounded remains selectable.
- Gap:
  - Godot does not enforce web `commandRank` / `commandLimit`. Each SpinBox max is the whole `max_deployable_troops`, not the hero command limit (`player_attack_deployment_panel.gd:196-202`).
- Risk:
  - Medium. Players can assign all troops to one low-command hero, diverging from web balance and UI expectations.
- Recommended patch:
  - Add Godot command-rank/command-limit helper and clamp each selected hero allocation by that limit.
- Priority:
  - P1

### Source City Troop Decrement

- Web status:
  - `startBattle()` subtracts `troopAllocation.totalAllocatedTroops` from the source city before battle (`app_state.js:1364-1373`).
- Godot status:
  - `_confirm_player_attack_deployment()` subtracts `total_allocated_troops` from source city and records before/after fields in BattleContext (`worldmap_test.gd:1898-1954`).
- Gap:
  - Player source city decrement parity is implemented in Godot 29A.
- Risk:
  - Low. F6/save-load QA still needed for click-flow persistence.
- Recommended patch:
  - Manual QA only.
- Priority:
  - P1

### Defender Allocation / Enemy Defender Garrison Pre-Decrement

- Web status:
  - `startBattle()` builds `enemyTroopAllocation` from the defender city for attack battles and subtracts `enemyTroopAllocation.totalAllocatedTroops` from that city before battle if separate from source (`app_state.js:1356-1383`).
- Godot status:
  - 29A builds `defender_troop_allocation`, `defender_total_allocated_troops`, and defender unit allocated fields (`worldmap_test.gd:3070-3115`, `3168-3193`).
  - Godot does not pre-decrement defender city garrison before battle start.
- Gap:
  - Metadata/outcome parity exists, but enemy defender garrison pre-decrement parity is missing.
- Risk:
  - High. Defender troops can be counted as still in the city during battle and then also used in outcome application, creating troop accounting drift.
- Recommended patch:
  - Next patch should subtract defender allocated troops at player attack battle confirmation/start, with a double-decrement guard and save/load persistence.
- Priority:
  - P0

### BattleContext / Battle Unit Allocation Fields

- Web status:
  - `battleTroopAllocation` includes player and enemy allocations plus `unitAllocations` (`app_state.js:1384-1393`).
  - `buildBattleUnit()` stores `troops`, `maxTroops`, `allocatedTroops`, and `initialAllocatedTroops`, but leaves HP at hero `maxHp` (`battle_state.js:51-75`).
- Godot status:
  - BattleContext carries selected ids, allocation, supply, source before/after, and defender allocation (`worldmap_test.gd:3061-3115`).
  - `BattleUnitState` now stores `allocated_troops` and `initial_allocated_troops` (`battle_unit_state.gd:20-60`).
  - Battle scene context registry preserves allocated fields and applies them to unit troop fields without HP scaling (`battle_web_import_test.gd:1503-1510`, `6437-6446`).
- Gap:
  - Player attack allocation field parity is mostly implemented.
- Risk:
  - Low. Need F6 confirmation that allocation-zero heroes are absent and allocated troop labels are sane.
- Recommended patch:
  - QA and unit-level debug assertions.
- Priority:
  - P1

## Enemy Invasion / Defense

### Invasion Candidate / Roll

- Web status:
  - `getEnemyInvasionCandidates()` picks enemy cities adjacent to player cities (`world_rules.js:191-214`).
  - `rollEnemyInvasion()` picks a candidate by chance (`world_rules.js:216-225`).
  - `endWorldTurn()` applies income/recovery/supply, then rolls invasion and creates defense choice (`app_state.js:1713-1755`).
- Godot status:
  - Enemy invasion flow exists in `worldmap_test.gd` and uses source-limited rosters/support rules from previous patches.
  - Godot has turn advance and pending battle choice/context cleanup.
- Gap:
  - Godot has a richer current support-source MVP, but not all web turn pipeline pieces are parity in this audit scope.
- Risk:
  - Medium. Invasion timing and recovery order should be confirmed after troop woundedQueue is expanded to defense.
- Recommended patch:
  - Keep invasion roll as-is until defense troop parity is patched.
- Priority:
  - P1

### Defense Deployment / Troop Allocation

- Web status:
  - `buildDefaultDefenseDeployment()` auto-selects defender city player heroes and default troop allocations by command limits (`app_state.js:930-959`).
  - `startBattle()` uses this deployment for defense if no pending deployment exists (`app_state.js:1353-1355`).
- Godot status:
  - Enemy invasion defense can launch BattleContext, but there is no player defense deployment panel or command-limit troop allocation equivalent.
  - Existing Godot invasion result still uses `_calculate_invasion_casualty_result()` MVP rates for defense (`worldmap_test.gd:2268-2322`, `2661-2714`, `2831-2911`).
- Gap:
  - Defense battle does not use the 29A allocated troop outcome / woundedQueue parity path.
- Risk:
  - High. Player attack and defense battles now use different troop accounting models.
- Recommended patch:
  - Add defense deployment/default allocation parity and pass defense allocations through the battle scene result payload.
- Priority:
  - P0

### Enemy Attacker Garrison Decrement in Defense

- Web status:
  - For defense battles, `enemySourceCity` is the attacker city; enemy allocation is built and pre-decremented (`app_state.js:1356-1383`).
- Godot status:
  - Enemy invasion attacker rosters exist, but no allocated troop pre-decrement parity for enemy attacker city is present in the defense flow.
- Gap:
  - Enemy attacker city can keep full city troops while its attack force is in battle.
- Risk:
  - High. This is the defense equivalent of the player-attack defender pre-decrement gap.
- Recommended patch:
  - Include enemy attacker allocation and source-city pre-decrement in the same defense troop parity patch.
- Priority:
  - P0

### Defense Victory / Defeat Result Handling

- Web status:
  - Defense lost: occupy defender city, clear captured city garrison, apply enemy troop return to captured city, and player wounded to nearest player-owned neighbor (`app_state.js:1578-1601`).
  - Defense won: return player survivors/wounded to defender city; enemy wounded returns to enemy source city without survivors (`app_state.js:1602-1609`).
- Godot status:
  - Defense victory/defeat use bounded casualty formulas and city owner/troop changes (`worldmap_test.gd:2661-2714`, `2831-2911`).
  - Godot does not apply troop woundedQueue to invasion defense outcomes.
  - Godot has support rules, captured/dead exclusion, and hero status placeholders.
- Gap:
  - Defense result troop return, retreat city, and woundedQueue handling are not web parity.
- Risk:
  - High. Defense battles are currently the biggest post-29A parity gap.
- Recommended patch:
  - Implement defense troop outcome application using web `returnFromBattle()` rules.
- Priority:
  - P0

## Battle Result

### Survivor / Wounded / Dead Formula

- Web status:
  - `calculateBattleUnitSurvivors()` uses `floor(initialAllocatedTroops * hp/maxHp)` (`app_state.js:320-330`).
  - `calculateBattleTroopOutcome()` and `calculateEnemyBattleTroopOutcome()` apply the win/defeat formulas (`app_state.js:332-386`).
- Godot status:
  - `battle_web_import_test.gd` now mirrors this for player attack payloads (`battle_web_import_test.gd:2085-2128`).
  - `worldmap_test.gd` includes fallback outcome helpers for player attack (`worldmap_test.gd:2797-2828`).
- Gap:
  - Player attack parity is implemented; defense/invasion still uses old MVP casualty formula.
- Risk:
  - High for defense, low for player attack.
- Recommended patch:
  - Reuse the 29A outcome payload path for `source == enemy_invasion`.
- Priority:
  - P0

### Captured City Garrison / Hero Recruitment

- Web status:
  - Captured city garrison is cleared before troop return (`app_state.js:1501-1507`, `1637-1646`).
  - Player attack victory recruits/converts city heroes to player faction (`app_state.js:1647-1650`, `world_rules.js:366-395`).
  - Defense defeat converts city heroes to conqueror faction (`app_state.js:1601`).
- Godot status:
  - Player attack victory clears target woundedQueue and sets target garrison to player survivors (`worldmap_test.gd:2717-2755`).
  - Godot intentionally does not recruit/convert enemy city heroes during player attack per previous patch scope.
  - Captured heroes and runtime hero state are separate placeholder systems.
- Gap:
  - Hero faction conversion/recruitment is web-implemented but intentionally deferred in Godot.
- Risk:
  - Medium. Occupied cities may retain enemy heroes in data until a dedicated conversion/captive rule is implemented.
- Recommended patch:
  - Defer until prisoner/recruit policy is defined.
- Priority:
  - Deferred

### Result Card / Troop Result Display

- Web status:
  - `lastBattleTroopResult` is stored and rendered in military UI (`app_state.js:1626-1633`, `1671-1675`, `1704-1708`; `military_ui.js:136-147`).
- Godot status:
  - Post-battle result card exists and player attack copy now includes allocated/survivor/wounded/dead lines (`worldmap_test.gd:2717-2794`).
- Gap:
  - Godot result copy is sufficient for current MVP, but not identical to web city military result display and lacks F6 QA.
- Risk:
  - Low.
- Recommended patch:
  - Add F6 QA checklist and optionally city panel last troop result display later.
- Priority:
  - P2

## Wounded System

### Hero Wounded

- Web status:
  - The inspected web battle troop code is soldier woundedQueue based; hero-level wounded/captured/dead status is not the same system.
- Godot status:
  - Godot has hero `status`, `wounded`, `captured`, `dead`, `[부상 N턴]` display, captured/dead exclusion, and wounded battle penalties.
- Gap:
  - Godot intentionally extends beyond current web parity here.
- Risk:
  - Medium if hero wounded and troop woundedQueue are confused in future patches.
- Recommended patch:
  - Keep names and docs explicit: hero wound state vs troop woundedQueue.
- Priority:
  - P2

### Troop WoundedQueue

- Web status:
  - City `military.woundedQueue` stores `{ turnsLeft, troops }`; `applyWoundedRecovery()` decrements each world turn and recovers troops to garrison (`app_state.js:275-295`, `1509-1563`).
  - Save/load preserves city `military.woundedQueue` through world city merge (`save_load.js:180-276`; `world_rules.js:250-264`).
- Godot status:
  - 29A adds city `woundedQueue` / `wounded_queue`, save/load, and `_apply_wounded_recovery_for_world_turn_mvp()` (`worldmap_test.gd:3489-3581`, `3996-4111`).
  - Currently applied to player attack outcomes, not full defense/invasion outcomes.
- Gap:
  - Player attack woundedQueue is implemented; defense/invasion woundedQueue parity is missing.
- Risk:
  - High for defense result consistency; medium for persistence until F6 save/load QA is complete.
- Recommended patch:
  - Extend woundedQueue to defense result application and manually QA save/load/turn recovery.
- Priority:
  - P0

## Save / Load

### Pending Battle Cleanup

- Web status:
  - `normalizeWorldOnlyState()` forces `mode: "world"`, clears `battle`, `pendingBattleChoice`, `pendingHeroDeployment`, `pendingHeroTransfer`, and `pendingEnemyTurnResult`, and normalizes turn owner to player (`save_load.js:214-275`).
- Godot status:
  - Save serializes player state and clears pending invasion event/context fields (`worldmap_test.gd:3855-3868`).
  - Load applies world state and refreshes UI.
- Gap:
  - Godot cleanup policy is broadly aligned for pending invasion/context, but no explicit `pendingHeroDeployment` equivalent is persisted.
- Risk:
  - Low for current MVP.
- Recommended patch:
  - Recheck when Godot adds more pending UI states.
- Priority:
  - P2

### City / Resource / Hero / WoundedQueue Persistence

- Web status:
  - Cities, heroes, resources, last battle troop result, and wounded recovery result are normalized into save state (`save_load.js:180-276`).
  - Web `main.js` blocks save/load while battle mode or active battle exists (`main.js:1190-1217`).
- Godot status:
  - City owner/troops/rosters/resource_stock/woundedQueue and hero status/location save/load are implemented (`worldmap_test.gd:3996-4150`).
- Gap:
  - Godot does not persist a web-style `lastBattleTroopResult` as a world UI result object; result card is immediate guidance.
- Risk:
  - Low.
- Recommended patch:
  - Optional city panel result history after core parity gaps are closed.
- Priority:
  - P2

## UI / UX

### Attack Choice / Deployment / Defense Choice

- Web status:
  - Selected city UI renders attack button only through `renderAttackAction()` when `canOpenAttackChoice` is true (`selected_city_ui.js:15-39`).
  - World map UI binds `data-attack-city-id` clicks to `onAttackCity` and battle choice clicks to `onBattleChoiceConfirm` (`world_map_ui.js:263-285`).
  - Web has attack choice panel, defense modal, deployment modal, auto/manual buttons, remote battle label, command-limit sliders (`ui_render.js:258-315`; `hero_transfer_ui.js:1-104`).
  - `main.js` forwards deployment toggle/troop changes and `onHeroDeploymentStart()` to `startBattle()` only in world mode and with nonempty selection (`main.js:900-932`).
- Godot status:
  - Godot has city attack button, player attack deployment panel with SpinBoxes and supply preview, and enemy invasion manual/auto defense choice.
  - Godot lacks a defense deployment UI.
- Gap:
  - Player attack deployment is MVP-polished, but defense deployment UI is missing.
- Risk:
  - Medium. Defense troop parity likely needs a default allocation first, then optional UI.
- Recommended patch:
  - P0 should implement default defense allocation/result parity; manual defense deployment UI can follow.
- Priority:
  - P1

### Wounded Recovery Notification / Troop Result Display

- Web status:
  - Web keeps `lastWoundedRecoveryResult` and `lastBattleTroopResult` for UI (`app_state.js:1552-1561`, `1626-1633`; `military_ui.js:136-147`).
- Godot status:
  - Godot logs troop wounded recovery and result cards show player attack troop outcome, but no dedicated wounded recovery UI notification was confirmed.
- Gap:
  - Recovery notification parity is incomplete.
- Risk:
  - Low to medium; functionality can work without UX clarity.
- Recommended patch:
  - Add UI notification after defense troop parity is stable.
- Priority:
  - P2

## P0 Recommendations

1. **Player attack defender garrison pre-decrement parity**
   - Implement defender allocation source-city troop decrement at battle start for `source == player_attack`.
   - Add double-decrement guard and ensure victory/defeat result application does not count undeployed defender garrison as active battle troops.

2. **Enemy invasion defense troop allocation/result parity**
   - Add defense default player troop allocation, enemy attacker allocation, and both source-city pre-decrements.
   - Reuse 29A battle unit allocated troop fields and HP-ratio survivor formulas for `source == enemy_invasion`.

3. **Defense woundedQueue / retreat-city parity**
   - Defense win: player survivors/wounded return to defender city, enemy wounded return to attacker source without survivors.
   - Defense loss: city occupied, captured city garrison cleared, enemy survivors/wounded enter captured city, player wounded return to nearest player-owned neighbor if available.

4. **WoundedQueue F6/save-load QA**
   - Verify queue persistence, `turnsLeft` decrement, garrison recovery, and result-card/city panel clarity after both player attack and defense parity are wired.

## Final Summary Table

| Area | Web Implemented | Godot Implemented | Gap | Priority | Recommended Patch |
|---|---:|---:|---|---|---|
| Player attack eligibility/source city | Yes | Yes | Minor mode-state differences | P2 | Revisit with more pending world states |
| Player attack deployment UI | Yes | Partial | No commandRank/commandLimit clamp | P1 | Add command limit helper/clamp |
| Player source troop decrement | Yes | Yes | Needs F6 save/load QA | P1 | Manual QA |
| Player attack defender pre-decrement | Yes | No | Defender allocation not removed before battle | P0 | Defender garrison pre-decrement patch |
| Battle unit allocated troop fields | Yes | Yes | Needs F6 context QA | P1 | Debug/QA assertions |
| Player attack troop outcome | Yes | Yes | F6 win/loss QA pending | P1 | Manual QA |
| Enemy invasion candidate roll | Yes | Partial | Godot richer MVP, timing parity not fully confirmed | P1 | Recheck after defense troop parity |
| Defense deployment/default allocation | Yes | No | No web-style defense allocation | P0 | Defense allocation parity patch |
| Enemy attacker pre-decrement in defense | Yes | No | Attacker city troop accounting drift | P0 | Defense source pre-decrement patch |
| Defense result troop return | Yes | No | Uses old casualty MVP, not allocated outcomes | P0 | Defense troop result parity patch |
| Defense retreat city | Yes | No | Player wounded do not return to nearest player neighbor | P0 | Defense retreat-city woundedQueue patch |
| Troop woundedQueue player attack | Yes | Yes | F6/save-load QA pending | P1 | Manual QA |
| Troop woundedQueue defense | Yes | No | Defense outcomes do not use queue | P0 | Extend queue to defense |
| Hero wounded/captured/dead | No direct parity | Yes | Godot-specific system | P2 | Keep separate from troop queue |
| Save/load city troops/resources/queue | Yes | Yes | No lastBattleTroopResult persistence | P2 | Optional result history |
| Attack/defense UX | Yes | Partial | Defense deployment and recovery notification missing | P1/P2 | Defense deploy UI later |
| Hero recruit/conversion on capture | Yes | No | Intentionally deferred | Deferred | Prisoner/recruit policy patch |
