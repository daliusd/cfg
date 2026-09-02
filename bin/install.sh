#!/usr/bin/env bash
set -Eeuo pipefail

# Bootstrap and update Dalius' command-line environment on Ubuntu and macOS.
# Upstream release artifacts are preferred; apt is used for bootstrap, costly
# dependency chains, and OS integration. Safe to rerun.

YES=false
DESKTOP=false
SYSTEM_TWEAKS=false
DRY_RUN=false
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PREFIX="${HOME}/.local"
BIN_DIR="${PREFIX}/bin"
OPT_DIR="${PREFIX}/opt"
SRC_DIR="${PREFIX}/src"
CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/dalius-install"
STATE_DIR="${PREFIX}/share/dalius-install/releases"

usage() {
  cat <<'EOF'
Usage: install.sh [options]

  -y, --yes          Do not prompt
      --desktop      Install desktop applications and GNOME helpers
      --system-tweaks Set the login shell/editor and Linux inotify limits
      --dry-run      Print the plan without changing anything
  -h, --help         Show this help
EOF
}

while (($#)); do
  case "$1" in
    -y|--yes) YES=true ;;
    --desktop) DESKTOP=true ;;
    --system-tweaks) SYSTEM_TWEAKS=true ;;
    --dry-run) DRY_RUN=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

if [[ $(uname -s) == Linux ]]; then
  OS=linux
  [[ -r /etc/os-release ]] || die 'Linux is supported only on Ubuntu.'
  # shellcheck disable=SC1091
  . /etc/os-release
  [[ ${ID:-} == ubuntu ]] || die "Unsupported Linux distribution: ${ID:-unknown} (Ubuntu required)."
elif [[ $(uname -s) == Darwin ]]; then
  OS=darwin
else
  die "Unsupported operating system: $(uname -s)"
fi

case "$(uname -m)" in
  x86_64|amd64) ARCH=x86_64 ;;
  arm64|aarch64) ARCH=aarch64 ;;
  *) die "Unsupported architecture: $(uname -m)" ;;
esac

if $DRY_RUN; then
  cat <<EOF
Plan for ${OS}/${ARCH}:
  bootstrap OS build dependencies
  install/update CLI tools and fonts in ${PREFIX}
  install Docker Engine from Ubuntu, or Docker CLI + Compose + Lima + Colima on macOS
  install/update Go, Rust, Ruby + Kamal, Volta, Node LTS, and global npm packages
  desktop applications: ${DESKTOP}
  login shell/editor/inotify system tweaks: ${SYSTEM_TWEAKS}
EOF
  exit 0
fi

if ! $YES; then
  printf 'Install/update the environment for %s/%s? [y/N] ' "$OS" "$ARCH"
  read -r answer
  [[ $answer == y || $answer == Y ]] || exit 0
fi

mkdir -p "$BIN_DIR" "$OPT_DIR" "$SRC_DIR" "$CACHE_DIR" "$STATE_DIR"
export PATH="$BIN_DIR:$HOME/.cargo/bin:$HOME/.volta/bin:$PATH"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dalius-install.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT

sudo_run() {
  if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

github_release_tag() {
  local repo=$1 release=${2:-latest} effective
  if [[ $release != latest ]]; then
    printf '%s\n' "$release"
    return
  fi

  # Resolve the ordinary releases/latest redirect instead of GitHub's API.
  # The unauthenticated API allows only 60 requests/hour, which made routine
  # updateall runs fail with a misleading "No asset" error.
  effective="$(curl -fsSLI --retry 3 -o /dev/null -w '%{url_effective}' \
    "https://github.com/${repo}/releases/latest")"
  [[ $effective == */tag/* ]] \
    || die "Could not resolve the latest release tag for ${repo}."
  printf '%s\n' "${effective##*/}"
}

github_release_marker() {
  local repo=$1 release=${2:-latest} endpoint tag assets
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if [[ $release == latest ]]; then
      endpoint="repos/${repo}/releases/latest"
    else
      endpoint="repos/${repo}/releases/tags/${release}"
    fi
    gh api "$endpoint" --jq '.updated_at'
    return
  fi

  tag="$(github_release_tag "$repo" "$release")"
  assets="$(curl -fsSL --retry 3 \
    "https://github.com/${repo}/releases/expanded_assets/${tag}")"
  if command -v sha256sum >/dev/null; then
    printf '%s' "$assets" | sha256sum | awk '{print $1}'
  else
    printf '%s' "$assets" | shasum -a 256 | awk '{print $1}'
  fi
}

github_asset_url() {
  local repo=$1 pattern=$2 release=${3:-latest} tag assets path endpoint url

  # Prefer gh's authenticated API (5,000 requests/hour). A clean machine does
  # not have gh or credentials yet, so the release-page path remains required.
  if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
    if [[ $release == latest ]]; then
      endpoint="repos/${repo}/releases/latest"
    else
      endpoint="repos/${repo}/releases/tags/${release}"
    fi
    url="$(gh api "$endpoint" --jq '.assets[].browser_download_url' 2>/dev/null \
      | grep -E "$pattern" | head -n 1 || true)"
    if [[ -n $url ]]; then
      printf '%s\n' "$url"
      return
    fi
    warn "Authenticated gh could not resolve ${repo}; using the release page."
  fi

  tag="$(github_release_tag "$repo" "$release")"
  assets="$(curl -fsSL --retry 3 \
    "https://github.com/${repo}/releases/expanded_assets/${tag}")" \
    || die "Could not load release assets for ${repo} (${tag})."
  path="$(printf '%s' "$assets" \
    | grep -Eo 'href="[^"]+"' \
    | cut -d'"' -f2 \
    | grep -E "$pattern" \
    | head -n 1 || true)"
  [[ -n $path ]] \
    || die "No asset matching '${pattern}' in ${repo} (${tag})."
  case "$path" in
    http://*|https://*) printf '%s\n' "$path" ;;
    *) printf 'https://github.com%s\n' "$path" ;;
  esac
}

download() {
  local url=$1 output=$2 expected actual
  curl -fL --retry 3 --retry-all-errors --progress-bar "$url" -o "$output"
  # Verify the common upstream sidecar format when one is published.
  expected="$(curl -fsSL --retry 2 "${url}.sha256" 2>/dev/null \
    | grep -Eo '[0-9a-fA-F]{64}' | head -n 1 || true)"
  if [[ -n $expected ]]; then
    if command -v sha256sum >/dev/null; then
      actual="$(sha256sum "$output" | awk '{print $1}')"
    else
      actual="$(shasum -a 256 "$output" | awk '{print $1}')"
    fi
    actual="$(printf '%s' "$actual" | tr '[:upper:]' '[:lower:]')"
    expected="$(printf '%s' "$expected" | tr '[:upper:]' '[:lower:]')"
    [[ $actual == "$expected" ]] || die "Checksum verification failed for $url"
  fi
}

extract() {
  local archive=$1 destination=$2
  mkdir -p "$destination"
  case "$archive" in
    *.tar.gz|*.tgz) tar -xzf "$archive" -C "$destination" ;;
    *.tar.xz) tar -xJf "$archive" -C "$destination" ;;
    *.zip) unzip -q -o "$archive" -d "$destination" ;;
    *) die "Unknown archive format: $archive" ;;
  esac
}

release_is_current() {
  local name=$1 release=$2 installed_path=$3 state_file="$STATE_DIR/$1"
  local release_version installed_version
  [[ -e $installed_path ]] || return 1

  # GitHub release URLs contain the exact stable tag. Check the executable's
  # actual version on every run, including installations made before manifests
  # existed or binaries changed outside this script.
  if [[ -x $installed_path && $release == */releases/download/* ]]; then
    release_version="${release#*/releases/download/}"
    release_version="${release_version%%/*}"
    release_version="${release_version#v}"
    installed_version="$("$installed_path" --version </dev/null 2>&1 \
      | grep -Eo '[0-9]+(\.[0-9]+){1,3}([-+][0-9A-Za-z.-]+)?' \
      | head -n 1 || true)"
    if [[ -n $installed_version ]]; then
      if [[ $installed_version == "$release_version" ]]; then
        record_release "$name" "$release"
        return 0
      fi
      return 1
    fi
  fi

  # Non-executable assets such as fonts and applications use the recorded
  # release URL (or nightly release marker) plus the installed path.
  [[ -r $state_file && $(<"$state_file") == "$release" ]]
}

record_release() {
  local name=$1 release=$2
  printf '%s\n' "$release" > "$STATE_DIR/$name"
}

install_archive_binary() {
  local name=$1 repo=$2 pattern=$3 binary=${4:-$1} release=${5:-latest}
  local work="$TMP_DIR/$name" url archive found
  rm -rf "$work"; mkdir -p "$work"
  url="$(github_asset_url "$repo" "$pattern" "$release")"
  if release_is_current "$name" "$url" "$BIN_DIR/$binary"; then
    log "$name is already the latest release"
    return
  fi
  archive="$work/asset.${url##*.}"
  case "$url" in
    *.tar.gz) archive="$work/asset.tar.gz" ;;
    *.tar.xz) archive="$work/asset.tar.xz" ;;
    *.tgz) archive="$work/asset.tgz" ;;
    *.zip) archive="$work/asset.zip" ;;
  esac
  log "Installing $name from $url"
  download "$url" "$archive"
  extract "$archive" "$work/unpacked"
  found="$(find "$work/unpacked" -type f -name "$binary" -perm -u+x -print -quit)"
  [[ -n $found ]] || found="$(find "$work/unpacked" -type f -name "$binary" -print -quit)"
  [[ -n $found ]] || die "Could not find $binary in the $name archive."
  install -m 0755 "$found" "$BIN_DIR/$binary"
  record_release "$name" "$url"
}

