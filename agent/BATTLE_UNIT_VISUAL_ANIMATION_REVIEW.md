# Battle Unit Visual / Animation Pure Helper Review

## 1. Baseline

- Version: `v0.72-12 Battle Unit Visual / Animation Pure Helper Review`
- Repository: `kimjak-app/SamWar_BattleLab`
- Branch: `main`
- Baseline commit: `b98feae778c36dc960ed6dfb3a2883135e167a95`
- Target: `scripts/battle_web_import_test.gd`

## 2. Search Method

- Reviewed the Unit Visual / Animation, Portrait, Token, Facing Indicator, and directly connected Stage B function-map entries.
- Searched the requested visual, animation, texture, portrait, token, scale, offset, alpha, duration, flip, color, display-key, and facing-visual patterns.
- Read each candidate implementation and all direct callers, checking constants/members, Node/resource/texture/state/registry access, collection mutation, animation/Tween execution, layout application, and formula/AI/WorldMap coupling.

## 3. Candidate Table

| Function | Current line | Direct callers | Inputs -> return | Member / Node / resource / state access | Mutation / animation / layout coupling | Example | Group | Decision |
|---|---:|---|---|---|---|---|---|---|
| `_get_default_visual_key_for_worldmap_hero` | 1832 | WorldMap context path | `Dictionary` -> `String` | WorldMap payload | WorldMap visual preparation | `korea_archer` | Runtime/state | Rejected — WorldMap boundary |
| `_get_status_display_color*` | 3607 / 3625 | status UI | status/entry -> `Color` | status display chain | UI consumer | status color | Pure metadata | Deferred — belongs to prior UI formatter boundary |
| `_get_unique_skill_cutin_texture` and texture helpers | 4656 onward | cutin flow | state/data -> `Texture2D` | `BattleUnitState`, cache, resource loading | cutin/resource | texture | Resource/texture | Rejected — resource/state/cutin |
| formation-guide / troop-icon / visual-key helpers | 6276–6400 | guide and unit UI | mixed -> strings/textures | state, token paths, texture loads | visual/UI | icon/key | Resource/registry | Rejected — runtime/resource coupling |
| visual-slot/root/token/portrait/base-scale helpers | 6404–6554, 7372–8450 | visual update | state -> Node/Dictionary/vector | visual registry and Nodes | actual visual application | visual slot | Node application | Rejected — Node/registry/state |
| `_get_move_dust_base_scale`, duration, range scale helpers | 9542–10272 | effect/overlay | Node/int -> vector/float | Sprite or effect constants | effect/overlay execution | scale/duration | Tween/animation | Rejected — visual-effect boundary |
| scene visual anchor/marker helpers | 10795–10949 | deployment/layout | positions/Node -> vectors/Nodes | Node/marker access | actual layout | anchor | Node application | Rejected — Node/layout |
| `_capture_portrait_template_offsets` | 10978 | template setup | Node2D/vectors -> `Dictionary` | Node template capture | layout capture | offset map | Portrait layout | Rejected — Node access |
| `_get_portrait_template_offset` | 11007 | `8785`, `8801`, `11018`, `11025` / 4 | Dictionary, vector, facing -> `Vector2` | read-only Dictionary only | none | selected offset/fallback | Pure visual metadata | Selected |
| `_get_ally_portrait_offset_for_facing` | 11014 | `11462`, `11502` / 2 | Dictionary, vector, facing -> `Vector2` | read-only Dictionary only | none | vertical fallback | Pure visual metadata | Selected |
| `_get_enemy_portrait_offset_for_facing` | 11021 | `11482`, `11522` / 2 | Dictionary, vector, facing -> `Vector2` | read-only Dictionary only | none | vertical fallback | Pure visual metadata | Selected |
| visual template/key/token paths/textures | 11052–11172 | visual update | state -> Node/key/path/texture | state, registry, resource | actual visual selection | texture | Resource/registry | Rejected — state/resource/Node |
| portrait markers/anchors/group positions | 11400–11718 | portrait layout | state/marker -> vectors | Node/state | layout application | anchor/offset | Portrait layout | Deferred — requires layout-application boundary |
| visual group/facing indicator helpers | 12920–13134 | UI update | state -> Node/vector | Node/state registry | visible/position changes | indicator | Node application | Rejected — Node mutation |
| `_is_token_flip_h_for_facing` | 14529 | `_apply_token_facing_visual` / 1 | facing, side -> `bool` | only facing normalization | consumed only by token Node application | `right -> true` | Token layout | Deferred — a one-caller bool does not make an independent boundary |
| `_get_default_token_texture_for_facing` | 14548 | token visual | facing, side -> `Texture2D` | texture members | texture return/application | texture | Resource/texture | Rejected — texture members |
| `_get_facing_aware_portrait_offset` | 14565 | template/portrait lookup callers / 3 | vector, facing -> `Vector2` | no member/Node/resource/state access | none | `(8,0), left -> (-8,0)` | Pure visual metadata | Selected |

## 4. Dependency Groups

