# T07-1 Five Unit-Type Current-State Audit & Canonical Contract Design

Status: `AUDIT COMPLETE / CANONICAL CONTRACT DESIGNED / PRODUCTION IMPLEMENTATION NOT STARTED`

## Baseline

- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Audited remote baseline: `b7e708a4bb4099795b61a889f53f7ea00d7c07c5`
- Existing protected path: `HeroDesignDataRegistry -> HeroRuntimeFactory -> BattleUnitState -> BattleSkillResolver`
- This transaction changes no production battle behavior.

## Canonical Unit Types

The project has exactly five canonical land unit types.

| ID | Korean name | Move | Range | Regional identity |
|---|---|---:|---:|---|
| `infantry` | 보병 | 3 | 1 | Korea, China, common core |
| `cavalry` | 기병 | 4 | 1 | Korea, China, common core |
| `archer` | 궁병 | 3 | 3 | Korea, China, common core |
| `gunner` | 총병 | 2 | 3 | Japan expansion |
| `mounted_archer` | 궁기병 | 4 | 2 | Mongolia expansion |

`support` remains a battle role only and must not return as a unit type.

## Authoritative Data

Primary unit-type design data:

- `data/heroes/generated/unit_type_rules.json`
- `data/heroes/generated/hero_battle_profiles.json`

Production roster distribution:

- infantry: 11
- cavalry: 10
- archer: 11
- gunner: 4
- mounted_archer: 3

Korea MVP production heroes use only infantry, cavalry, and archer. Gunner and mounted archer must not be forced into the Korea roster.

## Existing Runtime Contract

`HeroRuntimeFactory` already:

- permits only the five canonical IDs;
- rejects unknown unit types instead of silently converting them;
- loads `move_range` and `attack_range` from the unit-type rule;
- locks `unit_type`, `visual_key`, movement, range, roles, and unique skill as battle-authority fields;
- preserves canonical IDs through battle payload creation.

`BattleUnitState` already stores:

- `unit_type`
- `visual_key`
- `move_range`
- `attack_range`
- `has_moved`
- `has_acted`
- `last_action`
- `status_effects`

Battle snapshots already preserve current position, facing, action flags, last action, and status effects.

## Fallback Audit

There is no canonical-ID fallback from:

- `gunner` to `archer`
- `mounted_archer` to `cavalry`
- `mounted_archer` to `archer`

Legacy `web_role` maps both expansion unit types to `ranged`. This does not rewrite the canonical ID, but any combat or AI code that reads only `web_role` may currently treat them as generic ranged units.

## Current Implementation State

| Area | Infantry | Cavalry | Archer | Gunner | Mounted archer |
|---|---|---|---|---|---|
| Generated data | Complete | Complete | Complete | Complete | Complete |
| Hero assignment | Complete | Complete | Complete | Complete | Complete |
| Runtime ID round trip | Complete | Complete | Complete | Complete | Complete |
| Move/range import | Complete | Complete | Complete | Complete | Complete |
| Visual key contract | Complete | Complete | Complete | Complete | Complete |
| Distinct combat behavior | Existing | Existing | Existing | Not complete | Not complete |
| Distinct AI behavior | Existing baseline | Existing baseline | Existing baseline | Not complete | Not complete |
| Dedicated visual resources | Existing | Existing | Existing | Audit required | Audit required |

## Gunner Audit

Design data already defines:

- move 2;
- range 3;
- armor ignore 20%;
- prepared-fire damage +15%;
- post-fire next-turn attack -40%;
- weakness in movement, close response, and sustained fire.

Currently confirmed runtime consumption is limited to canonical ID, move, range, visual key, and generic ranged classification. Armor ignore, prepared fire, post-fire penalty, reload state, and close-range weakness are not yet represented as a structured runtime behavior contract.

## Mounted-Archer Audit

Design data already defines:

- move 4;
- range 2;
- attack before/after movement;
- side-attack damage +6%;
- base attack damage -8%;
- received damage +8%;
- mobile ranged identity distinct from cavalry charge.

Currently confirmed runtime consumption is limited to canonical ID, move, range, visual key, and generic ranged classification. Post-attack movement, distance keeping, side bonus, damage penalty, and defensive weakness are not yet represented as a structured runtime behavior contract.

