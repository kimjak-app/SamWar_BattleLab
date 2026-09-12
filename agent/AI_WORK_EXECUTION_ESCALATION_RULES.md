# AI Work Execution & Codex Escalation Rules

작성 목적: 삼국WAR 개발에서 채코치(ChatGPT)와 로컬 Codex의 역할 경계를 명확히 하고, 도구 한계 때문에 실제 구현·검증이 불가능한 작업을 애매하게 미루지 않기 위한 영구 운영 규칙.

적용 범위: `kimjak-app/SamWar_BattleLab` 프로젝트 전반. 특히 WorldMap / Battle / UI / Godot 작업.

---

## 1. 기본 원칙

채코치는 자신이 현재 사용할 수 있는 도구로 **실제로 구현·검증 가능한 작업은 직접 수행한다.**

단순히 작업이 크거나 번거롭다는 이유, 시간이 오래 걸릴 것 같다는 이유, 실수 가능성이 있다는 이유만으로 Codex에 넘기지 않는다.

반대로 현재 도구 한계 때문에 **실제 수정·검증을 끝까지 수행할 수 없는 작업은 미루거나 말로만 끝내지 않는다.** 그 경우 채코치는 즉시 다음을 명확히 말한다.

> 이 작업은 현재 채코치의 도구 한계로 직접 완료할 수 없고, 로컬 Codex가 수행해야 한다.

그리고 사용자가 바로 실행할 수 있도록 **완성된 Codex 지시문을 제공한다.**

---

## 2. Codex 에스컬레이션이 반드시 필요한 경우

아래 조건 중 하나라도 해당하고, 다른 현재 사용 가능 도구로 안전하게 완료할 방법이 없으면 Codex로 에스컬레이션한다.

### 2-1. 대형 로컬 파일의 부분 수정이 필요한데 원격 도구가 전체 파일 교체만 지원하는 경우

예:

- 매우 큰 `worldmap_main.gd`처럼 연결 도구가 전체 내용을 안정적으로 읽지 못함
- 필요한 수정은 파일 일부인데 GitHub write interface는 전체 파일 replacement만 가능
- 이 상태에서 억지로 우회 controller나 임시 wrapper를 만드는 것은 구조적 부채를 늘림

이 경우 로컬 Codex가 실제 파일을 직접 읽고 부분 수정하도록 한다.

### 2-2. 로컬 저장소 전체를 대상으로 정밀 grep / rg / git diff / git status / 참조 추적이 필수인 경우

특히 다음처럼 여러 파일 사이의 실제 실행 관계를 감사해야 할 때:

- 동일 node/subtree ownership 충돌
- 동일 property의 multi-writer 충돌
- scene reference 제거 여부
- dead file 판정
- `.uid` / `.tscn` / `.gd` 연결 관계 전수 확인
- repository 전체의 test_controller inventory

채코치의 연결 도구만으로도 충분히 검증 가능하면 직접 한다. 그러나 connector 검색 범위나 파일 크기 제한 때문에 **정확한 전수 감사가 불가능하다면 Codex가 해야 한다.**

### 2-3. 로컬 실행 환경에서만 가능한 검증이 작업 완료의 필수 조건인 경우

예:

- Godot executable을 이용한 headless parse / scene load / project 실행
- 로컬 빌드
- 로컬 테스트 suite
- 실제 filesystem 경로를 요구하는 import / asset 검증

채코치가 해당 실행 도구를 가지고 있지 않다면 실행한 것처럼 말하지 않는다.

필요한 경우 Codex에게 실행 검증까지 지시한다.

단, Codex 환경에도 Godot executable이 없다면 Codex 역시 `STATIC VERIFIED / RUNTIME F6 REQUIRED`라고 명시해야 한다.

### 2-4. 여러 파일을 하나의 atomic change로 동시에 안전하게 수정해야 하는데 연결 write 도구만으로 일관성 보장이 어려운 경우

예:

- `.gd` 수정
- `.tscn` reference 제거
- `.uid` 삭제
- handoff 문서 갱신
- repository-wide reference 0개 검증

이런 작업에서 중간 commit이 생기거나 파일별 write가 분리되어 repository가 일시적으로 불완전한 상태가 될 위험이 크고, 로컬 작업이 명백히 더 안전하면 Codex에 맡긴다.

### 2-5. patch 적용 전에 실제 local dirty state를 반드시 확인해야 하는 고위험 작업

사용자의 로컬 미커밋 변경을 보호해야 하며 다음이 중요한 작업:

- dirty worktree
- local-only commits
- origin과 local의 divergence
- 최근 Codex 작업 직후 후속 패치

채코치가 로컬 상태를 직접 볼 수 없고 그 상태가 안전성에 결정적이면 Codex가 먼저 local audit을 수행하도록 한다.

---

## 3. Codex에 넘기면 안 되는 경우

다음은 Codex 에스컬레이션 이유가 아니다.

- 작업이 귀찮다
- 파일이 여러 개다
- 코드를 많이 읽어야 한다
- 설계를 다시 생각해야 한다
- 한 번 실패했다
- 시간이 오래 걸릴 것 같다
- 채코치가 먼저 원인을 분석해야 하는 상황이다

현재 도구로 실제 구현할 수 있으면 채코치가 직접 한다.

즉 Codex는 **작업 회피 수단이 아니라 로컬 실행·수정 권한이 반드시 필요한 경우의 실행 파트너**다.

