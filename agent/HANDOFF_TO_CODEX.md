# HANDOFF TO CODEX

## v0.70-7 Cutin OGV Video Fallback Handoff
- `v0.70-7 Cutin OGV Video Fallback` is complete for ally `yi_sunsin` only.
- `scripts/battle_web_import_test.gd` now selects Yi Sunsin cutin video candidates in priority order: `yi_sun_sin_cutin_bg.ogv`, `yi_sun_sin_cutin_bg.webm`, legacy spaced WebM compatibility candidate, then `yi_sun_sin_cutin_bg.mp4`.
- The selected existing candidate is logged with `[SPECIALTY_CUTIN] selected_video_candidate=...`; successful load logs `selected_video=...`; selected-candidate load failure logs `selected_video_load_failed=... fallback=png_text`.
- OGV existence now wins over WebM/MP4. If the OGV exists but cannot load as a Godot `VideoStream`, the video layer remains safe and the existing PNG/text cutin continues.
- The existing `VideoStreamPlayer_Cutin` node is reused and still stopped/cleared on start and hide, so repeat activation should restart from the beginning.
- The centered cutin banner/card layout from v0.70-6 remains unchanged.
- No unique-skill 판정, effect, damage, buff/debuff, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- 김작 F6 QA should confirm OGV visibility, centered banner/card composition, portrait/text fallback, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-8 Specialty Skill Cutin Visual Polish`
  - `v0.70-9 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-10 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-6 Cutin WebM Video Connection + Center Layout Fix Handoff
- `v0.70-6 Cutin WebM Video Connection + Center Layout Fix` is complete for ally `yi_sunsin` only.
- `scripts/battle_web_import_test.gd` now selects Yi Sunsin cutin video candidates in priority order: `yi_sun_sin_cutin_bg.webm`, actual repo file `Yi Sun Sin Cutin Bg.webm`, `yi_sun_sin_cutin_bg.ogv`, then `yi_sun_sin_cutin_bg.mp4`.
- The cutin video stream is stopped/cleared before assignment and stopped/cleared again on hide, so repeat activation should start from the beginning when a loadable stream is available.
- `BattleUI/SkillCutinLayer` remains scene-authored and reusable. `VideoStreamPlayer_Cutin` was changed to a free-positioned centered banner area so code can size it without full-anchor warnings.
- The Yi Sunsin cutin layout is now centered: the video/card rect is centered, the portrait is placed inside the central composition, hero/skill text is center-aligned, and the animation uses center scale/fade instead of lateral slide.
- Kwon Yul and Jeong Do Jeon WebM assets are present in repo as `Kwon Yul Cutin Bg.webm` and `Jeong Do Jeon Cutin Bg.webm`. Their activation wiring remains deferred.
- Godot headless load did not create tracked `.import` files for WebM assets. If F6 still does not display video, the remaining risk is Godot runtime WebM import/playback support; fallback PNG/text cutin still runs.
- No unique-skill 판정, effect, damage, buff/debuff, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm WebM visibility, centered banner/card composition, portrait/text placement, 3-second pacing, post-cutin effect continuation, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-7 Specialty Skill Cutin Visual Polish`
  - `v0.70-8 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-9 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-5 Specialty Skill Video Cutin MVP Handoff
- `v0.70-5 Specialty Skill Video Cutin MVP` is complete for ally `yi_sunsin` only.
- `Battle_Fullscreen_Test.tscn` now has a reusable scene-authored `BattleUI/SkillCutinLayer` with `ColorRect_Darken`, `VideoStreamPlayer_Cutin`, `TextureRect_Slash`, `TextureRect_Hero`, `Control_Text/Label_HeroName`, `Control_Text/Label_SkillName`, and `AnimationPlayer_Cutin`.
- `scripts/battle_web_import_test.gd` routes ally Yi Sunsin unique-skill presentation through the new 3-second specialty cutin and schedules the existing unique-skill effect after the cutin duration.
- The effect path remains the existing `_apply_unique_skill_effect_if_valid` / `_apply_unique_skill_effect` flow; only presentation timing changes for Yi Sunsin.
- The transparent portrait asset is `res://assets/ui/cutin/portraits/yi_sun_sin_cutin.png`.
- The mp4 asset path is `res://assets/ui/cutin/videos/yi_sun_sin_cutin_bg.mp4`. The file exists, but no imported Godot VideoStream metadata was found, so runtime code logs and continues with portrait/text cutin if ResourceLoader cannot load the mp4. `ogv` or `webm` remains a likely follow-up for real video playback.
- Non-Yi-Sunsin heroes continue to use the existing unique-skill toast/cutin flow. If the Yi Sunsin layer or portrait is missing, the old toast fallback is used.
- A busy guard prevents overlapping specialty cutins.
- No battle rules, movement/attack 판정, damage formulas, buff/debuff effects, AI, results, woundedQueue, prisoner/death, battle overlay, camera, pop wave, direction-selection, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm actual mp4 playback or fallback behavior, cutin impact, 3-second pacing, portrait placement, text readability, effect continuation after cutin, no soft lock, and normal battle flow.
- Next candidates:
  - `v0.70-6 Specialty Skill Cutin Visual Polish`
  - `v0.70-7 Add Kwon Yul and Jeong Do Jeon Cutins`
  - `v0.70-8 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-4 Battle Overlay Rollback Shape + Palette Retune Handoff
- `v0.70-4 Battle Overlay Rollback Shape + Palette Retune` is complete in `scripts/battle_web_import_test.gd`, `scripts/battle_range_overlay_tile.gd`, and `scripts/battle_facing_arrow_tile_button.gd`.
- Camera zoom remains unchanged at the v0.70-2/v0.70-3 value `Vector2(0.84, 0.84)`; this pass did not touch camera framing.
- Default play still hides the logical grid guide; `SHOW_LOGICAL_GRID_14X8_GUIDE` remains `false`.
- The successful v0.70-3 pop wave reveal is preserved, including distance-based delay, smaller starting scale, stronger overshoot, settle scale, tween cleanup, and quick cancel behavior.
- The v0.70-3 center-fade/internal band rendering was removed from range overlays so cells read as one clean octagonal tile rather than stacked inner octagons.
- Movement range was retuned to a clearer blue tactical color. Attack range, single-target, multi-target/unique-skill, and strategy overlays remain visually distinct.
- Direction-selection arrow buttons keep the octagonal tile draw script and short pop reveal, but their color is restored to the gold/yellow direction-selection role instead of movement blue.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm pop wave retention, no stacked internal octagons, v0.70-2-like simple octagonal tile shape, better movement blue, role-color separation, restored direction-selection color, and click feel.
- Next candidates:
  - `v0.70-5 Battle Overlay Fine Color Tuning`
  - `v0.70-6 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-3 Battle Overlay Palette + Pop Wave Polish Handoff
- `v0.70-3 Battle Overlay Palette + Pop Wave Polish` is complete in `scripts/battle_web_import_test.gd`, `scripts/battle_range_overlay_tile.gd`, and `scripts/battle_facing_arrow_tile_button.gd`.
- Camera zoom remains at the v0.70-2 value `Vector2(0.84, 0.84)`; this pass did not further adjust camera framing.
- Default play still hides the logical grid guide; `SHOW_LOGICAL_GRID_14X8_GUIDE` remains `false`.
- Overlay colors remain type-distinct but are now toned down: movement steel blue-gray, attack coral/rose red, single-target toned amber, multi-target muted violet, and strategy subdued teal.
- Range tile rendering now uses edge-band center-fade instead of a clear small inner octagon, keeping a visible tactical outline while allowing terrain to show through the tile center.
- Pop wave reveal is stronger than v0.70-2: delay is `0.06s` per grid distance, cells start smaller, overshoot more strongly, and settle back to `1.0`.
- Direction selection arrow buttons now get a matching octagonal tile draw script and a short pop reveal, while preserving the existing Button click paths.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm distinct-but-cohesive palette, reduced sky-blue/casual feel, center-fade interior, terrain visibility, visible unit-centered pop wave, near/far pop strength, direction tile unification, and click feel.
- Next candidates:
  - `v0.70-4 Battle Overlay Fine Color Tuning`
  - `v0.70-5 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-2 Battle Overlay Shape + Wave Tuning Handoff
- `v0.70-2 Battle Overlay Shape + Wave Tuning` is complete in `Battle_Fullscreen_Test.tscn`, `scripts/battle_web_import_test.gd`, and `scripts/battle_range_overlay_tile.gd`.
- `MainCamera` default zoom is now `Vector2(0.84, 0.84)`. The camera position remains scene-authored.
- Default play still hides the logical grid guide; `SHOW_LOGICAL_GRID_14X8_GUIDE` remains `false` for normal play and available as a future debug flag.
- Range overlays still use the existing `MoveRangeOverlayLayer` ColorRect pool. Each cell now receives a lightweight `BattleRangeOverlayTile` draw script at runtime.
- The tile draw script renders clipped-corner octagonal cells with low-alpha fill, softer inner fill, clear outline, and subtle inner highlight. No external assets were added.
- Movement tiles use blue styling; attack tiles use red/orange-red styling. Unique skill and strategy overlays share the same tactical tile renderer for consistency.
- Wave/stagger reveal is now stronger: `0.04s` delay per Manhattan distance, scale `0.86 -> 1.04 -> 1.0`, and alpha `0 -> 1`.
- Existing overlay hide paths still kill active range tweens before hiding cells, so quick cancel/selection changes should not leave delayed ghost overlays.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed with clean warning/error output.
- 김작 F6 QA should confirm zoom `0.84` feel, background visibility, unit size, octagonal tile read, outline strength, alpha/terrain visibility, wave direction/timing, direct move click, attack click, right-click cancel, floating command panel, and turn/auto flow.
- Next candidates:
  - `v0.70-3 Battle Overlay Visual Fine Tuning`
  - `v0.70-4 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.70-1 Battle Visual Detail Polish Start Handoff
- `v0.70-1 Battle Visual Detail Polish Start` is complete in `Battle_Fullscreen_Test.tscn` and `scripts/battle_web_import_test.gd`.
- Default play no longer shows the logical grid guide. The debug flag `SHOW_LOGICAL_GRID_14X8_GUIDE` remains available for future development use.
- `MainCamera` default zoom is `Vector2(0.88, 0.88)`, preserving the scene-authored camera position while showing more of the 3200x1800 battlefield art.
- Movement and attack overlays continue to reuse the existing `MoveRangeOverlayLayer` cell pool; movement is blue, attack is red, and cells are inset from full-cell bounds.
- Overlay presentation now animates from the selected/casting unit outward using short distance-based staggered alpha/scale tweens.
- Overlay hide paths clear active range tweens before hiding cells, preventing stale/ghost overlay nodes after cancel, movement, attack, strategy, or skill transitions.
- No battle rules, move/attack 판정, damage formulas, AI, results, woundedQueue, prisoner/death, or WorldMap UX logic was intentionally changed.
- Headless project load and `Battle_Fullscreen_Test.tscn` load passed. Manual F6 QA remains for camera feel, background readability, unit size, overlay visual taste, wave timing, right-click cancel, direct move click, attack click, floating command panel, and turn/auto flow.
- Next candidates:
  - `v0.70-2 Battle Overlay Visual Tuning`
  - `v0.70-3 WorldMap Final IA Blueprint + Panel Skeleton`

## v0.69-14A GDScript Reload Warning Cleanup Handoff
- `v0.69-14A GDScript Reload Warning Cleanup Before v0.70` is complete in `scripts/worldmap_test.gd`.
- This pass only cleaned Godot GDScript reload warnings before `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- No strategic logic, formulas, balance values, save/load structure, battle, invasion, diplomacy, espionage, tech, trade, or resource behavior was intentionally changed.
- The next task remains `v0.70-1 WorldMap Final UX/UI Information Architecture`.

## v0.69-14 EASTWAR Strategic Logic Final Checkpoint Handoff
- Start any new chat/session from this baseline unless the user explicitly provides a newer commit:
  - `v0.69-13 Espionage Action Foundation MVP`
  - Commit: `0565f2d5f0acfde609e9df9e96d8e3b25726196c`
- v0.69 strategic simulation logic is now considered complete enough for the next phase.
- The next task should be `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- v0.70 should begin with information structure and UX/UI design, not additional strategic logic.
- The first priority is to decide how the v0.69 systems should be exposed, grouped, summarized, and operated in the WorldMap UI.
- During UI work, if behavior looks wrong, first isolate whether it is a display/state-binding issue or an actual v0.69 logic bug.
- Modify v0.69 logic only when F6 manual validation identifies a clear bug; keep those fixes minimal and scoped.
- Existing City Detail / WorldMap UI is temporary and should not be treated as final UX.
- High-risk systems still deferred beyond UI foundation: real revolt, neutral owner conversion, suppression battle, assassination, actual allied military support troop movement, and joint invasion.

## v0.69-13 Espionage Action Foundation Handoff
- `v0.69-13 Espionage Action Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- The requested guide file `GUIDE_v0.69_12_13_to_v0.70.md` was not found in the repo; implementation followed the explicit v0.69-13 task requirements.
- Added helper/API actions: `_disrupt_city_loyalty`, `_instigate_revolt`, and `_drive_wedge`, with matching validation and forced-roll helpers for QA.
- Loyalty disruption directly lowers city loyalty for this MVP. It does not create pending seasonal loyalty penalties.
- Revolt instigation records `_player_state["revolt_instigation"][city_id]` for 3 turns with a `probability_boost`; it does not cause revolt, neutralization, battle, or owner changes.
- Wedge driving lowers relation score between two allied non-player factions only. It does not auto-break alliance status.
- Detection penalties change relation scores only: loyalty disruption `-40`, revolt instigation `-60`, wedge detection `-20` against each target faction from the player.
- All spy actions reuse shared `spy_cooldown`. The existing primary political chancellor cooldown `-2` policy is applied to new actions.
- Not implemented: assassination, real revolt, suppression battle, war declaration, automatic hostile conversion, alliance break, espionage UI, battle/invasion/defense changes, or save/load core rewrites.
- v0.69 is ready to pivot toward `v0.70-1 WorldMap Final UX/UI Information Architecture`.
- Remaining risks: action values are MVP balance; all actions are API-only; revolt boost has no real revolt consumer yet.

## v0.69-12 Diplomacy Action Foundation Handoff
- `v0.69-12 Diplomacy Action Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- The requested guide file `GUIDE_v0.69_12_13_to_v0.70.md` was not found in the repo; implementation followed the explicit v0.69-12 task requirements.
- Added API/helper actions: `_propose_alliance`, `_request_military_support`, and `_propose_trade_agreement`.
- Alliance proposal is deterministic for MVP QA: acceptance chance is relation score + resource-package bonus, clamped to `0..95`; accepted at `>= 70`.
- Alliance proposal pays the provided resource package on attempt. On success it sets relation `status` to `allied` and records `alliance_turns_remaining`.
- Military support requires `allied`; success/failure is recorded only. Do not infer troop movement, joint invasion, battle support, or defense support from this helper.
- Military support rejection applies relation score `-20`; third and later repeated rejection applies `-40`.
- Trade agreement requires relation score `>= 50`, costs `gold 200 + silk 50`, records a 20-turn agreement, and adds `+0.15` to Phase A route relation multiplier via `_get_trade_agreement_bonus_multiplier`.
- Phase A base status multipliers remain unchanged. The trade agreement bonus is additive and separate from `RELATION_TRADE_MULTIPLIER`.
- Not implemented: war declaration, actual military support troop transfer, joint invasion, alliance/trade duration expiry, diplomacy UI, trade transaction execution, or save/load core rewrites.
- Remaining risks: deterministic diplomacy acceptance needs balance review; recorded durations currently do not tick down; final F6 diplomacy UX remains future work.

## v0.69-11B Espionage Public Support Disrupt Handoff
- `v0.69-11B Espionage Public Support Disrupt MVP` is implemented in `scripts/worldmap_test.gd`.
- This is the first offensive espionage action and only affects target city publicSupport.
- Cost is fixed: `gold 300`.
- Effect amount by political aptitude: `5 -> 20`, `4 -> 15`, `3 -> 10`, `2 -> 5`, `1 -> 3`.
- The action uses shared `spy_cooldown`: base `8`, primary political chancellor `6`.
- If detected, effect is canceled and relation score receives `-30` with reason `spy_public_support_disrupt_detected`.
- Detection does not auto-change relation status, declare war, trigger revolt, or change city owner.
- Do not add loyalty disruption, revolt instigation, alienation, assassination, or real revolt unless a future task explicitly scopes it.
- Not implemented: espionage UI, diplomacy status conversion, war declaration, battle/invasion/defense changes, or save/load core rewrites.
- Next candidates: `v0.69-11C Espionage Detection Penalty Audit` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no UI trigger exists; detection penalty only changes score; disruption balance needs later review.

