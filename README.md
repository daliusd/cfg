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
config submodules init
config submodule pull --remote
```