- **Pure Visual Metadata Group:** portrait offset lookup and facing-aware offset calculation. This is the selected four-function group.
- **Node Application Group:** visual roots, slots, markers, indicators, and visual updates. Locked because it reads/mutates Nodes.
- **Resource / Texture Group:** texture lookup/load/cache and `Texture2D` returns. Locked because resource or runtime texture ownership is involved.
- **Tween / Animation Execution Group:** cutins, dust, effect duration/scale, overlays, hit feedback, and animation execution. Locked because effects are runtime visual behavior.
- **Portrait / Token Layout Group:** template capture, markers, anchors, and group positions. Deferred/rejected where Node layout ownership is involved.
- **Runtime State / Registry Group:** any `BattleUnitState`, visual slot registry, hero/unit registry, or deployed-state dependent helper. Locked.

## 5. Selected Extraction

- Added `scripts/battle/helpers/battle_unit_visual_helper.gd` with `class_name BattleUnitVisualHelper` and static functions.
- Extracted `_get_portrait_template_offset`, `_get_ally_portrait_offset_for_facing`, `_get_enemy_portrait_offset_for_facing`, and `_get_facing_aware_portrait_offset`.
- Existing wrappers retain signatures and all callers remain unchanged.
- The wrapper passes existing facing constants into the helper; no battle-main constant is duplicated. Input Dictionaries remain read-only, vertical fallback remains unchanged, and the helper returns the original `Vector2` values.

## 6. Rejected Candidates

- Node/visual slot/indicator, texture/resource, cutin/effect/Tween, state/registry, and WorldMap-linked candidates are rejected because they are not input-only pure computations.

## 7. Deferred Candidates

- `_is_token_flip_h_for_facing`: pure but has only the token application caller, so extracting it alone does not improve the boundary.
- Portrait marker/anchor/group-position functions: some return vectors, but their Node layout ownership should remain a dedicated future boundary.

## 8. Changed Files

- Added `scripts/battle/helpers/battle_unit_visual_helper.gd` and generated `.uid` companion.
- Modified `scripts/battle_web_import_test.gd` only for one preload and four preserved wrapper delegations.
- Added this review record and updated `agent/NEXT_TASKS.md`.

## 9. Validation

- Baseline HEAD and clean worktree verified before modification.
- Godot editor/project parse passed.
- `Battle_Land.tscn` headless load passed.
- `BattleUnitVisualHelper` class/preload registration passed.
- Wrapper signatures, callers, facing fallbacks, Dictionary lookup behavior, and `Vector2` output expressions were preserved by source review.
- No Node, position/scale/rotation/modulate, resource/texture load, Tween/animation, portrait/token application, runtime registry/state, grid/formation, formula/AI, WorldMap/result/transition, or protected-file diff was introduced.

## 10. Rollback

- Remove the helper and generated `.uid` companion.
- Remove its preload and restore the four original wrapper bodies in `scripts/battle_web_import_test.gd`.
- Revert this review record and `NEXT_TASKS.md` entry.

## 11. Manual QA

- QA basis: Human gameplay QA performed in Godot editor.
- QA baseline commit: `3c243ef38cfd95ab13e20bf292ac8f497db6a89e`.
- Human gameplay QA: `PASS`.
- Ally portrait position: `PASS`.
- Enemy portrait position: `PASS`.
- Left facing portrait offset: `PASS`.
- Right facing portrait offset: `PASS`.
- Up facing fallback position: `PASS`.
- Down facing fallback position: `PASS`.
- Portrait position after movement: `PASS`.
- Portrait position before/after attack: `PASS`.
- Portrait position before/after skill: `PASS`.
- Enemy reinforcement portrait position: `PASS`.
- Battle → WorldMap return: `PASS`.
- 신규 extraction 회귀: 없음.
- 향후 detail 개선은 가능하지만 이번 helper extraction의 blocker나 회귀가 아니며 별도 작업 범위다.

## 12. Next Recommended Task

- Function map과 최근 review 문서를 재검토하여 남은 Stage B 순수 helper 경계를 선정한다. 안전한 경계가 없으면 `v0.72-14 Battle Stage B Remaining Pure Helper Audit`으로 진행한다.

## Complete Lock

- `v0.72-12 Battle Unit Visual Animation Pure Helper Extraction`은 parse/headless 검증과 Human gameplay QA를 통과했다.
- portrait offset Dictionary lookup, facing fallback 및 `Vector2` 결과는 기존 동작을 유지한다.
- 좌우 facing offset과 상하 fallback 위치가 정상 동작한다.
- Node application, texture/resource, Tween/animation, portrait/token actual layout, runtime registry/state, grid/formation, formula/AI, WorldMap handoff, battle result 및 scene transition에는 변경이 없다.
- `v0.72-12`는 최종 완료 및 잠금 상태다.

## Known Technical Debt

- `BattleUnitVisualHelper` 내부의 private facing normalization은 `BattleFormationFacingHelper.normalize_facing()`과 동일한 결과와 fallback을 별도로 보유한다.
- Status: `RESOLVED in v0.72-14`.
- Resolution: `BattleUnitVisualHelper`의 private normalizer를 제거하고 `BattleFormationFacingHelper.normalize_facing()`을 단방향으로 재사용했다. 순환 참조는 없다.
- Verification: parse/headless `PASS`, Human gameplay QA `PASS`.
- 해당 technical debt는 더 이상 open 상태가 아니다.
