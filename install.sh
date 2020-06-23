#!/bin/sh

sudo apt-get install software-properties-common

# Neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

npm install -g typescript
npm install -g neovim
npm i -g typescript-language-server
npm i -g svelte-language-server
npm i -g vscode-html-languageserver-bin
npm i -g vscode-json-languageserver-bin
npm i -g vscode-css-languageserver-bin

# neovim python modules
cd projects
virtualenv --python=python2.7 py2nvim
cd py2nvim
source bin/active
pip install pynvim
pip install -U msgpack

virtualenv py3nvim
cd py3nvim
source bin/active
pip install pynvim

sudo update-alternatives --config editor

# Ctags
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure
make
sudo make install

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

# Fonts
# FiraCode (https://github.com/tonsky/FiraCode)
# http://typeof.net/Iosevka/
curl -LO https://github.com/be5invis/Iosevka/releases/download/v2.0.2/01-iosevka-2.0.2.zip
curl -LO https://github.com/be5invis/Iosevka/releases/download/v2.0.2/02-iosevka-term-2.0.2.zip

gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 12'

# Kitty. I will not use this as for now. Maybe in the future.
curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

# Default: /usr/bin/gnome-terminal
gsettings set org.gnome.desktop.default-applications.terminal exec ~/.local/kitty.app/bin/kitty

# Node stuff
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
npm completion >> ~/.bashrc

npm install -g import-js

# Gnome tweaks. E.g. use it for Alt+Shift to switch layouts.
sudo apt install gnome-tweaks

# Conky
# Select Startup Applications. Click Add. In the resulting dialog box give the name as "Conky" and the command as conky. Click add and close.
sudo apt-get install conky-all

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# pass
sudo apt install pass
# passff installation - https://github.com/passff/passff#installation

# Max OS X
brew install pinentry-mac

# Italics in terminal and tmux (https://alexpearce.me/2014/05/italics-in-iterm2-vim-tmux/)
tic xterm-256color-italic.terminfo
tic -x tmux-256color.terminfo
