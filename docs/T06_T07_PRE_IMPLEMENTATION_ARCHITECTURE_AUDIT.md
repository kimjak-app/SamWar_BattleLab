# T06–T07 선행 구조 감사 및 구현 계약

기준선: `main` / `0d805dbbbf445cb0aec689e842646311063fdbc9`

## 1. 목적과 범위

이 문서는 T06–T07 장수 고유기 구현에 앞서 데이터 권한, 런타임 생성, 전투 실행, 기세, 병종, ID 규칙을 단일 파이프라인으로 고정한다. 이번 단계에서는 39명 고유기를 실전에 연결하지 않는다. 구조 감사, 고아 후처리 제거, 실행 아키텍처 계약 수립까지만 수행한다.

## 2. 현재 권한 경계

### 유지되는 단일 경로

`hero_unique_skills.json`
→ `HeroDesignDataRegistry`
→ `HeroRuntimeFactory`
→ `BattleUnit payload`
→ `BattleSkillResolver`

- 장수 원천 데이터의 정규화와 검증은 `HeroDesignDataRegistry`가 담당한다.
- 전투에 들어가는 런타임 장수 및 payload 조립은 `HeroRuntimeFactory`가 담당한다.
- 전투 상태는 Factory가 만든 payload를 소비하며 별도 Registry나 UI 후처리로 재조립하지 않는다.
- 실제 효과 해석과 실행은 신규 `BattleSkillResolver` 계층에서만 수행한다.
- 월드맵 UI, 씬 폴링, Label 탐색, setter 부작용은 데이터 권한을 소유하지 않는다.

### 삭제되는 구형 경로

- `scripts/worldmap/hero_worldmap_stat_integration.gd`
  - 월드맵 씬 폴링
  - Label RegEx 재귀 스캔
  - 능력치 및 병종 사후 덮어쓰기
  - 구형 `support`/`지원` 표시 처리
- `scripts/battle/hero_battle_design_invocation.gd`
  - `HeroBattleDesignAdapter`를 감싸는 미사용 중복 래퍼

`HeroRuntimeFactory.build_battle_unit_payload()`는 실제 `BattleUnitState` 생성 경계이므로 유지한다.

## 3. 고유기 원본 계약

`data/heroes/generated/hero_unique_skills.json`을 고유기 설계 데이터의 유일한 원본으로 지정한다.

필수 필드 후보:

- `skill_id`
- `hero_id`
- `display_name`
- `effect_type`
- `momentum_cost`
- 대상 규칙
- 범위 규칙
- 수치 modifier
- 지속 턴
- 확률
- 태그
- AI 힌트

구형 `UNIQUE_SKILL_REGISTRY`와 Context 내부 재조립은 단계적으로 제거한다. 전환 기간에도 신규 JSON과 구형 Registry를 동시에 합성하는 fallback은 두지 않는다.

## 4. effect_type 정규화

장수별 수십 종 `effect_type`을 실행 코드가 직접 분기하지 않는다. Registry 로딩 단계에서 8~10개 공통 execution archetype으로 정규화한다.

권장 archetype:

1. `damage_single`
2. `damage_line`
3. `damage_area`
4. `buff_self`
5. `buff_team_area`
6. `debuff_single`
7. `debuff_area`
8. `control_area`
9. `restore_dispel`
10. `movement_charge`

장수별 차이는 modifier 데이터로 표현한다.

예시 modifier:

- damage coefficient
- stat scaling source
- target filter
- shape/radius/line length
- duration
- stack rule
- hit count
- displacement distance
- cleanse/dispel count
- status tags
- conditional bonus

Resolver는 `archetype + modifiers`만 실행하며 장수 이름이나 개별 skill ID 하드코딩을 금지한다.

## 5. BattleSkillResolver 책임

Resolver 입력:

- caster `BattleUnitState`
- validated skill payload
- battle context snapshot
- selected target or target position

Resolver 출력:

- 검증 결과
- 기세 소비 계획
- 대상 목록
- 효과 명령 목록
- 실패 사유
- 전투 로그/UI 표시용 결과

Resolver 단계:

1. skill payload schema 검증
2. caster 생존/행동 가능 여부 검증
3. 기세 및 cooldown 검증
4. 대상 및 범위 검증
5. archetype 실행 계획 생성
6. 효과 적용
7. 성공 시 자원 확정 차감
8. 결과 이벤트 발행

UI나 AI는 효과를 직접 적용하지 않고 Resolver 호출만 수행한다.

## 6. 기세 시스템 선행 결정 항목

구현 전 아래 항목을 별도 설계 결정으로 확정해야 한다.

- 기세 소유 단위: 진영 공용 / 장수별 / 혼합
- 시작 기세
- 최대 기세
- 획득 조건과 획득량
- 턴 경과에 따른 자연 증감 여부
- 스킬 선택 취소 시 차감 여부
- 대상 무효 또는 실행 실패 시 환불 여부
- 다단계 스킬 중단 시 처리
- UI 표시 위치와 예고
- AI 최소 기대효용 및 보존 기준
- 저장/불러오기 schema

권장 기본안은 **진영 공용 기세**다. 전투 흐름과 AI 판단을 단순화하고 장수 교체·사망 때 자원 소실 문제가 적다. 단, 최종 결정 전 실제 전투 루프와 UI를 대조한다.

차감 원칙 권장안:

