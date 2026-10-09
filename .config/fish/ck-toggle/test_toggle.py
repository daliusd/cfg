import json
import os
from pathlib import Path
import subprocess
import tempfile
import tomllib
import unittest

SCRIPT = Path(__file__).with_name('toggle.py')


class ToggleTest(unittest.TestCase):
    def test_git_clean_roundtrip(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / 'project with spaces'
            skills = root / '.agents/skills'
            (skills / 'ck-example').mkdir(parents=True)
            (skills / 'ck-example/SKILL.md').write_text('---\nname: ck-example\ndescription: CK\n---\nCK')
            (skills / 'other').mkdir()
            (skills / 'other/SKILL.md').write_text('Other')
            (root / '.claude').mkdir()
            (root / '.claude/skills').symlink_to('../.agents/skills')
            tracked = root / '.claude/settings.json'
            tracked.write_text('{"hooks": {"Stop": []}}')
            local = root / '.claude/settings.local.json'
            local.write_text('{"skillOverrides": {"ck-example": "name-only", "other": "off"}}')
            pi = root / '.pi/settings.json'
            pi.parent.mkdir()
            pi.write_text('{"skills": ["!**/other/**"]}')
            hooks = root / '.codex/hooks.json'
            hooks.parent.mkdir()
            hooks.write_text(json.dumps({'hooks': {'Stop': [{'hooks': [
                {'command': './hooks/creator-kit/logger.js'}, {'command': './hooks/lint.sh'}]}]}}))
            home = Path(tmp) / 'codex-home'
            home.mkdir()
            config = home / 'config.toml'
            hook_key = str(hooks) + ':stop:0:0'
            original = '# Preserve comments\nmodel = "test"\n[hooks.state.' + json.dumps(hook_key) + ']\ntrusted_hash = "sha256:keep"\n'
            config.write_text(original)
            subprocess.run(['git', 'init', '-q', str(root)], check=True)
            # Only actual project resources tracked, local config remains untracked.
            subprocess.run(['git', '-C', str(root), 'add', '.agents', '.claude/settings.json',
                            '.claude/skills', '.codex/hooks.json'], check=True)
            before_status = subprocess.check_output(['git', '-C', str(root), 'diff', '--cached'])
            script = Path(tmp) / 'toggle.py'
            script.write_text(SCRIPT.read_text())
            env = dict(os.environ, CODEX_HOME=str(home))

            def run(action, success=True):
                result = subprocess.run(['python3', str(script), action, str(root)],
                                        env=env, capture_output=True, text=True)
                self.assertEqual(result.returncode == 0, success, result.stderr)

            run('disable')
            self.assertTrue((skills / 'ck-example/SKILL.md').exists())
            self.assertTrue(json.loads(local.read_text())['disableAllHooks'])
            self.assertEqual(json.loads(local.read_text())['skillOverrides']['ck-example'], 'off')
            self.assertIn('!**/skills/ck-*/**', json.loads(pi.read_text())['skills'])
            data = tomllib.loads(config.read_text())
            self.assertFalse(data['hooks']['state'][hook_key]['enabled'])
            self.assertEqual(data['hooks']['state'][hook_key]['trusted_hash'], 'sha256:keep')
            self.assertFalse(data['skills']['config'][0]['enabled'])
            self.assertEqual(data['skills']['config'][0]['path'], str(skills / 'ck-example/SKILL.md'))
            self.assertEqual(subprocess.check_output(['git', '-C', str(root), 'diff']), b'')
            self.assertEqual(subprocess.check_output(['git', '-C', str(root), 'diff', '--cached']), before_status)
            subprocess.run(['git', '-C', str(root), 'check-ignore', '-q', str(pi)], check=True)
            run('disable')
            # Unrelated local changes survive; tracked files stay untouched.
            data = json.loads(local.read_text())
            data['permissions'] = {'allow': ['new']}
            local.write_text(json.dumps(data))
            data = json.loads(pi.read_text())
            data['skills'].append('!**/another/**')
            pi.write_text(json.dumps(data))
            config.write_text(config.read_text() + '\n# Unrelated later comment\n')
            run('enable')
            self.assertNotIn('disableAllHooks', json.loads(local.read_text()))
            self.assertEqual(json.loads(local.read_text())['skillOverrides']['ck-example'], 'name-only')
            self.assertEqual(json.loads(local.read_text())['permissions']['allow'], ['new'])
            self.assertEqual(json.loads(pi.read_text())['skills'], ['!**/other/**', '!**/another/**'])
            self.assertEqual(config.read_text(), original + '\n# Unrelated later comment\n')
            run('enable')
            run('disable')
            data = json.loads(local.read_text())
            data['skillOverrides']['ck-example'] = 'on'
            local.write_text(json.dumps(data))
            run('enable', success=False)
            data['skillOverrides']['ck-example'] = 'off'
            local.write_text(json.dumps(data))
            run('enable')


if __name__ == '__main__':
    unittest.main()
