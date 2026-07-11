# Battle Engine Refactor Function Map

## Baseline
- Target file: `scripts/battle_web_import_test.gd`
- Line count: 14810
- Function count: 791
- Const count: 317
- @onready var count: 225
- Extends: `extends Node2D`
- Analysis type: static function inventory and heuristic first-pass risk classification.

## Methodology
- Stage A: Yes / low-risk extraction candidate. Pure or near-pure helper, no obvious node access, no contract mutation.
- Stage B: Sometimes / wrapper-required candidate. Reads battle data or constants and needs signature/return-shape review before extraction.
- Stage C: No / keep in main for now. Node/UI/animation/tween/state/AI/formula/flow coupled.
- Stage D: Do Not Move Yet / contract-locked. WorldMap handoff, battle result, scene transition, or meta payload ownership.
- Note: this map is intentionally conservative. Stage A still requires focused smoke/headless validation before code movement.

## Summary Counts
| Stage | Count | Meaning |
|---|---:|---|
| Stage A | 0 | Low-risk extraction candidate |
| Stage B | 145 | Wrapper-required / review |
| Stage C | 575 | Keep in battle main |
| Stage D | 71 | Contract-locked / do not move yet |

## Domain Counts
| Domain | Count | Stage A | Stage B | Stage C | Stage D |
|---|---:|---:|---:|---:|---:|
| Damage / Stat / Formula | 83 | 0 | 0 | 83 | 0 |
| Enemy AI | 130 | 0 | 0 | 130 | 0 |
| Formation / Facing | 96 | 0 | 51 | 45 | 0 |
| Mixed / Unsafe | 4 | 0 | 3 | 1 | 0 |
| Movement / Range / Path | 13 | 0 | 8 | 5 | 0 |
| Reinforcement | 44 | 0 | 19 | 25 | 0 |
| Selection / Interaction | 38 | 0 | 0 | 38 | 0 |
| Turn / Phase / Flow | 13 | 0 | 0 | 13 | 0 |
| UI / HUD / Text Formatter | 48 | 0 | 19 | 29 | 0 |
| Unique / Specialty Skill | 98 | 0 | 45 | 53 | 0 |
| Unit Visual / Animation | 153 | 0 | 0 | 153 | 0 |
| WorldMap Bridge / Handoff Contract | 71 | 0 | 0 | 0 | 71 |

## Naval Reuse Candidate Summary
| Domain | Function Count | Candidate Type | Notes |
|---|---:|---|---|
| Damage / Stat / Formula | 83 | REVIEW - Generic combat calculation candidate | Review before extraction; execution/visual/state functions remain locked. |
| Formation / Facing | 96 | YES - Formation reuse candidate | Review before extraction; execution/visual/state functions remain locked. |
| Reinforcement | 44 | YES - Reinforcement reuse candidate | Review before extraction; execution/visual/state functions remain locked. |
| UI / HUD / Text Formatter | 48 | YES - Formatter/lookup reuse candidate | Review before extraction; execution/visual/state functions remain locked. |
| Unique / Specialty Skill | 98 | REVIEW - Naval skill reuse candidate | Review before extraction; execution/visual/state functions remain locked. |

## Recommended First Extraction Batches
| Priority | Domain | Candidate Count | Why |
|---:|---|---:|---|
| 1 | Debug / Logging | 0 | Only if pure log/string helpers are selected; no gameplay behavior change; wrapper kept. |
| 2 | UI / HUD / Text Formatter | 0 | Extract pure label/summary/description builders only; no node mutation. |
| 3 | Data Lookup / Constants | 0 | Pure lookup/name/normalization helpers are low-risk when return shape is preserved. |
| 4 | Unique / Specialty Skill Metadata | 45 | Metadata/description helpers only; skill execution remains locked. |
| 5 | Formation / Facing Pure Review | 51 | Only node-free calculations; visual indicators remain locked. |

## Do Not Move Yet
- WorldMap handoff / context
- Battle result
- Scene transition
- Enemy AI execution
- Unit visual / animation
- HP bar / tween / effect
- Selection state
- Damage/stat formula unless pure and reviewed

## Deferred / Locked Domains for v0.72 Battle Refactor

The following domains should not be extracted opportunistically:

- WorldMap Bridge / Handoff Contract
- Battle Result / Defeat / Retreat
- Scene transition / lifecycle
- Enemy AI decision execution
- Unit Visual / Animation / Tween / Effect
- HP bar and runtime UI node updates
- Selection / Interaction state
- Damage / stat formula unless separately reviewed
- Mixed / Unsafe
- Unknown / Needs Review

## Recommended Next Steps

1. `v0.72-05 Battle Debug / Logging Helper Extraction`
   - Only if Stage A debug/log formatter candidates exist.
   - No gameplay behavior change.
   - Wrapper kept.

2. `v0.72-06 Battle UI Text / Formatter Helper Extraction`
   - Only pure formatter / label helpers.
   - No node mutation.

3. `v0.72-07 Battle Skill Metadata / Description Helper Extraction`
   - Only pure skill metadata/description lookup.
   - Unique/specialty skill execution remains locked.

4. `v0.72-08 Battle Formation / Facing Pure Helper Review`
   - Only node-free calculations.
   - Visual indicator functions remain locked.

5. Dedicated contract task before touching:
   - `worldmap_context_*`
   - `battle_result_*`
   - `defeat_retreat_*`

