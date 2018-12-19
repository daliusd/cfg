#!/bin/bash

if grep -q .bash_private ~/.bashrc
then
    echo "bash_private already configured."
else
    echo ". ~/.bash_private" >> ~/.bashrc
    echo "bash_private now configured."
fi

git config --global include.path "~/.gitconfig_private"

mkdir ~/.npm-global
npm config set prefix '~/.npm-global'

# https://github.com/mrowa44/emojify
sudo sh -c "curl https://raw.githubusercontent.com/mrowa44/emojify/master/emojify -o /usr/local/bin/emojify && chmod +x /usr/local/bin/emojify"
