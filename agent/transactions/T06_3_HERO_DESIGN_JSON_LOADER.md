# T06-3 Hero Design JSON Parity & Non-Destructive Loader

Status: `IMPLEMENTED / STATIC QA PENDING USER GODOT CONFIRMATION`

## Purpose

Expose the T06-2 generated hero design JSON to Godot without replacing or mutating the protected legacy WorldMap hero registry.

## Added Files

- `scripts/worldmap/hero_design_data_registry.gd`
- `tools/validate_hero_design_registry.py`

## Loader Contract

`HeroDesignDataRegistry` lazily reads the five generated JSON files:

- `hero_base_stats.json`
- `hero_battle_profiles.json`
- `hero_unique_skills.json`
- `unit_type_rules.json`
- `battle_role_rules.json`

It validates schema version, duplicate/empty IDs, and the required 39/39/39 record counts before exposing defensive-copy lookup methods.

## Protected Runtime Boundary

- `HeroDefinitionRegistry.HERO_DATA` remains the active WorldMap source.
- Existing save/load, city assignment, faction ownership, BattleContext, battle formulas, and legacy unique-skill runtime remain unchanged.
- The new loader is read-only and opt-in. Merely adding it does not alter current gameplay.
- No legacy `war`, `command`, `attack`, `troops`, or similar value is overwritten by the new T06-1 fields.

## Parity Contract

`tools/validate_hero_design_registry.py` compares:

- legacy Registry hero IDs and order,
- generated base-stat hero IDs,
- generated battle-profile hero IDs,
- generated unique-skill hero IDs and links,
- six unit types,
- eight battle roles.

Legacy combat/stat numbers are deliberately not compared because the historical fields do not have the same semantic contract as `leadership`, `martial`, `intelligence`, and `politics`.

## Required Verification

Run from repository root:

```bash
python tools/validate_hero_design_registry.py
```

Expected result:

```text
PARITY PASS: 39 legacy hero IDs match generated base/profile/skill JSON; 6 unit types and 8 roles present
```

Then run Godot 4.6 parse/F5 smoke:

- WorldMap opens normally.
- Existing hero roster/UI remains unchanged.
- Battle entry and return remain unchanged.
- Save/load remains unchanged.
- No new parse error or warning appears.

## Non-Goals

- Replacing legacy WorldMap values with the new design values
- Activating six-unit-type combat rules
- Activating eight-role passives
- Activating the 39 new unique-skill effects
- Changing UI, cutins, VFX, AI, balance, or sound effects

## Next Transaction

After static parity and user Godot smoke pass, T06-4 may connect the new base-stat/profile data to a bounded battle-side adapter. It must preserve WorldMap runtime state and may not activate all unique skills at once.
