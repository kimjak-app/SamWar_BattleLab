"""Exact, reviewable deltas approved after the WorldMap warning-cleanup checkpoint.

The checkpoint-style guards (diplomacy routing, AF-1 settlement) deliberately compare
files byte-for-byte against an approved commit. P-1C/P-1D then changed two files on
purpose. Instead of relaxing those guards, the new state is pinned to a commit AND the
exact line delta between the old approved state and the new one is spelled out here,
so any further drift still fails.

Regenerate only with a reviewed, intentional change:
    delta = line_delta(git_show(OLD, path), git_show(NEW, path))
"""

import difflib
import subprocess

WARNING_CLEANUP_CHECKPOINT = "c098fb7e92006103c630aefb20b99067e2822caf"

# Last commit that touched worldmap_main.gd on the P-1 line (P-1D retreat label hotfix).
P1_MAIN_CHECKPOINT = "9b2cd8ee6d5ab2aac1071af8e43ed5f7360bde2d"
# Last commit that touched battle_settlement_applier.gd on the P-1 line (P-1D hotfix).
P1D_SETTLEMENT_CHECKPOINT = "f1f3fde1e0698a94e1de29fdeb942ab96e4c2226"

EXPECTED_P1_MAIN_DELTA = ['-const WORLDMAP_BATTLE_SCENE_PATH := "res://Battle_Land.tscn"',
 '+const WORLDMAP_BATTLE_SCENE_PATH := "res://scenes/battle/Battle_Main.tscn"',
 '-\tvar attacker_won := str(plan.get("result_kind", "")) == INVASION_RESULT_ATTACKER_WIN',
 '-\tvar outcome_label := "점령 성공" if attacker_won else ("30턴 제한 패배" if '
 'str(result.get("result_reason", "")) == "turn_limit" else "공격 패배")',
 '+\tvar result_kind := str(plan.get("result_kind", ""))',
 '+\tvar attacker_won := result_kind == INVASION_RESULT_ATTACKER_WIN',
 '+\tvar outcome_label := "점령 성공" if attacker_won else ("후퇴" if result_kind == '
 'INVASION_RESULT_RETREAT or str(result.get("result_reason", "")) == "retreat" else ("30턴 제한 패배" '
 'if str(result.get("result_reason", "")) == "turn_limit" else "공격 패배"))',
 '+\t_refresh_territory_overlay_if_present()',
 '+',
 '+',
 '+func _refresh_territory_overlay_if_present() -> void:',
 '+\tvar territory := get_node_or_null("WorldMapTerritoryController")',
 '+\tif territory != null and territory.has_method("refresh_territory_data"):',
 '+\t\tterritory.call_deferred("refresh_territory_data")',
 '+\t_refresh_worldmap_tech_badge_summary_if_present()',
 '+',
 '+',
 '+func _refresh_worldmap_tech_badge_summary_if_present() -> void:',
 '+\tvar badges := get_node_or_null("WorldMapTechBadgeSummaryController")',
 '+\tif badges != null and badges.has_method("refresh_from_runtime"):',
 '+\t\tbadges.call_deferred("refresh_from_runtime")',
 '+\t_refresh_worldmap_tech_badge_summary_if_present()',
 '+\t_refresh_territory_overlay_if_present()']

EXPECTED_P1D_SETTLEMENT_DELTA = ['-\tif result_kind == RESULT_RETREAT:',
 '+\tif result_kind == RESULT_RETREAT and str(plan.get("settlement_profile", "standard")) != '
 '"t02_return":',
 '+\telif not attacker_won:',
 '+\t\tvar defending_wounded := maxi(0, int(troop_plan.get("defender_wounded", 0)))',
 '+\t\tif defending_wounded > 0:',
 '+\t\t\t_m("add_wounded", [target_city_id, defending_wounded, '
 'int(_config.get("normal_wounded_turns", 3)), "normal", str(plan.get("transaction_id", ""))], '
 'null)',
 '+\t\t\treport["troop_changes"].append({"city_id": target_city_id, "wounded_added": '
 'defending_wounded})',
 '-\tif str(plan.get("result_kind", "")) == RESULT_ATTACKER_WIN:',
 '+\tif str(plan.get("result_kind", "")) == RESULT_ATTACKER_WIN or '
 'str(plan.get("settlement_profile", "standard")) == "t02_return":']


