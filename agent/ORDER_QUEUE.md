기준 화면: 없음(운영 규칙 문서). 지시서 큐와 진행 규칙이다. 각 단계의 기준 화면은 단계 지시서 맨 위에 있다.
합격 기준: 김작이 하루 끝에 F6 한 번으로 T-WM3D-06·07·08을 확인한다(3D 월드맵 정식 연결). 그 전까지 클코드는 자동 검증(로컬 테스트 + CI 초록 + 보고서)으로 다음 단계로 넘어간다.

# ORDER_QUEUE — T-WM3D-06 → 07 → 08 작전 (클코치 작성, 2026-11-05 10:20)

## 0. 이 문서의 위치와 효력
- 이 문서와 단계 지시서(`agent/ORDER_WM3D_*.md`)는 **지시서 전용 가지** `origin/feature/wm3d-orders-20261105`(코드 없는 빈 이력)에만 있다. 김작이 11-05 09:59 "B로 하자"로 승인했다: 클코치가 이 가지에 지시서를 올리고, 클코드는 읽기만 한다.
- 클코드는 이 가지에 **절대 push하지 않는다.** 코드·보고서는 지금처럼 `feature/wm3d-intake-20261101`에 올린다.
- 읽는 법(작업 트리를 건드리지 않음): `git fetch origin feature/wm3d-orders-20261105` 뒤 `git show origin/feature/wm3d-orders-20261105:agent/ORDER_QUEUE.md`. 지시서 파일 목록은 `git ls-tree --name-only origin/feature/wm3d-orders-20261105 agent/`.
- 이 큐와 단계 지시서가 충돌하면 **단계 지시서가 우선**(좁은 규칙이 우선). 이 큐와 기존 운영 규칙(김작 11-01 21:25 사전 승인: 클코드는 `feature/wm3d-*`에만 push, force·보호 가지·삭제 금지)이 충돌하면 **더 엄격한 쪽**을 따른다.

