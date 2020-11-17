#!/bin/bash

shopt -s expand_aliases
source ~/.bash_aliases

cfg pull
pass git pull
cd ~/projects/todolists
git pull
cd
