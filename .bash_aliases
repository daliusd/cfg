alias config='/usr/bin/git --git-dir=/home/dalius/.cfg/ --work-tree=/home/dalius'

alias configup='config pull && config submodule init && config submodule update --remote --recursive'

source ~/django-completion.bash
