#!/usr/bin/env node
// Resolve Pi resources without executing extensions, then launch the normal CLI.
import { spawn, execFileSync } from 'node:child_process';
import { existsSync, realpathSync } from 'node:fs';
import { dirname, join, parse } from 'node:path';
import { pathToFileURL } from 'node:url';

function piExecutable() {
  let executable;
  try {
    executable = execFileSync('which', ['pi'], { encoding: 'utf8' }).trim();
  } catch {
    // Volta's node shim can remove ~/.volta/bin from its child's PATH.
    return execFileSync('volta', ['which', 'pi'], { encoding: 'utf8' }).trim();
  }
  if (realpathSync(executable).endsWith('/volta-shim')) {
    return execFileSync('volta', ['which', 'pi'], { encoding: 'utf8' }).trim();
  }
  return executable;
}

function piPackageDir(executable) {
  let directory = dirname(realpathSync(executable));
  while (directory !== parse(directory).root) {
    if (existsSync(join(directory, 'dist/index.js')) && existsSync(join(directory, 'dist/cli.js'))) {
      return directory;
    }
    directory = dirname(directory);
  }
  throw new Error('Cannot locate the Pi SDK next to the pi executable.');
}

function isCreatorKit(path) {
  return path.split(/[\\/]/).some(part => part === 'creator-kit' || part.startsWith('ck-'));
}

async function main() {
  const args = process.argv.slice(2);
  const options = args.slice(0, args.indexOf('--') < 0 ? args.length : args.indexOf('--'));
  if (options.some(arg => ['--extension', '-e', '--skill'].includes(arg.split('=')[0]))) {
    throw new Error('Explicit --skill/--extension paths bypass filtering; use plain pi instead.');
  }
  if (['install', 'remove', 'uninstall', 'update', 'config'].includes(args[0])) {
    throw new Error('Use plain pi to manage persistent packages/settings.');
  }
  const executable = piExecutable();
  const sdk = await import(pathToFileURL(join(piPackageDir(executable), 'dist/index.js')).href);
  const cwd = process.cwd();
  const agentDir = sdk.getAgentDir();
  const settings = sdk.SettingsManager.create(cwd, agentDir, { projectTrusted: false });
  let trusted = new sdk.ProjectTrustStore(agentDir).get(cwd);
  if (options.some(arg => arg === '--approve' || arg === '-a')) trusted = true;
  if (options.some(arg => arg === '--no-approve' || arg === '-na')) trusted = false;
  if (trusted === undefined) {
    const policy = settings.getDefaultProjectTrust();
    if (policy === 'always' || !sdk.hasTrustRequiringProjectResources(cwd)) trusted = true;
    else if (policy === 'never') trusted = false;
    else throw new Error('Project trust is undecided. Use kosherpi --approve or --no-approve, or save trust with pi /trust.');
  }
  settings.setProjectTrusted(trusted);
  await settings.reload();
  const manager = new sdk.DefaultPackageManager({ cwd, agentDir, settingsManager: settings });
  // Do not install missing packages during the resource-discovery pass.
  const resources = await manager.resolve(async () => 'skip');
  const filtered = ['--no-skills', '--no-extensions'];
  if (!options.some(arg => arg === '--no-skills' || arg === '-ns')) {
    const paths = resources.skills.filter(resource => resource.enabled).map(resource => resource.path);
    const { skills } = sdk.loadSkills({ cwd, agentDir, skillPaths: paths, includeDefaults: false });
    for (const skill of skills) {
      if (!skill.name.startsWith('ck-') && !isCreatorKit(skill.filePath)
          && !isCreatorKit(realpathSync(skill.filePath))) {
        filtered.push('--skill', skill.filePath);
      }
    }
  }
  if (!options.some(arg => arg === '--no-extensions' || arg === '-ne')) {
    for (const resource of resources.extensions) {
      if (resource.enabled && !isCreatorKit(resource.path)
          && !isCreatorKit(realpathSync(resource.path))) {
        filtered.push('--extension', resource.path);
      }
    }
  }
  const child = spawn(executable, [...filtered, ...args], { stdio: 'inherit' });
  // Terminal SIGINT already reaches Pi; keep the launcher alive while Pi handles it.
  process.on('SIGINT', () => {});
  process.on('SIGTERM', () => child.kill('SIGTERM'));
  child.on('error', error => {
    console.error(`kosherpi: ${error.message}`);
    process.exitCode = 1;
  });
  child.on('exit', (code, signal) => {
    process.exitCode = code ?? (signal === 'SIGINT' ? 130 : 143);
  });
}

main().catch(error => {
  console.error(`kosherpi: ${error.message}`);
  process.exitCode = 1;
});
