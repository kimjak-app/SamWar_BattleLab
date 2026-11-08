기준 화면: 새 가지 `feature/wm3d-debugcheats-20261108`(시작: `origin/main` `a9e3b84229f63286bbdc784d78826b0e2cdb792d`)에서 F6로 `WorldMap.tscn`을 열고(디버그 빌드), 키 3개로 ① 금·자원 전부 채움 ② 선택한 테크 즉시 완료 ③ 첩보 없이 적 성 정보 전부 표시가 된다. 출시(비디버그) 빌드에서는 키가 아무 일도 하지 않는다.
합격 기준: 6절 자동 기준 전부 + 세이브 형식 변화 0 + C-track 4 shard·`Verify WorldMap3D` 초록. 최종 합격은 김작 F6(7절 체크리스트). **이번에는 코드 변경 0으로 멈춘다.**

# REPORT_DEBUG_CHEATS_STOP — `worldmap_main.gd`는 바이트 단위로 고정돼 있어 "생성 연결 몇 줄"도 CI 검증기 1개를 깨뜨림 (클코드, 2026-11-08, 큐 30번)

- **됐나**: 안 됐다. 코드 커밋 0, 이 보고서만 올렸다.
- **가지**: `feature/wm3d-debugcheats-20261108` = `origin/main` `a9e3b84` + 이 보고서 커밋 1개(`[skip ci]`). `main` 푸시 없음.
- **막힌 것**: 큐 4절 3번(허용 목록 밖을 고쳐야 함)·4번(지시서 [사실]과 실제 코드가 다름). 지시서 1절은 "`validate_worldmap_main_integrity.py`는 줄 수·함수 수 **하한**만 본다"고 적었지만, 그와 별개로 `worldmap_main.gd` **전체를 한 커밋과 바이트 단위로 비교하는** 검증기가 CI에서 돈다.

## 1. 부딪치는 검사 [사실]
- `tools/validate_worldmap_diplomacy_routing.py` 146행 → `tools/p1_exact_delta.py`의 `assert_main_is_approved_p1_state`:
```
assert current_main == p1_main, (
    "worldmap_main.gd changed after the approved P-1 checkpoint; review a new exact delta "
    "instead of relaxing the guard"
)
```
- `p1_main` = `P1_MAIN_CHECKPOINT` `9b2cd8ee6d5ab2aac1071af8e43ed5f7360bde2d`(P-1D 핫픽스) 시점의 `worldmap_main.gd`. 현재 `main` `a9e3b84`의 파일은 이것과 **똑같다**(`git diff --stat 9b2cd8e a9e3b84 -- scripts/worldmap/worldmap_main.gd` 출력 없음, 마지막 수정 커밋 = `9b2cd8e`).
- 이 검증기는 `.github/workflows/verify-c-track.yml` 86행에서 돈다.
- 시험(코드는 곧바로 원복, 커밋 없음): `worldmap_main.gd` 끝에 빈 함수 3줄(`func _ensure_debug_cheats_controller() -> void: pass`)만 붙이고 실행 →
  - 붙이기 전 `python tools/validate_worldmap_diplomacy_routing.py` = 종료 코드 0
  - 붙인 뒤 = `AssertionError: worldmap_main.gd changed after the approved P-1 checkpoint; review a new exact delta instead of relaxing the guard`
  - 같은 모듈을 쓰는 `validate_worldmap_player_attack_deployment_service_extraction.py`, `validate_worldmap_t03_battle_presentation_extraction.py`는 붙인 뒤에도 0(정산 파일 검사만 씀).
- 결론: 지시서 0절 2항("`_ensure_*` 패턴으로 생성 연결 몇 줄")은 **어떤 줄 수로도** 이 검사를 통과할 수 없다. 통과하려면 `tools/p1_exact_delta.py`(고정 커밋·기대 delta)를 고쳐야 하는데, 이 파일은 허용 목록에 없고 파일 자체가 "검사를 풀지 말고 새 delta를 검토하라"고 적고 있다.

## 2. 지시서 2절 [미확인] 4건 — 멈추기 전에 읽기로 확인한 것
1. **키 충돌** [사실]: `scripts/worldmap/` 안의 키 사용은 카메라 W/A/S/D·방향키(2D), W/A/S/D/Q/E(3D), Space/Enter/Esc(전투 진입 건너뛰기·연출 카드·턴 요약), `ui_cancel`/`ui_accept`뿐이다. `KEY_G`·`KEY_T`·`KEY_I`는 0건(`scripts/battle3d/`의 실험실 장면에만 있음, 월드맵과 무관). `shared_ui_controller.handle_input`은 마우스(드래그)만 본다. `project.godot`에 `[input]` 절 없음. → 권장 후보 **Ctrl+Shift+G / T / I** 그대로 쓸 수 있다.
2. **테크트리가 열린 상태의 키 입력** [추정, Godot 4 입력 순서 기준]: main의 `_unhandled_input`은 테크트리가 열려 있으면 모든 입력을 먹는다(1119~1121행). Godot 4 순서는 `_input` → GUI → `_shortcut_input` → `_unhandled_key_input` → `_unhandled_input`이라, 자식 노드의 `_unhandled_key_input`은 main의 `_unhandled_input`보다 **먼저** 받는다. 구현 때 테스트(뷰포트 `push_input`)로 확인할 예정.
3. **테크 전체 목록의 공개 수단** [사실]: `domestic_tech_catalog.gd`의 `get_definitions()`(184행, 도시+나라 합침), `get_city_definitions()`, `get_national_definitions()`, `get_definition(tech_id)`. main의 `_ensure_domestic_tech_catalog()`로 얻는다. 선택된 테크는 트리 컨트롤러의 공개 함수 `get_selection()`(186행, `{tech_id, city_id}`).
4. **턴 진행 중 용량으로 깎이는지** [사실, 정적 확인]: `WAREHOUSE_CAPACITY`를 읽는 곳은 main의 HUD 문구 함수 2곳(`_build_warehouse_hud_rows`, `_format_warehouse_summary`)뿐. `scripts/worldmap/turn`·`economy_city`·`orchestration`에 `capacity` 단어 0건. → 깎는 코드 없음.

