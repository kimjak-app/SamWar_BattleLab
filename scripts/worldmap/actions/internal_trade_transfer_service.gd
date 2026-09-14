class_name WorldMapInternalTradeTransferService
extends RefCounted

const RESOURCE_ORDER := ["gold", "rice", "barley", "seafood", "wood", "iron", "horses", "silk", "salt"]


func validate_transfer(adapter: Object, source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	if adapter == null:
		return {"ok": false, "reason": "교역 실행 API가 준비되지 않았습니다."}
	if source_city_id.is_empty():
		return {"ok": false, "reason": "출발 성을 확인할 수 없습니다."}
	if target_city_id.is_empty():
		return {"ok": false, "reason": "도착 성을 선택하십시오."}
	if source_city_id == target_city_id:
		return {"ok": false, "reason": "출발 성과 도착 성은 달라야 합니다."}
	if not adapter.call("is_city_owned_by_player", source_city_id) or not adapter.call("is_city_owned_by_player", target_city_id):
		return {"ok": false, "reason": "자국 성끼리만 이송할 수 있습니다."}
	if not adapter.call("get_internal_trade_connected_player_city_ids", source_city_id).has(target_city_id):
		return {"ok": false, "reason": "연결된 아군 성으로만 이송할 수 있습니다."}
	if amounts.is_empty():
		return {"ok": false, "reason": "이송할 자원을 1개 이상 입력하십시오."}
	var source_storage: Dictionary = adapter.call("get_city_storage", source_city_id)
	for resource_id_variant in amounts.keys():
		var resource_id := str(resource_id_variant)
		if not RESOURCE_ORDER.has(resource_id):
			return {"ok": false, "reason": "허용되지 않은 자원입니다."}
		var amount := int(amounts.get(resource_id, 0))
		if amount < 0:
			return {"ok": false, "reason": "이송 수량은 0 이상이어야 합니다."}
		if amount > maxi(0, int(source_storage.get(resource_id, 0))):
			return {"ok": false, "reason": "보유량을 초과할 수 없습니다."}
	return {"ok": true}


func execute_transfer(adapter: Object, source_city_id: String, target_city_id: String, amounts: Dictionary) -> Dictionary:
	var validation := validate_transfer(adapter, source_city_id, target_city_id, amounts)
	if not bool(validation.get("ok", false)):
		return validation
	var source_storage: Dictionary = adapter.call("get_city_storage", source_city_id)
	var target_storage: Dictionary = adapter.call("get_city_storage", target_city_id)
	for resource_id_variant in amounts.keys():
		var resource_id := str(resource_id_variant)
		var amount := maxi(0, int(amounts.get(resource_id, 0)))
		if amount <= 0:
			continue
		source_storage[resource_id] = maxi(0, int(source_storage.get(resource_id, 0)) - amount)
		target_storage[resource_id] = maxi(0, int(target_storage.get(resource_id, 0)) + amount)
	adapter.call("set_city_storage", source_city_id, source_storage)
	adapter.call("set_city_storage", target_city_id, target_storage)
	var payload := {
		"source_city_id": source_city_id,
		"target_city_id": target_city_id,
		"trade_type": "internal",
		"mode": "manual_transfer",
		"amounts": amounts.duplicate(true),
		"message": "수동 이송 완료",
	}
	adapter.call("record_internal_trade_transfer_result", payload)
	return payload
