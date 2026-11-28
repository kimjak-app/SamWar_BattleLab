#!/usr/bin/env python3
"""Validate the locked 삼국WAR hero workbook and generate JSON design data.

Uses only the Python standard library so contributors do not need openpyxl.
This is a development-time importer. Godot runtime does not read .xlsx files.
"""

from __future__ import annotations

import argparse
import json
import math
import re
import sys
import zipfile
from pathlib import Path
from typing import Any
from xml.etree import ElementTree as ET

NS = {"m": "http://schemas.openxmlformats.org/spreadsheetml/2006/main"}
REL_NS = {"r": "http://schemas.openxmlformats.org/package/2006/relationships"}

EXPECTED_HERO_COUNT = 44
UNIT_TYPES = {"infantry", "cavalry", "archer", "gunner", "mounted_archer"}
ROLES = {"assault", "vanguard", "defender", "commander", "mobile", "ranged", "tactician", "support"}
TARGET_MODES = {
    "self", "single_enemy", "single_ally", "enemy_line", "enemy_area",
    "enemy_adjacent", "ally_area", "self_area", "self_area_enemy",
}
FORBIDDEN_TEXT = {"대백제", "대백제 진군", "영락대전"}
UNIT_NAME_TO_ID = {
    "보병": "infantry", "기병": "cavalry", "궁병": "archer",
    "총병": "gunner", "궁기병": "mounted_archer",
}
ROLE_NAME_TO_ID = {
    "돌격": "assault", "선봉": "vanguard", "방어": "defender",
    "지휘": "commander", "기동": "mobile", "원거리": "ranged",
    "책략": "tactician", "지원": "support",
}


class WorkbookError(RuntimeError):
    pass


def _column_index(cell_ref: str) -> int:
    letters = re.match(r"[A-Z]+", cell_ref)
    if not letters:
        raise WorkbookError(f"Invalid cell reference: {cell_ref}")
    value = 0
    for ch in letters.group(0):
        value = value * 26 + ord(ch) - 64
    return value - 1


def _load_shared_strings(book: zipfile.ZipFile) -> list[str]:
    try:
        root = ET.fromstring(book.read("xl/sharedStrings.xml"))
    except KeyError:
        return []
    result: list[str] = []
    for si in root.findall("m:si", NS):
        result.append("".join(node.text or "" for node in si.iterfind(".//m:t", NS)))
    return result


def _sheet_paths(book: zipfile.ZipFile) -> dict[str, str]:
    workbook = ET.fromstring(book.read("xl/workbook.xml"))
    rels = ET.fromstring(book.read("xl/_rels/workbook.xml.rels"))
    rel_targets = {
        rel.attrib["Id"]: rel.attrib["Target"]
        for rel in rels.findall("r:Relationship", REL_NS)
    }
    paths: dict[str, str] = {}
    for sheet in workbook.findall("m:sheets/m:sheet", NS):
        name = sheet.attrib["name"]
        rel_id = sheet.attrib["{http://schemas.openxmlformats.org/officeDocument/2006/relationships}id"]
        target = rel_targets[rel_id].lstrip("/")
        if not target.startswith("xl/"):
            target = "xl/" + target
        paths[name] = target
    return paths


def _cell_value(cell: ET.Element, shared: list[str]) -> Any:
    cell_type = cell.attrib.get("t")
    if cell_type == "inlineStr":
        return "".join(node.text or "" for node in cell.iterfind(".//m:t", NS))
    value_node = cell.find("m:v", NS)
    if value_node is None:
        return None
    raw = value_node.text or ""
    if cell_type == "s":
        return shared[int(raw)]
    if cell_type in {"str", "b"}:
        return raw if cell_type == "str" else raw == "1"
    try:
        number = float(raw)
        if math.isfinite(number) and number.is_integer():
            return int(number)
        return number
    except ValueError:
        return raw


