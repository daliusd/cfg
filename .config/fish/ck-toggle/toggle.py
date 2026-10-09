#!/usr/bin/env python3
"""Toggle project CK skills without changing tracked project files (Python 3.11+)."""
import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tomllib

MISSING = {'__ck_missing__': True}
PI_EXCLUSION = '!**/skills/ck-*/**'


def text_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + '.ck-tmp')
    tmp.write_text(text)
    tmp.chmod(path.stat().st_mode & 0o777 if path.exists() else 0o600)
    tmp.replace(path)


def dump(path, value):
    text_write(path, json.dumps(value, indent=2) + '\n')


def git(root, *args):
    return subprocess.run(['git', '-C', str(root), *args], capture_output=True, text=True)


def project(path):
    path = Path(path).expanduser().resolve()
    if not path.is_dir():
        raise ValueError(f'Not a directory: {path}')
    result = git(path, 'rev-parse', '--show-toplevel')
    return Path(result.stdout.strip()).resolve() if result.returncode == 0 else path


def local_only(root, path):
    relative = path.relative_to(root).as_posix()
    if git(root, 'ls-files', '--error-unmatch', '--', relative).returncode == 0:
        raise ValueError(f'{path} is tracked. Untrack it before using local CK overrides.')
    result = git(root, 'rev-parse', '--git-path', 'info/exclude')
    if result.returncode == 0 and git(root, 'check-ignore', '--quiet', '--', relative).returncode != 0:
        exclude = Path(result.stdout.strip())
        if not exclude.is_absolute():
            exclude = root / exclude
        old = exclude.read_text() if exclude.exists() else ''
        text_write(exclude, old + ('\n' if old and not old.endswith('\n') else '') + '/' + relative + '\n')


def resources(root):
    skills = set()
    for folder in ('.agents/skills', '.claude/skills', '.codex/skills', '.pi/skills'):
        directory = root / folder
        if not directory.is_dir():
            continue
        if not directory.resolve().is_relative_to(root):
            raise ValueError(f'Refusing global/external skills directory: {directory}')
        for item in directory.glob('ck-*/SKILL.md'):
            if not item.resolve().is_relative_to(root):
                raise ValueError(f'Refusing external skill: {item}')
            skills.add(item.resolve())
    return sorted(skills)


def header_path(line):
    if not re.match(r'^\s*\[(?!\[)', line):
        return None
    try:
        data = tomllib.loads(line + '\n__ck_probe__ = true\n')
        keys = []
        while isinstance(data, dict) and '__ck_probe__' not in data and len(data) == 1:
            key, data = next(iter(data.items()))
            keys.append(key)
        return tuple(keys) if isinstance(data, dict) and '__ck_probe__' in data else None
    except tomllib.TOMLDecodeError:
        return None


def codex_plan(path, skills, hook_keys, key):
    text = path.read_text() if path.exists() else ''
    parsed = tomllib.loads(text)
    replacements = []
    additions = []
    marker = f'ck-toggle:{key}'
    # Absolute path selectors affect only this project's skills, not identically named global ones.
    existing = parsed.get('skills', {}).get('config', [])
    for skill in skills:
        if any(e.get('path') == str(skill) and e.get('enabled') is False for e in existing):
            continue
        additions.append('[[skills.config]]\npath = ' + json.dumps(str(skill)) + '\nenabled = false\n')
    for hook_key in hook_keys:
        entry = parsed.get('hooks', {}).get('state', {}).get(hook_key, {})
        if entry.get('enabled') is False:
            continue
        lines = text.splitlines(keepends=True)
        start = next((i for i, line in enumerate(lines)
                      if header_path(line) == ('hooks', 'state', hook_key)), None)
        tagged = f'enabled = false # {marker}:{hashlib.sha256(hook_key.encode()).hexdigest()[:16]}\n'
        if start is None:
            if entry:
                raise ValueError('Unsupported inline Codex hook-state table; use explicit TOML tables.')
            additions.append('[hooks.state.' + json.dumps(hook_key) + ']\n' + tagged)
            continue
        end = next((i for i in range(start + 1, len(lines))
                    if re.match(r'^\s*\[', lines[i])), len(lines))
        enabled = next((i for i in range(start + 1, end)
                        if re.match(r'^\s*enabled\s*=', lines[i])), None)
        original = lines[enabled] if enabled is not None else ''
        if enabled is None:
            lines.insert(start + 1, tagged)
        else:
            lines[enabled] = tagged
        replacements.append({'old': original, 'new': tagged})
        text = ''.join(lines)
    if additions:
        block = f'\n# BEGIN {marker}\n' + '\n'.join(additions) + f'# END {marker}\n'
        text += block
        replacements.append({'old': '', 'new': block})
    # Refuse unsupported TOML forms rather than silently corrupting user configuration.
    tomllib.loads(text)
    return text, replacements


def hook_keys(root):
    path = root / '.codex/hooks.json'
    if not path.exists():
        return []
    data = json.loads(path.read_text()).get('hooks', {})
    result = []
    for event, groups in data.items():
        label = re.sub(r'(?<!^)(?=[A-Z])', '_', event).lower()
        for i, group in enumerate(groups):
            for j, handler in enumerate(group.get('hooks', [])):
                if 'creator-kit' in json.dumps(handler):
                    result.append(f'{path}:{label}:{i}:{j}')
    return result


