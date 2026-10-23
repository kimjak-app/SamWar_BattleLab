# HUD 시험 — 3D 전장 상단 기세 다이아몬드 + 턴 표시 결과 (2026-10-23)

- **푸시: 못 했다.** NIGHT4 지시문(김작 승인)에 따라 `feature/hud-spike-top-20261023`만 `origin`에 푸시하려 했으나, 이 작업 세션의 권한 확인이 `git push`를 거부했다. 우회하지 않았다. 김작이 직접 푸시하거나 세션 권한을 허용해야 한다. 끝 해시는 이 보고서를 담은 커밋이다(커밋은 자기 해시를 담을 수 없어서 zip의 `commit_info.txt`와 `agent/NIGHT4_SUMMARY_20261024.md` 맨 위에 적는다). `integration/*`·`main`은 건드리지 않았다.
- 지시: `HUD_SPIKE_TOP_20261023.md` (클코치)
- 기준 BASE `ba058c8a8e09f955230b5d48dd97e9de09074637`, 브랜치 `feature/hud-spike-top-20261023`
- 커밋 2개(작성자·커미터 `Claude <noreply@anthropic.com>`):
  1. `f0e91dcfd268b77e7eceead9842ba2de887e5dfa` `feat(battle3d): HUD spike - the 2D top HUD as an overlay on the 3D shell`
  2. 이 보고서 + 검증기 TIP 고정(`HUD_SPIKE_SCOPE_TIP` 기본값 = `f0e91dc`)
- 합격 판정은 하지 않는다. 멈춤 규칙에 걸린 것은 없다(2D 씬·엔진·서비스·어댑터·호스트·랩 변경 0, 새 엔진 읽기·쓰기 0, 새 난수 0).

## 0. 2D와 3D가 안 맞는 것 (맨 위)

1. **라벨 겹침**: 3D 랩이 이미 만든 텍스트 라벨 2개(`turn_label` "라운드 1 · 아군 턴 · 행동 중: …", `momentum_label` "기세 아군 3 / 적 3")가 HUD와 같은 자리(700..1220 × 18..76)에 있다.
   - 시험 기본값은 **(a) 셸에서 숨기기**다. HUD가 보이는 동안 셸이 두 라벨의 `visible`만 끈다(랩 코드 diff 0).
   - 숨기면 그 라벨에만 있던 정보가 화면에서 빠진다: **누구 턴인지(아군/적)**, **행동 중인 부대 id**, **기세 메모**(`momentum_note`), **"전투 종료" 문구**. 2D의 `ActiveSideLabel`·`BattleTitleLabel`은 2D 씬에 없는 노드라 HUD에도 없다.
   - 숨기지 않으면(`hide_lab_top_labels = false`) 라벨이 HUD **아래**(라벨 층 1, HUD 층 5)에 깔려 보이지 않는다(캡처 01). 라벨을 HUD 앞으로 꺼낸 증거 캡처(02)에서는 글자가 다이아몬드·"전투 1/30" 위에 겹친다.
   - (b) 비켜 두기는 하지 않았다. HUD를 옮기는 것은 재배치라 클코치 상의가 먼저다. 랩 라벨을 옮기는 것은 셸에서 `position`을 쓰면 랩 diff 0으로 가능하지만, 지시가 "옵션을 사실로 적기"라서 구현하지 않았다.
   - 라벨을 확인하는 기존 테스트(grep): `battle3d_skill_harness.gd` 6곳, `test_battle3d_defend_default_round`·`enemy_turn_default_layout`·`enemy_turn_locks`·`skill_rejections`·`wait_default_round` 각 1곳, `skill_default_round` 2곳, `validate_battle3d_m4c1_skill.py` 1곳. 모두 랩 단독(셸 없음)이라 숨김의 영향이 없다.
