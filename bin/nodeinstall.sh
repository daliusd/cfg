#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${1:-} == --yes ]]; then
  shift
fi
(($# == 0)) || { printf 'Usage: nodeinstall.sh [--yes]\n' >&2; exit 2; }

command -v npm >/dev/null 2>&1 || {
  printf 'error: npm is unavailable; install Node through Volta first.\n' >&2
  exit 1
}

# Deliberately preserve the active npm registry (public or Wix private).
# Exporting npm_config_registry also makes Volta's global-install interception
# use that registry instead of silently falling back to registry.npmjs.org.
registry="$(npm config get registry)"
printf 'Using npm registry: %s\n' "$registry"
export npm_config_registry="$registry"

# Node LTS supplies its compatible npm release. Volta hard-codes the public
# registry when replacing npm itself, so updating Node is the registry-safe way
# to update npm; all ordinary global packages use the preserved registry.
npm install --global corepack@latest

# Pi's official quickstart explicitly disables dependency lifecycle scripts.
npm install --global --ignore-scripts '@earendil-works/pi-coding-agent@latest'

# agent-browser's package postinstall rewrites npm shims to a temporary path,
# which is incompatible with Volta. Its JS launcher selects the bundled native
# binary correctly, so lifecycle scripts are intentionally disabled here too.
npm install --global --ignore-scripts 'agent-browser@latest'

packages=(
  '@daliusd/lang-lsp@latest'
  'typescript@7'
  'cssmodules-language-server@latest'
  'tsx@latest'
  'vscode-langservers-extracted@latest'
  'yaml-language-server@latest'
)

npm install --global "${packages[@]}"

# Corepack may already be enabled by Volta; failure here should be visible but
# should not discard otherwise successful package installation.
corepack enable || printf 'warning: corepack was installed but could not be enabled.\n' >&2
