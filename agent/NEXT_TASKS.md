# NEXT TASKS

## Current Stable Baseline
v0.64y Ally Ready Frame + Unit Selection Close-up Panel Verified

Do not bump to `v0.65` yet.
Current work remains in the `v0.64` track.

## Priority 1
v0.64z Battle UX Polish / Round Toast Image Slot

Goal:
- Prepare a scene-authored `TextureRect` slot so the current center round text banner can later be replaced by an image banner.
- Current text banner behavior may remain as-is for now.
- Follow `Scene controls layout / Code controls behavior`.

## Priority 2
v0.65 candidate stabilization QA

Goal:
- Repeat 2v2 battle loop QA.
- Re-check death cleanup, round reset, right-click rollback, attack select cancel, and enemy AI alternation.
- If no major bugs remain, promote toward `v0.65 Godot Battle 2v2 MVP Stable` candidate later.

## Priority 3
Basic Battle FX

Goal:
- Movement indicator polish
- Attack indicator polish
- Hit spark / impact pop
- Damage number polish

Rule:
- Do this after battle loop stability remains solid.

## Priority 4
UnitVisual Template actual `tscn` split

Goal:
- Move from current scene template slot structure toward reusable visual templates later.
- Future expansion target: Infantry / Cavalry / Archer / Gunner.

## Priority 5
Additional troop classes

Goal:
- Lock infantry size as the baseline
- Archer close to infantry size
- Gunner close to infantry size
- Cavalry slightly larger than infantry

## Priority 6
Hero skills / skill range system

Goal:
- Extend the current `Basic Attack Select Mode` foundation into future skill range display and target selection.

## Ongoing Guardrails
- `attack_range` 변경 금지
- `move_range` 변경 금지
- `distance formula` 변경 금지
- 유닛 크기 / 배치 코드 덮어쓰기 금지
- `UnitCloseupPanel` 위치는 scene-authored 상태 유지
- `READY frame`은 클릭을 막으면 안 됨
- 우클릭 이동 롤백 / 공격 취소 기능 유지
- 전투 루프와 AI 순서 구조는 안정화 전까지 불필요하게 건드리지 말 것
