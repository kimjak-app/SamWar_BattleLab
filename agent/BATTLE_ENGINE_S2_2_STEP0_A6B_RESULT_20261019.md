# S2-2 Step 0 — A6b 실제 이동 후 공격 기준선

기준: `ba0402c8575714a9c7037d815220beb91eeb6531`
브랜치: `test/s2-2-step0-real-move-baseline-20261019`
origin: `https://github.com/kimjak-app/SamWar_BattleLab.git`
원격 integration을 fetch하여 정확한 해시 일치 확인. push 없음.

## 구현
- 기존 작업 디렉터리를 재사용하고 새 로컬 브랜치에서 작업했다. 추가 대용량 복사본을 만들지 않았다.
- A6은 유지하고 A6b를 추가했다. 초기 위치 (1,4)에서 `_try_direct_move_to_cell(Vector2i(3,4))`로 실제 이동한다.
- 실제 Tween을 기다려 facing_select에 도달한 뒤 `_select_post_move_facing("right")` → `try_basic_attack()` → `_try_attack_enemy_target_from_attack_select(target)`를 호출한다.
- 관찰 중 has_moved/last_action/phase/pending을 직접 쓰지 않는다. 이동거리 2 보존, 이동과 공격의 실제 콜백, 자동 적 행동 후 복귀까지 관찰한다.
- 기존 15개 사례와 골든의 기존 메타데이터는 값 동일. 새 A6b 레코드만 추가. 기존 골든의 base_commit은 최초 기준 2ba0464를 유지하며 이번 추가 기준은 이 보고서의 ba0402c다.
- 프로덕션 scripts/**, scenes/**, project.godot 및 이동 골든 변경 없음.

## 중요한 경계: 상태 관찰과 호출 보존은 다르다
| 체크포인트 | phase | pending snapshot |
|---|---|---|
| start | ally_turn | false |
| move_requested | resolving | true |
| move_finished | facing_select | true |
| facing_confirmed | ally_turn | false |
| attack_select | attack_select | false |
| requested / animating | resolving | false |
| finished_before_enemy | enemy_turn | false |
| after_enemy_slot | ally_turn | false |

정상 입력 경로에서는 방향 확정이 이미 snapshot을 해제한다. 따라서 실제 이동을 추가하는 것만으로 공격 종료의 정리 호출 삭제를 상태 골든에서 구분할 수 없다.

테스트 전용 BoundaryBattle에 투명한 `_clear_pending_move_snapshot` 관찰 override를 추가했다. 항상 즉시 super를 한 번 호출하고, A6b 방향 확정 이후에만 호출 당시 phase와 pending_before를 기록한다. 생산 코드는 수정하지 않았다.
- 요청 직후: 정리 호출 기록이 비어 있어야 한다.
- 적 행동 직전: 정확히 `[{phase: resolving, pending_before: false}]`여야 한다.
- 전체 공격 경로: resolving 중 정리 호출은 한 번이어야 한다.
- 적 행동 이후 enemy_turn의 별도 정리 호출도 골든에 그대로 기록한다.

이 단언은 **공격 종료의 호출/시점 보존 계약**이다. 삭제가 정상 입력에서 가시적인 상태 오류를 만든다는 주장이나, pending=true인 채 공격하는 사용자 경로를 재현했다는 주장이 아니다. 내부 공격 진입 함수를 직접 호출해 phase gate를 우회하거나 가짜 snapshot을 주입하지 않았다.

## 검증 (Level 1, 해당 범위)
- 전체 16사례 generate: exit=0, 70.46초. 각 사례 2회 비교.
- 전체 16사례 compare: exit=0, 70.89초. 각 사례 2회 비교.
- 종료 시점 단언 보강 후 A6b만 최종 재실행: `checks=36 failures=[]`, exit=0. 생산 코드/골든 변경은 없어 전체 회귀를 반복하지 않았다.
- 기존 S2-1, S1-2, M1-b, B3D contract validator 모두 PASS.
- S2-1 validator는 병합 시 고정된 기존 15사례 구현 커밋을 검증한다. A6b는 현재 실행 테스트와 기존 15사례 불변 비교로 검증했으며 역사적 validator의 고정값을 변경하지 않았다.
- git diff --check 통과. 기존 15사례 전체 JSON 동일, 프로덕션/이동 골든 diff 없음 확인.
- 원격 CI, Linux 실행, 전체 프로젝트 회귀는 이번 작은 테스트 보강에서 재실행하지 않았다. 이전 검수의 Linux 결과를 이번 A6b 결과로 주장하지 않는다.

## 정리 호출 제거 음성 프로브
기존 S2_1_NegativeProbe 디렉터리를 재사용했다. 원본 생산 코드가 현재 기준과 같은지 확인한 뒤 복사본의 `_finish_basic_attack_demo`에서 정리 호출 한 줄만 제거했다. finally에서 원래 바이트를 복원했다.

exit=1, 5.16초
```text
[ATTACK_ORACLE] FAIL A6b pending cleanup observed at attack finish before enemy
[ATTACK_ORACLE] FAIL A6b attack finish preserves pending cleanup call
```

구문 오류 없이 새 단언에서 실패했다. 로그와 변경 patch는 외부 검수 ZIP에 포함한다.

## 다음 단계와 검수 추천
S2-2 상태/이벤트 분리는 지시서 수령 후 시작한다. 이번에는 **호출 보존 단언의 의미가 적절한지** 클코치의 짧은 확인을 추천한다. 새 A6b는 정상 이동 후 공격 경로를 고정하고, 삭제 프로브는 별도의 호출 관찰로 검출한다는 구분이 검수 포인트다. 전체 회귀 재검수를 요청하는 것은 아니다.
