# T06-10 Hero Cutin & Battle Presentation

## Status

`T06-10A STANDALONE PREVIEW IMPLEMENTED / USER VISUAL QA PENDING`

## T06-10A Scope

- A standalone F6 preview scene is implemented before any battle connection.
- `scenes/debug/hero_cutin_preview.tscn` compares two Gwanggaeto cutin image styles.
  - Mode A: foreground image with dark stage, radial burst, speed lines, flash, and text.
  - Mode B: full skill background with restrained push-in, flash, and text.
- The preview reads Gwanggaeto's canonical unique-skill display name through `HeroDesignDataRegistry` (`영락대제`).
- Playback controls include replay, loop, three presentation-strength presets, and 0.75x / 1.0x / 1.25x speed selection.
- Replay kills and resets active tween state before a new sequence; loop completion resets the stage before scheduling its next run.

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