## 3. 그 밖에 미리 확인한 것 (재개하면 쓸 내용) [사실]
- 치트 ① 쓰기 수단: 도시 `resource_stock`은 `_wounded_recovery_mutation("set_city_resource_amount", [city_id, resource_id, amount])`(main 2013행), 도시 `storage`는 `_set_city_storage(city_id, storage)`(3759행), 재집계 `_rebuild_occupation_runtime_indexes_mvp()`(7191행), 소유 도시 `_get_national_payment_city_ids_mvp()`(7842행). 화면 갱신은 `_refresh_left_world_status_panel()` + (내 도시 선택 시) `_refresh_unified_panel_content()`.
- 치트 ② 완료 수단: 연구 서비스 `mark_completed_from_normalize(scope, city_id, tech_id)` + 도시면 `sync_city_completed_mirror(city_id)` — 진행 중 연구 슬롯을 건드리지 않는다(`complete_*_research`는 슬롯을 비움). 화면 갱신은 정상 턴 완료(`_advance_domestic_tech_research_for_world_turn_mvp`, 9729행)와 같은 `_refresh_domestic_tech_tree_overlay_mvp()` → `_refresh_domestic_tech_effect_display_surfaces_mvp({"completed": [...]})` → `_refresh_worldmap_tech_badge_summary_if_present()`.
- 치트 ③ 실제 값: `_ensure_spy_controller()`는 `RefCounted`이고 `get("_service")`로 `SpyActionService`를 얻을 수 있다. **단** `_build_spy_info_payload`는 서비스의 `_adapter`(스파이 컨트롤러)를 쓰는데, 이 값은 서비스의 공개 함수가 한 번이라도 불려야 채워진다(38·64·84·97… 행에서 `_adapter = adapter`). 새 게임 직후에는 비어 있을 수 있어, 부르기 전에 `service.set("_adapter", spy_controller)`(공개 함수들이 매번 넣는 것과 같은 값)를 해야 한다. 스파이 파일 수정은 필요 없다.

## 4. 클코치에게 필요한 판단
- **A (클코드 권장)**: `worldmap_main.gd` 수정 0줄. CH-2b·CH-2c와 같은 방식으로 컨트롤러를 `WorldMap.tscn` 루트 자식 노드 1개로 붙인다(허용 목록에 `WorldMap.tscn` 노드 1개 추가). 컨트롤러는 `_ready`에서 `OS.is_debug_build()`가 false면 **즉시 `queue_free()`** 하고 아무것도 하지 않는다(main에 meta도 안 남김). "생성되지 않는다"는 "출시 빌드에서는 첫 프레임 전에 스스로 사라진다"로 읽는다. 테스트는 활성 여부 주입 함수로 비활성 경로를 검증.
- **B**: 지시서대로 main에 연결 몇 줄 + `tools/p1_exact_delta.py`의 `P1_MAIN_CHECKPOINT`를 새 커밋으로 옮기고 그 사이의 정확한 delta를 새 상수로 고정(검사를 풀지 않고 재고정). 허용 목록에 `tools/p1_exact_delta.py` 추가 필요. main을 건드리는 첫 사례라 클코드는 권하지 않는다.
- **C**: 다른 생성 경로를 지시.
- 함께 확인 바람: 3절 마지막 항목(`service.set("_adapter", spy_controller)` 한 줄로 실제 값을 만드는 것)을 지시서 5절의 "`_service.call(...)` 경로"로 인정하는지.

## 종료 루틴
1. 정본 작업 폴더 `C:\dev\SamWar_BattleLab_cc`: 가지 `feature/wm3d-debugcheats-20261108`(코드는 `main` `a9e3b84`과 같음), `git status` 깨끗(시험 편집은 원복).
2. 새로 생긴 것: 가지 `feature/wm3d-debugcheats-20261108` 1개(이 보고서). 폴더·worktree·태그 0, 삭제 예정 0.
3. 푸시: 이 가지에 보고서 커밋 1개(`[skip ci]`)만. `main`·다른 가지 푸시 없음.
4. CI: 실행 0(코드 커밋 없음).
5. 김작/클코치 결정: 4절 A/B/C. 답신(`agent/ORDER_DEBUG_CHEATS_REPLY_1_20261108.md` 등)이 오면 이 가지에서 그대로 잇는다. 27번(CH-4)과는 독립이라 영향 없음.
