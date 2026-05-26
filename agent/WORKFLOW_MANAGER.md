# WORKFLOW MANAGER

## Role
- Owns SamWar_BattleLab task permission boundaries.
- Tracks forbidden actions, commit policy, push policy, and local environment policy.
- Defines the recommended document reading order for a new Codex session.

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

## Forbidden Actions
- Do not run `git push`.
- Do not delete files.
- Do not install programs or global packages.
- Do not change PATH, OS settings, or repo-outside system state.
- Do not modify out-of-scope code, scenes, or assets.

## Local Environment Policy
- `agent/LOCAL_ENV.md` may be read for local Godot path discovery.
- `agent/LOCAL_ENV.md` must not be committed.
- Godot executable paths must not be written into tracked docs.

## Commit Policy
- If a task provides an explicit commit message, complete the scoped work, verification, required docs updates, and local git commit autonomously.
- Commit only in-scope tracked changes.
- Never push unless Kimjak explicitly gives a separate push instruction.

## New Session Reading Order
1. `agent/WORKFLOW_MANAGER.md`
2. `agent/CODEX_WORKFLOW_RULES.md`
3. `agent/ARCHITECT_AGENT.md`
4. `agent/IMPLEMENTATION_AGENT.md`
5. `agent/QA_AGENT.md`
6. `agent/RUNTIME_QA_AGENT.md`
7. `agent/VISUAL_QA_AGENT.md`
8. `agent/GODOT_RULES.md`
9. `agent/CURRENT_STATE.md`
10. `agent/NEXT_TASKS.md`
11. `agent/HANDOFF_TO_CODEX.md`

## Completion Report Format
- Modified file list.
- Verification results.
- Commit hash.
- Remaining risks.