def read_sheet_rows(workbook_path: Path, sheet_name: str) -> list[list[Any]]:
    with zipfile.ZipFile(workbook_path) as book:
        shared = _load_shared_strings(book)
        paths = _sheet_paths(book)
        if sheet_name not in paths:
            raise WorkbookError(f"Missing worksheet: {sheet_name}")
        root = ET.fromstring(book.read(paths[sheet_name]))
    rows: list[list[Any]] = []
    for row in root.findall(".//m:sheetData/m:row", NS):
        values: list[Any] = []
        for cell in row.findall("m:c", NS):
            index = _column_index(cell.attrib["r"])
            while len(values) <= index:
                values.append(None)
            values[index] = _cell_value(cell, shared)
        rows.append(values)
    return rows


def table_from_sheet(workbook_path: Path, sheet: str, header_name: str) -> list[dict[str, Any]]:
    rows = read_sheet_rows(workbook_path, sheet)
    header_index = next(
        (index for index, row in enumerate(rows) if header_name in row),
        None,
    )
    if header_index is None:
        raise WorkbookError(f"{sheet}: header {header_name!r} not found")
    headers = rows[header_index]
    records: list[dict[str, Any]] = []
    for values in rows[header_index + 1:]:
        if not any(value is not None and value != "" for value in values):
            continue
        padded = values + [None] * max(0, len(headers) - len(values))
        records.append({str(headers[i]): padded[i] for i in range(len(headers)) if headers[i] is not None})
    return records


