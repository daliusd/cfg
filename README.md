# Home folder configuration

Initial run requires following commands:

```console
# Clone this repo
git clone --bare git@github.com:daliusd/cfg.git .cfg

# Alias cfg properly
alias cfg='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

# Do initial config repository configuration and checkout
cfg config --local status.showUntrackedFiles no
cfg checkout

cfg push --set-upstream origin master
```

Follow install.sh for software installation instructions.
