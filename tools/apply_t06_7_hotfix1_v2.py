#!/usr/bin/env python3
"""Canonical-ID wrapper for the T06-7-hotfix1 applicator."""
from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

import apply_t06_7_hotfix1 as hotfix

ROOT = Path(__file__).resolve().parents[1]

COST_BY_HERO_ID = {
    "shimazu_yoshihiro": 1,
    "cheok_jun_gyeong": 2,
    "dorim": 2,
    "fan_zeng": 2,
    "xiahou_dun": 2,
    "lu_meng": 2,
    "konishi_yukinaga": 2,
    "honda_masanobu": 2,
    "honda_tadakatsu": 2,
    "jebe": 2,
    "jeong_do_jeon": 3,
    "kwon_yul": 3,
    "kim_chun_chu": 3,
    "kim_yu_sin": 3,
    "jang_bo_go": 3,
    "uija_wang": 3,
    "gyebaek": 3,
    "heukchi_sangji": 3,
    "xun_yu": 3,
    "lu_bu": 3,
    "guo_jia": 3,
    "guan_yu": 3,
    "zhang_fei": 3,
    "sun_ce": 3,
    "nobunaga": 3,
    "takeda_shingen": 3,
    "kenshin": 3,
    "subutai": 3,
    "yi_sun_sin": 4,
    "gwanggaeto": 4,
    "eulji_mundeok": 4,
    "xiang_yu": 4,
    "cao_cao": 4,
    "zhuge_liang": 4,
    "liu_bei": 4,
    "zhou_yu": 4,
    "toyotomi_hideyoshi": 4,
    "tokugawa_ieyasu": 4,
    "genghis_khan": 4,
}


def patch_costs_by_id() -> None:
    path = ROOT / "data/heroes/generated/hero_unique_skills.json"
    payload = json.loads(path.read_text(encoding="utf-8"))
    skills = payload.get("skills", [])
    ids = {str(row.get("hero_id", "")) for row in skills}
    missing = set(COST_BY_HERO_ID) - ids
    extra = ids - set(COST_BY_HERO_ID)
    if missing or extra or len(skills) != 39:
        raise RuntimeError(f"hero-id contract mismatch missing={sorted(missing)} extra={sorted(extra)} count={len(skills)}")
    for row in skills:
        row["momentum_cost"] = COST_BY_HERO_ID[str(row["hero_id"])]
        row["action_cost"] = 1
        row["hp_condition"] = None
    distribution = Counter(int(row["momentum_cost"]) for row in skills)
    expected = Counter({1: 1, 2: 9, 3: 18, 4: 11})
    if distribution != expected:
        raise RuntimeError(f"momentum distribution mismatch: {distribution} != {expected}")
    path.write_text(json.dumps(payload, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")


hotfix.patch_costs = patch_costs_by_id
hotfix.main()
