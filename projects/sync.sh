#!/bin/bash

shopt -s expand_aliases
source ~/.bash_aliases

cfg pull
cfg push

pass git pull
pass git push

cd ~/projects/todolists
git pull
git push
cd