## v0.69-11 Espionage Info Gathering Handoff
- `v0.69-11 Espionage Info Gathering MVP` is implemented in `scripts/worldmap_test.gd`.
- Espionage subject is the current chancellor. If no chancellor is assigned, info gathering is unavailable.
- Political aptitude is read from existing chancellor hero data. Primary political type gives detection `-10` and cooldown `-2`.
- Success chance table: aptitude `5 -> 80`, `4 -> 65`, `3 -> 50`, `2 -> 35`, `1 -> 20`.
- Visibility table: aptitude `5` shows troops/resources/publicSupport/loyalty/governor/tech; `4` shows troops/resources/publicSupport/loyalty; `3` shows troops/resources; `2` shows troops; `1` shows deterministic troop estimate.
- `_roll_spy_info_result()` supports forced rolls for deterministic tests. `_gather_spy_info()` records result and payload.
- Detection is recorded only. Do not add relation penalties, status changes, war, or revolt effects unless explicitly scoped.
- Spy cooldown is `_player_state["spy_cooldown"]`: base `6`, primary political chancellor `4`.
- Not implemented: publicSupport disruption, loyalty disruption, revolt instigation, alienation, assassination, espionage UI, alliance/trade agreement, or war declaration.
- Next candidates: `v0.69-11B Espionage Public Support Disrupt MVP` or `v0.69-10C Alliance War Status Foundation MVP`.
- Remaining risks: no player-facing espionage trigger exists; detection penalty is deferred; target national/city tech visibility is constrained by existing data structures.

## v0.69-10B Tribute Diplomacy Action Handoff
- `v0.69-10B Tribute Diplomacy Action MVP` is implemented in `scripts/worldmap_test.gd`.
- Tribute is the first diplomacy action and is currently helper/API only.
- Cost is fixed for MVP: `gold 300` + `silk 100`.
- Relation gain is fixed for MVP: deterministic `+20`, clamped by existing score bounds.
- Tribute rejects invalid/self targets, `hostile`, `suspended`, active `tribute_cooldown`, and insufficient resources.
- Tribute uses separate `tribute_cooldown`, not the existing relation `cooldown`; this avoids collision with Phase A trade/suspended-status behavior.
- Domestic turn decreases `tribute_cooldown` once per world turn through `_advance_diplomacy_cooldowns_for_world_turn()`.
- Status must not auto-convert to allied or hostile from tribute score changes.
- Phase A trade remains status-based. Do not make score or tribute affect trade income without a scoped future task.
- Not implemented: alliance proposal, trade agreement, declaration of war, espionage, revolt instigation, specialty trade execution, AI response, or diplomacy UI.
- Next candidates: `v0.69-10C Alliance War Status Foundation MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: no player-facing trigger exists; fixed cost/gain need balance review; no diplomatic response/AI behavior exists.

## v0.69-10 Diplomacy Relation Score Handoff
- `v0.69-10 Diplomacy Relation Score MVP` is implemented in `scripts/worldmap_test.gd`.
- `faction_relations` entries now normalize to `{"status": String, "score": int, "cooldown": int}`.
- Score is clamped to `0..100`; missing scores default to `50`.
- `relation_band` is derived from score only: `friendly >=70`, `neutral 31..69`, `hostile <=30`.
- `status` and `relation_band` are separate. Do not auto-convert `friendly` to `allied` or `hostile` band to `hostile` status without a scoped diplomacy-action task.
- Phase A trade remains status-based. `RELATION_TRADE_MULTIPLIER` and the trade income formula should remain unchanged unless explicitly scoped.
- Trade routes may carry `relation_score` and `relation_band` as display/debug fields; they must not affect income.
- Current result fields: `_player_state["last_diplomacy_relation_result"]` and `_player_state["last_diplomacy_normalize_result"]`.
- Not implemented: tribute, trade agreements, alliance proposal/acceptance, declaration of war, espionage, revolt instigation, specialty trade execution, or diplomacy UI.
- Next candidates: `v0.69-10B Tribute Diplomacy Action MVP` or `v0.69-11 Espionage Info Gathering MVP`.
- Remaining risks: relation score has no gameplay action consumer yet; normalization initializes all known city-owner faction pairs; final F6 diplomacy UX remains future work.

## v0.69-9 Trade Market Price Handoff
- `v0.69-9 Trade Deepening Data Market Price MVP` is implemented in `scripts/worldmap_test.gd`.
- This is a data/calculation/recording layer only. It must remain separate from existing Phase A inter-faction trade income.
- New market result field: `_player_state["last_trade_market_result"]`.
- Result structure includes `turn`, `season`, `season_label`, `context`, and `prices`; each price entry includes `name`, `base_price`, `season_multiplier`, `situation_multiplier`, `price`, and `trend`.
- Current market context defaults: `war_state=false`, `famine=false`, `abundant_harvest=false`, `alliance_recently_signed=false`; `supply_isolated_count` is pulled from the current/last supply result when available.
- The calculation is deterministic. Do not add random price volatility until a focused follow-up.
- Existing Phase A trade income and `last_inter_faction_trade_result` are not replaced and should not be reshaped by market-price work.
- Not implemented: manual trade, resource exchange execution, trade agreements, diplomacy, maritime trade, pirate losses, hero trade traits, and trade UI.
- Next candidates: `v0.69-9B Specialty Trade Data MVP` or `v0.69-10 Diplomacy Relation Score MVP`.
- Remaining risks: market prices have no transaction consumer yet; situation context depends on future event/diplomacy systems; F6/manual UX validation is deferred to later UI work.

## v0.69-8B Tech Effect Application Handoff
- `v0.69-8B Tech Effect Application MVP` is implemented in `scripts/worldmap_test.gd`.
- Effects apply from completed tech only. In-progress tech has no effect.
- One-time effect: `legal_reform` applies publicSupport `+5` to all player-owned cities once. Duplicate prevention is stored in `_player_state["applied_tech_effects"]["national"]["legal_reform"]`.
- Continuous income effects: `tax_reform` gives domestic gold income `x1.10`; `street_market` gives city domestic gold income `x1.05`. These do not affect inter-faction trade income.
- Conscription effects: completed city `barracks` is now required for automatic conscription. Completed national `conscription_system` changes only turnly automatic conscription add by `x1.10`, capped by available amount. Capacity is unchanged.
- Recognized but no consumer yet: `national_foundation`, `improved_farming_tools`, and `fishing_village`.
- `last_tech_effect_result` records applied effects and no-consumer recognized effects.
- Do not assume battle/special-unit/diplomacy/revolt/trade-deepening effects exist. Those are not implemented.
- No tech UI or auto tech selection exists yet.
- Next candidate is `v0.69-9 Trade Deepening MVP`.
- Remaining risks: barracks gating changes automatic conscription balance; most tech effects are still pending; no final F6 UX validation exists.

## v0.69-8 Tech Start Progress Pipeline Handoff
- `v0.69-8 Tech Start Progress Pipeline MVP` is implemented in `scripts/worldmap_test.gd`.
- National and city tech can now start, pay costs, enter `in_progress`, advance by domestic world turns, and migrate to `completed`.
- Use `_start_national_tech(tech_id)` and `_start_city_tech(city_id, tech_id)` for starting tech. Both require `_can_start_*` to pass and deduct cost on success.
- Use `_advance_national_tech_progress_for_world_turn()` and `_advance_city_tech_progress_for_world_turn()` for per-turn progress. The domestic turn pipeline already calls both after revolt warning.
- `_get_tech_duration_turns(tier)` provides MVP defaults: basic `4`, mid `9`, advanced `18`, capstone `28`, rare `30`. Definition `duration_turns` overrides this if added later.
- Generic cost helpers support `food` as rice+barley+seafood pool, deducted in order `rice -> barley -> seafood`.
- Completed entries include `effect_summary` and `effect_applied: false`.
- Do not assume effects exist. No national/city tech effect is applied yet.
- No UI or automatic tech selection exists. Start calls are helper/API only until a later UI/task explicitly wires player choices.
- Existing publicSupport, loyalty, recruitment, revolt, trade, supply, troop movement, battle, invasion, defense, and save/load core behavior must remain untouched unless explicitly scoped.
- Superseded by `v0.69-8B`: first Tech Effect Application MVP is implemented.
- Remaining risks: no player-facing selection UI, no effect application, no automatic selection, and several placeholder conditions still block advanced techs.

## v0.69-7A Tech Data Consistency Audit Handoff
- `v0.69-7A National City Tech Data Consistency Audit` is complete in `scripts/worldmap_test.gd`.
- `_validate_tech_data_consistency()` audits national/city tech definitions only. It must remain QA/debug-only unless a future task explicitly scopes runtime use.
- The audit checks `required_national_tech`, city and national `requires`, allowed cost keys, allowed aptitude/governor/chancellor types, `icon_path` / `image_path`, and placeholder condition keys.
- `logistics_system` / `병참 제도` now exists as a national tech so `dried_fish_supply_base` no longer points to a missing national tech ID.
- National tech definitions now include `icon_path` and `image_path` as empty-string placeholders. Do not load images or add UI unless explicitly scoped.
- Placeholder conditions still block and must not be auto-passed: `chancellor_type_turns`, `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, `has_hero_yi_sunsin`, `has_city_tech_mint`, `has_silkroad_or_trade_port`, `neutral_faction_count`, and `allied_faction_count`.
- `food` is still an MVP cost key for the rice+barley+seafood food pool. No cost deduction exists in this audit.
- Superseded by `v0.69-8`: Tech Start/Progress Pipeline MVP is implemented.
- Remaining risks: `connected_supply_city_count` needs a real source later; `maritime` is an allowed type but no dedicated hero data source is wired yet; no tech lifecycle, effects, UI, or final F6 UX validation exists.

## v0.69-7 City Tech Tree Data Handoff
- `v0.69-7 City Tech Tree Data MVP` is implemented in `scripts/worldmap_test.gd`.
- Scope is data/state/check helpers only. No UI, start, cost deduction, turn progress, completion, effect application, or governor auto-selection exists yet.
- City tech definitions are returned by `_get_city_tech_definitions()`.
- Definition records include `icon_path` and `image_path` as empty-string placeholders for later tech UI image connection. Do not load images or add UI in follow-up logic tasks unless explicitly scoped.
- Per-city state is `city_tech = {"completed": {}, "in_progress": {}, "available_cache": {}}`, normalized by `_ensure_city_tech_state(city_id)`.
- Use `_check_city_tech_requirements(city_id, tech_id)`, `_can_pay_city_tech_cost(city_id, tech_id)`, and `_can_start_city_tech(city_id, tech_id)` for validation.
- `_start_city_tech(city_id, tech_id)` is intentionally a no-op skeleton returning `false`; it only records `last_city_tech_start_check`.
- Food cost is checked as the existing rice+barley+seafood pool. No cost is deducted in this MVP.
- City tech and national tech are separate. Advanced city tech may require completed national tech through `required_national_tech`.
- Placeholder conditions must not pass automatically: `governor_type_turns`, `food_surplus_turns`, `connected_supply_city_count`, and `has_hero_yi_sunsin`.
- Maritime governor requirements currently fail unless a future hero/runtime entry explicitly provides `maritime`; no new hero data model was added.
- Superseded by `v0.69-7A`: National/City tech data consistency audit is complete.
- Next candidate is `v0.69-8 Tech Start/Progress Pipeline MVP`.
- Remaining risks: placeholder conditions block advanced branch techs until supporting systems exist; no research lifecycle, effect application, UI, or final F6 UX validation exists yet.

## v0.69-6 National Tech Tree Data Handoff
- `v0.69-6 National Tech Tree Data MVP` is implemented in `scripts/worldmap_test.gd`.
- Scope is data/state/check helpers only. No UI, start, cost deduction, turn progress, completion, or effect application exists yet.
- National tech definitions are returned by `_get_national_tech_definitions()`.
- Player state is `_player_state["national_tech"] = {"completed": {}, "in_progress": {}, "available_cache": {}}`, normalized by `_ensure_national_tech_state()`.
- Use `_check_national_tech_requirements(tech_id)`, `_can_pay_national_tech_cost(tech_id)`, and `_can_start_national_tech(tech_id)` for validation.
- `_start_national_tech(tech_id)` is intentionally a no-op skeleton returning `false`; it only records `last_national_tech_start_check`.
- Food cost is checked as the existing rice+barley+seafood pool. No cost is deducted in this MVP.
- Placeholder conditions must not pass automatically: `chancellor_type_turns`, `allied_faction_count`, `neutral_faction_count`, `has_city_tech_mint`, and `has_silkroad_or_trade_port`.
- Superseded by `v0.69-7`: City Tech Tree Data MVP is implemented. Keep national tech and city tech separate.
- Next candidates are `v0.69-8 Tech Start/Progress Pipeline MVP` or `v0.69-6B National Tech Start/Progress MVP`.
- Remaining risks: placeholder conditions block later branch techs until supporting systems exist; no research lifecycle, effect application, or UI exists yet.

