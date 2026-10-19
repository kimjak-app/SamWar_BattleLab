# B-1H | Execution Brief — BattleUniqueSkillBuffStateService

Repository: `kimjak-app/SamWar_BattleLab`  
Base branch: `integration/p1-engine-core-20261019` (new branch: `refactor/b1h-unique-skill-buff-state-20261019`)  
Plan revision: `BRP-20260919-1`  
Audit: `agent/BATTLE_ENGINE_B1H_UNIQUE_SKILL_BUFF_STATE_AUDIT_20261019.md`  
Common rules: `.agents/skills/samwar-dev/SKILL.md`. This brief lists deltas only.

## Goal

Move only the three unique-skill buff dictionaries into a focused RefCounted state service. No gameplay change, no snapshot change.

## Required service

`scripts/battle/services/battle_unique_skill_buff_state_service.gd` (+ tracked `.gd.uid`)

```gdscript
clear()
has_active_attack_buff(key: String) -> bool
get_attack_buff_bonus(key: String) -> int
set_attack_buff(key: String, bonus: int, turns: int)
get_defense_buff_bonus(key: String) -> int
set_defense_buff(key: String, bonus: int)
tick_attack_buff(key: String) -> Dictionary   # {"expired": bool, "restore_bonus": int}
```

## Compatibility locks

Controller wrappers stay with identical names/signatures: `_get_unique_skill_attack_buff_key`, `_has_active_unique_skill_attack_buff`, `_get_unique_skill_attack_buff_bonus`, `_set_unique_skill_attack_buff_state`, `_get_unique_skill_defense_buff_key`, `_get_unique_skill_defense_buff_bonus`, `_set_unique_skill_defense_buff_state`, `_tick_unique_skill_attack_buffs_for_side`.

1. Key resolution stays in the controller. Empty key -> wrapper returns early, as today.
2. `unit_state.attack` / `defense` mutation stays in the controller. The service returns `restore_bonus`; the controller applies `unit_state.attack = maxi(0, unit_state.attack - restore_bonus)` only when `restore_bonus > 0`.
3. Preserve the audit's six asymmetries exactly (defense never expires and max-merges; attack getter 0 when turns <= 0; attack setter overwrites and clamps turns >= 0; tick restores only when bonus > 0; expired entries erase both turns and bonus).
4. `_tick_unique_skill_attack_buffs_for_side(side)` keeps its loop over `_get_alive_deployed_unit_states_for_side(side)` and ends with `_refresh_formation_slot_guides()` then `_refresh_strategy_status_icon_labels()`.
5. `_tick_unique_skill_cooldowns_for_side` still ticks cooldowns first, then buffs.
6. `reset_demo_state()` calls `clear()` on the service instead of clearing three dictionaries.
7. **No resume wiring.** Do not add buffs to the snapshot, do not change `cooldowns`, no schema/version change.

## Forbidden service ownership

`BattleUnitState`, skill metadata, side/phase/round, cooldowns, AI policy, GameSession, BattleRuntimeSnapshot, UI, logs, FX, WorldMap, BattleContext, BattleResult, signals, await, tween, audio, Node/scene APIs.

## Do not touch

`scripts/worldmap/**`, `WorldMap.tscn`, `scenes/**`, `project.godot`, existing services, existing validators/tests (read-only), `scripts/battle3d/**` (parallel 3D work).

## Validation (Level 2)

1. New `tests/scripts/test_battle_unique_skill_buff_state_service.gd` pinning each asymmetry with its own check, ending `PASS: N checks`.
2. New `tools/validate_b1h_battle_unique_skill_buff_state_service.py` modeled on the B-1G validator, including: service is `extends RefCounted`, forbidden tokens absent, the three `var unique_skill_*_buff_*_by_unit_id` declarations no longer in the controller, wrappers delegate, tick order and refresh calls kept, `"cooldowns"` snapshot key unchanged, no buff key added to the snapshot, `scripts/worldmap/` untouched.
3. Register both in the established CI workflow (add lines only).
4. Existing regression stays green: all CI validators and Godot tests, plus B-1E/B-1F/B-1G and movement/combat query tests.
5. `git diff --check` clean; tree clean; push and verify the hash with `git ls-remote`.

## Report must contain

Commit hash + `git ls-remote` proof; changed files; exact test/validator output; anything not run and why (never pack it as PASS); confirmation that no snapshot field was added; any behavior difference noticed (report, do not fix).

## Reviewer gate

클코치 verifies independently: scope guard, diff of controller wrappers against the audit's asymmetries, rerun of new test/validator, negative probes (e.g. making defense expire must fail the test), and Godot parse.
