# TECH TREE GAMEPLAY CONTRACT

## Scope

This contract defines the target responsibility boundary for technology gameplay. It does not change existing values or runtime behavior. An unverified implementation is `Needs Runtime Audit`.

## Research Domains

| Domain | Owner | Applies to |
| --- | --- | --- |
| National research | NationTechState | The owning nation and its eligible systems/cities |
| City research | CityTechState | The owning city and explicitly city-scoped systems |

Technology definitions are separate from per-nation and per-city research state. Definitions describe requirements, effects, and presentation; state records progress, completion, and eligible ownership. Technology-effect lookup has one responsibility: resolve applicable, completed effects for a supplied gameplay context without duplicating state ownership.

## Effect Requirement

Every active technology must provide at least one actual effect: command, unit type, facility, tactic, production/cost/defense/supply modifier, information reveal, or restriction removal. AI uses the same resolved effects as the player. UI must show relevant locked, progressing, completed, and applied state. Save/load must preserve research state and enough context to restore effects.

## Ownership And Occupation

National research remains attached to its nation. City research requires explicit occupation handling: retain, transfer, disable, reset, or otherwise resolve it in the applicable transaction; the actual current behavior is `Needs Runtime Audit` until verified. Do not infer it from design intent.

## Korea MVP Activation

T01 preserves national tech in `player_state` and city tech in serialized city runtime state. Session-selected faction and capital select the player scope; no Hanseong research state is copied when another faction is selected.

The complete tech data remains preserved. Korea MVP selects a bounded active technology set only after a data/runtime audit. China, Japan, and naval technologies remain inactive-but-preserved unless a scenario explicitly activates them.

## Transaction Connection Table

Each transaction records its connection in this form:

| Transaction | Related technology | Before state | Unlock/condition | After state/effect | AI | UI | Save |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TXX | ID or `Needs Data Audit` | state | condition | actual effect | same policy | display | persisted fields |
| T02 | siege branch lookup | completed city/nation state | existing attack eligibility | existing naval/siege availability and displayed modifier only | same lookup | deployment/target surfaces | existing tech state |
| T02 | logistics/expedition/dried-fish/granary/intelligence families | defined | not connected to T02 supply calculator | Defined but Not Connected | Needs Runtime Audit | definitions remain visible | definitions/state preserved |

Do not state unverified effects or numeric values as implemented.

T02 deliberately reserves `tech_effect_snapshot` and future calculator modifier inputs without applying unverified technology effects. `fish_dried_supply_base` declares `expedition_food_cost_percent`, but no audited runtime consumer existed, so T02 does not silently apply it. No technology may change the absolute 30-turn battle cap.