2. **기세 숫자 노드 없음**: 2D 컨트롤러는 `AllyMomentumHud/ValueLabel`, `EnemyMomentumHud/ValueLabel`, `TurnHud/ActiveSideLabel`, `TurnHud/BattleTitleLabel`에 글자를 쓰려 하지만 2D 씬에 그 노드가 없다(H0 §1). 3D에도 만들지 않았다. 그래서 기세는 다이아몬드로만, 턴은 "N / 30"으로만 보인다.
3. **기세 값이 바뀌는 때**: 2D는 엔진 값을 바로 보여 준다. 3D HUD는 랩의 `momentum_display`를 보여 준다. 랩은 이 값을 **적 행동 재생이 끝난 뒤에** 엔진 값으로 갱신한다(랩의 기존 동작). 그래서 적 턴 동안 다이아몬드는 재생이 끝날 때까지 이전 값이다. 라운드도 랩의 `current_round`(엔진 이벤트에서 유도)라서 재생 순서를 따른다.
4. **라운드 넘김 때 순서**: 랩의 `current_round`(라운드 시작 이벤트를 재생할 때 바뀜)와 `momentum_display`(재생이 다 끝난 뒤 바뀜)는 바뀌는 때가 다르다. 그래서 "2 / 30"이 먼저 나오고 기세가 조금 뒤에 바뀌는 프레임이 있을 수 있다. 캡처 driver 첫 실행 로그에서는 기세 상승이 처음 보인 프레임에 이미 라운드가 2였다("ally rose 0 -> 2 at round 2"). 몇 프레임인지는 재지 않았다.
5. **결과 후**: 2D는 전투 결과가 확정되면 HUD 전체를 숨긴다(`production_hud_root.visible = not battle_complete`). 3D도 랩의 `battle_result`가 생기면 숨기고 랩 라벨을 다시 보이게 한다. 2D의 "확정" 시점과 3D의 `battle_ended` 이벤트 시점이 같은 프레임인지는 비교하지 않았다.
6. **모양**: 다이아몬드 줄·"아군 기세"/"적군 기세" 제목·"전투"·"1 / 30" 글자는 같은 1920×1080에서 2D 화면과 **픽셀이 같다**(§2 표). 다른 곳은 프레임 가장자리처럼 반투명한 부분에 비치는 배경뿐이다(2D는 지도 그림, 3D는 어두운 배경과 전장).
7. 2D 씬의 TurnLabel 기본 글자는 "1/30"(띄어쓰기 없음)이지만, 2D 컨트롤러가 처음 갱신할 때 "1 / 30"으로 바꾼다. 3D도 "%d / %d"를 쓴다.

## 1. 기능 상태

바뀐 파일(BASE..`f0e91dc`, 8개):

| 파일 | 내용 |
|---|---|
| `scenes/battle3d/Battle3D_TopHud.tscn` (새) | 2D `Battle_Production.tscn`의 `TopHudRoot` 서브트리(노드 52개)를 그대로 복사했다. 위에 자체 루트 `CanvasLayer`(층 5)와 2D와 같은 `ProductionHudRoot` 감싸개(오프셋 −3, 2)를 뒀다. 자원은 2D가 쓰는 테마 `battle_ui_theme.tres`, 텍스처 `top_hud_frame_full.png`, 글꼴 `NotoSansCJKkr-Medium.otf`(경로·uid 같음)와 스타일박스 5개(내용 같음)다. 자산 복사는 없다 |
| `scripts/battle3d/battle3d_top_hud.gd` (새) | 채움 스크립트 `show_values(아군, 적, 라운드)`. 값이 바뀔 때만 적용한다. 칸 채움은 2D `_refresh_production_momentum_slots`와 같은 규칙이다(`index < value` → `MomentumSlot{Ally,Enemy}{Filled,Empty}` + 메타 스타일박스 + `modulate` 흰색). 턴은 `"%d / %d" % [라운드, BattleHudStateAdapter.MAX_TURN]`(=30, 2D 어댑터 상수). 엔진을 읽지도 쓰지도 않는다 |
| `scripts/battle3d/battle3d_scenario_shell.gd` (+20줄, 지운 줄 0) | HUD 장면을 셸 자식으로 붙인다. 값은 랩에 이미 있는 `lab.momentum_display`·`lab.current_round`만 넘긴다. 전투 결과가 생기면 HUD를 숨긴다(2D와 같음). HUD가 보이는 동안 랩의 `turn_label`·`momentum_label`의 `visible`만 끈다(`hide_lab_top_labels`, 기본 true) |
| `tests/scripts/test_battle3d_top_hud.gd` (새) + `.uid` | 새 테스트 1개(20 checks) |
| `tools/validate_battle3d_hud_spike_top.py` (새) | 새 검증기 |
| `.github/workflows/verify-c-track.yml` | 위 테스트·검증기 2줄 추가만 |
| `scripts/battle3d/battle3d_top_hud.gd.uid` (새) | Godot가 만든 uid |

