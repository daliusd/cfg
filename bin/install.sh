#!/usr/bin/env bash
set -Eeuo pipefail

# Homebrew manages CLI tools on Ubuntu and Apple Silicon macOS. Intel Macs
# retain the standalone installer for compatibility with older macOS releases.
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ $(uname -s) == Darwin && $(uname -m) == x86_64 ]]; then
  exec bash "$SCRIPT_DIR/install-mac-x64.sh" "$@"
fi

YES=false
DESKTOP=false
SYSTEM_TWEAKS=false
DRY_RUN=false
usage() {
  cat <<'EOF'
Usage: install.sh [options]

  -y, --yes           Do not prompt
      --desktop       Install desktop applications and GNOME helpers
      --system-tweaks  Set the login shell/editor and Linux inotify limits
      --dry-run       Print the plan without changing anything
  -h, --help          Show this help

Uses Homebrew on Ubuntu and Apple Silicon Macs; Intel Macs use install-mac-x64.sh.
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
log() { printf '\n==> %s\n' "$*"; }
die() { printf 'error: %s\n' "$*" >&2; exit 1; }
sudo_run() { if [[ $EUID -eq 0 ]]; then "$@"; else sudo "$@"; fi; }

case "$(uname -s)" in
  Linux)
    OS=linux
    [[ -r /etc/os-release ]] || die 'Ubuntu is required.'
    # shellcheck disable=SC1091
    . /etc/os-release
    [[ ${ID:-} == ubuntu ]] || die 'Ubuntu is required.'
    ;;
  Darwin) OS=darwin ;;
  *) die "Unsupported operating system: $(uname -s)" ;;
esac
case "$(uname -m)" in
  x86_64|amd64) ARCH=x64 ;;
  arm64|aarch64) ARCH=arm64 ;;
  *) die "Unsupported architecture: $(uname -m)" ;;
esac

BIN_DIR="$HOME/.local/bin"
if $DRY_RUN; then
  cat <<EOF
Plan for ${OS}/${ARCH}:
  bootstrap Homebrew and OS prerequisites
  install/update CLI tools, Go, Ruby, uv, whisper.cpp and Volta with Homebrew
  install Docker Engine with apt on Ubuntu; Docker CLI, Compose, Buildx and Colima with Homebrew on macOS
  install/update Rust, Kamal, Node LTS, npm packages, Sentry and Claude Code
  install Nerd Fonts
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
[[ $EUID -ne 0 ]] || die 'Run as your normal user; Homebrew cannot run as root.'

