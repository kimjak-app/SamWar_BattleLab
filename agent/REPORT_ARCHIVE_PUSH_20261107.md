기준 화면: 해당 없음(게임 화면 아님, 백업 푸시) — 푸시 뒤 `git ls-remote origin 'refs/heads/archive/*'` 결과 15줄(4절).
합격 기준: ① 원격 `refs/heads/archive/…` 15개, 해시가 1절 표와 같음 — **충족** ② 기존 원격 가지·태그·`main` 변경 0, 강제 푸시 0 — **충족** ③ CI 미시작 — **충족**(archive/* 실행 0) ④ 이 보고서. 게임 F6 없음.

# REPORT — 큐 29 ARCHIVE-PUSH: 로컬 전용 가지 15개 → `archive/…` 백업 푸시 (클코드, 2026-11-07)

- 지시서: `agent/ORDER_ARCHIVE_PUSH_BACKUP_BRANCHES_20261107.md`(지시서 가지 `origin/feature/wm3d-orders-20261105` 끝 `e39edfe`)
- 승인 [사실]: 지시서 기재 김작 11-07 10:23 "푸시해줘", 김작 채팅 11-07 "큐 다시 읽고 29번 진행해".
- 출처 A = `C:\dev\SamWar_BattleLab_cc`(정본), 출처 B = `C:\dev\_archive\SamWar_BattleLab_cc_백업_1026`.
- 결과: 15개 모두 `[new branch]`로 푸시 성공. 삭제 0, 강제 푸시 0, 코드 변경 0.

## 1. 15개 표
| # | 출처 | 로컬 가지 | 지시서 7자리 | 로컬 전체 해시(`git rev-parse`) | 원격 해시(`ls-remote`) | 같음 | 끝 포함(`is-ancestor`) |
|---|---|---|---|---|---|---|---|
| 1 | A | `preserve/grok-terrain-20261029` | `9e80008` | `9e800082486008c0b881dd59fdd1b8d3d89bc1a7` | `9e800082486008c0b881dd59fdd1b8d3d89bc1a7` | 같음 | True |
| 2 | B | `feature/battle3d-m3-enemy-turn-20261020` | `4545f46` | `4545f4636d4485cbd39cc2af6f504bb7f3818690` | `4545f4636d4485cbd39cc2af6f504bb7f3818690` | 같음 | True |
| 3 | B | `feature/battle3d-m4a-defend-20261021` | `adc6acc` | `adc6acc0b9606cb44d2d3ab902c01b52a7ffad79` | `adc6acc0b9606cb44d2d3ab902c01b52a7ffad79` | 같음 | True |
| 4 | B | `feature/battle3d-m4b-strategy-20261022` | `37132ce` | `37132ceb0dfe7b13ff7a943f981d719b87e1dba3` | `37132ceb0dfe7b13ff7a943f981d719b87e1dba3` | 같음 | True |
| 5 | B | `feature/battle3d-m4c1-skill-20261022` | `8e736fb` | `8e736fb4322f68d6a64dce0620e77ecec5b3cb96` | `8e736fb4322f68d6a64dce0620e77ecec5b3cb96` | 같음 | True |
| 6 | B | `feature/battle3d-m4c2-enemy-skill-20261022` | `a6b51da` | `a6b51da8e8491e844c507aa562957e0a058bc0fb` | `a6b51da8e8491e844c507aa562957e0a058bc0fb` | 같음 | True |
| 7 | B | `feature/battle3d-m4d-reinforce-20261022` | `af96d53` | `af96d5305c37e27f157c628459337d5830b1bd61` | `af96d5305c37e27f157c628459337d5830b1bd61` | 같음 | True |
| 8 | B | `feature/battle3d-m5a-autoplay-20261022` | `c855d27` | `c855d27434a0eb2600e595ba14330d5d182f36c3` | `c855d27434a0eb2600e595ba14330d5d182f36c3` | 같음 | True |
| 9 | B | `feature/battle3d-m5b-scenario-20261022` | `054bafe` | `054bafec21fa164267d855c934eab9b77a1e3abf` | `054bafec21fa164267d855c934eab9b77a1e3abf` | 같음 | True |
| 10 | B | `feature/engine-s4-1-tactic-events-20261021` | `a6ef11b` | `a6ef11b76f54e1f51d7bc3eba88f0a0eca54a8cb` | `a6ef11b76f54e1f51d7bc3eba88f0a0eca54a8cb` | 같음 | True |
| 11 | B | `feature/engine-s4-2-enemy-strategy-20261022` | `390d623` | `390d623a7558303a6cf7fb2375123cf430b02323` | `390d623a7558303a6cf7fb2375123cf430b02323` | 같음 | True |
| 12 | B | `feature/engine-s4-2c-skill-rotation-20261022` | `0dd907b` | `0dd907b12ddd35540091a8a5795a45234f9c630c` | `0dd907b12ddd35540091a8a5795a45234f9c630c` | 같음 | True |
| 13 | B | `feature/legacy-validators-refresh-20261023` | `9e763cd` | `9e763cd4ffcc5e2aff61b0e2ca59c21a43c0e616` | `9e763cd4ffcc5e2aff61b0e2ca59c21a43c0e616` | 같음 | True |
| 14 | B | `feature/night3-stack-20261023` | `e27ad14` | `e27ad1422436204fac23fdce6fe1c0a65f2f7e06` | `e27ad1422436204fac23fdce6fe1c0a65f2f7e06` | 같음 | True |
| 15 | B | `feature/night3-test-gaps-20261023` | `93fb5dc` | `93fb5dc33649e584390df5611784a167759bd4a4` | `93fb5dc33649e584390df5611784a167759bd4a4` | 같음 | True |

원격 이름은 모두 `archive/<원래 이름>`이다. 7자리 앞자리 불일치는 0개였다.

## 2. 푸시 전 확인 (원문)
1. `git status --short`
   - 출처 A(가지 `feature/wm3d-cityhud4-20261106`): 출력 없음
   - 출처 B(가지 `feature/hud-label-move-20261024`): 출력 없음
   - 두 저장소 모두 `git switch`를 하지 않았다.
2. `git ls-remote origin 'refs/heads/archive/*'` → 출력 없음(빈 값).
3. 출처 B `git remote -v`:
   ```
   origin	https://github.com/kimjak-app/SamWar_BattleLab.git (fetch)
   origin	https://github.com/kimjak-app/SamWar_BattleLab.git (push)
   ```
4. 추가 확인 [사실]: CI 트리거를 지시서 1절과 대조했다.
   - `origin/main`: `verify-c-track.yml`, `verify-worldmap3d.yml` = `feature/**` + 고정 이름. `build-worldmap-action-videos.yml` = 고정 이름 1개.
   - 15개 끝 커밋 안의 워크플로(`build-worldmap-action-videos.yml`, `verify-c-track.yml`)에도 `**` 전체 매치나 `archive` 패턴은 없었다.

## 3. 푸시
가지마다 `git -C <출처> push origin <전체해시>:refs/heads/archive/<원래 이름>` 한 줄씩 실행했다(`+`·`--force` 없음). 15회 모두 exit 0이었고, 각 출력에 `* [new branch]      <전체해시> -> archive/<원래 이름>`이 있었다.

## 4. 푸시 후 확인 (원문)
1. `git ls-remote origin 'refs/heads/archive/*'` (15줄):
```
4545f4636d4485cbd39cc2af6f504bb7f3818690	refs/heads/archive/feature/battle3d-m3-enemy-turn-20261020
adc6acc0b9606cb44d2d3ab902c01b52a7ffad79	refs/heads/archive/feature/battle3d-m4a-defend-20261021
37132ceb0dfe7b13ff7a943f981d719b87e1dba3	refs/heads/archive/feature/battle3d-m4b-strategy-20261022
8e736fb4322f68d6a64dce0620e77ecec5b3cb96	refs/heads/archive/feature/battle3d-m4c1-skill-20261022
a6b51da8e8491e844c507aa562957e0a058bc0fb	refs/heads/archive/feature/battle3d-m4c2-enemy-skill-20261022
af96d5305c37e27f157c628459337d5830b1bd61	refs/heads/archive/feature/battle3d-m4d-reinforce-20261022
c855d27434a0eb2600e595ba14330d5d182f36c3	refs/heads/archive/feature/battle3d-m5a-autoplay-20261022
054bafec21fa164267d855c934eab9b77a1e3abf	refs/heads/archive/feature/battle3d-m5b-scenario-20261022
a6ef11b76f54e1f51d7bc3eba88f0a0eca54a8cb	refs/heads/archive/feature/engine-s4-1-tactic-events-20261021
390d623a7558303a6cf7fb2375123cf430b02323	refs/heads/archive/feature/engine-s4-2-enemy-strategy-20261022
0dd907b12ddd35540091a8a5795a45234f9c630c	refs/heads/archive/feature/engine-s4-2c-skill-rotation-20261022
9e763cd4ffcc5e2aff61b0e2ca59c21a43c0e616	refs/heads/archive/feature/legacy-validators-refresh-20261023
e27ad1422436204fac23fdce6fe1c0a65f2f7e06	refs/heads/archive/feature/night3-stack-20261023
93fb5dc33649e584390df5611784a167759bd4a4	refs/heads/archive/feature/night3-test-gaps-20261023
9e800082486008c0b881dd59fdd1b8d3d89bc1a7	refs/heads/archive/preserve/grok-terrain-20261029
```
2. `git ls-remote origin refs/heads/main` → `a9e3b84229f63286bbdc784d78826b0e2cdb792d	refs/heads/main`(그대로).
   - 기존 ref 비교 [사실]: 푸시 전후 `git ls-remote origin` 전체 목록을 비교했다. 전 73줄, 후 88줄이다. 바뀐 것은 `refs/heads/archive/…` 15줄 추가뿐이고, 그 밖의 가지·태그 변경·삭제는 0이다.
3. CI:
   - `gh api repos/kimjak-app/SamWar_BattleLab/actions/runs?per_page=30`에서 `head_branch`가 `archive/`로 시작하는 실행 = `0`.
   - `gh run list --limit 5`의 맨 위는 푸시 전과 같다(`42232869404` CH-4, 2026-11-06T14:19:19Z). 새 실행은 없다.
4. `git merge-base --is-ancestor <끝> origin/archive/…`: 15개 모두 `True`(1절 표 마지막 열).
   - 첫 확인 스크립트는 PowerShell 변수 `$a`/`$A` 이름 충돌로 저장소 경로가 덮어써져 `fatal`이 났다. 변수 이름을 바꿔 다시 실행한 결과가 위 값이다. 푸시 자체와는 관계없다.

## 5. 택한 해석
- 보고서 가지 `feature/wm3d-archivereport-20261107`(시작 `origin/main` `a9e3b84`)는 정본의 현재 가지를 바꾸지 않으려고 git 하위 명령으로 만들었다(임시 index, `commit-tree`, 해시 푸시). 정본 작업 트리와 현재 가지(`feature/wm3d-cityhud4-20261106`)는 그대로다. 로컬 가지는 만들지 않았다.
- 보고서 커밋은 `[skip ci]` 1개뿐이다(`feature/**` 트리거 대상이므로 `[skip ci]` 필수).

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-cityhud4-20261106` 그대로, `git status` 깨끗. 출처 B도 가지 `feature/hud-label-move-20261024` 그대로, `git status` 깨끗.
2. 원격 변경은 `archive/…` 15개 추가와 이 보고서 가지 `feature/wm3d-archivereport-20261107`(`[skip ci]` 1개)뿐이다. `main`(`a9e3b84`)·orders·intake·그 밖의 가지·태그·PR 변경 0, 강제 푸시 0.
3. **삭제한 것 0.** `SamWar_BattleLab_cc_백업_1026` 폴더와 번들(`cc_all_refs_20261029.bundle`)은 그대로 둔다. 로컬 가지 15개도 그대로다.
4. 코드 변경 0줄. 김작 사용자 파일(`user://`) 손대지 않음. Godot 실행 없음.
5. 다음: 클코치가 4절 결과를 독립 확인한다. 그 뒤 김작 승인으로 백업 폴더·번들 정리 지시서를 따로 받는다(이 지시서 6절). 큐의 남은 '준비됨' 항목 확인.