- **랩(`battle3d_engine_play.gd`) diff 0, 엔진·서비스·어댑터·호스트·2D 씬 diff 0, 새 엔진 읽기·쓰기 0, 새 난수 0.** 셸은 랩의 기존 멤버 6개(`momentum_display`, `current_round`, `ready_for_input`, `battle_result`, `turn_label`, `momentum_label`)만 쓴다. 쓰기는 라벨 2개의 `visible`뿐이다.
- 갱신 시점: 셸 노드는 랩보다 먼저 처리돼서, 처음에는 HUD가 한 프레임 늦었다(첫 테스트 실행에서 전환 프레임 28개 불일치). HUD 노드에 `process_priority = 100`을 주고 HUD의 `_process`에서 셸 갱신 함수를 부르게 바꿨다. 이제 랩이 값을 바꾼 그 프레임에 HUD도 바뀐다. 셸의 기존 `_process`(결과창)는 그대로다.
- 셸을 안 거치는 `Battle3D_EnginePlayLab.tscn` 단독 실행에는 HUD가 없다(지시가 허용한 범위).

### 1-1. 새 테스트 `test_battle3d_top_hud.gd`

기대값은 테스트가 엔진 값으로 따로 만든다(칸: `engine.battle_momentum.get_value(side)`, 글자: `"%d / 30" % engine.battle_round`). 셸은 M5-b 하니스(관찰 호스트, 쓰기 기록)를 그대로 쓴다.

1. 시작 화면: HUD 숨김(층 5, 셸 층 10 아래)
2. 기본 배치 시작: 엔진 3/3·1라운드, 칸 3/10씩(변형 이름과 스타일박스 둘 다), "1 / 30"
3. 입력 전 쓰기 = 엔진 단독 시작과 같음
4. 랩 라벨 2개 숨김
5. 30프레임 그대로 두면 다시 적용 0, 엔진 쓰기 0
6. 숨김을 끄면 라벨이 보이고 HUD 상단 영역과 겹침(사각형 교차). 다시 켜면 숨김
7. 대기 3번 → 라운드 2, 아군 기세 상승(라운드 끝 +2), 칸·글자가 엔진 값과 같음
8. 승리 연습 [자동]으로 끝까지: 보인 모든 프레임에서 HUD 값 = 랩 값(불일치 0, 아군 상승 11번). 승리 뒤 HUD 숨김, 랩 라벨 다시 보임

결과(Windows, 단독): **20 checks, 실패 0, 35초**. `[TOP_HUD] applies=31 writes_default=10 ally_rises=11`

### 1-2. 새 검증기 `validate_battle3d_hud_spike_top.py`