## 1. 큐 (순서대로, 건너뛰지 않는다)
| 순서 | 파일 | 상태 |
|---|---|---|
| 1 | `agent/ORDER_WM3D_06_ROADS_20261105.md` | 준비됨 |
| 2 | `agent/ORDER_WM3D_07_BATTLE_ENTRY_20261105.md` | 준비됨 |
| 3 | `agent/ORDER_WM3D_08_PRODUCTION_20261105.md` | 준비됨 |
| 4 | `agent/ORDER_AUDIT_M7_WORLDMAP_TO_3D_BATTLE_20261105.md` | 완료 |
| 5 | `agent/ORDER_AUDIT_CITYHUD_20261105.md` | 완료 |
| 6 | `agent/ORDER_M7_0_TEST_REPAIR_20261105.md` | 준비됨 — **새 가지** `feature/wm3d-m7prep-20261105`(시작점 `9160baf`), 정본 가지 push 금지 |
| 6 | (위 6번) | **완료**(`add66d5`·`62abaad`) |
| 7 | `agent/ORDER_CITYHUD_CH1_ASSETS_20261105.md` + **답신 `agent/ORDER_CITYHUD_CH1_REPLY_1_20261105.md`** | **멈춤→답신(B안)으로 재개**, 새 가지 `feature/wm3d-cityhud-20261105` |
| 7 | (위 7번) | **완료**(`e391737`·`ef509c1`) |
| 8 | `agent/ORDER_M7_0B_LIFECYCLE_TEST_20261105.md` | **완료**(`bc79d2a`·`05e2e1b`) |
| 9 | `agent/ORDER_CITYHUD_CH2_WINDOW_20261105.md` | **완료**(`ffb8778`·`846f128`) |
| 10 | `agent/ORDER_MERGE_MAIN_20261105.md` | **완료**(`main` = `ab9b739`, 태그 `baseline-pre-wm3d-main-20261105` → `66b29ba`, 보고서 `70392ba`) |
| 11 | `agent/ORDER_M7_1_CONTEXT_ENTRY_20261105.md` + 답신 `agent/ORDER_M7_1_REPLY_1_20261105.md` | **완료**(`a051d5a`·`8b139b4`, 보고서 `ae49670`, C-track success) |
| 12 | `agent/ORDER_CITYHUD_CH3_LAYOUT_20261105.md` | **완료**(`328ee04`·`a63e137`, 보고서 `ced058f`) |
| 13 | `agent/ORDER_CITYHUD_CH2B_DOCK_20261106.md` | 준비됨 — 가지 `feature/wm3d-cityhud-20261105`(이어서 커밋, 시작 `ced058f`). **김작 F6(11-06 09:08) 지적: 성 안 창을 좌측 정보창 옆으로. M7보다 먼저** |
| 14 | `agent/ORDER_CITYHUD_CH2C_LEFT_PANEL_GRIP_20261106.md` | 준비됨 — 가지 `feature/wm3d-cityhud-20261105`, 13번 뒤. 좌측 정보창 이동 손잡이(main 수정 0, 불가하면 멈춤) |
| 15 | `agent/ORDER_WM3D_PERF_CSV_READ_20261106.md` | 준비됨 — **읽기 전용**(코드·설정 수정 금지). 김작 PC `wm3d_mem_log.csv` 숫자 요약 + 증거 CSV 커밋 |
| 16 | `agent/ORDER_M7_2_RESULT_RETURN_20261106.md` | 준비됨 — 가지 `feature/wm3d-m7prep-20261105`(이어서 커밋, 시작 `ae49670`). 엔진 쓰기 +1(17) |
| 17 | `agent/ORDER_M7_4_RETREAT_20261106.md` + **답신 `agent/ORDER_M7_4_REPLY_1_20261106.md`** | **멈춤→답신(A안)으로 재개**(준비됨 상태 복귀). 18·19번은 다른 가지라 **멈추지 않고 진행**(답신 3절) — M7 가지, 16번 뒤. 엔진 쓰기 +1(18). M7-3(월드맵→3D 전장)은 별도 지시서(클코치 작성 예정) |
| 18 | `agent/ORDER_TURNBTN_RESKIN_20261106.md` | 준비됨 — **새 가지** `feature/wm3d-turnbtn-20261106`(시작 `main` `ab9b739`). 턴 종료 버튼 겉모습만 교체(노드·시그널 불변). 에셋 `agent/assets/turnbtn_512/` 9장. 17번 뒤 |
| 19 | `agent/ORDER_WM3D_PERF2_STARTUP_PROFILE_20261106.md` | 준비됨 — **읽기 전용 측정**. 새 가지 `feature/wm3d-perf-20261106`(시작 `main` `ab9b739`). 3D 시작 ~10초를 단계별로 쪼개고 구울 수 있는지 판정. 코드·설정 수정 금지. 18번 뒤(맨 뒤) |
| 20 | `agent/ORDER_HUD_CAPTURE_20261106.md` | 준비됨 — **읽기 전용 증거 수집**. 새 가지 `feature/wm3d-evidence-20261106`(시작 `cityhud` 끝). **16번 끝난 직후, 17번보다 먼저**(허드 리뉴얼용 전체 캡처 4장 + 창 위치 JSON, 김작 11-06 11:42) |
| 21 | `agent/ORDER_INTEGRATE_F6_20261106.md` | 준비됨 — **새 가지** `feature/wm3d-integrate-20261106`(시작 `main` `ab9b739`). cityhud·m7prep·turnbtn 3개 가지를 합쳐 김작이 F6 한 번으로 확인. 충돌은 `verify-c-track.yml` 하나만 예상. `main` 병합 금지. **먼저 한다** |
| 22 | `agent/ORDER_WM3D_PERF3_BAKE_PATHS_20261106.md` | 준비됨 — **새 가지** `feature/wm3d-bake-20261106`(시작 `main` `ab9b739`). 도로·바닷길 경로를 미리 구워 시작 약 4초 단축(결과 완전 일치가 조건). 21번과 독립, 21번 뒤 |
| 23 | `agent/ORDER_MERGE_MAIN_INTEGRATE_20261106.md` | 준비됨 — **`main` fast-forward 1회 + 백업 태그 1회**(김작 승인 11-06, 조건부 합격·F6 미확인). integrate 끝 `042b070`을 `main`에 합류. PERF3는 제외. 보고서는 새 가지 `feature/wm3d-mergereport-20261106`. 22번과 독립 — **22번을 기다리지 말고 지금 진행해도 된다**(다른 가지). 멈추면 이 항목만 막는다 |
| 24 | `agent/ORDER_HUDFIX_CITYWIN_TURNBTN_20261106.md` | 준비됨 — **새 가지** `feature/wm3d-hudfix-20261106`(시작 `main` `042b070`). 도시 내부창을 성 그림만(제목줄·닫기 삭제, ESC/창 밖 빈 지도 클릭으로 닫기) + 턴 버튼 하늘/테두리 틈 원인 수정(구멍 실측 중심에 맞추고 +3px 겹침). `main` 푸시 금지. 22번과 독립 — 22번 멈춤을 기다리지 말고 진행 |
| 25 | `agent/ORDER_HUDFIX_REPLY_1_20261106.md` | 준비됨 — **24번 STOP 답신**(가지 `feature/wm3d-hudfix-20261106`에서 이어서). 턴 버튼 테스트 72행 한 줄 수정 허용(선택 A), 창 밖 클릭 규칙 확정(드래그는 닫지 않음). 24번을 이 답신대로 끝낸다 |
| 26 | `agent/ORDER_WM3D_PERF3_REPLY_1_20261106.md` | 준비됨 — **22번 STOP 답신**(`feature/wm3d-bake-20261106`). 조건부 합격 문구 한 줄만 보고서에 추가(문서만, `[skip ci]`). 코드·CI 변경 0. 25번 뒤 |
| 27 | `agent/ORDER_CITYHUD_CH4_TECH_LINK_20261106.md` | **준비됨** — 28번 합류 확인(`main` = `a9e3b84`). 새 가지 `feature/wm3d-cityhud4-20261106`(시작: `origin/main` `a9e3b84229f63286bbdc784d78826b0e2cdb792d`). 성 안 건물을 테크 완료와 연동(생활 5종·민가 항상, 시장 최고 단계 하나, 항구→무역항). `main` 수정 0줄 |
| 28 | `agent/ORDER_MERGE_MAIN_HUDFIX_20261106.md` | 준비됨 — **김작 승인 11-06 21:16 "병합해!"**. HUDFIX(`a9e3b84`)를 `main`에 fast-forward 1회 + 백업 태그 1회. 보고서는 새 가지 `feature/wm3d-mergereport2-20261106`. 27번(CH-4)보다 **먼저** 한다 |
| 29 | `agent/ORDER_ARCHIVE_PUSH_BACKUP_BRANCHES_20261107.md` | 준비됨 — **김작 승인 11-07 10:23 "푸시해줘"**. 로컬 전용 가지 15개(정본 `preserve/grok-terrain-20261029` 1 + 백업_1026 가지 14)를 `archive/<원래 이름>`으로 GitHub에 백업 푸시. `main` 병합 아님, 삭제 0, 강제 푸시 0. 27번(CH-4)과 독립. 보고서는 새 가지 `feature/wm3d-archivereport-20261107` |
| 30 | `agent/ORDER_DEBUG_CHEATS_20261108.md` | 준비됨 — **새 가지** `feature/wm3d-debugcheats-20261108`(시작 `main` `a9e3b84`). 디버그 빌드 전용 치트 3개(자원 9999 채움 / 선택 테크 즉시 완료 / 첩보 없이 적 성 정보). **STOP→답신 `agent/ORDER_DEBUG_CHEATS_REPLY_1_20261108.md`로 재개(A안): `worldmap_main.gd` 수정 0줄, 컨트롤러는 `WorldMap.tscn` 자식 노드 1개**, 푸시는 이 가지에만. 27번(CH-4)과 독립 |
| 31 | `agent/ORDER_WARNFIX_20261108.md` | 준비됨 — **새 가지** `feature/wm3d-warnfix-20261108`(시작 `main` `a9e3b84`). 디버거 경고 14개(그림자 5·정수 나눗셈 9) 뿌리 정리, 동작 불변. **30번이 끝난 뒤 시작.** `worldmap_main.gd`·`p1_exact_delta` 금지(걸리면 STOP 목록으로) | **[11-08 STOP→답신 1 `agent/ORDER_WARNFIX_REPLY_1_20261108.md`: A안 — 31번은 `main` 12개만, 30번 가지에서 치트 컨트롤러 경고 2개 먼저 정리]**
| 32 | `agent/ORDER_MERGE_MAIN_CHEATS_WARNFIX_20261109.md` | 준비됨 — **김작 승인 11-09 10:08 "병합해."**. 30번(치트+경고2)과 31번(경고12)을 합친 새 가지 `feature/wm3d-warnmerge-20261109`(30번 끝 `3e391b1` + 31번 커밋 3개 cherry-pick, `PROGRESS_WM3D.md` 충돌만 허용) → CI 초록 → `main`(`a9e3b84`) fast-forward 1회 + 백업 태그 `baseline-pre-debugcheats-warnfix-20261109` 1회. 보고서는 새 가지 `feature/wm3d-mergereport3-20261109`. 30·31번 가지 수정 금지 | **[11-09 STOP(푸시가 `[skip ci]`로 CI 0회)→답신 1 `agent/ORDER_MERGE_MAIN_CHEATS_WARNFIX_REPLY_1_20261109.md`: A′ — 새 가지 `feature/wm3d-warnmerge2-20261109`에 순서만 바꿔(문서 2개 → 코드 커밋 마지막) 다시 만든 뒤 CI → `main`. 기존 가지·force push 없음]**
| 33 | `agent/ORDER_CLEANUP_BRANCHES_20261109.md` | **완료**(11-09, 합격, 보고서 `e62e201`) — **김작 삭제 승인 11-09 11:07 "지워주고"**. 이미 `main`(`8cc0640`)에 들어간 가지 4개(`feature/wm3d-debugcheats-20261108`·`…warnfix-20261108`·`…warnmerge-20261109`·`…warnmerge2-20261109`) 원격+로컬 삭제. 삭제 전 번들·기록을 기존 `_archive\cleanup_20261029\`에 저장. 다른 가지·태그·PR 변경 0. 보고서는 새 가지 `feature/wm3d-cleanupreport-20261109`. **32번은 이미 완료** |
| 34 | `agent/ORDER_CLEANUP_MERGED_BRANCHES_20261109.md` | 준비됨 — **김작 삭제 승인 11-09 11:53 "추천대로"**. `main`(`8cc0640`)에 통째로 들어간 `feature/wm3d-*` 7개(`ci-prep`·`cityhud`·`hudfix`·`intake`·`integrate`·`m7prep`·`turnbtn`) 원격+로컬 삭제. 번들 없이 해시 기록(tsv)만. 다른 가지·태그·PR 변경 0, 옛 `t06-*`·PR은 건드리지 않음. 보고서는 기존 가지 `feature/wm3d-cleanupreport-20261109`에 커밋 1개 |

- 다음 지시서 파일이 아직 없으면 **작업을 시작하지 말고** 5분마다 `git fetch`로 확인한다(최대 90분). 그래도 없으면 `agent/PROGRESS_WM3D.md`에 "대기 중: <파일명> 없음"을 적고 `[skip ci]` 커밋으로 올린 뒤 멈춘다.
- 클코드는 한 번에 한 단계만 한다. 단계가 끝나기 전에 다음 단계 파일을 읽어 두는 것은 허용(준비 목적), 코드 수정은 금지.

## 2. 한 단계가 끝났다는 조건 (다음 단계로 넘어가는 문)
1. 단계 지시서의 로컬 검증 전부 통과(결과 줄 원문을 보고서에).
2. 코드 커밋을 `feature/wm3d-intake-20261101`에 push, 원격 해시 = 로컬 HEAD.
3. 그 커밋의 `Verify C-track refactor`(4 shard)와 `Verify WorldMap3D`가 **success**. (아래 4절의 알려진 컷인 관찰은 예외 규칙을 따른다.)
4. 보고서 커밋(`[skip ci]`)과 `agent/PROGRESS_WM3D.md` 갱신(아래 3절)을 push.
5. 위 4개가 모두 되면 **김작 F6를 기다리지 않고** 다음 단계로 간다. (F6는 오늘 마지막에 김작이 한꺼번에 한다. 단계마다 커밋을 따로 만들어 두었으니 불합격하면 그 단계만 되돌릴 수 있다.)

## 3. 진행 기록 `agent/PROGRESS_WM3D.md` (feature/wm3d-intake 가지, 기존 `agent/` 폴더, 새 파일 1개)
단계가 끝날 때마다, 그리고 멈출 때마다 갱신한다. 내용: 시각 / 현재 단계 / 마지막 코드 커밋 해시 / 마지막 보고서 파일명 / CI 결과 / 다음 할 일 한 줄 / 멈춘 이유(있으면). 맨 위 두 줄은 "기준 화면 / 합격 기준". 이 파일은 클코드의 대화가 길어져 기억이 끊겨도 이어갈 수 있게 하는 용도다. **세션이 새로 시작되면 가장 먼저 이 파일과 이 큐를 읽는다.** 이 파일의 커밋은 `[skip ci]`로, 코드 커밋과 합치지 않는다.

## 4. 멈추는 조건 (아래 외에는 계속 진행한다)
다음 중 하나라도 해당하면 코드 수정을 멈추고, 상황을 `agent/REPORT_<단계>_STOP_<날짜>.md`(`[skip ci]`)와 `PROGRESS_WM3D.md`에 적고, **그 뒤 대기 절차(5절)**로 들어간다.
1. CI가 빨개졌고, 한 번의 읽기 전용 조사로도 원인이 확정되지 않을 때. (재실행으로 때우기 금지. 알려진 예외: shard 0의 `[CUTIN]` 길이 검사가 **60fps 이상 러너**에서 실패하면 컷인 관찰 자료로 적고 단계를 멈추지 않는다 — 단 CI가 그 실패 때문에 빨개서 문 조건 3을 못 채우면 멈춘다.)
2. `main`·`integration/*`·`work/*`·열린 PR의 머리/바닥 가지에 손대야 하거나, 삭제·force push·`gh`의 쓰기 명령이 필요할 때. **예외: `ORDER_MERGE_MAIN_20261105.md`(10번)만, 그 지시서가 적은 `main` fast-forward 푸시 1회와 태그 푸시 1회를 한다(김작 승인 11-05). 그 밖의 `main` 접근은 그대로 멈춤 사유.**
3. 단계 지시서의 수정·추가 경로 목록 밖을 고쳐야 할 때.
4. 단계 지시서의 [사실]과 실제 코드가 다를 때(추정으로 진행 금지).
5. 새 테스트 실패가 기존 코드의 문제로 보이는데 고치면 단계 지시서의 범위를 넘을 때.
6. 한 단계의 작업이 로컬 검증 시작 후 **4시간**을 넘겼을 때(무한 루프 방지).

## 5. 대기 절차 (멈춘 뒤)
- 멈춘 뒤에는 5분마다(최대 6시간) `git fetch origin feature/wm3d-orders-20261105`로 **새 지시서·답신**을 확인한다. 클코치는 멈춤 보고서를 읽고 이 가지에 `agent/ORDER_WM3D_<단계>_REPLY_<번호>.md` 형식의 답신을 올린다. 답신이 올라오면 그 파일의 지시대로 이어간다.
- 답신이 없으면 6시간 뒤 `PROGRESS_WM3D.md`에 "대기 종료(답신 없음)"을 적고 멈춘다.
- 클코드는 같은 이유로 두 번 멈췄다면(같은 파일·같은 오류) 세 번째 시도를 하지 않는다.

## 6. 변하지 않는 규칙 (모든 단계 공통)
- push는 `feature/wm3d-intake-20261101` 하나, force 없음. 보호 가지 금지. 삭제 금지. `gh`는 읽기 명령만(재실행·취소·삭제·secrets·settings 금지).
- 코드 커밋 → CI 확인 → 보고서 커밋(`[skip ci]`) 순서, 한 커밋에 합치지 않는다. 보고서는 `agent/REPORT_<단계>_<날짜>.md`.
- `scripts/worldmap/worldmap_main.gd`는 **08 지시서가 허용하는 경우에만** 수정한다(pinned 검사기). 07까지는 수정 금지.
- 새 폴더 금지(`scripts/worldmap/map3d/` 제외). 지시서의 수정·추가 경로 목록이 전부.
- 맨 위 두 줄 "기준 화면 / 합격 기준", 라벨 [사실]/[추정]/[미확인], 빈 곳은 추정으로 채우지 않고 문서·코드로 확인한다.
- 정답이 비명시이면 더 엄격한 쪽(코드를 덜 바꾸는 쪽)으로 하고 보고서의 "택한 해석"에 쓴다.

## 7. 클코치가 대신 정해 둔 결정 (김작 위임 11-05, 결정 기록에 남김)
1. ★ "3D 카메라 컨트롤러를 2D와 분리할까?": 김작 의견(분리)대로 **08의 마지막 하위 단계**로 한다. 비용이 크거나 테스트가 깨지면 보류하고 보고한다(상속 유지로 08은 완료 가능).
2. 08의 설정 화면은 **최소**: 2D/3D 전환, 3D 카메라 입력안(A/B). 그 이상 만들지 않는다.
3. 07은 **2D 전투(`Battle_Main.tscn`)로 들어가는 연출과 메모리 측정만**. 3D 전투 연결(M7)은 이번 작전(06~08)에서 하지 않는다. (11-05 13:19 김작이 M7 방향을 승인했고, 4번 감사 → 구현 지시서 순서로 간다. 4·5번은 **읽기 전용 감사**라 코드 수정 금지.)
4. F6와 GTX 1660 FPS(08 목표 ≥ 60)는 김작만 확인한다. 클코드는 이를 합격 조건으로 쓰지 말고, 측정 수단·방법만 보고서에 정리한다.

## 8. 김작이 하는 일 (오늘)
1. 클코드에게 이 큐를 읽게 하는 문장 하나만 붙여 넣는다(클코치가 문장을 따로 준다).
2. 하루 끝에 F6 한 번(06·07·08), "합격/불합격".
3. `main` 병합 승인(오늘이 아니어도 됨).

## 9. 6·7번 특별 규칙 (11-05 16:30, 5절·6절의 push 가지 규칙보다 **이 절이 우선**)
- 6번·7번은 오늘 밤 김작 F6·`main` 합류 대상(`feature/wm3d-intake-20261101` `9160baf`)을 **바꾸지 않기 위해** 각자 새 가지에서 한다. 각 지시서가 정한 가지에만 push한다(김작 11-01 사전 승인 `feature/wm3d-*` 범위). 정본 가지에는 push하지 않는다.
- 보고서·진행 기록도 각자의 새 가지에만 쓴다(정본 `PROGRESS_WM3D.md` 수정 금지). 6번이 끝난 뒤 7번을 시작하고, 새 가지는 항상 `9160baf`에서 만든다(7번은 6번 가지 위가 아님).
- 6·7번 중 하나라도 멈추면 큐 5절 대기 절차를 따른다.

## 10. 상시 진행 규칙 (11-05 20:30, 김작 지시 "내가 알아서 계속 진행")
- **큐에 '준비됨' 항목이 있는 동안은 멈추지 말고 순서대로 끝까지 진행한다.** 확인 질문("이어서 진행할까요?")을 하지 않는다. 큐 항목이 다 끝났거나 멈춤 조건(4절)에 걸릴 때만 멈춘다.
- 큐가 비면 5분마다 `git fetch origin feature/wm3d-orders-20261105`로 새 항목·답신을 확인한다(최대 6시간). 새 항목이 올라오면 위 규칙대로 이어서 진행한다.
- 시작 전 항상 `git fetch origin`으로 지시서가 가리키는 가지의 끝 해시를 확인하고, **코드 HEAD가 같으면(문서 커밋만 다르면) 계속 진행**한다(정확한 해시 일치를 요구하는 문구는 "코드 HEAD 기준"으로 읽는다).
- 김작은 사업계획서 작업 중이라 부르지 않는다. 판단이 필요하면 STOP 보고서를 올리고 답신을 기다린다(5절).
