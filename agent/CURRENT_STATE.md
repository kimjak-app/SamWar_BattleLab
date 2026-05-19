# CURRENT STATE

## Project
SamWar_BattleLab

## Current Stable Baseline
v0.64y Ally Ready Frame + Unit Selection Close-up Panel Verified

Do not bump to `v0.65` yet.
`v0.65` is still a later stability milestone, not the current baseline.

## Main Scene
`Battle_Fullscreen_Test.tscn`

This is the current stable 2v2 Godot battle verification scene.
The battle loop is working on this scene.

## Current Battle Setup
- Ally: 이순신, 정도전
- Enemy: 관우, 장비

## Current Battle Flow
1. 아군 1명 행동
2. 적군 1명 AI 행동
3. 남은 아군 행동
4. 남은 적군 AI 행동
5. 새 라운드 시작

This is the current verified 2v2 loop:
ally one actor acts -> enemy one actor acts -> remaining ally acts -> remaining enemy acts -> new round.

## Current Working Features
- 이순신 / 정도전 선택 가능
- 선택된 아군 기준 이동 가능
- 이동 후 방향 선택 가능
- 방향 선택 중 우클릭 이동 롤백 가능
- 기본공격 버튼 -> 공격 범위 표시 -> 관우 / 장비 클릭 공격 가능
- 공격 선택 중 우클릭 취소 가능
- 공격 / 대기 / 턴 종료 시 acted 처리 유지
- HP 0 유닛 cleanup 유지
- dead unit은 occupied / target / AI 후보에서 제외
- 관우 / 장비 AI 교대 행동 가능
- 새 라운드 중앙 배너 표시 가능
- READY frame으로 행동 가능한 아군 표시 가능
- UnitCloseupPanel로 선택한 아군 portrait / troop / 상태 표시 가능
- UnitCloseupPanel 위치는 Godot 2D editor에서 scene-authored 상태로 직접 조정 가능

## Completed Milestones
- v0.64s Two Unit Deployment Prototype
  2대2 전장 배치, 아군 이순신 / 정도전, 적군 관우 / 장비, 4유닛 occupied blocking 확장
- v0.64t Ally Unit Selection MVP
  이순신 / 정도전 선택 가능, 선택된 아군 기준 이동 / 방향 선택 / 공격 흐름 일반화
- v0.64u Enemy Target Selection MVP
  관우 / 장비 중 공격 대상 선택 가능, `selected_attack_target_state` 기준 데미지 / 피격 / HPBar 갱신
- v0.64v Occupied Hard Block + Basic Attack Select Mode
  유닛 겹침 방지 hard block, 기본공격 버튼 -> 공격 범위 표시 -> 적 클릭 공격 구조
- v0.64w Round Banner + Move-Then-Attack + Dead Unit Cleanup
  이동 후 방향 선택 -> 기본공격 / 대기 / 턴 종료, HP 0 유닛 전장 제거, 새 라운드 중앙 표시
- v0.64w hotfixes
  Attack Select Cancel + Move Rollback, Facing Select Right Click Rollback Fix, 우클릭 공격 취소, 우클릭 이동 롤백
- v0.64x Enemy Multi AI Activation MVP
  관우 / 장비 모두 AI actor로 교대 행동
- v0.64y Ally Ready Frame + Unit Selection Close-up Panel
  READY frame, 아군 closeup panel, scene-authored closeup panel 위치 조정 유지

## Working Principles
- Scene controls layout
- Code controls behavior
- Godot 2D editor에서 배치 후 `Ctrl+S` -> `F6` 반영
- `UnitCloseupPanel` 위치는 scene-authored 상태 유지
- `READY frame`은 클릭을 막으면 안 됨

## Guardrails
- `attack_range` 변경 금지
- `move_range` 변경 금지
- `distance formula` 변경 금지
- 유닛 크기 / 배치 코드 덮어쓰기 금지
- 우클릭 이동 롤백 / 공격 취소 기능 유지
- `Attack Select Mode` 유지