# Queue 36 STOCK-AUTHORITY-P0 (Kim approved re-pin 11-27): the code commit that made each city's resource_stock the only
# stock ledger. worldmap_main.gd must equal that commit and differ from P1_MAIN_CHECKPOINT by exactly
# EXPECTED_P0_STOCK_MAIN_DELTA. Other files the same commit changed on purpose, which older guards freeze byte for byte,
# are listed in EXPECTED_P0_STOCK_FROZEN_DELTAS: path -> exact delta from the text such a guard expects.
# Empty checkpoint = no approved P0 state yet (only the P-1 state is accepted).
P0_STOCK_CHECKPOINT = "e206d60678196550a4763906456bbc0ce11a67a4"
EXPECTED_P0_STOCK_MAIN_DELTA: list[str] = ['+const STOCK_LEDGER_VERSION := "resource_stock_v1"',
 '-\t\t\t_player_state["resource_stock"] = (args[0] as Dictionary).duplicate(true)',
 '+\t\t\t# Queue 36: both national caches hold the same live owned-city sum the warehouse window reads.',
 '+\t\t\tvar national := _get_player_national_resource_stock_mvp()',
 '+\t\t\t_player_state["resource_stock"] = national.duplicate(true)',
 '+\t\t\tvar aggregation: Dictionary = _player_state.get("national_aggregation", {}) if '
 '_player_state.get("national_aggregation", {}) is Dictionary else {}',
 '+\t\t\taggregation["resources"] = national.duplicate(true)',
 '+\t\t\t_player_state["national_aggregation"] = aggregation',
 '+\t\t"national_resource_stock":',
 '+\t\t\treturn _get_player_national_resource_stock_mvp().duplicate(true)',
 '+\t\t"charge_national_city_stock":',
 '+\t\t\treturn bool(_commit_national_city_stock_payment_mvp((args[0] as Dictionary).duplicate(true)).get("ok", '
 'false))',
 '-\tmutable_city_state["storage"] = _ensure_city_resource_service().ensure_city_storage_keys(storage)',
 '+\tmutable_city_state["resource_stock"] = _ensure_city_resource_service().ensure_city_storage_keys(storage)',
 '+\t_sync_player_resource_compatibility_from_city_stock_mvp()',
 '-\tvar resource_stock: Dictionary = _player_state.get("resource_stock", {})',
 '+\tvar resource_stock := _get_player_national_resource_stock_mvp()',
 '-\tvar city_ids: Array[String] = []',
 '-\tfor city_id_variant in _city_runtime_states.keys():',
 '-\t\tvar city_id := str(city_id_variant)',
 '-\t\tif _get_city_owner_id_for_battle_context(city_id) == _get_current_player_faction_id():',
 '-\t\t\tcity_ids.append(city_id)',
 '-\tcity_ids.sort()',
 '+\tvar city_ids := _get_player_city_ids_for_national_stock_mvp()',
 '-\tvar resource_stock: Dictionary = _player_state.get("resource_stock", {})',
 '+\tvar resource_stock := _get_player_national_resource_stock_mvp()',
 '+# Queue 36: a national cost is paid out of the owned cities (capital first, then by city id; "food" = rice, barley,',
 '+# seafood in that order). All or nothing: if any item is short, no city stock changes and every paid amount is 0.',
 '-\tvar resource_stock: Dictionary = _player_state.get("resource_stock", {}).duplicate(true)',
 '-\tvar before_stock := resource_stock.duplicate(true)',
 '+\tvar before_stock := _get_player_national_resource_stock_mvp().duplicate(true)',
 '+\tvar payment := _plan_national_city_stock_payment_mvp(cost)',
 '+\tvar plan: Dictionary = payment.get("plan", {}) if bool(payment.get("ok", false)) else {}',
 '+\tvar paid_by_resource := {}',
 '+\tfor raw_city_id in plan:',
 '+\t\tfor raw_resource_id in (plan[raw_city_id] as Dictionary):',
 '+\t\t\tpaid_by_resource[str(raw_resource_id)] = int(paid_by_resource.get(str(raw_resource_id), 0)) + '
 'int((plan[raw_city_id] as Dictionary).get(raw_resource_id, 0))',
 '-\t\tvar required_amount := maxi(0, int(cost.get(resource_id_variant, 0)))',
 '-\t\t\tvar remaining_food := required_amount',
 '-\t\t\t\tvar food_before_amount := maxi(0, int(resource_stock.get(food_resource_id, 0)))',
 '-\t\t\t\tvar food_paid_amount := mini(food_before_amount, remaining_food)',
 '-\t\t\t\tresource_stock[food_resource_id] = food_before_amount - food_paid_amount',
 '-\t\t\t\tremaining_food -= food_paid_amount',
 '-\t\t\t\tfood_paid[food_resource_id] = food_paid_amount',
 '+\t\t\t\tfood_paid[food_resource_id] = int(paid_by_resource.get(food_resource_id, 0))',
 '-\t\tvar before_amount := maxi(0, int(resource_stock.get(resource_id, 0)))',
 '-\t\tvar paid_amount := mini(before_amount, required_amount)',
 '-\t\tresource_stock[resource_id] = before_amount - paid_amount',
 '-\t\tpaid[resource_id] = paid_amount',
 '-\t_player_state["resource_stock"] = resource_stock',
 '+\t\tpaid[resource_id] = int(paid_by_resource.get(resource_id, 0))',
 '+\tif not plan.is_empty():',
 '+\t\t_commit_city_stock_payment_plan_mvp(payment)',
 '-\t\t"after": resource_stock.duplicate(true),',
 '+\t\t"after": _get_player_national_resource_stock_mvp().duplicate(true),',
 '-\tvar resource_stock: Dictionary = _player_state.get("resource_stock", {})',
 '+\tvar resource_stock := _get_player_national_resource_stock_mvp()',
 '-\tvar resource_stock: Dictionary = _player_state.get("resource_stock", {})',
 '+\tvar resource_stock := _get_player_national_resource_stock_mvp()',
 '+\t\t"stock_ledger": STOCK_LEDGER_VERSION,',
 '-\t_apply_worldmap_city_runtime_state(data.get("worldmap_city_state", {}))',
 '+\t_apply_worldmap_city_runtime_state(data.get("worldmap_city_state", {}), str(data.get("stock_ledger", "")) != '
 'STOCK_LEDGER_VERSION)',
 '-\tif not mutable_city_state.has("storage") or not (mutable_city_state["storage"] is Dictionary):',
 '-\t\tmutable_city_state["storage"] = _build_default_city_storage(city_id, mutable_city_state)',
 '-\telse:',
 '-\t\tmutable_city_state["storage"] = _normalize_city_storage(mutable_city_state.get("storage"))',
 '-\t\tif source.has("storage") and source.get("storage") is Dictionary:',
 '-\t\t\tcity_payload["storage"] = _normalize_city_storage(source.get("storage"))',
 '-func _apply_worldmap_city_runtime_state(raw_state: Variant) -> void:',
 '+func _apply_worldmap_city_runtime_state(raw_state: Variant, legacy_stock_ledger: bool = false) -> void:',
 '-\t\tif source.has("storage") and source.get("storage") is Dictionary:',
 '-\t\t\tcity_state["storage"] = _normalize_city_storage(source.get("storage"))',
 '-\t\telse:',
 '-\t\t\tcity_state["storage"] = _build_default_city_storage(city_id, city_state)',
 '+\t\tif legacy_stock_ledger and source.get("storage") is Dictionary:',
 '+\t\t\t# Queue 36 option A: an old save keeps only resource_stock; the separate storage ledger is dropped, not '
 'added.',
 '+\t\t\tprint("[STOCK_MIGRATION] city=%s dropped_storage=%s" % [city_id, str(source.get("storage"))])',
 '-\tvar aggregation: Variant = _player_state.get("national_aggregation", {})',
 '-\tif aggregation is Dictionary and (aggregation as Dictionary).get("resources", {}) is Dictionary:',
 '-\t\treturn ((aggregation as Dictionary).get("resources", {}) as Dictionary)',
 '-\treturn _player_state.get("resource_stock", {})',
 '-',
 '-',
 '+\t# Queue 36: computed from the owned cities every time; national_aggregation / resource_stock are only caches.',
 '+\treturn _sum_city_resource_stocks_mvp(_get_player_city_ids_for_national_stock_mvp())',
 '+',
 '+',
 "+# Queue 36 (STOCK-AUTHORITY-P0): the national stock is only the sum of the owned cities' resource_stock. Same owner",
 '+# test as _rebuild_occupation_runtime_indexes_mvp.',
 '+func _get_player_city_ids_for_national_stock_mvp() -> Array[String]:',
 '+\tvar player_cities: Array[String] = []',
 '+\tfor city_id_variant in CITY_HUD_DATA.keys():',
 '+\t\tvar city_id := str(city_id_variant)',
 '+\t\tif _get_city_owner_id_for_battle_context(city_id) == _get_current_player_faction_id():',
 '+\t\t\tplayer_cities.append(city_id)',
 '+\tplayer_cities.sort()',
 '+\treturn player_cities',
 '+',
 '+',
 '+func _sum_city_resource_stocks_mvp(city_ids: Array[String]) -> Dictionary:',
 '+\tvar resources := {}',
 '+\tfor city_id in city_ids:',
 '+\t\tvar stock: Variant = _get_city_hud_entry(city_id).get("resource_stock", {})',
 '+\t\tif stock is Dictionary:',
 '+\t\t\tfor resource_id in (stock as Dictionary).keys():',
 '+\t\t\t\tresources[str(resource_id)] = int(resources.get(str(resource_id), 0)) + maxi(0, int((stock as '
 'Dictionary).get(resource_id, 0)))',
 '+\treturn resources',
 '+',
 '+',
 '+# Queue 36: the city "storage" ledger is gone. This adapter name stays for the trade / research / UI services and',
 "+# returns the city's resource_stock (supply defaults ensured) with the 9 resource keys.",
 '-\tif source_data.is_empty() and not city_id.is_empty():',
 '+\tif not city_id.is_empty():',
 '+\t\t_ensure_city_supply_resource_defaults(city_id)',
 '-\tvar player_resource_stock: Dictionary = _player_state.get("resource_stock", {}) if '
 '_player_state.get("resource_stock", {}) is Dictionary else {}',
 '-\tvar storage := _ensure_city_resource_service().get_city_storage(city_id, source_data, player_resource_stock)',
 '-\tif not city_id.is_empty():',
 '-\t\tvar runtime_state := _get_mutable_city_runtime_state(city_id)',
 '-\t\tif not runtime_state.is_empty():',
 '-\t\t\truntime_state["storage"] = storage.duplicate(true)',
 '-\t\t\t_city_runtime_states[city_id] = runtime_state',
 '-\treturn storage',
 '-',
 '-',
 '-func _normalize_city_storage(raw_storage: Variant) -> Dictionary:',
 '-\treturn _ensure_city_resource_service().normalize_city_storage(raw_storage)',
 '-',
 '-',
 '-func _build_default_city_storage(city_id: String, _city_data: Dictionary) -> Dictionary:',
 '-\tvar player_resource_stock: Dictionary = _player_state.get("resource_stock", {}) if '
 '_player_state.get("resource_stock", {}) is Dictionary else {}',
 '-\treturn _ensure_city_resource_service().build_default_city_storage(city_id, player_resource_stock)',
 '+\treturn _ensure_city_resource_service().get_city_storage(source_data)']
