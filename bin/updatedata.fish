#!/usr/bin/env fish

if type -q sync.sh
    sync.sh
else
    echo 'warning: sync.sh is not on PATH' >&2
end

if test -x ~/projects/sync/pull.sh
    ~/projects/sync/pull.sh
else
    echo 'warning: ~/projects/sync/pull.sh is unavailable' >&2
end
