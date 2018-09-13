#!/bin/bash

if grep -q .bash_private ~/.bashrc
then
    echo "bash_private already configured."
else
    echo ". ~/.bash_private" >> ~/.bashrc
    echo "bash_private now configured."
fi

git config --global include.path "~/.gitconfig_private"