- BASE `ba058c8`..TIP. **고정 모드(`HUD_SPIKE_SCOPE_TIP=<커밋>`)에서는 파일과 파일 목록을 모두 TIP 트리(`git ls-tree -r`, `git show`)에서 읽는다.** 작업 트리를 보지 않는다(밤샘 ③ 결함 재발 방지). `HEAD`면 작업 트리(추적 안 된 새 파일 포함)를 본다.
- 범위: 새 파일 6개 + 바뀐 파일 2개(셸, CI 목록) 밖이면 실패. 2D 씬·엔진·서비스·랩·랩 씬·셸 씬·어댑터·호스트·골든·데이터·자산 diff 0, 기존 테스트·하니스·검증기 diff 0, CI 목록은 추가 2줄만.
- HUD 장면 = 2D `TopHudRoot` 서브트리. 노드 52개를 `unique_id`와 부모 경로만 바꿔 줄 단위로 비교한다. 스타일박스 5개, 자원 3줄이 2D와 같아야 하고, `ProductionHudRoot` 오프셋은 (−3, 2)다.
- HUD 스크립트: 엔진·`call`/`get`/`set`·트리·파일·난수 없음, 2D 채움 규칙, "%d / %d"와 `BattleHudStateAdapter.MAX_TURN`, 값이 바뀔 때만 적용, 랩 뒤 갱신.
- 셸: 추가만, 추가 줄에 `engine` 없음, 랩 멤버는 위 6개만, 쓰기는 라벨 2개 `visible`만, 결과 뒤 숨김.
- 결과: 작업 트리 모드 PASS, 고정 모드(`f0e91dc`) PASS.

### 1-3. 변조 프로브 13개 (+ 대조군)

- 방식: 제품 파일에 변조를 1개씩 넣고(정확히 1곳 바뀜을 확인), 새 테스트(기본 설정)와 새 검증기(작업 트리 모드)를 돌린 뒤 원래 바이트로 되돌렸다. 끝에 3개 파일 모두 바이트가 같음을 확인했다.
- 러너 `evidence/run_hud_probes.py`, 원문 `evidence/probes/`, 요약 `evidence/probes_final_stdout.txt`
- 대조군: 테스트 exit 0, 검증기 PASS

| # | 변조 | 테스트 | 검증기 |
|---|---|---|---|
| P01 | 값이 반대(아군↔적) | **잡음** "every shown frame matched the lab's values (mismatches 814 …)" | **잡음** |
| P02 | 칸 수 off by one(`index <= value`) | **잡음** "start: Ally 3 of 10 filled (wrong slots [3])" | **잡음** "2D fill rule" |
| P03 | 라운드 글자 형식 "1/30" | **잡음** "turn '1/30' == '1 / 30'" | **잡음** |
| P04 | 셸에 엔진 쓰기(`_end_ally_turn_by_wait`) | **잡음** "before any input: writes == an engine started alone [_select_ally_unit, _end_ally_turn_by_wait]" | **잡음** "shell additions: no engine access" |
| P05 | 랩 값 대신 엔진 직접 읽기 | **잡음** "mismatches 166" | **잡음** |
| P06 | 매 프레임 다시 적용 | **잡음** "30 idle frames: no re-apply (36)" | **잡음**(검사 문자열이 없어 ValueError) |
| P07 | 랩 라벨 숨김 끔(기본 false) | **잡음** | **잡음** |
| P08 | 결과 뒤에도 HUD 표시 | **잡음** "battle result: HUD hidden (like 2D), lab labels back" | **잡음** |
| P09 | 랩보다 먼저 갱신(`process_priority = 0`) | **잡음** "mismatches 28" | **잡음** |
| P10 | 최대 턴 20 | **잡음** "turn '1 / 20' == '1 / 30'" | **잡음** |
| P11 | 장면의 아군 다이아몬드 색 바꿈 | **못 잡음**(테스트는 메타 스타일박스와 비교라 색을 안 본다) | **잡음** "stylebox == 2D: AllyDiamondFilled" |
| P12 | 결과 뒤 랩 라벨이 안 돌아옴 | **잡음** | **못 잡음**(PASS) |
| P13 | 시작 화면에도 HUD 표시 | **잡음** "start screen: HUD … hidden" | **못 잡음**(PASS) |

