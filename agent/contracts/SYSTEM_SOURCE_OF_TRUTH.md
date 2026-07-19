# SYSTEM SOURCE OF TRUTH

## Target Contract

This is a target responsibility contract for future transaction implementation. Current code may not yet have these exact structures. It does not authorize an immediate broad refactor.

| State | Recommended single source |
| --- | --- |
| Active scenario | ScenarioDefinition / GameSession |
| Player nation | `GameSession.player_faction_id` (implemented by T01; persisted under root `game_session`) |
| Nation resources | NationState |
| City owner | CityState |
| City resources and troops | CityState |
| General current nation | GeneralState |
| General current city | GeneralState |
| National research | NationTechState |
| City research | CityTechState |
| Battle input | BattleContext |
| Battle result | BattleResult |
| Pending invasion | Pending Invasion / Transaction State |
| Expedition cargo | T02 BattleContext/BattleSupplyRuntime until settlement; then source/occupied CityState |
| Healthy city troops | CityState `troops` |
| Wounded troops and recovery | CityState wounded queue |
| Applied battle result IDs | persisted WorldMap player/session transaction registry |

T02 uses CityState `resource_stock` for expedition gold/food/salt and does not use nation `resource_stock` for cargo settlement. Confirmed cargo is owned by BattleContext/BattleSupplyRuntime until result settlement. Pending battle context is transient; applied result IDs and wounded recovery state persist. Transactions should read and update the responsible state once, then derive UI and battle payloads from it.

For T02 defender supply, target CityState `resource_stock` is the sole food/salt source of truth. `BattleSupplyRuntime` is an in-battle temporary snapshot; WorldMap result settlement owns the single write of remaining defender supply back to the target city. `GameSession.get_battle_faction_display_name` owns Korean production battle-faction display names, while city display names are resolved by WorldMap into BattleContext.
