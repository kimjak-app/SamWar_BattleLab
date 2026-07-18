class_name WoundedRecovery
extends RefCounted


static func make_entry(wounded: int, mode: String, transaction_id: String) -> Dictionary:
	var normalized_mode := "fast" if mode == "fast" else "normal"
	return {
		"wounded_count": maxi(0, wounded),
		"recovery_months_remaining": ExpeditionSupplyCalculator.FAST_WOUNDED_RECOVERY_MONTHS if normalized_mode == "fast" else ExpeditionSupplyCalculator.NORMAL_WOUNDED_RECOVERY_MONTHS,
		"recovery_mode": normalized_mode,
		"source_transaction_id": transaction_id,
	}


static func advance_month(queue: Array) -> Dictionary:
	var remaining: Array[Dictionary] = []
	var recovered := 0
	for raw_entry in queue:
		if not raw_entry is Dictionary:
			continue
		var entry := (raw_entry as Dictionary).duplicate(true)
		var wounded := maxi(0, int(entry.get("wounded_count", entry.get("troops", 0))))
		var months := maxi(0, int(entry.get("recovery_months_remaining", entry.get("turnsLeft", 0)))) - 1
		if wounded <= 0:
			continue
		if months <= 0:
			recovered += wounded
		else:
			entry["wounded_count"] = wounded
			entry["recovery_months_remaining"] = months
			remaining.append(entry)
	return {"recovered": recovered, "queue": remaining}
