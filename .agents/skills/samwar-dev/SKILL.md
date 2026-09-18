---
name: samwar-dev
description: Automatically routes SamWar Godot development tasks into the correct project workflow for refactoring, integration, regression validation, scene/resource verification, or task closeout. Use for any coding, refactor, branch merge/integration, Godot scene/resource issue, test/CI validation, or engineering completion task in this repository. The user does not need to name this skill.
---

# SamWar Development Router

Use this skill automatically for SamWar engineering work in this repository.

## Core principle
The user states the goal; you choose and apply the workflow. Do not require the user to remember skill names or invocation syntax.

## 1. Classify the task
Choose one or more playbooks:

- **Refactor / responsibility split**: moving logic out of large scripts such as `main.gd`, creating Service/Coordinator layers, preserving behavior.
  - Read `references/refactor.md`.
- **Branch or feature integration**: combining battle/world-map/audio/system branches, cherry-picking, reconciling conflicts, preserving known-good variants.
  - Read `references/integration.md`.
- **Regression / validation**: checking that an implementation is actually green, reproducing CI, confirming clean worktree, finding generated artifacts.
  - Read `references/regression.md`.
- **Closeout**: wrapping a completed unit of work, verifying commit/remote/CI, and reporting the exact finished state.
  - Read `references/closeout.md`.
- **Scene/resource problem**: missing `.tscn`, broken `res://` path, audio/image/resource reference, Godot import/UID issues.
  - Use the regression playbook plus the scene/resource rules below.

If several categories apply, sequence them in this order:
1. preflight
2. implementation/refactor/integration
3. scene/resource verification if relevant
4. regression
5. closeout

## 2. Mandatory preflight
Before substantial edits:
1. State or infer a short work ID/title.
2. Inspect current branch, HEAD, upstream relationship, and worktree state.
3. Identify unrelated local changes and protect them.
4. Find the repository's actual test/validation commands from existing CI, scripts, README, or prior project conventions. Reuse them; do not invent commands.
5. For risky work, create or identify a recoverable checkpoint.
6. Confirm the target files and call paths before editing.

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

## 5. Validation standard
A task is not "done" until the relevant checks pass or the blocker is explicitly reported.

At minimum, when applicable:
- project tests pass
- targeted tests for changed behavior pass
- static checks / Godot parse/import checks pass
- `git diff` matches the intended scope
- no accidental generated files or unrelated edits remain
- worktree status is understood
- local HEAD and remote/upstream state are understood
- CI/GitHub Actions is green if the task requires repository completion

## 6. Completion language
Do not say "complete", "full green", "done", or equivalent unless the required checks were actually run and passed.

If validation is partial, say exactly what is verified and what is not.

## 7. Final report format
Keep it compact and factual:
- **Work**: ID/title
- **Result**: what changed
- **Verification**: tests/checks and outcomes
- **Git**: branch + HEAD + upstream/worktree state
- **CI**: latest relevant run status, if applicable
- **Next**: only the most useful next step

## Routing examples
- "main.gd에서 외교 기능 빼자" → refactor + regression + closeout
- "전투 브랜치랑 월드맵 브랜치 합치자" → integration + regression + closeout
- "여기까지 마감하고 전체 검증해줘" → regression + closeout
- "이 tscn 왜 안 보여?" → scene/resource verification + regression
- "C-track 끝났는지 확인" → regression + closeout
