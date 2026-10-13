import importlib.util
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('launcher.py')


class LauncherTest(unittest.TestCase):
    def test_filters_only_ck_handlers_and_merges_local_settings(self):
        spec = importlib.util.spec_from_file_location('launcher', SCRIPT)
        self.assertIsNotNone(spec)
        if not SCRIPT.exists():
            self.fail('Filtered Claude launcher is not implemented')
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            folder = root / '.claude'
            folder.mkdir()
            project = folder / 'settings.json'
            local = folder / 'settings.local.json'
            project.write_text(json.dumps({
                'model': 'project', 'permissions': {'allow': ['Bash(git *)']},
                'hooks': {'Stop': [{'matcher': 'anything', 'hooks': [
                    {'type': 'command', 'command': './hooks/creator-kit/logger.js'},
                    {'type': 'command', 'command': './hooks/lint.sh'}]}]}}))
            local.write_text(json.dumps({
                'model': 'local', 'permissions': {'allow': ['Bash(git *)', 'Bash(ls *)']},
                'skillOverrides': {'ck-example': 'off'},
                'hooks': {'SessionStart': [{'hooks': [
                    {'type': 'command', 'command': './hooks/creator-kit/context.js'}]}]}}))
            skill = root / '.agents/skills/ck-discovery'
            skill.mkdir(parents=True)
            (skill / 'SKILL.md').write_text('CK skill')
            before = (project.read_bytes(), local.read_bytes())
            result = module.filtered_settings(root)
            self.assertEqual(result, {
                'model': 'local', 'permissions': {'allow': ['Bash(git *)', 'Bash(ls *)']},
                'skillOverrides': {'ck-example': 'off', 'ck-discovery': 'off'},
                'hooks': {'Stop': [{'matcher': 'anything', 'hooks': [
                    {'type': 'command', 'command': './hooks/lint.sh'}]}]}})
            self.assertEqual((project.read_bytes(), local.read_bytes()), before)

    def test_launch_passes_settings_arguments_cwd_and_exit_status(self):
        if not SCRIPT.exists():
            self.fail('Filtered Claude launcher is not implemented')
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / 'project with spaces'
            folder = root / '.claude'
            folder.mkdir(parents=True)
            (folder / 'settings.json').write_text('{"model": "project"}')
            capture = Path(tmp) / 'capture.json'
            executable = Path(tmp) / 'claude'
            executable.write_text(
                '#!/usr/bin/env python3\nimport json, os, pathlib, sys\n'
                'args = sys.argv[1:]\n'
                'settings = pathlib.Path(args[args.index("--settings") + 1])\n'
                'pathlib.Path(os.environ["CAPTURE"]).write_text(json.dumps({'
                '"args": args, "cwd": os.getcwd(), '
                '"settings": json.loads(settings.read_text()), "path": str(settings)}))\n'
                'sys.exit(7)\n')
            executable.chmod(0o700)
            env = dict(os.environ, PATH=str(executable.parent) + os.pathsep + os.environ['PATH'],
                       CAPTURE=str(capture))
            result = subprocess.run(['python3', str(SCRIPT), '--', '--resume', 'session'],
                                    cwd=root, env=env, capture_output=True, text=True)
            self.assertEqual(result.returncode, 7, result.stderr)
            saved = json.loads(capture.read_text())
            self.assertEqual(saved['args'][:2], ['--setting-sources', 'user'])
            self.assertEqual(saved['args'][-2:], ['--resume', 'session'])
            self.assertEqual(saved['cwd'], str(root))
            self.assertEqual(saved['settings'], {'model': 'project'})
            self.assertFalse(Path(saved['path']).exists())

    def test_project_skills_load_without_ck_skills(self):
        # Source filtering must not hide unrelated project skills/plugins.
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            skills = root / '.agents/skills'
            for directory, name in [('wds-docs', 'wds-docs'),
                                    ('conductor_use-in-code', 'conductor:use-in-code'),
                                    ('ck-example', 'ck-example')]:
                skill = skills / directory
                skill.mkdir(parents=True)
                (skill / 'SKILL.md').write_text(
                    f'---\nname: {name}\ndescription: Regression fixture\n---\nInstructions\n')
            plugin = skills / 'example-plugin'
            (plugin / '.claude-plugin').mkdir(parents=True)
            (plugin / '.claude-plugin/plugin.json').write_text('{"name":"example-plugin"}')
            (plugin / 'skills/check').mkdir(parents=True)
            (plugin / 'skills/check/SKILL.md').write_text(
                '---\nname: check\ndescription: Plugin regression fixture\n---\nInstructions\n')
            (root / '.claude').mkdir()
            (root / '.claude/skills').symlink_to(skills, target_is_directory=True)
            before = sorted(str(path.relative_to(root)) for path in root.rglob('*'))
            request = json.dumps({'type': 'control_request', 'request_id': 'test',
                                  'request': {'subtype': 'initialize'}}) + '\n'
            result = subprocess.run(
                ['python3', str(SCRIPT), '--', '--print', '--verbose',
                 '--input-format', 'stream-json', '--output-format', 'stream-json'],
                input=request, cwd=root, capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            responses = [json.loads(line) for line in result.stdout.splitlines()]
            response = next(row['response']['response'] for row in responses
                            if row.get('type') == 'control_response')
            names = set()
            for command in response['commands']:
                names.add(command['name'])
                names.update(command.get('aliases', []))
            self.assertIn('wds-docs', names)
            self.assertIn('conductor_use-in-code:conductor:use-in-code', names)
            self.assertIn('example-plugin:check', names)
            self.assertFalse(any('ck-example' in name for name in names))
            self.assertEqual(before, sorted(str(path.relative_to(root))
                                            for path in root.rglob('*')))

    def test_rejects_settings_flags_that_bypass_filtering(self):
        if not SCRIPT.exists():
            self.fail('Filtered Claude launcher is not implemented')
        for flag in ('--settings', '--setting-sources=project'):
            result = subprocess.run(['python3', str(SCRIPT), '--', flag],
                                    capture_output=True, text=True)
            self.assertEqual(result.returncode, 1)
            self.assertIn('settings', result.stderr)


if __name__ == '__main__':
    unittest.main()
