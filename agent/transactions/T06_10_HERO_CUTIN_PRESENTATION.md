# T06-10 Hero Cutin & Battle Presentation

## Status

`T06-10A VIDEO-BACKED PRACTICE PREVIEW IMPLEMENTED / USER VISUAL QA PENDING`

`T06-10B-hotfix2 CHEOK JUN-GYEONG ACTION CUTIN MASTER IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER F6 VISUAL QA PENDING`

`T06-10B-hotfix3 CHEOK JUN-GYEONG READABILITY CORRECTION IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER F6 VISUAL QA PENDING`

`T06-10B-hotfix5 CHEOK JUN-GYEONG TEXT STYLING IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER F6 VISUAL QA PENDING`

`T06-10C REUSABLE HERO CUTIN PRESENTATION IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER F6 REGRESSION QA PENDING`

`T06-10D KOREA MVP 13-HERO CUTIN ASSET NORMALIZATION, REGISTRY & CAROUSEL IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER 13-HERO F6 VISUAL QA PENDING`

`T06-10D-hotfix1 KOREA MVP 13-HERO FINAL DIALOGUE REGISTRY IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER 13-HERO DIALOGUE F6 QA PENDING`

`T06-10E KOREA MVP DIALOGUE VERTICAL LIFT & PER-HERO X OFFSET CALIBRATION IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER 13-HERO POSITION F6 QA PENDING`

`T06-10E-hotfix1 KOREA MVP CUTIN FINAL MICRO X-AXIS ALIGNMENT IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER FINAL CUTIN F6 QA PENDING`

`T06-10E-hotfix2 KOREA MVP CUTIN FINAL 4PX TEXT MICRO ALIGNMENT IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER FINAL CUTIN F6 QA PENDING`

`T06-10E-hotfix3 KOREA MVP FINAL 3-HERO CUTIN TEXT ALIGNMENT LOCK IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER FINAL CUTIN F6 QA PENDING`

## T06-10E-hotfix3 Final 3-Hero Text Alignment Lock

- The remaining F6 QA corrections are locked in the registry only: `kim_yu_sin` dialogue `+28 → +32`; `heukchi_sangji` name `-10 → -14` and dialogue `+32 → +36`; `kwon_yul` dialogue `+30 → +34`. The actual pre-hotfix values matched the expected hotfix2 baseline, so no reconciliation was required.
- No other hero offset, string, Y value, font, size, video/PNG, timing, crop, CutinStage, or common authored transform changed. The existing relative formula and reset/replay/loop protections are retained.
- Automated smoke verified all 13 configured positions, unchanged other ten heroes, 52 natural auto-cycle completions with no duplicate advance, and common/Cheok/carousel headless scene loading. The pre-existing uncommitted carousel scene UID/editor metadata remains outside this transaction.
- The 13-hero visual calibration phase is now locked pending final user F6 approval. Next planned scope is `T06-10F Actual Battle Unique Skill Cutin Integration`; it is not implemented by this work.

## T06-10E-hotfix2 Final 4px Text Micro Alignment

- User F6 QA retained the approved common composition and requested only the final 4px X-axis adjustments. The stored final hero-name offsets are `yi_sun_sin +12`, `uija_wang +4`, `jang_bo_go +4`, `gyebaek +10`, `kwon_yul +10`, `dorim +10`, and `heukchi_sangji -10`.
- The stored final dialogue offsets are `kim_yu_sin +28`, `heukchi_sangji +32`, `kwon_yul +30`, and `jang_bo_go +18`. All other dialogue values remain as approved; no Y, text, font, asset, crop, timing, or CutinStage value changed.
- The existing registry-relative composition remains authoritative: captured scene transform + one stored X override + the already-approved dialogue common Y lift. Reset/replay/loop cannot accumulate these adjustments.
- The headless carousel smoke verified all 13 final values, natural auto-cycle completion 53 times with one auto advance per completion, and loading of the common presentation, Cheok preview, and carousel. The pre-existing uncommitted carousel scene UID/editor metadata change is preserved outside this transaction.
- This finishes the visual micro-alignment pass; the next deferred integration is actual unique-skill invocation, which remains unimplemented.