install_direct_binary() {
  local name=$1 repo=$2 pattern=$3 binary=${4:-$1}
  local url="$TMP_DIR/${name}.url" file="$TMP_DIR/${name}.download"
  github_asset_url "$repo" "$pattern" > "$url"
  if release_is_current "$name" "$(<"$url")" "$BIN_DIR/$binary"; then
    log "$name is already the latest release"
    return
  fi
  log "Installing $name from $(<"$url")"
  download "$(<"$url")" "$file"
  install -m 0755 "$file" "$BIN_DIR/$binary"
  record_release "$name" "$(<"$url")"
}

log 'Installing operating-system prerequisites'
if [[ $OS == linux ]]; then
  apt_packages=(
    build-essential ca-certificates curl git gnupg pass pinentry-curses
    unzip xz-utils fontconfig autoconf bison libssl-dev libyaml-dev
    libreadline-dev zlib1g-dev libffi-dev libgdbm-dev libncurses-dev
  )
  docker_engine_installed=false
  for package in docker.io docker-ce; do
    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'ok installed'; then
      docker_engine_installed=true
      break
    fi
  done
  $docker_engine_installed || apt_packages+=(docker.io)
  docker compose version >/dev/null 2>&1 || apt_packages+=(docker-compose-v2)

  missing_packages=()
  for package in "${apt_packages[@]}"; do
    dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -q 'ok installed' \
      || missing_packages+=("$package")
  done
  if ((${#missing_packages[@]})); then
    sudo_run apt-get update
    sudo_run env DEBIAN_FRONTEND=noninteractive apt-get install -y "${missing_packages[@]}"
  else
    log 'Ubuntu prerequisites are already installed'
  fi

  if getent group docker >/dev/null 2>&1; then
    if ! id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
      sudo_run usermod -aG docker "$USER"
      warn 'Added your account to the docker group; log out and back in before using Docker without sudo.'
    fi
    if command -v systemctl >/dev/null 2>&1 \
      && ! systemctl is-active --quiet docker; then
      sudo_run systemctl enable --now docker
    fi
  fi
else
  if ! xcode-select -p >/dev/null 2>&1; then
    xcode-select --install
    die 'Finish installing Xcode Command Line Tools, then rerun this script.'
  fi
fi

git config --global include.path '~/.gitconfig_private'

log 'Installing Fish'
if [[ $OS == linux ]]; then
  fish_url="$(github_asset_url fish-shell/fish-shell 'fish-[0-9.]+-linux-'"${ARCH}"'\.tar\.xz$')"
else
  fish_url="$(github_asset_url fish-shell/fish-shell 'fish-[0-9.]+\.app\.zip$')"
fi
if release_is_current fish "$fish_url" "$BIN_DIR/fish"; then
  log 'Fish is already the latest release'
elif [[ $OS == linux ]]; then
  download "$fish_url" "$TMP_DIR/fish.tar.xz"
  tar -xJf "$TMP_DIR/fish.tar.xz" -C "$TMP_DIR"
  install -m 0755 "$TMP_DIR/fish" "$BIN_DIR/fish"
  record_release fish "$fish_url"
else
  download "$fish_url" "$TMP_DIR/fish.app.zip"
  extract "$TMP_DIR/fish.app.zip" "$TMP_DIR/fish-app"
  fish_base="$(find "$TMP_DIR/fish-app" -type d -path '*/Resources/base/usr/local' -print -quit)"
  [[ -n $fish_base ]] || die 'Could not locate Fish files in the macOS app archive.'
  cp -R "$fish_base/"* "$PREFIX/"
  record_release fish "$fish_url"
fi

if [[ $OS == linux ]]; then
  PLATFORM=linux
  FZF_ARCH=$([[ $ARCH == x86_64 ]] && echo amd64 || echo arm64)
  RUST_TARGET="${ARCH}-unknown-linux-gnu"
  NVIM_ASSET="nvim-linux-${ARCH}\.tar\.gz$"
  LUA_ASSET="lua-language-server-.*-linux-$([[ $ARCH == x86_64 ]] && echo x64 || echo arm64)\.tar\.gz$"
else
  PLATFORM=darwin
  FZF_ARCH=$([[ $ARCH == x86_64 ]] && echo amd64 || echo arm64)
  RUST_TARGET="${ARCH}-apple-darwin"
  NVIM_ASSET="nvim-macos-$([[ $ARCH == x86_64 ]] && echo x86_64 || echo arm64)\.tar\.gz$"
  LUA_ASSET="lua-language-server-.*-darwin-$([[ $ARCH == x86_64 ]] && echo x64 || echo arm64)\.tar\.gz$"
fi

install_archive_binary fzf junegunn/fzf "fzf-.*-${PLATFORM}_${FZF_ARCH}\\.tar\\.gz$"
install_archive_binary starship starship/starship "starship-${RUST_TARGET}\\.tar\\.gz$"
RIPGREP_TARGET=$RUST_TARGET
[[ $OS == linux && $ARCH == x86_64 ]] && RIPGREP_TARGET=x86_64-unknown-linux-musl
install_archive_binary rg BurntSushi/ripgrep "ripgrep-.*-${RIPGREP_TARGET}\\.tar\\.gz$" rg
install_archive_binary fd sharkdp/fd "fd-v.*-${RUST_TARGET}\\.tar\\.gz$" fd
install_archive_binary bat sharkdp/bat "bat-v.*-${RUST_TARGET}\\.tar\\.gz$" bat
if [[ $OS == darwin && $ARCH == x86_64 ]]; then
  : # dandavison/delta stopped publishing an x86_64-apple-darwin asset; installed via cargo below.
else
  install_archive_binary delta dandavison/delta "delta-.*-${RUST_TARGET}\\.tar\\.gz$" delta
fi

GH_ARCH=$([[ $ARCH == x86_64 ]] && echo amd64 || echo arm64)
if [[ $OS == linux ]]; then
  GH_ASSET="gh_.*_linux_${GH_ARCH}\\.tar\\.gz$"
else
  GH_ASSET="gh_.*_macOS_${GH_ARCH}\\.zip$"
fi
install_archive_binary gh cli/cli "$GH_ASSET" gh

if [[ $OS == linux ]]; then
  install_archive_binary eza eza-community/eza "eza_${RUST_TARGET}\\.tar\\.gz$" eza
else
  log 'Installing Docker CLI, Compose, Lima, and Colima'
  MAC_ARCH=$([[ $ARCH == x86_64 ]] && echo x86_64 || echo aarch64)

  docker_listing="$(curl -fsSL --retry 3 \
    "https://download.docker.com/mac/static/stable/${MAC_ARCH}/")"
  docker_asset="$(printf '%s' "$docker_listing" \
    | grep -Eo 'docker-[0-9]+(\.[0-9]+)+\.tgz' | tail -n 1)"
  [[ -n $docker_asset ]] || die 'Could not resolve the latest Docker CLI release.'
  docker_version="${docker_asset#docker-}"
  docker_version="${docker_version%.tgz}"
  docker_url="https://download.docker.com/mac/static/stable/${MAC_ARCH}/${docker_asset}"
  installed_docker_version="$(docker --version 2>/dev/null \
    | grep -Eo '[0-9]+(\.[0-9]+){1,3}' | head -n 1 || true)"
  if [[ $installed_docker_version == "$docker_version" ]]; then
    record_release docker "$docker_url"
    log "Docker CLI ${docker_version} is already the latest release"
  else
    download "$docker_url" "$TMP_DIR/docker.tgz"
    extract "$TMP_DIR/docker.tgz" "$TMP_DIR/docker"
    install -m 0755 "$TMP_DIR/docker/docker/docker" "$BIN_DIR/docker"
    record_release docker "$docker_url"
  fi

  compose_url="$(github_asset_url docker/compose "/docker-compose-darwin-${MAC_ARCH}$")"
  compose_dir="$HOME/.docker/cli-plugins"
  mkdir -p "$compose_dir"
  if release_is_current docker-compose "$compose_url" "$compose_dir/docker-compose"; then
    log 'Docker Compose is already the latest release'
  else
    download "$compose_url" "$TMP_DIR/docker-compose"
    install -m 0755 "$TMP_DIR/docker-compose" "$compose_dir/docker-compose"
    record_release docker-compose "$compose_url"
  fi
  ln -sfn "$compose_dir/docker-compose" "$BIN_DIR/docker-compose"

  lima_url="$(github_asset_url lima-vm/lima "/lima-[0-9.]+-Darwin-${MAC_ARCH}\\.tar\\.gz$")"
  if release_is_current lima "$lima_url" "$BIN_DIR/limactl"; then
    log 'Lima is already the latest release'
  else
    download "$lima_url" "$TMP_DIR/lima.tar.gz"
    extract "$TMP_DIR/lima.tar.gz" "$TMP_DIR/lima"
    cp -R "$TMP_DIR/lima/"* "$PREFIX/"
    record_release lima "$lima_url"
  fi

  install_direct_binary colima abiosoft/colima "/colima-Darwin-$([[ $ARCH == x86_64 ]] && echo x86_64 || echo arm64)$" colima
fi

log 'Installing Neovim'
nvim_url="$(github_asset_url neovim/neovim "$NVIM_ASSET")"
if release_is_current nvim "$nvim_url" "$BIN_DIR/nvim"; then
  log 'Neovim is already the latest release'
else
  download "$nvim_url" "$TMP_DIR/nvim.tar.gz"
  rm -rf "$OPT_DIR/nvim" "$TMP_DIR/nvim-unpacked"
  extract "$TMP_DIR/nvim.tar.gz" "$TMP_DIR/nvim-unpacked"
  nvim_root="$(find "$TMP_DIR/nvim-unpacked" -mindepth 1 -maxdepth 1 -type d -print -quit)"
  [[ -n $nvim_root ]] || die 'Could not find the Neovim archive root.'
  mv "$nvim_root" "$OPT_DIR/nvim"
  ln -sfn "$OPT_DIR/nvim/bin/nvim" "$BIN_DIR/nvim"
  record_release nvim "$nvim_url"
fi

log 'Installing Lua language server'
lua_url="$(github_asset_url LuaLS/lua-language-server "$LUA_ASSET")"
if release_is_current lua-language-server "$lua_url" "$BIN_DIR/lua-language-server"; then
  log 'Lua language server is already the latest release'
else
  download "$lua_url" "$TMP_DIR/lua-language-server.tar.gz"
  rm -rf "$OPT_DIR/lua-language-server"
  mkdir -p "$OPT_DIR/lua-language-server"
  extract "$TMP_DIR/lua-language-server.tar.gz" "$OPT_DIR/lua-language-server"
  ln -sfn "$OPT_DIR/lua-language-server/bin/lua-language-server" "$BIN_DIR/lua-language-server"
  record_release lua-language-server "$lua_url"
fi

BUF_OS=$([[ $OS == linux ]] && echo Linux || echo Darwin)
BUF_ARCH=$([[ $ARCH == x86_64 ]] && echo x86_64 || echo arm64)
install_direct_binary buf bufbuild/buf "/buf-${BUF_OS}-${BUF_ARCH}$" buf

STYLUA_OS=$([[ $OS == linux ]] && echo linux || echo macos)
STYLUA_ARCH=$([[ $ARCH == x86_64 ]] && echo x86_64 || echo aarch64)
install_archive_binary stylua JohnnyMorganz/StyLua "stylua-${STYLUA_OS}-${STYLUA_ARCH}\\.zip$" stylua

TREE_OS=$([[ $OS == linux ]] && echo linux || echo macos)
TREE_ARCH=$([[ $ARCH == x86_64 ]] && echo x64 || echo arm64)
install_archive_binary tree-sitter tree-sitter/tree-sitter "tree-sitter-cli-${TREE_OS}-${TREE_ARCH}\\.zip$" tree-sitter

install_archive_binary typos-lsp tekumara/typos-lsp "typos-lsp-v.*-${RUST_TARGET}\\.tar\\.gz$" typos-lsp

if [[ $OS == linux && $ARCH == x86_64 ]]; then RTK_TARGET=x86_64-unknown-linux-musl; else RTK_TARGET=$RUST_TARGET; fi
install_archive_binary rtk rtk-ai/rtk "rtk-${RTK_TARGET}\\.tar\\.gz$" rtk

SENTRY_OS=$([[ $OS == linux ]] && echo Linux || echo Darwin)
SENTRY_ARCH=$([[ $ARCH == x86_64 ]] && echo x86_64 || echo arm64)
install_direct_binary sentry-cli getsentry/sentry-cli "/sentry-cli-${SENTRY_OS}-${SENTRY_ARCH}$" sentry-cli

log 'Installing Go'
go_metadata="$(curl -fsSL --retry 3 'https://go.dev/dl/?mode=json')"
go_release="$(printf '%s' "$go_metadata" \
  | grep -Eo '"version"[[:space:]]*:[[:space:]]*"go[0-9.]+"' \
  | head -n 1 | grep -Eo 'go[0-9.]+' || true)"
[[ -n $go_release ]] || die 'Could not resolve the latest stable Go release.'
go_version="${go_release#go}"
go_os=$([[ $OS == linux ]] && echo linux || echo darwin)
go_arch=$([[ $ARCH == x86_64 ]] && echo amd64 || echo arm64)
go_url="https://go.dev/dl/${go_release}.${go_os}-${go_arch}.tar.gz"
installed_go_version="$("$OPT_DIR/go/bin/go" version 2>/dev/null \
  | grep -Eo 'go[0-9.]+' | head -n 1 || true)"
if [[ $installed_go_version == "$go_release" ]]; then
  record_release go "$go_url"
  log "Go ${go_version} is already the latest stable release"
else
  download "$go_url" "$TMP_DIR/go.tar.gz"
  rm -rf "$OPT_DIR/go" "$TMP_DIR/go-unpacked"
  mkdir -p "$TMP_DIR/go-unpacked"
  extract "$TMP_DIR/go.tar.gz" "$TMP_DIR/go-unpacked"
  mv "$TMP_DIR/go-unpacked/go" "$OPT_DIR/go"
  record_release go "$go_url"
fi
ln -sfn "$OPT_DIR/go/bin/go" "$BIN_DIR/go"
ln -sfn "$OPT_DIR/go/bin/gofmt" "$BIN_DIR/gofmt"

log 'Installing Rust'
if ! command -v rustup >/dev/null 2>&1; then
  curl --proto '=https' --tlsv1.2 -fsSL https://sh.rustup.rs \
    | sh -s -- -y --no-modify-path --profile minimal --default-toolchain stable
fi
rustup update stable
rustup default stable
if [[ $OS == darwin ]]; then
  # eza does not currently publish macOS release artifacts.
  cargo install --locked eza
fi
if [[ $OS == darwin && $ARCH == x86_64 ]]; then
  # dandavison/delta stopped publishing an x86_64-apple-darwin asset.
  cargo install --locked git-delta
fi

log 'Installing uv'
if command -v uv >/dev/null 2>&1; then
  uv self update
else
  curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
fi

if [[ $OS == darwin ]]; then
  # macOS ships no yaml.h, and there is no Homebrew here, so ruby-build's
  # psych extension cannot find libyaml. Vendor a static build ourselves.
  log 'Installing libyaml'
  libyaml_version=0.2.5
  libyaml_dir="$OPT_DIR/libyaml-${libyaml_version}"
  if [[ -f $libyaml_dir/lib/libyaml.a || -f $libyaml_dir/lib/libyaml.dylib ]]; then
    log "libyaml ${libyaml_version} is already installed"
  else
    download "https://pyyaml.org/download/libyaml/yaml-${libyaml_version}.tar.gz" \
      "$TMP_DIR/libyaml.tar.gz"
    rm -rf "$TMP_DIR/libyaml-src"
    extract "$TMP_DIR/libyaml.tar.gz" "$TMP_DIR/libyaml-src"
    (
      cd "$TMP_DIR/libyaml-src/yaml-${libyaml_version}"
      ./configure --prefix="$libyaml_dir" --disable-shared --with-pic
      make -j"$(sysctl -n hw.ncpu)"
      make install
    )
  fi
  ln -sfn "$libyaml_dir" "$OPT_DIR/libyaml"
  export RUBY_CONFIGURE_OPTS="${RUBY_CONFIGURE_OPTS:-} --with-libyaml-dir=$OPT_DIR/libyaml"
fi

log 'Installing Ruby from source'
ruby_build_dir="$SRC_DIR/ruby-build"
if [[ -d $ruby_build_dir/.git ]]; then
  git -C "$ruby_build_dir" pull --ff-only
else
  rm -rf "$ruby_build_dir"
  git clone --depth 1 https://github.com/rbenv/ruby-build.git "$ruby_build_dir"
fi
ruby_latest="$("$ruby_build_dir/bin/ruby-build" --definitions \
  | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | tail -n 1)"
[[ -n $ruby_latest ]] || die 'Could not resolve the latest stable Ruby release.'
ruby_version_dir="$OPT_DIR/ruby-${ruby_latest}"
installed_ruby="$("$OPT_DIR/ruby/bin/ruby" --version 2>/dev/null \
  | grep -Eo '[0-9]+(\.[0-9]+){2}' | head -n 1 || true)"
if [[ $installed_ruby == "$ruby_latest" ]]; then
  log "Ruby ${ruby_latest} is already the latest stable release"
else
  rm -rf "$ruby_version_dir"
  if [[ $OS == darwin ]]; then
    RUBY_BUILD_VENDOR_OPENSSL=1 \
      "$ruby_build_dir/bin/ruby-build" "$ruby_latest" "$ruby_version_dir"
  else
    "$ruby_build_dir/bin/ruby-build" "$ruby_latest" "$ruby_version_dir"
  fi
  if [[ -d $OPT_DIR/ruby && ! -L $OPT_DIR/ruby ]]; then
    mv "$OPT_DIR/ruby" "$OPT_DIR/ruby-legacy-$(date +%s)"
  fi
  ln -sfn "$ruby_version_dir" "$OPT_DIR/ruby"
  record_release ruby "$ruby_latest"
fi
export PATH="$OPT_DIR/ruby/bin:$PATH"

log 'Installing Kamal gem'
kamal_latest="$(gem list --remote --exact kamal 2>/dev/null \
  | grep -Eo '[0-9]+(\.[0-9]+){1,3}' | head -n 1 || true)"
[[ -n $kamal_latest ]] || die 'Could not resolve the latest Kamal gem.'
kamal_installed="$(gem list --local --exact kamal 2>/dev/null \
  | grep -Eo '[0-9]+(\.[0-9]+){1,3}' | head -n 1 || true)"
if [[ $kamal_installed == "$kamal_latest" ]]; then
  log "Kamal ${kamal_latest} is already the latest release"
else
  gem install kamal --version "$kamal_latest" --no-document
  gem cleanup kamal >/dev/null 2>&1 || true
fi

log 'Installing Nerd Fonts'
font_dir="$HOME/.local/share/fonts"
[[ $OS == darwin ]] && font_dir="$HOME/Library/Fonts"
mkdir -p "$font_dir"
fonts_changed=false
for font_asset in VictorMono.zip NerdFontsSymbolsOnly.zip; do
  font_url="$(github_asset_url ryanoasis/nerd-fonts "/${font_asset}$")"
  font_name="font-${font_asset%.zip}"
  if release_is_current "$font_name" "$font_url" "$font_dir"; then
    log "${font_asset%.zip} is already the latest release"
    continue
  fi
  download "$font_url" "$TMP_DIR/$font_asset"
  unzip -q -o "$TMP_DIR/$font_asset" -d "$font_dir"
  record_release "$font_name" "$font_url"
  fonts_changed=true
done
[[ $OS == linux && $fonts_changed == true ]] && fc-cache -f

if [[ $OS == darwin ]]; then
  log 'Installing GPG Suite and pass'
  if ! command -v gpg >/dev/null || ! command -v pinentry-mac >/dev/null; then
    gpg_dmg_url="$(curl -fsSL https://gpgtools.org/ | grep -Eo 'https://releases\.gpgtools\.com/[^" ]+\.dmg' | head -n 1 || true)"
    if [[ -n $gpg_dmg_url ]]; then
      download "$gpg_dmg_url" "$TMP_DIR/gpg-suite.dmg"
      mount_point="$TMP_DIR/gpg-suite"
      mkdir -p "$mount_point"
      hdiutil attach -nobrowse -quiet -mountpoint "$mount_point" "$TMP_DIR/gpg-suite.dmg"
      gpg_pkg="$(find "$mount_point" -name '*.pkg' -print -quit)"
      [[ -n $gpg_pkg ]] || die 'No installer package found in GPG Suite image.'
      sudo_run installer -pkg "$gpg_pkg" -target /
      hdiutil detach -quiet "$mount_point"
    else
      warn 'Could not discover the current GPG Suite download.'
    fi
  fi
  if [[ -d $SRC_DIR/password-store/.git ]]; then
    git -C "$SRC_DIR/password-store" pull --ff-only
  else
    rm -rf "$SRC_DIR/password-store"
    git clone https://git.zx2c4.com/password-store "$SRC_DIR/password-store"
  fi
  make -C "$SRC_DIR/password-store" install PREFIX="$PREFIX"
fi

log 'Installing Volta and Node LTS'
volta_tag="$(github_release_tag volta-cli/volta)"
volta_latest="${volta_tag#v}"
volta_installed="$(volta --version 2>/dev/null || true)"
if [[ $volta_installed == "$volta_latest" ]]; then
  log "Volta ${volta_installed} is already the latest release"
else
  curl -fsSL https://get.volta.sh | bash -s -- --skip-setup
fi
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# A script launched by a Volta-managed tool (including this coding agent) can
# inherit this internal guard, which would otherwise pin child commands to the
# parent's Node version instead of the newly installed LTS.
unset _VOLTA_TOOL_RECURSION || true
volta install node@lts
if $YES; then
  "$SCRIPT_DIR/nodeinstall.sh" --yes
else
  "$SCRIPT_DIR/nodeinstall.sh"
fi
# Volta can restore a package's previously selected platform while replacing a
# global package; assert the requested default once more after all installs.
volta install node@lts

log 'Installing agent-browser Chrome runtime and skill'
if [[ $OS == linux ]]; then
  agent-browser install --with-deps
else
  agent-browser install
fi
if [[ -f $HOME/.pi/agent/skills/agent-browser/SKILL.md ]]; then
  log 'Pi agent-browser skill is already installed'
else
  npx --yes skills add vercel-labs/agent-browser --global --agent pi --yes
fi

if $DESKTOP; then
  log 'Installing desktop tools'
  if [[ $OS == linux ]]; then
    sudo_run env DEBIAN_FRONTEND=noninteractive apt-get install -y \
      gnome-tweaks gnome-sushi libfuse2t64
    wezterm_marker="$(github_release_marker wez/wezterm nightly)"
    if release_is_current wezterm "$wezterm_marker" "$BIN_DIR/wezterm"; then
      log 'WezTerm nightly is already current'
    else
      wezterm_url="$(github_asset_url wez/wezterm 'WezTerm-nightly-Ubuntu24\.04\.AppImage$' nightly)"
      download "$wezterm_url" "$BIN_DIR/wezterm"
      chmod 0755 "$BIN_DIR/wezterm"
      record_release wezterm "$wezterm_marker"
    fi
  else
    mkdir -p "$HOME/Applications"
    wezterm_marker="$(github_release_marker wez/wezterm nightly)"
    if release_is_current wezterm "$wezterm_marker" "$HOME/Applications/WezTerm.app"; then
      log 'WezTerm nightly is already current'
    else
      wezterm_url="$(github_asset_url wez/wezterm 'WezTerm-macos-nightly\.zip$' nightly)"
      download "$wezterm_url" "$TMP_DIR/wezterm.zip"
      extract "$TMP_DIR/wezterm.zip" "$TMP_DIR/wezterm"
      wezterm_app="$(find "$TMP_DIR/wezterm" -maxdepth 2 -name 'WezTerm.app' -print -quit)"
      [[ -n $wezterm_app ]] || die "WezTerm.app not found in downloaded archive"
      rm -rf "$HOME/Applications/WezTerm.app"
      cp -R "$wezterm_app" "$HOME/Applications/"
      record_release wezterm "$wezterm_marker"
    fi
  fi
fi

if $SYSTEM_TWEAKS; then
  log 'Applying system-level settings'
  fish_path="$BIN_DIR/fish"
  grep -Fxq "$fish_path" /etc/shells 2>/dev/null \
    || printf '%s\n' "$fish_path" | sudo_run tee -a /etc/shells >/dev/null
  sudo_run chsh -s "$fish_path" "$USER"
  if [[ $OS == linux ]]; then
    sudo_run update-alternatives --install /usr/bin/editor editor "$BIN_DIR/nvim" 100
    sudo_run tee /etc/sysctl.d/99-user-watches.conf >/dev/null <<'EOF'
fs.inotify.max_user_watches=1048576
fs.inotify.max_user_instances=1024
fs.inotify.max_queued_events=65536
EOF
    sudo_run sysctl --system
  fi
fi

log 'Installation complete'
printf 'Ensure %s and %s are at the front of PATH, then restart Fish.\n' "$BIN_DIR" "$HOME/.volta/bin"
if ! $DESKTOP; then printf 'Rerun with --desktop to install WezTerm and desktop helpers.\n'; fi
if ! $SYSTEM_TWEAKS; then printf 'Rerun with --system-tweaks to change the login shell and system settings.\n'; fi