## v0.69-5 Revolt Warning Handoff
- `v0.69-5 Revolt Warning Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- Revolt warning is a read-only calculation over current city `publicSupport` and `loyalty`.
- Risk states are exactly `stable`, `warning`, and `danger`.
- `warning` means both publicSupport and loyalty are `<= 40`.
- `danger` means both publicSupport and loyalty are `<= 30`.
- `_calculate_city_revolt_risk(city_id)` returns the per-city risk payload. `_apply_revolt_warning_check_for_world_turn()` scans player-owned cities and records `last_revolt_warning_result`.
- Domestic turn runs revolt warning after publicSupport drift, city loyalty drift, seasonal loyalty, and conscription so the check reads current values.
- This MVP does not trigger revolts, does not change owner to neutral, does not create suppression battles, and does not integrate espionage revolt agitation.
- Map markers, icon/color UX, and final UI are deferred to later UI work. Current City Detail text is temporary minimal display.
- PublicSupport, loyalty, conscription/recruitment, troop movement, P0-1/P0-2/Phase A/Phase B, battle, and save/load formulas/cores must remain untouched unless a future task explicitly scopes them.
- Superseded by `v0.69-6`: National Tech Tree Data MVP is implemented.
- Remaining risks: warning-only foundation, no actual event lifecycle, no espionage integration, no map warning UI, and no final F6 UX validation yet.

## v0.69-4 Recruitment/Conscription Handoff
- `v0.69-4 Recruitment/Conscription Foundation MVP` is implemented in `scripts/worldmap_test.gd`.
- Conscription is loyalty-based. Use `_get_conscription_capacity_by_loyalty(city_id)` and `_get_city_conscription_available(city_id)` for capacity/available calculations.
- Automatic conscription is slow and free: `_apply_city_conscription_for_world_turn()` runs after publicSupport drift, existing city loyalty drift, and seasonal loyalty from publicSupport in the domestic turn, then adds `min(available, 100)` troops.
- Conscription does not reduce population and does not directly change publicSupport or loyalty.
- Recruitment is publicSupport-based. Use `_get_recruitment_limit_by_public_support(city_id)`, `_calculate_recruitment_cost(amount)`, `_can_recruit_troops(city_id, amount)`, and `_recruit_troops(city_id, amount)`.
- Recruitment is immediate and paid, but currently helper/API only. Do not assume a final UI exists.
- Recruitment cost is `gold = amount` and `food = amount / 2`; MVP food payment uses national `resource_stock` in order `rice -> barley -> seafood`.
- Recruitment does not reduce population, does not directly change publicSupport or loyalty, and does not implement fatigue/publicSupport decline yet.
- Current City Detail output is a temporary minimal display. Real F6 mouse-based UX verification belongs with the June City Detail/WorldMap UI overhaul.
- Superseded by `v0.69-5`: revolt warning foundation is implemented.
- Remaining risks: no explicit recruitment UI, MVP national food-pool payment, no population/fatigue effects, and no final UX validation yet.

## v0.69-3A Strategic Logic Checkpoint Handoff
- `v0.69-3A Strategic Logic Checkpoint Documentation` is documentation-only. No code or formulas were changed.
- v0.69-1 through v0.69-3 are complete as the first strategic logic foundation block:
  - `publicSupport` changes through domestic stability.
  - `publicSupport` affects city `loyalty` on seasonal turns.
  - Current city `loyalty` controls troop movement loss.
- Treat the strategic chain `publicSupport -> seasonal loyalty -> troop movement efficiency/loss` as the locked v0.69 foundation unless a later task explicitly reopens balance.
- Current validation coverage is headless/API-oriented. Do not treat the temporary City Detail surfaces as final UX validation.
- Real F6 mouse-based UX verification should be performed during the June city information panel and WorldMap UX/UI redesign phase.
- Current City Detail UI is a minimal temporary display/connection surface. Avoid polishing it as final UI before the planned redesign.
- Superseded by `v0.69-4`: recruitment/conscription foundation is implemented. Manual UX verification for v0.69-1 through v0.69-4 should still be revisited alongside the later UI overhaul.

## v0.69-3 Troop Move Loyalty Efficiency Handoff
- `v0.69-3 Troop Move Loyalty Efficiency Final Patch` is implemented in `scripts/worldmap_test.gd`.
- C1 manual troop movement now uses the final source-city loyalty efficiency formula instead of total preservation.
- Movement formula is locked: all `commanded_amount` troops depart, `arrived_amount = floor(commanded_amount * from_loyalty / 100.0)` arrive, and `lost_amount` is recorded as movement loss.
- `_can_move_troops` still validates against the commanded amount, including the minimum source-garrison guard.
- `last_troop_move_result` records commanded/departed/arrived/lost/from_loyalty plus source/destination after values; `amount` remains for compatibility.
- C2 approval still goes through `_apply_troop_rebalance_suggestion()` -> `_move_troops()`, so C2 receives the same loyalty-based loss automatically. Do not add C2 automatic execution or a separate direct-write path.
- `publicSupport` is not a direct troop movement input. Movement uses current city loyalty, which may already include seasonal publicSupport effects from v0.69-2.
- Superseded by `v0.69-4`: recruitment/conscription foundation is implemented.
- Remaining risks: minimal movement UI still lacks explicit target/amount controls, and manual F6 visual QA remains useful for display copy.

## v0.69-2 Seasonal Loyalty Handoff
- `v0.69-2 Seasonal Loyalty From Public Support MVP` is implemented in `scripts/worldmap_test.gd`.
- Public support remains a separate fast-changing domestic stability axis; loyalty remains the slower military-operation axis.
- Seasonal loyalty bridge applies only on `turn_number % 10 == 0`, matching the current 10-turn season calendar and current domestic-apply-before-turn-advance flow.
- Current domestic turn order: publicSupport drift -> existing P0-2 city loyalty drift -> seasonal loyalty from publicSupport.
- Existing P0-2 city loyalty drift was not removed, replaced, or merged into publicSupport.
- Seasonal publicSupport thresholds are locked for this MVP: `90+ +2`, `80+ +1`, `60..79 -1`, `40..59 -2`, `0..39 -3`.
- Payroll/gold surplus and equipment surplus loyalty factors are not implemented yet; leave them for a later focused pass.
- Superseded by v0.69-3 for the next military-operation consumer of current loyalty.
- Remaining risks: minimal UI display only; seasonal bridge is publicSupport-only and does not yet include payroll/equipment/supply seasonal modifiers beyond the existing P0-2/supply systems.

## v0.69-1 Public Support MVP Handoff
- `v0.69-1 Public Support MVP` is implemented in `scripts/worldmap_test.gd`.
- `publicSupport` is a separate city runtime value from existing `loyalty` / `cityLoyalty`. Do not merge, rename, or replace loyalty with public support.
- Existing P0-2 city loyalty drift remains active and separate. This v0.69-1 note is superseded by v0.69-2, where publicSupport is seasonally reflected into loyalty.
- `publicSupport` defaults to `70`, clamps `0..100`, saves/loads through the existing city runtime payload, and records turn output in `_player_state["last_public_support_result"]`.
- Domestic turn order now applies public support drift after income/upkeep/trade resource application and before national/city loyalty drift. This is intentionally non-coupled for v0.69-1.
- Next task after v0.69-2 should be `v0.69-3 Troop Move Loyalty Efficiency Final Patch`.
- Remaining risks: the MVP food/commerce checks use current `resource_stock` plus recent domestic/trade result fallback, not a complete city-level economy model; UI display is minimal.

## v0.69-0 Roadmap Handoff
- `v0.69` is not a simple feature-addition track. It is the start of the EASTWAR strategic simulation foundation.
- Build beyond the existing web-version MVP depth. The v0.68b baseline is closed at `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` / commit `aec588b`.
- Public support, loyalty, and security are the central axes for national operation, troops, revolt pressure, tech progression, diplomacy, and espionage.
- Do not build final UI first. Implement the v0.69 strategic logic foundations first, then perform final WorldMap UX/UI information architecture in `v0.70-1`.
- `_incoming_confirmed_designs/` is a temporary input staging folder and is not a commit target.
- The current official `agent/CONFIRMED_*` documents have been replaced with the latest incoming confirmed designs for v0.69.
- Confirmed design documents now live in `agent/`:
  - `CONFIRMED_LOYALTY_PUBLICSUPPORT_DESIGN.md`
  - `CONFIRMED_NATIONAL_TECHTREE_DESIGN.md`
  - `CONFIRMED_CITY_TECHTREE_DESIGN.md`
  - `CONFIRMED_TRADE_SYSTEM_DESIGN.md`
  - `CONFIRMED_DIPLOMACY_ESPIONAGE_REVOLT.md`
- Next implementation order:
  1. `v0.69-1 Public Support MVP`
  2. `v0.69-2 Seasonal Loyalty From Public Support MVP`
  3. `v0.69-3 Troop Move Loyalty Efficiency Final Patch`
  4. `v0.69-4 Recruitment/Conscription Foundation MVP`
  5. `v0.69-5 Revolt Warning Foundation MVP`
  6. `v0.69-6 National Tech Tree Data MVP`
  7. `v0.69-7 City Tech Tree Data MVP` - complete
  8. `v0.69-8 Trade Deepening MVP`
  9. `v0.69-9 Diplomacy/Espionage Foundation MVP`
  10. `v0.70-1 WorldMap Final UX/UI Information Architecture`

## Latest Patch Note
- `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions` implements Phase C C2 as pure suggestion calculation only.
- No UI, suggestion cards, automatic redistribution, direct troop writes, resource changes, battle changes, save/load core rewrites, or C1 validation formula changes were implemented.
- `HANDOFF_P2C2_REBALANCE_SUGGESTIONS.md` was not found in the repo; implementation followed the explicit task text. `ROLE_TARGET_GARRISON_RATIO` was absent and was added minimally for the requested target-garrison formula.
- Added `_calculate_troop_rebalance_suggestions()`: reads existing Phase B supply states, builds `hub/rear` surplus suppliers and `frontline` shortage demands, processes larger shortages first and larger surplus suppliers first, validates candidates with `_can_move_troops`, stores `last_troop_rebalance_suggestions`, and returns the array.
- Added `_apply_troop_rebalance_suggestion(suggestion)`: extracts `from`, `to`, and `amount`, then delegates to C1 `_move_troops`. C2 does not call `_set_city_runtime_troops`.
- QA confirmed start-state 0 suggestions, crafted multi-city suggestion generation, all suggestions passing `_can_move_troops`, suggestion calculation preserving world and per-city troops, apply preserving total troops through `_move_troops`, and save/load preserving moved troops.
- Remaining risks: no approval UI yet; first-pass target-garrison ratios should be balance-reviewed; future UI flow needs F6 manual QA.
- Next candidates: `City Panel Rebuild / Chancellor Suggestion UI` or `Troop Move UI from/to/amount Control Polish`.

## Previous Patch Note
- `v0.68b-13-6C1 Troop Move Manual MVP` implements Phase C C1 only: manual troop movement between player-owned cities.
- C2 chancellor suggestions and automatic troop redistribution were not implemented.
- Precheck: existing state was sufficient for movement locking. Reused `_enemy_turn_mvp_pending`, pending invasion event, pending battle context, `Engine` battle context meta, and `turn_phase == player`; no new lock flag was added.
- Added `TROOP_MOVE_MIN_GARRISON_RATIO := 0.6` and C1 helpers for supply-path validation, minimum garrison, peacetime gate, validation, movement, total troop audit, and minimal UI preview.
- Movement rule: `_can_move_troops` must pass; `_move_troops` then writes source and destination only with `_set_city_runtime_troops(from, from - amount)` and `_set_city_runtime_troops(to, to + amount)`.
- The manual UI is intentionally minimal: City Detail internal/supply tab uses the selected city as source, first connected player-owned city in existing `owned_city_ids` as target, and up to 100 movable surplus troops as amount.
- QA runner confirmed total troop preservation, minimum garrison rejection, no supply path rejection, pending invasion rejection, save/load troop preservation, and player attack BattleContext reading the moved troops.
- Not changed: resource_stock, P0-1, P0-2, Phase A trade, Phase B supply calculations, battle scene logic, battle troop formulas, battle/invasion/defense logic, and save/load core structure.
- Remaining risks: minimal UI lacks explicit target/amount controls; F6 visual/manual QA is recommended; last move summary is persisted through existing full `_player_state`.
- Next candidate: `v0.68b-13-6C2 Chancellor Troop Rebalance Suggestions`.

## Previous Patch Note
- `v0.68b-13-5A City Info Display Spacing Micro Polish` is a display-formatting-only follow-up to 13-5.
- It only changes 13-5 helper output strings: adds section titles, line breaks, and normalized empty-state copy for trade/supply/loyalty display text.
- Route display now uses the existing routes array in current order with `slice(0, 3)` and an `외 N개` suffix for remaining routes. It does not sort, prioritize, filter by value, or mutate the original routes array.
- No calculation logic, result structure, real resource/loyalty/upkeep/troop values, P0-1, P0-2, Phase A, Phase B, Phase C, battle/invasion/defense, or save/load code was changed.
- Verification passed for scoped diff review, route slice/original-array mutation QA, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless display-spacing QA runner. Godot `--check-only` timed out locally after 124 seconds.
- Remaining risks: manual visual F6 mouse QA is still needed for actual label spacing/font rendering; Phase C remains unimplemented.
- Next candidate: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP`.

## Previous Patch Note
- `v0.68b-13-5 City Info Trade Supply Loyalty Display Polish` fills existing City Detail internal/external trade tab cases and turn result text with existing result/state data only.
- This is display-only. It does not change P0-1 governor income, P0-2 city loyalty drift, Phase A trade, Phase B supply connectivity, resources, loyalty, upkeep, result schemas, Phase C troop redistribution, battle/invasion/defense, or save/load core logic.
- Internal/supply tab display source: `_calculate_all_city_supply_states().city_states[city_id]`, using existing `role`, `supplied`, `isolated`, `income_multiplier`, `loyalty_delta`, and `security_delta`.
- Internal/supply tab loyalty display source: `_player_state["last_city_loyalty_drift_result"]`, using existing selected-city `reasons[]` and tax/security/economy/military/supply/supply_security/control delta fields.
- External trade tab display source: `_player_state["last_inter_faction_trade_result"]`, using `route_count`, `applied_player_totals` with `player_totals` fallback, and `routes` filtered to the selected city.
- Turn result/status text now includes trade income summary, supply hub/supplied-frontline/isolated summary, and city loyalty drift changed-city/large-drop summary.
- Added formatting helpers only: trade result summary, supply state summary, city loyalty drift summary, selected-city supply display, selected-city drift display, and selected-city route display.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and a temporary headless display QA runner. `--check-only` timed out locally after 125 seconds.
- Remaining risks: no manual visual F6 mouse QA yet; long detail text may need later spacing polish; supply tab display refreshes the runtime supply summary because it uses the existing supply calculation helper.
- Next candidates: `v0.68b-13-6 Phase C Internal Troop Rebalance MVP` or additional `Supply/Trade UI Polish`.

## Previous Patch Note
- `v0.68b-13-4A Supply Connectivity F6 QA Closeout` completed Phase B supply connectivity QA/documentation with no gameplay code changes.
- QA used `WorldMap_Test.tscn` plus a temporary headless runner, then removed the runner before commit.
- Starting state passed: Hanseong is the supply hub; with only Hanseong owned, there are no supplied frontlines and no isolated cities; turn end advances and records domestic/trade results.
- Connected scenario passed: Pyeongyang, Gyeongju, and Sabi as player-owned cities classify as supplied frontlines with paths back to Hanseong.
- Bonus checks passed: supplied frontline income `x1.10`, loyalty `+1`, security `+1`, supplied-frontline hero upkeep discount, and the `0.85` discount floor.
- Isolated scenario passed: Kyoto as a player-owned disconnected city classifies as isolated frontline with income `x0.80`, loyalty `-2`, and security `-1`; no isolated upkeep surcharge is expected in this MVP.
- Save/load behavior: loaded `_player_state` may contain a stale `last_supply_state_result`, but the next supply calculation recomputes from owner/owned-city/neighbor topology and overwrites it. Do not treat the loaded summary as authoritative.
- Light regressions passed for Phase A trade, city loyalty/runtime save-load, `faction_relations` persistence shape, player attack BattleContext build, and enemy invasion/defense event creation.
- Remaining risks: headless/API QA only, no visual supply-state UI, possible stale loaded runtime summary before recalculation, no Phase C troop redistribution, and no battle/invasion/defense supply effects.
- Next candidates: `v0.68b-13-5 Phase C Internal Troop Rebalance MVP` or `City Info Supply State Display Polish`.

## Previous Patch Note
- `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP` implements the redesigned Phase B as connectivity-gated domestic modifiers, not as resource movement.
- The national single-warehouse model remains intact. No city-level warehouse split, city-to-city transfer logic, or Phase C troop redistribution was added.
- Supply helpers in `scripts/worldmap_test.gd`: `_get_player_supply_hub_id`, `_is_city_supply_connected`, `_calculate_city_supply_state`, and `_calculate_all_city_supply_states`.
- `_apply_domestic_turn_mvp` calculates `supply_states` once, then passes the same result into domestic income, hero upkeep, and city loyalty drift.
- Frontline supplied cities receive income `x1.10`, loyalty `+1`, security `+1`; isolated frontline cities receive income `x0.80`, loyalty `-2`, security `-1`; hub/rear cities receive no bonus.
- Hero upkeep discount uses `max(0.85, 1.0 - 0.03 * supplied_frontline_count)`. Isolated-frontline upkeep surcharge is deferred as a remaining risk.
- `last_supply_state_result` is stored with `hub_id`, `supplied_frontline_count`, `isolated_count`, and `city_states`. It is recalculated each turn and is not a save/load payload extension.
- `worldmap_test_FULL.gd` is treated as an untracked source integration file and is not part of this commit.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, Godot headless `WorldMap_Test.tscn` load, and Godot `--check-only`.
- F6 manual QA remains for multi-city frontline/rear classification, connected and isolated cases, save/load recalculation, and visual/domestic summary sanity.

## Latest Patch Note
- `v0.68b-13-3 Final Merged WorldMap Domestic Trade Loyalty QA` applied `worldmap_test_FULL.gd` to `scripts/worldmap_test.gd`.
- The final merged WorldMap file contains P0-1 governor income effects, P0-2 city loyalty drift, Phase A inter-faction trade income, and trade tuning C.
- Trade tuning C values are confirmed in code: `TRADE_GLOBAL_DAMPENER := 0.5` and `TRADE_FOOD_FACTOR := 1.5`.
- `_apply_domestic_turn_mvp` preserves the integrated order: income, upkeep, Phase A trade, national loyalty, then city loyalty drift.
- Diff review against previous HEAD showed only trade tuning C changes and no battle/invasion/defense code changes.
- Static route check confirms Hanseong routes to Pyeongyang, Gyeongju, and Sabi, with tuned gold income totaling +40.
- Headless project and WorldMap scene loads pass; `--check-only` times out locally.
- F6 manual QA is still needed for visual trade income display, city loyalty save/load, `faction_relations` save/load, governor income sanity, and light battle/invasion/defense entry regression.
- Phase B supply connectivity was not implemented. Next task: `v0.68b-13-4 Phase B Supply Connectivity Bonus MVP`.

## Previous Patch Note
- `v0.68b-13-2 City Loyalty Drift Patch Acceptance QA` applies the P0-2 city loyalty drift patch to `scripts/worldmap_test.gd`.
- The patch adds the requested constants and four helpers: `_apply_city_loyalty_drift_for_world_turn`, `_calculate_city_loyalty_drift`, `_get_city_security_required_troops`, and `_governor_has_aptitude`.
- `_apply_domestic_turn_mvp` now applies city loyalty drift after national loyalty update and stores details in `last_city_loyalty_drift_result` / `last_domestic_apply_result.city_loyalty_drift_result`.
- P0-1 `city_loyalty_loss_multiplier` is now consumed by city tax loyalty drift via `_adjust_loyalty_delta`.
- `recruitable_troops_bonus` is still not connected to recruitment, security bonuses, or any consumer.
- City loyalty is stored through `_get_mutable_city_runtime_state` / `_city_runtime_states`; `loyalty` and `cityLoyalty` are included in the existing city runtime save/load payload without rewriting save/load core structure.
- Phase A trade was not implemented in this task. This branch already contains Phase A from `v0.68b-13-2A`; future merges should keep the intended turn order: P0-1 governor income, Phase A trade income if present, hero upkeep, national loyalty, then P0-2 city loyalty drift.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, and `WorldMap_Test.tscn` headless load. `--check-only` timed out locally.

## Previous Patch Note
- `v0.68b-13-2A Inter-Faction Trade Income MVP` implements Phase A only.
- WorldMap domestic turn processing now calculates adjacent inter-faction trade routes from player-owned cities and applies player trade income through `_apply_resource_delta(...)`.
- Relations are stored lazily in `_player_state["faction_relations"]` using sorted `a|b` keys; absent relation keys fall back to `neutral`.
- `last_inter_faction_trade_result` is saved in `_player_state` with `turn`, `route_count`, `player_totals`, `routes`, and `applied_player_totals`.
- `neutral` and `allied` trade; `hostile` and `suspended` do not. Same-faction city pairs are excluded.
- No Phase B internal supply network, Phase C troop redistribution, diplomacy manipulation UI, trade setting UI, battle/invasion/defense changes, or P0-2 loyalty/recruitment connection was added.
- Verification passed for `rg`, `git diff --check`, Godot headless project load, and `WorldMap_Test.tscn` headless load. `--check-only` timed out locally.

