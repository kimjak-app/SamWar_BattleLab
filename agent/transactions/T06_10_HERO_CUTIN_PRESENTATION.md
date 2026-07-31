# T06-10 Hero Cutin & Battle Presentation

## Status

`T06-10A VIDEO-BACKED PRACTICE PREVIEW IMPLEMENTED / USER VISUAL QA PENDING`

`T06-10B-hotfix2 CHEOK JUN-GYEONG ACTION CUTIN MASTER IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER F6 VISUAL QA PENDING`

`T06-10B-hotfix3 CHEOK JUN-GYEONG READABILITY CORRECTION IMPLEMENTED / AUTOMATED VERIFICATION PASS / USER F6 VISUAL QA PENDING`

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
