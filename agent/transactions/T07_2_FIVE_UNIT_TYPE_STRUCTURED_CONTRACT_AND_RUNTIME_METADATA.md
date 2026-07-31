# T07-2 Five Unit-Type Structured Contract & Runtime Metadata

Status: `IMPLEMENTED / DATA CONTRACT STRUCTURED / RUNTIME LOOKUP ADDED / LOCAL GODOT VALIDATION PENDING`

## Goal

Convert the five unit types from human-readable passive text into structured metadata that later player, AI, damage, auto-battle, UI, and persistence transactions can consume without hero-name hardcoding.

## Implemented

- Upgraded `data/heroes/generated/unit_type_rules.json` to schema version 2.
- Preserved the five canonical IDs only:
  - `infantry`
  - `cavalry`
  - `archer`
  - `gunner`
  - `mounted_archer`
- Added structured shared fields for:
  - movement;
  - minimum and maximum attack range;
  - counterattack range;
  - attack-after-move;
  - move-after-attack;
  - post-attack movement limit;
  - stationary, base, received, side, and rear damage metadata;
  - armor ignore;
  - AI behavior profile;
  - visual, icon, and animation keys.
- Added gunner-specific fields for prepared fire, armor ignore, post-fire penalty, reload contract, and close-range response.
- Added mounted-archer fields for mobile ranged behavior, limited post-attack movement, distance keeping, and disengagement.
- Updated `HeroDesignDataRegistry` to accept unit-type schema versions 1 and 2 while all other generated design files remain schema version 1.
- Added canonical display-name and all-unit-type lookup helpers.
- Added `scripts/battle/unit_type_contract.gd` as the shared read-only contract interface.
- Added `tools/validate_five_unit_type_structured_contract.py`.

## Locked Functional Defaults

| Unit type | Move | Min range | Max range | Attack after move | Move after attack |
|---|---:|---:|---:|---|---|
| infantry | 3 | 1 | 1 | yes | no |
| cavalry | 4 | 1 | 1 | yes | no |
| archer | 3 | 1 | 3 | yes | no |
| gunner | 2 | 1 | 3 | no | no |
| mounted_archer | 4 | 1 | 2 | yes | yes, limit 2 |

Final numerical balance remains T11 scope. These values lock the T07 functional contract needed for deterministic implementation and validation.

## Regression Protection

- Korea production roster assignments are unchanged.
- `support` is not restored as a unit type.
- No hero-name-specific behavior was added.
- No existing battle action, AI, damage, auto-battle, or scene code was modified in this transaction.
- Legacy `attack_range` remains present as a compatibility mirror of `maximum_attack_range`.

## Validation

The new validator checks:

- schema version 2;
- exact five canonical IDs;
- required structured fields;
- move/min/max range parity;
- visual key parity;
- gunner movement/fire contract;
- mounted-archer post-attack movement contract.

The GitHub-only execution environment used for this transaction cannot run the project's Godot binary or the repository Python validator against a local checkout. Local validator and headless Godot execution remain required before T07-3 production integration.

## Commits

- `426fffe0c84f21033bd19f926a7b188742188e68` — structured schema data.
- `22d7634e2d7103767db89ff53117df815e27ef64` — registry schema support and lookup helpers.
- `44b920191436b54f3174dcf3a7b879e75c4b5007` — shared unit-type contract helper.
- `5464b267564bd88a54b9d09763d2c9b61892731d` — structured-contract validator.

## Completion Decision

T07-2 source implementation is complete. Before T07-3 changes production movement and attack eligibility, run:

```bash
python tools/validate_five_unit_type_structured_contract.py
python tools/validate_hero_design_registry.py
python tools/validate_hero_battle_profile_integration.py
```

and perform a headless project parse from the local Godot environment.
