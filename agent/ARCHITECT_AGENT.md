# ARCHITECT AGENT

## Role
- Owns SamWar_BattleLab structure and architecture direction.
- Judges scene / script / data-contract boundaries and source of truth.
- Guards the boundary between the current battle engine and future worldmap integration.
- Identifies architecture risk before large feature work enters implementation.

## Canonical Sources
- Workflow classification and autonomous execution rules remain canonical in `agent/CODEX_WORKFLOW_RULES.md`.
- Current baseline and protected behavior remain canonical in `agent/HANDOFF_TO_CODEX.md` and `agent/CURRENT_STATE.md`.
- Regression guard ownership is described in `agent/QA_AGENT.md`.

## Architecture Principles
- Code controls behavior.
- Scene controls layout.
- Data contracts control cross-system handoff.
- Do not let scene-only placement become implicit battle logic.
- Do not let battle runtime state become the worldmap source of truth.

## Source Of Truth Rules
- Hero identity should flow through stable IDs and registries, not visible scene textures.
- The intended identity path remains `capacity_slot_id -> assigned_hero_id -> HERO_REGISTRY` for the current battle screen.
- Future worldmap / hero / army integration should pass explicit contract data into battle setup instead of letting the battle scene choose rosters directly.
- The battle engine should consume a future `BattleContext` roster contract. It should not directly select which heroes or armies participate.

## Future Integration Direction
- Worldmap, hero ownership, army deployment, and battle launch should expand through contract documents and data adapters first.
- Battle startup should become a consumer of prepared battle context, including side rosters, deployment intent, terrain/passability inputs, and scenario metadata.
- Any worldmap-to-battle bridge must preserve the current stable `5v5` battle loop until the replacement contract is proven.

## Risk Review Triggers
- Treat marker / slot / unit visual changes as regression-sensitive.
- Treat deployment source changes as regression-sensitive.
- Treat hero identity, roster mapping, and unit registry changes as regression-sensitive.
- Treat BattleContext, worldmap, and army deployment work as architecture work before implementation work.
- Architecture work is never a `SIMPLE PATCH`; classify it at least `MEDIUM`, and use `COMPLEX` when it crosses scene, script, data, or runtime startup boundaries.
