#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REGISTRY = ROOT / "data" / "cutin" / "imjin_demo_hero_cutins.json"
EXPECTED_HEROES = {
    "gwak_jae_u",
    "go_gyeong_myeong",
    "kim_deok_ryeong",
    "toyotomi_hideyoshi",
    "shimazu_yoshihiro",
    "kato_kiyomasa",
    "konishi_yukinaga",
    "kuroda_nagamasa",
}
EXPECTED_SKILLS = {
    "gwak_jae_u": ("gwak_jae_u_unique", "홍의장군"),
    "go_gyeong_myeong": ("go_gyeong_myeong_unique", "호남의병"),
    "kim_deok_ryeong": ("kim_deok_ryeong_unique", "충용장"),
    "toyotomi_hideyoshi": ("toyotomi_hideyoshi_unique", "태합호령"),
    "shimazu_yoshihiro": ("shimazu_yoshihiro_unique", "귀석만자"),
    "kato_kiyomasa": ("kato_kiyomasa_unique", "칠본창"),
    "konishi_yukinaga": ("konishi_yukinaga_unique", "선봉교섭"),
    "kuroda_nagamasa": ("kuroda_nagamasa_unique", "세키가하라 조략"),
}


def res_path(value: str) -> Path:
    if value.startswith("res://"):
        value = value[6:]
    return ROOT / value


def find_ffprobe() -> str | None:
    local = ROOT / "tools" / "ffmpeg" / "bin" / "ffprobe.exe"
    if local.exists():
        return str(local)
    return shutil.which("ffprobe")


def probe(ffprobe: str, path: Path) -> dict:
    result = subprocess.run(
        [
            ffprobe,
            "-v",
            "error",
            "-select_streams",
            "v:0",
            "-show_entries",
            "stream=codec_name,width,height,pix_fmt,avg_frame_rate",
            "-show_entries",
            "format=duration",
            "-of",
            "json",
            str(path),
        ],
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        check=False,
    )
    if result.returncode != 0:
        raise AssertionError(f"ffprobe failed for {path}: {result.stderr.strip()}")
    return json.loads(result.stdout)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--video-only",
        action="store_true",
        help="Validate MP4 sources and generated OGV files without requiring final title PNG assets.",
    )
    args = parser.parse_args()

    if not REGISTRY.exists():
        raise AssertionError(f"missing D5 registry: {REGISTRY}")

    payload = json.loads(REGISTRY.read_text(encoding="utf-8"))
    assert payload.get("schema_version") == 1, "unsupported D5 registry schema"
    entries = payload.get("entries", [])
    assert isinstance(entries, list), "D5 registry entries must be a list"
    assert len(entries) == 8, f"expected 8 D5 entries, found {len(entries)}"

    seen: set[str] = set()
    ffprobe = find_ffprobe()
    errors: list[str] = []

    for entry in entries:
        hero_id = str(entry.get("hero_id", ""))
        skill_id = str(entry.get("skill_id", ""))
        skill_name = str(entry.get("skill_name", ""))
        source = res_path(str(entry.get("source_path", "")))
        video = res_path(str(entry.get("video_path", "")))
        title = res_path(str(entry.get("skill_title_texture_path", "")))

        if hero_id in seen:
            errors.append(f"duplicate hero_id: {hero_id}")
        seen.add(hero_id)

        expected_skill = EXPECTED_SKILLS.get(hero_id)
        if expected_skill is None:
            errors.append(f"unexpected hero_id: {hero_id}")
        elif (skill_id, skill_name) != expected_skill:
            errors.append(
                f"skill mismatch: {hero_id} expected={expected_skill} actual={(skill_id, skill_name)}"
            )

        if not bool(entry.get("enabled", False)):
            errors.append(f"disabled cutin entry: {hero_id}")
        if not source.exists() or source.suffix.lower() != ".mp4":
            errors.append(f"missing source MP4: {hero_id} -> {source.relative_to(ROOT)}")
        if not video.exists() or video.suffix.lower() != ".ogv":
            errors.append(f"missing final OGV: {hero_id} -> {video.relative_to(ROOT)}")
        elif ffprobe:
            try:
                info = probe(ffprobe, video)
                stream = info.get("streams", [{}])[0]
                duration = float(info.get("format", {}).get("duration", 0.0))
                if stream.get("codec_name") != "theora":
                    errors.append(f"wrong codec: {hero_id} -> {stream.get('codec_name')}")
                if (int(stream.get("width", 0)), int(stream.get("height", 0))) != (1280, 720):
                    errors.append(
                        f"wrong size: {hero_id} -> {stream.get('width')}x{stream.get('height')}"
                    )
                if str(stream.get("pix_fmt", "")) != "yuv420p":
                    errors.append(f"wrong pix_fmt: {hero_id} -> {stream.get('pix_fmt')}")
                if not 3.90 <= duration <= 4.10:
                    errors.append(f"wrong duration: {hero_id} -> {duration:.3f}s")
            except Exception as exc:  # noqa: BLE001
                errors.append(f"probe failure: {hero_id} -> {exc}")

        if not args.video_only and not title.exists():
            errors.append(f"missing title PNG: {hero_id} -> {title.relative_to(ROOT)}")

        print(
            "D5 CUTIN AUDIT "
            f"hero={hero_id} source={source.exists()} ogv={video.exists()} "
            f"title={'SKIP' if args.video_only else title.exists()} enabled={bool(entry.get('enabled', False))}"
        )

    if seen != EXPECTED_HEROES:
        errors.append(
            f"hero roster mismatch missing={sorted(EXPECTED_HEROES - seen)} unexpected={sorted(seen - EXPECTED_HEROES)}"
        )

    if errors:
        print("D5 IMJIN DEMO CUTIN VALIDATION FAILED", file=sys.stderr)
        for error in errors:
            print(f"ERROR: {error}", file=sys.stderr)
        return 1

    mode = "VIDEO-ONLY" if args.video_only else "FINAL"
    print(f"D5 IMJIN DEMO CUTIN VALIDATION PASS ({mode}): 8 canonical cutin contracts")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