def get(data, keys):
    return (data if len(keys) == 1 else data.get(keys[0], {})).get(keys[-1], MISSING)


def put(data, keys, value):
    target = data if len(keys) == 1 else data.setdefault(keys[0], {})
    if value == MISSING:
        target.pop(keys[-1], None)
    else:
        target[keys[-1]] = value


def disable(root, state, key):
    if state.exists():
        print('CK already disabled. Enable then disable again to include newly installed skills/hooks.')
        return
    skills = resources(root)
    hooks = hook_keys(root)
    if not skills and not hooks:
        print(f'No project CK resources found in {root}')
        return
    names = sorted({p.parent.name for p in skills})
    files = []
    plans = []
    for relative in ('.claude/settings.local.json', '.pi/settings.json'):
        path = root / relative
        local_only(root, path)
        existed = path.exists()
        data = json.loads(path.read_text()) if existed else {}
        changes = []
        if relative.startswith('.claude'):
            desired = [(('disableAllHooks',), True)] + [(('skillOverrides', name), 'off') for name in names]
        else:
            desired = [] if PI_EXCLUSION in data.get('skills', []) else [
                (('skills',), data.get('skills', []) + [PI_EXCLUSION])]
        for keys, after in desired:
            before = get(data, keys)
            if before != after:
                changes.append({'keys': keys, 'before': before, 'after': after})
                put(data, keys, after)
        if changes:
            files.append({'path': str(path), 'existed': existed, 'changes': changes})
            plans.append((path, json.dumps(data, indent=2) + '\n'))
    codex = Path(os.environ.get('CODEX_HOME', str(Path.home() / '.codex'))) / 'config.toml'
    codex_text, replacements = codex_plan(codex, skills, hooks, key)
    if replacements:
        plans.append((codex, codex_text))
    # Write the recovery journal first. Enable handles interrupted operations as well.
    dump(state, {'version': 2, 'root': str(root), 'files': files,
                 'codex': str(codex), 'replacements': replacements})
    for path, text in plans:
        text_write(path, text)
    print(f'CK disabled in {root}: {len(skills)} skills; Claude all hooks; Codex {len(hooks)} CK hooks.')
    print('Tracked project files untouched. Restart agents; re-toggle after aicm updates.')


def enable(root, state):
    if not state.exists():
        print('No saved CK disable state; nothing to restore.')
        return
    saved = json.loads(state.read_text())
    if saved.get('version') != 2:
        raise ValueError(f'Legacy moving-based state found at {state}; restore it using the legacy script first.')
    plans = []
    for entry in saved['files']:
        path = Path(entry['path'])
        data = json.loads(path.read_text()) if path.exists() else {}
        for change in entry['changes']:
            current = get(data, change['keys'])
            if current == change['before']:
                continue
            # Remove only our Pi exclusion, preserving other exclusion edits.
            if change['keys'] == ['skills'] and isinstance(current, list):
                if PI_EXCLUSION in current:
                    current.remove(PI_EXCLUSION)
                if not current and change['before'] == MISSING:
                    put(data, change['keys'], MISSING)
                else:
                    put(data, change['keys'], current)
                continue
            if current != change['after']:
                raise ValueError(f'Override changed: {path}, {change["keys"]}. Recovery state: {state}')
            put(data, change['keys'], change['before'])
        if data.get('skillOverrides') == {}:
            data.pop('skillOverrides')
        plans.append((path, None if not entry['existed'] and not data else json.dumps(data, indent=2) + '\n'))
    codex = Path(saved['codex'])
    text = codex.read_text() if codex.exists() else ''
    for replacement in reversed(saved['replacements']):
        if replacement['new'] not in text:
            # Missing generated text may mean disable was interrupted before this file was written.
            if '# BEGIN ck-toggle:' in text or 'enabled = false # ck-toggle:' in text:
                raise ValueError(f'Codex override changed; check recovery state: {state}')
            continue
        if text.count(replacement['new']) != 1:
            raise ValueError(f'Ambiguous Codex override; recovery state: {state}')
        text = text.replace(replacement['new'], replacement['old'], 1)
    tomllib.loads(text)
    if saved['replacements']:
        plans.append((codex, text))
    for path, text in plans:
        if text is None:
            path.unlink(missing_ok=True)
        else:
            text_write(path, text)
    state.unlink()
    print(f'CK restored in {root}. Previous exclusions and hook preferences preserved. Restart agents.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['disable', 'enable'])
    parser.add_argument('project', nargs='?', default='.', help='project path (default: current Git root)')
    args = parser.parse_args()
    root = project(args.project)
    if root in (Path.home(), Path('/')):
        raise ValueError('Refusing home/root directory; choose a project.')
    key = hashlib.sha256(str(root).encode()).hexdigest()[:24]
    base = Path(__file__).resolve().parent / 'state' / key
    base.mkdir(parents=True, exist_ok=True, mode=0o700)
    with (base / 'lock').open('w') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        if args.action == 'disable':
            disable(root, base / 'state.json', key)
        else:
            enable(root, base / 'state.json')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError) as exc:
        print(f'ck-toggle: {exc}', file=sys.stderr)
        sys.exit(1)
