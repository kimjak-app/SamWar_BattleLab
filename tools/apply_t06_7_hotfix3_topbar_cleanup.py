#!/usr/bin/env python3
from pathlib import Path
import re

path = Path('scripts/battle_web_import_test.gd')
raw = path.read_bytes()
newline = '\r\n' if b'\r\n' in raw else '\n'
text = raw.decode('utf-8').replace('\r\n', '\n')

replacement = '''func _configure_momentum_ui() -> void:\n\t_remove_legacy_top_bar_background()\n\t_refresh_runtime_momentum_hud()\n\n\nfunc _remove_legacy_top_bar_background() -> void:\n\tvar top_bar := get_node_or_null("BattleUI/TopBar") as Control\n\tif top_bar == null:\n\t\treturn\n\tif top_bar is ColorRect:\n\t\tvar top_bar_color := (top_bar as ColorRect).color\n\t\ttop_bar_color.a = 0.0\n\t\t(top_bar as ColorRect).color = top_bar_color\n\telif top_bar is Panel:\n\t\t(top_bar as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())\n\telif top_bar is PanelContainer:\n\t\t(top_bar as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())\n\tfor child in top_bar.get_children():\n\t\tif child is ColorRect:\n\t\t\tvar child_color := (child as ColorRect).color\n\t\t\tchild_color.a = 0.0\n\t\t\t(child as ColorRect).color = child_color\n\t\telif child is Panel:\n\t\t\t(child as Panel).add_theme_stylebox_override("panel", StyleBoxEmpty.new())\n\t\telif child is PanelContainer:\n\t\t\t(child as PanelContainer).add_theme_stylebox_override("panel", StyleBoxEmpty.new())\n'''

pattern = re.compile(r'^func _configure_momentum_ui\(\) -> void:\n.*?(?=^func _refresh_momentum_ui\(\) -> void:)', re.M | re.S)
match = pattern.search(text)
if not match:
    raise SystemExit('configure momentum UI block not found')
text = text[:match.start()] + replacement + '\n\n' + text[match.end():]

out = text if newline == '\n' else text.replace('\n', '\r\n')
path.write_bytes(out.encode('utf-8'))
print('T06-7-hotfix3 top bar cleanup applied')
