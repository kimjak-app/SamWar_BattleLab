#!/usr/bin/env python3
"""Validate the one-way legacy-to-canonical hero identity contract for cutins."""
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "scripts/ui/cutin/korea_mvp_hero_cutin_registry.gd"
BATTLE = ROOT / "scripts/battle_web_import_test.gd"
GODOT_TEST = ROOT / "tests/scripts/test_canonical_hero_identity_contract.gd"

errors: list[str] = []
registry = REGISTRY.read_text(encoding="utf-8")
battle = BATTLE.read_text(encoding="utf-8")
test = GODOT_TEST.read_text(encoding="utf-8")

required_registry = (
    "const HERO_ID_CANONICAL_ALIASES",
    "static func canonicalize_hero_id(raw_id: String) -> String:",
    "static func canonicalize_skill_id(raw_id: String) -> String:",
    "static func get_portrait_path(hero_id: String) -> String:",
    "canonicalize_hero_id(hero_id)",
)
for token in required_registry:
    if token not in registry:
        errors.append(f"registry missing canonical identity contract: {token}")

for legacy, canonical in {
    "yi_sunsin": "yi_sun_sin",
    "jeong_dojeon": "jeong_do_jeon",
    "gim_yusin": "kim_yu_sin",
}.items():
    if f'"{legacy}": "{canonical}"' not in registry:
        errors.append(f"missing authoritative canonical mapping: {legacy} -> {canonical}")

for token in (
    "var canonical_caster_hero_id := KoreaMvpHeroCutinRegistryScript.canonicalize_hero_id(runtime_caster_hero_id)",
    "var canonical_skill_owner_hero_id := KoreaMvpHeroCutinRegistryScript.canonicalize_hero_id(raw_skill_owner_hero_id)",
    "KoreaMvpHeroCutinRegistryScript.find_entry(canonical_skill_owner_hero_id, skill_id)",
):
    if token not in battle:
        errors.append(f"battle cutin boundary does not canonicalize: {token}")

parity_gate = battle.find("if not canonical_caster_hero_id.is_empty() and canonical_skill_owner_hero_id != canonical_caster_hero_id:")
lookup = battle.find("KoreaMvpHeroCutinRegistryScript.find_entry(canonical_skill_owner_hero_id, skill_id)")
if parity_gate < 0 or lookup < 0 or parity_gate > lookup:
    errors.append("canonical parity gate must run before registry lookup")
if "RUNTIME_HERO_ID_ALIASES" in registry:
    errors.append("obsolete duplicate runtime hero alias table remains")

for hero in ("yi_sun_sin", "jeong_do_jeon", "kim_yu_sin", "kwon_yul", "eulji_mundeok", "guan_yu", "zhang_fei", "liu_bei", "xiahou_dun", "zhuge_liang"):
    if f'"expected": "{hero}"' not in test:
        errors.append(f"identity matrix missing legacy hero: {hero}")

if errors:
    print("CANONICAL HERO IDENTITY VALIDATION FAILED", file=sys.stderr)
    print("\n".join(f"ERROR: {error}" for error in errors), file=sys.stderr)
    raise SystemExit(1)
print("CANONICAL HERO IDENTITY VALIDATION PASS: authoritative normalization, canonical parity gate, 10-hero matrix")
