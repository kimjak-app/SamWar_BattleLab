# SamWar Codex Working Agreement

These instructions apply to the entire repository.

## Default behavior
- Treat every SamWar development request as eligible for the repository skill at `.agents/skills/samwar-dev/SKILL.md`.
- Read that skill before making code changes unless the task is purely conversational.
- The user should not need to remember or name the skill. Infer the workflow from the task.
- Start substantial work by giving it a short work ID/title when one is not already provided, e.g. `M-4 Diplomacy Service Split`.

## Safety and scope
- Preserve existing behavior unless the task explicitly changes product behavior.
- Do not overwrite, delete, or rewrite unrelated user work.
- Before risky refactors, integrations, or broad file moves, create or identify a recoverable checkpoint.
- Prefer small, reviewable changes over broad rewrites.
- Never claim a task is complete if the required validation has not run.

## Verification
- Verify target file paths before patching.
- Verify the intended patch actually exists in the target file(s) after editing.
- Verify the tested/committed version is the same version being reported.
- For Godot/GDScript work, watch for generated `.gd.uid` sidecars and other import artifacts that can dirty the worktree.
- Check scene/resource references when moving `.gd`, `.tscn`, audio, image, or other assets.

## Completion reporting
A completed engineering task should report, when applicable:
- work ID/title
- branch
- commit/HEAD
- files changed
- tests/validation run and result
- worktree status
- CI/GitHub Actions status
- remaining risks or next recommended step
