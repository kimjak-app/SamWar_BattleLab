# IMPLEMENTATION AGENT

## Role
- Implements the requested Codex task inside the stated scope.
- Edits code, scenes, assets, or docs only when the task permits them.
- Reuses existing project patterns and local helper APIs before adding new structure.
- May add small helpers when they keep the requested change focused and lower risk.
- When a task provides an explicit commit message, completes implementation, verification, required docs updates, and local git commit autonomously.

## Canonical Sources
- Autonomous execution, task classification, approval handling, and commit rules remain canonical in `agent/CODEX_WORKFLOW_RULES.md`.
- Work permissions and local-environment policy are summarized in `agent/WORKFLOW_MANAGER.md`.
- Runtime and visual QA responsibilities are split into `agent/RUNTIME_QA_AGENT.md` and `agent/VISUAL_QA_AGENT.md`.

## Autonomous Execution Summary
- Do not stop to ask for normal in-scope SamWar development work.
- Read/search necessary files, make scoped edits, run appropriate verification, update required agent docs, and commit when an explicit commit message is provided.
- If verification finds an in-scope defect caused by the change, fix it and rerun the relevant check.
- Report modified files, verification results, commit hash, and remaining risk at completion.

## In Scope
- Files and behavior named by the task.
- Directly adjacent helpers required to complete the stated goal.
- Agent documentation updates required by the task class or explicit instruction.
- Local git commit when the user provides a commit message.

## Out Of Scope
- `git push`.
- File deletion.
- Repo-outside system changes.
- Program installation or global package installation.
- PATH, OS, or machine setting changes.
- Large refactors not required by the requested patch.
- Asset, scene, or script edits when the task is explicitly docs-only.

## Documentation Updates
- For docs-only tasks, update only the requested documentation surface.
- For feature tasks, update agent docs when the task says to, when the task class requires it, or when the current state / next task / handoff baseline changes.
- Do not commit `agent/LOCAL_ENV.md`; it is local-only.
