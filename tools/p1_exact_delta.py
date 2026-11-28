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


# Queue 39 CITIES65 0.7 (Kim approved 11-27, re-pin allowed): the code commit that added the 52 unclaimed cities.
# worldmap_main.gd must equal that commit and differ from the P0-stock text by exactly this delta (CITY_HUD_DATA rows,
# 상도 name, the roster call). Empty checkpoint = not approved yet.
CITIES65_CHECKPOINT = "215de311b325c15d49f6c7d394f562ef797c246d"
EXPECTED_CITIES65_MAIN_DELTA: list[str] = ['-\t"pyeongyang": {"id": "pyeongyang", "name": "평양", "owner": "goguryeo", "nation": "goguryeo", "region": "한반도", '
 '"region_key": "region.korean_peninsula", "type": "production_city", "population": 42000, "population_rating": 3, '
 '"commerce_rating": 3, "gold": 420, "food": 512, "troops": 280, "public_order": 66, "commerce": 42, "agriculture": '
 '68, "defense": 3, "governor_id": "gwanggaeto", "governor_policy_id": "military", "stationed_hero_ids": '
 '["gwanggaeto", "eulji_mundeok", "dorim", "cheok_jun_gyeong"], "hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim", '
 '"cheok_jun_gyeong"], "loyalty": 72, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★★★ / 철 ★★ / 말 ★★★ / 비단 ★ / 소금 ★", '
 '"military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 한성-카라코룸 연결 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 '
 '420", "resource_seed": {"rice": 3, "barley": 3, "seafood": 1, "wood": 3, "iron": 2, "horses": 3, "silk": 1, "salt": '
 '1, "gold": 420, "specialty": 1}, "domestic_seed": {"publicSupport": 62, "publicOrder": 66, "agriculture": 68, '
 '"commerce": 42, "stability": 58}, "yield_seed": {"riceHarvest": 340, "barleyHarvest": 160, "seafoodPerTurn": 12, '
 '"commerceIncome": 90, "specialtyIncome": 260}},',
 '-\t"karakorum": {"id": "karakorum", "name": "카라코룸", "owner": "mongol_faction", "nation": "mongol_faction", "region": '
 '"북방초원", "region_key": "region.northern_steppe", "type": "military_fortress", "population": 36000, '
 '"population_rating": 3, "commerce_rating": 2, "gold": 620, "food": 380, "troops": 460, "public_order": 74, '
 '"commerce": 44, "agriculture": 42, "defense": 4, "governor_id": "genghis_khan", "governor_policy_id": "military", '
 '"stationed_hero_ids": ["genghis_khan", "subutai", "jebe"], "hero_ids": ["genghis_khan", "subutai", "jebe"], '
 '"loyalty": 78, "resources": "쌀 ★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★ / 말 ★★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 '
 '460 / 치안 기준 900 / 방어력 4", "trade": "내부 교역로: 평양-업성 북방 연결", "rating": "인구 ★★★ · 상업력 ★★ · 금전 620", "resource_seed": '
 '{"rice": 1, "barley": 4, "seafood": 0, "wood": 2, "iron": 4, "horses": 5, "silk": 2, "salt": 1, "gold": 620, '
 '"specialty": 2}, "domestic_seed": {"publicSupport": 68, "publicOrder": 74, "agriculture": 42, "commerce": 44, '
 '"stability": 70}, "yield_seed": {"riceHarvest": 160, "barleyHarvest": 220, "seafoodPerTurn": 0, "commerceIncome": '
 '105, "specialtyIncome": 360}},',
 '+\t"pyeongyang": {"id": "pyeongyang", "name": "평양", "owner": "goguryeo", "nation": "goguryeo", "region": "한반도", '
 '"region_key": "region.korean_peninsula", "type": "production_city", "population": 42000, "population_rating": 3, '
 '"commerce_rating": 3, "gold": 420, "food": 512, "troops": 280, "public_order": 66, "commerce": 42, "agriculture": '
 '68, "defense": 3, "governor_id": "gwanggaeto", "governor_policy_id": "military", "stationed_hero_ids": '
 '["gwanggaeto", "eulji_mundeok", "dorim", "cheok_jun_gyeong"], "hero_ids": ["gwanggaeto", "eulji_mundeok", "dorim", '
 '"cheok_jun_gyeong"], "loyalty": 72, "resources": "쌀 ★★★ / 보리 ★★★ / 수산물 ★ / 목재 ★★★ / 철 ★★ / 말 ★★★ / 비단 ★ / 소금 ★", '
 '"military": "도시 주둔군 280 / 치안 기준 500 / 방어력 3", "trade": "내부 교역로: 한성-상도 연결 후보", "rating": "인구 ★★★ · 상업력 ★★★ · 금전 420", '
 '"resource_seed": {"rice": 3, "barley": 3, "seafood": 1, "wood": 3, "iron": 2, "horses": 3, "silk": 1, "salt": 1, '
 '"gold": 420, "specialty": 1}, "domestic_seed": {"publicSupport": 62, "publicOrder": 66, "agriculture": 68, '
 '"commerce": 42, "stability": 58}, "yield_seed": {"riceHarvest": 340, "barleyHarvest": 160, "seafoodPerTurn": 12, '
 '"commerceIncome": 90, "specialtyIncome": 260}},',
 '+\t"karakorum": {"id": "karakorum", "name": "상도", "owner": "mongol_faction", "nation": "mongol_faction", "region": '
 '"내몽골", "region_key": "region.northern_steppe", "type": "military_fortress", "population": 36000, '
 '"population_rating": 3, "commerce_rating": 2, "gold": 620, "food": 380, "troops": 460, "public_order": 74, '
 '"commerce": 44, "agriculture": 42, "defense": 4, "governor_id": "genghis_khan", "governor_policy_id": "military", '
 '"stationed_hero_ids": ["genghis_khan", "subutai", "jebe"], "hero_ids": ["genghis_khan", "subutai", "jebe"], '
 '"loyalty": 78, "resources": "쌀 ★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★ / 말 ★★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 '
 '460 / 치안 기준 900 / 방어력 4", "trade": "내부 교역로: 평양-업성 북방 연결", "rating": "인구 ★★★ · 상업력 ★★ · 금전 620", "resource_seed": '
 '{"rice": 1, "barley": 4, "seafood": 0, "wood": 2, "iron": 4, "horses": 5, "silk": 2, "salt": 1, "gold": 620, '
 '"specialty": 2}, "domestic_seed": {"publicSupport": 68, "publicOrder": 74, "agriculture": 42, "commerce": 44, '
 '"stability": 70}, "yield_seed": {"riceHarvest": 160, "barleyHarvest": 220, "seafoodPerTurn": 0, "commerceIncome": '
 '105, "specialtyIncome": 360}},',
 '-\t"yecheng": {"id": "yecheng", "name": "업성", "owner": "wei", "nation": "wei", "region": "중국대륙", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 55000, "population_rating": 4, '
 '"commerce_rating": 3, "gold": 720, "food": 550, "troops": 450, "public_order": 68, "commerce": 52, "agriculture": '
 '64, "defense": 5, "governor_id": "cao_cao", "governor_policy_id": "military", "stationed_hero_ids": ["cao_cao", '
 '"xiahou_dun", "xun_yu", "guo_jia"], "hero_ids": ["cao_cao", "xiahou_dun", "xun_yu", "guo_jia"], "loyalty": 70, '
 '"resources": "쌀 ★★★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★★ / 말 ★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 450 / 치안 기준 '
 '1000 / 방어력 5", "trade": "내부 교역로: 낙양-건업-카라코룸 연결", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 720", "resource_seed": {"rice": '
 '3, "barley": 4, "seafood": 0, "wood": 2, "iron": 5, "horses": 4, "silk": 2, "salt": 1, "gold": 720, "specialty": 1}, '
 '"domestic_seed": {"publicSupport": 60, "publicOrder": 68, "agriculture": 64, "commerce": 52, "stability": 58}, '
 '"yield_seed": {"riceHarvest": 350, "barleyHarvest": 200, "seafoodPerTurn": 0, "commerceIncome": 110, '
 '"specialtyIncome": 280}},',
 '+\t"yecheng": {"id": "yecheng", "name": "업성", "owner": "wei", "nation": "wei", "region": "중국대륙", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 55000, "population_rating": 4, '
 '"commerce_rating": 3, "gold": 720, "food": 550, "troops": 450, "public_order": 68, "commerce": 52, "agriculture": '
 '64, "defense": 5, "governor_id": "cao_cao", "governor_policy_id": "military", "stationed_hero_ids": ["cao_cao", '
 '"xiahou_dun", "xun_yu", "guo_jia"], "hero_ids": ["cao_cao", "xiahou_dun", "xun_yu", "guo_jia"], "loyalty": 70, '
 '"resources": "쌀 ★★★ / 보리 ★★★★ / 수산물 - / 목재 ★★ / 철 ★★★★★ / 말 ★★★★ / 비단 ★★ / 소금 ★", "military": "도시 주둔군 450 / 치안 기준 '
 '1000 / 방어력 5", "trade": "내부 교역로: 낙양-건업-상도 연결", "rating": "인구 ★★★★ · 상업력 ★★★ · 금전 720", "resource_seed": {"rice": 3, '
 '"barley": 4, "seafood": 0, "wood": 2, "iron": 5, "horses": 4, "silk": 2, "salt": 1, "gold": 720, "specialty": 1}, '
 '"domestic_seed": {"publicSupport": 60, "publicOrder": 68, "agriculture": 64, "commerce": 52, "stability": 58}, '
 '"yield_seed": {"riceHarvest": 350, "barleyHarvest": 200, "seafoodPerTurn": 0, "commerceIncome": 110, '
 '"specialtyIncome": 280}},',
 '+\t# Queue 39 (CITIES65 0.7): 52 unclaimed cities (빈 성) — owner "", 0 troops, display-only minimum values.',
 '+\t"ansiseong": {"id": "ansiseong", "name": "안시성", "owner": "", "nation": "", "region": "만주", "region_key": '
 '"region.korean_peninsula", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"gungnaeseong": {"id": "gungnaeseong", "name": "국내성", "owner": "", "nation": "", "region": "만주", "region_key": '
 '"region.korean_peninsula", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"sanggyeong_yongcheonbu": {"id": "sanggyeong_yongcheonbu", "name": "상경 용천부", "owner": "", "nation": "", "region": '
 '"만주", "region_key": "region.korean_peninsula", "type": "commercial_capital", "population": 1000, '
 '"population_rating": 1, "commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, '
 '"agriculture": 10, "defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": '
 '[], "hero_ids": [], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 '
 '없음)", "resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": '
 '0, "gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, '
 '"commerce": 10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, '
 '"commerceIncome": 0, "specialtyIncome": 0}},',
 '+\t"byeokjin": {"id": "byeokjin", "name": "벽진 성주", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"cheorwon": {"id": "cheorwon", "name": "철원", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"gaeseong": {"id": "gaeseong", "name": "개성", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "commercial_capital", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"goryeong": {"id": "goryeong", "name": "고령", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"jeju": {"id": "jeju", "name": "제주", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"jeonju": {"id": "jeonju", "name": "전주", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"jinju": {"id": "jinju", "name": "진주 강주", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"myeongju": {"id": "myeongju", "name": "명주 강릉", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"naju": {"id": "naju", "name": "나주", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "river_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"sangju": {"id": "sangju", "name": "상주", "owner": "", "nation": "", "region": "한반도", "region_key": '
 '"region.korean_peninsula", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"aizu": {"id": "aizu", "name": "아이즈", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "production_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"bungo": {"id": "bungo", "name": "분고 후나이", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"echigo": {"id": "echigo", "name": "에치고", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"hiroshima": {"id": "hiroshima", "name": "히로시마", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"hitachi": {"id": "hitachi", "name": "히타치 미토", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "production_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"hizen": {"id": "hizen", "name": "히젠 사가", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"kagoshima": {"id": "kagoshima", "name": "가고시마", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"kitaomi": {"id": "kitaomi", "name": "북오미 오다니", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"kofu": {"id": "kofu", "name": "고후", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"nagoya": {"id": "nagoya", "name": "나고야", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"odawara": {"id": "odawara", "name": "오다와라", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "military_fortress", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"sendai": {"id": "sendai", "name": "센다이", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "production_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"tosa": {"id": "tosa", "name": "토사", "owner": "", "nation": "", "region": "일본", "region_key": '
 '"region.japanese_archipelago", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"jiangdong": {"id": "jiangdong", "name": "강동", "owner": "", "nation": "", "region": "강남", "region_key": '
 '"region.china_mainland", "type": "river_trade_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"lingnan": {"id": "lingnan", "name": "영남 광주", "owner": "", "nation": "", "region": "강남", "region_key": '
 '"region.china_mainland", "type": "coastal_trade_city", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"yangzhou": {"id": "yangzhou", "name": "양주", "owner": "", "nation": "", "region": "강남", "region_key": '
 '"region.china_mainland", "type": "river_trade_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"changsha": {"id": "changsha", "name": "장사", "owner": "", "nation": "", "region": "남방", "region_key": '
 '"region.china_mainland", "type": "river_trade_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"hetuala": {"id": "hetuala", "name": "허투알라", "owner": "", "nation": "", "region": "만주", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"huining": {"id": "huining", "name": "회령", "owner": "", "nation": "", "region": "만주", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"liaodong": {"id": "liaodong", "name": "요동 양평", "owner": "", "nation": "", "region": "만주", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"shangjing": {"id": "shangjing", "name": "상경", "owner": "", "nation": "", "region": "만주", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"lhasa": {"id": "lhasa", "name": "라싸", "owner": "", "nation": "", "region": "서남", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"nanzhong": {"id": "nanzhong", "name": "운남(남중)", "owner": "", "nation": "", "region": "서남", "region_key": '
 '"region.china_mainland", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"wuguo": {"id": "wuguo", "name": "오과 독룡", "owner": "", "nation": "", "region": "서남", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"yunnan": {"id": "yunnan", "name": "운남", "owner": "", "nation": "", "region": "서남", "region_key": '
 '"region.china_mainland", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"hexi": {"id": "hexi", "name": "하서 고장", "owner": "", "nation": "", "region": "서북", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"longxi": {"id": "longxi", "name": "농서", "owner": "", "nation": "", "region": "서북", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"xingqing": {"id": "xingqing", "name": "흥경", "owner": "", "nation": "", "region": "서북", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"ordubaliq": {"id": "ordubaliq", "name": "오르두발릭", "owner": "", "nation": "", "region": "오르도스", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"orkhon": {"id": "orkhon", "name": "오르혼", "owner": "", "nation": "", "region": "오르도스", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"changan": {"id": "changan", "name": "장안", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "commercial_capital", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"dadu": {"id": "dadu", "name": "대도", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "commercial_capital", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"jizhou": {"id": "jizhou", "name": "기주", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"kaifeng": {"id": "kaifeng", "name": "개봉", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "commercial_capital", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"pengcheng": {"id": "pengcheng", "name": "팽성", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "river_trade_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"puyang": {"id": "puyang", "name": "복양", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"xiangyang": {"id": "xiangyang", "name": "양양", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "military_fortress", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\t"xianyang": {"id": "xianyang", "name": "함양", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "commercial_capital", "population": 1000, "population_rating": 1, '
 '"commerce_rating": 1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, '
 '"defense": 1, "governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": '
 '[], "loyalty": 50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", '
 '"resource_seed": {"rice": 0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, '
 '"gold": 0, "specialty": 0}, "domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": '
 '10, "stability": 50}, "yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, '
 '"specialtyIncome": 0}},',
 '+\t"xuchang": {"id": "xuchang", "name": "허창", "owner": "", "nation": "", "region": "중원", "region_key": '
 '"region.china_mainland", "type": "production_city", "population": 1000, "population_rating": 1, "commerce_rating": '
 '1, "gold": 0, "food": 0, "troops": 0, "public_order": 50, "commerce": 10, "agriculture": 10, "defense": 1, '
 '"governor_id": "", "governor_policy_id": "follow_chancellor", "stationed_hero_ids": [], "hero_ids": [], "loyalty": '
 '50, "resources": "-", "military": "도시 주둔군 0 / 빈 성", "trade": "-", "rating": "빈 성(주인 없음)", "resource_seed": {"rice": '
 '0, "barley": 0, "seafood": 0, "wood": 0, "iron": 0, "horses": 0, "silk": 0, "salt": 0, "gold": 0, "specialty": 0}, '
 '"domestic_seed": {"publicSupport": 50, "publicOrder": 50, "agriculture": 10, "commerce": 10, "stability": 50}, '
 '"yield_seed": {"riceHarvest": 0, "barleyHarvest": 0, "seafoodPerTurn": 0, "commerceIncome": 0, "specialtyIncome": '
 '0}},',
 '+\tWorldMapCityRosterService.add_missing_city_markers(city_layer, CITY_HUD_DATA)  # Queue 39: 52 unclaimed cities.']


