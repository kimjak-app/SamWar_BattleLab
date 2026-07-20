# SYSTEM SOURCE OF TRUTH

## T02 Occupation Settlement

- City ownership: runtime `CityState.owner_faction_id` (with compatibility mirrors), never a fixed city list.
- General faction/location: normalized runtime general state (`faction_id`/`side`, `current_city_id`).
- Stationed roster: target CityState `stationed_hero_ids`; a general is in at most one roster.
- Governor UI and runtime appointment: CityState `governor_id`; occupation starts empty until manual appointment.
- National aggregation: active cities whose runtime owner equals `GameSession.player_faction_id`; city stock stays source data.
- Faction elimination: persisted `player_state.defeated_factions`, derived from owner-matching active cities.
- AI target ownership: live CityState owner; derived cache generation invalidates after settlement.

## Hotfix 5 Resource and Research Scope

| Domain | Authoritative source | Derived/UI source |
| --- | --- | --- |
| City resources | `CityState.resource_stock` | city panel |
| National warehouse | no separate inventory | current player-owned city-stock aggregate |
| National research | owned city stock | aggregate validation, capital-first atomic payment plan |
| City research | selected city stock | selected-city validation/payment |
| Expedition cargo | source city stock | deployment panel/BattleContext |
| Turn production | city-stock mutation | rebuilt national aggregate |
| General location | runtime city + roster invariant | city panel |
| Wounded | city wounded queue | troop/treatment UI |

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
