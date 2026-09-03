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
command -v volta >/dev/null 2>&1 || {
  printf 'error: Volta is unavailable.\n' >&2
  exit 1
}

# Deliberately preserve the active npm registry (public or Wix private).
# Exporting npm_config_registry also makes Volta's global-install interception
# use that registry instead of silently falling back to registry.npmjs.org.
registry="$(npm config get registry)"
printf 'Using npm registry: %s\n' "$registry"
export npm_config_registry="$registry"

installed_version() {
  local package=$1 line version
  line="$(volta list --format plain | grep -F "package ${package}@" | head -n 1 || true)"
  [[ -n $line ]] || return 1
  version="${line#package ${package}@}"
  printf '%s\n' "${version%% *}"
}

ensure_package() {
  local spec=$1 package wanted installed
  shift
  package="${spec%@*}"
  wanted="$(npm view "$spec" version | tail -n 1)"
  installed="$(installed_version "$package" || true)"
  if [[ -n $wanted && $installed == "$wanted" ]]; then
    printf '%s %s is already the latest release\n' "$package" "$installed"
    return
  fi
  printf 'Installing %s (installed: %s, latest: %s)\n' \
    "$package" "${installed:-missing}" "$wanted"
  npm install --global "$@" "$spec"
}

# Node LTS supplies its compatible npm release. Volta hard-codes the public
# registry when replacing npm itself, so updating Node is the registry-safe way
# to update npm; all ordinary global packages use the preserved registry.
ensure_package 'corepack@latest'

# Pi's official quickstart explicitly disables dependency lifecycle scripts.
ensure_package '@earendil-works/pi-coding-agent@latest' --ignore-scripts

# agent-browser's package postinstall rewrites npm shims to a temporary path,
# which is incompatible with Volta. Its JS launcher selects the bundled native
# binary correctly, so lifecycle scripts are intentionally disabled here too.
ensure_package 'agent-browser@latest' --ignore-scripts

# OpenAI Codex CLI: https://learn.chatgpt.com/docs/codex/cli
ensure_package '@openai/codex@latest'

packages=(
  '@daliusd/lang-lsp@latest'
  'typescript@7'
  'cssmodules-language-server@latest'
  'tsx@latest'
  'vscode-langservers-extracted@latest'
  'yaml-language-server@latest'
)
for package in "${packages[@]}"; do
  ensure_package "$package"
done

# Corepack may already be enabled by Volta; failure here should be visible but
# should not discard otherwise successful package installation.
corepack enable || printf 'warning: corepack was installed but could not be enabled.\n' >&2
