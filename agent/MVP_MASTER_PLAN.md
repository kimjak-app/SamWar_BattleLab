# MVP MASTER PLAN

## Product Vision

SamWar_BattleLab is a strategy game in which the player leads a chosen nation through world-map decisions, research, military preparation, invasion, defense, and tactical battles. Development completes player-visible transactions, not isolated helpers or version-sized patches.

## Korea Four-City MVP

The first shippable scenario is Korea with four active cities: **Hanseong**, **Pyongyang**, **Gyeongju**, and **Sabi**. Jeonju is not one of the four Korea MVP cities.

At new game, the player freely chooses one of four starting factions. The selected faction becomes the player nation; the other three become AI nations. Player role and nation ID are separate. Hanseong is not a permanently player-controlled faction.

## Core Play Loop

1. Start a new game and select a faction.
2. Manage cities, research, armies, and generals.
3. Invade or defend through a prepared encounter.
4. Directly command with the existing `Battle_Land` tactical engine, or use a separately calculated auto-delegation result.
5. Apply battle results, ownership, resources, research effects, and turn resolution.
6. Capture all four active Korea cities to win; lose when the player owns zero cities.

## Existing Assets To Use

- Preserve and actively use the existing `Battle_Land` tactical battle engine. Do not replace it with a simple three-round auto battle.
- Preserve the existing national research, city research, technology icons, research progress, and cost systems.
- National research and city research must deliver actual gameplay effects; technology is not decorative UI.

## Transaction-Driven Development

The primary unit of work is a complete user action: for example new-game selection, domestic order, recruitment, general movement, invasion and occupation, defense, turn end, or Korea unification. Refactoring is allowed only when needed to complete that transaction safely.

Every major transaction checks its relevant tech state and exposes resulting unlocks, modifiers, information, or choices. A technology must have at least one actual effect: command, unit, facility, tactical option, numeric modifier, cost reduction, information, or restriction removal.

## MVP Completion Definition

The Korea MVP is complete when a player can choose any starting faction, enter the world map, use relevant national/city research, complete player invasion and occupation, resolve enemy invasion and player defense, end turns, save/load the required session state, and reach the four-city victory or zero-city defeat condition. Direct battle and auto delegation must both have clear, bounded paths.

## Beyond Korea

- Post-MVP: talent discovery and recruitment, after general-definition/runtime-state separation is safe.
- Expansion: activate China and Japan scenarios using the same scenario/session contracts; preserve their content while Korea is active.
- Later: naval expansion uses the same transaction and tech-effect principles.

## Explicit Non-Goals

- No runtime implementation, broad refactor, or arbitrary balance change is authorized by this plan.
- Do not delete inactive China/Japan content to make Korea smaller.
- Do not duplicate canonical facts across plans, handoffs, audits, and QA locks.

## Documentation Priority And Single Source Rule

Read `WORKFLOW_MANAGER`, `TRANSACTION_DEVELOPMENT_RULES`, this plan, `CURRENT_STATE`, `TRANSACTION_ROADMAP`, then the active transaction specification. Domain rules and contracts are conditional reads. Each fact has one canonical home; completed transaction evidence leaves active context for archive review rather than being copied into the roadmap.