## T06-10E-hotfix1 Final Micro X-Axis Alignment

- User carousel QA approved the common structure and dialogue Y lift, and requested only visible text X-axis corrections. The registry now supplies `hero_name_offset_x` for `yi_sun_sin +8`, `gyebaek +6`, `kwon_yul +6`, `dorim +6`, and `heukchi_sangji -6`.
- Final dialogue X overrides are `yi_sun_sin +22`, `kim_yu_sin +24`, `heukchi_sangji +28`, and `kwon_yul +26`. The remaining values are retained: `uija_wang +18`, `kim_chun_chu +18`, `jeong_do_jeon +14`, `jang_bo_go +22`, `gyebaek +18`, and `0` for `gwanggaeto`, `eulji_mundeok`, `dorim`, and `cheok_jun_gyeong`.
- `HeroCutinPresentation` composes both final targets from captured scene-authored positions plus X-only registry offsets; its original entry offsets remain relative. This protects reset/replay/loop from accumulating movement and preserves the common dialogue `Vector2(0, -9)` lift.
- `uija_wang` and `gwanggaeto` intentionally received no new micro alignment. Automated smoke verified all 13 final targets, exactly five name and nine dialogue override fields, 52 natural carousel auto-cycle completions without duplicate advance, and unchanged title position/scale, dialogue font size, common scene, and Cheok preview loading.
- Next step: actual unique-skill invocation connection. This hotfix does not change video/PNG assets, dialogue strings, fonts, sizes, crop, timing, CutinStage, or battle flow.

## T06-10E Dialogue Position Calibration

- The 13-hero F6 carousel QA identified the dialogue layer as visually too close to the bottom frame. The reusable presentation now applies one relative common layout offset, `dialogue_layout_offset = Vector2(0, -9)`, to the captured scene-authored dialogue position. No scene transform is overwritten.
- The registry adds X-only `dialogue_offset_x` overrides for `yi_sun_sin +14`, `uija_wang +18`, `kim_yu_sin +16`, `kim_chun_chu +18`, `jeong_do_jeon +14`, `jang_bo_go +22`, `heukchi_sangji +20`, `gyebaek +18`, and `kwon_yul +18`. `gwanggaeto`, `eulji_mundeok`, `dorim`, and `cheok_jun_gyeong` deliberately have no X override.
- The component composes the final dialogue target from captured authored position + common Y lift + current hero X override. Its enter offset remains relative to that target; reset, replay, loop, and carousel switching restore it without cumulative movement.
- Automated smoke confirmed all 13 targets at y=341 (authored y=350 minus 9), exact X mappings, 52 natural auto-cycle completions, no duplicate auto-advance handling, unchanged hero-name/title position and title scale, dialogue font size 29, and common/Carousel/Cheok preview scene loading. Video-only dialogue hiding remains covered by the preceding dialogue carousel smoke.
- Next step: actual battle unique-skill connection. No battle connection, asset, dialogue, font, timing, crop, hero-name, or title-PNG change is included in this calibration.

## T06-10D-hotfix1 Final Dialogue Registry Correction

- The user supplied and finalized all 13 Korea MVP dialogue strings. `data/cutin/korea_mvp_hero_cutins.json` now stores each exact unquoted, trimmed dialogue; all `dialogue_status` and `missing_authoritative_source` fields are removed.
- The carousel no longer contains the missing-dialogue notice node or fallback path. Every registry configure call supplies the final dialogue directly to the common presentation. Video-only mode continues to hide its text layers through the unchanged common-component API.
- Headless validation confirmed 13 non-empty exact strings with no outer whitespace or quote characters, 13 configure results, Replay/reset persistence, forward/backward wrap, and 52 natural `cutin_finished` auto-cycle advances without duplicate auto-advance handling.
- At the authored 396px dialogue-label width, `gwanggaeto` measures 504px and is the only line exceeding the original authored width. Godot resolves its effective minimum width to 504px so the automated one-line check passes; it is an explicit T06-10E visual-QA candidate. All other source measurements are at or below 396px (the closest are `jang_bo_go` 388px and `gyebaek` 380px). No font, size, transform, crop, title, or timeline adjustment was made here.
- Next: `T06-10E 13-Hero Dialogue & Visual Exception Calibration`. Battle invocation remains unimplemented.

