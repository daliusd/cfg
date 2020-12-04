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
source bin/activate
pip install pynvim

sudo update-alternatives --config editor

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

" Hide terminal title bar in Ubuntu
sudo apt install gnome-shell-extension-pixelsaver

# Mac OSX
brew tap homebrew/cask-fonts
brew cask install font-iosevka-nerd-font
brew install git-delta

" Debian https://github.com/dandavison/delta/releases/download/0.4.4/git-delta_0.4.4_amd64.deb

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