## Largest Structural Gap

`unit_type_rules.json` contains several gameplay rules only as human-readable strings such as `passive`, `weakness`, and `implementation_note`.

The battle engine needs structured fields that can be consumed consistently by player commands, AI, damage calculation, auto battle, UI, and snapshot restore.

## Canonical Structured Contract Draft

Shared fields:

- `unit_type`
- `display_name`
- `move_range`
- `minimum_attack_range`
- `maximum_attack_range`
- `counterattack_min_range`
- `counterattack_max_range`
- `can_attack_after_move`
- `can_move_after_attack`
- `post_attack_move_limit`
- `stationary_attack_bonus`
- `base_damage_modifier`
- `received_damage_modifier`
- `side_attack_modifier`
- `rear_attack_modifier`
- `armor_ignore_ratio`
- `ai_behavior_profile`
- `visual_key`
- `icon_path`
- `animation_profile`

Gunner-specific candidates:

- `prepared_fire_bonus`
- `post_fire_penalty`
- `reload_contract`
- `close_range_response`

Mounted-archer-specific candidates:

- `mobile_ranged`
- `post_attack_movement`
- `distance_keeping_profile`
- `disengagement_contract`

Exact final balance values remain deferred to T11. T07 may use functional defaults only where needed for deterministic validation.

## Persistence Impact

WorldMap long-term save schema likely does not require a version change because canonical unit type, movement, and range are regenerated from design authority.

Battle snapshot impact may be required for:

- gunner prepared/reload/post-fire state;
- mounted-archer post-attack movement availability;
- remaining post-attack movement;
- turn-local attack and movement locks.

Prefer reusing `status_effects` and `last_action` where the contract remains explicit and deterministic. Add dedicated snapshot fields only when those containers cannot safely represent the state.

## Primary Regression Risks

- generic `ranged` logic erasing gunner and mounted-archer identity;
- player and AI using different range or action-eligibility rules;
- counterattack range inheriting maximum attack range incorrectly;
- mounted archer gaining unlimited move-attack-move loops;
- gunner reload or penalty state disappearing after battle save/load;
- duplicate display-name dictionaries and legacy `support` labels drifting from canonical data;
- auto battle using a separate matchup table from manual battle;
- missing `gunner` or `mounted_archer` visual resources causing invisible or wrong tokens;
- unintended changes to Korea MVP hero unit assignments.

## Locked Design Principles

- Korea MVP production assignments remain unchanged.
- Gunner and mounted archer are expansion-ready runtime types, not Korea roster requirements.
- No hero-name hardcoding for unit-type behavior.
- Generated design data remains authoritative.
- Player, AI, auto battle, result settlement, and save/load must consume the same canonical rules.
- Existing infantry, cavalry, and archer behavior must not regress.
- Final numerical balance remains T11 scope.

## Follow-up Transactions

### T07-2 Five Unit-Type Structured Contract & Runtime Metadata

Convert human-readable design rules into structured metadata, centralize Korean display names, and expose a stable runtime contract without changing final balance.

### T07-3 Shared Movement, Range, Counterattack & Action Eligibility

Create shared player/AI helpers for movement, minimum/maximum range, attack eligibility, counterattack eligibility, attack-after-move, and move-after-attack.

### T07-4 Firearm Infantry Runtime & AI

Implement prepared fire, armor ignore, post-fire penalty or reload behavior, close-range response, combat logs, and AI firing-position selection.

### T07-5 Mounted Archer Runtime & AI

Implement mobile ranged attack, limited post-attack movement, distance keeping, side-pressure behavior, loop prevention, and AI retreat/reposition logic.

### T07-6 Five Unit-Type Damage, Auto-Battle & Skill Parity

Connect unit matchups, damage modifiers, unique-skill interactions, and auto-battle parity using functional T07 defaults while deferring final balance to T11.

### T07-7 UI, Visual Resource, Persistence & Full QA

Complete Korean labels, icons, token/animation metadata, battle snapshot parity, Japan gunner test roster, Mongolia mounted-archer test roster, and Korea three-type regression QA.

## Completion Decision

T07-1 is complete as an architecture and current-state audit.

The next implementation transaction is:

`T07-2 Five Unit-Type Structured Contract & Runtime Metadata`