EXPECTED_P0_STOCK_FROZEN_DELTAS: dict[str, list[str]] = {'scripts/worldmap/actions/diplomacy_action_service.gd': ['+\t# Queue 36: the live host pays national costs out of the '
                                                          'owned cities; the code below is the plain-host fallback.',
                                                          '+\tif host.has_method("_can_pay_national_city_stock_cost"):',
                                                          '+\t\treturn host.call("_can_pay_national_city_stock_cost", '
                                                          'cost)',
                                                          '+\tif host.has_method("_pay_national_city_stock_cost"):',
                                                          '+\t\treturn host.call("_pay_national_city_stock_cost", '
                                                          'cost)'],
 'tests/scripts/test_worldmap_diplomacy_alliance_extraction.gd': ['-\t_worldmap.set("_player_state", state)',
                                                                  '+\t_set_state(state)',
                                                                  '-\t_worldmap.set("_player_state", state)',
                                                                  '+\t_set_state(state)',
                                                                  '-\t_worldmap.set("_player_state", '
                                                                  'before.duplicate(true))',
                                                                  '+\t_set_state(before.duplicate(true))',
                                                                  '-\t_worldmap.set("_player_state", '
                                                                  'before.duplicate(true))',
                                                                  '+\t_set_state(before.duplicate(true))',
                                                                  '-\t_worldmap.set("_player_state", state)',
                                                                  '+\t_set_state(state)',
                                                                  '-\t_worldmap.set("_player_state", state)',
                                                                  '+\t_set_state(state)',
                                                                  '-\t_worldmap.set("_player_state", '
                                                                  'before_sync.duplicate(true))',
                                                                  '+\t_set_state(before_sync.duplicate(true))',
                                                                  '+',
                                                                  '+# Queue 36 (STOCK-AUTHORITY-P0): the national '
                                                                  "stock is only the sum of the owned cities' "
                                                                  'resource_stock, so the stock a',
                                                                  '+# test puts in _player_state is seeded into the '
                                                                  'first national payment city (the capital) and the '
                                                                  'other owned cities',
                                                                  '+# are emptied. A state reset therefore resets the '
                                                                  'city stock too.',
                                                                  '+func _set_state(state: Dictionary) -> void:',
                                                                  '+\t_worldmap.set("_player_state", state)',
                                                                  '+\tvar stock: Dictionary = '
                                                                  '(state.get("resource_stock", {}) as '
                                                                  'Dictionary).duplicate(true) if '
                                                                  'state.get("resource_stock", {}) is Dictionary else '
                                                                  '{}',
                                                                  '+\tvar city_ids: Array = '
                                                                  '_worldmap.call("_get_national_payment_city_ids_mvp")',
                                                                  '+\tfor index in city_ids.size():',
                                                                  '+\t\t_worldmap.call("_set_city_storage", '
                                                                  'str(city_ids[index]), stock if index == 0 else {})',
                                                                  '+'],
 'tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd': ['-\t_worldmap.set("_player_state", state)',
                                                                  '+\t_set_state(state)',
                                                                  '-\t_worldmap.set("_player_state", '
                                                                  'before.duplicate(true))',
                                                                  '+\t_set_state(before.duplicate(true))',
                                                                  '-\t_worldmap.set("_player_state", '
                                                                  'before.duplicate(true))',
                                                                  '+\t_set_state(before.duplicate(true))',
                                                                  '-\t_worldmap.set("_player_state", '
                                                                  'before.duplicate(true))',
                                                                  '+\t_set_state(before.duplicate(true))',
                                                                  '+',
                                                                  '+# Queue 36 (STOCK-AUTHORITY-P0): the national '
                                                                  "stock is only the sum of the owned cities' "
                                                                  'resource_stock, so the stock a',
                                                                  '+# test puts in _player_state is seeded into the '
                                                                  'first national payment city (the capital) and the '
                                                                  'other owned cities',
                                                                  '+# are emptied. A state reset therefore resets the '
                                                                  'city stock too.',
                                                                  '+func _set_state(state: Dictionary) -> void:',
                                                                  '+\t_worldmap.set("_player_state", state)',
                                                                  '+\tvar stock: Dictionary = '
                                                                  '(state.get("resource_stock", {}) as '
                                                                  'Dictionary).duplicate(true) if '
                                                                  'state.get("resource_stock", {}) is Dictionary else '
                                                                  '{}',
                                                                  '+\tvar city_ids: Array = '
                                                                  '_worldmap.call("_get_national_payment_city_ids_mvp")',
                                                                  '+\tfor index in city_ids.size():',
                                                                  '+\t\t_worldmap.call("_set_city_storage", '
                                                                  'str(city_ids[index]), stock if index == 0 else {})',
                                                                  '+'],
 'tests/scripts/test_worldmap_diplomacy_routing.gd': ['-\t_worldmap.set("_player_state", state)',
                                                      '+\t_set_state(state)',
                                                      '-\t_worldmap.set("_player_state", before.duplicate(true))',
                                                      '+\t_set_state(before.duplicate(true))',
                                                      '-\t_worldmap.get("_player_state")["resource_stock"]["gold"] = 0',
                                                      '+\t_set_national_gold(0)',
                                                      '+',
                                                      '+# Queue 36 (STOCK-AUTHORITY-P0): the national stock is only '
                                                      "the sum of the owned cities' resource_stock, so the stock a",
                                                      '+# test puts in _player_state is seeded into the first national '
                                                      'payment city (the capital) and the other owned cities',
                                                      '+# are emptied. A state reset therefore resets the city stock '
                                                      'too.',
                                                      '+func _set_state(state: Dictionary) -> void:',
                                                      '+\t_worldmap.set("_player_state", state)',
                                                      '+\tvar stock: Dictionary = (state.get("resource_stock", {}) as '
                                                      'Dictionary).duplicate(true) if state.get("resource_stock", {}) '
                                                      'is Dictionary else {}',
                                                      '+\tvar city_ids: Array = '
                                                      '_worldmap.call("_get_national_payment_city_ids_mvp")',
                                                      '+\tfor index in city_ids.size():',
                                                      '+\t\t_worldmap.call("_set_city_storage", str(city_ids[index]), '
                                                      'stock if index == 0 else {})',
                                                      '+',
                                                      '+',
                                                      '+# Queue 36: set the national gold through the cities (capital '
                                                      'gets the amount, the other owned cities 0).',
                                                      '+func _set_national_gold(gold: int) -> void:',
                                                      '+\tvar city_ids: Array = '
                                                      '_worldmap.call("_get_national_payment_city_ids_mvp")',
                                                      '+\tfor index in city_ids.size():',
                                                      '+\t\tvar stock: Dictionary = '
                                                      '_worldmap.call("_get_city_storage", str(city_ids[index]))',
                                                      '+\t\tstock["gold"] = gold if index == 0 else 0',
                                                      '+\t\t_worldmap.call("_set_city_storage", str(city_ids[index]), '
                                                      'stock)',
                                                      '+'],
 'tests/scripts/test_worldmap_diplomacy_state_extraction.gd': ['-\t_worldmap.set("_player_state", state)',
                                                               '+\t_set_state(state)',
                                                               '-\t_worldmap.set("_player_state", state)',
                                                               '+\t_set_state(state)',
                                                               '-\t_worldmap.set("_player_state", '
                                                               'before.duplicate(true))',
                                                               '+\t_set_state(before.duplicate(true))',
                                                               '-\t_worldmap.set("_player_state", state)',
                                                               '+\t_set_state(state)',
                                                               '-\t_worldmap.set("_player_state", '
                                                               'before.duplicate(true))',
                                                               '+\t_set_state(before.duplicate(true))',
                                                               '+',
                                                               '+# Queue 36 (STOCK-AUTHORITY-P0): the national stock '
                                                               "is only the sum of the owned cities' resource_stock, "
                                                               'so the stock a',
                                                               '+# test puts in _player_state is seeded into the first '
                                                               'national payment city (the capital) and the other '
                                                               'owned cities',
                                                               '+# are emptied. A state reset therefore resets the '
                                                               'city stock too.',
                                                               '+func _set_state(state: Dictionary) -> void:',
                                                               '+\t_worldmap.set("_player_state", state)',
                                                               '+\tvar stock: Dictionary = '
                                                               '(state.get("resource_stock", {}) as '
                                                               'Dictionary).duplicate(true) if '
                                                               'state.get("resource_stock", {}) is Dictionary else {}',
                                                               '+\tvar city_ids: Array = '
                                                               '_worldmap.call("_get_national_payment_city_ids_mvp")',
                                                               '+\tfor index in city_ids.size():',
                                                               '+\t\t_worldmap.call("_set_city_storage", '
                                                               'str(city_ids[index]), stock if index == 0 else {})',
                                                               '+'],
 'tests/scripts/test_worldmap_diplomacy_validation_extraction.gd': ['-\t_worldmap.set("_player_state", state)',
                                                                    '+\t_set_state(state)',
                                                                    '+',
                                                                    '+# Queue 36 (STOCK-AUTHORITY-P0): the national '
                                                                    "stock is only the sum of the owned cities' "
                                                                    'resource_stock, so the stock a',
                                                                    '+# test puts in _player_state is seeded into the '
                                                                    'first national payment city (the capital) and the '
                                                                    'other owned cities',
                                                                    '+# are emptied. A state reset therefore resets '
                                                                    'the city stock too.',
                                                                    '+func _set_state(state: Dictionary) -> void:',
                                                                    '+\t_worldmap.set("_player_state", state)',
                                                                    '+\tvar stock: Dictionary = '
                                                                    '(state.get("resource_stock", {}) as '
                                                                    'Dictionary).duplicate(true) if '
                                                                    'state.get("resource_stock", {}) is Dictionary '
                                                                    'else {}',
                                                                    '+\tvar city_ids: Array = '
                                                                    '_worldmap.call("_get_national_payment_city_ids_mvp")',
                                                                    '+\tfor index in city_ids.size():',
                                                                    '+\t\t_worldmap.call("_set_city_storage", '
                                                                    'str(city_ids[index]), stock if index == 0 else '
                                                                    '{})',
                                                                    '+']}


