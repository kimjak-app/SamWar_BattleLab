# SamWar Shared AI Development Protocol

This is the canonical shared protocol for ChatGPT (채코치) and Codex.

## Single-owner rule

Each kind of rule has one owner:
- **Permission / safety / push / commit / local environment** → `agent/WORKFLOW_MANAGER.md`
- **Execution routing / preflight / validation / duplicate-work prevention / closeout** → `.agents/skills/samwar-dev/SKILL.md`
- **Battle architecture / stage / current next action** → `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- **Battle behavior invariants** → `agent/BATTLE_ENGINE_RULES.md`
- **Per-task scope** → the current audit/execution brief

Do not copy the same operating rule into several files. If a legacy brief repeats generic execution or validation rules, the repository skill supersedes those generic parts; task-specific behavior locks remain valid.

## Reading policy

- Long architecture plans are read in full only on the first session for that track, when the plan revision changes, or when crossing into a new architecture boundary.
- Consecutive B-1x work on the same plan revision should read only the current-status/next-action section, the active audit/brief, and specifically relevant invariant sections.
- Re-reading an unchanged 300+ line plan on every B-1x task is not required.
- Skill/playbook documents loaded for a coherent work unit do not need to be reopened after every small edit.
- Per-task briefs must be delta-only and must not contain generic full-regression/CI/closeout boilerplate.

## Validation

Validation is risk-proportional:
- **Level 1**: targeted verification for narrow changes
- **Level 2**: targeted + nearest relevant regression for medium/local subsystem changes
- **Level 3**: full checkpoint for integration, cross-system boundaries, milestone/release readiness, or explicit Full Green requests

Never rerun identical expensive checks when no relevant state changed.

## Completion language

Report only what the gathered evidence supports.
`Full Green` is reserved for Level 3 when all required checkpoint evidence matches the exact reported state.
