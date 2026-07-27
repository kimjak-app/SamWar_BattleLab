# T06-4 Battle-side Hero Stat/Profile Adapter

Status: `IMPLEMENTED / GODOT QA PENDING`

## Purpose

Provide a bounded Battle-side adapter that combines a protected legacy hero contract with the new T06 design data without overwriting any legacy runtime field.

## Added File

- `scripts/battle/hero_battle_design_adapter.gd`

## Adapter Contract

`HeroBattleDesignAdapter.build_battle_contract(legacy_hero)` returns a deep copy of the incoming legacy hero Dictionary and adds only namespaced design fields:

- `design_contract_version`
- `design_stats`
- `design_battle_multipliers`
- `design_profile`
- `design_unit_rule`
- `design_primary_role_rule`
- `design_secondary_role`
- `design_unique_skill`

The adapter never overwrites legacy fields such as:

- `attack`
- `defense`
- `war`
- `command`
- `troops`
- `troop_count`
- `unique_skill_id`
- city/faction/save/BattleContext fields

## Validation Behavior

The adapter fails closed by attaching `design_adapter_error` when:

- `hero_id` is missing,
- the JSON Registry fails to load,
- the hero has no matching base/profile record,
- unit, role, or unique-skill links are incomplete.

`has_valid_design_contract()` confirms that all namespaced design sections are present.

## Runtime Boundary

This transaction adds the adapter only. It does not yet replace Battle roster construction or combat formulas.

- WorldMap authority remains `HeroDefinitionRegistry.HERO_DATA`.
- Existing BattleContext shape is unchanged.
- Existing battle actors and formulas continue to use legacy fields.
- Six-unit behavior, primary-role passives, momentum, and new unique-skill execution remain inactive.

## Required Godot QA

1. Godot parse succeeds with the new adapter script.
2. Existing WorldMap and Battle entry/return remain unchanged.
3. A focused debug call can build valid design contracts for representative heroes.
4. Missing or invalid IDs return `design_adapter_error` without crashing.
5. No new Output error or warning appears.

## Next Gate

After QA PASS, a separate T06-5 transaction may call the adapter at the Battle roster-registration boundary and expose namespaced design data to battle units. It must still preserve all legacy formulas until six-unit and role-passive activation transactions are separately approved.
