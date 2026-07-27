# T06 Hero Battle Profile Integration

Status: `IMPLEMENTED / USER GODOT QA PENDING`

## Transaction Goal

Complete one bounded, verifiable Battle-side integration flow from generated 39-hero design data to active BattleUnitState profiles without splitting adapter creation, invocation, unit-profile application, logging, and validation into separate user-facing transactions.

## Included Internal Steps

The earlier T06-4 and T06-5 labels are internal implementation steps of this transaction, not standalone playable transactions:

- read-only JSON loader reuse
- legacy/design contract composition
- Battle scene invocation
- both-side roster enrichment
- six-unit movement/range activation
- primary/secondary role metadata attachment
- design unique-skill metadata attachment without effect activation
- runtime logging and static validation

## Runtime Implementation

- `scripts/battle/hero_battle_design_adapter.gd`
- `scripts/battle/hero_battle_profile_integration.gd`
- `project.godot` Autoload: `HeroBattleProfileIntegration`

The Autoload detects `res://Battle_Land.tscn`, waits for the WorldMap hero registries to be ready, enriches both attacker and defender hero contracts, then applies the approved unit-type movement and attack range to active `BattleUnitState` objects.

## Applied Runtime Fields

Applied to active battle unit state:

- `unit_type`
- `move_range`
- `attack_range`

Stored as non-combat metadata:

- `design_primary_role`
- `design_secondary_role`
- `design_unique_skill_id`

Stored on the Battle root for inspection:

- `hero_battle_profile_integration`

The design unique-skill Dictionary is exposed under `design_unique_skill` and marked `design_skill_inactive=true`; legacy skill execution remains active until the later unique-skill transaction.

## Protected Boundaries

This transaction does not change:

- WorldMap hero source of truth
- save schema or runtime WorldMap hero state
- BattleContext shape
- troop allocations, casualties, settlement, or return payloads
- legacy attack, defense, damage, wounded, or AI formulas
- role-passive combat effects
- momentum
- new unique-skill execution
- cutins, VFX, or sound

Gunner and mounted-archer visuals use existing fallback visuals until their visual transaction. Their movement and range profiles are active in this transaction.

## Runtime Evidence

Expected Output for each deployed hero:

```text
[HERO_PROFILE] hero=<hero_id> unit=<unit_type> role=<primary_role> move=<move_range> range=<attack_range>
```

Expected transaction summary:

```text
[HERO_PROFILE_INTEGRATION] applied=<count> scene=res://Battle_Land.tscn
```

## Static Validation

Run:

```bash
python tools/validate_hero_design_registry.py
python tools/validate_hero_battle_profile_integration.py
```

Expected second result:

```text
INTEGRATION VALIDATION PASS: 39 heroes, 6 unit types, 8 roles, Battle autoload and profile application present
```

## User Godot QA Gate

- Project parses without new error or warning.
- WorldMap opens normally.
- Enter Battle from WorldMap with both attacker and defender heroes.
- Output shows `HERO_PROFILE` lines for deployed heroes from both sides.
- Infantry, cavalry, archer, gunner, mounted archer, and support use the generated movement/range rules when represented in battle.
- Battle entry, action flow, battle return, save/load, and settlement remain normal.
- Legacy damage and unique-skill behavior remain unchanged.

## Completion Rule

After the static commands and user Godot QA pass, mark this entire integrated transaction complete. Do not create another user-facing transaction merely to record adapter invocation.