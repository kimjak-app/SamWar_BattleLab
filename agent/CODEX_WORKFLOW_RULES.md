# CODEX WORKFLOW RULES

## Purpose
- These rules define how Codex should classify SamWar_BattleLab tasks, how much it should investigate, and how much verification it should perform before reporting back.

## Task Classification

### SIMPLE PATCH
- Typical examples:
  - constants
  - UI timing
  - UI scale
  - labels
  - logs
  - tiny position tweaks
- Scope:
  - a small targeted fix or doc-only change
  - one narrow behavior adjustment
  - one file or a very small set of directly related files
  - no architecture change

### MEDIUM PATCH
- Typical examples:
  - existing function flow bugfixes
  - small helper additions
  - focused behavior fixes within an existing subsystem
- Scope:
  - a focused feature improvement or bug fix across a small subsystem
  - multiple related functions/files may change
  - existing patterns should be reused where possible
  - limited structural cleanup is acceptable when directly needed

### COMPLEX PATCH
- Typical examples:
  - AI behavior
  - battle loop
  - slot/state architecture
  - scene/script integration
  - new systems
- Scope:
  - multi-system changes
  - larger refactor, architecture adjustment, or feature integration
  - behavior may cross battle logic, UI flow, scene integration, data contracts, or tooling
  - requires deliberate coordination across several touched areas

## Scope Rule By Task Type
- SIMPLE PATCH:
  - keep the change small and local
  - do not over-investigate
  - do not redesign
  - do not scan unrelated systems
- MEDIUM PATCH:
  - inspect the directly affected flow and adjacent helpers
  - keep the work inside the existing subsystem unless a clear blocker forces expansion
- COMPLEX PATCH:
  - inspect all systems that materially participate in the requested behavior
  - coordinate scene/script/state/integration impact deliberately

## Verification Depth By Task Type
- SIMPLE PATCH:
  - minimal safe verification only
  - verify the touched path and obvious syntax/load safety
  - do not run excessive verification unless requested or clearly necessary
- MEDIUM PATCH:
  - run the primary verification path for the affected subsystem
  - verify the requested behavior and nearby regressions
  - include warning/error checks when the project has a standard validation path
- COMPLEX PATCH:
  - use the strongest practical verification available in the repo
  - validate main behavior, adjacent regressions, and integration points
  - include project/scene launch checks and subsystem smoke coverage when appropriate
  - summarize residual risk when full verification is not possible

## Autonomous Execution Rule
- This project is already planned and directed by Kimjak + ChatCoach.
- Codex is expected to execute the agreed task autonomously.
- Proceed without asking for confirmation for normal SamWar development work:
  - reading/searching files
  - consolidated read/check commands
  - inspecting necessary line ranges when a consolidated read is not practical
  - editing task-related scripts
  - updating agent docs
  - running Godot headless checks
  - running warning checks
  - repeating verification after fixes
  - making small local fixes required to complete the stated goal
- Do not stop at intermediate steps.
- Do not ask whether to inspect code.
- Do not ask whether to run verification.
- Do not ask whether to update docs.
- If the task includes an explicit commit message, do not stop before commit.
- Complete implementation, verification, required doc updates, and `git commit` autonomously when that commit message is provided.
- Report the resulting commit hash after completion.
- Complete the task goal first.

## Confirmation Rule
- Ask only before:
  - git push
  - deleting files
  - destructive cleanup
  - changing unrelated systems
  - modifying assets/scenes outside the requested task scope
  - making a design decision not covered by the task

## Read Command Rule
- For harmless read-only commands, prefer consolidated reads over many tiny line-range reads.
- Avoid repeated small read/check commands that create unnecessary approval prompts or workflow interruption.
- If the approval UI appears for a harmless read/check command, use the broad proceed / do-not-ask-again option when available.

## Special Rule For SIMPLE PATCH
- Do not over-investigate.
- Do not redesign.
- Do not scan unrelated systems.
- Expected code change should remain small.
- Minimal safe verification only.
- Do not update docs unless requested.

## Default Behavior
- Start with the likely task class based on the user request.
- Reclassify only if the codebase evidence shows the task is broader than it first appeared.
- If a task begins as SIMPLE PATCH, keep it simple unless a concrete blocker forces expansion.
