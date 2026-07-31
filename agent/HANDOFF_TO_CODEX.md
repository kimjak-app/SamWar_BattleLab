# HANDOFF TO CODEX

T06-10F connects the approved Korea MVP registry presentation to `Battle_Land.tscn` at `HeroCutinOverlay/HeroCutinViewport/HeroCutinPresentation`.

- Common invocation is `_begin_unique_skill_sequence` after `BattleSkillResolver.build_plan` succeeds and `battle_momentum.spend` returns true. Both player and AI reach this function.
- `_play_committed_hero_cutin` requires canonical `hero_id`/`skill_id` parity through `KoreaMvpHeroCutinRegistry.find_entry`. It configures the common component, while `_on_hero_cutin_finished` applies the existing pending resolver plan and calls the existing finalizer exactly once.
- `is_unique_skill_presenting`, `is_demo_animating`, and `PHASE_RESOLVING` remain the gameplay/AI lock; the overlay also consumes pointer input. A 4.60-second signal watchdog is only a missing-signal recovery path, not a normal cutin timer.
- Registry/resource mismatch warns with `[HERO_CUTIN]`, skips only presentation, and preserves the committed skill, momentum, resolver, and action-completion contracts.

Next gate is user player+AI battle QA. The next unrelated large task is T06-11 AI multi-unit engagement/surround/cooperative attack correction.
