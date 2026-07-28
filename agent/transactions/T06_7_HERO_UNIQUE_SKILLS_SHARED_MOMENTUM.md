# T06-7 Hero Unique Skills & Shared Momentum Playable Transaction

## Status

`IMPLEMENTED / RUNTIME STATIC VALIDATION PASS / GODOT HEADLESS & F6 QA PENDING`

## Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Starting commit: `f928745d82ed7a4f08735c6e72bbd1b88502040f`
- Delivery rule: one playable transaction; no helper-only intermediate completion

## Player Transaction

1. Both sides start battle with side-shared momentum `3/10`.
2. A successful basic attack gives the acting side `+1` momentum.
3. The selected hero's button shows canonical skill name, individual momentum cost, current shared pool, and description.
4. Skill selection and preview do not charge momentum.
5. `BattleSkillResolver` validates caster, target, range, archetype, commands, and available momentum.
6. Momentum is charged exactly once only after a valid plan exists.
7. The resolver applies damage, healing, status, cleanse, movement, and momentum commands.
8. The action is logged, visual state is refreshed, the unit action is consumed, and the battle loop continues.
9. Cancel, invalid target, and resolver rejection leave momentum unchanged and log no-charge evidence.

## Canonical Runtime Direction

`hero_unique_skills.json`
→ `HeroDesignDataRegistry`
→ `HeroRuntimeFactory.design_unique_skill`
→ `BattleUnitState.unique_skill_definition`
→ `BattleSkillResolver`
→ battle command application

- The player and AI call the same resolver.
- Runtime lookup no longer uses `UNIQUE_SKILL_REGISTRY` as a fallback.
- Hero names and skill IDs are not hardcoded in resolver execution.

## Resolver Coverage

All 39 canonical effect types map to ten execution archetypes:

- `damage_single`
- `damage_line`
- `damage_area`
- `buff_self`
- `buff_team_area`
- `debuff_single`
- `debuff_area`
- `control_area`
- `restore_dispel`
- `movement_charge`

The resolver emits data commands. Battle presentation and scene state consume commands without owning skill design authority.

## AI Contract

- AI checks the same shared momentum pool and effective per-hero cost.
- AI builds the same resolver plan as the player.
- AI plan value is scored from executable commands: damage, kill value, healing, status, cleanse, momentum, and movement.
- AI cannot bypass cost, target, range, or resolver validation.

## Save & Resume

- `GameSession` persists `user://battle_runtime_resume.json`.
- The snapshot stores battle ID, round, stable phase, all unit HP/troops/cells/facing/action/status state, side momentum, acted/dead maps, cooldowns, reinforcement/deployment state, battle supply and settlement guards, active unit, and battle log.
- Matching WorldMap battle IDs restore automatically.
- Enemy-phase restore resumes AI by deferred call.
- Completed WorldMap return clears the battle snapshot.
- Mismatched battle IDs and schema versions are rejected.

## UI & Log Evidence

- Top bar: `아군 기세 ◆ N/10`, `적군 기세 ◆ N/10`
- Hero command: `고유기명 · 기세 N`
- Tooltip: description, current pool, maximum, cost
- Logs: basic-attack gain, committed skill spend/remain, skill gain/drain, effect summary, restore, and failure no-charge

## Automated Coverage

- `tools/validate_t06_t07_playable_transaction.py`
  - 39 records
  - every effect type mapped
  - canonical Factory/Unit/Resolver direction
  - player and AI momentum gain/use
  - UI/log evidence
  - snapshot save/load/clear hooks
  - smoke-test presence
- `scripts/t06_t07/t06_t07_playable_transaction_smoke.gd`
  - shared momentum gain/spend/reject/cap/restore
  - all 39 skills build non-empty executable plans
  - battle snapshot roundtrip

## Verification

Passed in Work:

- `python3 tools/validate_t06_t07_playable_transaction.py`
- Tree-sitter GDScript parse for all new/modified modular scripts except the pre-existing 15k-line battle script, which exceeds the parser binding's input handling
- `git diff --check`
- `tools/validate_hero_battle_profile_integration.py`
- `tools/validate_hero_runtime_authority.py`

Environment limitation:

- Godot executable is unavailable in this Work container, so the GDScript smoke and F6 visual/runtime QA remain pending.

Pre-existing baseline validator drift found and intentionally not changed in this runtime transaction:

- `validate_hero_design_registry.py`: committed JSON reports momentum distribution `1/8/20/10`, while the committed validator expects `1/9/18/11`.
- `validate_hero_five_unit_assignment.py`: stale pre-final assignment expects 김춘추 archer.
- `validate_hero_worldmap_stat_integration.py`: references a previously deleted integration script.

## Local Godot Exit Gate

Run:

```text
godot --headless --path . --script res://scripts/t06_t07/t06_t07_playable_transaction_smoke.gd
```

Then F6/F5 confirm:

- both momentum labels start at `3/10`
- player and enemy basic attack add exactly `+1`
- cancel and invalid target spend `0`
- cost 1–4 skills enable only with enough shared momentum
- committed skill spends once and applies visible/logged effects
- AI uses a skill when resolver score and shared momentum permit
- re-entering the same pending battle restores round, units, status, momentum, and log
- battle completion returns to WorldMap and clears resume state

## Protected Scope

- Final workbook-derived JSON values were not regenerated or edited.
- T01–T05 city, faction, troop, supply, occupation, and turn settlement contracts remain unchanged.
- Battle result payload and WorldMap result accounting remain unchanged.
- Existing cutin/VFX presentation is reused; missing 39-hero cutin assets remain a later art transaction.
- Sound remains later polish.
