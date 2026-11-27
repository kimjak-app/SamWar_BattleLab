class_name WorldMapUnclaimedCityRules
extends RefCounted

## Queue 39 (CITIES65 0.7): an unclaimed city ("빈 성") is a permanent, normal city state — a city with no owner.
## It can be selected and its city window shown, but until capture / created-hero starts are designed it is left out of:
## AI production and invasion candidates, diplomacy / trade / spy targets, the victory city list, player sortie targets,
## the owned city list (also in saves) and the national stock sum.
## Most of those paths already skip an empty owner; the ones that did not call is_unclaimed_owner() from here, so the
## rule lives in one place when capture is added later.

const UNCLAIMED_OWNER := ""
const OWNER_LABEL := "주인 없음(빈 성)"
const REJECT_REASON := "unclaimed_city"
const REJECT_MESSAGE := "주인 없는 빈 성은 대상이 아닙니다."


static func is_unclaimed_owner(owner_id: Variant) -> bool:
	return owner_id == null or str(owner_id).strip_edges() == UNCLAIMED_OWNER
