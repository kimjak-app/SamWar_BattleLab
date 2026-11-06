기준 화면: 정본이 아닌 작업 가지 `feature/wm3d-m7prep-20261105`(코드 커밋 `a051d5a`). 셸이 월드맵 전투 문맥으로 곧바로 3D 전장을 시작하는 경로는 로컬에서 전부 통과했으나, 그 커밋의 C-track이 빨갛다.
합격 기준: 지시서 `agent/ORDER_M7_1_CONTEXT_ENTRY_20261105.md` ④ C-track 4 shard success — **미충족**. 지시서 5절 2번("실패하면 고치지 말고 읽기 전용 조사 후 STOP")과 큐 4절 1번에 따라 멈춘다.

# 멈춤 보고서 — M7-1 (CI 빨강 2 shard)

## 요약 (3줄)
1. 코드 커밋 `a051d5a` push(원격 = 로컬). 로컬 검증은 전부 통과(새 테스트 35/0, battle3d 105/105, 검증기 72/72, 3D 월드맵 8종·왕복 28·입력 수명주기 PASS).
2. C-track run `42049548382`: shard 1·3 success, **shard 0 failure**(알려진 `[CUTIN]` 길이 검사), **shard 2 failure**(새 테스트의 검사 1개 — CI 환경에서는 월드맵 출정이 곧바로 장면 전환까지 감).
3. 판단 필요: ① shard 2를 테스트 쪽에서 어떻게 고칠지(아래 제안 A) ② shard 0 컷인 예외를 이번 문 조건에서 어떻게 볼지. 코드 수정은 하지 않았다.

## 진행 기록 (정본 `PROGRESS_WM3D.md` 대신 여기에 쓴다)
- 2026-11-05 23:5x~2026-11-06 — 큐 11번: 조사 → 구현 → 로컬 검증 → `a051d5a` push → CI 빨강 → 읽기 전용 조사 → 이 멈춤 보고서.
- 앞선 큐 9번(CH-2 `ffb8778`·보고서 `846f128`), 10번(MERGE-MAIN, 원격 `main` = `ab9b739`, 보고서 `70392ba`, 둘 다 `feature/wm3d-cityhud-20261105`)은 끝났다.
- 다음 할 일: 답신 대기(큐 5절, 5분마다 최대 6시간). 큐 12번(CH-3)은 순서상 시작하지 않는다(입력 zip 크기 64,054,220·SHA-256 `a1988dc0…9bb2` 일치만 미리 확인).

## 1. CI [사실]
| job | 결과 | 원인(로그 원문) |
|---|---|---|
| shard 0 `127321630391` | failure | `tests/scripts/test_battle3d_cutin_result_toast.gd` → `[CUTIN] checks=16 failures=["at speed x4.0 every 3D cut-in lasts at least 4.0 s minus 0.05 s measurement tolerance in real seconds (decision 3) [3.952, 3.954, 3.965, 3.955, 3.935]"]` |
| shard 1 `127321630292` | success | |
| shard 2 `127321630296` | failure | `tests/scripts/test_battle3d_worldmap_context_entry.gd` → `[BATTLE3D_CONTEXT_ENTRY] checks=35 failures=["no handoff happened while getting it (no meta, no scene change)"]` |
| shard 3 `127321630285` | success | |
- shard 0 로그는 `gh run view --log`에서 잘려 보였고, 전체 로그는 `gh api --allow-escape-sequences …/jobs/127321630391/logs`(읽기)로 받았다.
- 앞 커밋 `05e2e1b`(run `42021399523`)는 4 shard 모두 success였다.