## Previous Patch Note
- `v0.68b-13-1 Governor Income Effect Patch Acceptance QA` reviewed and accepted the P0-1 governor income patch in `scripts/worldmap_test.gd`.
- The requested gates were missing, so only the narrow domestic-income patch points were added: governor rates, city effect calculation, governor type/policy effect helpers, city-income `city_effects` parameter, and player-income pass-through.
- Governor city effects now apply before the existing chancellor policy and national multipliers. No battle, invasion, defense, save/load, or scene logic was changed.
- `city_loyalty_loss_multiplier` and `recruitable_troops_bonus` are intentionally retained in the effect dictionary without current Godot consumers.
- Verified with `rg`, Godot headless project load, and `WorldMap_Test.tscn` headless load. `--check-only` timed out locally, so treat that specific check as inconclusive.
- F6 follow-up should compare Hanseong turn-end income before/after governor assignment and again after save/load; current Hanseong candidate effects may round to no visible income-number change at default values.

## Previous Patch Note
- `v0.68b-12b-31 Player/Defense Troop Accounting Parity Fix` closes the P0 troop-accounting gaps from the web parity audit.
- Player attack now subtracts defender allocated troops from the target city before battle, and preserves defender before/after metadata in the BattleContext/result payload.
- Enemy invasion defense now builds and pre-decrements both attacker and defender troop allocations before battle handoff.
- Battle result payload now includes player/enemy troop outcomes for defense battles as well as attack battles.
- Defense victory/defeat now apply survivor/wounded/dead results through city garrison and troop woundedQueue rules, including nearest-player-neighbor wounded retreat on defense defeat.
- Manual F6 QA remains required for queue persistence/recovery and win/loss city accounting.

## Previous Patch Note
- `v0.68b-12b-30 Invasion Attack Web Parity Gap Audit` is a docs-only audit comparing SamWar_web and Godot invasion/attack parity.
- New document: `agent/INVASION_ATTACK_WEB_PARITY_GAP_AUDIT.md`.
- Confirmed P0: player attack defender garrison pre-decrement is missing; defense battle troop allocation/result parity is missing; defense woundedQueue/nearest-player retreat-city handling is missing; woundedQueue F6/save-load QA remains required.
- Confirmed P1: commandRank/commandLimit allocation clamp is missing in Godot deployment UI, and defense deployment UI/default allocation needs follow-up.
- Deferred: captured city hero recruit/conversion, prisoner soldier systems, troop-count combat scaling, in-battle supply effects, and siege-specific formulas.

## Previous Patch Note
- `v0.68b-12b-29A Web-Parity Troop Allocation Wounded Queue Import` ports the web troop allocation and wounded soldier queue rules into the Godot player attack path.
- Deployment confirmation subtracts allocated sortie troops from the player source city before battle handoff and records source before/after troop values in the BattleContext.
- Battle units now carry `allocated_troops` and `initial_allocated_troops`; these fields drive result accounting but do not scale HP, attack, defense, unit size, or animation.
- Player attack result payloads include player/enemy troop outcomes. Victory uses HP-ratio survivors plus 30% wounded losses; defeat has 0 survivors and 50% wounded allocated troops.
- Victory transfers player survivors to the occupied target city and queues wounded troops there; defeat queues player wounded troops at the source city while the target owner remains unchanged.
- City `woundedQueue` persists through save/load and recovers into garrison troops on WorldMap strategy turn advance after 3 turns.
- Deferred: defender pre-battle garrison decrement parity, troop-count combat effects, in-battle supply effects, troop types, siege math, loot, and prisoner soldier systems.

## Previous Patch Note
- `v0.68b-12b-26 Player City Attack MVP Import` ports the web player city attack flow into the Godot WorldMap MVP.
- The selected-city `공격` button now emits an attack request and WorldMap enables it only for enemy cities with a directly adjacent player-owned city and no pending invasion/turn conflict.
- Player attack BattleContext uses `source: player_attack`, `type: attack`, source city as attacker, target city as defender, and the existing city-roster/support helper with captured/dead exclusion.
- Battle_Fullscreen_Test now maps player attack attacker roster to ally slots and defender roster to enemy slots; enemy-invasion defense context mapping is unchanged.
- Player attack result handling applies player victory as target-city occupation and player defeat as owner retention, reusing casualty, result card, hero status, and save/load persistence paths.
- Deferred: deployment selection, troop allocation, sea/route-type attacks, 2-hop attacks, marching/supply, siege UI, AI counterattack, and enemy hero recruitment.

## Previous Patch Note
- `v0.68b-12b-26 Wounded Hero Recovery Turn MVP` adds `wounded_turns_remaining` to hero runtime state.
- New wounded placeholders start at 3 WorldMap strategy turns; captured/dead/normal heroes keep the counter at `0`.
- Recovery ticks only from `_advance_world_turn_mvp()`, so battle rounds and auto-battle turns do not heal wounds.
- UI state markers now show `[부상 N턴]`; when the counter reaches `0`, status returns to `normal`, the badge disappears, and v25 battle penalties stop applying.
- Save/load now includes `wounded_turns_remaining`, with older wounded saves normalized to the 3-turn MVP default.
- Deferred: treatment buildings/items, ability-based recovery duration, prisoner release/recruit/execute, and death handling.

## Previous Patch Note
- `v0.68b-12b-25 Wounded Hero Battle Penalty MVP` keeps wounded heroes battle-eligible but weakens their combat output.
- Wounded penalty MVP values are attack damage `75%`, defense as incoming damage `120%`, and unique-skill numeric effects `70%`.
- Unique-skill damage, splash, attack buff, and defense buff amounts use the skill penalty; the toast/name presentation is unchanged.
- The battle scene reads wounded state from preserved context hero status fields; save/load continues through existing `worldmap_hero_state`.
- Captured/dead exclusion from v24 remains intact, while wounded heroes are intentionally not excluded.
- Deferred: wound recovery, treatment UI, prisoner movement/recruit/execute/release, real death handling, and refined ability-based wound balance.

## Previous Patch Note
- `v0.68b-12b-24 Captured Hero Battle Exclusion MVP` keeps captured heroes in WorldMap city rosters but excludes them from future invasion BattleContext rosters.
- The exclusion guard treats `captured == true`, `status == "captured"`, and safety `dead == true` as ineligible for battle; wounded heroes remain eligible.
- Support/reinforcement candidate picks use the same guard, so captured heroes are skipped instead of becoming reinforcements.
- The battle scene also rejects captured/dead WorldMap context heroes before slot assignment and deactivates the slot as a defensive guard.
- Save/load does not need a new payload shape; loaded `worldmap_hero_state` status fields continue to drive the exclusion.
- Deferred: prisoner movement/holding, recruit/execute/release, wound recovery, wounded penalties, and actual death processing.

## Previous Patch Note
- `v0.68b-12b-23 Hero State Visual Marker Roster Badge MVP` makes placeholder hero state visible in key roster surfaces.
- Runtime/display helpers append `[부상]`, `[포로]`, or `[사망]` with priority `dead` -> `captured` -> `wounded`; normal heroes have no marker.
- WorldMap selected-city hero lists receive merged `_hero_runtime_states`, and battle formation panels preserve context status fields from BattleContext.
- Post-battle result card hero status lines use the same marker style.
- Captured heroes are still not removed from rosters or excluded from battle; `dead` is display-safe but not applied by gameplay.
- Deferred: captured hero battle exclusion, prisoner movement/holding UI, wound recovery, death, and status stat penalties.

## Previous Patch Note
- `v0.68b-12b-22 Hero Wound Capture Placeholder MVP` applies a deterministic losing-side hero status placeholder after invasion battle results.
- MVP rule: first eligible losing-side hero is marked `wounded`, second eligible losing-side hero is marked `captured`, and `dead` remains unused.
- Captured heroes are not removed from city rosters and no prison/movement/recruit/execution/recovery flow is implemented.
- Status changes are stored in `_hero_runtime_states`, continue through `worldmap_hero_state` save/load, and are summarized in the post-battle result card.
- Deferred: actual capture movement, prison UI, recruitment/execution, wound recovery turns, death, stat-based rolls, and detailed prisoner panels.

## Previous Patch Note
- `v0.68b-12b-21 Post Battle Result Panel Polish MVP` adds an immediate WorldMap post-battle result summary card.
- Invasion result return now builds a display-only summary for defender win, attacker win/city fall, retreat, and unknown paths.
- The card lists ownership change/retention, defender city troop change, attacker source-city troop change, and occupation troops when present.
- The summary is not part of save/load persistence; actual owner/troop state remains in runtime city overrides from the previous patches.
- Deferred result report items remain out of scope: prisoner/wound/death display, resource loot display, detailed combat statistics, and a full report UI.

## Previous Patch Note
- `v0.68b-12b-20 Invasion Casualty Formula Hero State MVP` adds bounded MVP casualty application and hero status persistence fields.
- Defense victory keeps ownership while applying clamped defender city losses and heavier attacker source-city losses; defense defeat transfers ownership and applies occupation troops from attacker survivors/fallbacks.
- Troop math is intentionally temporary balance and clamps values to safe nonnegative bounds.
- `worldmap_hero_state` now stores `status`, `wounded`, `captured`, and `dead`, defaulting missing fields to `normal` / `false`.
- Deferred systems remain out of scope: actual wound/capture/death rolls, hero holding/movement after capture, resource looting, precise battle-power casualty math, AI strategy recalculation, and multi-invasion queues.

## Previous Patch Note
- `v0.68b-12b-19 WorldMap Battle Result Save/Load Persistence MVP` persists invasion-result worldmap runtime state.
- Save data now carries `worldmap_city_state` for city owner/nation/owner_faction_id, troops, and stationed hero ids, plus `worldmap_hero_state` for hero current city ids.
- Load starts from seed city/hero data and applies runtime overrides into `_city_runtime_states` / `_hero_runtime_states`, then refreshes city marker ownership and worldmap UI.
- Pending invasion event/context remains cleared in save/load so completed invasion choices do not reappear after reload.
- Deferred systems remain out of scope: hero wounds/capture/death, resource looting, precise casualty, AI strategy recalculation, and multi-invasion queues.

## Previous Patch Note
- `v0.68b-12b-18c Reinforcement Toast Auto Battle Final Stop Hotfix` closes the support-toast and post-result auto-turn leak left after 18b.
- Confirmed source: reinforcement toast was tied to round/deploy attempt flow, not to a nonempty actual arriving unit list, so no-support WorldMap context battles could still show the arrival toast.
- Reinforcement arrival now records successful deployed units and skips toast/log copy when the list is empty; inactive context slots are not arrival candidates.
- Result-finalized guards now block non-result toast enqueue/playback, enemy callbacks, move/attack finish callbacks, round start, auto action, and reinforcement deployment checks.
- Next QA should F6-check no turn-3 support toast when support is absent, sample battle support toast when real sample support arrives, immediate auto stop after result, and worldmap return.

## Previous Patch Note
- `v0.68b-12b-18b Roster Panel Source Auto Battle End Hotfix` closes the remaining formation-panel sample roster leak after the 18a battlefield-slot fix.
- Confirmed source: `_refresh_formation_slot_guide_for_entry()` could resolve hero identity through capacity-slot `unit_state` before checking WorldMap context-empty metadata, so hidden support slots could still show sample 김유신/을지문덕/유비/제갈량 in the side panels.
- WorldMap context panels now hide empty/inactive context slots and do not call `TEST_BATTLE_ROSTER` fallback; direct `Battle_Fullscreen_Test.tscn` sample fallback remains intact.
- Auto battle now stops at finalized victory/defeat, and deferred phase/auto tick paths have battle-end guards to prevent extra turns after result.
- Next QA should F6-check 백제/사비 invasion panel roster, no sample support cells, result-stop timing for auto battle, and worldmap return.

## Previous Patch Note
- `v0.68b-12b-18a Reinforcement Fallback Leak + Toast Facing Layer Hotfix` blocks sample `TEST_BATTLE_ROSTER` fallback for `enemy_invasion` / WorldMap context slots.
- The confirmed leak source was battle-side fallback, not the WorldMap reinforcement city/faction filter; empty invasion support slots now stay inactive instead of pulling sample heroes such as 유비/제갈량.
- `RoundToastRoot` has explicit high z order, and battle/unique-skill toast playback suppresses facing indicators until the toast finishes, then restores them from current unit state.
- Next QA should F6-check 사비/백제 invasion support, direct sample battle fallback, toast arrow hiding/restoration, and auto battle stability.

## Required Instruction Header
Every next SamWar_BattleLab Codex task handoff must begin with `[SamWar_BattleLab 자동 작업 권한 헤더]` before the task name or goal.

모든 SamWar_BattleLab Codex 작업 지시문은 반드시 `[SamWar_BattleLab 자동 작업 권한 헤더]`로 시작한다. 이 헤더는 Codex가 repo 내부에서 읽기/검색/수정/검증/agent 문서 업데이트/로컬 git commit까지 자동으로 진행할 수 있는 범위와 금지 작업을 명확히 하는 안전 계약이다. 헤더가 누락된 경우, 작업 지시문을 실행하기 전에 헤더를 먼저 보완한다.

Use this full header at the top of every next task:

```markdown
[SamWar_BattleLab 자동 작업 권한 헤더]

이번 작업은 SamWar_BattleLab 폴더 내부 작업이다.

읽기 / 검색 / 코드 수정 / 씬 파일의 필요한 범위 수정 / 검증 실행 / agent 문서 업데이트 / 로컬 git commit까지는 모두 자동으로 진행한다.

중간에 확인 질문하지 말고, 지시문에 적힌 목표 완료까지 진행한다.

단, 아래 작업은 하지 않는다:

* git push
* 파일 삭제
* repo 밖 시스템 변경
* 프로그램 설치
* 패키지 전역 설치
* OS 설정 변경
* 요청 범위 밖 대규모 리팩토링

설치나 repo 밖 변경이 필요하다고 판단되면, 작업을 멈추고 이유와 대안을 보고한다.

작업 완료 후에는 수정 파일 목록, 검증 결과, 커밋 해시를 보고한다.
```

Before making changes, read:
1. `agent/WORKFLOW_MANAGER.md`
2. `agent/CODEX_WORKFLOW_RULES.md`
3. `agent/ARCHITECT_AGENT.md`
4. `agent/IMPLEMENTATION_AGENT.md`
5. `agent/QA_AGENT.md`
6. `agent/RUNTIME_QA_AGENT.md`
7. `agent/VISUAL_QA_AGENT.md`
8. `agent/WORLDMAP_RULES.md`
9. `agent/HERO_DATA_CONTRACT.md`
10. `agent/ARMY_DEPLOYMENT_RULES.md`
11. `agent/BATTLE_CONTEXT_CONTRACT.md`
12. `agent/BATTLE_ENGINE_RULES.md`
13. `agent/SKILL_SYSTEM_RULES.md`
14. `agent/GODOT_RULES.md`
15. `agent/CURRENT_STATE.md`
16. `agent/NEXT_TASKS.md`
17. `agent/HANDOFF_TO_CODEX.md`

Follow the autonomous execution and commit rules in `agent/CODEX_WORKFLOW_RULES.md`, including autonomous commit when the task provides an explicit commit message.
At the start of a new Codex session, always follow the `SamWar_BattleLab 자동 작업 권한 헤더` section in `agent/WORKFLOW_MANAGER.md` and `agent/CODEX_WORKFLOW_RULES.md`.
Role-based agent docs are responsibility guides. `agent/CODEX_WORKFLOW_RULES.md` remains the canonical source for task classification, autonomous execution, approval handling, and verification depth.
WorldMap integration must respect the `BattleContext` contract.
BattleEngine must not directly consume global world state.
Worldmap is not implemented yet, but the worldmap -> battle_context -> battle_engine contract direction is selected.

## Local Godot Execution Path
- Godot 실행파일은 설치형이 아닐 수 있으며 PATH에 없을 수 있다.
- Codex는 Godot 검증 전 `agent/LOCAL_ENV.md`가 존재하는지 확인한다.
- `agent/LOCAL_ENV.md`가 있으면 그 안의 Godot 실행 경로를 우선 사용한다.
- PATH의 `godot`, `godot4`, `godot_console`, `godot4_console` 명령이 실패해도, LOCAL_ENV.md의 exe 경로가 있으면 그 경로로 headless 검증을 시도한다.
- `agent/LOCAL_ENV.md`는 김작 로컬 PC 전용 파일이며 git commit 대상이 아니다.

## Stable Baseline
Current stable baseline is:

`v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`

Latest docs/workflow baseline:

`v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`

Latest UI patch:

`v0.68a-fix6 Vertical Facing Status Badge Side Edge Snap Fix`

Latest camera foundation:

`v0.68a-1 Camera2D World/UI Layer Foundation`

- Latest camera focus patch:
`v0.68a-2 Combat Focus Camera Follow`

- Latest camera overlay hotfix:
`v0.68a-2-hotfix1 Camera-Bound Overlay Sync Fix`

- Latest battlefield visual patch:
`v0.68a-3 Battlefield Large Background Apply + Camera Clamp`

- Latest skill presentation patch:
`v0.68a-4-hotfix6 Unique Skill Cutin Punch Motion`

- Latest worldmap foundation patch:
`v0.68b-1 WorldMap Four-Tile Canvas Foundation`

