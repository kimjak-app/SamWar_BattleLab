# 옛 검증기 갱신 결과 (2026-10-23 밤샘 ③ 단계 ⑦)

- 지시문 `NIGHT3_STACK_20261023.md` §9. 근거 조사: `LEGACY_VALIDATORS_TRIAGE_20261022.md`(클코드, 기준 `8957b27`)
- 브랜치 `feature/legacy-validators-refresh-20261023` ← `origin/integration/p1-engine-core-20261019`(기준 `406bb73a024c3a0277ac8c06b891c30bc9e96e6b` 확인). 스택과 섞지 않았다.
- 커밋 1개 `test(tools): refresh nine legacy validators to the current references`. 작성자·커미터 `noreply@anthropic.com`. 푸시 안 함.
- **검증기만** 고쳤다(`tools/validate_*.py` 9개). 제품 코드·게임 데이터·CI 목록은 바꾸지 않았다.
- 합격 판정은 하지 않는다(검수: 클코치).
- 멈춤 규칙에 걸리지 않았다.

## 1. 고친 검증기 (전 → 후)

"전"은 기준 `406bb73` 그대로, "후"는 이 커밋이다. Windows, Python 3.14, 인자 없이 기본 실행(`PYTHONUTF8` 없음).

| # (조사표) | 검증기 | 분류 | 전 | 후 | 고친 내용 | 근거 커밋 |
|---|---|---|---|---|---|---|
| 1 | `validate_five_unit_type_action_eligibility` | A 위치 이동 | 실패: `moved_distance` 없음 | **통과** | 공유 계약 토큰을 컨트롤러 + `battle_ally_move_state_service.gd` + `battle_attack_state_service.gd`에서 찾음 | `aa0d667`(S1-2), `f934f31`(S2-2) |
| 3 | `validate_gunner_runtime_and_ai` | A 위치 이동 | 실패: `prepared_fire_bonus`, `armor_ignore_ratio` 없음 | **통과** | 런타임 토큰을 컨트롤러 + `battle_damage_formula_service.gd`에서 찾음 | `edfc67e`(B1d) |
| 8 | `validate_imjin_demo_test2` | A 위치 이동 | 실패: Test2 `extends` 줄 | **통과** | 한 줄 비교 대신 `extends "res://…"` 사슬을 따라가 제품 컨트롤러가 들어 있는지 확인(Test2 → `battle_controller.gd` → `battle_web_import_test.gd`) | `0826ac2` |
| 2 | `validate_five_unit_type_full_completion` | B 장수 | 실패: 프로필 39 기대 | **통과** | 프로필 수 = `hero_base_stats.json`의 장수 수(데이터에서 읽음) | `a006074`, `315c31b` |
| 4 | `validate_hero_battle_profile_integration` | B 장수·비주얼 | 실패: 39×3, factory `visual_key = unit_type` | **통과** | 장수 수를 base stats에서 읽고 프로필·특기 수가 그와 같은지 확인. factory의 `visual_key`는 T07 비주얼 메타데이터에서 가져오는지 확인 | `a006074`/`315c31b`/`74f974e`, `d973b2d` |
| 6 | `validate_hero_five_unit_assignment` | B 장수 | 실패: `profile count=44` | **통과** | 개수는 base stats에서 읽음. 병종 분포는 데이터에서 따로 읽을 출처가 없어 새 값 `14/12/11/4/3`으로 갱신(39명 분포 `5f4e943` + 임진 5명 보병 3·기병 2 `315c31b`) | `5f4e943`, `315c31b` |
| 7 | `validate_hero_runtime_authority` | B 비주얼 | 실패: 재구성 시 `visual_key = unit_type` | **통과** | 컨텍스트 재구성의 `visual_key`가 `UnitTypeContractScript.get_visual_metadata(unit_type, nation)`에서 오는지 확인 | `d973b2d` |
| 11 | `validate_t06_t07_playable_transaction` | B 장수·밸런스 | 실패: 특기 39, 기세 분포, 라운드 획득 1 | **통과** | 특기 수 = base stats 장수 수(장수당 1개). 비용 분포는 출처가 없어 새 값 `1:1, 2:9, 3:23, 4:11`(임진 5개 모두 비용 3, `74f974e`). 라운드 획득은 상수 자신 말고 읽을 곳이 없어 새 값 2로 갱신 | `74f974e`, `414a2ea` |
| 10 | `validate_samwar_audio_settings` | C' 검증기 결함 | 실패: `UnicodeDecodeError: 'cp949'` | **통과** | `read_text()` 6곳에 `encoding="utf-8"` | — |

## 2. 건드리지 않은 것 (지시대로)

| 검증기 | 지금 결과 | 이유 |
|---|---|---|
| `validate_hero_design_registry`(조사표 5) | 실패(그대로) | 병종·기세 비용 분포 김작 확인 대기 |
| `validate_korea_mvp_video_cutin_routing`(9) | 실패(그대로) | 컷인 오탐. `unique_skill_ready_icon.png` 의도 김작 결정 대기 |
| T08 HUD 고정 7개(12~18) | 실패(그대로) | 폐기 여부 클코치 확인 대기 |

- CI 목록(`verify-c-track.yml`)에는 아무것도 넣지 않았다(지시: 클코치가 정함).

## 3. 전체 실행 (새로 돌린 것)

- 이 브랜치에서 `tools/validate_*.py` **81개** 전부를 실행했다(조사 때 79개 + 그 뒤 통합 브랜치에 들어온 검증기 2개). 원문: zip `evidence/after/`, `evidence/after_results.txt`
- 실패는 **9개**이고, 모두 §2의 건드리지 않은 것이다(`hero_design_registry`, `korea_mvp_video_cutin_routing`, T08 7개). 그 밖에는 모두 exit 0이다.
- 조사표 18개 중 9개가 통과로 바뀌었다. 9개는 그대로 실패다(§2).

## 4. 결정 사항

| 항목 | 결정 | 이유 |
|---|---|---|
| "폐기된 규칙 — 장수·밸런스·비주얼(6개)" | 조사표 2·4·6·7·11 다섯 개를 고침 | 조사표의 B(T08 제외)는 2·4·5·6·7·11 여섯 개인데, 지시가 5(`hero_design_registry`)를 따로 제외했다. 그래서 5개다 |
| 숫자를 데이터에서 읽기 | 장수·프로필·특기 **개수**는 `hero_base_stats.json`에서 읽음 | 장수 명단이 기준 데이터다. 프로필·특기는 장수마다 1개라는 규칙으로 비교한다 |
| 분포(병종·기세 비용) | 새 값으로 갱신하고 커밋 근거를 주석에 적음 | 같은 데이터에서 분포를 읽으면 검사가 항상 통과해 의미가 없다. 독립 출처가 없다 |
| 라운드 기세 획득 | 2로 갱신(`414a2ea`) | 엔진 상수 자신이 출처라 "데이터에서 읽기"가 불가능하다. 지시대로 현재 엔진을 맞다고 봄 |
| 작업 위치 | 별도 git 워크트리(스크래치) | 스택 작업 트리에서 전체 CI가 돌고 있어 브랜치를 바꿀 수 없었다. 스택 브랜치는 건드리지 않았다 |
| 변조 프로브 | 하지 않음 | §9에 요구가 없다. 고친 검사가 실제 값을 보는지는 전/후 결과와 메시지로 확인했다(예: `44 profiles 14/12/11/4/3`) |
