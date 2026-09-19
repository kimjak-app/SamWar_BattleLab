---
name: samwar-dev
description: Automatically routes SamWar Godot development tasks into the correct project workflow for refactoring, integration, regression validation, scene/resource verification, or task closeout. Use for any coding, refactor, branch merge/integration, Godot scene/resource issue, test/CI validation, or engineering completion task in this repository. The user does not need to name this skill.
---

# SamWar Development Router

Use this skill automatically for SamWar engineering work in this repository.

## Core principle
The user states the goal; you choose and apply the workflow. Do not require the user to remember skill names or invocation syntax.

Validation must be proportional to risk. Use the lowest validation level that is sufficient to prove the requested change, and escalate only when the changed surface or task boundary requires it. Do not turn every small edit into a full-repository closeout.

## Instruction ownership

Keep each rule in one canonical place:

- `agent/WORKFLOW_MANAGER.md`: permission, safety, commit/push, and local-environment boundaries only.
- This skill: execution routing, preflight, validation level, duplicate-work prevention, and closeout mechanics.
- Domain architecture documents such as `BATTLE_RUNTIME_REFACTOR_PLAN.md` and `agent/BATTLE_ENGINE_RULES.md`: product/runtime ownership, sequencing, and behavior invariants.
- Per-task execution briefs: task-specific delta only — goal, exact ownership boundary, behavior locks, forbidden scope, and task-specific focused checks.

If an older task brief repeats generic preflight, validation, CI, closeout, or reading instructions, this skill supersedes those generic instructions. The brief still controls its task-specific behavior and scope locks.

## Reading policy

- Read a long architecture plan in full on the first session for that track, when its declared plan revision changes, or when the task crosses into a new architecture boundary.
- For consecutive tasks in the same track with the same plan revision, do **not** reread the whole plan. Read the current-status/next-action section plus the task-specific audit/brief and any explicitly relevant invariant section.
- Do not reread unchanged skill/playbook files after every small edit inside one coherent work unit.
- Do not open `references/closeout.md` unless the work unit is actually being closed.
- Future B-1x briefs should not contain generic `Read first`, full preflight, full regression, CI, or generic closeout checklists. Reference this skill instead.

## 1. Classify the task
Choose one or more playbooks:

- **Refactor / responsibility split**: moving logic out of large scripts such as `main.gd`, creating Service/Coordinator layers, preserving behavior.
  - Read `references/refactor.md`.
- **Branch or feature integration**: combining battle/world-map/audio/system branches, cherry-picking, reconciling conflicts, preserving known-good variants.
  - Read `references/integration.md`.
- **Regression / validation**: checking that an implementation is actually green at the validation level appropriate to its risk.
  - Read `references/regression.md`.
- **Closeout**: wrapping a completed work unit or milestone and reporting the exact finished state.
  - Read `references/closeout.md`.
- **Scene/resource problem**: missing `.tscn`, broken `res://` path, audio/image/resource reference, Godot import/UID issues.
  - Use the regression playbook plus the scene/resource rules below.

If several categories apply, sequence them in this order:
1. preflight
2. implementation/refactor/integration
3. scene/resource verification if relevant
4. validation at the selected level
5. closeout only when the requested work unit or milestone is actually being closed

## 2. Mandatory preflight
Before substantial edits:
1. State or infer a short work ID/title.
2. Inspect current branch, HEAD, upstream relationship, and worktree state.
3. Identify unrelated local changes and protect them.
4. Find the repository's actual test/validation commands from existing CI, scripts, README, or prior project conventions. Reuse them; do not invent commands.
5. For risky work, create or identify a recoverable checkpoint.
6. Confirm the target files and call paths before editing.

Run this full preflight once per coherent work unit. Do not repeat the same branch/HEAD/upstream/test-command discovery after every small edit unless repository state, branch, or scope materially changed.

Do not stop merely because the worktree is dirty. Distinguish unrelated user work from task-related changes and proceed safely when possible.