- Latest worldmap marker patch:
`v0.68b-3 WorldMap City Castle Icon Apply`

- Latest worldmap route patch:
`v0.68b-4 WorldMap Route Layer Path2D MVP`

- Latest worldmap route hotfix:
`v0.68b-4-hotfix1 WorldMap Land Route Visibility Tuning`

- Latest worldmap route FX patch:
`v0.68b-5 WorldMap Sea Route Arrow Flow FX MVP`

- Latest worldmap selected city UI patch:
`v0.68b-6 WorldMap Selected City Panel Web Parity MVP`

- Latest worldmap functional marker patch:
`v0.68b-6a WorldMap Castle Icon Visual Disable Functional Marker Patch`

- Latest worldmap HUD structure patch:
`v0.68b-8 WorldMap Web HUD Panel Structure Import MVP`

- Latest worldmap HUD visual patch:
`v0.68b-8 WorldMap Web HUD Visual Parity MVP`

- Latest worldmap HUD data patch:
`v0.68b-9 WorldMap HUD Data Binding MVP`

- Latest worldmap domestic web parity patch:
`v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`

- Latest worldmap draggable HUD patch:
`v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`

- Latest worldmap unified panel patch:
`v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`

- Latest worldmap unified panel UX patch:
`v0.68b-12a Unified City Panel UX Fix + Web Content Parity Patch`

- Latest worldmap left HUD content patch:
`v0.68b-12b Left World HUD Web Content Parity`

- Latest worldmap seed data audit patch:
`v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit`

- Latest session handoff docs patch:
`v0.68b-12b-0.5 Session Handoff Docs Update Before New Chat`

- Latest worldmap seed import patch:
`v0.68b-12b-1 WorldMap Hero City Seed Data Import`

- Latest worldmap left panel binding QA patch:
`v0.68b-12b-2 WorldMap Left Panel Seed Binding QA`

- Latest worldmap left panel controls patch:
`v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP`

- Latest worldmap left panel policy/warehouse patch:
`v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP`

- Latest worldmap warehouse UI cleanup patch:
`v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup`

- Latest worldmap turn/save patch:
`v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP`

- Latest worldmap turn cycle patch:
`v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP`

- Latest worldmap domestic apply patch:
`v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP`

- Latest worldmap domestic apply QA patch:
`v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check`

- Latest worldmap enemy invasion audit patch:
`v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit`

- Latest worldmap enemy invasion event patch:
`v0.68b-12b-9 WorldMap Enemy Invasion Event MVP`

- Latest worldmap enemy invasion choice UI patch:
`v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP`

- Latest worldmap right city panel cleanup patch:
`v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup`

- Latest worldmap hero portrait binding patch:
`v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP`

- Latest worldmap BattleContext bridge patch:
`v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge`

- Latest worldmap battle scene handoff patch:
`v0.68b-12b-12 WorldMap Enemy Invasion Battle Scene Handoff MVP`

- Latest battle roster context patch:
`v0.68b-12b-13 Battle Roster Context Apply MVP`

- Latest worldmap battle result return patch:
`v0.68b-12b-14 WorldMap Battle Result Return MVP`

- Latest worldmap invasion result apply patch:
`v0.68b-12b-15 WorldMap Invasion Result Ownership Troop Apply MVP`

- Latest worldmap invasion result hotfix:
`v0.68b-12b-15-hotfix1 ReadOnly City Dictionary Troop Apply Fix`

- Latest worldmap hero battle contract patch:
`v0.68b-12b-16 WorldMap Hero Battle Data Unique Skill Contract MVP`

- Latest worldmap hero placement data patch:
`v0.68b-12b-16b Hero Placement Data Patch`

- Latest hero portrait import metadata audit:
`v0.68b-12b-16c Hero Portrait Import Metadata Audit`

- Latest actual hero portrait binding patch:
`v0.68b-12b-17 Actual Hero Portrait Binding + Skill Toast UI MVP`

- Latest battlefield portrait/skill hotfix:
`v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`

- Latest invasion reinforcement source patch:
`v0.68b-12b-18 Invasion Reinforcement Source Rule MVP`

- Latest warning cleanup hotfix:
`v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup`

- Latest session handoff docs patch:
`v0.68b-12b-10.5 Session Handoff Docs Update Before Stop`

- Latest worldmap marker hotfix:
`v0.68b-2-hotfix1 WorldMap City Marker Coordinate Space Fix`

- Latest worldmap tile hotfix:
`v0.68b-2-hotfix2 WorldMap Tile Editor Seam Fix`

- Latest worldmap manual layout patch:
`v0.68b-2-hotfix3 WorldMap Manual Tile Layout Control`

- Latest worldmap marker attachment hotfix:
`v0.68b-2-hotfix6 WorldMap City Marker Node2D NameLabel Fix`

## Core Scene And Scripts
- Worldmap foundation scene: `WorldMap_Test.tscn`
- Worldmap foundation script: `scripts/worldmap_test.gd`
- Worldmap city marker script: `scripts/worldmap_city_marker.gd`
- Core scene: `Battle_Fullscreen_Test.tscn`
- Core scripts:
  - `scripts/battle_web_import_test.gd`
  - `scripts/battle_unit_state.gd`
  - `scripts/unit_visual_slot.gd`

Do not modify casually:
- `Battle_Fullscreen_Test.tscn`