def line_delta(old_text: str, new_text: str) -> list[str]:
    return [
        line
        for line in difflib.unified_diff(old_text.split("\n"), new_text.split("\n"), lineterm="", n=0)
        if not line.startswith(("---", "+++", "@@"))
    ]


def git_show_text(root, commit: str, path: str) -> str:
    return subprocess.check_output(["git", "show", f"{commit}:{path}"], cwd=root).decode("utf-8").replace("\r\n", "\n")


def assert_main_is_approved_p1_state(root, current_main: str, warning_cleanup_main: str, main_path: str) -> None:
    p1_main = git_show_text(root, P1_MAIN_CHECKPOINT, main_path)
    assert line_delta(warning_cleanup_main, p1_main) == EXPECTED_P1_MAIN_DELTA, (
        "P-1 worldmap_main.gd delta no longer matches the approved exact delta"
    )
    approved_main = git_show_text(root, P0_STOCK_CHECKPOINT, main_path) if P0_STOCK_CHECKPOINT else p1_main
    assert current_main == approved_main, (
        "worldmap_main.gd changed after the approved P-1/P0-stock checkpoint; review a new exact delta "
        "instead of relaxing the guard"
    )
    if P0_STOCK_CHECKPOINT:
        assert line_delta(p1_main, approved_main) == EXPECTED_P0_STOCK_MAIN_DELTA, (
            "P0-stock worldmap_main.gd delta no longer matches the approved exact delta"
        )


