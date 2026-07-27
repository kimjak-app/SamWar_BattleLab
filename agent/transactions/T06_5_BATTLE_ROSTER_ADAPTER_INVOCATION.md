# T06-5 Battle Roster Adapter Invocation

Status: `BRIDGE IMPLEMENTED / GUARDED PATCH AND GODOT QA PENDING`

## Purpose

Invoke the T06-4 battle design adapter exactly once when WorldMap hero contracts are registered inside `Battle_Land`, while preserving every legacy combat and persistence field.

## Implemented Files

- `scripts/battle/hero_battle_design_invocation.gd`
- `tools/apply_t06_5_battle_adapter_invocation.py`

## Invocation Point

The audited target is `_register_worldmap_context_hero_contracts()` in `scripts/battle_web_import_test.gd`.

For each incoming WorldMap hero Dictionary:

1. duplicate the legacy hero contract,
2. call `HeroBattleDesignInvocation.enrich_worldmap_hero_contract()`,
3. continue the existing registry-entry and skill-entry builders with the enriched copy.

## Protected Boundary

The adapter adds only namespaced design fields:

- `design_stats`
- `design_battle_multipliers`
- `design_profile`
- `design_unit_rule`
- `design_primary_role_rule`
- `design_secondary_role`
- `design_unique_skill`

It must not overwrite legacy:

- `attack`, `defense`, `war`, `command`
- `troops`, `troop_count`, `max_troops`, `max_hp`
- `move_range`, `attack_range`, `skill_range`
- `unique_skill_id`, `skill_id`, `skill_power`, `skill_cooldown`
- faction/city/save/BattleContext fields

No six-unit behavior, role passive, momentum, or new unique-skill execution is activated in T06-5.

## Guarded Patch

Run from repository root:

```bash
python tools/apply_t06_5_battle_adapter_invocation.py
```

The patcher:

- inserts exactly one preload,
- replaces exactly one audited hero-data assignment,
- aborts if either source anchor is absent or duplicated,
- is idempotent.

Expected first-run output:

```text
T06-5 PATCH APPLIED: battle hero contracts now receive design namespaces
```

Expected repeated-run output:

```text
T06-5 PATCH ALREADY APPLIED
```

## Required Godot QA

- Godot parse succeeds.
- WorldMap enters normally.
- Both player-attack and enemy-invasion battles enter and return normally.
- Existing damage, movement, troop accounting, and skill behavior remain unchanged.
- Save/load remains unchanged.
- Output contains no new errors or warnings.

## Exit Gate

After guarded patch and Godot QA PASS, T06-5 may be locked complete. The next bounded transaction may expose the attached design profile in diagnostics/UI or begin six-unit behavior one rule at a time; it may not activate all new combat rules at once.