# Queue 41 3D HUD connection (Kim approved 11-27 order, re-pin allowed): the code commit that wired the hidden windows.
# worldmap_main.gd must equal that commit and differ from the CITIES65 text by exactly this delta (city storage / spy
# report / strategy request texts in CityDetailPanel, three missing refresh calls). Empty checkpoint = not approved yet.
HUD41_CHECKPOINT = "2d347342b3b2db0e36b81cb26ae7a0b50f8c43ed"
EXPECTED_HUD41_MAIN_DELTA: list[str] = ['+const WORLDMAP_MANUAL_SAVE_PATH := "user://worldmap_manual_save.json"  # Queue 41: system menu save slot',
 '-\t\t\tcity_detail_status_label.text = ""',
 '+\t\t\tcity_detail_status_label.text = WorldMapHudConnectPresenter.format_strategy_requests(self, "trade")',
 '-\t\t"storage_summary": _format_city_storage_summary(_get_city_storage(city_id, city_data)),',
 '+\t\t"storage_summary": WorldMapHudConnectPresenter.format_city_storage(self, city_id, '
 '_format_city_storage_summary(_get_city_storage(city_id, city_data))),',
 '-\t\tcity_detail_rating_label.text = ""',
 '+\t\tcity_detail_rating_label.text = WorldMapHudConnectPresenter.format_intel_card(self, current_selected_city_id)',
 '-\t\tcity_detail_rating_label.text = ""',
 '+\t\tcity_detail_rating_label.text = WorldMapHudConnectPresenter.format_strategy_requests(self, "diplomacy")',
 '+\t# Queue 41: the research cost left the city stock — refresh the national / city stock now, not at the next click.',
 '+\t_refresh_left_world_status_panel()',
 '+\t_refresh_city_hud_data_bindings()',
 '+\t_refresh_city_hud_data_bindings()  # Queue 41: the reserved cost left the city stock; show it now.',
 '+\t_refresh_left_world_status_panel()  # Queue 41: the spy cost left the city stock; national stock now.',
 '-func _write_worldmap_state_mvp(show_status: bool) -> bool:',
 "+## Queue 41: the system menu's save is its own slot (same JSON), so the turn-end checkpoint — which rewrites",
 '+## WORLDMAP_SAVE_PATH every turn — cannot overwrite it. Load reads it first (else the checkpoint slot, as before).',
 '+func _save_worldmap_manual_slot_mvp() -> bool:',
 '+\treturn _write_worldmap_state_mvp(true, WORLDMAP_MANUAL_SAVE_PATH)',
 '+',
 '+',
 '+func _load_worldmap_manual_slot_mvp() -> void:',
 '+\t_load_worldmap_state(WORLDMAP_MANUAL_SAVE_PATH if FileAccess.file_exists(WORLDMAP_MANUAL_SAVE_PATH) else '
 'WORLDMAP_SAVE_PATH)',
 '+',
 '+',
 '+func _write_worldmap_state_mvp(show_status: bool, path: String = WORLDMAP_SAVE_PATH) -> bool:',
 '-\tvar file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.WRITE)',
 '+\tvar file := FileAccess.open(path, FileAccess.WRITE)',
 '-\t\tpush_warning("[WorldMap] Failed to open worldmap save path: %s" % WORLDMAP_SAVE_PATH)',
 '+\t\tpush_warning("[WorldMap] Failed to open worldmap save path: %s" % path)',
 '-func _load_worldmap_state() -> void:',
 '-\tif not FileAccess.file_exists(WORLDMAP_SAVE_PATH):',
 '+func _load_worldmap_state(path: String = WORLDMAP_SAVE_PATH) -> void:',
 '+\tif not FileAccess.file_exists(path):',
 '-\tvar file := FileAccess.open(WORLDMAP_SAVE_PATH, FileAccess.READ)',
 '+\tvar file := FileAccess.open(path, FileAccess.READ)']


