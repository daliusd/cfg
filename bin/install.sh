#!/bin/sh

# This file is not intended to be run. It is just instructions what must be done or installed.

sudo apt install git
git config --global include.path "~/.gitconfig_private"

# Ubuntu

sudo apt install gnome-tweaks # Gnome tweaks. E.g. caps lock to escape

sudo apt install build-essential
sudo apt install curl
sudo apt install fzf
curl -sS https://starship.rs/install.sh | sh

sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt update
sudo apt-get install neovim
sudo update-alternatives --config editor

curl https://sh.rustup.rs -sSf | sh
cargo install lsd
chsh -s $(which fish) # might need relogin after this

curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
sudo apt update
sudo apt install wezterm
# Override Super+S, Super+L, Super+H in Ubuntu

sudo update-alternatives --config x-terminal-emulator

# Password store gist here: https://gist.github.com/abtrout/d64fb11ad6f9f49fa325
# Multi user password store: https://medium.com/@davidpiegza/using-pass-in-a-team-1aa7adf36592
#
# import gpg keys
#
sudo apt install pass
git clone password-store-location ~/.password-store

# Tools
sudo apt install ripgrep
sudo apt install fd-find
ln -s $(which fdfind) ~/bin/fd
sudo apt install bat
sudo apt install git-delta

# Fonts
mkdir ~/.fonts
cd .fonts/
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/VictorMono.zip
unzip VictorMono.zip
fc-cache -fv
# ??? gsettings set org.gnome.desktop.interface monospace-font-name 'Victor Mono'

# Node
#
#
curl https://get.volta.sh | bash
volta install node

./nodeinstall.sh

# In case volta is not used.
# mkdir ~/.npm-global
# npm config set prefix '~/.npm-global'

# ??? Node stuff
# echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

# Mac OSX
brew tap homebrew/cask-fonts
brew cask install victor-mono-nerd-font
brew install git-delta
brew install lua-language-server
brew install pinentry-mac
