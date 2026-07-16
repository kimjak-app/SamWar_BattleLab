# KOREA MVP SCENARIO

## Proposed Identity And Scope

- Scenario ID: `korea_mvp_four_cities` (implemented)
- Active region: Korea
- Active cities: Hanseong, Pyongyang, Gyeongju, Sabi
- China and Japan content: retained but inactive for this scenario

## Start

The player selects one of four registry-backed starts: `player`/한성, `goguryeo`/평양, `silla`/경주, or `baekje_faction`/사비. `GameSession` saves the role separately from the faction ID, and the other three are AI.

Starting generals must use the actual WorldMap registry and city assignments as authoritative sources. Thirteen previously observed generals are useful reference only; omissions or duplicates remain possible until a code audit. Starting resources are `Needs Data Audit`. Starting research is `Needs Runtime Audit` and must be confirmed against the existing tech tree before values are set.

## Outcome And Persistence

- Victory: player controls all four active cities.
- Defeat: player controls zero cities.
- Save data must identify the active scenario and player nation, alongside the responsible nation/city/general/research/transaction state.

## Expansion

Additional regions activate by scenario definition and GameSession selection, not by deleting inactive data. China, Japan, and future naval content may add their own active cities, technologies, encounters, and victory rules while preserving this scenario contract.