def frozen_text_matches(root, path: str, expected_text: str, current_text: str) -> bool:
    """A frozen file equals what its guard expects, after the approved stages in order: each stage that lists the path
    must be reached by exactly its approved delta (queue 36 P0-stock, then queue 38 P1-strategy)."""
    current_text = current_text.replace("\r\n", "\n")
    approved_text = expected_text
    for checkpoint, deltas in _approved_frozen_stages():
        if not checkpoint or path not in deltas:
            continue
        stage_text = git_show_text(root, checkpoint, path)
        if line_delta(approved_text, stage_text) != deltas[path]:
            return False
        approved_text = stage_text
    return current_text == approved_text


# Queue 38 STRATEGY-P1 (Kim approved 11-27, re-pin allowed): the code commit that added the strategy request ledger.
# Frozen files it changed on purpose: path -> exact delta from the P0-stock text (or from the guard's text when the
# file has no P0 stage). Controller functions it changed on purpose, which a guard freezes function by function:
# path -> {function name -> exact delta of the normalized body}. Empty checkpoint = no approved P1 state yet.
P1_STRATEGY_CHECKPOINT = "45ee6d9565bec6c8493a375bd86214be593d6290"
EXPECTED_P1_STRATEGY_FROZEN_DELTAS: dict[str, list[str]] = {'scripts/worldmap/actions/diplomacy_action_service.gd': ['-\t_source_city_id: String = ""',
                                                          '+\t_source_city_id: String = "",',
                                                          '+\tprepaid_payment: Dictionary = {}',
                                                          "+\t# Queue 38: prepaid_payment = a strategy request's own "
                                                          'reservation (cost already taken out of the cities when it',
                                                          '+\t# was submitted). With it, the payment check passes and '
                                                          'nothing is charged again; everything else is unchanged.',
                                                          '+\tif not prepaid_payment.is_empty():',
                                                          '+\t\t(context_variant as Dictionary)["payment_check"] = '
                                                          '{"ok": true, "prepaid": true}',
                                                          '-\tvar payment_result := '
                                                          'apply_diplomacy_resource_cost(host, cost)',
                                                          '+\tvar payment_result := prepaid_payment if not '
                                                          'prepaid_payment.is_empty() else '
                                                          'apply_diplomacy_resource_cost(host, cost)'],
 'tests/scripts/test_worldmap_diplomacy_mutation_extraction.gd': ['+const Strategy := '
                                                                  'preload("res://scripts/worldmap/actions/strategy_request_service.gd")  '
                                                                  '# queue 38: player diplomacy is submitted (T) and '
                                                                  'resolved at the turn end',
                                                                  '-\tvar direct: Dictionary = '
                                                                  '_service.call("execute", '
                                                                  '_worldmap.call("_ensure_diplomacy_controller"), '
                                                                  'action_id, _foreign_city_id)',
                                                                  '+\tvar direct: Dictionary = '
                                                                  'Strategy.submit_player_diplomacy(_worldmap.call("_ensure_diplomacy_controller"), '
                                                                  'action_id, _foreign_city_id)'],
 'tests/scripts/test_worldmap_diplomacy_routing.gd': ['+const Strategy := '
                                                      'preload("res://scripts/worldmap/actions/strategy_request_service.gd")  '
                                                      '# queue 38: player diplomacy is submitted (T) and resolved at '
                                                      'the turn end',
                                                      '-\tvar service_result: Dictionary = _service.call("execute", '
                                                      '_worldmap.call("_ensure_diplomacy_controller"), action, '
                                                      '_target)',
                                                      '+\tvar service_result: Dictionary = '
                                                      'Strategy.submit_player_diplomacy(_worldmap.call("_ensure_diplomacy_controller"), '
                                                      'action, _target)',
                                                      '-\t\t_parity("alliance_proposal", faction, 0, "neutral", 10000, '
                                                      '0, false)',
                                                      '+\t\t_parity("alliance_proposal", faction, 0, "neutral", 10000, '
                                                      '0, true)  # queue 38: submitted; acceptance is judged at the '
                                                      'turn end'],
 'tests/scripts/test_worldmap_diplomacy_state_extraction.gd': ['+const Strategy := '
                                                               'preload("res://scripts/worldmap/actions/strategy_request_service.gd")  '
                                                               '# queue 38: player diplomacy is submitted (T) and '
                                                               'resolved at the turn end',
                                                               '-\tvar direct: Dictionary = _service.call("execute", '
                                                               '_worldmap.call("_ensure_diplomacy_controller"), '
                                                               '"trade_agreement", city_id)',
                                                               '+\tvar direct: Dictionary = '
                                                               'Strategy.submit_player_diplomacy(_worldmap.call("_ensure_diplomacy_controller"), '
                                                               '"trade_agreement", city_id)']}
