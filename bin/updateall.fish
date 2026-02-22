#!/usr/bin/env fish

switch (uname)
    case Linux
      sudo apt update
      sudo apt upgrade -y
      brew update
      brew upgrade
    case Darwin
      brew update
      brew upgrade
    case '*'
        echo Open updateall.fish and review it!
end

npm update -g --verbose

snc

~/projects/sync/pull.sh
# Not sure if I want to update Lazy silently
# nvim --headless "+Lazy! sync" +qa