log 'Installing operating-system prerequisites'
if [[ $OS == linux ]]; then
  sudo_run apt-get update
  sudo_run env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    build-essential procps ca-certificates curl git unzip fontconfig
  docker_packages=()
  if ! dpkg-query -W -f='${Status}' docker.io docker-ce 2>/dev/null | grep -q 'ok installed'; then
    docker_packages+=(docker.io)
  fi
  docker compose version >/dev/null 2>&1 || docker_packages+=(docker-compose-v2)
  docker buildx version >/dev/null 2>&1 || docker_packages+=(docker-buildx-plugin)
  if ((${#docker_packages[@]})); then
    sudo_run env DEBIAN_FRONTEND=noninteractive apt-get install -y "${docker_packages[@]}"
  fi
  if getent group docker >/dev/null && ! id -nG "$USER" | tr ' ' '\n' | grep -Fxq docker; then
    sudo_run usermod -aG docker "$USER"
    printf 'Log out and back in to use Docker without sudo.\n'
  fi
  if command -v systemctl >/dev/null; then sudo_run systemctl enable --now docker; fi
elif ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  die 'Finish installing Xcode Command Line Tools, then rerun this script.'
fi

log 'Setting up Homebrew'
# Homebrew refuses to write its trust store in a group/world-writable dir.
mkdir -p "$HOME/.homebrew"
chmod 700 "$HOME/.homebrew"
# Discover an existing installation even when its shellenv is not loaded.
if ! command -v brew >/dev/null; then
  for brew_path in /opt/homebrew/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    if [[ -x $brew_path ]]; then
      eval "$("$brew_path" shellenv)"
      break
    fi
  done
fi
if ! command -v brew >/dev/null; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [[ $OS == linux ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  else
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
fi
eval "$(brew shellenv)"
BREW_PREFIX="$(brew --prefix)"

log 'Configuring Homebrew for Fish'
fish_conf_dir="${XDG_CONFIG_HOME:-$HOME/.config}/fish/conf.d"
mkdir -p "$fish_conf_dir"
# Configure before package installation, which may fail. No Fish binary is
# needed yet. Escape backslashes and quotes for a Fish single-quoted path.
fish_brew_path="$BREW_PREFIX/bin/brew"
fish_brew_path="${fish_brew_path//\\/\\\\}"
fish_brew_path="${fish_brew_path//\'/\\\'}"
printf "# Managed by install.sh.\nif test -x '%s'\n    '%s' shellenv fish | source\nend\n" \
  "$fish_brew_path" "$fish_brew_path" > "$fish_conf_dir/dalius-homebrew.fish"

export HOMEBREW_NO_AUTO_UPDATE=1
brew update
formulae=(
  fish fzf starship ripgrep fd bat git-delta gh eza neovim lua-language-server
  buf stylua tree-sitter typos-lsp ffmpeg go ruby rustup uv whisper-cpp volta
  htop cmake gnupg pass pinentry
)
if [[ $OS == darwin ]]; then
  formulae+=(docker docker-compose docker-buildx lima colima pinentry-mac)
fi
brew install "${formulae[@]}"
brew upgrade "${formulae[@]}"

# Replace previous standalone launchers so ~/.local/bin cannot shadow brew.
# Linking these also preserves the PATH used by the existing Fish config.
mkdir -p "$BIN_DIR"
for tool in fish fzf starship rg fd bat delta gh eza nvim lua-language-server \
  buf stylua tree-sitter typos-lsp ffmpeg ffprobe go gofmt uv htop cmake ctest \
  cpack gpg pass pinentry volta whisper-cli whisper-server whisper-bench whisper-quantize; do
  if [[ -x $BREW_PREFIX/bin/$tool ]]; then
    ln -sfn "$BREW_PREFIX/bin/$tool" "$BIN_DIR/$tool"
  fi
done
export PATH="$BREW_PREFIX/opt/ruby/bin:$BREW_PREFIX/opt/rustup/bin:$BIN_DIR:$HOME/.cargo/bin:$HOME/.volta/bin:$PATH"
# Keep gems outside the versioned Homebrew cellar across Ruby upgrades.
export GEM_HOME="$HOME/.local/share/gems"
export PATH="$GEM_HOME/bin:$PATH"
ln -sfn "$BREW_PREFIX/opt/rustup/bin/rustup" "$BIN_DIR/rustup"
for tool in ruby gem bundle bundler irb rake; do
  [[ ! -x $BREW_PREFIX/opt/ruby/bin/$tool ]] || ln -sfn "$BREW_PREFIX/opt/ruby/bin/$tool" "$BIN_DIR/$tool"
done

if [[ $OS == darwin ]]; then
  mkdir -p "$HOME/.docker/cli-plugins"
  for plugin in compose buildx; do
    ln -sfn "$BREW_PREFIX/opt/docker-${plugin}/bin/docker-${plugin}" "$HOME/.docker/cli-plugins/docker-${plugin}"
  done
  for tool in docker docker-compose limactl colima; do
    ln -sfn "$BREW_PREFIX/bin/$tool" "$BIN_DIR/$tool"
  done
fi

git config --global include.path '~/.gitconfig_private'
log 'Installing Rust and Kamal'
rustup toolchain install stable --profile minimal
rustup default stable
gem install kamal --no-document
# Kamal must retain its gem location and brewed Ruby after this script exits.
kamal_launcher="$(mktemp "$BIN_DIR/.kamal.XXXXXX")"
printf '#!/usr/bin/env bash\nexport GEM_HOME=%q\nexport PATH=%q:"$PATH"\nexec %q "$@"\n' \
  "$GEM_HOME" "$BREW_PREFIX/opt/ruby/bin" "$GEM_HOME/bin/kamal" > "$kamal_launcher"
chmod 0755 "$kamal_launcher"
mv -f "$kamal_launcher" "$BIN_DIR/kamal"

log 'Installing Nerd Fonts'
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/dalius-install.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT
if [[ $OS == darwin ]]; then
  brew install --cask font-victor-mono-nerd-font font-symbols-only-nerd-font
  brew upgrade --cask font-victor-mono-nerd-font font-symbols-only-nerd-font
else
  font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
  for font in VictorMono NerdFontsSymbolsOnly; do
    curl -fL --retry 3 "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font}.zip" -o "$TMP_DIR/font.zip"
    unzip -q -o "$TMP_DIR/font.zip" -d "$font_dir"
  done
  fc-cache -f
fi

log 'Installing/updating Sentry CLI'
curl -fL --retry 3 "https://github.com/getsentry/cli/releases/latest/download/sentry-${OS}-${ARCH}" -o "$TMP_DIR/sentry"
install -m 0755 "$TMP_DIR/sentry" "$BIN_DIR/sentry"

log 'Installing Node LTS and global packages'
export VOLTA_HOME="$HOME/.volta"
unset _VOLTA_TOOL_RECURSION || true
volta install node@lts
if $YES; then "$SCRIPT_DIR/nodeinstall.sh" --yes; else "$SCRIPT_DIR/nodeinstall.sh"; fi
volta install node@lts
log 'Installing/updating Claude Code'
curl -fsSL --retry 3 https://claude.ai/install.sh | bash
log 'Installing agent-browser Chrome runtime and skill'
if [[ $OS == linux ]]; then agent-browser install --with-deps; else agent-browser install; fi
if [[ ! -f $HOME/.pi/agent/skills/agent-browser/SKILL.md ]]; then
  npx --yes skills add vercel-labs/agent-browser --global --agent pi --yes
fi

if $DESKTOP; then
  if [[ $OS == darwin ]]; then
    brew install --cask wezterm
    brew upgrade --cask wezterm
  else
    sudo_run env DEBIAN_FRONTEND=noninteractive apt-get install -y gnome-tweaks gnome-sushi libfuse2t64
    curl -fL --retry 3 https://github.com/wez/wezterm/releases/download/nightly/WezTerm-nightly-Ubuntu24.04.AppImage -o "$TMP_DIR/wezterm"
    install -m 0755 "$TMP_DIR/wezterm" "$BIN_DIR/wezterm"
  fi
fi
if $SYSTEM_TWEAKS; then
  fish_path="$BIN_DIR/fish"
  grep -Fxq "$fish_path" /etc/shells || printf '%s\n' "$fish_path" | sudo_run tee -a /etc/shells >/dev/null
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
printf 'Add %s/bin, %s/opt/ruby/bin, %s/bin, ~/.cargo/bin and ~/.volta/bin to PATH, then restart Fish.\n' "$BREW_PREFIX" "$BREW_PREFIX" "$GEM_HOME"
printf 'Homebrew is configured in %s/dalius-homebrew.fish; restart Fish to load it.\n' "$fish_conf_dir"
printf 'Homebrew launchers are also linked in %s.\n' "$BIN_DIR"
