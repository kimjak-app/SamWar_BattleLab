# 삼국WAR AI 협업 구현 원칙

이 문서는 김작과 채코치(ChatGPT)의 **협업 역할과 아키텍처 소유권 원칙**을 고정한다.
작업 실행 순서, preflight, 검증 레벨, CI/closeout 규칙은 이 문서가 아니라 `.agents/skills/samwar-dev/SKILL.md`가 단일 기준이다.

## 1. 기본 역할

- 채코치가 GitHub/연결 도구로 직접 구현 가능한 작업은 채코치가 직접 구현한다.
- 코드 수정, 리소스 경로 연결, 테스트 씬 수정, 설정 변경, 브랜치 반영 등 도구로 가능한 작업을 사용자에게 떠넘기지 않는다.
- 사용자는 구현 후 필요할 때 GitHub Desktop에서 Fetch/Pull하고 Godot F6/F5로 실제 화면과 동작을 검수한다.
- 사람 눈이 필요한 검수 결과를 바탕으로 채코치가 다시 수정한다.

기본 루프:
1. 채코치가 실제 코드/문서와 대상 범위를 확인한다.
2. 채코치가 직접 구현 가능한 부분을 구현한다.
3. 스킬이 정한 위험도 수준만큼 검증한다.
4. 사람 눈 검수가 필요한 경우에만 김작이 Godot에서 확인한다.
5. 피드백을 반영한다.

## 2. 금지 사항

- 직접 가능한 구현을 설명만 하고 사용자에게 떠넘기지 않는다.
- 최신 대상 브랜치/HEAD를 확인하지 않고 과거 상태를 기준으로 수정하지 않는다.
- 사용자의 기존 변경을 reset, rebase, restore, stash 등으로 임의로 덮어쓰지 않는다.
- 검증 근거보다 강한 완료 표현을 쓰지 않는다.

권한·push·commit·로컬환경의 상세 경계는 `agent/WORKFLOW_MANAGER.md`만 따른다.

## 3. 사용자 작업이 필요한 경우

다음처럼 연결 도구로 수행할 수 없는 경우에만 사용자 작업을 요청한다.
- Photoshop 등 로컬 GUI에서 수작업 원본 편집이 필요한 경우
- Godot 실행 화면을 사람 눈으로 판단해야 하는 경우
- 외부 로컬 환경에서만 가능한 입력/검수가 필요한 경우
- 연결 도구가 제공하지 않는 기능이 반드시 필요한 경우

사용자에게 요청하는 작업은 최소화한다.

## 4. 기본 검수 계약

- 채코치/Codex: 구현 및 코드 기반 검증
- 김작: 필요한 경우에만 최종 시각/플레이 검수
- 검증의 범위와 강도: `.agents/skills/samwar-dev/SKILL.md`의 Level 1/2/3 체계가 단일 기준

## 5. 월드맵 아키텍처 소유권

월드맵 신규 기능은 `scripts/worldmap/worldmap_main.gd`에 도메인 로직을 계속 쌓지 않는다.

1. 기존 책임 소유 Controller / Service / Helper가 있으면 그곳에 구현한다.
2. 기존 책임에 자연스럽게 속하지 않는 독립 기능만 전용 `.gd`를 만든다.
3. `worldmap_main.gd`에는 생성, dependency 연결, signal wiring, scene handoff, high-level orchestration만 남긴다.
4. 호환 wrapper가 필요하면 얇은 delegation/API adapter만 허용한다.
5. 구현 후 main에 새로운 도메인 계산·상태 mutation·UI 세부 로직이 쌓이지 않았는지 확인한다.

## 6. 전투엔진 리팩토링 소유권

- **어떻게 작업할지**: `.agents/skills/samwar-dev/SKILL.md`
- **권한/안전 경계**: `agent/WORKFLOW_MANAGER.md`
- **무엇을 어떤 순서/소유권으로 바꿀지**: `BATTLE_RUNTIME_REFACTOR_PLAN.md`
- **보존해야 할 전투 동작/공식/타이밍**: `agent/BATTLE_ENGINE_RULES.md`
- **WorldMap↔Battle 연결을 건드릴 때만**: `agent/BATTLE_WORLDMAP_HANDOFF_CONTRACT.md`

이 문서에서는 위 문서들의 읽기 순서나 검증 체크리스트를 복제하지 않는다.

B-0 이후 신규 전투 기능은 Production Controller/Service/Helper의 책임 소유자를 먼저 정하고 구현하며, 테스트는 Production 동작의 소비자/fixture로 유지한다.