## 2. shard 2 원인 [사실]
- 로컬: 월드맵의 출정 확인(`_confirm_player_attack_deployment`) 뒤 전투 진입 카메라 연출이 시간을 두고 진행되므로, 테스트는 한 프레임 뒤 `_get_pending_battle_context_mvp()`로 문맥을 읽고 월드맵을 해제해 장면 전환 없이 끝난다.
- CI: `Exclude 3D world map from shard import` 단계 때문에 `worldmap3d/` 스크립트가 파싱 실패한다(로그 `Failed to load script "res://worldmap3d/scripts/worldmap3d_root.gd"`, `set_city_owner … in base 'Node3D'`). 이때 출정 뒤 로그 순서가 `[PLAYER_ATTACK] start …` → `Battle_Main`의 `[Battle] WorldMap battle context received: type=attack …`·`WorldMap roster applied` → 테스트 실패 줄이다. 즉 **CI에서는 연출 없이 곧바로 `_change_scene_to_battle_with_context`가 불려 메타가 세워지고 `Battle_Main`으로 장면이 바뀌었다.**
- [추정] `_start_worldmap_battle_entry_camera_handoff`(main:6968)가 `_build_worldmap_battle_entry_focus`(6954)에서 빈 값(도시 화면 위치 없음)을 받아 `continue_callable.call()`로 바로 넘어간 경우다. 3D 없는 CI에서 도시 위치가 왜 없는지는 [미확인].
- 나머지 34개 검사(문맥 모드 시작·메타 소비·setup 메타 없음·버튼 숨김·양쪽 부대와 병력·메타 없을 때 시작 패널·깨진 문맥 2종)는 CI에서도 통과했다. 셸 코드 문제는 아니고 **테스트가 문맥을 얻는 방법이 CI 환경을 가정한 것**이 원인이다.

## 3. shard 0 원인 [사실]
- 큐 4절 1번의 알려진 예외(`[CUTIN]` 길이 검사, 60fps 이상 러너)와 같은 검사다. 이번 변경(셸 문맥 진입·`RESULT_TEXT`)은 컷인 경로를 건드리지 않았고 로컬에서 이 테스트는 통과했다. 그러나 큐 규칙대로 이 실패로 문 조건 3을 못 채웠으므로 멈춤 사유다. [미확인] 이번 러너의 fps.

## 4. 제안 (클코치 판단)
- **A(추천, 테스트만 수정, 6절 목록 안)**: 문맥을 얻을 때 월드맵의 장면 전환 경로가 열리지 않게, 출정 확인 **전에** 테스트가 카메라 컨트롤러의 "전투 진입 연출 중" 상태를 켜 둔다 → `_handoff_battle_context_to_battle_scene`이 맨 앞에서 돌아가(메타·장면 전환 없음) `pending_battle_context`만 남는다(main:6878-6881, `_set_pending_battle_context_mvp`는 그 전에 불림). 로컬·CI 모두 같은 경로가 된다. 보고서에 "테스트용 우회"로 방법·이유를 적는다.
- B: CI에서 장면 전환이 나면 그 메타 값을 문맥으로 쓰고 `Battle_Main`을 내리는 방식 — 지시서 3절 1번("장면 전환은 일어나지 않게")에 어긋나므로 추천하지 않음.
- shard 0: 다음 커밋의 CI에서 같은 컷인 실패가 다시 나면 어떻게 할지(이 단계 문 조건에서 예외로 볼지) 결정 필요. 재실행은 하지 않았다.

## 5. 현재 상태
- 가지 `feature/wm3d-m7prep-20261105` 끝: 코드 `a051d5a` + 이 보고서 커밋(`[skip ci]`). 작업 트리 깨끗. 정본 가지·`main`·`PROGRESS_WM3D.md` 손대지 않음. `worldmap_main.gd`·엔진 규칙 코드 0줄.
- M7-1 일반 보고서(`REPORT_M7_1_20261105.md`)는 CI가 초록이 된 뒤 쓴다(로컬 결과 표·diff·택한 해석 초안은 준비됨).

## 6. 종료 루틴
1. 코드 커밋 `a051d5a` push, 원격 = 로컬.
2. CI: run `42049548382` — shard 0·2 failure, 1·3 success.
3. 멈춤 보고서 커밋 `[skip ci]`, 이 가지에만.
4. 재실행·force·삭제·`gh` 쓰기 없음.
5. 다음: 답신 `agent/ORDER_M7_1_REPLY_<번호>` 대기(5분마다, 최대 6시간).
