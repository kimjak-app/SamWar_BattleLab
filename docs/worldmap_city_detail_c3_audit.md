# C-3 City Detail Presentation Extraction Audit

## Baseline

- C-2 baseline checkpoint: `6a3e73e5133ab6a24209d41f99e309a53166cf97`
- C-3 production checkpoint: `6cfea9a1651999a9b97b96eb3a56ece213f2b04f`
- Branch: `recovery/worldmap-iso-sfx-services-20260912`
- Scope: City Detail presentation ownership only. No City Administration, resource mutation, recruitment, hero transfer, Trade, battle, save, or turn ownership moves in C-3.

## Ownership moved

`WorldMapCityDetailPresentationController` is the presentation owner for:

- resource/default city-detail rendering
- city storage/resource summary formatting
- resource status/detail text formatting
- recruitment result presentation and failure hints
- governor/recruitment request presentation signals
- city-detail-only presentation helpers

The controller is a `Node`, receives a narrow query callable and the already-extracted `CityResourceService`, and does not read `_player_state` or `_city_runtime_states` directly.

## Main boundary after C-3

`worldmap_main.gd` remains the coordinator for:

- CityInfoPanel signal wiring
- attack request -> existing battle entry
- governor assignment request -> C-1 `CityAdministrationService`
- recruitment request -> existing M-1 `MilitaryController`
- hero transfer -> existing Hero/Occupation cross-domain tail
- unified-panel shell/tab routing
- internal/external Trade routes
- HUD refresh/save/turn/scene orchestration

`_apply_city_detail_tab_content` remains a top-level router because the unified panel hosts multiple domains. Its resource/default branch delegates presentation to `CityDetailPresentationController`; internal/external Trade branches retain the existing Trade-owned paths.

## Protected cross-domain boundaries

- Recruitment rules and mutation remain owned by `MilitaryController`.
- `_transfer_stationed_hero_between_player_cities` remains outside City Detail ownership.
- attack/battle handoff remains outside City Detail ownership.
- internal/external Trade calculation and execution remain owned by existing Trade components.
- `_setup_warehouse_card_ui` and actual left-status-panel warehouse node placement remain HUD/Common UI ownership for the later HUD track.
- `_apply_domestic_turn_mvp` remains Turn/Session orchestration.

## Visual and schema preservation

C-3 is an ownership refactor, not a redesign. Existing city-detail labels, ordering, resource/status wording, tab routing, colors, and visibility contracts are preserved. C-3 does not change city `resource_stock`, `storage`, governor, hero, recruitment, save, or player-state schemas.

## Tests added

`tests/scripts/test_worldmap_city_detail_presentation_extraction.gd` covers the extracted presentation boundary, including:

- resource/default rendering
- storage summary formatting
- recruitment success/failure presentation
- governor/recruitment request signaling
- absence of direct player/city runtime state access
- absence of recruitment/governor mutation ownership
- retention of external attack, hero-transfer, and Trade paths in main

The interrupted Codex session committed this test together with the C-3 production checkpoint. Full post-C-3 regression closure is performed separately after validator recognition.

## Main reduction

C-3 production diff for `worldmap_main.gd`:

- additions: 101
- deletions: 174
- net: -73 lines

C-1 through C-3 cumulative reduction from the T-4 baseline is approximately 264 lines (`15,592 -> ~15,328`).

## Final C-track classification

- A: City Administration wrappers/coordinators -> C-1 service
- B: City Resource/Production wrappers/coordinators -> C-2 service
- C: City Detail Presentation wrappers/coordinators -> C-3 controller
- D: Recruitment adapters -> existing M-1 Military ownership
- E: Hero/Occupation transfer tail -> intentionally retained outside C-track
- F: Trade adapters -> existing Trade ownership
- G: HUD/Common UI shell -> intentionally deferred
- H: Turn/Save/Session orchestration -> intentionally deferred
- I: non-trivial City Administration/Resource/Detail implementation remaining in main -> none identified; only cross-domain coordinators/adapters remain

## Next boundary

After C-1~C-3 validation closure, the next intended refactor track is HUD/Camera/WorldMap common UI. Legacy Hero/Occupation cross-domain tails and Turn/Save/Session orchestration remain separate later tracks.
