"""Check the C-0~C-3 change set (BASE..TIP) adds only allowed new files.

TIP is the reviewed feature tip. After the integration merge the branch carries
unrelated later work, so the guard is pinned to the C-0~C-3 range instead of HEAD.
Set BATTLE3D_SCOPE_TIP=HEAD to audit uncommitted/later work against the same rules.
"""
from pathlib import Path
import os, subprocess, re, sys
ROOT=Path(__file__).resolve().parents[1]
BASE='f8b56c3de0e05c33c620d32e021f4b466f40a984'
TIP=os.environ.get('BATTLE3D_SCOPE_TIP','084b5d3ae1eec797cae037308f7130a0431cd868')
def git(*args):
    return subprocess.check_output(['git','-C',str(ROOT),*args],text=True).strip()
patterns=[r'(scripts|scenes|assets)/battle3d/.+',r'tests/scripts/test_battle3d_[^/]+\.gd(?:\.uid)?',r'tools/validate_battle3d_[^/]+\.py',r'agent/BATTLE3D_[^/]+\.md']
changed=set(git('diff','--name-only',BASE,TIP,'--').splitlines())
if TIP=='HEAD':
    changed.update(git('diff','--name-only',BASE,'--').splitlines())
    changed.update(git('ls-files','--others','--exclude-standard').splitlines())
errors=[]
for path in sorted(changed):
    if not any(re.fullmatch(p,path) for p in patterns):
        errors.append('Outside new-file allowlist: '+path)
    elif git('ls-tree','--name-only',BASE,'--',path):
        errors.append('Existing base file modified: '+path)
    elif not git('ls-tree','--name-only',TIP,'--',path):
        errors.append('Deleted/missing: '+path)
print(f'BATTLE3D_SCOPE {"FAIL" if errors else "PASS"}: {len(changed)} paths; base={BASE[:7]} tip={TIP[:7]}')
for error in errors: print(error)
sys.exit(bool(errors))
