# B-1D | Codex Execution Brief — BattleDamageFormulaService

> **Legacy execution note (2026-09-19):** This is a historical B-1x task record. Generic `Read first`, preflight, validation/full-regression, CI, and closeout boilerplate in this file is superseded by `.agents/skills/samwar-dev/SKILL.md`. Preserve this file's task-specific architecture/behavior locks when reviewing history; do not use its old generic checklist to drive a new run.


Repository: `kimjak-app/SamWar_BattleLab`  
Branch: `refactor/engine-core-20260918`

Read first:

- `.agents/skills/samwar-dev/SKILL.md`
- `.agents/skills/samwar-dev/references/refactor.md`
- `.agents/skills/samwar-dev/references/regression.md`
- `.agents/skills/samwar-dev/references/closeout.md`
- `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- `agent/BATTLE_ENGINE_B1D_DAMAGE_FORMULA_AUDIT_20260918.md`
- `agent/BATTLE_ENGINE_RULES.md`

## Goal

Extract only the synchronous pre-wounded damage formula from `scripts/battle_web_import_test.gd` into:

`scripts/battle/services/battle_damage_formula_service.gd`

Recommended:

```gdscript
class_name BattleDamageFormulaService
extends RefCounted
```

Preserve observable battle behavior exactly.

## Mandatory preflight

Before editing:

1. confirm branch is `refactor/engine-core-20260918`;
2. fetch and record local HEAD / origin HEAD / upstream;
3. inspect `git status --short`;
4. protect unrelated user changes; no reset/restore/stash/delete;
5. re-read the current functions from current HEAD;
6. confirm WorldMap still points to `res://Battle_Land.tscn`;
7. confirm B-1C exact-head workflow is green;
8. do not use historical function-map line numbers as execution coordinates.

## Exact implementation boundary

Create one production service only.

Move/delegate:

- angle damage multiplier calculation;
- the synchronous damage multiplier chain;
- gunner prepared-fire/post-fire/armor-ignore formula;
- pre-wounded integer damage result.

Keep controller compatibility wrappers:

- `_get_attack_angle_damage_multiplier`
- `_get_directional_attack_damage`

Do not rewrite the seven existing callers.

## Wounded handling MUST stay in controller

The service must not inspect hero registry or decide whether a hero is wounded.

After service calculation, the existing controller wrapper must still perform:

```gdscript
if apply_attacker_wounded_penalty:
    damage = _apply_wounded_amount_multiplier(attacker_state, "attack", damage, should_log_wounded_penalty)
return _apply_wounded_incoming_damage_penalty(defender_state, damage, should_log_wounded_penalty)
```

Equivalent formatting is fine; behavior and logging must remain identical.

Do not move:

- `_is_unit_hero_wounded`
- `_get_wounded_penalty_multiplier`
- `_apply_wounded_amount_multiplier`
- `_apply_wounded_incoming_damage_penalty`
- `_log_wounded_penalty`

## Formula parity rules

Preserve modifier order exactly as documented in the B-1D audit.

Preserve current default status magnitudes.

Preserve `UnitTypeContract` as authority for:

- damage context;
- matchup data;
- side/rear modifier;
- received modifier;
- gunner prepared-fire bonus;
- gunner armor-ignore ratio.

Preserve exact two-stage rounding:

1. round/clamp after the main multiplier chain;
2. gunner armor-ignore calculation and second round/clamp.

Do not algebraically combine or optimize those stages.

Do not introduce extra null handling or formula fixes not present in the baseline. This is extraction, not rebalance/bug-fix work.

## Skill-call parity

Some current callers already apply wounded skill reduction through `_get_unique_skill_effect_amount` and call directional damage with `apply_attacker_wounded_penalty=false`.

Do not change those flags and do not add a second attacker wounded penalty.

## Forbidden changes

Do not modify behavior in:

- `BattleCombatQueryService`;
- movement/path service;
- attack eligibility/range;
- attack execution or `apply_damage`;
- attack commit state;
- momentum;
- AI scoring/ranking;
- target selection;
- counterattack flow;
- unique-skill amount calculation;
- wound registry lookup/logging;
- animation/FX/audio/UI;
- turn/phase sequencing;
- WorldMap/BattleContext/BattleResult;
- canonical scene routing.

Do not start B-1E.

## Tests

Add:

`tests/scripts/test_battle_damage_formula_service.gd`

Cover every minimum case in the B-1D audit.

Use exact expected integer values where deterministic.

Include representative compatibility-wrapper parity without directly preloading the controller in a way that bypasses required autoload/class-cache setup. The B-1C test fixture bug showed that a script can print PASS after dependency compile errors if the fixture is wrong.

Prefer loading/instantiating `res://scenes/battle/Battle_Main.tscn` for wrapper parity.

If that fixture starts audio, clean it up using the already-established fixture-audio teardown pattern so the test adds no new resource leak.

The test must fail nonzero if wrapper parity cannot actually execute.

## Static validator

Add:

`tools/validate_b1d_battle_damage_formula_service.py`

Wire both the validator and focused test into `.github/workflows/verify-c-track.yml`.

Validator should verify the boundary described in the audit, including that wounded handling remains in controller.

## Validation gate

Run targeted checks first, then the established full workflow.

Required:

- focused damage-formula test;
- B-1D static validator;
- B-1B movement service test;
- B-1C combat query test;
- five-unit-type action eligibility validator;
- battle turn-order regressions;
- Godot 4.6 import/class cache;
- project parse;
- `Battle_Main.tscn` load;
- Imjin ISO scenario load;
- full established workflow;
- `git diff --check`;
- generated `.gd.uid` state understood/clean;
- WorldMap remains on `res://Battle_Land.tscn`.

Audit logs for hidden `SCRIPT ERROR`, `Compile Error`, `Failed to load script`, and `Invalid call` even if the workflow exits zero.

Do not claim Full Green if those appear in the B-1D focused test.

## Closeout

Report:

- branch + exact final HEAD;
- changed files;
- service API;
- controller wrappers;
- exact formula parity coverage;
- focused test check/failure count;
- static validator result;
- hidden-error log scan result;
- full CI run ID/status/head SHA;
- worktree state;
- local/origin ahead/behind;
- remaining pre-existing warnings.

Do not begin another extraction.
