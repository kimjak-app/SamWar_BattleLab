# 시험 보강 D — 변이가 통과하던 두 곳에 검사 추가 (2026-10-25)

| 상태 | 브랜치 | 기준 | 끝 해시 | 커밋 |
|---|---|---|---|---|
| 끝남 | `feature/test-strengthen-20261025` | `3f8f83e`(integration) | 이 보고서를 담은 커밋(zip `commit_info.txt`·`AFTERNOON_SUMMARY`에 적음) | 1 |

- 지시: `QUEUE_AFTERNOON_20261025.md` 항목 D. 합격 판정은 하지 않는다. **[사실]** / **[추정]**으로 구분한다.
- **제품 코드 변경 0.** 엔진 쓰기 15개 그대로, 새 엔진 읽기 0. 새 검증기 없음. 기존 검사는 한 줄도 지우거나 바꾸지 않았다. **추가만** 했다(19줄). [사실, `git diff --stat`]

## 1. 바꾼 줄 (파일:줄, 모두 추가)

### 1-1. `tests/scripts/test_battle3d_top_commands.gd` (+4줄, 37 → 39 checks)

| 줄 | 추가한 것 |
|---|---|
| :75-76 | `auto_text_colors`(자동 버튼의 글자색 4개: 보통·호버·누름·포커스)와 시작(꺼짐) 때 값 `text0` |
| :139 | **자동 켜짐**: 글자색 4개가 모두 꺼짐 때 색과 다르다 |
| :143 | **자동 꺼짐**: 글자색 4개가 꺼짐 때 색으로 돌아온다 |

- 막는 변이: `battle3d_top_commands.gd:95`의 `LIT_TEXT if lit else TEXT_COLOR`를 `TEXT_COLOR`로 바꾸는 것. 이전 시험은 테두리 색만 봐서 이 변이가 통과했다.

### 1-2. `tests/scripts/test_battle3d_enemy_roster.gd` (+15줄, 37 → 39 checks)

| 줄 | 추가한 것 |
|---|---|
| :129-134 | 재생 보류 검사(기존) 뒤, 적 재생이 끝나고 아군 턴이 될 때까지 기다린 다음 5프레임 더 기다림. 그때의 `apply_count`를 적어 둠(:135) |
| :136-137 | **20프레임 정지 구간**: `enemy_roster.apply_count`(다시 그린 횟수)가 늘지 않는다 |
| :138-143 | 관우에게 시험용으로 화상 3턴을 넣어 카드 값 하나를 바꿈('▼ 화상 2턴' → '▼ 화상 3턴'). **5프레임 안에 `apply_count`가 정확히 1 늘고** 카드 글이 새 엔진 값이다 |

- 막는 변이: `battle3d_enemy_roster_hud.gd:30`의 `if cards == shown: return`을 지우는 것. 이전 시험은 보이는 값만 봐서 이 변이가 통과했다.
- 시험용 쓰기(`apply_status_effect`)는 기존 보류 검사(:115)와 같은 방식이다. 이 뒤의 승리 연습은 새 전투라 영향이 없다. [사실]

## 2. 실행 결과 (Windows, 단독)

| 시험 | 결과 | 원문 |
|---|---|---|
| `test_battle3d_top_commands.gd` | **39 checks, 실패 0** | `evidence/test_runs/test_battle3d_top_commands.log` |
| `test_battle3d_enemy_roster.gd` | **39 checks, 실패 0** | `evidence/test_runs/test_battle3d_enemy_roster.log` |

### 2-1. 변이를 넣어 한 번씩 확인 (참고용, 정식 변이 시험은 클코치가 함)

제품 파일에 변이를 잠깐 넣고 시험을 돌린 뒤 `git checkout`으로 되돌렸다(커밋에는 없음, `git status`로 확인). [사실]

| 변이 | 시험 | 결과 |
|---|---|---|
| `top_commands.gd:95` `LIT_TEXT if lit else TEXT_COLOR` → `TEXT_COLOR` | top_commands | **실패 1**: "auto on: every text color ... differs" (켜짐 글자색이 꺼짐 색 (0.93, 0.9, 0.84)과 같음) |
| `enemy_roster_hud.gd:30` `if cards == shown: return` 삭제 | enemy_roster | **실패 2**: "20 still frames" (apply_count 297 → 317, 매 프레임 다시 그림), "re-applied exactly once" (297 → 322) |

원문: `evidence/test_runs/mut1_top_commands.log`, `mut2_enemy_roster.log`.

## 3. 전체 CI 방식 실행 (Windows, 원문 `evidence/ci_full/`)

- 작업 트리(이 두 시험 추가분, 커밋한 내용과 같음)에서 실행했다. 검증기 **58개 전부 exit 0**, 시험 **154개 전부 exit 0**(이 두 시험은 CI 안에서도 각 39 checks). 씬 불러오기 3개·`editor --quit-after 2`·`git diff --check` exit 0. **실패 0**(기준 대비 새 실패 없음). 합계 약 3336초. [사실]

## 4. 김작이 정할 것

- 없음.

## 5. 못 한 것

- 사람이 직접 한 플레이는 없다. Linux에서는 돌리지 않았다.
- 정식 변이 시험은 하지 않았다(클코치 몫). §2-1은 지시에 적힌 두 변이만 한 번씩 넣어 본 것이다.
