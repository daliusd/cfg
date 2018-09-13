Home folder configuration
=========================

Initial run requires following commands:

```console
# Clone this repo
git clone --bare git@bitbucket.org:daliusd/cfg.git .cfg

# Alias config properly
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Do initial config repository configuration and checkout
config config --local status.showUntrackedFiles no
config checkout
config submodule init
config submodule update --remote --recursive

# Run initialization.
./init.sh
```

Vim notes
---------

You will need to run ":set spell" to download spell files.
