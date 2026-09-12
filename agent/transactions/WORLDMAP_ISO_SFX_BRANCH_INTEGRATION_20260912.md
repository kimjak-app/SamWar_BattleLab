# WorldMap / ISO battle / SFX integration — 2026-09-12

Status: STATIC VERIFIED / GODOT F6 REQUIRED

## Scope and authorization
Kimjak requested a new shared development branch while keeping WorldMap and battle test scenes separate. Existing branches and main are preserved. This is branch integration only; production scene promotion and new gameplay changes are outside this task.

## Sources
- WorldMap / SFX base: feature/samwar-sfx-integration @ 897b5f0ff2a7fff7376b1aa8924b80751d036901
- ISO / SFX parent: integration/imjin-iso-sfx @ 18fe82e6891ba58e89adb6224d8a7e19983e2b87
- Shared branch: integration/worldmap-iso-sfx-20260912

## Resolution
Use the WorldMap base for existing shared paths, except scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd, whose ISO-parent version preserves the runtime registry cache. Add all 25 ISO-only paths, including the ISO scene/scripts/UIDs, arrow PNGs/imports and existing workflow documents. No source path is deleted.

WorldMap changes retained include action-video and result presentation, five action OGVs, city action controls, turn-summary art/layout, SFX hooks, spy cost handling, and HUD variable warning fixes. WorldMap versions of CURRENT_STATE/CHANGELOG/SESSION_LOG retain all ISO-parent contents plus their later audio entries.

## Foreign-city action transaction follow-up
The foreign-city Diplomacy, Spy and Trade buttons now open their production control panels instead of emitting a video-only preview signal. `WorldMapActionCoordinator` owns the contextual target/source, presentation-pending state and single resolution boundary. `worldmap_main.gd` remains the public hub and delegates execution only after the action video finishes; diplomacy and spy return immediately after requesting presentation so their effects cannot be applied once before the video and again afterward. Resolution refreshes WorldMap state and feeds the existing result scroll.

Domain rules and calculations remain in their existing WorldMap functions in this transaction. Moving those rules into separate diplomacy/trade/spy services is intentionally deferred until this coordinator boundary has passed runtime F6 verification.

All binary assets are reused by their existing Git blob SHA. No image/audio/video is regenerated or re-encoded in the committed result. Shared battle controller, audio manager, game_session, production battle and existing battle-test scenes match both parents. No balance, save schema, scene entrypoint or gameplay behavior is newly designed by this merge.

## Entry points
- WorldMap standalone F6: res://WorldMap_16x9_Test.tscn
- ISO battle standalone F6: res://tests/scenes/Battle_UI_Production_Imjin_IsoMovement_Test.tscn
- SFX standalone F6: res://tests/scenes/SFX_Preview.tscn
- F5 remains NewGameFactionSelect -> WorldMap -> Battle_Land.
The two F6 scenes are developed independently in this shared branch. This does not promote the fixed Imjin demo roster into a live campaign.

## Verification
Source HEADs and complete recursive Git trees were retrieved. All 1,631 source blob paths are preserved; this document is one additional file. Text inspection and tests used verified source blob contents; 462 local source files were SHA-checked before validation.

PASS:
- validate_samwar_audio_settings.py
- validate_samwar_sfx.py (21 WAV format/amplitude checks and reproducibility; regeneration occurs only in a scratch verification copy, never in the commit)
- validate_single_side_exhaustion_turn_order.py
- validate_worldmap_to_battle_input_lifecycle.py
- validate_worldmap_contextual_action_transaction.py
- validate_imjin_d0_d1_worldmap_hero_integration.py
- Selected scene external-resource and ISO script preload/extends paths exist in the combined remote tree.
- Original F5 route, separate F6 scenes and registry cache are preserved.

NOT PASS / LIMITS:
- validate_t08_battle_scene_isolation.py fails in the partial local copy because many art/resources are not materialized, plus existing test Ally/Enemy momentum 10-slot expectations. The validator and the two scene files it checks are byte-identical in both source parents; they are not changed by this integration. Referenced resources were independently checked against the remote tree rather than fabricating local placeholders.
- No Godot executable is available, so no parser/import/scene-load/playback/listening or full game runtime PASS is claimed.
- Older 39-profile / 39-skill / momentum +1 validators remain inconsistent with current 44-hero / +2 data as recorded in the preceding audit. This merge does not change balance or those validators.

## Kimjak F6 review
1. Fetch origin and select integration/worldmap-iso-sfx-20260912; keep any uncommitted local changes on their original branch.
2. WorldMap_16x9_Test: select a foreign city and run Diplomacy, Spy and Trade through their production panels; check video, exactly one resource/state change, result scroll, refreshed HUD/panel state and System audio controls.
3. Battle_UI_Production_Imjin_IsoMovement_Test: check movement/facing, attack, unique-skill cutin, enemy turn and SFX.
4. Confirm both scenes can be selected in the same branch. Existing production F5 scene routing remains unchanged.
5. Record any runtime errors and screenshots; further corrections should be made on this shared branch.
