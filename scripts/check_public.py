#!/usr/bin/env python3
# Copyright (c) 2026 Scott Armstrong and Vlad Vicol.
# Released under Apache 2.0 license.
"""Check the published file set, local documentation links and source references.

In a Git checkout the tracked files are checked; in an unversioned tree (for
example a freshly exported one) every file outside `.lake/` and `.git/` is.
"""
from pathlib import Path
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(Path(__file__).resolve().parent))
import check_axioms  # noqa: E402
ROOT_FILES = {
    '.gitignore', 'CITATION.cff', 'CIV.lean', 'CONTRIBUTING.md', 'LICENSE',
    'README.md', 'formalization.yaml', 'lake-manifest.json', 'lakefile.toml',
    'lean-toolchain', 'comparator.json', 'Challenge.lean', 'Solution.lean',
}
REQUIRED = ROOT_FILES | {'paper/NSE_Anisotropic_Pointwise.tex'}
DIRECTORIES = {'CIV', 'comparators', 'docs', 'paper', 'scripts', '.github'}
TEXT_SUFFIXES = {'.lean', '.md', '.tex', '.bib', '.py', '.sh', '.toml', '.yaml', '.yml', '.json', '.cff', '.txt'}


def release_files() -> list[str]:
    result = subprocess.run(['git', 'ls-files', '-z'], cwd=ROOT, capture_output=True)
    if result.returncode == 0 and (ROOT / '.git').exists():
        return result.stdout.decode().split('\0')[:-1]
    return sorted(
        path.relative_to(ROOT).as_posix()
        for path in ROOT.rglob('*')
        if (path.is_file() or path.is_symlink())
        and not {'.git', '.lake', '__pycache__'} & set(path.relative_to(ROOT).parts)
    )


def main() -> int:
    files = release_files()
    errors = []
    if not REQUIRED <= set(files):
        errors.append(f'missing required files: {sorted(REQUIRED - set(files))}')
    for name in files:
        path = Path(name)
        if name not in ROOT_FILES and (len(path.parts) == 1 or path.parts[0] not in DIRECTORIES):
            errors.append(f'unexpected release path: {name}')
        allowed = (
            path.parts[0] == 'CIV' and path.suffix == '.lean'
            or path.parts[0] == 'comparators' and path.suffix in {'.lean', '.md'}
            or path.parts[0] == 'docs' and path.suffix == '.md'
            or path.parts[0] == 'paper' and path.suffix in {'.tex', '.bib'}
            or path.parts[0] == 'scripts' and path.suffix in {'.py', '.sh', '.txt'}
            or path.parts[:2] == ('.github', 'workflows') and path.suffix == '.yml'
            or name in ROOT_FILES
        )
        if not allowed:
            errors.append(f'unexpected release file type: {name}')
        source = ROOT / path
        if source.is_symlink() or not source.is_file():
            errors.append(f'missing or symlinked source: {name}')
            continue
        if path.suffix not in TEXT_SUFFIXES:
            continue
        text = source.read_text(encoding='utf-8')
        if path.suffix == '.md':
            for match in re.finditer(r'\]\(([^\s)]+)\)', text):
                target = match.group(1).split('#')[0]
                if not target or re.match(r'[a-z]+:', target):
                    continue
                destination = (source.parent / target).resolve()
                if not destination.is_relative_to(ROOT) or not destination.exists():
                    errors.append(f'{name}: missing local link {target}')
        if path.suffix == '.lean':
            for module in [m for m in check_axioms.imported_modules(text) if m == 'CIV' or m.startswith('CIV.')]:
                if module.replace('.', '/') + '.lean' not in files:
                    errors.append(f'{name}: missing import {module}')
    for error in errors:
        print(f'check_public: {error}', file=sys.stderr)
    print(f'check_public: {"FAIL" if errors else "PASS"} ({len(files)} files)')
    return bool(errors)


if __name__ == '__main__':
    raise SystemExit(main())
