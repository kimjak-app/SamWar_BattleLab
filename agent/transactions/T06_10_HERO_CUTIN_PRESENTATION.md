# T06-10 Hero Cutin & Battle Presentation

## Status

`T06-10A DUEL-STYLE MODE A REBUILD IMPLEMENTED / USER VISUAL QA PENDING`

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
