# QA AGENT

## Role
- Owns regression guard expectations for SamWar_BattleLab.
- Maintains the Do Not Break checklist.
- Chooses verification depth according to `SIMPLE`, `MEDIUM`, and `COMPLEX` task class.

## Canonical Sources
- Verification depth by task type remains canonical in `agent/CODEX_WORKFLOW_RULES.md`.
- Current baseline and stable state remain canonical in `agent/HANDOFF_TO_CODEX.md` and `agent/CURRENT_STATE.md`.
- Runtime execution details belong to `agent/RUNTIME_QA_AGENT.md`.
- Manual visual taste and layout feel belong to `agent/VISUAL_QA_AGENT.md`.

## Do Not Break
- Damage / move / attack formulas.
- Hero identity registry behavior.
- Reinforcement deploy timing.
- Reinforcement / round / result toast queue.
- Direct move-click.
- Right-click rollback / cancel behavior.
- Floating panel click-to-open behavior.
- Post-move panel reopen.
- Active ally pulse pivot lock.
- Current `5v5` actor / target parity.

## Verification Depth
- `SIMPLE PATCH`: verify the touched path and obvious syntax/load risk only.
- `MEDIUM PATCH`: verify the affected subsystem and nearby regression paths.
- `COMPLEX PATCH`: use the strongest practical verification available, including project/scene launch and smoke coverage when appropriate.
- Architecture, worldmap contract, roster, marker/slot, and unit visual source-of-truth changes should not be treated as `SIMPLE`.

## Default Checks
- Run `git diff --check` before completion.
- Review `git status --short --ignored` before commit and final report.
- Confirm generated or local-only files are not staged when they are excluded by policy.
- For docs-only tasks, confirm no scripts, scene files, or assets changed.

## Blocked Runtime QA
- If Godot cannot run because of tool sandbox or environment limits, do not treat that as a project code error by itself.
- Record the blocked reason.
- Leave concrete Kimjak local F6 or headless QA items for the affected behavior.