---

## 4. 에스컬레이션 전 채코치가 반드시 해야 할 일

Codex에게 넘기기 전에 채코치는 가능한 범위에서 다음을 끝낸다.

1. 문제 현상 정리
2. 근본 원인 가설 또는 확인된 원인 정리
3. 관련 파일/함수/노드 후보 식별
4. 절대 건드리면 안 되는 범위 정의
5. 성공 조건(acceptance criteria) 정의
6. 필요한 static/runtime QA 정의
7. active branch와 기준 HEAD 확인 가능한 경우 확인

즉 Codex에게 단순히:

> 알아서 고쳐

라고 넘기지 않는다.

Codex가 **감사 → 구현 → 검증 → commit**까지 안전하게 수행할 수 있는 구체적인 지시문을 만든다.

---

## 5. Codex 지시문 필수 항목

Codex 에스컬레이션 지시문에는 가능한 한 다음이 포함되어야 한다.

- Repository
- Active branch
- 예상 START HEAD (단, 실제 재확인 지시 포함)
- `agent/...HANDOFF.md` 선독
- `git status --short`
- local/origin 차이 확인
- dirty change 보호 규칙
- reset/rebase/stash/restore 금지 조건
- 수정 대상
- 수정 금지 대상
- 근본 원인
- 구현 목표
- acceptance criteria
- `git diff --check`
- repository-wide reference search
- 변경 파일 3중 검증
- runtime 검증 가능/불가능 여부
- atomic commit 전략
- push/merge 금지 여부
- 최종 보고 형식

---

## 6. Codex 작업 후 채코치의 역할

Codex가 완료 보고를 반환하면 채코치는 단순히 "잘 됐다"고 승인하지 않는다.

가능한 범위에서 반드시 2차 감사한다.

1. 보고된 branch / HEAD / commit 확인
2. 원격에 push된 경우 실제 commit/diff 확인
3. root cause와 fix가 일치하는지 검토
4. 땜질성 workaround가 새로 들어갔는지 검토
5. 삭제한 reference가 실제로 없어졌는지 가능한 범위에서 확인
6. runtime QA가 필요한지 판정
7. 사용자에게 F6 GO / NO-GO를 명확히 전달

Codex가 아직 push하지 않은 local-only commit은 채코치가 원격에서 직접 볼 수 없다는 사실을 명확히 말한다.

---

## 7. 사용자에게 반드시 즉시 알려야 하는 상황

작업 중 아래 상황이 발생하면 숨기지 않는다.

- 현재 connector가 파일 크기 때문에 내용을 읽을 수 없음
- write API가 필요한 부분 수정 방식을 지원하지 않음
- local filesystem / Godot executable이 필수인데 접근 불가
- 사용자의 local dirty state를 확인할 수 없어 안전한 수정이 불가능
- 현재 branch의 local-only commit을 원격에서 확인할 수 없음

이 경우:

1. 무엇이 막혔는지 정확히 설명하고
2. 왜 Codex가 반드시 필요한지 설명하고
3. 즉시 실행 가능한 Codex 지시문을 제공한다.

"나중에 하자", "일단 넘어가자"로 종료하지 않는다.

---

## 8. 삼국WAR 프로젝트의 고정 협업 모델

### 채코치

- 설계
- 구조 감사
- 원인 분석
- 작은/중간 코드 수정
- GitHub 연결 도구로 안전하게 가능한 직접 패치
- commit/diff 검토
- QA 설계
- F6 결과 해석
- Codex 작업 2차 리뷰

### 로컬 Codex

- 로컬 저장소 직접 수정이 필수인 작업
- 대형 파일 부분 수술
- repository-wide 정밀 검색/참조 감사
- 여러 파일 atomic 변경
- 로컬 git 상태 기반 작업
- 로컬 실행 환경이 필요한 검증

### 김작

- 최종 Godot F6 시각/기능 QA
- 디자인/기획 최종 판단
- branch merge/promotion 승인

---

## 9. 한 줄 판정 규칙

> 채코치가 현재 도구로 **안전하게 끝까지 실행할 수 있으면 직접 한다.**
>
> 현재 도구 한계 때문에 **끝까지 실행할 수 없으면 숨기거나 미루지 않고 즉시 Codex로 에스컬레이션한다.**
>
> Codex 에스컬레이션은 편의를 위한 선택이 아니라, 로컬 실행 권한이 실제로 필요한 경우에만 사용한다.

---

## 10. 이번 규칙이 생긴 실제 계기

WorldMap Domestic Tech Tree ownership 수정 과정에서 `scripts/worldmap/worldmap_main.gd`가 매우 큰 파일이라 연결 GitHub 도구로 전체 파일을 안정적으로 취득·부분 수정할 수 없었다.

이때 임시 test controller를 또 추가하는 방식은 문제를 가리는 땜질이 될 수 있었으므로, 로컬 Codex에 구조 통합 작업을 맡겼다.

Codex는 로컬 저장소에서:

- Tech Tree dual ownership 제거
- destructive rebuild lifecycle 수정
- test controller 제거
- scene reference 제거
- repository-wide ownership audit
- HUD property single-writer 추가 감사/수정

을 수행했고, 채코치와 김작이 F6 결과를 검수했다.

이 사례를 기준으로 앞으로도 **도구 한계가 구조 품질을 떨어뜨리게 두지 않는다.**
