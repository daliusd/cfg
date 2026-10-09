# CK toggle

```fish
ck-disable                 # Current Git project
ck-enable                  # Restore previous settings
ck-disable ~/projects/em   # Explicit project
```

Requires Python 3.11+. Restart agents after toggling.

- Claude: CK skill overrides and all hooks disabled in `.claude/settings.local.json`.
- Pi: CK skill exclusion in `.pi/settings.json`.
- Codex: absolute project skill paths and individual CK hook keys disabled in
  `$CODEX_HOME/config.toml` (defaults to `~/.codex/config.toml`).

Tracked project files stay untouched. Local configs are ignored through Git's
`info/exclude` if needed. Agent overrides must live in the agent-specific locations;
all implementation, tests, and recovery state live here.

`ck-enable` restores previous preferences while preserving unrelated edits.
Conflicting edits fail safely; the recovery journal remains in `state/`.
Re-enable and disable again after installing/updating CK to refresh skill/hook lists.
Claude's `/skills` menu can still list disabled skills as author-locked; they are not
invocable.

Run tests: `python3 ~/.config/fish/ck-toggle/test_toggle.py`
