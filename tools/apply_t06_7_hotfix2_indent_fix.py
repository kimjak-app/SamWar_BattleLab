#!/usr/bin/env python3
from pathlib import Path

path = Path('scripts/battle_web_import_test.gd')
raw = path.read_bytes()
newline = '\r\n' if b'\r\n' in raw else '\n'
text = raw.decode('utf-8').replace('\r\n', '\n')
old = '''\tvar lost := battle_momentum.record_received_hit(defending_side, false, "basic_attack_hit")
\t\t_append_battle_log("%s 기본공격 성공: 기세 +%d" % [attacker.display_name, gained])
\t\t_append_battle_log("%s 피격: 진영 기세 -%d" % [defending_side, lost])
\t_refresh_momentum_ui()
'''
new = '''\tvar lost := battle_momentum.record_received_hit(defending_side, false, "basic_attack_hit")
\t_append_battle_log("%s 기본공격 성공: 기세 +%d" % [attacker.display_name, gained])
\t_append_battle_log("%s 피격: 진영 기세 -%d" % [defending_side, lost])
\t_refresh_momentum_ui()
'''
if old not in text:
    raise SystemExit('target indentation block not found')
text = text.replace(old, new, 1)
out = text if newline == '\n' else text.replace('\n', '\r\n')
path.write_bytes(out.encode('utf-8'))
print('indentation fixed')