## Current Verified State
- `v0.68b-12b-18 Invasion Reinforcement Source Rule MVP` is complete. WorldMap-launched invasion battles now build attacker/defender rosters from the source city stationed heroes first and add support only from same-faction or explicit-ally cities within direct/2-hop MVP adjacency.
- Distant heroes are no longer force-filled into support slots. Empty context slots are deactivated in the battle scene instead of falling back to sample `TEST_BATTLE_ROSTER` heroes; direct sample battle fallback remains intact.
- 평양 -> 한성 static QA excludes 성도 from the 2-hop candidate set, so 유비/제갈량 are not eligible as ordinary support heroes.
- Save/Load, hero wounds/capture, hero movement, resource looting, precise strategic AI, and city ownership result behavior remain deferred.
- `WorldMap_Test.tscn` is the first worldmap visual canvas foundation.
- `WorldMap_Test.tscn` now stores editor-visible four-tile positions as A1 `(0, 0)`, A2 `(512, 0)`, B1 `(0, 512)`, and B2 `(512, 512)` so the Godot 2D editor can be used for manual city placement.
- The four Tile node positions are now the scene-authored source of truth; runtime does not overwrite Tile positions during `_ready()`.
- `scripts/worldmap_test.gd` computes camera clamp/world rect from the union of the current Tile Sprite2D world rects.
- The four prepared worldmap tiles are arranged as a 2x2 `WorldMapTileLayer` using `Sprite2D.centered = false` and texture-size-based placement.
- `WorldMapCamera` is a scene-authored `Camera2D` configured current at runtime with WASD/arrow pan, right/middle mouse drag pan, optional wheel zoom, and clamp against the combined tile rect.
- `WorldMapUI` is a CanvasLayer with screen-fixed title, camera debug, and input hint labels.
- `v0.68b-8` expands `WorldMapUI` with web-like HUD structure at MVP scope: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and expanded `CityInfoPanel`.
- City clicks refresh both `CityDetailPanel` and `CityInfoPanel` while preserving `selected_city_id`, `selected_city_marker`, and marker-local `SelectionRing`.
- The HUD buttons are placeholder-only: attack, hero movement, domestic, wild army edit, diplomacy, and spy actions only print debug output or update hint labels.
- `v0.68b-8 WorldMap Web HUD Visual Parity MVP` further tunes the HUD to the actual web CSS look: dark navy translucent panels, thin gold borders, gold/beige headings, dense text, inner cards, tab buttons, red action buttons, progress-bar placeholders, and a centered `SamWar Web` title banner.
- The right HUD uses a fixed multi-column visual layout for Diplomacy/Spy, City Detail, and Selected City. This is a visual parity MVP only and must remain decoupled from real domestic, diplomacy, spy, battle, and army behavior.
- `v0.68b-9 WorldMap HUD Data Binding MVP` adds local display-only HUD data binding on top of the visual HUD: player turn/status data, chancellor portrait/name/stats/policy, governor portrait/name/stats/policy, city loyalty, stationed hero chips, and CityDetail resource/military/trade/rating/governor summaries.
- Chancellor and governor policy `OptionButton` controls update local UI state and explanatory text only. They must not be treated as real domestic policy execution, resource mutation, turn processing, recruitment, hero transfer, or army movement.
- `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP` realigns the current Godot HUD to actual `SamWar_web` source structures. `CityDetailPanel` follows `resource_ui.js` tabs (`자원`, `자국무역`, `타국무역`) with display-only tab switching; `CityInfoPanel` follows `selected_city_ui.js` wording more closely; chancellor/governor policy options follow `constants.js`; city/garrison/governor seed data prioritizes `data/cities.js`, `data/heroes.js`, and `data/battle_rosters.js`.
- The v0.68b-10 tab/policy interactions remain local UI state only. They must not mutate resources, city stats, turns, save/load data, BattleContext, battle scenes, hero transfer, army movement, route logic, or AI.
- `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP` hides the retired top `SamWar Web` banner and old `도시 HUD 위치 이동 · Godot MVP fixed` dragbar at runtime.
- Unlike the web grouped `city-hud-stack` drag flow, Godot panels now move independently: `LeftWorldStatusPanel`, `DiplomacySpyPanel`, `CityDetailPanel`, and `CityInfoPanel` drag only from title/header labels, with no persistence.
- Panel drag should not be expanded into save/load, user config, project settings, domestic execution, battle entry, `BattleContext`, hero/army movement, route logic, or AI.
- `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP` consolidates the former separate City Detail and Diplomacy/Spy HUD surfaces into one `CityDetailPanel`-backed unified panel.
- Unified panel primary tabs are `도시 상세` and `외교·첩보`; secondary tabs are `자원` / `자국무역` / `타국무역` in city-detail mode and `외교` / `첩보` in diplomacy/spy mode.
- The standalone `DiplomacySpyPanel` is hidden at runtime. Keep diplomacy/spy behavior display-only until a dedicated feature task.
- The unified panel has runtime-only collapse/expand; no position/config persistence should be inferred from it.
- `v0.68b-12b Left World HUD Web Content Parity` realigns only the left main `LeftWorldStatusPanel` runtime copy against the actual web `renderWorldHud()`, `renderChancellorCard()`, `renderChancellorPolicyControl()`, and resource/trade summary wording.
- `v0.68b-12b-pre Codex Auto Work Header Rule Documentation` established the required `[SamWar_BattleLab 자동 작업 권한 헤더]` prompt header rule for future tasks.
- `v0.68b-12b` was a left HUD web content parity attempt/investigation flow: inspect actual web left HUD and resource/trade sources, adjust Godot display copy only, and keep all domestic/resource/turn/save behavior non-executing.
- The left HUD now displays web-like `World Turn`, turn/calendar/owner, `국가충성도`, `세금 수준`, chancellor portrait fallback/name/type lines, `재상 임명`, `재상 정책`, `보유 자원`, `국가 창고`, `내부 보급망`, `내부 병력 재배치`, `대외 무역`, and save/load/reset button copy.
- This is still display-only: chancellor policy selection updates explanation/hint text but must not apply policy effects, mutate resources, process turns, save/load/reset, run domestic/diplomacy/spy, move heroes/armies, create `BattleContext`, alter routes/sea arrows, or start battle.
- `v0.68b-12b-0 WorldMap Hero City Seed Data Structure Audit` completed the source-data audit for the next Godot seed import task without modifying code, scenes, assets, or repo-outside web files.
- Web `heroes.js` is an array structure; the next import should align Godot `HERO_DATA` with `id`, `name`, `factionId`, `side`, `role`, `stats`, `portraitImage`, `battlefieldPortraitImage`, and `chancellorProfile`.
- Web `cities.js` carries `id`, `name`, `region`, `ownerFactionId`, `neighbors`, `routeTypes`, `governorHeroId`, `cityLoyalty`, `resources`, `military`, `domestic`, and `yields`; the next import should preserve these as current display seed data where possible.
- Web `battle_rosters.js` `cityDefenderRosters` is the key source for each city's stationed hero seed data and should map into `CITY_HUD_DATA.stationed_hero_ids`.
- Web `app_state.createInitialDomesticPolicy()` initializes `chancellorHeroId: null`; web `getEligibleChancellorHeroes()` considers active heroes where `hero.side === playerFactionId`; web governor candidates are selected-city stationed player-side heroes with `hero.locationCityId === selectedCity.id`.
- Godot current seed ownership remains in `scripts/worldmap_test.gd`: `HERO_DATA`, `CITY_HUD_DATA`, `CHANCELLOR_POLICY_DATA`, `GOVERNOR_POLICY_DATA`, and `_player_state`.
- Godot current `_player_state.chancellor_id` now uses an empty value for web parity with `chancellorHeroId: null`; the left HUD should display `재상 미임명` and no chancellor effect until a future appointment task.
- Godot current worldmap seed data is display-only string-oriented data, not the full web numeric/stat object model.
- `v0.68b-12b-1 WorldMap Hero City Seed Data Import` is complete and updates only `scripts/worldmap_test.gd` seed data plus agent docs.
- Web sources used were local read-only `SamWar_web/data/heroes.js`, `SamWar_web/data/cities.js`, and `SamWar_web/data/battle_rosters.js`, with constants/app-state references for faction IDs, resource keys, selected city, initial resources, and web no-chancellor default.
- `HERO_DATA` preserves existing HUD compatibility keys while adding web identity/faction/side/role/command/stat/portrait/skill/chancellor-profile seed fields.
- `CITY_HUD_DATA` preserves existing display strings while adding city identity, owner/nation/region/type, population/gold/food/troop/public-order/commerce/agriculture/defense numeric seeds, `hero_ids`, and nested resource/domestic/yield seed dictionaries.
- `_player_state` now includes player faction, selected/origin/ruler city, owned city/hero seed lists, resource stock, and an empty `chancellor_id` to match web `chancellorHeroId: null`.
- The import remains data-only. It did not add movement, appointment execution, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding changes, scene layout changes, castle icon changes, or web repo edits.
- `v0.68b-12b-2 WorldMap Left Panel Seed Binding QA` is complete and updates only `scripts/worldmap_test.gd` display binding plus agent docs.
- The existing `LeftWorldStatusPanel` now reads imported `_player_state`, `CITY_HUD_DATA`, and `HERO_DATA` seeds for selected/origin city, selected city owner/region/governor/stationed heroes, owned city list, owned hero list, resource stock, and no-chancellor fallback.
- City marker selection now updates `_player_state.selected_city_id` and refreshes the left panel so the current selected city seed is shown without adding movement or appointment behavior.
- The patch added fallback-only display helpers for unknown city/hero ids, empty governor/chancellor states, empty stationed heroes, empty owned heroes, and resource stock formatting.
- This remains display-only. It did not add movement, appointment execution, policy effects, resource/troop/turn mutation, `BattleContext`, battle transition, route/pathfinding changes, scene layout changes, castle icon changes, or web repo edits.
- `v0.68b-12b-2 WorldMap Left Panel Web Parity Controls MVP` is complete and updates `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web parity references inspected were local read-only `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, and `js\ui\world_hud_ui.js`.
- The requested `scenes/WorldMap_Test.tscn` path is absent; the active worldmap scene remains root `WorldMap_Test.tscn`.
- The left panel now has seed-backed national loyalty label/status/progress and a tax slider bound to `_player_state.tax_level`.
- Tax changes update visible value/status and web-like income/loyalty preview text only; they do not apply turn income, resources, or permanent loyalty deltas.
- Chancellor assignment now uses selected-city stationed heroes from `CITY_HUD_DATA.stationed_hero_ids` resolved through `HERO_DATA`, with `미임명` as the first dropdown option.
- Chancellor selection updates `_player_state.chancellor_id` only for left-panel UI state and previews imported chancellor-profile effect text; missing portraits fall back to `?`.
- This remains left-panel UI/data-binding scope only. It did not add turn simulation, resource mutation, loyalty application, policy effect execution, movement, appointment system behavior, `BattleContext`, battle transition, route/pathfinding changes, castle icon changes, or web repo edits.
- `v0.68b-12b-3 WorldMap Chancellor Policy + National Warehouse Web Parity MVP` is complete and updates `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web parity references inspected were local read-only `C:\dev\SamWar_web\data\heroes.js`, `cities.js`, `battle_rosters.js`, `js\core\app_state.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\resource_ui.js`.
- The left panel now has a functional `재상 정책` dropdown backed by `_player_state.chancellor_policy_id` with web options `균형형`, `농업 중심`, `상업 중심`, `무역 중심`, and `군사 중심`.
- Policy effect text and preview lines now use structured local metadata aligned with web `CHANCELLOR_POLICY_EFFECTS`, including resource multipliers, hero upkeep preview, soldier upkeep preview, and salt preservation preview. Current resource stock is not changed by policy selection.
- The old duplicate visible `보유 자원: ...` summary is retired. `국가 창고` is the authoritative left-panel resource display and reads `_player_state.resource_stock` for current amount, capacity, and status rows.
- This remains left-panel UI/data-binding scope only. It did not add movement, appointment execution beyond UI state, policy effect application to resources, full end-turn simulation, `BattleContext`, battle transition, route/pathfinding changes, castle icon changes, or web repo edits.
- `v0.68b-12b-3a WorldMap National Warehouse Card UI Cleanup` is complete and updates `scripts/worldmap_test.gd`, root `WorldMap_Test.tscn`, and agent docs.
- The visible `국가 창고` section now uses a boxed runtime `WarehouseCard` instead of the previous plain multiline `SupplyLabel` output.
- The card shows only 9 resource rows (`쌀`, `보리`, `수산물`, `목재`, `철`, `말`, `비단`, `소금`, `금전`) with current/max values and status labels bound from `_player_state.resource_stock`, `WAREHOUSE_CAPACITY`, and `_get_resource_status_label()`.
- Internal maintenance/preview lines are hidden from the visible warehouse card: `영웅 유지비`, `병사 유지비 preview`, `보존 소금`, `유지비 정상`, and related explanation lines.
- This remains a narrow UI cleanup. It did not add upkeep/resource production, resource mutation, turn simulation, appointment execution, movement, `BattleContext`, battle transition, route/pathfinding changes, or broader HUD redesign.
- `v0.68b-12b-4 WorldMap Turn End + Save Management Web Parity MVP` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- The left panel bottom now hides remaining internal/debug lines below `국가 창고`, replaces `야군 편집` with `아군 턴 종료`, and shows web-like `저장 관리` controls.
- `아군 턴 종료` changes `_player_state.turn_phase` from `player` to `enemy`, updates the visible phase label to `적군 턴`, refreshes the left panel, and calls `_run_enemy_turn_mvp()` as a hook only.
- `_run_enemy_turn_mvp()` is intentionally non-simulating: no enemy invasion, AI, city ownership changes, hero movement, `BattleContext`, battle transition, resource ticks, or player-turn return is implemented yet.
- Save/load/reset now persists runtime worldmap/player HUD state to `user://worldmap_left_panel_state.json`, restores it with clean fallback messages, and resets to the startup seed baseline without using repo files for runtime saves.
- `v0.68b-12b-5 WorldMap Enemy Turn Return / Turn Cycle MVP` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- Web turn-cycle references inspected were local read-only `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\ui\world_hud_ui.js`, `js\ui\world_map_ui.js`, `js\main.js`, `js\core\world_calendar.js`, and `js\constants.js`.
- The current Godot turn loop is now `아군 턴 -> 적군 턴 -> 다음 아군 턴`: `_run_enemy_turn_mvp()` starts a short placeholder timer, `_finish_enemy_turn_mvp()` returns to player phase, and `_advance_world_turn_mvp()` increments `turn_number` once per completed cycle.
- Calendar display follows the web calendar MVP rule: start year `154`, season order `봄/여름/가을/겨울`, `10` turns per season, `40` turns per year.
- Enemy-turn pending state disables the turn-end button during the placeholder and is cancelled on load/reset so duplicate timers do not stack. Save/load/reset preserve phase and turn/calendar state through `_player_state`; loading an enemy-phase save resumes the placeholder return path.
- The turn-cycle patch did not add enemy invasion, target selection, hero movement, city ownership changes, domestic/resource turn application, `BattleContext`, battle transition, route/pathfinding changes, or broad AI simulation.
- `v0.68b-12b-6 WorldMap Turn Domestic Apply Web Parity MVP` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- Web domestic references inspected were local read-only `C:\dev\SamWar_web\js\core\app_state.js`, `js\core\save_load.js`, `js\core\world_calendar.js`, `js\core\domestic_income.js`, `js\core\domestic_effects.js`, `js\constants.js`, `js\ui\world_hud_ui.js`, and `js\ui\world_map_ui.js`.
- Domestic apply now runs exactly once at the completed full-cycle boundary: `아군 턴 종료 -> 적군 턴 placeholder -> 다음 아군 턴`.
- The applied MVP subset covers owned-city seasonal income, population/commerce tax gold, tax loyalty delta, chancellor policy income multipliers, active chancellor national modifiers, player hero upkeep deduction, resource stock capacity clamp, warehouse refresh, loyalty refresh, and concise result status text.
- Tax slider and chancellor policy dropdown remain preview controls until the turn cycle applies them; save/load/reset and UI refresh do not apply domestic changes.
- Save/load/reset preserve domestic-updated resources, national loyalty, tax level, chancellor id, chancellor policy, turn phase, turn number, and calendar labels through `_player_state`; runtime saves still use `user://worldmap_left_panel_state.json`.
- The patch did not add enemy invasion, full enemy AI, enemy target selection, enemy hero movement, city ownership changes, governor appointment execution, soldier upkeep application, salt consumption, internal supply/troop rebalance, `BattleContext`, battle transition, route/pathfinding changes, or repo-outside web edits.
- `v0.68b-12b-7 WorldMap Domestic Apply Visual QA + Balance Check` is complete and updates `scripts/worldmap_test.gd` plus agent docs only.
- The QA stabilization adds `_player_state.last_domestic_apply_turn` and a same-turn guard in `_apply_domestic_turn_mvp()` so resources and loyalty cannot be applied twice by a stale or duplicate callback for the same turn.
- Save metadata now records `v0.68b-12b-7`; save/load/reset continue to preserve domestic-updated resources, national loyalty, tax level, chancellor id/policy, turn phase, turn number, calendar labels, pending state, and the last applied turn guard.
- The visible left panel still keeps tax/policy/chancellor changes preview-only until full turn completion, refreshes warehouse/loyalty/status after apply, and keeps internal debug/warehouse lines hidden.
- `v0.68b-12b-7` did not add enemy invasion, enemy AI, target selection, hero movement, city ownership changes, governor execution, new domestic systems, `BattleContext`, battle transition, route/pathfinding changes, or broad simulation.
- `v0.68b-12b-8 WorldMap Enemy Invasion Web Logic Audit` is complete as a docs-only audit. It created `agent/ENEMY_INVASION_AUDIT.md` and did not modify Godot gameplay code or the root `WorldMap_Test.tscn`.
- Web enemy invasion is rolled in `js/core/app_state.js` `endWorldTurn()` after player-side turn systems using `world_rules.rollEnemyInvasion()` and `ENEMY_INVASION_CHANCE = 0.45`.
- Web invasion candidates are enemy-owned cities whose `neighbors` include player-owned cities. Selection is random among eligible adjacent pairs; no route type, troop threshold, diplomacy/peace check, city strength priority, cooldown, or multi-action enemy world turn was found.
- A successful web invasion creates a defense `pendingBattleChoice` with `battleContext: { type: "defense", attackerCityId, defenderCityId }`; battle starts only after manual/auto defense choice, and city ownership changes only after defense battle retreat/return.
- Web save/load clears pending invasion/battle state and returns to normalized player-turn world mode.
- Godot gap: current `scripts/worldmap_test.gd` has only the enemy-turn placeholder hook. It still needs an invasion event model, pending battle-choice UI, BattleContext bridge, battle return/result ownership apply, and explicit pending-event save/load policy.
- `v0.68b-12b-9 WorldMap Enemy Invasion Event MVP` is complete in `scripts/worldmap_test.gd`; the root `WorldMap_Test.tscn` was inspected but not modified.
- Godot now rolls `ENEMY_INVASION_CHANCE = 0.45` once per enemy placeholder phase, builds candidate pairs from enemy-owned scene city markers whose `neighbors` include player-owned markers, and stores a display-only `_player_state.pending_invasion_event`.
- The event records `type: defense`, `attacker_city_id`, `defender_city_id`, source, and turn number; it selects the defender city and shows `적군 침공 발생: ... · 방어전 준비 필요` in the left world status area.
- Pending invasion events are excluded from runtime save data and cleared on load/reset; enemy-phase saves load back to player turn, matching the web save/load normalization found in `save_load.js`.
- `v0.68b-12b-9` intentionally did not create `BattleContext`, transition to battle, change city ownership, move heroes/troops, resolve battle, add pathfinding, add cooldown/diplomacy checks, or implement enemy AI.
- `v0.68b-12b-10 WorldMap Enemy Invasion Choice UI MVP` is complete in `scripts/worldmap_test.gd`; the root `WorldMap_Test.tscn` was inspected but not modified.
- Godot now creates a runtime `PendingInvasionChoiceCard` in the left world status panel when `_player_state.pending_invasion_event` exists.
- The card shows web-like defense choice copy: `Enemy Invasion`, `적군 침공 발생`, attacker/defender city lines, `방어전을 준비하십시오.`, and `수동 방어` / `자동 방어` buttons.
- The two defense buttons now create runtime-only battle prep data: they validate `_player_state.pending_invasion_event`, write `_player_state.pending_battle_context`, update status text, and keep the pending event intact. They do not start battle, auto-resolve, change ownership, or deduct troops.
- `아군 턴 종료` is disabled/blocked while the pending event exists so enemy invasion events do not stack before the choice flow is handled.
- `v0.68b-12b-10.5 Session Handoff Docs Update Before Stop` is a docs-only wrap-up. No gameplay code or scene file should be inferred as changed by this handoff.
- `v0.68b-12b-10a WorldMap Right City Info Panel Web Parity Cleanup` is complete.
- The right `CityInfoPanel` now displays selected city name, owner/nation/region, population, gold, food, resource ratings, troops, defense, public support/order, commerce, agriculture, taesu/governor, and stationed hero names from existing seed data.
- The no-selection fallback is clean (`선택 도시 없음`, `월드맵에서 도시를 선택하십시오.`), and the panel avoids raw ids as primary display, raw nulls, dictionary dumps, and old visible placeholder blocks.
- Pending invasion display is still read-only: defender city shows `침공 대상 도시 · 방어전 준비 중`; attacker city shows `침공 출발 도시`.
- Modified files were `scripts/worldmap_test.gd`, `scripts/worldmap_city_info_panel.gd`, root `WorldMap_Test.tscn`, and agent docs.
- Web references inspected were `world_map_ui.js`, `world_hud_ui.js`, `ui_render.js`, `selected_city_ui.js`, `app_state.js`, `world_rules.js`, `data/cities.js`, and `data/heroes.js`.
- Verification passed: patch strings present, right-panel display strings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-10b WorldMap Hero Portrait Asset Binding MVP` is complete.
- Added shared portrait helper `scripts/worldmap_hero_portrait_helper.gd`; it reads existing `portrait_image`/portrait path fields, maps legacy `assets/portraits/...` seed paths to `assets/web_battle/portraits/...`, applies compact compatibility paths for known available assets, and safely falls back to `?`.
- The left chancellor card and right taesu/governor card now create runtime `TextureRect` nodes inside the existing portrait boxes. Valid portraits hide the `?` fallback; missing or failed loads clear the texture and show `?`.
- Stationed hero list remains text-only in this MVP to avoid crowding the cleaned right panel, but future pending invasion/defense UI can reuse the shared helper.
- Asset folders inspected: `assets/web_battle/portraits`, `assets/web_battle/portraits_battlefield`, and worldmap/battle asset listings.
- Verification passed: helper/patch strings present, chancellor/governor bindings present, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-11 WorldMap Enemy Invasion BattleContext Bridge` is complete.
- Manual/auto defense context creation includes defense type/source/mode, attacker/defender city ids and names, turn numbers, owner ids, troop totals, stationed hero ids, and governor ids from existing marker/HUD seed data.
- Validation fails safely for missing event, non-defense type, unknown city ids, non-enemy attacker, or non-player defender; failed validation clears only the runtime pending battle context.
- Runtime save policy follows the web audit: pending invasion event and pending battle context are excluded from save serialization and cleared on load/reset normalization.
- `v0.68b-12b-14 WorldMap Battle Result Return MVP` is complete.
- Battle result return uses runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_result`; no save file, repo runtime file, autoload, or project setting was added.
- WorldMap-launched battles show a runtime `월드맵으로 돌아가기` button after victory/defeat, build a defense result payload, and transition back to root `WorldMap_Test.tscn`.
- Result payload fields: source, type, mode, result, winner, attacker/defender city ids and names, and turn number.
- WorldMap consumes and clears the result metadata on startup, shows a Korean defense success/failure status, clears pending invasion event and pending battle context, hides the pending choice card, and refreshes HUD panels.
- Direct `Battle_Fullscreen_Test.tscn` launch remains preserved because no WorldMap context keeps the return button hidden and the demo setup unchanged.
- Final ownership, troop/resource, wounded, hero movement/capture, and persistence apply remain deferred to the next task.
- `v0.68b-12b-14-hotfix1 Unified Panel Chrome Nil Visible Guard` is complete.
- Cause: `_refresh_unified_panel_chrome()` assumed unified panel chrome nodes and runtime-created primary tab buttons were always non-null before `.visible` writes.
- Fix summary: `scripts/worldmap_test.gd` guards unified panel chrome `.visible` / `.modulate` writes and warns once if a chrome node is missing.
- `WorldMap_Test.tscn` was inspected but not modified for this hotfix.
- `v0.68b-12b-14-hotfix2 Integer Division Warning Cleanup` is complete.
- Cause: WorldMap calendar helpers used ambiguous integer `/` expressions for `zero_based_turn / 40` and `(zero_based_turn % 40) / 10`, which triggered Godot reload warnings.
- Fix summary: `scripts/worldmap_test.gd` uses explicit `floori(float(... ) / float(...))` for the intended integer calendar divisions.
- Behavior preservation: calendar output rules remain start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, and `40` turns per year; no gameplay, battle, invasion, turn-cycle, domestic, save/load, panel layout, or portrait behavior changed.
- Verification passed: patch strings, calendar constants, touched-file integer division scan, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 console warning cleanliness should still be confirmed during live UI interaction.
- `v0.68b-12b-14-hotfix3 Owner Shadow Warning Cleanup` is complete.
- Cause: `scripts/battle_web_import_test.gd` used local variable `owner` in `_apply_worldmap_context_side_roster()`, shadowing the base `Node.owner` property.
- Fix summary: renamed the local to `city_owner_id` and updated only local references.
- Behavior preservation: `"source_owner"` metadata and summary `"owner"` output still receive the same WorldMap context value; no gameplay, ownership, battle transition, turn/domestic, or save/load behavior changed.
- Verification passed: repo-local GDScript `var owner` search, `git diff --check`, Godot project headless load, root `WorldMap_Test.tscn` headless load, and root `Battle_Fullscreen_Test.tscn` headless load.
- Remaining risk: interactive F6 console warning cleanliness should still be confirmed during live UI interaction.
- Verification passed: patch strings, guarded visible assignments, forbidden-scope search, `git diff --check`, Godot project headless load, and root `WorldMap_Test.tscn` headless load.
- `v0.68b-12b-13 Battle Roster Context Apply MVP` is complete.
- `Battle_Fullscreen_Test.tscn` remains the selected battle scene.
- Handoff strategy is still runtime-only through Godot `Engine` metadata key `samwar_worldmap_battle_context`; the battle scene reads it once and direct scene launch keeps the demo setup.
- WorldMap context roster behavior: defender governor/stationed hero ids map onto ally slots, attacker governor/stationed hero ids map onto enemy slots, and current battle-registry-compatible ids replace demo identities where safe.
- Fallback behavior: empty hero arrays, unknown hero ids, missing governor ids, and direct battle launch all keep the existing `TEST_BATTLE_ROSTER` slot identities.
- City troop/garrison values are not applied to combat HP yet; troop scaling remains deferred.
- Selected battle scene is `Battle_Fullscreen_Test.tscn`, using `scripts/battle_web_import_test.gd`.
- Handoff uses runtime-only Godot `Engine` metadata key `samwar_worldmap_battle_context`; the battle scene reads and clears it at startup, then logs mode and attacker/defender city names while preserving the existing demo battle setup.
- Direct `Battle_Fullscreen_Test.tscn` launch without WorldMap context remains supported and logs `No WorldMap battle context; using test battle setup`.
- Current stable baseline for the next session is `v0.68b-12b-17a Battlefield Portrait Scale + Skill Name Hotfix`.
- `v0.68b-12b-17a` restores battlefield portrait badge scale to the old engine baseline: 128px battlefield portraits at scene scale `0.32`, so 512-source `portrait_path` textures display at roughly `41px` on battlefield badges.
- Skill display now treats `장수명 전법` as fallback-only. WorldMap context skill entries reuse existing sample skill names/cutin paths when context data only contains generated fallback names, preserving the old toast frame/animation path where assets exist.
- `v0.68b-12b-17` binds WorldMap BattleContext `portrait_path` into battle UI portraits, scales the single 512-source portrait into the existing 128 Sprite2D portrait slots, and prefers WorldMap context `skill_name` for unique-skill toast text.
- Missing hero portraits use the named common unknown portrait fallback, and missing skill toast/cutin images use a common skill fallback icon. Full cutin presentation, save/load, capture/wounds/death, hero movement, and resource looting remain deferred.
- `v0.68b-12b-16c` confirmed the repo already tracks Godot `.png.import` files, including `assets/heroes/portraits/**`, while `.gitignore` ignores the generated `.import/` cache directory. No untracked portrait `.import` files remained, so none were deleted or newly added.
- `v0.68b-12b-16b` adds/strengthens 유비, 권율, 척준경, 여포, and 하후돈 in WorldMap `HERO_DATA`, with confirmed unique skill names and explicit `portrait_path` / `cutin_path` contracts.
- Placement is now 성도: 유비, 한성: 권율, 평양: 척준경, 낙양: 여포, 업성: 하후돈. 척준경 is no longer stationed in 한성.
- `v0.68b-12b-16` adds actual city hero battle-data copies to WorldMap BattleContext via `attacker_heroes` / `defender_heroes`, with required combat fields and unique-skill fields for every included hero.
- Portrait contract is one 512-source `portrait_path`; 128 battle slots should scale that same source. Cutin/effect images are separate `cutin_path` fields. Existing 128 folders remain and were not deleted.
- Battle scene registers WorldMap context hero/skill data into runtime registries, and still falls back to `TEST_BATTLE_ROSTER` when data is missing or unsupported.
- `v0.68b-12b-15-hotfix1` fixes the read-only city Dictionary crash on F6 manual invasion battle return. Runtime owner/troop changes now duplicate seed/current city state into `_city_runtime_states`, mutate only that runtime copy, and rebind the right panel from merged seed + runtime data.
- `v0.68b-12b-15` result apply is complete: WorldMap consumes returned enemy-invasion defense payloads, preserves ownership on defense victory, transfers the target city to the attacker owner on defense defeat, applies safe nonnegative troop changes, clears pending invasion/context, and refreshes marker/right panel/world HUD.
- Battle result payloads now include attacker/defender owner ids, starting troop counts, and deployed survivor troop totals.
- Retreat/cancel/aborted/unknown results clear pending state safely and do not change ownership.
- User-reported F6 runtime visual check is working normally, and the pending invasion choice UI is good enough for the current MVP.
- Active worldmap scene is root-level `WorldMap_Test.tscn`; `scenes/WorldMap_Test.tscn` may not exist.
- Runtime save path is `user://worldmap_left_panel_state.json`.
- `agent/LOCAL_ENV.md` and `.godot/` are ignored local files and must not be committed.
- Pending invasion event and pending battle context are not persisted on save/load; load/reset clear both following the web audit policy. The scene handoff context is also runtime-only and not saved to `user://`.
- Defense deployment, auto defense resolution, resource battle loss, detailed casualties, hero capture, hero city movement, save/load persistence expansion for resolved city state, enemy strategic AI, enemy multi-action turns, internal supply network, troop redistribution, trade cooldown, soldier upkeep/salt consumption, and full governor appointment execution are still deferred.

## Current WorldMap MVP Systems
- Web hero/city/battle roster seed data imported into Godot.
- Left panel web-parity HUD controls: national loyalty, tax slider, chancellor assignment, chancellor policy, policy effect text, and national warehouse card.
- Turn system: ally turn end button, enemy placeholder, return to next ally turn, turn number/calendar advancement.
- Calendar rule: start year `154`, seasons `봄 / 여름 / 가을 / 겨울`, `10` turns per season, `40` turns per year.
- Save/load/reset via `user://worldmap_left_panel_state.json`.
- Domestic apply once per full turn cycle: tax income, loyalty change, chancellor policy effects, warehouse resource updates, duplicate apply guard.
- Enemy invasion MVP: 45% roll during enemy turn, enemy-owned attacker, neighboring player-owned defender, pending event, defender city auto-selection, pending choice card, manual/auto battle context creation, and ally turn-end blocked while pending.
- BattleContext bridge MVP: `_player_state.pending_battle_context` is runtime-only and stores defense source/mode, attacker/defender ids and names, turn numbers, owners, troops, stationed hero ids, and governor ids for future handoff.
- Battle scene handoff MVP: manual/auto defense stores the full context payload in runtime-only `Engine` metadata and transitions to `Battle_Fullscreen_Test.tscn`; the battle controller consumes the context if present and otherwise keeps the standalone test battle path.
- Invasion result apply MVP: returned defense result payloads are interpreted safely, defense wins keep target ownership, defense losses transfer target ownership to the attacker and set safe occupation troops, and retreat/unknown outcomes never change ownership.
- Hero battle contract MVP: BattleContext now carries actual city hero battle copies and unique-skill contract data while preserving current direct sample battle fallback.
- Right selected-city panel cleanup: selected city name, owner/nation/region, population/resources/economy/military values, taesu, stationed hero list, and pending invasion defender/attacker labels are now readable in the right `CityInfoPanel`.
- Hero portrait binding MVP: the chancellor card and right taesu/governor card use `WorldMapHeroPortraitHelper` to show existing portrait assets where available and keep the stable dark `?` fallback where missing.
- `RouteLayer` contains the first scene-authored route graph MVP: each route root owns route metadata, a `Path2D`, and a `Line2D`.
- Route connection meaning is controlled by exported metadata on `scripts/worldmap_route_path.gd`.
- Actual route shape is controlled by each scene-authored `Path2D.curve`; runtime must not regenerate or overwrite existing route curves.
- `Line2D` visualizes baked `Path2D` points. Land routes use muted earth tones and sea routes use pale blue tones.
- After `v0.68b-4-hotfix1`, land route `Line2D` style is width `4.5` with `Color(0.86, 0.62, 0.32, 0.72)` for better readability on earth-tone terrain; sea route style remains unchanged.
- `v0.68b-5` adds sea-only arrow flow FX through `ArrowFlowRoot` Path2D nodes and four `PathFollow2D` arrow markers per sea route.
- Sea arrow flow references each route's scene-authored `Path2D.curve`, moves one-way from `start_city_id` to `end_city_id`, and remains visual-only.
- Land routes remain line-only with no arrow flow.
- `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` remain the other prepared worldmap layers.
- `CityLayer` contains the first 13 scene-authored `CityMarker_*` nodes based on `SamWar_web/data/cities.js`.
- Each `CityMarker_*` root contains its marker body, name label, and click area/collision shape so root movement carries the whole city marker bundle.
- `WorldMapTileLayer`, `RouteLayer`, `CityLayer`, `ArmyLayer`, `EffectLayer`, and `DebugLayer` share the same explicit zero-offset `WorldMapRoot` coordinate basis.
- The current 13 `CityMarker_*` positions have been re-seeded to the 4-tile combined rect so they sit on the map image in the 2D editor.
- After the tile seam fix, the 13 `CityMarker_*` positions are seeded against the corrected 1024x1024 editor-visible combined rect.
- Each city marker stores exported metadata for city id, display name, region id, owner faction id, neighbors, route types, and `web_seed_position`.
- Web `x` / `y` values are only initial seed/fallback placement data; final marker position source of truth is the `CityMarker_*` node position saved in `WorldMap_Test.tscn`.
- City marker positions remain scene-authored source of truth after manual tile layout control.
- City marker click updates `selected_city_id`, keeps `selected_city_marker`, clears the previous marker selection, shows the selected marker's `SelectionRing`, and refreshes `WorldMapUI/CityInfoPanel` from marker metadata.
- `CityInfoPanel` is a reduced Godot port of the web `renderSelectedCityPanel()` shape and displays city name, id, region/owner, type, neighbors, route type summary, MVP status text, and attack / hero-move placeholder buttons.
- `CityInfoPanel` now also displays a selected-city description, garrison placeholder, military placeholder, hint text, and an added domestic placeholder button.
- `CityInfoPanel` now visually includes loyalty progress, governor placeholder, selected-hero chips placeholder, military state placeholder, and recruit placeholder button.
- Castle icon visuals are currently disabled for the functional marker phase. `CastleIcon` nodes and castle icon asset references remain in `WorldMap_Test.tscn`, but they are hidden and controlled by `CASTLE_ICON_VISUALS_ENABLED := false`.
- The visible city marker is currently the lightweight colored `CityDot`; `NameText`, `ClickArea`, `SelectionRing`, selected city state, and `CityInfoPanel` remain active.
- Attack and hero-move placeholders do not create `BattleContext`, change scenes, move heroes/armies, or open domestic detail UI.
- Route click, army movement, pathfinding, battle entry, and `BattleContext` runtime injection remain unimplemented.
- `scripts/worldmap_city_marker.gd` may update marker label/color visuals but must not overwrite marker root positions from web data at runtime.
- City click, city data, route graph, army movement, battle entry, and `BattleContext` runtime injection remain unimplemented.
- Current MVP battle target is stable `5v5`.
- Round flow is stable:
  - `ROUND 1 = 3v3`
  - `ROUND 2 = 4v4`
  - `ROUND 3 = 5v5`
- Enemy AI multi-target engagement is improved and considered stable.
- Hero identity registry is applied by `hero_id`.
- Reinforcement arrival toast is stable.
- Victory / defeat result toast is stable.
- Reinforcement / round / result toast queue is stable.
- Bottom global command bar exists.
- Bottom command bar art-prep structure now exists under `assets/web_battle/ui/bottom_command/`.
- Bottom command buttons are now scene-authored `TextureButton` nodes with the 6 PNG assets connected directly in `Battle_Fullscreen_Test.tscn`.
- `bottom_command_bar_bg.png` is now applied as the scene-authored `CommandBar` background.
- The old black `CommandBar` panel fill is hidden via transparent panel styling.
- Bottom command bar background is treated as MVP-complete and not a blocker for the current baseline.
- 2D editor visibility for the bottom command buttons is restored.
- Legacy large `LeftPanel` / `RightPanel` info panels are hidden/deprecated.
- `BattleMiniLogPanel` and `FormationSlotGuideLayer` are now part of the battle UI.
- Formation slot guide shows only main `3` + reinforce `2` per side and is display-only.
- `UnitCloseupPanel` is hidden and reserved for future popup reuse.
- Formation guide cards now show portrait + name + troop count + troop icon + troop type.
- Formation guide status text is removed; active/reserve distinction is style-based.
- Current locked MVP battle-screen UX is:
  - left ally formation guide `5` cards
  - right enemy formation guide `5` cards
  - lower-left mini log
  - bottom command bar with `3` ink buttons + background panel
  - floating command panel over the battlefield interaction flow
- Floating command panel exists and remains click-to-open.
- Direct move-click UX remains stable.
- Post-move floating panel auto-reopen remains stable.
- Active ally pulse uses the unified root pulse with pivot lock at around `1.5x`.
- `5v5` full auto result path is reachable.
- Headless project / scene launch are expected to remain `0` errors and `GDScript` warnings are expected to remain `0`.
- `AutoBattleButton`, `EndTurnButton`, and `RetreatButton` are now `TextureButton` nodes with existing handlers reused.
- Existing handlers remain reused.
- `RetreatButton` remains a disabled placeholder.
- Current test battle `10` heroes have `hero_id`-based unique skill registry entries.
- Ally manual unique skill use is enabled through `FloatingUniqueSkillButton`.
- Floating unique skill hover tooltip text is intentionally suppressed; button text remains the visible label.
- Formation guide cards include an enlarged `64 x 64` `UniqueSkillReadyIcon` for the currently usable active ally only.
- Deployment markers now sync from scene-authored `Slot` / `UnitVisualRoot` anchors at runtime start and before demo state creation, so moving a unit slot/root in the Godot 2D editor changes the actual deployment marker/grid-cell source as well as the visual group.
- `UnitMarker` nodes are retained as compatibility runtime sync targets and should not be deleted casually.
- Token, portrait, HP bar, troop label, shadow, move dust, click area, READY frame, facing indicator, and status badges are treated as one root-relative visual attachment set through the `UnitVisualSlot` registry.
- Click areas remain scene-level `Area2D` nodes for compatibility, and READY/facing/status overlays remain UI/FX layer nodes, but all are positioned from the slot-synced visual anchor.
- Battlefield status badges now snap badge edge to facing-arrow visual edge instead of using the full facing indicator Control width.
- Vertical-facing battlefield status badges now use left-side arrow edge snap: up-facing and down-facing badges both sit tightly to the arrow's left edge.
- Confusion battlefield badges use the stable `◎N` fallback because the attempted blank-symbol display did not render reliably in Godot.
- `MainCamera` is scene-authored `Camera2D`, configured as current at runtime, and reset to its scene-authored position/zoom before battle reset paths.
- Camera2D controls battle world view only; `BattleUI`, `EnemyRetreatToastLayer`, `CutinOverlay`, and `ResultOverlay` remain CanvasLayer-based screen UI.
- Combat focus camera follows battle start, ally selection, move resolution, combat pair midpoints, strategy/unique skill presentation, enemy attacks, and reinforcement arrival while preserving CanvasLayer UI.
- Unique-skill camera shake uses the current focus baseline so it returns to the focused combat view instead of the original scene center.
- Camera-bound overlays are refreshed during/after Camera2D focus movement, and world-to-UI conversion is based on current `MainCamera` position/zoom so facing indicators and the post-move FacingArrowPanel do not keep stale positions.
- `Battle_Fullscreen_Test.tscn` uses the 3200x1800 worldmap-test battlefield background at `assets/web_battle/battlefield/battlefield_3200x1800_worldmap_test_01.png`.
- Camera clamp prefers the visible battlefield texture rect before falling back to logical board bounds, while current unit deployment remains intentionally unrecentered.
- Ally manual unique skill use now requires range/target selection before resolution.
- Unique skill range overlays are purple and valid target cells are gold/orange.
- Unique skill presentation uses the existing `BattleUI/UniqueSkillToastRoot` as a screen-fixed wide fullscreen cut-in, independent from Camera2D movement/zoom.
- Unique skill cut-in uses the existing skill cutin image enlarged to roughly `96%` viewport width and `52%` viewport height, with large skill-name text over the lower banner.
- Unique skill cut-in now plays as a dynamic impact presentation: short ink flash, side-based slide-in, root scale punch, delayed skill-name pop, short hold, and fast slide/fade-out.
- Unique skill cut-in root now adds punch motion: alpha fade-in, scale `0.85 -> 1.12 -> 1.0`, minimal `0.08s` hold, then upward fade-out / shrink to `0.92`.
- Particles, glow shaders, and sound are intentionally deferred and are not part of this cut-in punch step.
- Unique skill cut-in timing uses `0.14s` enter, `0.04s` skill-name delay, `0.06s` punch settle, `0.08s` hold, and `0.15s` exit; actual damage/buff/FX and camera shake begin after the cut-in exits.
- `UNIQUE_SKILL_CUTIN_TIMING_DEBUG` enables `[UNIQUE_CUTIN]` console logs for SHOW_START, ENTER_DONE, HOLD_START, HOLD_DONE, EXIT_START, HIDE_DONE, and EFFECT_APPLY elapsed times.
- The fullscreen cut-in tween uses explicit enter-parallel, hold interval, and exit-parallel sequencing; the previous `1.5s` hold is no longer used.
- The former `global_scale` / `position` local variables in `scripts/battle_web_import_test.gd` were renamed to avoid Node2D property shadowing warnings.
- Unique skill effect values, target selection, cooldowns, registry data, and AI value gates are unchanged.
- Unique skills have MVP effects for `cannon_aoe`, `ally_attack_buff`, `self_defense_single`, and `single_damage_adjacent_shake`.
- Unique skill damage numbers are larger red labels and unique skills trigger short camera shake.
- Auto battle can use available ally unique skills before falling back to basic attack / movement / wait.
- Enemy AI can use available unique skills on enemy turns and after movement rechecks.
- Unique skill ranges are first-normalized: melee skills require close engagement and AOE remains mid-range.
- Enemy/auto unique skill selection now checks high-value or fallback-value conditions instead of using every ready skill.
- Enemy movement, approach, and basic attack pressure are restored in full-auto flow.
- Unique skill readiness is cooldown-state based; old one-use gating is removed.
- Directional damage bonus is active for basic attacks, enemy hits, and single-target attack unique skills.
- Directional multipliers are front `1.0`, side `1.15`, back `1.3`.
- Formation guide troop icons are readable again while `UniqueSkillReadyIcon` remains `64 x 64`.
- `SkillInfoPanel` remains deferred and is not implemented in the current scene.
- Detailed unique skill range balance remains deferred.

## Recommended Next Task
- Current stable behavior baseline: `v0.67z-3 Strategy Status Badge Near Facing Arrow Patch`
- Current docs/contract baseline: `v0.68 Agent Contract Split for WorldMap + Hero Scale Prep`
- Immediate next task:
  - `v0.68b-12b-17b Hero Portrait Battle F6 QA Follow-up`
- `v0.68b-12b-17b` goal:
  - F6-check WorldMap invasion manual defense into battle and confirm actual city-roster portraits/skill names display as intended.
  - Keep existing 128 folders, no bulk image deletion or migration, and no battle formula changes.
- Next candidates:
  - `v0.68b-12b-17b Hero Portrait Battle F6 QA Follow-up`
  - `v0.68b-12b-16a WorldMap Hero Battle Data F6 QA Follow-up`
  - `v0.68b-12b-4 WorldMap City Detail Governor / Stationed Hero Web Parity MVP`
  - `v0.68b-12c Selected City Panel Web Content Parity`
  - `v0.68b-12d City Detail Panel Web Content Parity`
  - `v0.68b-12e Diplomacy Spy Panel Web Content Parity`
  - `v0.68b-13 Hero Portrait Asset Naming Contract`
  - `v0.68b-14 Hero Portrait Asset Apply MVP`
  - `v0.68c BattleContext Runtime Injection MVP`
  - `v0.68d Hero/Army Deployment MVP`
- 김작 F6 visual QA remains for `v0.68b-12b Left World HUD Web Content Parity`: confirm left HUD section order resembles the web left HUD, turn/date/phase wording is web-like, chancellor card and policy UI match web labels/descriptions, policy selection only updates explanation, resource/warehouse/supply/troop-rebalance/external-trade summaries use web copy, button text matches web save/load/reset and wild-army edit wording, placeholder feel is reduced, bottom blank space is acceptable, other panels remain intact, independent drag/collapse still works, Selected City remains separate, city-click refresh still works, route/sea arrow flow is normal, castle icon visuals remain hidden, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-12 WorldMap Unified City Detail Diplomacy Panel MVP`: confirm CityDetailPanel and DiplomacySpyPanel appear as one unified panel, primary tabs `도시 상세` / `외교·첩보` are visible, city-detail mode shows `자원` / `자국무역` / `타국무역`, diplomacy/spy mode shows `외교` / `첩보`, tab clicks switch only display content, collapse reduces the panel to a compact reopenable header, the unified panel and CityInfoPanel drag independently, panel dragging does not pan the camera, city clicks still update unified and selected-city content, buttons do not execute real systems, castle icons stay hidden, route lines / sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-11 WorldMap Independent Draggable Panels + Top Banner Cleanup MVP`: confirm the `SamWar Web` banner and `도시 HUD 위치 이동 · Godot MVP fixed` bar are gone, `CityDetailPanel`, `CityInfoPanel`, and `DiplomacySpyPanel` drag independently, other panels do not follow, drag starts only from header labels, buttons/tabs/OptionButtons still click normally, panel dragging does not pan the camera, pan/zoom keeps HUD screen-fixed, city clicks still update Selected City and City Detail, resource/trade tabs and policy UI remain, castle icons stay hidden, route lines / sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-10 WorldMap Domestic Affairs Web Source Parity MVP`: confirm Godot panel structure resembles the actual web HUD source, City Detail tabs/text/buttons follow `resource_ui.js`, Selected City follows `selected_city_ui.js`, chancellor/governor policies follow web constants, web city/governor/hero roster data is reflected where available, tab clicks only switch display, policy selection only changes descriptions, all buttons remain placeholder-only, city clicks update Selected City and City Detail together, castle icons remain hidden, route/sea arrow flow remains normal, HUD stays fixed during pan/zoom, and battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-9 WorldMap HUD Data Binding MVP`: confirm left chancellor portrait/name/stats/policy/resource display, chancellor policy description updates without real effects, city clicks update Selected City and City Detail, selected city governor portrait/name/stats/policy displays, governor policy description updates without real city changes, stationed hero chips display, CityDetail resource/military/trade/rating/governor/stationed hero count updates, all buttons remain placeholder-only, castle icons stay hidden, route lines / sea arrow flow remain normal, HUD stays screen-fixed during pan/zoom, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-8 WorldMap Web HUD Visual Parity MVP`: confirm the left World Turn panel resembles the web version, upper-right Diplomacy/Spy panel is visible, right City Detail panel is visible, Selected City panel visually resembles the web version, panel colors/borders/titles/buttons are close to the web HUD, city clicks update Selected City and City Detail, buttons do not execute real systems, panels stay screen-fixed during pan/zoom, panel coverage is acceptable, castle icon visuals remain disabled, route lines / sea arrow flow remain normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-8`: confirm left World Turn/국력/자원 panel, upper-right Diplomacy/Spy panel, right City Detail panel, right Selected City panel, city-click updates for City Detail and Selected City together, screen-fixed HUD behavior during pan/zoom, non-obstructive panel coverage, placeholder-only attack/hero-move/domestic buttons, castle icon visuals still disabled, route line / sea arrow flow continuity, and existing battle scene stability.
- 김작 F6 visual QA remains for `v0.68b-6a`: confirm castle icons are not visible, city name labels and simple functional markers remain visible, city clicks still select cities, selected markers show `SelectionRing`, `CityInfoPanel` appears normally, route lines and sea arrow flow remain normal, pan/zoom keeps city clicking normal, and existing battle scenes remain stable.
- 김작 F6 visual QA remains for `v0.68b-6`: confirm city marker click selection, selected marker ring readability, fixed `CityInfoPanel` placement, city name/id/region/owner/type/neighbors/routeTypes text, attack / hero-move placeholder visibility, pan/zoom click behavior, route line and sea arrow flow continuity, city click/UI non-regression, and existing battle scene stability.
- 김작 F6 visual QA remains for `v0.68b-5`: confirm sea route arrows are visible, follow `Path2D` curves naturally, wrap from route end to start, move at a readable speed, do not cover city names/icons, land routes have no arrows, pan/zoom keeps arrows attached to the map, city click info panel remains normal, and existing battle scenes are stable.
- 김작 F6 visual QA remains for `v0.68b-4-hotfix1`: confirm land routes are clearly more visible than before, do not disappear into mountain/plain earth tones, do not overpower city castle icons, sea route style still feels unchanged, pan/zoom keeps routes attached, `Path2D` curve editability remains intact, city click info panel still works, and existing battle scenes remain stable.
- 김작 2D/F6 visual QA remains for `v0.68b-4`: confirm `RouteLayer` route roots have `Path2D` and `Line2D`, route curves are editable in the 2D editor, route lines roughly connect city markers, land/sea routes are visually distinct without covering city markers, camera pan/zoom keeps route lines attached to the map, city click info panel remains normal, and existing battle scenes are stable.
- Known issue retained: CityMarker root movement / name text attachment still needs manual confirmation and was not changed by the route-layer MVP.
- 김작 2D/F6 visual QA remains for `v0.68b-3`: confirm all 13 cities show castle icons instead of dots, Korea/China/Japan/Ordo icon mapping is correct, `CityMarker_*` root movement carries `CastleIcon`, `NameText`, and `ClickArea/CollisionShape2D`, city names do not severely overlap icons, marker click info panel remains normal, camera pan/zoom/clamp remains normal, and the battle scene is stable.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix6`: move `CityMarker_Hanseong` root and confirm the Node2D `NameLabel` text visibly moves with `CityDot` and `ClickArea/CollisionShape2D`; repeat spot checks on other city markers; save with Ctrl+S and confirm F6 preserves the bundle.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix5`: move `CityMarker_Hanseong` root and confirm `CityDot`, `NameLabel`, and `ClickArea/CollisionShape2D` move together; repeat spot checks on the other 12 cities; Ctrl+S persistence; marker click info panel; camera pan/zoom/clamp; and battle scene stability.
- Codex Godot headless verification for `v0.68b-2-hotfix5` may be blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output if needed.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix4`: move `CityMarker_Hanseong` root and confirm marker body, name label, and click area move together; check all other city marker roots; Ctrl+S persistence; marker click info label; camera pan/zoom/clamp; and battle scene stability.
- Codex Godot headless verification for `v0.68b-2-hotfix4` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix3`: select/move the four Tile nodes in the 2D editor, Ctrl+S, confirm F6 preserves the saved layout, camera clamp follows the current tile union rect, all 13 city markers remain present, and the battle scene is not broken.
- Codex Godot headless verification for `v0.68b-2-hotfix3` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 2D/F6 visual QA remains for `v0.68b-2-hotfix2`: confirm 4 tiles attach as one map in the 2D editor, no gray band appears between rows, no left/right seam gap appears, all 13 city markers sit on the map, debug rects do not block placement, camera pan/zoom/clamp remains normal, UI labels stay fixed, and the battle scene is not broken.
- Codex Godot headless verification for `v0.68b-2-hotfix2` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains for `v0.68b-2-hotfix1`: confirm all 13 city markers sit on top of the 4-tile map image in the 2D editor, no marker is in the lower gray area, `CityLayer` and `WorldMapTileLayer` share coordinates, editor move-and-save persists marker positions, camera pan/zoom/clamp remains normal, UI labels stay fixed, and the battle scene is not broken.
- Codex Godot headless verification for `v0.68b-2-hotfix1` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains for `v0.68b-2`: confirm all 13 city markers are visible under `CityLayer`, marker labels/colors are readable enough for MVP placement, editor move-and-save persists marker positions, camera pan/zoom keeps markers attached to the map, and no city click/battle entry behavior exists yet.
- Codex Godot headless verification for `v0.68b-2` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains for `v0.68b-1`: confirm `WorldMap_Test.tscn` shows all 4 tiles as one map without visible gap/overlap/seam, Camera2D pans smoothly, clamp avoids excessive gray outside area, UI labels stay screen-fixed, future layers exist in the scene tree, and existing `Battle_Fullscreen_Test.tscn` is not broken.
- Codex Godot headless verification for `v0.68b-1` was blocked by `windows sandbox: spawn setup refresh`; run local F6/headless QA for `WorldMap_Test.tscn` load and GDScript warning output.
- 김작 F6 visual QA remains before treating layout feel as final: move `Slots/AllyReinforce01Slot` and confirm ROUND 2 김유신 spawn plus HP/troop/portrait/click/facing/status alignment.
- 김작 F6 visual QA also remains for status badge placement: confirm `→` badges sit left of arrow, `←` badges sit right, `↑` and `↓` badges sit tightly on the arrow's left edge, confusion remains `◎N`, and multi-status groups attach as one badge block.
- 김작 F6 visual QA remains for Camera2D foundation: confirm F6 shows the normal battle screen, fixed UI panels/toasts stay screen-anchored, `MainCamera` is current, existing camera shake still works, and the battle loop remains stable.
- 김작 F6 visual QA remains for combat focus: confirm battle start, ally selection, move completion, attack midpoint, enemy attack midpoint, strategy/unique skill, and reinforcement arrival are visible; UI stays fixed; status badge fix6 remains intact; and camera shake returns to the current focus.
- 김작 F6 visual QA remains for overlay sync: confirm first-screen facing indicators sit on units, post-move direction arrows appear around the active unit after camera focus, no overlay stays in a stale gray/off-unit area, and camera shake does not desync overlays.
- 김작 F6 visual QA remains for the large battlefield: confirm the new background is visible without gray/empty areas during camera follow/shake, current separated starting positions are preserved, and direction/status/UI overlays remain synced.
- 김작 F6 visual QA remains for fullscreen unique skill cut-ins: confirm the cut-in strongly fills the screen on the 3200x1800 battlefield, UI panels/buttons are not broken, timing is not sluggish, existing damage/buff/FX happens after cut-in exit, camera focus does not jump, camera shake returns to the current focus, status badge fix6 remains intact, and normal attack/strategy/defend flow remains stable.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix1`: confirm the cut-in/toast holds for about `1.5s`, does not vanish too quickly, enter/exit remain short, post-cutin effects still apply, camera shake returns to current focus, and GDScript warning output no longer includes `global_scale` / `position` shadowing.
- `v0.68a-4-hotfix2` timing trace logs remain available for diagnosis, but the `1.5s` hold check is superseded by the toast-tempo match timing.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix2` tempo match: confirm the cut-in feels close to turn-exchange toast tempo, is still readable, no longer lingers like the `1.5s` hold, enter/exit remain snappy, post-cutin effects still apply, camera shake returns to current focus, and GDScript warnings stay clean.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix3`: confirm the cut-in hits strongly without lingering, total feel is around `0.6s`, skill name / general image remains momentarily clear, post-cutin effects apply naturally, battle tempo is not interrupted, and GDScript warnings stay clean.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix4`: confirm the cut-in does not look like a static large toast, slide-in feels forceful, scale punch is visible, ink flash is brief, skill-name pop reads, cut-in exits quickly into battlefield damage/buff/FX/camera shake, Camera2D does not jump, status badge fix6 remains intact, and normal attack/strategy/defend flow remains stable.
- 김작 F6 visual QA remains for `v0.68a-4-hotfix6`: confirm the cut-in pops from small scale into a fast overshoot punch, exits upward while shrinking/fading, does not linger or feel like buffering, has no scale/position accumulation on repeated unique skills, and preserves UI, status badge fix6, damage/buff/FX, camera shake, and normal attack/strategy/defend flow.

## Important Direction
- Keep the current battle screen interaction baseline stable before new UX/art expansion.
- Enemy AI multi-target engagement is completed stable functionality, not an open known-issue track.
- Scene portrait textures are not the final identity source of truth.
- `capacity_slot_id -> assigned_hero_id -> HERO_REGISTRY` remains the intended identity path.
- Worldmap integration should build on the current stable `5v5` roster/battle contract path.
- The battle engine must not choose heroes directly; it should consume future `BattleContext.roster`.
- Worldmap / army systems own encounter creation, battle type, terrain, region, and `map_variant_id` selection.
- BattleEngine must not directly consume global world state.
- Contract docs for this direction live in `agent/WORLDMAP_RULES.md`, `agent/HERO_DATA_CONTRACT.md`, `agent/ARMY_DEPLOYMENT_RULES.md`, `agent/BATTLE_CONTEXT_CONTRACT.md`, `agent/BATTLE_ENGINE_RULES.md`, and `agent/SKILL_SYSTEM_RULES.md`.

## Do Not Break
Canonical regression guard details are also tracked in `agent/QA_AGENT.md`.

- Damage / move / attack formulas.
- Hero identity registry behavior.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback / cancel behavior.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.
## v0.68b-12b-28 Handoff
- Deployment UX polish is in `scripts/player_attack_deployment_panel.gd` and player_attack feedback copy is in `scripts/worldmap_test.gd`.
- Panel now shows source/target, source troops, max deployable troops, total assigned troops, remaining garrison, and supply enough/shortage lines.
- Confirm is blocked with visible reason for no selected hero, zero troops, source reserve violation, troop overflow, and food/gold/salt shortage.
- Confirm feedback logs `[PLAYER_ATTACK_DEPLOY]` and sets WorldMap status with assigned troop and supply consumption.
- Player attack result summary now uses clearer occupation/failure copy; owner/troop logic is unchanged.
- F6 manual QA was not performed by Codex in this environment; verify panel size/position, SpinBox input, supply shortage states, sortie transition, victory/defeat result, save/load, and enemy invasion regression.

## v0.68b-12b-32 Handoff
- CommandRank/commandLimit parity is implemented in `scripts/worldmap_test.gd` and surfaced in `scripts/player_attack_deployment_panel.gd`.
- Web constants are mirrored: `governor=10000`, `general=8000`, `lieutenant=6000`, `officer=5000`; unknown rank falls back to officer, and legacy `captain` maps to `lieutenant`.
- A city governor receives governor command rank for allocation without changing hero data.
- Player attack deployment rows now show command label/limit, and SpinBox max is capped by `min(command_limit, source_city_troops - 1)`.
- Confirm validation clamps allocation by command limit and remaining source garrison before source troop pre-decrement.
- Enemy invasion defense default allocation and player attack defender allocation now use commandLimit distribution; the old even allocation helper remains as fallback.
- F6 manual QA remains required for visible command-limit display, over-limit input blocking, player attack win/loss troop accounting, enemy invasion defense win/loss, and woundedQueue save/load/recovery.

## v0.68b-12b-33D Handoff
- `PlayerAttackDeploymentPanel` is now shared by player attack and enemy invasion defense through `deployment_type`.
- Manual/auto defense buttons call `_open_defense_deployment_panel_from_pending_invasion()` instead of immediate battle handoff.
- Defense mode panel title/copy changes to 방어 준비 / 방어 확정 and suppresses extra supply-cost validation.
- Defense confirm path is `_confirm_defense_deployment()` -> `_build_battle_context_from_pending_invasion(..., selected_defender_hero_ids, allocation)` -> existing attacker/defender pre-decrement -> battle handoff.
- BattleContext now carries `selected_defender_hero_ids`, selected `defender_troop_allocation`, `defender_total_allocated_troops`, and existing before/after pre-decrement metadata.
- Cancel only closes the panel/status and keeps `pending_invasion_event`.
- F6 QA still needed: invasion popup -> defense panel open, defender selection/allocation, commandLimit clamp, battle transition, defense victory/defeat accounting, woundedQueue recovery, and player attack regression.

## v0.68b-12b-27 Handoff
- Player attack no longer jumps directly into `Battle_Fullscreen_Test.tscn`; `_start_player_attack_battle()` opens `PlayerAttackDeploymentPanel`.
- New script: `scripts/player_attack_deployment_panel.gd`.
- Confirm path: panel `deployment_confirmed` -> `_confirm_player_attack_deployment()` -> source-city supply validation/payment -> `_build_player_attack_battle_context(..., selected_hero_ids, allocation, supply_cost)` -> existing battle handoff.
- BattleContext now carries `selected_attacker_hero_ids`, `attacker_troop_allocation`, `supply_cost`, and `supply_source_city_id`.
- Source-city supply stock is runtime city state `resource_stock`; missing food/rice, gold, or salt is defaulted only for the source city when opening deployment. Save/load persists this field in `worldmap_city_state`.
- Manual QA still needed for F6 click flow, UI sizing, insufficient resource blocking, post-deployment win/loss result, and save/load after source-city supply payment.
