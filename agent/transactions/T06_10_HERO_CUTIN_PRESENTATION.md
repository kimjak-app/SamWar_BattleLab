# T06-10 Hero Cutin & Battle Presentation

## Status

`T06-10A VIDEO-BACKED PRACTICE PREVIEW IMPLEMENTED / USER VISUAL QA PENDING`

`T06-10B CHEOK JUN-GYEONG ACTION VIDEO CUTIN PREVIEW IMPLEMENTED / USER VISUAL QA PENDING`

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
- q10 Theora (q:v 10, GOP 30, Vorbis q:a 5) is the default comparison target; legacy q8 remains selectable. A VP9 CRF16/Opus WebM comparison file was generated, but this Godot build returns `No loader found` for WebM `VideoStream`, so it is deliberately not connected to the preview.

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