## Full Function Map
| # | Function | Line | Estimated End Line | Domain | Stage | Reason | Reuse Candidate | Move Recommendation |
|---:|---|---:|---:|---|---|---|---|---|
| 1 | `_ready` |  1334 | 1449 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 2 | `_read_worldmap_battle_context_handoff` |  1450 | 1470 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 3 | `_apply_worldmap_battle_context_handoff` |  1471 | 1495 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 4 | `_setup_worldmap_context_battle_roster` |  1496 | 1546 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 5 | `_is_worldmap_player_attack_context` |  1547 | 1552 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 6 | `_apply_worldmap_context_side_roster` |  1553 | 1640 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 7 | `_deactivate_worldmap_context_slot` |  1641 | 1663 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 8 | `_get_context_hero_ids_for_side` |  1664 | 1680 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 9 | `_is_worldmap_invasion_context_for_roster` |  1681 | 1689 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 10 | `_allows_sample_roster_crash_guard` |  1690 | 1695 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 11 | `_register_worldmap_context_hero_contracts` |  1696 | 1724 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 12 | `_build_worldmap_context_hero_registry_entry` |  1725 | 1746 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 13 | `_build_worldmap_context_unique_skill_entry` |  1747 | 1772 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 14 | `_get_sample_unique_skill_entry_for_worldmap_hero` |  1773 | 1782 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 15 | `_resolve_worldmap_context_skill_name` |  1783 | 1795 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 16 | `_get_existing_resource_path` |  1796 | 1803 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 17 | `_resolve_hero_portrait_path` |  1804 | 1813 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 18 | `_resolve_hero_portrait_texture` |  1814 | 1817 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 19 | `_apply_battle_portrait_texture_to_sprite` |  1818 | 1827 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 20 | `_get_default_visual_key_for_worldmap_hero` |  1828 | 1848 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 21 | `_get_target_mode_for_worldmap_skill_effect` |  1849 | 1858 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 22 | `_append_unique_context_hero_id` |  1859 | 1867 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 23 | `_resolve_worldmap_context_hero_id` |  1868 | 1880 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 24 | `_apply_worldmap_context_hero_to_unit_state` |  1881 | 1890 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 25 | `_process` |  1891 | 1900 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 26 | `_get_main_camera_or_null` |  1901 | 1906 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 27 | `_configure_main_camera` |  1907 | 1919 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 28 | `_reset_main_camera_to_scene_position` |  1920 | 1935 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 29 | `_is_battle_intro_camera_playing` |  1936 | 1939 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 30 | `_capture_battle_gameplay_camera_state` |  1940 | 1950 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 31 | `_apply_battle_gameplay_camera_state` |  1951 | 1966 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 32 | `_set_battle_intro_ui_visible` |  1967 | 1976 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 33 | `_get_battle_intro_wide_camera_state` |  1977 | 1995 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 34 | `_play_battle_intro_camera_zoom` |  1996 | 2035 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 35 | `_finish_battle_intro_camera_zoom` |  2036 | 2039 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 36 | `_skip_battle_intro_camera_zoom` |  2040 | 2043 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 37 | `_complete_battle_intro_camera_zoom` |  2044 | 2056 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 38 | `_is_battle_intro_skip_input` |  2057 | 2076 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 39 | `_focus_camera_on_world_position` |  2077 | 2101 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 40 | `_focus_camera_on_unit` |  2102 | 2107 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 41 | `_focus_camera_on_combat_pair` |  2108 | 2121 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 42 | `_get_camera_focus_position_for_unit` |  2122 | 2132 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 43 | `_clamp_camera_position_to_battlefield` |  2133 | 2152 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 44 | `_get_battlefield_visual_world_rect` |  2153 | 2169 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 45 | `_clamp_camera_position_to_world_rect` |  2170 | 2194 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 46 | `_set_camera_focus_base_position` |  2195 | 2201 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 47 | `_set_main_camera_position_for_focus` |  2202 | 2209 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 48 | `_refresh_camera_bound_world_overlays` |  2210 | 2218 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 49 | `_input` |  2219 | 2328 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 50 | `_unhandled_input` |  2329 | 2340 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 51 | `show_cutin` |  2341 | 2346 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 52 | `hide_cutin` |  2347 | 2350 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 53 | `show_result` |  2351 | 2365 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 54 | `hide_result` |  2366 | 2370 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 55 | `_configure_battle_result_video` |  2371 | 2380 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 56 | `_get_battle_result_video_panel_rect` |  2381 | 2394 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 57 | `_prepare_battle_result_video_panel` |  2395 | 2408 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 58 | `_get_battle_result_video_path` |  2409 | 2416 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 59 | `_assign_battle_result_video_stream` |  2417 | 2444 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 60 | `_create_battle_result_theora_stream_direct` |  2445 | 2456 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 61 | `_play_battle_result_video_before_toast` |  2457 | 2486 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 62 | `_on_battle_result_video_finished` |  2487 | 2490 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 63 | `_on_battle_result_video_fallback_timeout` |  2491 | 2496 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 64 | `_complete_battle_result_video_before_toast` |  2497 | 2509 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 65 | `_hide_battle_result_video_overlay` |  2510 | 2528 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 66 | `_show_battle_result_toast_after_video` |  2529 | 2534 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 67 | `_configure_worldmap_result_return_button` |  2535 | 2556 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 68 | `_refresh_worldmap_result_return_button` |  2557 | 2569 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 69 | `_has_worldmap_battle_context` |  2570 | 2573 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 70 | `_on_worldmap_result_return_pressed` |  2574 | 2577 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 71 | `_return_to_worldmap_with_result` |  2578 | 2601 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 72 | `_build_worldmap_battle_result_payload` |  2602 | 2662 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 73 | `_sum_alive_deployed_troops_for_side` |  2663 | 2669 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 74 | `_calculate_unit_surviving_allocated_troops` |  2670 | 2685 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 75 | `_calculate_player_attack_troop_outcome_from_units` |  2686 | 2722 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 76 | `reset_demo_state` |  2723 | 2866 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 77 | `play_basic_move_demo` |  2867 | 2944 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 78 | `_finish_basic_move_demo` |  2945 | 2970 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 79 | `try_basic_attack` |  2971 | 2987 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 80 | `_enter_attack_select_mode` |  2988 | 3002 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 81 | `_exit_attack_select_mode` |  3003 | 3006 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 82 | `_is_enemy_target_in_active_attack_range` |  3007 | 3010 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 83 | `_try_attack_enemy_target_from_attack_select` |  3011 | 3041 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 84 | `play_basic_attack_demo` |  3042 | 3114 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 85 | `_sync_demo_positions` |  3115 | 3118 | Mixed / Unsafe | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 86 | `_reset_unit_group_positions` |  3119 | 3125 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 87 | `_finish_basic_attack_demo` |  3126 | 3152 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 88 | `_get_unique_skill_for_unit` |  3153 | 3163 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 89 | `_can_use_unique_skill` |  3164 | 3188 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 90 | `_can_actor_use_unique_skill` |  3189 | 3213 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 91 | `_on_unique_skill_button_pressed` |  3214 | 3226 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 92 | `_enter_unique_skill_target_select_mode` |  3227 | 3249 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 93 | `_should_unique_skill_resolve_without_manual_target` |  3250 | 3253 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 94 | `_begin_manual_unique_skill_preview` |  3254 | 3267 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 95 | `_finish_manual_unique_skill_preview` |  3268 | 3293 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 96 | `_cancel_unique_skill_target_select_mode` |  3294 | 3308 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 97 | `_clear_unique_skill_targeting_state` |  3309 | 3313 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 98 | `_on_strategy_button_pressed` |  3314 | 3326 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 99 | `_enter_strategy_target_select_mode` |  3327 | 3347 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 100 | `_cancel_strategy_target_select_mode` |  3348 | 3360 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 101 | `_clear_strategy_targeting_state` |  3361 | 3364 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 102 | `_can_use_strategy` |  3365 | 3384 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 103 | `_get_strategy_range` |  3385 | 3396 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 104 | `_get_strategy_tier` |  3397 | 3408 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 105 | `_get_strategy_outcome_pool` |  3409 | 3422 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 106 | `_get_strategy_targets` |  3423 | 3435 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 107 | `_get_strategy_success_rate` |  3436 | 3442 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 108 | `_roll_strategy_outcome` |  3443 | 3449 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 109 | `_is_valid_strategy_target` |  3450 | 3455 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 110 | `_get_strategy_clicked_target_at_position` |  3456 | 3464 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 111 | `_try_use_strategy_on_target` |  3465 | 3477 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 112 | `_resolve_strategy` |  3478 | 3517 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 113 | `_get_strategy_status_display_name` |  3518 | 3527 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 114 | `_is_unit_confused` |  3528 | 3531 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 115 | `_get_unit_status_display_entries` |  3532 | 3572 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 116 | `_get_unit_status_badge_text` |  3573 | 3583 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 117 | `_get_unit_status_summary_text` |  3584 | 3594 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 118 | `_get_unit_status_summary_text_compact` |  3595 | 3608 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 119 | `_get_status_display_color` |  3609 | 3626 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 120 | `_get_status_display_color_for_entry` |  3627 | 3630 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 121 | `_get_unit_status_summary_color` |  3631 | 3636 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 122 | `_get_strategy_status_icon_text` |  3637 | 3640 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 123 | `_get_strategy_status_summary_text` |  3641 | 3644 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 124 | `_get_formation_status_summary_text` |  3645 | 3648 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 125 | `_has_strategy_status_effect` |  3649 | 3652 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 126 | `_consume_strategy_status_after_unit_action` |  3653 | 3662 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 127 | `_refresh_strategy_status_icon_labels` |  3663 | 3687 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 128 | `_create_strategy_status_icon_label` |  3688 | 3696 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 129 | `_sync_strategy_status_icon_label_children` |  3697 | 3726 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 130 | `_get_strategy_status_badge_position_for_unit` |  3727 | 3753 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 131 | `_get_facing_indicator_world_position_for_unit` |  3754 | 3760 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 132 | `_remove_strategy_status_icon_label` |  3761 | 3767 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 133 | `_clear_strategy_status_icon_labels` |  3768 | 3773 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 134 | `_consume_confused_ally_turn_if_needed` |  3774 | 3800 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 135 | `_get_unique_skill_range` |  3801 | 3828 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 136 | `_get_unique_skill_range_cells` |  3829 | 3839 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 137 | `_get_unique_skill_valid_targets` |  3840 | 3856 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 138 | `_is_valid_unique_skill_target` |  3857 | 3862 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 139 | `_has_valid_unique_skill_action` |  3863 | 3868 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 140 | `_get_best_unique_skill_target_for_actor` |  3869 | 3885 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 141 | `_get_best_unique_skill_aoe_target` |  3886 | 3899 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 142 | `_get_best_unique_skill_single_target` |  3900 | 3923 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 143 | `_count_adjacent_unique_skill_splash_targets` |  3924 | 3935 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 144 | `_get_unique_skill_aoe_hit_count` |  3936 | 3941 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 145 | `_get_unique_skill_cannon_aoe_targets` |  3942 | 3949 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 146 | `_get_unique_skill_buff_candidate_count_for_actor` |  3950 | 3957 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 147 | `_is_unique_skill_high_value_for_actor` |  3958 | 3990 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 148 | `_is_unique_skill_fallback_value_for_actor` |  3991 | 4007 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 149 | `_get_unique_skill_clicked_target_at_position` |  4008 | 4021 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 150 | `_try_use_unique_skill_on_target` |  4022 | 4041 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 151 | `_try_auto_unique_skill_for_actor` |  4042 | 4066 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 152 | `_begin_auto_unique_skill_preview` |  4067 | 4078 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 153 | `_finish_auto_unique_skill_preview` |  4079 | 4084 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 154 | `_begin_unique_skill_sequence` |  4085 | 4113 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 155 | `_show_specialty_skill_video_cutin` |  4114 | 4228 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 156 | `_get_specialty_skill_video_cutin_hero_id` |  4229 | 4237 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 157 | `_get_specialty_skill_cutin_config` |  4238 | 4241 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 158 | `_get_specialty_skill_cutin_config_float` |  4242 | 4245 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 159 | `_assign_specialty_skill_cutin_video_stream_for_hero` |  4246 | 4266 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 160 | `_assign_specialty_skill_cutin_video_stream` |  4267 | 4305 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 161 | `_log_specialty_skill_cutin_video_candidates` |  4306 | 4326 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 162 | `_get_specialty_skill_cutin_video_load_failure_guess` |  4327 | 4340 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 163 | `_create_specialty_skill_cutin_theora_stream_direct` |  4341 | 4369 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 164 | `_debug_object_has_property` |  4370 | 4379 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 165 | `_get_debug_object_class_name` |  4380 | 4385 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 166 | `_prepare_specialty_skill_cutin_video_node` |  4386 | 4410 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 167 | `_log_specialty_skill_cutin_video_player_state` |  4411 | 4443 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 168 | `_log_specialty_skill_cutin_draw_order` |  4444 | 4459 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 169 | `_get_debug_node_index` |  4460 | 4465 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 170 | `_get_debug_node_z_index` |  4466 | 4471 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 171 | `_log_specialty_skill_cutin_video_player_state_later` |  4472 | 4475 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 172 | `_log_specialty_skill_cutin_video_player_state_later_async` |  4476 | 4480 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 173 | `_debug_play_cutin_video_only` |  4481 | 4510 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 174 | `_focus_camera_for_unique_skill` |  4511 | 4520 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 175 | `_apply_unique_skill_effect_if_valid` |  4521 | 4530 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 176 | `_show_unique_skill_toast_over_unit` |  4531 | 4606 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 177 | `_get_unique_skill_cutin_slide_direction` |  4607 | 4612 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 178 | `_log_unique_skill_cutin_timing` |  4613 | 4625 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 179 | `_get_unique_skill_fullscreen_cutin_rect` |  4626 | 4636 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 180 | `_layout_unique_skill_fullscreen_cutin` |  4637 | 4652 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 181 | `_get_unique_skill_name_position` |  4653 | 4659 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 182 | `_get_unique_skill_cutin_texture` |  4660 | 4667 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 183 | `_load_unique_skill_texture` |  4668 | 4682 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 184 | `_apply_unique_skill_effect` |  4683 | 4702 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 185 | `_apply_unique_skill_cannon_aoe` |  4703 | 4724 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 186 | `_apply_unique_skill_ally_attack_buff` |  4725 | 4738 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 187 | `_apply_unique_skill_self_defense_single` |  4739 | 4760 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 188 | `_apply_unique_skill_single_damage_adjacent_shake` |  4761 | 4788 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 189 | `_find_unique_skill_enemy_target` |  4789 | 4804 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 190 | `_get_opposing_side` |  4805 | 4810 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 191 | `_get_side_display_name` |  4811 | 4816 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 192 | `_get_direction_from_positions` |  4817 | 4830 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 193 | `_get_opposite_facing` |  4831 | 4844 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 194 | `_get_attack_angle_type` |  4845 | 4856 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 195 | `_get_attack_angle_damage_multiplier` |  4857 | 4866 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 196 | `_get_directional_attack_damage` |  4867 | 4881 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 197 | `_show_defend_hit_reaction_if_needed` |  4882 | 4887 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 198 | `_append_attack_angle_log` |  4888 | 4894 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 199 | `_get_unique_skill_cooldown_key` |  4895 | 4898 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 200 | `_set_unique_skill_cooldown` |  4899 | 4905 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 201 | `_tick_unique_skill_cooldowns_for_side` |  4906 | 4918 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 202 | `_get_unique_skill_attack_buff_key` |  4919 | 4924 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 203 | `_has_active_unique_skill_attack_buff` |  4925 | 4931 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 204 | `_get_unique_skill_attack_buff_bonus` |  4932 | 4940 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 205 | `_set_unique_skill_attack_buff_state` |  4941 | 4948 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 206 | `_get_unique_skill_defense_buff_key` |  4949 | 4954 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 207 | `_get_unique_skill_defense_buff_bonus` |  4955 | 4961 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 208 | `_set_unique_skill_defense_buff_state` |  4962 | 4969 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 209 | `_tick_unique_skill_attack_buffs_for_side` |  4970 | 4990 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 210 | `_finalize_unique_skill_action` |  4991 | 5024 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 211 | `_set_phase` |  5025 | 5083 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 212 | `_configure_floating_ally_command_panel` |  5084 | 5117 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 213 | `_configure_command_bar` |  5118 | 5142 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 214 | `_apply_floating_command_button_style` |  5143 | 5171 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 215 | `_should_show_floating_ally_command_panel` |  5172 | 5195 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 216 | `_refresh_floating_ally_command_panel` |  5196 | 5234 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 217 | `_hide_floating_ally_command_panel_for_tactical_selection` |  5235 | 5241 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 218 | `_restore_floating_ally_command_panel_input` |  5242 | 5255 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 219 | `_position_floating_ally_command_panel` |  5256 | 5271 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 220 | `_is_tactical_target_selection_mode` |  5272 | 5279 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 221 | `_choose_floating_ally_command_panel_position` |  5280 | 5299 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 222 | `_get_floating_ally_command_panel_candidate_positions` |  5300 | 5317 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 223 | `_clamp_floating_ally_command_panel_position` |  5318 | 5324 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 224 | `_score_floating_ally_command_panel_position` |  5325 | 5337 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 225 | `_get_rect_overlap_area` |  5338 | 5347 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 226 | `_get_visible_tactical_cell_ui_rects` |  5348 | 5368 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 227 | `_refresh_auto_battle_button_state` |  5369 | 5379 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 228 | `_on_defend_button_pressed` |  5380 | 5434 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 229 | `_recover_wounded_troops_for_defend` |  5435 | 5444 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 230 | `_end_ally_turn_by_wait` |  5445 | 5483 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 231 | `_can_use_direct_move_click` |  5484 | 5501 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 232 | `_is_move_range_overlay_visible` |  5502 | 5511 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 233 | `_try_handle_valid_move_cell_click` |  5512 | 5539 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 234 | `_try_direct_move_to_cell` |  5540 | 5554 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 235 | `_show_facing_selection_panel` |  5555 | 5574 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 236 | `_hide_facing_selection_panel` |  5575 | 5582 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 237 | `_position_facing_arrow_panel_near_ally` |  5583 | 5600 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 238 | `_place_facing_arrow_button_on_cell` |  5601 | 5629 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 239 | `_apply_facing_arrow_panel_visual_style` |  5630 | 5642 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 240 | `_apply_facing_arrow_button_style` |  5643 | 5670 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 241 | `_clear_facing_arrow_button_tweens` |  5671 | 5677 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 242 | `_play_facing_arrow_button_pop` |  5678 | 5697 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 243 | `_enter_post_move_facing_selection` |  5698 | 5712 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 244 | `_clear_auto_action_flags` |  5713 | 5717 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 245 | `_select_post_move_facing` |  5718 | 5743 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 246 | `_append_battle_log` |  5744 | 5750 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 247 | `_refresh_battle_log` |  5751 | 5766 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 248 | `_configure_layout_guides` |  5767 | 5816 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 249 | `_configure_formation_guide_slot` |  5817 | 5871 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 250 | `_clear_transient_battle_highlights` |  5872 | 5878 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 251 | `_configure_ally_ready_frames` |  5879 | 5883 | Mixed / Unsafe | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 252 | `_apply_ready_frame_style` |  5884 | 5896 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 253 | `_configure_unit_closeup_panel` |  5897 | 5924 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 254 | `_update_ally_ready_frames` |  5925 | 5931 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 255 | `_update_ready_frame_for_unit` |  5932 | 5952 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 256 | `_position_ready_frame_for_unit` |  5953 | 5967 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 257 | `_is_ally_unit_ready_for_action` |  5968 | 5983 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 258 | `_start_ready_frame_pulse` |  5984 | 6003 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 259 | `_stop_ready_frame_pulse` |  6004 | 6021 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 260 | `_show_unit_closeup_for_ally` |  6022 | 6050 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 261 | `_hide_unit_closeup_panel` |  6051 | 6059 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 262 | `_refresh_formation_slot_guides` |  6060 | 6066 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 263 | `_refresh_formation_slot_guide_for_entry` |  6067 | 6224 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 264 | `_log_roster_panel_slot_state` |  6225 | 6232 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 265 | `_get_formation_guide_unit_state_for_capacity_slot_id` |  6233 | 6236 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 266 | `_get_formation_guide_panel_nodes` |  6237 | 6255 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 267 | `_get_unique_skill_remaining_cooldown_turns` |  6256 | 6267 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 268 | `_is_unique_skill_ready_for_formation_guide` |  6268 | 6275 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 269 | `_set_formation_slot_unique_skill_ready_icon` |  6276 | 6281 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 270 | `_get_formation_guide_visual_key` |  6282 | 6301 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 271 | `_get_formation_guide_unit_type` |  6302 | 6308 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 272 | `_infer_unit_type_from_visual_key` |  6309 | 6321 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 273 | `_get_troop_type_label_for_visual_key` |  6322 | 6337 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 274 | `_get_troop_icon_texture_for_visual_key` |  6338 | 6353 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 275 | `_get_troop_icon_texture_from_token_paths` |  6354 | 6363 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 276 | `_get_troop_icon_fallback_keys` |  6364 | 6383 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 277 | `_get_closeup_portrait_texture_for_unit` |  6384 | 6388 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 278 | `_get_ally_portrait_texture_for_unit` |  6389 | 6405 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 279 | `_get_ally_token_texture_for_unit` |  6406 | 6409 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 280 | `_get_visual_token_for_unit` |  6410 | 6418 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 281 | `_get_visual_portrait_badge_for_unit` |  6419 | 6427 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 282 | `_get_visual_root_for_unit` |  6428 | 6436 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 283 | `_get_visual_token_base_scale_for_unit` |  6437 | 6484 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 284 | `_get_visual_portrait_badge_base_scale_for_unit` |  6485 | 6532 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 285 | `_set_visual_portrait_badge_base_scale_for_unit` |  6533 | 6559 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 286 | `_get_visual_root_base_scale_for_unit` |  6560 | 6607 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 287 | `_apply_active_ally_turn_pulse_root_ratio` |  6608 | 6622 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 288 | `_stop_active_ally_turn_pulse` |  6623 | 6647 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 289 | `_play_active_ally_turn_pulse` |  6648 | 6764 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 290 | `_get_unit_action_status_text` |  6765 | 6776 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 291 | `_handle_right_click_cancel` |  6777 | 6801 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 292 | `_cancel_attack_select_mode` |  6802 | 6814 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 293 | `_rollback_pending_ally_move` |  6815 | 6873 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 294 | `_store_pending_ally_move_snapshot` |  6874 | 6894 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 295 | `_clear_pending_move_snapshot` |  6895 | 6906 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 296 | `_play_enemy_turn_demo` |  6907 | 6910 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 297 | `_play_enemy_ai_turn` |  6911 | 6934 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 298 | `_play_enemy_ai_for_actor` |  6935 | 6989 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 299 | `_play_enemy_basic_attack_from_current_cell` |  6990 | 6993 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 300 | `_play_enemy_actor_basic_attack_from_current_cell` |  6994 | 7043 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 301 | `_play_enemy_path_move_then_act` |  7044 | 7047 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 302 | `_play_enemy_actor_path_move_then_act` |  7048 | 7088 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 303 | `_finish_enemy_basic_move` |  7089 | 7092 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 304 | `_finish_enemy_actor_basic_move` |  7093 | 7111 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 305 | `_play_enemy_basic_attack_or_wait_after_move` |  7112 | 7115 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 306 | `_play_enemy_actor_basic_attack_or_wait_after_move` |  7116 | 7141 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 307 | `_enemy_reaction_hit_on` |  7142 | 7166 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 308 | `_finish_enemy_actor_basic_attack` |  7167 | 7175 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 309 | `_return_to_ally_turn` |  7176 | 7212 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 310 | `_get_ally_group_nodes` |  7213 | 7224 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 311 | `_get_ally_support_group_nodes` |  7225 | 7236 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 312 | `_get_ally_main_03_group_nodes` |  7237 | 7248 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 313 | `_get_ally_reinforce_01_group_nodes` |  7249 | 7260 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 314 | `_get_ally_reinforce_02_group_nodes` |  7261 | 7272 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 315 | `_get_enemy_group_nodes` |  7273 | 7284 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 316 | `_get_enemy_support_group_nodes` |  7285 | 7296 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 317 | `_get_enemy_main_03_group_nodes` |  7297 | 7308 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 318 | `_get_enemy_reinforce_01_group_nodes` |  7309 | 7320 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 319 | `_get_enemy_reinforce_02_group_nodes` |  7321 | 7332 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 320 | `_get_click_area_layout_offset_for_unit` |  7333 | 7348 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 321 | `_get_group_base_positions_for_unit` |  7349 | 7364 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 322 | `_apply_group_offset_for_unit` |  7365 | 7377 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 323 | `_get_unit_visual_slots_for_state` |  7378 | 7406 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 324 | `_get_visual_slots_for_slot_id` |  7407 | 7423 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 325 | `_rebuild_unit_visual_slot_refs` |  7424 | 7431 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 326 | `_build_capacity_slot_metadata_registry` |  7432 | 7438 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 327 | `_create_capacity_slot_metadata` |  7439 | 7485 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 328 | `_get_test_battle_roster_hero_id` |  7486 | 7489 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 329 | `_get_test_battle_assigned_unit_id` |  7490 | 7496 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 330 | `_get_hero_id_for_unit_state` |  7497 | 7507 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 331 | `_get_hero_registry_entry` |  7508 | 7515 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 332 | `_get_hero_display_name_with_state` |  7516 | 7521 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 333 | `_get_hero_state_badge_text` |  7522 | 7537 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 334 | `_is_unit_hero_wounded` |  7538 | 7550 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 335 | `_get_wounded_penalty_multiplier` |  7551 | 7564 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 336 | `_get_unique_skill_effect_amount` |  7565 | 7569 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 337 | `_apply_wounded_amount_multiplier` |  7570 | 7581 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 338 | `_apply_wounded_incoming_damage_penalty` |  7582 | 7592 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 339 | `_log_wounded_penalty` |  7593 | 7606 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 340 | `_is_hero_entry_excluded_from_context_battle` |  7607 | 7617 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 341 | `_get_hero_entry_context_exclusion_reason` |  7618 | 7626 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 342 | `_load_texture_or_null` |  7627 | 7640 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 343 | `_apply_hero_identity_to_unit` |  7641 | 7671 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 344 | `_apply_all_hero_identities` |  7672 | 7679 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 345 | `_validate_hero_identity_bindings` |  7680 | 7722 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 346 | `_get_capacity_slot_formation_index` |  7723 | 7727 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 347 | `_get_capacity_slot_id_for_legacy_slot_id` |  7728 | 7731 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 348 | `_get_legacy_slot_id_for_capacity_slot_id` |  7732 | 7735 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 349 | `_get_capacity_slot_metadata` |  7736 | 7741 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 350 | `_set_capacity_slot_metadata_value` |  7742 | 7751 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 351 | `_is_capacity_slot_active` |  7752 | 7757 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 352 | `_is_capacity_slot_deployed` |  7758 | 7763 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 353 | `_get_active_capacity_slots_for_side` |  7764 | 7772 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 354 | `_get_deployed_capacity_slots_for_side` |  7773 | 7781 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 355 | `_rebuild_battle_unit_state_list_refs` |  7782 | 7813 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 356 | `_append_unit_state_to_adapter` |  7814 | 7819 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 357 | `_get_unit_states_for_side` |  7820 | 7828 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 358 | `_get_all_battle_unit_states_from_adapter` |  7829 | 7833 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 359 | `_is_battle_unit_state_adapter_ready` |  7834 | 7837 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 360 | `_get_unit_state_for_legacy_slot_id` |  7838 | 7844 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 361 | `_get_unit_state_for_capacity_slot_id` |  7845 | 7851 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 362 | `_get_capacity_slot_id_for_unit_state` |  7852 | 7862 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 363 | `_get_legacy_slot_id_for_unit_state` |  7863 | 7884 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 364 | `_get_deployed_unit_states_for_side` |  7885 | 7892 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 365 | `_get_active_unit_states_for_side` |  7893 | 7900 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 366 | `_get_alive_unit_states_for_side_from_adapter` |  7901 | 7908 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 367 | `_get_alive_deployed_unit_states_for_side` |  7909 | 7916 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 368 | `_get_all_alive_unit_states_from_adapter` |  7917 | 7925 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 369 | `_get_actor_candidates_for_side_from_adapter` |  7926 | 7933 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 370 | `_get_available_actor_candidates_for_side_from_adapter` |  7934 | 7947 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 371 | `_get_alive_target_candidates_for_side_from_adapter` |  7948 | 7958 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 372 | `_get_target_candidates_for_actor_from_adapter` |  7959 | 7965 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 373 | `_is_unit_state_deployed_by_capacity_slot` |  7966 | 7974 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 374 | `_is_unit_state_active_by_capacity_slot` |  7975 | 7983 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 375 | `_is_unit_state_available_for_battle_slot` |  7984 | 7998 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 376 | `_set_unit_deployed` |  7999 | 8011 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 377 | `_get_city_reinforcement_arrival_round` |  8012 | 8015 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 378 | `_is_city_reinforcement_ready_to_arrive` |  8016 | 8029 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 379 | `_deploy_city_reinforcement_unit` |  8030 | 8057 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 380 | `_deploy_reinforce_unit` |  8058 | 8084 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 381 | `_debug_log_reinforce_visual_state` |  8085 | 8158 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 382 | `_try_deploy_reinforce_01_pair` |  8159 | 8189 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 383 | `_try_deploy_city_reinforce_02_pair` |  8190 | 8227 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 384 | `_get_unit_visual_slot_for_state` |  8228 | 8257 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 385 | `_get_unit_visual_slot_for_slot_id` |  8258 | 8266 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 386 | `_get_unit_visual_slot_for_capacity_slot_id` |  8267 | 8275 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 387 | `_has_unit_visual_slot_for_state` |  8276 | 8279 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 388 | `_create_unit_visual_slot_from_dictionary` |  8280 | 8285 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 389 | `_get_visual_slots_dictionary_fallback_for_slot_id` |  8286 | 8311 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 390 | `_get_ally_main_visual_slots` |  8312 | 8327 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 391 | `_get_ally_support_visual_slots` |  8328 | 8343 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 392 | `_get_enemy_main_visual_slots` |  8344 | 8359 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 393 | `_get_enemy_support_visual_slots` |  8360 | 8375 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 394 | `_get_ally_main_03_visual_slots` |  8376 | 8391 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 395 | `_get_ally_reinforce_01_visual_slots` |  8392 | 8407 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 396 | `_get_ally_reinforce_02_visual_slots` |  8408 | 8423 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 397 | `_get_enemy_main_03_visual_slots` |  8424 | 8439 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 398 | `_get_enemy_reinforce_01_visual_slots` |  8440 | 8455 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 399 | `_get_enemy_reinforce_02_visual_slots` |  8456 | 8471 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 400 | `_debug_print_unit_visual_root_slots` |  8472 | 8491 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 401 | `_debug_print_capacity_slot_registry` |  8492 | 8512 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 402 | `_debug_print_mvp_scene_slot_scaffold_snapshot_once` |  8513 | 8545 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 403 | `_debug_print_battle_unit_state_list_adapter` |  8546 | 8558 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 404 | `_debug_print_adapter_alive_parity_snapshot_once` |  8559 | 8591 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 405 | `_debug_print_actor_target_adapter_snapshot_once` |  8592 | 8633 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 406 | `_debug_print_deployed_active_filter_snapshot_once` |  8634 | 8669 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 407 | `_debug_print_unit_state_visual_binding_summary` |  8670 | 8689 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 408 | `_debug_print_hp_troop_runtime_visibility_summary` |  8690 | 8763 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 409 | `_debug_print_ally_portrait_offsets` |  8764 | 8814 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 410 | `_configure_round_toast` |  8815 | 8832 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 411 | `_configure_unique_skill_toast` |  8833 | 8856 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 412 | `_configure_specialty_skill_cutin` |  8857 | 8887 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 413 | `_layout_specialty_skill_cutin` |  8888 | 8940 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 414 | `_hide_specialty_skill_cutin` |  8941 | 8967 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 415 | `_hide_unique_skill_toast` |  8968 | 8989 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 416 | `_configure_enemy_retreat_toast` |  8990 | 9013 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 417 | `_hide_enemy_retreat_toast` |  9014 | 9022 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 418 | `_make_defeat_retreat_toast_snapshot` |  9023 | 9034 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 419 | `_queue_defeat_retreat_toast_snapshot` |  9035 | 9049 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 420 | `_play_next_defeat_retreat_toast` |  9050 | 9063 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 421 | `_show_defeat_retreat_toast_snapshot` |  9064 | 9110 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 422 | `_begin_defeat_retreat_toast_hold` |  9111 | 9122 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 423 | `_log_defeat_retreat_toast_hold_elapsed` |  9123 | 9133 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 424 | `_finish_defeat_retreat_toast` |  9134 | 9154 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 425 | `_get_retreat_toast_portrait_texture` |  9155 | 9165 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 426 | `_get_defeat_retreat_line` |  9166 | 9177 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 427 | `_show_round_start_banner` |  9178 | 9184 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 428 | `_show_round_start_toast` |  9185 | 9188 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 429 | `_show_reinforcement_arrival_toast` |  9189 | 9204 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 430 | `_show_battle_result_toast` |  9205 | 9222 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 431 | `_enqueue_battle_toast` |  9223 | 9252 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 432 | `_play_next_battle_toast` |  9253 | 9281 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 433 | `_get_battle_result_state` |  9282 | 9291 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 434 | `_is_battle_result_finalized` |  9292 | 9295 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 435 | `_is_result_toast_tag` |  9296 | 9299 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 436 | `_clear_non_result_battle_toasts` |  9300 | 9322 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 437 | `_handle_battle_end_guard` |  9323 | 9344 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 438 | `_try_show_battle_result_toast_if_needed` |  9345 | 9365 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 439 | `_get_resolved_toast_texture` |  9366 | 9372 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 440 | `_show_battle_toast` |  9373 | 9421 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 441 | `_set_round_toast_shader_progress` |  9422 | 9430 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 442 | `_hide_round_start_toast` |  9431 | 9443 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 443 | `_finish_battle_toast_playback` |  9444 | 9452 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 444 | `_get_toast_texture_debug_name` |  9453 | 9461 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 445 | `_show_move_dust_for_unit` |  9462 | 9474 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 446 | `_fade_out_move_dust_for_unit` |  9475 | 9499 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 447 | `_hide_all_move_dust_sprites` |  9500 | 9522 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 448 | `_get_move_dust_sprite_for_unit` |  9523 | 9547 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 449 | `_get_move_dust_base_scale` |  9548 | 9553 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 450 | `_kill_move_dust_tween` |  9554 | 9563 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 451 | `_apply_move_dust_template_to_sprite` |  9564 | 9572 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 452 | `_spawn_attack_battle_dust_fx` |  9573 | 9576 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 453 | `_spawn_hit_battle_dust_fx` |  9577 | 9586 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 454 | `_spawn_battle_dust_fx` |  9587 | 9618 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 455 | `_play_arrow_projectile_effect` |  9619 | 9640 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 456 | `_get_arrow_curve_midpoint` |  9641 | 9651 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 457 | `_get_arrow_volley_blocking_duration` |  9652 | 9656 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 458 | `_get_arrow_volley_completion_extra_wait` |  9657 | 9660 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 459 | `_spawn_arrow_projectile` |  9661 | 9705 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 460 | `_spawn_arrow_impact_pin` |  9706 | 9743 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 461 | `_play_gunner_shot_effect` |  9744 | 9760 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 462 | `_get_gunner_visual_completion_extra_wait` |  9761 | 9764 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 463 | `_spawn_gunner_muzzle_flash` |  9765 | 9793 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 464 | `_spawn_gunner_tracer` |  9794 | 9814 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 465 | `_spawn_gunner_impact_pop` |  9815 | 9870 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 466 | `_spawn_attack_slash_fx` |  9871 | 9897 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 467 | `_spawn_hit_spark_fx` |  9898 | 9917 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 468 | `_spawn_damage_number_fx` |  9918 | 9945 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 469 | `_spawn_skill_damage_number_fx` |  9946 | 9973 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 470 | `_spawn_buff_number_fx` |  9974 | 9997 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 471 | `_spawn_defend_heal_text_fx` |  9998 | 10021 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 472 | `_spawn_strategy_text_fx` |  10022 | 10045 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 473 | `_start_unique_skill_camera_shake` |  10046 | 10068 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 474 | `_load_random_fx_texture` |  10069 | 10077 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 475 | `_create_fx_sprite` |  10078 | 10088 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 476 | `_start_new_round` |  10089 | 10107 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 477 | `_apply_group_offset` |  10108 | 10113 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 478 | `_apply_ally_group_offset` |  10114 | 10117 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 479 | `_apply_enemy_group_offset` |  10118 | 10121 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 480 | `_apply_enemy_support_group_offset` |  10122 | 10125 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 481 | `_apply_enemy_actor_group_offset` |  10126 | 10129 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 482 | `_set_group_modulate` |  10130 | 10136 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 483 | `_set_ally_group_modulate` |  10137 | 10140 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 484 | `_set_enemy_group_modulate` |  10141 | 10144 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 485 | `_set_enemy_actor_group_modulate` |  10145 | 10148 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 486 | `_set_all_unit_group_modulates` |  10149 | 10153 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 487 | `_show_move_highlight_at_position` |  10154 | 10164 | Movement / Range / Path | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 488 | `_collect_move_range_cells` |  10165 | 10181 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 489 | `_hide_move_range_overlay` |  10182 | 10189 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 490 | `_hide_attack_range_overlay` |  10190 | 10197 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 491 | `_hide_unique_skill_range_overlay` |  10198 | 10205 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 492 | `_hide_strategy_range_overlay` |  10206 | 10213 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 493 | `_clear_range_overlay_tweens` |  10214 | 10220 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 494 | `_get_cells_wave_order` |  10221 | 10229 | Movement / Range / Path | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 495 | `_show_range_overlay_cell` |  10230 | 10268 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 496 | `_get_range_overlay_start_scale` |  10269 | 10277 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 497 | `_get_range_overlay_pop_scale` |  10278 | 10286 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 498 | `_show_unique_skill_range_overlay` |  10287 | 10327 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 499 | `_show_strategy_range_overlay` |  10328 | 10369 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 500 | `_show_attack_range_overlay_for_active_unit` |  10370 | 10404 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 501 | `_show_move_range_overlay_for_active_unit` |  10405 | 10443 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 502 | `_is_move_range_overlay_rect_inside_visual_board` |  10444 | 10459 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 503 | `_format_troop_label` |  10460 | 10463 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 504 | `_update_troop_labels` |  10464 | 10467 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 505 | `_create_demo_unit_states` |  10468 | 10750 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 506 | `_sync_unit_state_cells_from_markers` |  10751 | 10773 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 507 | `_apply_melee_adjacent_qa_preset` |  10774 | 10800 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 508 | `_get_ally_visual_anchor_from_position` |  10801 | 10804 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 509 | `_get_enemy_visual_anchor_from_position` |  10805 | 10808 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 510 | `_get_ally_visual_anchor_position` |  10809 | 10812 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 511 | `_get_enemy_visual_anchor_position` |  10813 | 10816 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 512 | `_get_ally_support_visual_anchor_position` |  10817 | 10822 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 513 | `_get_enemy_support_visual_anchor_position` |  10823 | 10828 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 514 | `_capture_template_slot_offset` |  10829 | 10836 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 515 | `_get_canvas_item_world_position` |  10837 | 10846 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 516 | `_set_canvas_item_world_position` |  10847 | 10857 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 517 | `_set_marker_world_position` |  10858 | 10862 | Mixed / Unsafe | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 518 | `_get_slot_side_for_scene_visual_slot_id` |  10863 | 10868 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 519 | `_get_unit_marker_for_scene_visual_slot_id` |  10869 | 10894 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 520 | `_get_portrait_marker_for_scene_visual_slot_id` |  10895 | 10920 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 521 | `_get_visual_root_for_scene_visual_slot_id` |  10921 | 10925 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 522 | `_get_portrait_for_scene_visual_slot_id` |  10926 | 10930 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 523 | `_get_deployment_marker_base_world_position` |  10931 | 10939 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 524 | `_get_fallback_visual_anchor_for_deployment_marker` |  10940 | 10948 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 525 | `_get_scene_authored_visual_anchor` |  10949 | 10954 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 526 | `_get_scene_visual_anchor_for_slot_id` |  10955 | 10964 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 527 | `_sync_deployment_markers_from_scene_visual_anchors` |  10965 | 10983 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 528 | `_capture_portrait_template_offsets` |  10984 | 11012 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 529 | `_get_portrait_template_offset` |  11013 | 11019 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 530 | `_get_ally_portrait_offset_for_facing` |  11020 | 11026 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 531 | `_get_enemy_portrait_offset_for_facing` |  11027 | 11033 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 532 | `_normalize_unit_type` |  11034 | 11041 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 533 | `_get_default_attack_range_for_unit_type` |  11042 | 11053 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 534 | `_get_default_attack_range_for_visual_key` |  11054 | 11057 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 535 | `_get_visual_template_for_slot` |  11058 | 11066 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 536 | `_get_visual_template_for_unit` |  11067 | 11079 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 537 | `_get_visual_key_for_unit` |  11080 | 11090 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 538 | `_is_archer_unit` |  11091 | 11104 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 539 | `_is_gunner_unit` |  11105 | 11118 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 540 | `_get_visual_fallback_key_for_unit` |  11119 | 11127 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 541 | `_get_visual_token_paths_for_unit` |  11128 | 11144 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 542 | `_try_load_texture_or_null` |  11145 | 11150 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 543 | `_load_optional_texture` |  11151 | 11154 | UI / HUD / Text Formatter | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formatter/lookup reuse candidate | Review before extraction; wrapper required. |
| 544 | `_get_all_visual_template_roots` |  11155 | 11170 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 545 | `_set_visual_template_token_sprite_visibility` |  11171 | 11177 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 546 | `_get_visual_token_texture_for_unit` |  11178 | 11200 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 547 | `_sync_runtime_portrait_markers_to_visuals` |  11201 | 11225 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 548 | `_restore_enemy_main_portrait_bindings` |  11226 | 11232 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 549 | `_capture_scene_authored_unit_layout_offsets` |  11233 | 11462 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 550 | `_get_ally_group_base_positions` |  11463 | 11466 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 551 | `_get_ally_group_base_positions_for_unit` |  11467 | 11482 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 552 | `_get_enemy_group_base_positions` |  11483 | 11486 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 553 | `_get_enemy_group_base_positions_for_unit` |  11487 | 11502 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 554 | `_get_ally_support_group_base_positions` |  11503 | 11506 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 555 | `_get_ally_support_group_base_positions_for_unit` |  11507 | 11522 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 556 | `_get_enemy_support_group_base_positions` |  11523 | 11526 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 557 | `_get_enemy_support_group_base_positions_for_unit` |  11527 | 11542 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 558 | `_apply_group_base_positions` |  11543 | 11546 | Mixed / Unsafe | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 559 | `_get_ally_portrait_visual_offset` |  11547 | 11550 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 560 | `_get_enemy_portrait_visual_offset` |  11551 | 11554 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 561 | `_get_cell_from_world` |  11555 | 11558 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 562 | `_get_raw_move_target_cell` |  11559 | 11562 | Movement / Range / Path | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 563 | `_get_selected_move_target_cell` |  11563 | 11566 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 564 | `_get_snapped_move_target_cell` |  11567 | 11577 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 565 | `_get_snapped_move_target_world_position` |  11578 | 11581 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 566 | `_get_selected_ally_display_name` |  11582 | 11587 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 567 | `_get_selected_ally_unit_marker` |  11588 | 11591 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 568 | `_get_selected_ally_portrait_marker` |  11592 | 11595 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 569 | `_get_unit_marker_for_unit` |  11596 | 11619 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 570 | `_get_portrait_marker_for_unit` |  11620 | 11643 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 571 | `_get_selected_ally_click_area` |  11644 | 11647 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 572 | `_get_selected_ally_visual_anchor_position` |  11648 | 11651 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 573 | `_get_ally_target_visual_anchor_position` |  11652 | 11655 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 574 | `_get_ally_target_group_nodes` |  11656 | 11659 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 575 | `_apply_ally_target_group_offset` |  11660 | 11666 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 576 | `_set_ally_target_group_modulate` |  11667 | 11675 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 577 | `_update_ally_target_visuals_from_state` |  11676 | 11679 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 578 | `_apply_selected_ally_group_offset` |  11680 | 11683 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 579 | `_get_selected_ally_portrait_visual_offset` |  11684 | 11691 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 580 | `_sync_selected_ally_markers_to_position` |  11692 | 11703 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 581 | `_get_enemy_target_unit_marker` |  11704 | 11707 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 582 | `_get_enemy_target_visual_anchor_position` |  11708 | 11711 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 583 | `_get_enemy_target_group_nodes` |  11712 | 11715 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 584 | `_get_enemy_actor_unit_marker` |  11716 | 11719 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 585 | `_get_enemy_actor_portrait_marker` |  11720 | 11723 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 586 | `_get_enemy_actor_visual_anchor_position` |  11724 | 11727 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 587 | `_get_enemy_actor_group_nodes` |  11728 | 11731 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 588 | `_update_enemy_actor_visuals_from_state` |  11732 | 11735 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 589 | `_sync_enemy_actor_markers_to_position` |  11736 | 11744 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 590 | `_apply_enemy_target_group_offset` |  11745 | 11751 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 591 | `_set_enemy_target_group_modulate` |  11752 | 11760 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 592 | `_update_enemy_target_visuals_from_state` |  11761 | 11764 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 593 | `_get_alive_enemy_targets` |  11765 | 11771 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 594 | `_get_enemy_ai_target_state` |  11772 | 11778 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 595 | `_get_enemy_ai_target_state_for_actor` |  11779 | 11788 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 596 | `_get_enemy_ai_target_state_from_candidates` |  11789 | 11812 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 597 | `_clear_enemy_ai_turn_reservations` |  11813 | 11817 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 598 | `_is_enemy_ai_destination_cell_reserved_for_other_actor` |  11818 | 11828 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 599 | `_is_enemy_ai_engagement_cell_reserved_for_other_actor` |  11829 | 11839 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 600 | `_can_enemy_ai_use_destination_cell` |  11840 | 11847 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 601 | `_reserve_enemy_ai_decision_plan_for_actor` |  11848 | 11859 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 602 | `_get_enemy_ai_action_priority` |  11860 | 11873 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 603 | `_get_enemy_ai_target_candidates_in_priority_order` |  11874 | 11899 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 604 | `_should_replace_enemy_ai_decision_plan` |  11900 | 11925 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 605 | `_build_enemy_ai_target_action_plan_for_actor` |  11926 | 12036 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 606 | `_get_enemy_ai_decision_plan_for_actor` |  12037 | 12106 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 607 | `_log_enemy_ai_decision_plan` |  12107 | 12132 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 608 | `_get_legacy_enemy_ai_target_state` |  12133 | 12142 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 609 | `_get_target_candidates_for_actor` |  12143 | 12149 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 610 | `_get_fallback_target_candidates_for_actor` |  12150 | 12160 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 611 | `_get_first_candidate_from_list` |  12161 | 12166 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 612 | `_find_best_attack_target_for_active_ally` |  12167 | 12182 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 613 | `_refresh_attack_target_for_active_ally` |  12183 | 12202 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 614 | `_get_alive_ally_units` |  12203 | 12209 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 615 | `_get_fallback_alive_ally_units` |  12210 | 12220 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 616 | `_get_alive_enemy_units` |  12221 | 12227 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 617 | `_get_fallback_alive_enemy_units` |  12228 | 12238 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 618 | `_mark_ally_unit_acted` |  12239 | 12255 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 619 | `_has_ally_unit_acted` |  12256 | 12265 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 620 | `_reset_ally_action_locks_for_new_round` |  12266 | 12272 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 621 | `_mark_enemy_unit_acted` |  12273 | 12287 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 622 | `_has_enemy_unit_acted` |  12288 | 12297 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 623 | `_reset_enemy_action_locks_for_new_round` |  12298 | 12304 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 624 | `_are_all_alive_enemies_acted` |  12305 | 12314 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 625 | `_get_next_available_enemy_ai_actor` |  12315 | 12324 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 626 | `_are_all_alive_allies_acted` |  12325 | 12334 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 627 | `_get_first_available_ally_unit` |  12335 | 12341 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 628 | `_get_available_auto_units_for_side` |  12342 | 12368 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 629 | `_get_alive_auto_targets_for_side` |  12369 | 12380 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 630 | `_get_auto_damage_for_actor` |  12381 | 12388 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 631 | `_get_auto_damage_for_actor_against_target` |  12389 | 12392 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 632 | `_can_auto_kill_target` |  12393 | 12400 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 633 | `_get_auto_slot_priority` |  12401 | 12410 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 634 | `_score_auto_attack_target` |  12411 | 12436 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 635 | `_find_best_auto_attack_target_from_candidates` |  12437 | 12452 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 636 | `_find_best_auto_attack_target` |  12453 | 12456 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 637 | `_get_auto_move_path_for_actor` |  12457 | 12473 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 638 | `_find_best_auto_move_cell` |  12474 | 12518 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 639 | `_debug_print_auto_battle_policy_snapshot` |  12519 | 12549 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 640 | `_get_best_auto_facing_toward_nearest_enemy` |  12550 | 12574 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 641 | `_select_auto_facing_after_move_for_active_ally` |  12575 | 12580 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 642 | `_toggle_full_auto_battle` |  12581 | 12589 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 643 | `_set_full_auto_battle_enabled` |  12590 | 12611 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 644 | `_stop_full_auto_battle` |  12612 | 12628 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 645 | `_tick_full_auto_battle_if_needed` |  12629 | 12661 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 646 | `_get_auto_battle_max_steps` |  12662 | 12667 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 647 | `_try_auto_attack_for_active_ally` |  12668 | 12700 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 648 | `_try_auto_move_for_active_ally` |  12701 | 12739 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 649 | `_auto_wait_active_ally` |  12740 | 12747 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 650 | `_run_auto_action_for_active_ally_once` |  12748 | 12779 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 651 | `_is_active_ally_action_available` |  12780 | 12791 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 652 | `_is_active_ally_locked` |  12792 | 12809 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 653 | `_is_ally_selection_switch_blocked` |  12810 | 12815 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 654 | `_is_unit_selectable` |  12816 | 12819 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 655 | `_is_enemy_click_candidate_alive` |  12820 | 12823 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 656 | `_cleanup_dead_units` |  12824 | 12859 | WorldMap Bridge / Handoff Contract | Stage D | Scene transition, worldmap context, or battle result contract. | NO | Do not move before dedicated contract lock. |
| 657 | `_set_unit_visual_group_visible` |  12860 | 12888 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 658 | `_restore_unit_visual_group_modulate_for_unit` |  12889 | 12910 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 659 | `_set_unit_click_area_enabled` |  12911 | 12925 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 660 | `_get_visual_group_nodes_for_unit` |  12926 | 12957 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 661 | `_get_click_area_for_unit` |  12958 | 12986 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 662 | `_get_click_shape_for_unit` |  12987 | 13015 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 663 | `_get_ready_frame_for_unit` |  13016 | 13025 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 664 | `_get_facing_indicator_for_unit` |  13026 | 13035 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 665 | `_get_all_unit_states_in_slot_order` |  13036 | 13050 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 666 | `_get_ally_main_03_visual_anchor_position` |  13051 | 13056 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 667 | `_get_enemy_main_03_visual_anchor_position` |  13057 | 13062 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 668 | `_get_ally_reinforce_01_visual_anchor_position` |  13063 | 13068 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 669 | `_get_enemy_reinforce_01_visual_anchor_position` |  13069 | 13074 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 670 | `_get_ally_reinforce_02_visual_anchor_position` |  13075 | 13080 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 671 | `_get_enemy_reinforce_02_visual_anchor_position` |  13081 | 13086 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 672 | `_get_visual_anchor_position_for_unit` |  13087 | 13134 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 673 | `_refresh_facing_indicator_for_unit` |  13135 | 13144 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 674 | `_hide_facing_indicator_for_unit` |  13145 | 13151 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 675 | `_position_facing_indicator_for_unit` |  13152 | 13218 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 676 | `set_move_target_cell` |  13219 | 13242 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 677 | `_select_ally_unit` |  13243 | 13279 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 678 | `_select_enemy_attack_target` |  13280 | 13292 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 679 | `_clear_attack_target_selection` |  13293 | 13300 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 680 | `_show_attack_target_feedback` |  13301 | 13327 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 681 | `_is_click_inside_unit_click_area` |  13328 | 13345 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 682 | `_get_clicked_ally_unit_at_position` |  13346 | 13355 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 683 | `_get_clicked_enemy_unit_at_position` |  13356 | 13367 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 684 | `_get_closest_unit_state_to_click_position` |  13368 | 13384 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 685 | `_debug_log_enemy_click_binding` |  13385 | 13418 | Reinforcement | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Reinforcement reuse candidate | Keep in battle main for now. |
| 686 | `_is_click_inside_ally_support_click_area` |  13419 | 13437 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 687 | `_is_click_inside_enemy_support_click_area` |  13438 | 13456 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 688 | `_update_cell_size_visual_guide` |  13457 | 13503 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 689 | `_update_logical_grid_guide` |  13504 | 13544 | Movement / Range / Path | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 690 | `_place_cell_guide_rect` |  13545 | 13564 | Movement / Range / Path | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 691 | `_get_ally_click_area_local_position` |  13565 | 13574 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 692 | `_is_click_inside_ally_click_area` |  13575 | 13595 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 693 | `_get_enemy_click_area_local_position` |  13596 | 13605 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 694 | `_is_click_inside_enemy_click_area` |  13606 | 13622 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 695 | `_is_valid_grid_cell` |  13623 | 13626 | Movement / Range / Path | Stage B | Reads battle data or constants; wrapper/signature review required. | NO | Review before extraction; wrapper required. |
| 696 | `is_cell_occupied` |  13627 | 13633 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 697 | `get_active_move_origin_cell` |  13634 | 13639 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 698 | `get_active_move_range` |  13640 | 13645 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 699 | `_get_all_alive_unit_states` |  13646 | 13652 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 700 | `_get_fallback_all_alive_unit_states` |  13653 | 13673 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 701 | `_get_occupied_cells_except` |  13674 | 13684 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 702 | `_is_cell_occupied_except` |  13685 | 13691 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 703 | `_get_occupied_cells_for_move` |  13692 | 13695 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 704 | `_is_cell_occupied_for_move` |  13696 | 13699 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 705 | `_is_valid_destination_for_unit` |  13700 | 13716 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 706 | `_is_path_clear_for_unit` |  13717 | 13736 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 707 | `_is_cell_walkable_for_ally` |  13737 | 13748 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 708 | `_find_ally_move_path` |  13749 | 13806 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 709 | `_get_occupied_cells_for_enemy_move` |  13807 | 13813 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 710 | `_is_cell_walkable_for_enemy` |  13814 | 13817 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 711 | `_is_cell_walkable_for_enemy_actor` |  13818 | 13829 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 712 | `_find_enemy_move_path` |  13830 | 13833 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 713 | `_find_enemy_move_path_for_actor` |  13834 | 13840 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 714 | `_find_enemy_path_to_destination_for_actor` |  13841 | 13902 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 715 | `_get_enemy_reachable_paths` |  13903 | 13906 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 716 | `_get_enemy_reachable_paths_for_actor` |  13907 | 13955 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 717 | `_choose_enemy_basic_ai_destination` |  13956 | 13959 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 718 | `_choose_enemy_basic_ai_destination_for_actor` |  13960 | 13967 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 719 | `_should_enemy_use_surround_pressure_mode` |  13968 | 13973 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 720 | `_get_surround_candidate_cells_around_target` |  13974 | 13977 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 721 | `_get_enemy_engagement_candidate_cells` |  13978 | 14024 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 722 | `_is_surround_candidate_cell_for_target` |  14025 | 14034 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 723 | `_get_enemy_engagement_step_plan_for_actor` |  14035 | 14097 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 724 | `get_unit_grid_distance` |  14098 | 14103 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 725 | `_debug_print_combat_distance` |  14104 | 14117 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 726 | `is_unit_in_attack_range` |  14118 | 14129 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 727 | `is_enemy_in_active_attack_range` |  14130 | 14147 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 728 | `is_valid_move_target` |  14148 | 14170 | Damage / Stat / Formula | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Generic combat calculation candidate | Keep in battle main for now. |
| 729 | `_refresh_move_target_feedback` |  14171 | 14191 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 730 | `_clear_move_target_selection` |  14192 | 14198 | Selection / Interaction | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 731 | `_sync_ally_markers_to_current_position` |  14199 | 14205 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 732 | `_is_mouse_over_battle_ui` |  14206 | 14216 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 733 | `_is_node_in_subtree` |  14217 | 14225 | Turn / Phase / Flow | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 734 | `_format_cell` |  14226 | 14229 | UI / HUD / Text Formatter | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formatter/lookup reuse candidate | Keep in battle main for now. |
| 735 | `_update_all_unit_visuals_from_state` |  14230 | 14238 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 736 | `_update_unit_visuals_from_state` |  14239 | 14256 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 737 | `_update_ally_visuals_from_state` |  14257 | 14260 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 738 | `_update_ally_support_visuals_from_state` |  14261 | 14264 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 739 | `_update_ally_main_03_visuals_from_state` |  14265 | 14268 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 740 | `_update_enemy_visuals_from_state` |  14269 | 14272 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 741 | `_update_enemy_support_visuals_from_state` |  14273 | 14276 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 742 | `_update_enemy_main_03_visuals_from_state` |  14277 | 14280 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 743 | `_update_ally_reinforce_01_visuals_from_state` |  14281 | 14284 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 744 | `_update_ally_reinforce_02_visuals_from_state` |  14285 | 14288 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 745 | `_update_enemy_reinforce_01_visuals_from_state` |  14289 | 14292 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 746 | `_update_enemy_reinforce_02_visuals_from_state` |  14293 | 14296 | Reinforcement | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Reinforcement reuse candidate | Review before extraction; wrapper required. |
| 747 | `_get_hp_bar_for_unit` |  14297 | 14313 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 748 | `_get_troop_label_for_unit` |  14314 | 14330 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 749 | `_get_hp_bar_layout_offset_for_unit` |  14331 | 14342 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 750 | `_get_troop_label_layout_offset_for_unit` |  14343 | 14354 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 751 | `_apply_hp_bar_runtime_alpha` |  14355 | 14362 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 752 | `_apply_hp_bar_alpha_for_unit` |  14363 | 14369 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 753 | `_apply_hp_bar_alpha_to_all_units` |  14370 | 14374 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 754 | `_apply_unit_visual_layer_profile_for_unit` |  14375 | 14392 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 755 | `_restore_hp_troop_runtime_visibility_for_unit` |  14393 | 14412 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 756 | `_normalize_facing` |  14413 | 14424 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 757 | `_is_vertical_facing` |  14425 | 14429 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 758 | `_is_horizontal_facing` |  14430 | 14434 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 759 | `_set_unit_facing` |  14435 | 14440 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 760 | `_get_horizontal_facing_from_step` |  14441 | 14448 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 761 | `_apply_unit_movement_facing` |  14449 | 14461 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 762 | `_face_unit_toward_cell` |  14462 | 14475 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 763 | `_refresh_initial_unit_facing` |  14476 | 14488 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 764 | `_refresh_ally_facing_toward_enemy_if_not_manual` |  14489 | 14499 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 765 | `_refresh_enemy_facing_for_enemy_action` |  14500 | 14503 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 766 | `_refresh_enemy_facing_for_actor_action` |  14504 | 14514 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 767 | `_apply_unit_facing_visuals` |  14515 | 14526 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 768 | `_apply_token_facing_visual` |  14527 | 14544 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 769 | `_is_token_flip_h_for_facing` |  14545 | 14563 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 770 | `_get_default_token_texture_for_facing` |  14564 | 14580 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 771 | `_get_facing_aware_portrait_offset` |  14581 | 14591 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 772 | `_get_unit_facing` |  14592 | 14597 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 773 | `_get_facing_arrow_text` |  14598 | 14611 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 774 | `_update_facing_indicators` |  14612 | 14616 | Formation / Facing | Stage B | Reads battle data or constants; wrapper/signature review required. | YES - Formation reuse candidate | Review before extraction; wrapper required. |
| 775 | `_position_facing_indicator_for_ally` |  14617 | 14623 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 776 | `_position_facing_indicator_for_ally_support` |  14624 | 14630 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 777 | `_position_facing_indicator_for_ally_main_03` |  14631 | 14637 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 778 | `_position_facing_indicator_for_ally_reinforce_01` |  14638 | 14644 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 779 | `_position_facing_indicator_for_ally_reinforce_02` |  14645 | 14651 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 780 | `_position_facing_indicator_for_enemy` |  14652 | 14658 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 781 | `_position_facing_indicator_for_enemy_support` |  14659 | 14665 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 782 | `_position_facing_indicator_for_enemy_main_03` |  14666 | 14672 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 783 | `_position_facing_indicator_for_enemy_reinforce_01` |  14673 | 14679 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 784 | `_position_facing_indicator_for_enemy_reinforce_02` |  14680 | 14686 | Formation / Facing | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | YES - Formation reuse candidate | Keep in battle main for now. |
| 785 | `_set_facing_indicators_visible` |  14687 | 14695 | Unique / Specialty Skill | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | REVIEW - Naval skill reuse candidate | Keep in battle main for now. |
| 786 | `_set_toast_facing_indicator_suppression` |  14696 | 14713 | Unique / Specialty Skill | Stage B | Reads battle data or constants; wrapper/signature review required. | REVIEW - Naval skill reuse candidate | Review before extraction; wrapper required. |
| 787 | `_world_to_battle_ui_position` |  14714 | 14724 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 788 | `_start_idle_breathing` |  14725 | 14741 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 789 | `_start_token_idle` |  14742 | 14751 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 790 | `_stop_idle_breathing` |  14752 | 14801 | Enemy AI | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
| 791 | `_sync_overlay_positions` |  14802 | 14810 | Unit Visual / Animation | Stage C | Mutates battle runtime state or has node/formula/AI coupling. | NO | Keep in battle main for now. |