EXPECTED_P1_STRATEGY_FUNCTION_DELTAS: dict[str, dict[str, list[str]]] = {'scripts/worldmap/actions/diplomacy_controller.gd': {'execute': ['-(action_id: String, target_city_id: String = "", '
                                                                  'source_city_id: String = "") -> Dictionary:',
                                                                  '-\treturn _service.execute(self, action_id, '
                                                                  'target_city_id, source_city_id)',
                                                                  '+(action_id: String, target_city_id: String = "", '
                                                                  '_source_city_id: String = "") -> Dictionary:',
                                                                  '+\treturn '
                                                                  'StrategyRequestServiceScript.submit_player_diplomacy(self, '
                                                                  'action_id, target_city_id)']}}


def _approved_frozen_stages():
    return [
        (P0_STOCK_CHECKPOINT, EXPECTED_P0_STOCK_FROZEN_DELTAS),
        (P1_STRATEGY_CHECKPOINT, EXPECTED_P1_STRATEGY_FROZEN_DELTAS),
    ]


def approved_function_body(root, path: str, name: str, baseline_body: str, functions_of):
    """The body a guard must see for a frozen function: the baseline, or (queue 38) the P1-strategy commit's body when
    that commit changed it by exactly the approved delta. Returns None when the approved delta no longer matches."""
    changed = EXPECTED_P1_STRATEGY_FUNCTION_DELTAS.get(path, {})
    if not P1_STRATEGY_CHECKPOINT or name not in changed:
        return baseline_body
    stage_body = functions_of(git_show_text(root, P1_STRATEGY_CHECKPOINT, path)).get(name)
    if stage_body is None or line_delta(baseline_body, stage_body) != changed[name]:
        return None
    return stage_body


def assert_settlement_is_approved_p1d_state(root, current_bytes: bytes, af1_expected_bytes: bytes, path: str) -> None:
    p1d_text = git_show_text(root, P1D_SETTLEMENT_CHECKPOINT, path)
    assert current_bytes.decode("utf-8").replace("\r\n", "\n") == p1d_text, (
        "battle settlement changed beyond the approved AF-1 rename + P-1D retreat/defender-wounded delta"
    )
    af1_text = af1_expected_bytes.decode("utf-8").replace("\r\n", "\n")
    assert line_delta(af1_text, p1d_text) == EXPECTED_P1D_SETTLEMENT_DELTA, (
        "P-1D settlement delta no longer matches the approved exact delta"
    )
