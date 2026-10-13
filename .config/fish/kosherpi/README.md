# kosherpi

```fish
kosherpi                       # Pi without Creator Kit skills/extensions
kosherpi --continue            # Normal session/model/output options work
kosherpi --approve             # Trust an unfamiliar project for this run
pi                             # Normal, unfiltered Pi
```

Requires Node.js and an installed Pi CLI/SDK. Supports npm symlinked installs
and Volta-managed Pi (resolves the SDK from `volta which pi`).

The launcher uses Pi's SDK package resolver to discover enabled skills and
extensions without executing extensions. It filters `ck-*` skill names and
resources whose original or canonical path contains a `ck-*` or `creator-kit`
component. Pi is then launched with discovery disabled for those two resource
types and explicit paths to the remaining resources. User and project resources,
including installed package resources, retain their existing enable/disable rules.

Normal settings, credentials, context files, prompts, themes, and session storage
remain under Pi's control. Nothing is temporarily renamed or rewritten. Unlike
Claude, Pi does not load `.claude` hooks; its hook-like behavior comes from
extensions, so CK extensions are excluded before they can execute.

Trust:
- Saved trust and global `defaultProjectTrust` are respected.
- `--approve` and `--no-approve` provide a one-run decision.
- For an undecided project, the launcher asks you to rerun with one of those
  flags (or save trust through normal Pi). It never silently grants trust.

Limitations:
- Resource selection is a launch-time snapshot. Restart to discover added skills
  or extensions. Use plain Pi when switching to a different project's session.
- Existing non-CK exclusions stay in effect. For example, EM's `.pi/settings.json`
  currently excludes Conductor skills; kosherpi does not undo that choice.
- `--skill`/`--extension` arguments are rejected because they bypass filtering.
  Use plain Pi for explicit resources or package/config management commands.
- Missing packages are skipped during discovery, not automatically installed by
  the launcher. Install them using normal Pi first.
- Filtering uses CK naming/path conventions; this is not a sandbox. Retained
  extensions can still dynamically add resources or execute code.

Tests:
```sh
python3 -m unittest discover -s ~/.config/fish/kosherpi -p 'test_*.py'
fish -n ~/.config/fish/functions/kosherpi.fish
```

The tests exercise the real Pi RPC interface without sending a model prompt.