def table_from_first_available_sheet(
    workbook_path: Path,
    sheet_names: tuple[str, ...],
    header_name: str,
) -> list[dict[str, Any]]:
    with zipfile.ZipFile(workbook_path) as book:
        available = _sheet_paths(book)
    for sheet_name in sheet_names:
        if sheet_name in available:
            return table_from_sheet(workbook_path, sheet_name, header_name)
    raise WorkbookError(f"Missing worksheet; expected one of: {', '.join(sheet_names)}")


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def build_payloads(workbook_path: Path) -> tuple[dict[str, Any], list[str]]:
    base_rows = table_from_first_available_sheet(
        workbook_path,
        ("기본능력치_44명", "기본능력치_39명"),
        "hero_id",
    )
    unit_rows = [
        row for row in table_from_first_available_sheet(
            workbook_path,
            ("5병종_기본성능", "6병종_기본성능"),
            "내부값",
        )
        if row.get("내부값") in UNIT_TYPES
    ]
    role_rows = [
        row for row in table_from_sheet(workbook_path, "8역할_패시브", "주 역할")
        if row.get("내부값") in ROLES
    ]
    skill_rows = table_from_first_available_sheet(
        workbook_path,
        ("44명_고유기_1차안", "39명_고유기_1차안"),
        "고유기명",
    )

    errors: list[str] = []
    require(
        len(base_rows) == EXPECTED_HERO_COUNT,
        f"Expected {EXPECTED_HERO_COUNT} base heroes, found {len(base_rows)}",
        errors,
    )
    require(
        len(skill_rows) == EXPECTED_HERO_COUNT,
        f"Expected {EXPECTED_HERO_COUNT} skills, found {len(skill_rows)}",
        errors,
    )
    require(len(unit_rows) == 5, f"Expected 5 unit types, found {len(unit_rows)}", errors)
    require(len(role_rows) == 8, f"Expected 8 roles, found {len(role_rows)}", errors)

    base_ids = [str(row.get("hero_id", "")) for row in base_rows]
    skill_ids = [str(row.get("hero_id", "")) for row in skill_rows]
    require(len(set(base_ids)) == len(base_ids), "Duplicate hero_id in base sheet", errors)
    require(len(set(skill_ids)) == len(skill_ids), "Duplicate hero_id in skill sheet", errors)
    require(base_ids == skill_ids, "Hero order or IDs differ between base and skill sheets", errors)

    heroes: list[dict[str, Any]] = []
    profiles: list[dict[str, Any]] = []
    skills: list[dict[str, Any]] = []

    for base, skill in zip(base_rows, skill_rows):
        hero_id = str(base["hero_id"])
        unit_id = UNIT_NAME_TO_ID.get(str(base["병종"]))
        primary_role = ROLE_NAME_TO_ID.get(str(base["주 역할"]))
        secondary_role = ROLE_NAME_TO_ID.get(str(base["보조 역할"]))
        require(unit_id in UNIT_TYPES, f"{hero_id}: invalid unit type {base.get('병종')}", errors)
        require(primary_role in ROLES, f"{hero_id}: invalid primary role {base.get('주 역할')}", errors)
        require(secondary_role in ROLES, f"{hero_id}: invalid secondary role {base.get('보조 역할')}", errors)
        require(skill.get("병종") == base.get("병종"), f"{hero_id}: unit mismatch between sheets", errors)
        require(skill.get("주 역할") == base.get("주 역할"), f"{hero_id}: role mismatch between sheets", errors)

        expected_skill_id = f"{hero_id}_unique"
        momentum_cost = skill.get("기세 비용")
        require(skill.get("고유기 ID") == expected_skill_id, f"{hero_id}: skill ID must be {expected_skill_id}", errors)
        require(
            isinstance(momentum_cost, (int, float)) and not isinstance(momentum_cost, bool) and 1 <= momentum_cost <= 4,
            f"{hero_id}: momentum_cost must be 1..4",
            errors,
        )
        require(skill.get("행동 비용") == 1, f"{hero_id}: action_cost must be 1", errors)
        require(str(skill.get("HP 조건")).lower() == "none", f"{hero_id}: HP condition must be none", errors)
        require(skill.get("target_mode") in TARGET_MODES, f"{hero_id}: invalid target_mode {skill.get('target_mode')}", errors)
        require(isinstance(skill.get("사거리"), (int, float)) and 0 <= skill["사거리"] <= 5, f"{hero_id}: range must be 0..5", errors)
        require(isinstance(skill.get("반경"), (int, float)) and 0 <= skill["반경"] <= 3, f"{hero_id}: radius must be 0..3", errors)

        combined_text = " ".join(str(value) for value in skill.values() if value is not None)
        for forbidden in FORBIDDEN_TEXT:
            require(forbidden not in combined_text, f"{hero_id}: forbidden text remains: {forbidden}", errors)

        heroes.append({
            "hero_id": hero_id,
            "display_name": base["장수명"],
            "region": base["지역"],
            "stats": {
                "leadership": base["지휘력"],
                "martial": base["무력"],
                "intelligence": base["지력"],
                "politics": base["정치"],
            },
            "battle_multipliers": {
                "land": base["육전 보정"],
                "naval": base["수전 보정"],
            },
        })
        profiles.append({
            "hero_id": hero_id,
            "unit_type": unit_id,
            "primary_role": primary_role,
            "secondary_role": secondary_role,
            "unique_skill_id": expected_skill_id,
        })
        skills.append({
            "skill_id": expected_skill_id,
            "hero_id": hero_id,
            "display_name": skill["고유기명"],
            "concept": skill["콘셉트"],
            "effect_type": skill["effect_type"],
            "target_mode": skill["target_mode"],
            "range": skill["사거리"],
            "radius": skill["반경"],
            "power": skill["위력"],
            "momentum_cost": int(momentum_cost) if isinstance(momentum_cost, (int, float)) else momentum_cost,
            "action_cost": 1,
            "hp_condition": None,
            "duration_turns": skill["지속 턴"],
            "description": skill["효과 설명"],
        })

    unit_types = [{
        "unit_type": row["내부값"],
        "display_name": row["병종"],
        "move_range": row["이동력"],
        "attack_range": row["사거리"],
        "attack_profile": row["공격 성향"],
        "defense_profile": row["방어 성향"],
        "passive": row["확정 핵심 효과"],
        "weakness": row["핵심 약점"],
        "implementation_note": row["구현 메모"],
    } for row in unit_rows]

    battle_roles = [{
        "role": row["내부값"],
        "display_name": row["주 역할"],
        "passive": row["확정 효과"],
        "condition": row["조건"],
        "applies_to_self": row["본인 적용"] == "예",
        "stacking": row["중첩"],
        "cap_note": row["상한/주의"],
    } for row in role_rows]

    payloads = {
        "hero_base_stats.json": {"schema_version": 1, "heroes": heroes},
        "hero_battle_profiles.json": {"schema_version": 1, "profiles": profiles},
        "hero_unique_skills.json": {"schema_version": 1, "skills": skills},
        "unit_type_rules.json": {"schema_version": 1, "unit_types": unit_types},
        "battle_role_rules.json": {"schema_version": 1, "roles": battle_roles},
    }
    return payloads, errors


