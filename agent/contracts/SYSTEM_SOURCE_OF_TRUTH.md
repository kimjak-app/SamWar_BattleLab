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

Transactions should read and update the responsible state once, then derive UI and battle payloads from it. Where existing code differs, record `Needs Runtime Audit` and converge only as required by an active transaction. Existing Battle/WorldMap contracts remain protected until a dedicated implementation validates any change.
