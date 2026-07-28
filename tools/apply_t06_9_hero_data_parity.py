#!/usr/bin/env python3
from pathlib import Path

battle_path = Path('scripts/battle_web_import_test.gd')
world_path = Path('scripts/worldmap/worldmap_main.gd')

battle = battle_path.read_text(encoding='utf-8')
world = world_path.read_text(encoding='utf-8')

# 1. Emit explicit per-hero outcomes in battle result payload.
anchor = '''\tpayload["attacker_surviving_general_ids"] = _get_surviving_general_ids_for_side(attacker_battle_side)\n\tpayload["defender_surviving_general_ids"] = _get_surviving_general_ids_for_side(defender_battle_side)\n\treturn payload\n'''
replacement = '''\tpayload["attacker_surviving_general_ids"] = _get_surviving_general_ids_for_side(attacker_battle_side)\n\tpayload["defender_surviving_general_ids"] = _get_surviving_general_ids_for_side(defender_battle_side)\n\tpayload["attacker_hero_outcomes"] = _build_hero_outcomes_for_side(attacker_battle_side)\n\tpayload["defender_hero_outcomes"] = _build_hero_outcomes_for_side(defender_battle_side)\n\treturn payload\n'''
if anchor not in battle:
    raise SystemExit('battle result outcome anchor missing')
battle = battle.replace(anchor, replacement, 1)

insert_anchor = '''func _get_or_create_battle_result_id() -> String:\n'''
helper = '''func _build_hero_outcomes_for_side(side: String) -> Dictionary:\n\tvar outcomes := {}\n\tfor unit_state in _get_deployed_unit_states_for_side(side):\n\t\tif unit_state == null:\n\t\t\tcontinue\n\t\tvar hero_id := _get_hero_id_for_unit_state(unit_state)\n\t\tif hero_id.is_empty():\n\t\t\tcontinue\n\t\toutcomes[hero_id] = {\n\t\t\t"hero_id": hero_id,\n\t\t\t"unit_id": unit_state.unit_id,\n\t\t\t"survived": unit_state.is_alive(),\n\t\t\t"current_hp": maxi(0, int(unit_state.current_hp)),\n\t\t\t"max_hp": maxi(0, int(unit_state.max_hp)),\n\t\t\t"current_troops": maxi(0, int(unit_state.current_troops)),\n\t\t\t"max_troops": maxi(0, int(unit_state.max_troops)),\n\t\t\t"allocated_troops": maxi(0, int(unit_state.allocated_troops)),\n\t\t\t"initial_allocated_troops": maxi(0, int(unit_state.initial_allocated_troops)),\n\t\t\t"unit_type": unit_state.unit_type,\n\t\t\t"unique_skill_id": unit_state.unique_skill_id,\n\t\t}\n\treturn outcomes\n\n\n'''
if insert_anchor not in battle:
    raise SystemExit('battle helper insertion anchor missing')
battle = battle.replace(insert_anchor, helper + insert_anchor, 1)

# 2. Re-authorize context hero data through HeroRuntimeFactory.
anchor = '''func _get_hero_battle_data_for_battle_context(hero_id: String, fallback_city_id: String) -> Dictionary:\n\tvar hero_data := _get_hero_entry(hero_id)\n\tif hero_data.is_empty():\n\t\treturn {}\n\tvar battle_data := hero_data.duplicate(true)\n'''
replacement = '''func _get_hero_battle_data_for_battle_context(hero_id: String, fallback_city_id: String) -> Dictionary:\n\tvar hero_data := _get_hero_entry(hero_id)\n\tif hero_data.is_empty():\n\t\treturn {}\n\tvar battle_data := HeroRuntimeFactory.build_runtime_hero(hero_data, hero_data)\n\tif not HeroRuntimeFactory.is_valid_runtime_hero(battle_data):\n\t\tpush_error("[T06_9_PARITY] runtime hero rebuild failed hero=%s error=%s" % [\n\t\t\thero_id,\n\t\t\tString(battle_data.get("runtime_factory_error", "unknown")),\n\t\t])\n\t\treturn {}\n'''
if anchor not in world:
    raise SystemExit('worldmap battle data anchor missing')
world = world.replace(anchor, replacement, 1)

