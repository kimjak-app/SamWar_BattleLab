class_name WorldMapHudConnectPresenter
extends RefCounted

## Queue 41 (3D HUD connection): text for the existing CityDetailPanel labels — read only, no rules.
##   city storage: own city = its resource_stock (9 items); unclaimed = 주인 없음(빈 성); foreign = the last spy report
##   (P3 snapshot) if any, else 정보 없음.
##   spy report card: the P3 observation lines (stock 9 items + hero roster) of the selected city.
##   strategy requests: pending requests of one domain (submitted, result next turn) + this turn's results.

const DiplomacyActionServiceScript := preload("res://scripts/worldmap/actions/diplomacy_action_service.gd")
const StrategyRequestServiceScript := preload("res://scripts/worldmap/actions/strategy_request_service.gd")
const RESOURCE_IDS := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]
const NO_INFO := "창고: 정보 없음 (정탐 필요)"
## Queue 41 (8-2): "예약분 반환" only when it was given back; held = "돌려줄 도시가 없어 반환 보류".
const STATUS_TEXT := {"resolved": "성사", "invalid": "무효 · 예약분 반환", "held": "무효 · 돌려줄 도시가 없어 반환 보류"}


static func format_city_storage(main: Node, city_id: String, own_summary: String) -> String:
	var owner_id := str(main.call("_get_city_owner_faction_id_for_trade_display", city_id))
	if owner_id == str(main.call("_get_current_player_faction_id")):
		return own_summary
	if WorldMapUnclaimedCityRules.is_unclaimed_owner(owner_id):
		return "창고: %s" % WorldMapUnclaimedCityRules.OWNER_LABEL
	var card := format_intel_card(main, city_id)
	return card if not card.is_empty() else NO_INFO


## "" when the city has no spy report with observation lines.
static func format_intel_card(main: Node, city_id: String) -> String:
	if city_id.is_empty():
		return ""
	var registry: Dictionary = main.call("_normalize_city_intel_registry", (main.get("_player_state") as Dictionary).get("city_intel", {}))
	var intel: Dictionary = registry.get(city_id, {}) if registry.get(city_id, {}) is Dictionary else {}
	if intel.is_empty():
		return ""
	var panel: Node = main.get("city_info_panel")
	if panel == null or not panel.has_method("_format_enemy_intel_observation_lines"):
		return ""
	var fields: Array[String] = panel.call("_get_enemy_city_intel_fields", intel)
	var payload: Dictionary = panel.call("_get_enemy_city_intel_payload", intel)
	var lines := str(panel.call("_format_enemy_intel_observation_lines", fields, payload))
	if lines.is_empty():
		return ""
	var turn := int(intel.get("turn", payload.get("observed_turn", 0)))
	return "정탐 결과%s\n%s" % [(" · %d턴" % turn) if turn > 0 else "", lines]


static func format_strategy_requests(main: Node, domain: String) -> String:
	var state: Dictionary = main.get("_player_state")
	var ledger: Dictionary = state.get(StrategyRequestServiceScript.LEDGER_KEY, {}) if state.get(StrategyRequestServiceScript.LEDGER_KEY, {}) is Dictionary else {}
	var lines: Array[String] = []
	var ids := ledger.keys()
	ids.sort()
	for request_id in ids:
		var request: Dictionary = ledger[request_id]
		if str(request.get("domain", StrategyRequestServiceScript.DOMAIN_DIPLOMACY)) != domain or str(request.get("status", "")) != StrategyRequestServiceScript.STATUS_PENDING:
			continue
		lines.append("· 접수됨: %s (예약 %s) — 결과는 다음 턴" % [_request_label(main, request), _format_amounts(request.get("reserved_assets", {}))])
	var last: Dictionary = state.get(StrategyRequestServiceScript.LAST_RESULTS_KEY, {}) if state.get(StrategyRequestServiceScript.LAST_RESULTS_KEY, {}) is Dictionary else {}
	for entry in last.get("results", []):
		var request: Dictionary = ledger.get(str(entry.get("request_id", "")), {})
		if request.is_empty() or str(request.get("domain", StrategyRequestServiceScript.DOMAIN_DIPLOMACY)) != domain:
			continue
		var status := str(entry.get("status", ""))
		var detail := str(entry.get("message", ""))
		var outcome: Dictionary = request.get("result", {}) if request.get("result", {}) is Dictionary else {}
		if status == StrategyRequestServiceScript.STATUS_RESOLVED and domain == StrategyRequestServiceScript.DOMAIN_TRADE:
			detail = "받은 것 %s · 보낸 것 %s" % [_format_amounts({"_": outcome.get("received", {})}), _format_amounts({"_": outcome.get("paid", {})})]
		# A resolved diplomacy request can still be a rejection (alliance below 70) — "처리", its message says which.
		var status_text := "처리" if status == StrategyRequestServiceScript.STATUS_RESOLVED and domain != StrategyRequestServiceScript.DOMAIN_TRADE else str(STATUS_TEXT.get(status, status))
		lines.append("· %d턴 결과 %s: %s — %s" % [int(last.get("source_turn", 0)), status_text, _request_label(main, request), detail])
	if lines.is_empty():
		return ""
	return "전략 요청\n" + "\n".join(lines)


static func _request_label(main: Node, request: Dictionary) -> String:
	var target := str(main.call("_format_faction_label", str(request.get("target_faction_id", ""))))
	if str(request.get("domain", "")) == StrategyRequestServiceScript.DOMAIN_TRADE:
		var fixed: Dictionary = request.get("fixed_context", {})
		return "수동 무역 %s → %s(%s)" % [
			str(main.call("_format_city_name_by_id", str(fixed.get("source_city_id", "")), str(fixed.get("source_city_id", "")))),
			str(main.call("_format_city_name_by_id", str(fixed.get("target_city_id", "")), str(fixed.get("target_city_id", "")))),
			target,
		]
	var label := str(DiplomacyActionServiceScript.get_action_definition(str(request.get("action_id", ""))).get("label", request.get("action_id", "")))
	return "%s → %s" % [label, target]


static func _format_amounts(per_city: Variant) -> String:
	var totals := {}
	if per_city is Dictionary:
		for city_id in per_city:
			for resource_id in per_city[city_id]:
				totals[str(resource_id)] = int(totals.get(str(resource_id), 0)) + int(per_city[city_id][resource_id])
	var parts: Array[String] = []
	for resource_id in RESOURCE_IDS:
		if int(totals.get(resource_id, 0)) > 0:
			parts.append("%s %d" % [_resource_label(resource_id), int(totals[resource_id])])
	return ", ".join(parts) if not parts.is_empty() else "없음"


static func _resource_label(resource_id: String) -> String:
	return {"gold": "금", "rice": "쌀", "barley": "보리", "seafood": "수산물", "wood": "목재", "iron": "철", "horses": "말", "silk": "비단", "salt": "소금"}.get(resource_id, resource_id)