## T06-10D Korea MVP Asset Registry & Carousel

- The reusable presentation's user regression QA is recorded as passed; its approved Cheok Jun-gyeong layout, font treatment, crop, and timeline are unchanged.
- The tracked title assets were normalized: `kim_yu_sin__samguk_tongil__title.png` → `kim_yu_sin__samhan_tongil__title.png` and `gye_baek__baekje_buheung__title.png` → `gye_baek__hwangsan_beol__title.png`, with their Godot `.import` metadata updated by the editor import pass.
- The 13-item authoritative presentation registry is `data/cutin/korea_mvp_hero_cutins.json`; `scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd` loads it for presentation clients. It holds canonical hero/skill IDs and display names from generated hero data, asset paths, enabled state, and a dialogue provenance status.
- The approved Cheok OGV is retained unchanged. The other 12 source MP4s remain preserved under `assets/video_source_test/production_dry_run/korea_mvp/` and were converted to `assets/ui/cutin/videos/*__cutin_bg_theora_q8_1280x720.ogv` with the previously approved safe video-only setting: `-map 0:v:0 -an -vf fps=30,scale=1280:720:flags=bilinear,format=yuv420p -c:v libtheora -q:v 8 -g 1`.
- `scenes/debug/korea_mvp_hero_cutin_carousel_preview.tscn` is the 13-hero F6 QA wrapper. Its controls support previous/next (Left/Right), Play (Space/Enter), Replay (R), auto-cycle (L), video-only (V), 0.75x/1.0x/1.25x, and Escape stop/reset. It injects registry resources into the common component; no 13 individual cutin scenes were duplicated.
- Only Cheok Jun-gyeong has an authoritative cutin dialogue source in the current repository. The other 12 entries deliberately omit a dialogue value and are marked `missing_authoritative_source`; carousel QA shows an explicit metadata notice while leaving the in-stage dialogue layer blank. No temporary lines were invented.
- Automated checks: all 13 OGVs are Theora, 1280×720, 30fps, video-only, 4.000s, and passed full decode plus 0.10s/2.00s/3.50s extraction. Registry parity, 13 resource loads/configures, scene-authored reset, carousel forward/backward wrap, and 53 natural completion-signal auto-cycle advances passed headless smoke.
- Next step: T06-10E identifies only visually necessary per-hero exceptions through F6. Actual battle invocation, battle pause/resume, player/AI linkage, and any combat rules remain unimplemented.

## T06-10A Scope

- A standalone F6 preview scene is implemented before any battle connection.
- `scenes/debug/hero_cutin_preview.tscn` compares two Gwanggaeto cutin image styles.
  - Mode A: foreground image with dark stage, radial burst, speed lines, flash, and text.
  - Mode B: full skill background with restrained push-in, flash, and text.
- The preview reads Gwanggaeto's canonical unique-skill display name through `HeroDesignDataRegistry` (`영락대제`).
- Playback controls include replay, loop, three presentation-strength presets, and 0.75x / 1.0x / 1.25x speed selection.
- Replay kills and resets active tween state before a new sequence; loop completion resets the stage before scheduling its next run.

## T06-10A-hotfix1 Visual Quality Correction

- The user-supplied RGBA foreground PNG is preserved and included in the hotfix baseline; it has real non-opaque alpha pixels and is not edited by this task.
- Mode A now fills the presentation area with a large, right-weighted foreground hero, dark red-black gradient stage, layered radial light, diagonal speed lines, ember/dust light fragments, and a short stage shake.
- Mode B retains cover-cropped full-background framing with restrained push-in/pan and reduced effect density so the source artwork remains readable.
- Both modes use a rapid white-to-pale-gold flash with preset-limited opacity rather than the old opaque yellow rectangle effect.
- Hero and canonical skill labels use a larger lower-left title treatment. The control panel hides while playback is active and is restored on completion or Escape.
- Replay, mode changes, loop callbacks, and scene exit kill/reset active tween state before new playback.

