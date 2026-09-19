# WORKFLOW MANAGER

## Role
This file owns **permission and safety boundaries only** for SamWar_BattleLab work.

Execution routing, preflight, validation levels, duplicate-check policy, and closeout mechanics are owned by:
- `.agents/skills/samwar-dev/SKILL.md`
- `docs/SAMWAR_AI_PROTOCOL.md`

Do not duplicate those rules here or in per-task briefs.

## ChatCoach / Codex split
- 채코치는 GitHub에서 확인 가능한 코드와 문서를 직접 확인하고, 설계 판단·위험 범위·작업 경계를 정한다.
- Codex는 허용된 repo 내부 작업에서 실행/수정/검증/로컬 커밋을 담당할 수 있다.
- 로컬에만 존재하는 dirty state, 미푸시 커밋, 로컬 전용 파일은 Codex 보고나 사용자 제공 결과를 근거로 판단한다.
- 사용자의 직접 PowerShell/Git/Godot 조작은 가능한 한 최소화한다.

## SamWar_BattleLab automatic-work permission boundary
Allowed inside the repository when the task requires it:
- read/search
- scoped code and scene edits
- scoped validation
- required agent-document updates
- local git commit

Do not:
- git push unless Kim작 explicitly requests it separately
- delete files unless explicitly authorized for the task
- change anything outside the repository
- install programs or global packages
- change PATH or OS settings
- perform unrelated broad refactors

If required work cannot be completed without crossing one of those boundaries, stop that part and report the reason and safest alternative.

## Local environment policy
- `agent/LOCAL_ENV.md` may be read for local Godot path discovery.
- `agent/LOCAL_ENV.md` must not be committed.
- Local executable paths must not be written into tracked docs.

## Commit policy
- When a scoped task explicitly calls for a commit, complete the scoped implementation and validation, then commit only in-scope tracked changes.
- Never reset, restore, rebase, or stash unrelated user work merely to make the tree look clean.
- Push remains separately authorized.

## Architecture routing
Do not define document reading order here.

The skill chooses what must be read. Domain documents remain authoritative for their own content:
- Battle refactor architecture/status: `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- Battle invariants: `agent/BATTLE_ENGINE_RULES.md`
- WorldMap↔Battle boundary: `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md` only when that boundary is touched
- WorldMap architecture: `agent/WORLDMAP_RULES.md`
- Other domain contracts only when the scoped task actually touches them

## Completion report
Use the report shape selected by `.agents/skills/samwar-dev/SKILL.md`. Do not add extra CI/upstream/full-regression requirements here.
