#!/bin/sh

sudo apt-get install software-properties-common

# Neovim
sudo add-apt-repository ppa:neovim-ppa/unstable
sudo apt-get update
sudo apt-get install neovim

./nodeinstall.sh

# neovim python modules
cd projects/soft
python3.6 -m venv py3nvim
cd py3nvim
source bin/activate
pip install pynvim

sudo update-alternatives --config editor

sudo apt install ripgrep
sudo apt install fd-find

# bat
# sudo dpkg -i bat....

# starship
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
brew install lua-language-server

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
