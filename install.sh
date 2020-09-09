#!/bin/sh

sudo apt-get install software-properties-common

# Neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

./nodeinstall.sh

# neovim python modules
cd projects/tools
python3.6 -m venv py3nvim
cd py3nvim
source bin/active
pip install pynvim

sudo update-alternatives --config editor

# Ctags
# git clone https://github.com/universal-ctags/ctags.git
# cd ctags
# ./autogen.sh
# ./configure
# make
# sudo make install

# ripgrep (https://github.com/BurntSushi/ripgrep)
curl -LO https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep_0.10.0_amd64.deb
sudo dpkg -i ripgrep_0.10.0_amd64.deb

# fd (https://github.com/sharkdp/fd)
curl -LO https://github.com/sharkdp/fd/releases/download/v7.2.0/fd_7.2.0_amd64.deb
sudo dpkg -i fd_7.2.0_amd64.deb

# Fonts
# http://typeof.net/Iosevka/
curl -LO https://github.com/be5invis/Iosevka/releases/download/v2.0.2/01-iosevka-2.0.2.zip
curl -LO https://github.com/be5invis/Iosevka/releases/download/v2.0.2/02-iosevka-term-2.0.2.zip

gsettings set org.gnome.desktop.interface monospace-font-name 'Iosevka 12'

# Node stuff
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
npm completion >> ~/.bashrc

# Gnome tweaks. E.g. use it for Alt+Shift to switch layouts.
sudo apt install gnome-tweaks

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
