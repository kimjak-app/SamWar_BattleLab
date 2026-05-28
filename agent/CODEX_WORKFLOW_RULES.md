# CODEX WORKFLOW RULES

## SamWar_BattleLab 자동 작업 권한 헤더
이번 작업은 SamWar_BattleLab 폴더 내부 작업이다.

읽기 / 검색 / 코드 수정 / 씬 파일의 필요한 범위 수정 / 검증 실행 / agent 문서 업데이트 / 로컬 git commit까지는 모두 자동으로 진행한다.

중간에 확인 질문하지 말고, 지시문에 적힌 목표 완료까지 진행한다.

단, 아래 작업은 하지 않는다:
- git push
- 파일 삭제
- repo 밖 시스템 변경
- 프로그램 설치
- 패키지 전역 설치
- OS 설정 변경
- 요청 범위 밖 대규모 리팩토링

설치나 repo 밖 변경이 필요하다고 판단되면, 작업을 멈추고 이유와 대안을 보고한다.

작업 완료 후에는 수정 파일 목록, 검증 결과, 커밋 해시를 보고한다.

## Required Task Header Rule
- 모든 SamWar_BattleLab Codex 작업 지시문은 반드시 `[SamWar_BattleLab 자동 작업 권한 헤더]`로 시작한다.
- 이 헤더는 Codex가 repo 내부에서 읽기/검색/수정/검증/agent 문서 업데이트/로컬 git commit까지 자동으로 진행할 수 있는 범위와 금지 작업을 명확히 하는 안전 계약이다.
- 헤더가 누락된 경우, 작업 지시문을 실행하기 전에 헤더를 먼저 보완한다.
- 다음 헤더 전문을 모든 SamWar_BattleLab Codex 작업 지시문 최상단에 포함한다:

```markdown
[SamWar_BattleLab 자동 작업 권한 헤더]

이번 작업은 SamWar_BattleLab 폴더 내부 작업이다.

읽기 / 검색 / 코드 수정 / 씬 파일의 필요한 범위 수정 / 검증 실행 / agent 문서 업데이트 / 로컬 git commit까지는 모두 자동으로 진행한다.

중간에 확인 질문하지 말고, 지시문에 적힌 목표 완료까지 진행한다.

단, 아래 작업은 하지 않는다:

* git push
* 파일 삭제
* repo 밖 시스템 변경
* 프로그램 설치
* 패키지 전역 설치
* OS 설정 변경
* 요청 범위 밖 대규모 리팩토링

설치나 repo 밖 변경이 필요하다고 판단되면, 작업을 멈추고 이유와 대안을 보고한다.

작업 완료 후에는 수정 파일 목록, 검증 결과, 커밋 해시를 보고한다.
```

## Purpose
- These rules define how Codex should classify SamWar_BattleLab tasks, how much it should investigate, and how much verification it should perform before reporting back.

## Role-Based Agent Docs
- This file remains the canonical source for task classification, autonomous execution, confirmation rules, approval handling, and verification depth.
- Role-specific agent docs do not replace these rules; they interpret them for recurring responsibilities:
  - `agent/WORKFLOW_MANAGER.md`: task permission boundaries, commit/push policy, local environment policy, and new-session reading order.
  - `agent/ARCHITECT_AGENT.md`: architecture boundary review, source-of-truth decisions, and future worldmap / BattleContext contract direction.
  - `agent/IMPLEMENTATION_AGENT.md`: scoped implementation behavior, in-scope / out-of-scope distinction, docs update expectations, and commit execution.
  - `agent/QA_AGENT.md`: regression guard ownership and Do Not Break verification expectations.
  - `agent/RUNTIME_QA_AGENT.md`: Godot executable resolution, headless/runtime verification, and sandbox-blocked runtime QA handling.
  - `agent/VISUAL_QA_AGENT.md`: Kimjak manual F6 visual QA criteria and final visual-taste authority.

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

## Codex Approval Handling
- For harmless read/search/verification commands, use the broad "don't ask again for this command pattern" option when available.
- Prefer one targeted consolidated read over many small reads.
- Avoid repeated tiny `Get-Content` line-range commands unless a consolidated targeted read is not practical.
- Do not ask the user for normal SamWar development work.
- If the environment forces approval, proceed only when it is read/search/verification or an in-scope commit.
- Never auto-proceed on push, deletion, reset, destructive cleanup, or out-of-scope file changes.
- Push remains forbidden unless the user explicitly asks.

## Read Command Rule
- For harmless read-only commands, prefer one targeted consolidated read over many tiny line-range reads.
- Avoid repeated tiny `Get-Content` line-range commands that create unnecessary approval prompts.
- Avoid repeated small read/check commands that create unnecessary approval prompts or workflow interruption.
- If the approval UI appears for a harmless read/check command, proceed with the broad do-not-ask-again option when available.

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
