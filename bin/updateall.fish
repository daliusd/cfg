#!/usr/bin/env fish

set script_dir (dirname (status filename))

switch (uname)
    case Linux
        sudo apt-get update; or exit $status
        sudo apt-get upgrade -y; or exit $status
    case Darwin
        # Upstream artifacts are refreshed by install.sh below.
    case '*'
        echo "Unsupported operating system: "(uname) >&2
        exit 1
end

# Refresh upstream release artifacts, Rust, Volta, Node LTS, npm globals,
# fonts, WezTerm nightly, and desktop helpers. System tweaks remain opt-in.
"$script_dir/install.sh" --yes --desktop; or exit $status

if type -q gem
    gem install --user-install kamal
end

if type -q npx
    npx skills update -g -y
end

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

# Not sure if I want to update Lazy silently.
# nvim --headless "+Lazy! sync" +qa