# 3. T02 player attack: settle every participating attacker using explicit outcome.
old = '''\tvar wounded := maxi(0, int(result.get("attacker_wounded", 0)))\n\tvar surviving_generals := _normalize_battle_result_hero_ids(result.get("attacker_surviving_general_ids", []))\n\tvar destination_city_id := target_city_id if attacker_won else source_city_id\n'''
new = '''\tvar wounded := maxi(0, int(result.get("attacker_wounded", 0)))\n\tvar surviving_generals := _normalize_battle_result_hero_ids(result.get("attacker_surviving_general_ids", []))\n\tvar attacker_general_ids := _normalize_battle_result_hero_ids(result.get("attacker_general_ids", []))\n\tvar attacker_hero_outcomes := _normalize_battle_hero_outcomes(result.get("attacker_hero_outcomes", {}))\n\tvar destination_city_id := target_city_id if attacker_won else source_city_id\n'''
if old not in world:
    raise SystemExit('T02 result variables anchor missing')
world = world.replace(old, new, 1)

old = '''\tfor hero_id in surviving_generals:\n\t\t_move_hero_to_city_t02(hero_id, destination_city_id)\n\t\tvar hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))\n\t\thero_state["status"] = HERO_RUNTIME_STATUS_NORMAL\n\t\thero_state["wounded"] = false\n\t\t_hero_runtime_states[hero_id] = hero_state\n'''
new = '''\tif attacker_general_ids.is_empty():\n\t\tattacker_general_ids = attacker_hero_outcomes.keys()\n\tfor hero_id_variant in attacker_general_ids:\n\t\tvar hero_id := str(hero_id_variant)\n\t\tif hero_id.is_empty():\n\t\t\tcontinue\n\t\t_move_hero_to_city_t02(hero_id, destination_city_id)\n\t\tvar hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))\n\t\tvar outcome: Dictionary = attacker_hero_outcomes.get(hero_id, {})\n\t\tvar survived := bool(outcome.get("survived", surviving_generals.has(hero_id)))\n\t\tif survived:\n\t\t\thero_state["status"] = HERO_RUNTIME_STATUS_NORMAL\n\t\t\thero_state["wounded"] = false\n\t\t\thero_state["captured"] = false\n\t\t\thero_state["dead"] = false\n\t\t\thero_state["wounded_turns_remaining"] = 0\n\t\telse:\n\t\t\thero_state["status"] = HERO_RUNTIME_STATUS_WOUNDED\n\t\t\thero_state["wounded"] = true\n\t\t\thero_state["captured"] = false\n\t\t\thero_state["dead"] = false\n\t\t\thero_state["wounded_turns_remaining"] = DEFAULT_WOUNDED_RECOVERY_TURNS\n\t\thero_state["last_battle_current_troops"] = maxi(0, int(outcome.get("current_troops", 0)))\n\t\thero_state["last_battle_max_troops"] = maxi(0, int(outcome.get("max_troops", 0)))\n\t\thero_state["last_battle_transaction_id"] = transaction_id\n\t\t_hero_runtime_states[hero_id] = hero_state\n'''
if old not in world:
    raise SystemExit('T02 surviving hero loop anchor missing')
world = world.replace(old, new, 1)

