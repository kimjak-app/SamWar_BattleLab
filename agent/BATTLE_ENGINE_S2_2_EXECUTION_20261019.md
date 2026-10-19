# S2-2 — 공격 상태·이벤트 분리 실행 설계

- 사용자 승인: 클코치 지시서 없이 Codex가 세부 설계·구현·검증·로컬 커밋을 수행. push 없음.
- 기준: `3269385529f16bc8e77ce299ad05c53e022c4a11`
- 브랜치: `refactor/s2-2-attack-state-events-20261019`
- 전체 기준: BRP-20260919-1 / EASTWAR 3D 전체 설계 v1.1, M2 준비.
- 작업 전후 플레이: 3D 선택·이동은 동일. 공격 UI는 M2-3D에서 연결한다.

## 책임 경계

`BattleAttackStateService`는 계산이 끝난 피해 적용 및 기본 공격 metadata/status/post-attack-move 쓰기를 소유한다. Controller는 기존 계산, 게이트, 로그, 모멘텀, Tween, 타깃 선택, 행동 잠금, 상태 소모, 사망 정리, 턴 순서를 유지한다. 작은 쓰기 함수로 나누어 총병 로그 앞뒤의 쓰기 위치까지 보존한다.

수정할 기존 컨트롤러 함수는 정확히 네 개다.
- `play_basic_attack_demo`: 원래 피해 적용 위치를 서비스로 대체. 계약 커밋과 모멘텀 처리 후 `attack_resolved`를 기록한다.
- `_commit_basic_attack_unit_contract`: 기존 null guard와 로그·병종 조건 유지. metadata, 총병 penalty, 후속 이동 flag를 원래 순서대로 서비스에 위임한다. 이 공용 helper의 적 측 호출도 동일 값을 유지하며 적 공격 이벤트는 아직 없다.
- `_finish_basic_attack_demo`: 기존 `_mark_ally_unit_acted` 직후 `action_completed`를 기록한다. 상태/잠금/책략 tick은 해당 기존 함수가 계속 소유한다.
- `_cleanup_dead_units`: 기존 dead ID 최초 등록 및 lock 제거 직후 `unit_defeated`를 기록한다. 기존 중복 guard를 재사용한다. 이는 공용 사망 정리이므로 공격 외 원인의 전멸도 기록한다.

새 로그 `battle_action_event_log`는 씬 수명 단위이며 기존 `ally_move_event_log`와 별개 순서다. 두 로그의 sequence를 전역 순서로 비교하지 않는다. 향후 3D 소비자가 각 로그별 cursor를 가져야 한다. 동기 signal/callback은 도입하지 않는다.

## 고정할 동작

- 기존 이동/공격 골든 파일과 공격 관찰 하니스는 바이트 동일.
- 피해·공격 metadata·총병 penalty·모멘텀은 요청 시점. 행동 소모·status tick·사망 정리·적 자동 행동은 완료 시점.
- `_clear_pending_move_snapshot()`은 컨트롤러의 `_finish_basic_attack_demo` 안 기존 위치에서 정확히 한 번. A6b 호출 보존 단언 그대로.
- 계산 공식, 호출 게이트, A7a 아군 직접 공격 미보호 경계, A7b 후보 제외, 상태 비대칭, AI, 턴, 월드맵, 세이브, 3D 씬/입력 변경 없음.
- `damage_applied`는 기존 `apply_damage` 반환값(HP로 제한), 병력 차이를 재계산한 값이 아니다.
- `killed`는 피해 직후 생존 여부이며 `unit_defeated`는 실제 사망 정리 시점. 혼동하지 않는다.

## 테스트 경계 (Level 2)

- 기존 16사례 전체를 각 2회 실행하여 기존 골든과 비교한다.
- 기존 runner에 `case_labels()`만 추가하고 CI wrapper 두 개에서 앞 8개/뒤 8개를 실행한다. 전체 runner 수동 호출도 유지. partial 실행의 골든 쓰기 금지 유지. CI 기존 호출 한 줄을 두 shard로 교체하고 서비스/이벤트 테스트와 validator를 추가한다.
- 별도 이벤트 하니스는 기존 하니스를 상속하며 snapshot 시 로그 읽기만 한다. 16사례를 각 1회 구동, 기존 상태 골든과 비교한 후 요청/진행/완료/적 행동 전후의 event payload·횟수·순서를 검증한다. 기존 오라클에 새 사례를 추가하지 않는다.
- 서비스 단위 검증: HP/병력이 다른 입력, 0/음수/초과 피해, 공격 metadata, 5병종 후속 이동, 총병 penalty, 엄격한 JSON schema 및 복사 독립성.
- 이동/이벤트/3D 이동 및 인접 전투 회귀, 파싱/import, 단계 validator. 전체 월드맵 회귀나 Linux/원격 CI 실행을 주장하지 않는다.
- 별도 검증 복사본에서 피해·metadata·이벤트 시점/중복/사망·정리 호출 변조가 실패하는지 확인한다.

완료 후 독립 검수 권장: 상태 골든 불변, 공유 helper 호출 영향, 이벤트 발생 위치, A6b 호출 보존, CI shard의 누락/중복 여부.
