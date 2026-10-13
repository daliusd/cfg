# kosherclaude

```fish
kosherclaude                   # Claude without project CK hooks/skills
kosherclaude --resume          # Normal Claude arguments are forwarded
claude                        # Normal, unfiltered Claude
```

Requires Python 3.11+, Git, and Claude Code. Run inside the project; the current
Git root supplies `.claude/settings.json` and `.claude/settings.local.json`.
Outside Git, settings come from the current directory.

The launcher merges project/local settings into a private temporary file,
removes command-hook handlers referring to `creator-kit/`, and adds `off`
overrides for project `ck-*` skills. Other handlers, including those sharing a
hook group with CK, are retained. Claude loads this generated file with
`--setting-sources user`, preventing original project/local hooks from merging
back in. Because this also suppresses project skill/plugin discovery, non-CK
folders in `.claude/skills` and `.agents/skills` are explicitly loaded using
`--plugin-dir` (deduplicated by resolved path). Their original scripts and
references remain accessible. Full plugins with `.claude-plugin/plugin.json`
are included too. User/managed settings and installed plugins remain loaded
normally; CK installed there is not filtered. Temporary settings are removed
when Claude exits.

No persistent project settings, skills, Codex configuration, or Pi configuration
are changed. Disabled skills may still be listed in Claude's skills browser.

Limitations:
- Project/local settings and the skill-directory list are snapshots taken at
  launch; restart to pick up edits.
- Explicitly restored skills use Claude's plugin-qualified names. Simple names
  like `/wds-docs` retain aliases; names containing colons may need the qualified
  command shown in `/skills` (e.g. `conductor_use-in-code:conductor:use-in-code`).
- Generated settings are passed through `--settings`, which has higher precedence
  than ordinary settings files. Managed settings still take precedence.
- Claude does not load the original local settings source, so do not rely on
  normal local-settings reload/persistence behavior in this mode. Use plain
  `claude` when editing persistent settings/permission rules.
- Explicit `--settings` and `--setting-sources` arguments are rejected.
- Only root project/local command hooks using the installed CK directory pattern
  are filtered; this is not a sandbox or a security boundary.

The old `ck-enable`/`ck-disable` functions and implementation are archived under
`~/.config/fish/archived-ck-toggle/`. There was no active saved toggle state at
migration. If an existing Fish shell has already loaded the old functions, run
`functions -e ck-enable ck-disable`, or open a new shell.

Tests:
```sh
python3 -m unittest discover -s ~/.config/fish/kosherclaude -p 'test_*.py'
fish -n ~/.config/fish/functions/kosherclaude.fish
```
