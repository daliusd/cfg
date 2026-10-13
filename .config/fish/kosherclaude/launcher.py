#!/usr/bin/env python3
"""Launch Claude without project Creator Kit skills/hooks; never edit project files."""
import copy
import json
from pathlib import Path
import subprocess
import sys
import tempfile


def merge(base, overlay):
    """Claude settings: recursive objects, additive unique lists, last scalar wins."""
    result = copy.deepcopy(base)
    for key, value in overlay.items():
        if isinstance(result.get(key), dict) and isinstance(value, dict):
            result[key] = merge(result[key], value)
        elif isinstance(result.get(key), list) and isinstance(value, list):
            for item in value:
                if item not in result[key]:
                    result[key].append(copy.deepcopy(item))
        else:
            result[key] = copy.deepcopy(value)
    return result


def filtered_settings(root):
    data = {}
    for name in ('settings.json', 'settings.local.json'):
        path = root / '.claude' / name
        if path.exists():
            data = merge(data, json.loads(path.read_text()))
    hooks = {}
    for event, groups in data.get('hooks', {}).items():
        kept = []
        for group in groups:
            handlers = [handler for handler in group.get('hooks', [])
                        if 'creator-kit/' not in handler.get('command', '').replace('\\', '/')]
            if handlers:
                kept.append(dict(group, hooks=handlers))
        if kept:
            hooks[event] = kept
    if 'hooks' in data:
        data['hooks'] = hooks
    names = set()
    for folder in ('.agents/skills', '.claude/skills'):
        directory = root / folder
        if not directory.resolve().is_relative_to(root):
            continue
        for skill in directory.glob('ck-*/SKILL.md'):
            if skill.resolve().is_relative_to(root):
                names.add(skill.parent.name)
    if names:
        data.setdefault('skillOverrides', {}).update({name: 'off' for name in sorted(names)})
    return data


def project_plugin_args(root):
    """Restore non-CK skills/plugin directories excluded by --setting-sources.

    Claude accepts both standalone SKILL.md folders and full plugins via
    --plugin-dir. Use original paths so their scripts/references keep working.
    """
    args = []
    seen = set()
    for folder in ('.claude/skills', '.agents/skills'):
        for entry in sorted((root / folder).glob('*')):
            path = entry.resolve()
            if entry.name.startswith('ck-') or path in seen or not entry.is_dir():
                continue
            if not ((entry / 'SKILL.md').is_file()
                    or (entry / '.claude-plugin/plugin.json').is_file()):
                continue
            seen.add(path)
            args.extend(['--plugin-dir', str(path)])
    return args


def main():
    args = sys.argv[1:]
    if args[:1] == ['--']:
        args = args[1:]
    if any(arg.split('=', 1)[0] in ('--settings', '--setting-sources') for arg in args):
        raise ValueError('Custom --settings/--setting-sources would bypass filtering; use plain claude instead.')
    cwd = Path.cwd()
    git = subprocess.run(['git', 'rev-parse', '--show-toplevel'], capture_output=True, text=True)
    root = Path(git.stdout.strip()).resolve() if git.returncode == 0 else cwd
    settings = filtered_settings(root)
    # Exclude BOTH project and local sources: their hook arrays would otherwise merge back in.
    # This also excludes project skills/plugins; restore non-CK directories
    # explicitly without loading their original project hook settings.
    # User/managed settings and installed plugins remain under Claude's control.
    with tempfile.TemporaryDirectory(prefix='kosherclaude-') as tmp:
        path = Path(tmp) / 'settings.json'
        path.write_text(json.dumps(settings, indent=2) + '\n')
        path.chmod(0o600)
        return subprocess.call(['claude', '--setting-sources', 'user', '--settings', str(path),
                                *project_plugin_args(root), *args])


if __name__ == '__main__':
    try:
        sys.exit(main())
    except (ValueError, OSError) as exc:
        print(f'kosherclaude: {exc}', file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        sys.exit(130)