## T06-10A-hotfix2 Duel-Style Mode A Rebuild

- Mode A is rebuilt as a single approximately 1.89-second duel-style impact timeline instead of preset-scaled particle tuning: black-red ignition, large right-side Gwanggaeto entry, central `영락대제` title burst, readable standoff, white-gold decision flash, and rapid exit.
- `CutinRoot` now owns the impact shake and always restores its captured scene position. `HeroPortrait` and the central `TitleContainer` each restore their authored position, scale, alpha, and pivot-centered title state before replay.
- The canonical skill display name remains read from `HeroDesignDataRegistry`; generated hero data is untouched.
- Mode B remains a separate restrained full-background path. Strength controls are hidden for this QA so Mode A is evaluated as one fixed composition.

## T06-10A-hotfix4 Video-Backed Practice Preview

- The project convention is `VideoStreamPlayer` with a Theora `.ogv` `VideoStream`; the supplied H.264/AAC MP4 is retained unchanged as the source asset.
- `assets/battle/cutins/common/vfx/red_burst_backlight_01.ogv` is a 1280×720, video-only Theora conversion that preserves the Grok source resolution and is the Mode A playback target. The 16:9 player fits the 1152×648 viewport without crop or zoom; hero PNG and title remain separate Godot layers.
- Mode A seeks to the selected burst segment before every play, then layers the large foreground PNG and pivot-centered canonical skill title over the red video background.
- Replay, Escape, mode switches, completion, and auto-loop stop/reset the video player together with the visual tween state. Mode B remains the still-background comparison path.
- Mode A keeps the native-scale 16:9 video center-aligned and shifts the hero's final authored position left so the face and breastplate, rather than the PNG bounding box, align with the screen and burst center. The final flash now fades within 0.09 seconds.
- Mode A now uses the existing specialty video cutin reference rect as an explicit centered `CutinStage` (`1014×415` at approximately `(69,117)` for the 1152×648 viewport). The video, hero, and title use its local coordinates; the hidden stage-center guide at local x=507 anchors the hero's face/breastplate alignment. The q8 OGV is unchanged.
- Mode A foreground correction: HeroPortrait is immediately shown with white `modulate` and `self_modulate`, maintains `Vector2.ONE` scale, is not shaken, and remains above dim/backlight/particle layers through explicit z-order. FlashOverlay is hidden and held at alpha zero for Mode A; completion is a short foreground fade to the black stage, not a white screen flash.

## T06-10B Cheok Jun-gyeong Action Video Preview

- `cheok_jun_gyeong_cutin_source_04s.mp4` is preserved; its 1920×1080 H.264/AAC source was converted to the existing q8 Theora/Vorbis convention at `assets/ui/cutin/videos/cheok_jun_gyeong_cutin_bg_theora_q8_1920x.ogv`.
- The standalone F6 scene uses the existing 1014×415 centered video-cut-in rect, clips the 16:9 video to its stage, and leaves video colour, brightness, alpha, and scale unfiltered.
- The preview reads canonical `cheok_jun_gyeong` skill metadata for `검왕돌파`, with a left-side `척준경` support title and impact/settle/exit title choreography. It does not alter battle integration or the Gwanggaeto preview.
- The 1080p q8 Theora comparison reproduces the user-reported block/corruption issue. A separately encoded 1280×720 q8 Theora (`q:v 8`, GOP 60, Vorbis `q:a 4`) passes complete FFmpeg decode validation and a 1-second PNG frame extraction, and is the preview's default stream. The selector presents only `1080p q8 Theora` and `720p q8 Theora (verified)` using the identical player rect, crop, position, and speed.
- The earlier q10 Theora and VP9 CRF16/Opus WebM comparison files remain preserved for codec research, but are not the default playback target. This Godot build returns `No loader found` for the VP9 WebM `VideoStream`, so it remains deliberately disconnected.

## T06-10B-hotfix2 Cheok Jun-gyeong Final Master Preview