## 3. Implementation rules
- Preserve behavior unless the requested goal explicitly changes it.
- Prefer narrow responsibility boundaries.
- When extracting code, move logic first, then replace callers, then remove dead duplicates.
- Keep UI, coordination/orchestration, domain/service logic, and persistence/data concerns separated when practical.
- Avoid broad formatting churn.
- Add or update tests around changed behavior, especially edge cases and cancellation/failure paths.
- After editing, inspect the diff and confirm the intended patch is present.

## 4. Scene/resource rules
For Godot scene/resource work:
- Verify every referenced `res://` path exists in the current branch.
- When moving scripts/scenes/assets, search for old paths and update all references.
- Check `.tscn`, `.tres`, `.gd`, audio/image assets, and import metadata as relevant.
- Treat generated `.gd.uid` files as potentially significant: determine whether they are expected, should be tracked, or should be excluded. Never ignore them blindly.
- If a scene exists only on another branch, establish that fact explicitly before proposing code changes.

## 5. Validation levels
Select the lowest sufficient level. Escalate when risk crosses subsystem, resource, persistence, integration, or release boundaries.

### Level 1 — Fast / targeted
Default for narrow fixes, small edits, documentation/config changes, and focused extraction where the responsibility boundary is already understood.

Required when applicable:
- confirm target file/path
- confirm intended patch is present
- run the focused/targeted test or check for changed behavior
- inspect the scoped diff

Do **not** automatically run the full regression suite, remote/upstream checks, or CI for Level 1.

### Level 2 — Scoped regression
Use for medium multi-file refactors, changed call paths, scene/resource changes, or work that can affect a nearby subsystem.

Required when applicable:
- all Level 1 checks
- nearest relevant smoke/regression tests
- Godot parse/import/headless checks for affected scenes/resources
- generated-file/resource-path checks for the affected surface
- scoped worktree review

Do **not** automatically run unrelated full-project suites or CI unless the change crosses a major subsystem boundary.

### Level 3 — Full checkpoint
Use for branch/feature integration, WorldMap↔Battle handoff changes, persistence/schema changes, milestone closeout, release/merge readiness, explicit "full green" requests, or other high-risk cross-system work.

Required when applicable:
- targeted tests
- broader/full established regression suite
- Godot parse/import/headless checks
- generated artifact and resource-path review
- final worktree/diff review
- branch/HEAD/upstream relationship
- relevant CI/GitHub Actions status

## 6. Avoid duplicate validation
- Do not rerun an identical expensive check if no code/resource/repository state relevant to that check changed after it passed.
- After a tiny follow-up fix, rerun the affected targeted check first. Escalate only if the fix invalidates broader evidence.
- CI is evidence for a checkpoint, not a mandatory step after every local edit.
- A warning cleanup or documentation-only follow-up must not trigger a full validation cycle unless it changes executable behavior or the user explicitly asks for full verification.

## 7. Completion language
Do not say "complete", "full green", "done", or equivalent beyond the evidence actually gathered.

For Level 1 or Level 2, report the scoped verification plainly. Reserve "Full Green" for Level 3 when all required checkpoint checks passed.

## 8. Task brief contract

A new SamWar execution brief should contain only:
- work ID/title and target branch
- architecture-plan revision/reference
- task goal
- exact responsibility to move/change
- compatibility/behavior locks
- explicit out-of-scope boundaries
- task-specific focused tests/validators
- recommended validation level when the risk is known

It must not duplicate repository-wide permission rules, generic preflight, generic validation suites, CI requirements, or generic closeout fields.

## 9. Final report format
Keep it compact and factual:
- **Work**: ID/title
- **Result**: what changed
- **Verification**: selected validation level + checks/outcomes
- **Git**: branch + HEAD when relevant to the selected level
- **CI**: only when required or checked
- **Next**: only the most useful next step

## Routing examples
- "main.gd에서 외교 기능 한 덩어리 빼자" → refactor + Level 1 or 2 depending on call-path impact
- "작은 경고 하나 고쳐" → Level 1
- "전투 브랜치랑 월드맵 브랜치 합치자" → integration + Level 3
- "여기까지 마감하고 전체 검증해줘" → Level 3 + closeout
- "이 tscn 왜 안 보여?" → scene/resource verification + Level 2
- "C-track 끝났는지 확인" → Level 3 + closeout