# 4. Explicit outcome normalization and application for normal invasion/result path.
insert_anchor = '''func _apply_invasion_hero_state_placeholder(result_payload: Dictionary, result_summary: Dictionary) -> Dictionary:\n'''
helpers = '''func _normalize_battle_hero_outcomes(raw_outcomes: Variant) -> Dictionary:\n\tvar normalized := {}\n\tif not raw_outcomes is Dictionary:\n\t\treturn normalized\n\tfor key_variant in (raw_outcomes as Dictionary).keys():\n\t\tvar raw_value: Variant = (raw_outcomes as Dictionary).get(key_variant, {})\n\t\tif not raw_value is Dictionary:\n\t\t\tcontinue\n\t\tvar outcome := (raw_value as Dictionary).duplicate(true)\n\t\tvar raw_hero_id := str(outcome.get("hero_id", key_variant))\n\t\tvar hero_id := str(BATTLE_RESULT_HERO_ID_COMPATIBILITY.get(raw_hero_id, raw_hero_id))\n\t\tif hero_id.is_empty():\n\t\t\tcontinue\n\t\toutcome["hero_id"] = hero_id\n\t\tnormalized[hero_id] = outcome\n\treturn normalized\n\n\nfunc _apply_explicit_battle_hero_outcomes(result_payload: Dictionary) -> Dictionary:\n\tvar wounded_hero_ids: Array[String] = []\n\tvar normal_hero_ids: Array[String] = []\n\tvar skipped_hero_ids: Array[String] = []\n\tvar has_explicit_data := false\n\tfor context_side in ["attacker", "defender"]:\n\t\tvar outcomes := _normalize_battle_hero_outcomes(result_payload.get("%s_hero_outcomes" % context_side, {}))\n\t\tif not outcomes.is_empty():\n\t\t\thas_explicit_data = true\n\t\tfor hero_id_variant in outcomes.keys():\n\t\t\tvar hero_id := str(hero_id_variant)\n\t\t\tvar outcome: Dictionary = outcomes.get(hero_id, {})\n\t\t\tif hero_id.is_empty() or _get_hero_seed_entry(hero_id).is_empty():\n\t\t\t\tskipped_hero_ids.append(hero_id)\n\t\t\t\tcontinue\n\t\t\tvar hero_state := _normalize_hero_runtime_state(hero_id, _get_existing_hero_runtime_state(hero_id))\n\t\t\tif bool(hero_state.get("captured", false)) or bool(hero_state.get("dead", false)):\n\t\t\t\tskipped_hero_ids.append(hero_id)\n\t\t\t\tcontinue\n\t\t\tif bool(outcome.get("survived", false)):\n\t\t\t\thero_state["status"] = HERO_RUNTIME_STATUS_NORMAL\n\t\t\t\thero_state["wounded"] = false\n\t\t\t\thero_state["wounded_turns_remaining"] = 0\n\t\t\t\tnormal_hero_ids.append(hero_id)\n\t\t\telse:\n\t\t\t\thero_state["status"] = HERO_RUNTIME_STATUS_WOUNDED\n\t\t\t\thero_state["wounded"] = true\n\t\t\t\thero_state["wounded_turns_remaining"] = DEFAULT_WOUNDED_RECOVERY_TURNS\n\t\t\t\twounded_hero_ids.append(hero_id)\n\t\t\thero_state["last_battle_current_troops"] = maxi(0, int(outcome.get("current_troops", 0)))\n\t\t\thero_state["last_battle_max_troops"] = maxi(0, int(outcome.get("max_troops", 0)))\n\t\t\thero_state["last_battle_transaction_id"] = str(result_payload.get("transaction_id", ""))\n\t\t\t_hero_runtime_states[hero_id] = hero_state\n\treturn {\n\t\t"has_explicit_data": has_explicit_data,\n\t\t"wounded_hero_ids": wounded_hero_ids,\n\t\t"normal_hero_ids": normal_hero_ids,\n\t\t"captured_hero_ids": [],\n\t\t"dead_hero_ids": [],\n\t\t"skipped_hero_ids": skipped_hero_ids,\n\t}\n\n\n'''
if insert_anchor not in world:
    raise SystemExit('hero placeholder insertion anchor missing')
world = world.replace(insert_anchor, helpers + insert_anchor, 1)

old = '''func _apply_invasion_hero_state_placeholder(result_payload: Dictionary, result_summary: Dictionary) -> Dictionary:\n\tvar updated_summary := result_summary.duplicate(true)\n'''
new = '''func _apply_invasion_hero_state_placeholder(result_payload: Dictionary, result_summary: Dictionary) -> Dictionary:\n\tvar updated_summary := result_summary.duplicate(true)\n\tvar explicit_result := _apply_explicit_battle_hero_outcomes(result_payload)\n\tif bool(explicit_result.get("has_explicit_data", false)):\n\t\tupdated_summary["hero_state_result"] = explicit_result\n\t\t_append_hero_state_result_lines(updated_summary)\n\t\tprint("[T06_9_HERO_OUTCOMES] wounded=%s normal=%s skipped=%s" % [\n\t\t\tstr(explicit_result.get("wounded_hero_ids", [])),\n\t\t\tstr(explicit_result.get("normal_hero_ids", [])),\n\t\t\tstr(explicit_result.get("skipped_hero_ids", [])),\n\t\t])\n\t\treturn updated_summary\n'''
if old not in world:
    raise SystemExit('hero placeholder function anchor missing')
world = world.replace(old, new, 1)

battle_path.write_text(battle, encoding='utf-8')
world_path.write_text(world, encoding='utf-8')
print('T06-9 hero data parity patch applied')