def write_outputs(payloads: dict[str, Any], output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    for filename, payload in payloads.items():
        (output_dir / filename).write_text(
            json.dumps(payload, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )


# ---------------------------------------------------------------- queue 45: roster JSON input adapter
# The Excel path above is unchanged. This adapter reads the roster JSON (Drive 68, 245 heroes) and APPENDS the chosen
# heroes to the generated JSON files and to HeroDefinitionRegistry.LEGACY_IDENTITY_DATA without touching a byte of the
# existing records (each file keeps its own layout: indented, one record per line, or a single minified line).

REGISTRY_PATH = Path("scripts/worldmap/hero_definition_registry.gd")
REGISTRY_CLOSE = "}\n\nstatic var HERO_DATA"
NEW_HERO_CITY_FIELDS = ("assigned_city_id", "city_id", "location_city_id")   # left empty: placement is queue 46
NEW_HERO_FACTION_FIELDS = ("faction_id", "force_id", "side", "nation")


def roster_records(roster_path: Path, hero_ids: list[str], portrait_paths: dict[str, str]) -> tuple[dict[str, list], list[str]]:
    roster = {hero["hero_id"]: hero for hero in json.loads(roster_path.read_text(encoding="utf-8"))["heroes"]}
    errors: list[str] = []
    records: dict[str, list] = {"base": [], "profile": [], "loyalty": [], "skill": [], "identity": []}
    require(len(set(hero_ids)) == len(hero_ids), "Duplicate hero_id in the chosen list", errors)
    for hero_id in hero_ids:
        hero = roster.get(hero_id)
        if hero is None:
            errors.append(f"{hero_id}: not in the roster")
            continue
        unit_id = str(hero.get("unit_type", ""))
        primary_role = ROLE_NAME_TO_ID.get(str(hero.get("primary_role")))
        secondary_role = ROLE_NAME_TO_ID.get(str(hero.get("secondary_role")))
        require(unit_id in UNIT_TYPES, f"{hero_id}: invalid unit type {unit_id}", errors)
        require(primary_role in ROLES, f"{hero_id}: invalid primary role {hero.get('primary_role')}", errors)
        require(secondary_role in ROLES, f"{hero_id}: invalid secondary role {hero.get('secondary_role')}", errors)
        require(hero.get("unique_skill_id") == f"{hero_id}_unique", f"{hero_id}: skill ID must be {hero_id}_unique", errors)
        require(hero.get("target_mode") in TARGET_MODES, f"{hero_id}: invalid target_mode {hero.get('target_mode')}", errors)
        require(isinstance(hero.get("skill_range"), int) and 0 <= hero["skill_range"] <= 5, f"{hero_id}: range must be 0..5", errors)
        require(isinstance(hero.get("radius"), int) and 0 <= hero["radius"] <= 3, f"{hero_id}: radius must be 0..3", errors)
        require(isinstance(hero.get("momentum_cost"), int) and 1 <= hero["momentum_cost"] <= 4, f"{hero_id}: momentum_cost must be 1..4", errors)
        for stat in ("leadership", "martial", "intelligence", "politics", "initial_loyalty"):
            require(isinstance(hero.get(stat), int) and 0 <= hero[stat] <= 100, f"{hero_id}: {stat} must be 0..100", errors)
        combined_text = " ".join(str(value) for value in hero.values() if value is not None)
        for forbidden in FORBIDDEN_TEXT:
            require(forbidden not in combined_text, f"{hero_id}: forbidden text remains: {forbidden}", errors)
        skill_id = f"{hero_id}_unique"
        records["base"].append({
            "hero_id": hero_id,
            "display_name": hero["display_name"],
            "region": hero["region"],
            "stats": {"leadership": hero["leadership"], "martial": hero["martial"], "intelligence": hero["intelligence"], "politics": hero["politics"]},
            "battle_multipliers": {"land": hero["land_modifier"], "naval": hero["naval_modifier"]},
        })
        records["profile"].append({"hero_id": hero_id, "unit_type": unit_id, "primary_role": primary_role, "secondary_role": secondary_role, "unique_skill_id": skill_id})
        records["loyalty"].append({"hero_id": hero_id, "initial_loyalty": hero["initial_loyalty"]})
        records["skill"].append({
            "skill_id": skill_id, "hero_id": hero_id, "display_name": hero["skill_name"], "concept": hero["concept"],
            "effect_type": hero["skill_effect_type"], "target_mode": hero["target_mode"], "range": hero["skill_range"],
            "radius": hero["radius"], "power": hero["skill_power"], "momentum_cost": hero["momentum_cost"], "action_cost": 1,
            "hp_condition": None, "duration_turns": hero["duration_turns"], "description": hero["skill_desc"],
        })
        identity = {"id": hero_id, "hero_id": hero_id, "display_name": hero["display_name"], "name": hero["name"], "role": hero["role"]}
        # No faction yet (new faction ids are queue 46): the keys exist and are empty, so the faction scans in
        # worldmap_main (_get_known_non_player_faction_ids, the chancellor fallback) skip these heroes.
        identity.update({field: "" for field in NEW_HERO_FACTION_FIELDS})
        identity.update({field: "" for field in NEW_HERO_CITY_FIELDS})
        identity.update({
            "unique_skill_id": skill_id, "skill_id": skill_id, "skill_name": hero["skill_name"], "skill_desc": hero["skill_desc"],
            "skill_effect_type": hero["skill_effect_type"], "skill_power": hero["skill_power"], "skill_value": hero["skill_power"],
            "portrait_path": portrait_paths.get(hero_id, ""), "portrait_image": "", "battlefield_portrait_image": "",
            "hanja": hero.get("hanja", ""), "roster_faction": hero.get("faction", ""), "description": hero.get("bio", ""),
            "review_status": hero["review_status"], "stats_approved": False,
        })
        records["identity"].append(identity)
    return records, errors


def _compact(record: dict) -> str:
    return json.dumps(record, ensure_ascii=False, separators=(",", ":"))


def _append_indented_base_stats(text: str, records: list[dict]) -> str:
    tail = "    }\n  ]\n}\n"
    if not text.endswith(tail):
        raise WorkbookError("hero_base_stats.json: unexpected layout at the end")
    blocks = []
    for r in records:
        blocks.append("\n".join([
            "    {",
            f'      "hero_id": {json.dumps(r["hero_id"])},',
            f'      "display_name": {json.dumps(r["display_name"], ensure_ascii=False)},',
            f'      "region": {json.dumps(r["region"], ensure_ascii=False)},',
            f'      "stats": {json.dumps(r["stats"])},',
            f'      "battle_multipliers": {json.dumps(r["battle_multipliers"])}',
            "    }",
        ]))
    return text[: -len(tail)] + "    },\n" + ",\n".join(blocks) + "\n  ]\n}\n"


def _append_line_records(text: str, records: list[dict]) -> str:
    tail = "}\n  ]\n}\n"
    if not text.endswith(tail):
        raise WorkbookError("hero_initial_loyalty.json: unexpected layout at the end")
    return text[: -len(tail)] + "},\n" + ",\n".join("    " + _compact(r) for r in records) + "\n  ]\n}\n"


def _append_minified(text: str, records: list[dict], name: str) -> str:
    tail = "]}\n"
    if not text.endswith(tail):
        raise WorkbookError(f"{name}: unexpected layout at the end")
    return text[: -len(tail)] + "," + ",".join(_compact(r) for r in records) + tail


def _append_registry(text: str, records: list[dict]) -> str:
    if text.count(REGISTRY_CLOSE) != 1:
        raise WorkbookError("hero_definition_registry.gd: LEGACY_IDENTITY_DATA end not found")
    lines = "".join(f"\t{json.dumps(r['hero_id'])}: {json.dumps(r, ensure_ascii=False)},\n" for r in records)
    return text.replace(REGISTRY_CLOSE, lines + REGISTRY_CLOSE)


def append_roster(roster_path: Path, hero_ids: list[str], output_dir: Path, registry_path: Path, portrait_paths: dict[str, str]) -> list[str]:
    records, errors = roster_records(roster_path, hero_ids, portrait_paths)
    targets = {
        "hero_base_stats.json": ("heroes", lambda t: _append_indented_base_stats(t, records["base"])),
        "hero_battle_profiles.json": ("profiles", lambda t: _append_minified(t, records["profile"], "hero_battle_profiles.json")),
        "hero_initial_loyalty.json": ("heroes", lambda t: _append_line_records(t, records["loyalty"])),
        "hero_unique_skills.json": ("skills", lambda t: _append_minified(t, records["skill"], "hero_unique_skills.json")),
    }
    texts = {name: (output_dir / name).read_text(encoding="utf-8") for name in targets}
    for name, (key, _) in targets.items():
        existing = {str(r.get("hero_id")) for r in json.loads(texts[name])[key]}
        clash = existing & set(hero_ids)
        require(not clash, f"{name}: already has {sorted(clash)[:5]}", errors)
    registry_text = registry_path.read_text(encoding="utf-8")
    for hero_id in hero_ids:
        require(f'\t"{hero_id}": {{' not in registry_text, f"{registry_path.name}: already has {hero_id}", errors)
    if errors:
        return errors
    for name, (key, append) in targets.items():
        new_text = append(texts[name])
        old_records = json.loads(texts[name])[key]
        new_records = json.loads(new_text)[key]
        if new_records[: len(old_records)] != old_records or len(new_records) != len(old_records) + len(hero_ids):
            return [f"{name}: append check failed"]
        (output_dir / name).write_text(new_text, encoding="utf-8", newline="\n")
    registry_path.write_text(_append_registry(registry_text, records["identity"]), encoding="utf-8", newline="\n")
    return []


def main_roster(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(prog="convert_hero_workbook.py --roster-json")
    parser.add_argument("--roster-json", type=Path, required=True, help="roster JSON (schema eastwar_hero_workbook_v1)")
    parser.add_argument("--ids-csv", type=Path, required=True, help="csv with a hero_id column: the heroes to add, in order")
    parser.add_argument("--portrait-map", type=Path, help="csv with hero_id and output_path (portraits made by make_hero_portraits.py)")
    parser.add_argument("--output-dir", type=Path, default=Path("data/heroes/generated"))
    parser.add_argument("--registry", type=Path, default=REGISTRY_PATH)
    args = parser.parse_args(argv)
    import csv
    with args.ids_csv.open(encoding="utf-8", newline="") as handle:
        hero_ids = [row["hero_id"] for row in csv.DictReader(handle)]
    portrait_paths: dict[str, str] = {}
    if args.portrait_map and args.portrait_map.is_file():
        with args.portrait_map.open(encoding="utf-8", newline="") as handle:
            portrait_paths = {row["hero_id"]: "res://" + row["output_path"] for row in csv.DictReader(handle)}
    errors = append_roster(args.roster_json, hero_ids, args.output_dir, args.registry, portrait_paths)
    if errors:
        print("VALIDATION FAILED", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print(f"ROSTER APPEND PASS: {len(hero_ids)} heroes appended -> {args.output_dir}, {args.registry}")
    return 0


def main() -> int:
    if "--roster-json" in sys.argv[1:]:
        return main_roster(sys.argv[1:])
    parser = argparse.ArgumentParser()
    parser.add_argument("workbook", type=Path, help="Locked .xlsx design workbook")
    parser.add_argument("--output-dir", type=Path, default=Path("data/heroes/generated"))
    parser.add_argument("--validate-only", action="store_true")
    args = parser.parse_args()

    if not args.workbook.is_file():
        print(f"ERROR: workbook not found: {args.workbook}", file=sys.stderr)
        return 2
    try:
        payloads, errors = build_payloads(args.workbook)
    except (WorkbookError, zipfile.BadZipFile, ET.ParseError, KeyError, ValueError) as exc:
        print(f"ERROR: cannot parse workbook: {exc}", file=sys.stderr)
        return 2

    if errors:
        print("VALIDATION FAILED", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    if not args.validate_only:
        write_outputs(payloads, args.output_dir)
    print(
        f"VALIDATION PASS: {EXPECTED_HERO_COUNT} heroes, {EXPECTED_HERO_COUNT} unique skills, 5 unit types, 8 roles"
        + (" (no files written)" if args.validate_only else f" -> {args.output_dir}")
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