- **13개 모두 테스트나 검증기 중 하나 이상이 잡았다.** 둘 다 잡은 것 10개, 테스트만 2개(P12·P13), 검증기만 1개(P11).
- 처음 돌렸을 때 P04에서 테스트가 실패 문구 없이 시간 초과(400초)로 끝났다. 원인: 잘못된 쓰기로 전투가 끝난 뒤, 테스트가 다음 아군을 기다리다 빈 값에서 스크립트 오류로 멈췄다. 테스트를 고쳤다(입력 전 쓰기를 엔진 단독 시작과 비교, 아군이 없거나 전투가 끝나면 기다리지 않고 실패로 마감). 위 표는 고친 테스트로 13개 전부를 다시 돌린 결과다.

## 2. 화면 상태

캡처는 렌더링 창 1920×1080(`--resolution 1920x1080`, `root.size` 1920×1080), 기본 배치, 셸 장면 그대로(픽스처 없음)로 찍었다. 버튼은 `root.push_input` 마우스 클릭으로 눌렀다. 원본은 `evidence/capture/out/`에 있다. 상단을 2배 확대한 사본(`*_top_x2.png`, 440..1480 × 0..150)도 같이 넣었다.

| 파일 | 상태 | 엔진 값(같은 프레임 로그) | HUD |
|---|---|---|---|
| `00_start_3d_hud` | (1) 시작 | 기세 3/3, 라운드 1 | 칸 3/3, "1 / 30", 랩 라벨 숨김 |
| `01_overlap_lab_labels_kept` | (4) 겹침, 라벨 켬 | 3/3, 1 | 라벨이 HUD 아래(층 1 < 5)에 깔려 화면에 안 보임 |
| `02_overlap_lab_labels_in_front` | (4) 겹침 증거용(HUD 층을 0으로 잠깐 내림) | 3/3, 1 | 라벨 "라운드 1 · 아군 턴 · 행동 중: yi_sunsin", "기세 아군 3 / 적 3"이 다이아몬드·"전투 1/30" 위에 겹침 |
| `03_round_2` | (3) 라운드 넘김 뒤 | 기세 2/5, 라운드 2 | 칸 2/5, "2 / 30" |
| `04_ally_momentum_rose_by_attack` | (2) 아군 기세 상승 뒤 | 3/4, 라운드 2. 엔진 기세 기록 `basic_attack` 2→3 | 칸 3/4, "2 / 30" |
| `05_2d_production_start_reference` | 2D 비교용: `Battle_Production.tscn` 단독, 같은 창 | — | 2D 시작 상태 |

- (2)는 1라운드에 아군 기세가 오르지 않았다(기본 배치 [자동]에서 적에게 맞아 3→0). 그래서 엔진 기세 기록에서 첫 아군 `basic_attack` 상승을 찾고, HUD가 그 값을 보일 때 찍었다(2라운드). 라운드 끝 +2와 섞이지 않게 하려는 것이다. 엔진 기세 기록 읽기는 캡처 driver(증거용, 커밋 안 함)에서만 했다.
- 2D와 픽셀 비교(`00` 대 `05`, 같은 1920×1080 좌표):

| 영역 | 평균 차 | 차이 큰 픽셀(>24) |
|---|---|---|
| 아군 다이아몬드 657..872 × 50..68 | 0.00 | 0 / 3870 |
| 적 다이아몬드 1046..1256 × 48..66 | 0.00 | 0 / 3780 |
| "1 / 30" 920..1000 × 52..78 | 0.00 | 0 / 2080 |
| "아군 기세" 720..810 × 26..48 | 0.00 | 0 / 1980 |
| "전투" 935..980 × 28..50 | 0.00 | 0 / 990 |
| 상단 HUD 전체 497..1417 × 20..120 | 21.91 | 35873 / 92000 |

