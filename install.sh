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
