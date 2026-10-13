import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('launcher.mjs')


class LauncherTest(unittest.TestCase):
    def test_keeps_non_ck_skills_extensions_and_settings_without_writes(self):
        self.assertTrue(SCRIPT.exists(), 'kosherpi launcher is not implemented')
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / 'project with spaces'
            agent = Path(tmp) / 'agent'
            agent.mkdir()
            (agent / 'settings.json').write_text('{"theme":"light","packages":[]}')
            for folder, name in [('wds-docs', 'wds-docs'),
                                 ('conductor_use-in-code', 'conductor:use-in-code'),
                                 ('ck-example', 'ck-example'), ('excluded', 'excluded')]:
                skill = root / '.agents/skills' / folder
                skill.mkdir(parents=True)
                (skill / 'SKILL.md').write_text(
                    f'---\nname: {name}\ndescription: Regression fixture\n---\nInstructions\n')
            extensions = root / '.pi/extensions'
            extensions.mkdir(parents=True)
            (extensions / 'useful.ts').write_text(
                'export default function(pi) { pi.registerCommand("useful", '
                '{description: "Retained extension", handler: async () => {}}); }')
            ck = extensions / 'creator-kit'
            ck.mkdir()
            (ck / 'index.ts').write_text('throw new Error("CK extension must never execute");')
            settings = root / '.pi/settings.json'
            settings.write_text(json.dumps({'skills': ['!**/excluded/**']}))
            before = {str(p): p.read_bytes() for directory in (root, agent)
                      for p in directory.rglob('*') if p.is_file()}
            env = dict(os.environ, PI_CODING_AGENT_DIR=str(agent), PI_OFFLINE='1')
            result = subprocess.run(
                ['node', str(SCRIPT), '--approve', '--mode', 'rpc', '--no-session'],
                cwd=root, env=env, input='{"id":"commands","type":"get_commands"}\n',
                capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            response = next(json.loads(line) for line in result.stdout.splitlines()
                            if json.loads(line).get('id') == 'commands')
            self.assertTrue(response['success'], response)
            names = {command['name'] for command in response['data']['commands']}
            self.assertIn('skill:wds-docs', names)
            self.assertIn('skill:conductor:use-in-code', names)
            self.assertIn('useful', names)
            self.assertNotIn('skill:ck-example', names)
            self.assertNotIn('skill:excluded', names)
            for path, content in before.items():
                self.assertEqual(Path(path).read_bytes(), content, path)

    def test_fish_function_works_with_volta_node_path_rewriting(self):
        result = subprocess.run(['fish', '-c', 'kosherpi --no-approve --help'],
                                capture_output=True, text=True, timeout=30)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('Usage:', result.stdout)

    def test_does_not_load_project_skills_when_trust_declined(self):
        self.assertTrue(SCRIPT.exists(), 'kosherpi launcher is not implemented')
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            skill = root / '.agents/skills/example'
            skill.mkdir(parents=True)
            (skill / 'SKILL.md').write_text(
                '---\nname: example\ndescription: Test skill\n---\nInstructions\n')
            result = subprocess.run(
                ['node', str(SCRIPT), '--no-approve', '--mode', 'rpc', '--no-session', '--offline'],
                cwd=root, input='{"id":"commands","type":"get_commands"}\n',
                capture_output=True, text=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stderr)
            response = next(json.loads(line) for line in result.stdout.splitlines()
                            if json.loads(line).get('id') == 'commands')
            names = {command['name'] for command in response['data']['commands']}
            self.assertNotIn('skill:example', names)


if __name__ == '__main__':
    unittest.main()