- The master F6 preview remains the existing `scenes/debug/cheok_jun_gyeong_action_cutin_preview.tscn`; it is not connected to battle flow, hero registry, save data, or another hero.
- The supplied Korea MVP source is `assets/video_source_test/production_dry_run/korea_mvp/cheok_jun_gyeong__geomwang_dolpa__cutin_source_04s_silent.mp4`. Its SHA-256 differs from the earlier `assets/video_source_test/production_dry_run/cheok_jun_gyeong_cutin_source_04s.mp4`, so the default OGV was regenerated from the Korea MVP source.
- The sole default stream is `assets/ui/cutin/videos/cheok_jun_gyeong_cutin_bg_theora_q8_1280x720_verified.ogv`: Theora video only, 1280×720, CFR 30fps, duration 4.000 seconds. The safe output uses `fps=30,scale=1280:720:flags=bilinear,format=yuv420p`, `libtheora`, `q:v 8`, and GOP 1. GOP 1 was selected because q8 GOP 60 and GOP 30 outputs from the available local FFmpeg decoder failed complete decode; it preserves q8 while eliminating late packet corruption. No audio stream is present in the final OGV.
- The skill title is the supplied PNG at `assets/ui/cutin/titles/cheok_jun_gyeong__geomwang_dolpa__title.png`, displayed unchanged as a `TextureRect`; it is not regenerated as label text, recoloured, blurred, or given glow.
- The clipped 1014×415 `CutinStage` remains centered at `(69,117)` in the 1152×648 viewport. Its independent visual layers are `VideoBackgroundPlayer`, `HeroNameLabel` (`척준경`), `SkillTitlePng` (`검왕돌파` PNG), and `DialogueLabel` (`내 앞을 막는 자, 목을 내놔라!`). The thin stage border is retained but hidden by default.
- At 1.0x, the name enters at 0.12s, the title PNG impacts at 0.52s, and the dialogue enters at 1.05s. They begin independent exits at 3.28s, 3.38s, and 3.48s respectively, before the 4.00s video end. Replay, loop, Escape, and scene exit kill all root/layer tweens, stop/rewind the player, and restore authored positions, scale, and alpha before any next run.
- Automated video verification passed: `ffprobe` reports Theora / 1280×720 / `30/1` / 4.000s / video-only; full FFmpeg decode with `-xerror` succeeds; 1.0s, 2.0s, and 3.5s frame extraction succeeds. Headless project and master-scene validation also pass.
- Kimjak F6 visual QA remains required for video quality and ending decode, crop/aspect, name/title/dialogue placement and readability, timing/rhythm, replay/loop reset, video-only versus composite, and absence of black empty frames. Korea-MVP 13-hero common data and battle unique-skill integration remain explicitly unimplemented.

## T06-10B-hotfix3 Cheok Jun-gyeong Readability & Text Block Correction

- F6 first-pass QA confirmed the name, `검왕돌파` PNG, dialogue, and video all render. The required correction is readability: the prior name was visually detached in the upper-left, the elements exited too separately, and the dialogue had too little stable reading time.
- The three layers remain independent nodes, but now read as one left-side vertical block within `CutinStage`: name at `(180,70)`, title PNG at `(72,116)` with authored scale `(0.92,0.92)`, and dialogue at `(92,340)`. The name center aligns to the visible-title center rather than the viewport center; the dialogue remains below the title, above the stage edge, and retains the existing outline without a background panel.
- `scripts/debug/cheok_jun_gyeong_action_cutin_preview.gd` now owns the single authored configuration area for positions, scales, entry offsets, entry start/duration, shared hold end, exit duration, and total duration. `_reset()` restores those authored values before every replay or loop.
- At 1.0x: name enters from 0.12s to 0.32s; title impacts from 0.32s to 0.58s (`0.90 → 1.04 → 1.00` relative scale); dialogue enters from 0.65s to 0.88s. All three remain fully visible together from 0.88s to 3.25s (2.37s), then make the same short 0.30s exit and are cleared by 3.55s.
- Future battle integration contract: do not recreate this approved CutinStage-internal composition ad hoc. The 13-hero commonization step must elevate this structure and authored baseline into a reusable presentation component; battle invokes that component. Battle connection may vary hero video, name, title PNG, dialogue, and explicit hero overrides only, not the approved default layout or timeline.
- Automated scene load, script parse, and replay/loop/reset smoke remain required; F6 re-review is pending for block cohesion, title/face clearance, dialogue readability, stable hold, and identical repeated playback. No video, CutinStage geometry, combat behavior, persistence, or battle integration changes are included.

