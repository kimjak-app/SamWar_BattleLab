기준 화면: 해당 없음(게임 화면 아님, 백업 푸시) — 로컬에만 있는 가지 15개(정본의 `preserve/grok-terrain-20261029` 1개 + `C:\dev\_archive\SamWar_BattleLab_cc_백업_1026`의 가지 14개)를 GitHub 원격에 `archive/<원래 이름>`으로 올린 뒤의 `git ls-remote` 결과.
합격 기준: ① 원격에 `refs/heads/archive/…` 15개가 있고 각 해시가 아래 표와 같다 ② 이미 있던 원격 가지·태그·`main` 변경 0, 강제 푸시 0 ③ CI가 시작되지 않았다 ④ 보고서. 게임 F6는 없다.

# 지시서 — 로컬 전용 가지 15개를 `archive/` 이름으로 GitHub에 백업 푸시 (클코치, 2026-11-07)

- **김작 승인 [사실]**: 2026-11-07 10:23 "푸시해줘". 범위는 이 지시서의 15개 가지뿐이다. `main` 병합이 아니다.
- **목적**: 이 가지들의 사본이 지금은 백업 폴더와 번들(`cc_all_refs_20261029.bundle`) 둘뿐이다. GitHub에 사본을 하나 더 만들어, 이후 `SamWar_BattleLab_cc_백업_1026` 폴더를 지워도 되게 한다. 이 지시서는 **아무것도 지우지 않는다.**
- **큐의 일반 규칙(`feature/wm3d-*`만 푸시)의 예외**는 이 지시서의 `archive/…` 15개 푸시 하나뿐이다. 그 밖의 가지·태그 푸시, 삭제, 강제 푸시 금지.

## 0. 규칙
큐 상시 규칙 그대로. 막히면 `agent/REPORT_ARCHIVE_PUSH_STOP_20261107.md`로 멈추고 이 항목만 막는다. 허용 오차·CI 재실행 같은 일은 없다(코드 변경 0). `[skip ci]` 보고서 커밋은 큐의 평소 방식대로 새 가지 `feature/wm3d-archivereport-20261107`에 올린다.

## 1. 대상 15개 (이름 → 끝 커밋)
출처 A = `C:\dev\SamWar_BattleLab_cc`(정본), 출처 B = `C:\dev\_archive\SamWar_BattleLab_cc_백업_1026`.

| # | 출처 | 로컬 가지 | 끝 커밋 | 올릴 원격 이름 |
|---|---|---|---|---|
| 1 | A | `preserve/grok-terrain-20261029` | `9e80008` | `archive/preserve/grok-terrain-20261029` |
| 2 | B | `feature/battle3d-m3-enemy-turn-20261020` | `4545f46` | `archive/feature/battle3d-m3-enemy-turn-20261020` |
| 3 | B | `feature/battle3d-m4a-defend-20261021` | `adc6acc` | `archive/feature/battle3d-m4a-defend-20261021` |
| 4 | B | `feature/battle3d-m4b-strategy-20261022` | `37132ce` | `archive/feature/battle3d-m4b-strategy-20261022` |
| 5 | B | `feature/battle3d-m4c1-skill-20261022` | `8e736fb` | `archive/feature/battle3d-m4c1-skill-20261022` |
| 6 | B | `feature/battle3d-m4c2-enemy-skill-20261022` | `a6b51da` | `archive/feature/battle3d-m4c2-enemy-skill-20261022` |
| 7 | B | `feature/battle3d-m4d-reinforce-20261022` | `af96d53` | `archive/feature/battle3d-m4d-reinforce-20261022` |
| 8 | B | `feature/battle3d-m5a-autoplay-20261022` | `c855d27` | `archive/feature/battle3d-m5a-autoplay-20261022` |
| 9 | B | `feature/battle3d-m5b-scenario-20261022` | `054bafe` | `archive/feature/battle3d-m5b-scenario-20261022` |
| 10 | B | `feature/engine-s4-1-tactic-events-20261021` | `a6ef11b` | `archive/feature/engine-s4-1-tactic-events-20261021` |
| 11 | B | `feature/engine-s4-2-enemy-strategy-20261022` | `390d623` | `archive/feature/engine-s4-2-enemy-strategy-20261022` |
| 12 | B | `feature/engine-s4-2c-skill-rotation-20261022` | `0dd907b` | `archive/feature/engine-s4-2c-skill-rotation-20261022` |
| 13 | B | `feature/legacy-validators-refresh-20261023` | `9e763cd` | `archive/feature/legacy-validators-refresh-20261023` |
| 14 | B | `feature/night3-stack-20261023` | `e27ad14` | `archive/feature/night3-stack-20261023` |
| 15 | B | `feature/night3-test-gaps-20261023` | `93fb5dc` | `archive/feature/night3-test-gaps-20261023` |

- 끝 커밋은 7자리다. 전체 해시는 각 저장소에서 `git rev-parse <가지>`로 구해 보고서에 적는다. **표의 7자리와 앞자리가 다르면 그 가지는 푸시하지 말고 멈춘다.**
- **CI를 일으키지 않는 이름**: 워크플로가 `feature/**`·`integration/…`에만 반응하므로 앞에 `archive/`를 붙인 이름은 시작되지 않는다. 푸시 뒤 `gh run list`로 새 실행이 없음을 확인한다.

## 2. 푸시 전 확인
1. 출처 A·B 둘 다 `git status --short` 출력(변경이 있어도 푸시에는 영향 없으나 원문을 보고서에 적는다). 현재 가지를 바꾸지 않는다(`git switch` 금지).
2. `git ls-remote origin 'refs/heads/archive/*'` = **빈 값**이어야 한다. 이미 있으면 멈춘다(덮어쓰기 금지).
3. 출처 B의 `origin` 주소가 `https://github.com/kimjak-app/SamWar_BattleLab.git`인지 `git remote -v` 원문. 다르면 멈춘다.

## 3. 푸시
가지마다 한 줄씩(강제·`+` 없음, 현재 가지 불변):
```
git -C <출처 경로> push origin <끝 전체해시>:refs/heads/archive/<원래 이름>
```
15개를 순서대로, 하나라도 실패하면 거기서 멈추고 STOP 보고서.

## 4. 푸시 후 확인
1. `git ls-remote origin 'refs/heads/archive/*'` 원문 15줄. 각 해시가 1절 끝 전체해시와 같아야 한다.
2. `git ls-remote origin refs/heads/main` = `a9e3b84229f63286bbdc784d78826b0e2cdb792d` 그대로. 기존 가지·태그 변경 0.
3. `gh run list --limit 5` 또는 `gh api …/actions/runs`로 이번 푸시가 만든 새 실행이 없음.
4. 15개 각각 `git merge-base --is-ancestor <끝> origin/archive/…`로 올라간 가지가 끝 커밋을 포함하는지.

## 5. 보고서
`agent/REPORT_ARCHIVE_PUSH_20261107.md`: 15개 표(가지, 전체 해시, 원격 해시, 같음/다름), 위 확인 원문, 종료 루틴 5줄. 보고서만 새 가지 `feature/wm3d-archivereport-20261107`(시작 `origin/main`)에 `[skip ci]` 커밋 1개로 올린다.
- 종료 루틴에 반드시: "삭제한 것 0", "`SamWar_BattleLab_cc_백업_1026` 폴더·번들은 그대로 둔다".

## 6. 이 지시서가 하지 않는 것
백업 폴더·번들·로컬 가지 삭제(클코치가 4절 결과를 독립 확인한 뒤 김작 승인으로 별도 지시서), 원격 가지 삭제, `main` 변경, 코드 변경.
