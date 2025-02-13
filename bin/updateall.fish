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

nvim --headless "+Lazy! sync" +qa
snc