## T06-10B-hotfix5 Cheok Jun-gyeong Font & Dialogue Styling Correction

- The repository-supplied Noto Serif KR assets are used only by this preview: `assets/font/noto_serif_kr/NotoSerifKR-Bold.otf` for `HeroNameLabel` and `assets/font/noto_serif_kr/NotoSerifKR-Medium.otf` for `DialogueLabel`.
- Both labels use scene-local `theme_override_fonts/font`, retain their existing scene-authored transform, and add restrained dark `font_shadow_color` with 2px horizontal and 2–3px vertical shadow offsets while keeping the existing outline treatment. `SkillTitlePng` remains the unchanged supplied PNG.
- The final dialogue output is the unquoted plain text `내 앞을 막는 자, 목을 내놔라!`; no quotation or alternate brackets are applied.
- The hotfix preserves the capture/reset contract: 2D-editor position and scale remain the source of truth, and replay/loop restore captured scene transforms. F6 visual QA remains pending for font tone, one-line dialogue fit, shadow/outline feel, and text-block cohesion.

## T06-10C Reusable Hero Cutin Presentation Component

- Cheok Jun-gyeong's approved F6 master is now the visual baseline for the reusable component at `scenes/ui/cutin/hero_cutin_presentation.tscn`, with playback logic at `scripts/ui/cutin/hero_cutin_presentation.gd`.
- The public component API is `configure(hero_name, dialogue, video_stream, skill_title_texture)`, `set_playback_speed(value)`, `play_cutin(show_text_layers := true)`, `replay_cutin(show_text_layers := true)`, `stop_cutin()`, and `reset_cutin()`. `cutin_finished` emits once at the natural end of each playback for later battle follow-up.
- The reusable scene retains the approved `CutinStage`, video crop, HeroNameLabel Bold Noto Serif KR override, SkillTitlePng transform, DialogueLabel default sans fallback at size 29, outline, shadow, and all approved timing values. Its three text-layer transforms are captured once from the common scene and reset/replay restores those captured values; animation offsets remain relative.
- `scenes/debug/cheok_jun_gyeong_action_cutin_preview.tscn` is preserved as the F6 wrapper. It now instantiates the reusable presentation and injects only Cheok Jun-gyeong's approved name, dialogue, 720p OGV, and title PNG; the wrapper retains Play/Replay, loop, speed, video-only, and Escape controls.
- Automated verification covers common-scene and wrapper loading, resource injection, approved font fallback/override, completion signal exactly once for one natural play, Replay, two loop completions, and reset restoration of scene-authored layout. User F6 regression QA remains required because the master is now rendered through an instantiated common scene.
- The next step is limited to 13-hero cutin data plus their OGV/title assets and explicit per-hero overrides where approved. Actual battle invocation, battle stop/resume, AI skills, and any visual retuning remain out of scope.

## Explicitly Deferred

- No actual battle unique-skill call is connected.
- Existing video cutins and their normal call flow are unchanged.
- No other Korea hero is included; China and Japan heroes remain out of scope.
- Sound is still a later polish concern.

## Asset Finding

- Both supplied PNGs load at `1672 x 941`.
- `gwanggaeto_cutin_foreground.png` has PNG colour type 2 (truecolour, no alpha); the visible checkerboard is baked into the image rather than runtime transparency. It is intentionally not edited or masked in this experiment.
- `gwanggaeto_skill_background.png` is also PNG colour type 2. The preview uses aspect-preserving expand/crop behavior; visual crop and text placement remain user-QA items.

## Contract Safety

- No authoritative hero JSON, battle calculation, WorldMap handoff, or save schema changed.
- This preview owns presentation-only state and is not instantiated by battle scenes.
