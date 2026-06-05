# WORKFLOW MANAGER

## Role
- Owns SamWar_BattleLab task permission boundaries.
- Tracks forbidden actions, commit policy, push policy, and local environment policy.
- Defines the recommended document reading order for a new Codex session.

## ChatCoach Role Lock
- `v0.70-19a Agent Docs Handoff & ChatCoach Role Lock` records the current operating split after `v0.70-19 WorldMap Selected City Governor Assignment & Policy Connect` (`4c671b0e7599ade817d1274768f04b879a757ca4`).
- 채코치는 단순 지시문 생성기가 아니다.
- 채코치는 먼저 GitHub/깃에서 접근 가능한 실제 코드와 문서를 직접 확인한다.
- 내부 구현과 연결되는 작업은 감으로 지시하지 않는다.
- 채코치는 가능한 범위에서 직접 관련 파일, 함수, 변수, 저장 구조를 확인하고, 기존 구현과 연결 가능성을 판단한 뒤 위험 범위와 안전 범위를 분리한다.
- 그 후 Codex 실행용 지시문을 작성한다.
- Codex는 실행/수정/검증/로컬 커밋 담당이다.
- 채코치는 설계 판단/코드 근거 확인/작업 범위 결정 담당이다.
- `Codex가 분석해라`로 넘기기 전에, 채코치가 직접 확인 가능한 GitHub 코드와 문서는 먼저 확인해야 한다.
- 로컬에만 있고 GitHub에 없는 파일, 커밋, dirty 상태는 Codex 보고나 사용자 제공 결과를 근거로 판단한다.
- 사용자는 직접 PowerShell/Git/Godot 조작을 최소화하고, Codex 결과 보고를 붙여넣는 방식으로 진행한다.

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

## Task Header Operating Rule
- 모든 SamWar_BattleLab Codex 작업 지시문은 반드시 `[SamWar_BattleLab 자동 작업 권한 헤더]`로 시작한다.
- 이 헤더는 Codex가 repo 내부에서 읽기/검색/수정/검증/agent 문서 업데이트/로컬 git commit까지 자동으로 진행할 수 있는 범위와 금지 작업을 명확히 하는 안전 계약이다.
- 헤더가 누락된 경우, 작업 지시문을 실행하기 전에 헤더를 먼저 보완한다.
- 다음 작업이나 다음 세션 지시문을 작성할 때는 위 헤더 전문을 작업명보다 먼저 붙인다.

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
