#!/bin/sh

sudo apt-get install software-properties-common

# Neovim
sudo add-apt-repository ppa:neovim-ppa/stable
sudo apt-get update
sudo apt-get install neovim

npm install -g typescript
npm install -g neovim
pip3 install --user pynvim

# ripgrep (https://github.com/BurntSushi/ripgrep)
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb
sudo dpkg -i ripgrep_0.10.0_amd64.deb

# fd (https://github.com/sharkdp/fd)
curl -LO https://github.com/sharkdp/fd/releases/download/v7.2.0/fd_7.2.0_amd64.deb
sudo dpkg -i fd_7.2.0_amd64.deb

# neovim-qt
sudo apt install neovim-qt

# rust
# curl https://sh.rustup.rs -sSf | sh
sudo apt install cargo

# neovimgtk
sudo apt install libatk1.0-dev libcairo2-dev libgdk-pixbuf2.0-dev libglib2.0-dev libgtk-3-dev libpango1.0-dev
git clone https://github.com/daa84/neovim-gtk ~/projects/neovim-gtk
cd ~/projects/neovim-gtk
sudo make install
cd ~

# FiraCode (https://github.com/tonsky/FiraCode)
gsettings set org.gnome.desktop.interface monospace-font-name 'Fira Code 13'
