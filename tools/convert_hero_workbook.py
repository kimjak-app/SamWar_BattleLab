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

EXPECTED_HERO_COUNT = 39
UNIT_TYPES = {"infantry", "cavalry", "archer", "gunner", "mounted_archer", "support"}
ROLES = {"assault", "vanguard", "defender", "commander", "mobile", "ranged", "tactician", "support"}
TARGET_MODES = {
    "self", "single_enemy", "single_ally", "enemy_line", "enemy_area",
    "enemy_adjacent", "ally_area", "self_area", "self_area_enemy",
}
FORBIDDEN_TEXT = {"대백제", "대백제 진군", "영락대전"}
UNIT_NAME_TO_ID = {
    "보병": "infantry", "기병": "cavalry", "궁병": "archer",
    "총병": "gunner", "궁기병": "mounted_archer", "지원": "support",
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


def require(condition: bool, message: str, errors: list[str]) -> None:
    if not condition:
        errors.append(message)


def build_payloads(workbook_path: Path) -> tuple[dict[str, Any], list[str]]:
    base_rows = table_from_sheet(workbook_path, "기본능력치_39명", "hero_id")
    unit_rows = [
        row for row in table_from_sheet(workbook_path, "6병종_기본성능", "내부값")
        if row.get("내부값") in UNIT_TYPES
    ]
    role_rows = [
        row for row in table_from_sheet(workbook_path, "8역할_패시브", "주 역할")
        if row.get("내부값") in ROLES
    ]
    skill_rows = table_from_sheet(workbook_path, "39명_고유기_1차안", "고유기명")

    errors: list[str] = []
    require(len(base_rows) == EXPECTED_HERO_COUNT, f"Expected 39 base heroes, found {len(base_rows)}", errors)
    require(len(skill_rows) == EXPECTED_HERO_COUNT, f"Expected 39 skills, found {len(skill_rows)}", errors)
    require(len(unit_rows) == 6, f"Expected 6 unit types, found {len(unit_rows)}", errors)
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
        require(skill.get("고유기 ID") == expected_skill_id, f"{hero_id}: skill ID must be {expected_skill_id}", errors)
        require(skill.get("기세 비용") == 3, f"{hero_id}: momentum_cost must be 3", errors)
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
            "momentum_cost": 3,
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


def main() -> int:
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
        f"VALIDATION PASS: 39 heroes, 39 unique skills, 6 unit types, 8 roles"
        + (" (no files written)" if args.validate_only else f" -> {args.output_dir}")
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
