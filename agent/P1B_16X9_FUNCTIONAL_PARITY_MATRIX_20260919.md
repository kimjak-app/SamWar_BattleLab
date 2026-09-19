# P-1B | 16:9 → Production Functional Parity Matrix

Date: 2026-09-19  
Branch: `refactor/production-runtime-unification-20260919`  
Parity rule: **WorldMap_16x9_Test runtime behavior must be reproduced 1:1 in WorldMap.tscn before P-1B closes.**

The only intentional non-parity item is the old sample-tech badge fixture. It is explicitly replaced by real completed-tech state and real resolved icons.

| 16:9 feature axis | Production owner | Status |
|---|---|---|
| 2048×1152 Design-2 background | `WorldMap.tscn` + background refresh owner | Promoted |
| 13 approved city positions / labels / routes | canonical scene + marker/route owners | Promoted |
| Camera fit / bounds | canonical scene + camera controller | Promoted |
| Compact left/right HUD positions | `HudPositionOwner` | Promoted |
| Warehouse tabs | `WorldMapWarehouseTabsController` | Promoted |
| Three-column garrison | `WorldMapGarrisonCompactController` | Promoted |
| Readability / role summaries / portrait sizes | `WorldMapReadabilityController` | Promoted |
| Stability/tax/help presentation | `WorldMapPanelRefinementController` | Promoted |
| Tech badges | `WorldMapTechBadgeSummaryController` | **Upgraded: real completion data/icons only** |
| Top navigation | `WorldMapTopNav.tscn` | Promoted |
| Turn-end compass | production compass installer | Promoted |
| Contextual city actions | `WorldMapCityActionController` | Promoted |
| Diplomacy/trade/spy video + result | `WorldMapActionPresentation.tscn` | Promoted |
| Territory ownership overlay | `WorldMapTerritoryController` | Promoted |
| Turn-end summary popup | `WorldMapTurnSummaryController` | Promoted to real compass signal |
| Chancellor/governor assignment & policy speech | `WorldMapCharacterSpeechController` | Promoted |
| LeftPanelLockGuard result | authoritative compact HUD source + scoped turn-summary suppression | Replaced, no QA guard shipped |
| StableHudMirror result | source-owned stability/role/readability presentation | Replaced, no mirror shipped |
| TurnTransitionLateGuard result | deterministic production owners/signals | Replaced, no late guard shipped |
| V2BackgroundTestController | canonical persisted Design-2 scene | Replaced |
| 16x9 editor preview | canonical scene itself stores baseline | Superseded |

## Real-tech rule

Production must never import or use `worldmap_tech_badge_test_controller.gd`.

The production tech summary reads:

1. national/city completed-tech snapshots;
2. the real tech catalog definition;
3. the real resolved icon path;
4. the actual Texture2D.

It refreshes immediately after world-turn tech completion/normalization and on city selection.

## Hidden state rule

Legacy header controls may be hidden, but their authoritative text must not be blanked when game logic still consumes it.

In particular `CalendarLabel` remains populated while hidden because:

- TurnEndCompass uses it in turn-state handling;
- WorldMapTurnSummaryController uses it in the turn-completion token/meta.

## Close condition

P-1B is not complete from static parity alone. Runtime QA must confirm all of these in the canonical `WorldMap.tscn`:

1. territory colors;
2. one full turn → summary popup, with no legacy-text flash;
3. chancellor appointment → speech popup;
4. chancellor policy change → speech popup;
5. governor appointment → speech popup;
6. governor policy change → speech popup;
7. completed national tech → actual national icon appears;
8. completed city tech → actual selected-city icon appears;
9. contextual spy/diplomacy/trade → video/result flow;
10. compact HUD remains compact throughout these transitions.

Only after that evidence may P-1B-5 cleanup close the WorldMap promotion.