- 다이아몬드와 글자 영역에서는 글꼴·색·크기·위치가 2D와 같다. 전체 영역의 차이는 프레임 바깥(반투명 가장자리·그림자·빈 곳)에 비치는 배경 때문이다(2D는 지도 그림, 3D는 어두운 배경).
- 3D 화면의 다른 UI와는 겹치지 않는다. 왼쪽 정보 상자는 22..492, 오른쪽 옵션은 1690부터, [자동]·[속도] 버튼은 y 300 근처다(캡처 `00`).
- 김작이 올린 2D 스크린샷 원본은 받지 못했다. 그래서 비교 기준은 내가 같은 창 크기로 찍은 `05`다.

## 3. 실제 조작 증거

- 캡처 driver(`evidence/capture/capture_driver.gd`, 커밋 안 함): 셸 장면을 띄우고 [기본 배치] 버튼과 랩의 [자동 ▶] 버튼을 화면 좌표 마우스 클릭(`root.push_input`)으로 눌렀다. 로그 `evidence/capture/run.log`에 찍을 때마다 엔진 값·랩 값·HUD 값·라벨 상태를 같이 적었다.
- 새 테스트는 신호(`pressed.emit`)와 랩 클릭 함수로 조작한다(M5-b 하니스 방식).
- 영향 테스트·검증기(커밋 `f0e91dc`, Windows, `run_ci_subset.py`, 원문 `evidence/ci/`):
  - CI 목록 검증기 **52개 전부 exit 0**(새 검증기 포함). 기존 51개는 모두 고정 모드라 이 변경과 무관하다.
  - 셸을 쓰는 테스트 전부 **8개 exit 0**: `test_battle3d_scenario_start`(5초), `_defeat`(40초), `_new_battle`(28초), `_victory_seed_1/2/3`(각 40초 안팎), `_gaps`(20초), 새 `test_battle3d_top_hud`(35초). `editor --quit-after 2` exit 0.
  - 셸 승리 테스트 3개는 엔진 단독 자동과 최종 상태·로그·쓰기 순서가 같은지 본다. HUD를 붙인 셸에서도 같다.
  - 랩 코드가 그대로라서, 셸을 안 쓰는 3D 테스트(랩 라벨을 확인하는 `test_battle3d_*_default_round` 등)는 다시 돌리지 않았다. 전체 CI는 클코치가 한다.
- **사람이 직접 한 플레이는 없다.**

## 4. 남은 것

1. 라벨 겹침 처리 결정: 지금은 (a) 셸에서 숨김이다. 숨기면 "누구 턴 / 행동 중 부대 / 기세 메모 / 전투 종료" 글자가 화면에서 빠진다. (b) 비켜 두기(셸에서 랩 라벨 위치 옮기기, 또는 HUD 재배치)는 클코치 상의가 먼저라 하지 않았다.
2. 기세 숫자·차례 글자: 2D 씬에 노드(`ValueLabel`, `ActiveSideLabel`, `BattleTitleLabel`)가 없어서 3D에도 없다. 2D 컨트롤러는 그 노드에 쓰려다 아무것도 하지 않는다.
3. 적 재생 중 기세 값: 랩 설계대로 재생이 끝난 뒤 바뀐다. 2D처럼 바로 보이게 하려면 랩 쪽 결정(랩 변경)이 필요하다.
4. 라운드 글자와 기세 칸이 바뀌는 프레임이 어긋날 수 있다(§0-4). 몇 프레임인지 재지 않았다.
5. 2D와 결과 확정 시점 비교(§0-5)는 하지 않았다.
6. 프로브에서 한쪽이 못 잡은 것: P11은 테스트가 색을 안 보고, P12·P13은 검증기가 동작을 안 본다(각각 다른 쪽이 잡음).
7. Linux에서는 돌리지 않았다. 전체 CI도 돌리지 않았다.
8. 사람이 직접 한 플레이는 없다. 판단은 김작이 캡처를 2D와 나란히 보고 한다.
