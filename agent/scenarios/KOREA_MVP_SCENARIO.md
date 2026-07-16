# KOREA MVP SCENARIO

## Proposed Identity And Scope

- Scenario ID: `korea_mvp_four_cities` (`Proposed`)
- Active region: Korea
- Active cities: Hanseong, Pyongyang, Gyeongju, Sabi
- China and Japan content: retained but inactive for this scenario

## Start

The player freely selects one of the four starting factions. The selected faction becomes the player nation and the other three become AI nations. This is not yet implemented. Player role and nation ID must be saved separately; Hanseong has no permanent player-role exception.

Starting generals must use the actual WorldMap registry and city assignments as authoritative sources. Thirteen previously observed generals are useful reference only; omissions or duplicates remain possible until a code audit. Starting resources are `Needs Data Audit`. Starting research is `Needs Runtime Audit` and must be confirmed against the existing tech tree before values are set.

## Outcome And Persistence

- Victory: player controls all four active cities.
- Defeat: player controls zero cities.
- Save data must identify the active scenario and player nation, alongside the responsible nation/city/general/research/transaction state.

## Expansion

Additional regions activate by scenario definition and GameSession selection, not by deleting inactive data. China, Japan, and future naval content may add their own active cities, technologies, encounters, and victory rules while preserving this scenario contract.