- 스킬 버튼 선택: 차감 없음
- 유효 대상 확정 후 실행 커밋: 차감
- 사용자 취소: 차감 없음
- 시스템 검증 실패: 차감 없음
- 실행 커밋 뒤 일부 대상 면역/회피: 환불 없음

## 7. canonical hero ID 계약

- 모든 설계 JSON, RuntimeHero, BattleUnit payload, 저장 데이터는 canonical `hero_id`만 저장한다.
- 표시 이름은 lookup이나 저장 키로 사용하지 않는다.
- 구형 ID alias는 단일 alias table에서 canonical ID로 변환한다.
- alias 변환은 Registry 로딩 또는 save migration 경계에서 한 번만 수행한다.
- 여러 파일에 alias map을 복제하지 않는다.
- validator가 중복 ID, alias 충돌, 미등록 hero ID, skill의 미존재 hero 참조를 실패 처리한다.

## 8. 병종 계약

허용 전투 병종:

- `infantry`
- `cavalry`
- `archer`
- `gunner`
- `mounted_archer`

`support`는 병종이 아니라 전투 역할이다.

- 도림·정도전 등 구 지원형 장수는 `archer`
- 고니시 유키나가·혼다 마사노부는 `gunner`
- 도요토미 히데요시는 `archer`
- `support`를 `gunner`로 자동 변환하는 코드와 fallback은 제거한다.

### mounted_archer 상태

Factory 허용만으로 실전 지원으로 간주하지 않는다. 아래가 모두 확인되기 전까지 `mounted_archer`는 **미지원/실험 상태**로 표시한다.

- BattleUnit normalize
- unit template
- visual token / animation
- 이동 및 공격 규칙
- AI 평가
- 저장/불러오기
- 편성 UI
- validator 및 smoke test

미지원 상태에서 mounted_archer 데이터가 실전 진입하면 validator 또는 명시적 로딩 오류로 차단한다. 다른 병종으로 조용히 치환하지 않는다.

## 9. BattleUnit 재결합 계약

현재 `unit_id` setter의 `_rebuild_authority_from_unit_id()`는 QA 안전장치로 작동하지만 최종 구조로 승인하지 않는다.

목표 구조:

- `rebuild_from_runtime_hero(runtime_hero, overrides := {})`
- 호출자는 Context hero 변경을 명시적으로 수행한다.
- 함수는 `HeroRuntimeFactory.build_battle_unit_payload()` 결과를 한 번에 적용한다.
- `unit_id`, stats, unit_type, visual_key, roles, unique_skill_id를 원자적으로 갱신한다.
- 일반 property setter가 데이터 전체를 숨은 부작용으로 재생성하지 않는다.
- 별도 fallback이나 부분 patch를 추가하지 않는다.

교체 전까지 현재 setter는 회귀 방지 테스트 대상으로 유지하되 신규 호출 경로를 늘리지 않는다.

## 10. Validator 계약

T06–T07 구현 전 최소 validator:

- 39명 skill 데이터 로드 성공
- skill ID 중복 없음
- hero ID canonical 존재
- effect_type → archetype 매핑 누락 없음
- 필수 modifier schema 검증
- momentum_cost 범위 검증
- unit_type 5종 외 값 차단
- `support` unit_type 차단
- mounted_archer 실전 지원 플래그 검증
- 구형 Registry 참조 금지 또는 전환 목록 출력
- Factory payload에 `unique_skill_id` 및 validated skill reference 포함 확인

## 11. 단계별 구현 순서

### T06-7A: 데이터 계약

- JSON schema 확정
- canonical ID/alias 단일화
- effect taxonomy → archetype mapping 작성
- validator 추가

### T06-7B: 런타임 전달

- `HeroDesignDataRegistry`가 validated skill definition 제공
- `HeroRuntimeFactory`가 battle payload에 실행 가능한 skill reference 전달
- 구형 Context/Registry 재조립 제거

### T06-7C: 실행기

- `BattleSkillResolver`와 archetype executor 구현
- 개별 장수 하드코딩 금지
- 단위/헤드리스 테스트 작성

### T06-7D: 기세

- 소유 단위와 규칙 확정
- battle state/save/UI/AI 연결
- 취소/실패/환불 계약 테스트

### T06-7E: 제한된 실전 연결

- 대표 archetype별 1개 스킬만 먼저 연결
- Godot F5 수동 QA
- 회귀 확인 후 39명 확대

## 12. 유지되는 QA 자산

수동 QA 씬:

- `Battle_WebImport_Test.tscn`
- `Battle_Singijeon_Test.tscn`
- `scenes/dev/video_theora_test.tscn`

현재는 유지한다. 추후 `manual_qa` 경로 또는 이름 정리만 검토한다.

헤드리스 smoke test 5개는 정상적인 CLI 테스트 자산으로 유지한다.

## 13. 완료 기준

이번 감사·정리 트랜잭션 완료 기준:

- 확정 고아 파일 2개 물리 삭제
- 기존 `HeroRuntimeFactory.build_battle_unit_payload()` 유지
- 신규 fallback, 숨은 setter, 후처리 시스템 추가 없음
- T06–T07 선행 설계 계약 문서 추가
- 정적/헤드리스 검증 결과 기록
- Godot F5가 필요한 항목은 사용자 QA 전까지 PASS로 표기하지 않음

다음 세션의 구현 시작점은 **39명 연결이 아니라 T06-7A 데이터 계약과 validator**다.
