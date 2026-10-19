"""Check committed, staged, unstaged and untracked changes against the fixed base."""
from pathlib import Path
import subprocess, re, sys
ROOT=Path(__file__).resolve().parents[1]
BASE='f8b56c3de0e05c33c620d32e021f4b466f40a984'
def git(*args):
    return subprocess.check_output(['git','-C',str(ROOT),*args],text=True).strip()
patterns=[r'(scripts|scenes|assets)/battle3d/.+',r'tests/scripts/test_battle3d_[^/]+\.gd(?:\.uid)?',r'tools/validate_battle3d_[^/]+\.py',r'agent/BATTLE3D_[^/]+\.md']
changed=set(git('diff','--name-only',BASE,'--').splitlines())
changed.update(git('ls-files','--others','--exclude-standard').splitlines())
errors=[]
for path in sorted(changed):
    if not any(re.fullmatch(p,path) for p in patterns):
        errors.append('Outside new-file allowlist: '+path)
    elif git('ls-tree','--name-only',BASE,'--',path):
        errors.append('Existing base file modified: '+path)
    elif not (ROOT/path).is_file():
        errors.append('Deleted/missing: '+path)
print(f'BATTLE3D_SCOPE {"FAIL" if errors else "PASS"}: {len(changed)} paths; base={BASE}')
for error in errors: print(error)
sys.exit(bool(errors))