def line_delta(old_text: str, new_text: str) -> list[str]:
    return [
        line
        for line in difflib.unified_diff(old_text.split("\n"), new_text.split("\n"), lineterm="", n=0)
        if not line.startswith(("---", "+++", "@@"))
    ]


def git_show_text(root, commit: str, path: str) -> str:
    return subprocess.check_output(["git", "show", f"{commit}:{path}"], cwd=root).decode("utf-8").replace("\r\n", "\n")


# Queue 46 (PLACEMENT_A + 0.7 roads): three hook lines - the placement-A new game, markers take the runtime owner,
# placement-A static city values restored on load (WorldMapPlacementA).
PLACEMENT46_CHECKPOINT = "1b3bfad812d12385e20d7d17e2dc695ec2877b82"
EXPECTED_PLACEMENT46_MAIN_DELTA: list[str] = ['+\tWorldMapPlacementA.apply_new_game(self)  # Queue 46: placement A (39 cities, 34 factions; the 119 new heroes via '
 'the seeder).',
 '+\t_refresh_city_marker_owner_states_from_runtime()  # Queue 46: markers built from CITY_HUD_DATA take the runtime '
 'owner.',
 '+\tWorldMapPlacementA.restore_static_values(self)  # Queue 46: placement-A city values not in the save; old saves '
 'untouched.']


def assert_main_is_approved_p1_state(root, current_main: str, warning_cleanup_main: str, main_path: str) -> None:
    p1_main = git_show_text(root, P1_MAIN_CHECKPOINT, main_path)
    assert line_delta(warning_cleanup_main, p1_main) == EXPECTED_P1_MAIN_DELTA, (
        "P-1 worldmap_main.gd delta no longer matches the approved exact delta"
    )
    approved_main = git_show_text(root, P0_STOCK_CHECKPOINT, main_path) if P0_STOCK_CHECKPOINT else p1_main
    if P0_STOCK_CHECKPOINT:
        assert line_delta(p1_main, approved_main) == EXPECTED_P0_STOCK_MAIN_DELTA, (
            "P0-stock worldmap_main.gd delta no longer matches the approved exact delta"
        )
    if CITIES65_CHECKPOINT:
        cities65_main = git_show_text(root, CITIES65_CHECKPOINT, main_path)
        assert line_delta(approved_main, cities65_main) == EXPECTED_CITIES65_MAIN_DELTA, (
            "CITIES65 worldmap_main.gd delta no longer matches the approved exact delta"
        )
        approved_main = cities65_main
    if HUD41_CHECKPOINT:
        hud41_main = git_show_text(root, HUD41_CHECKPOINT, main_path)
        assert line_delta(approved_main, hud41_main) == EXPECTED_HUD41_MAIN_DELTA, (
            "HUD-41 worldmap_main.gd delta no longer matches the approved exact delta"
        )
        approved_main = hud41_main
    if PLACEMENT46_CHECKPOINT:
        placement46_main = git_show_text(root, PLACEMENT46_CHECKPOINT, main_path)
        assert line_delta(approved_main, placement46_main) == EXPECTED_PLACEMENT46_MAIN_DELTA, (
            "PLACEMENT-46 worldmap_main.gd delta no longer matches the approved exact delta"
        )
        approved_main = placement46_main
    assert current_main == approved_main, (
        "worldmap_main.gd changed after the approved P-1/P0-stock/CITIES65/HUD-41/PLACEMENT-46 checkpoint; review a new exact delta "
        "instead of relaxing the guard"
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
