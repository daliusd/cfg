#!/usr/bin/env fish

switch (uname)
    case Linux
      sudo apt update
      sudo apt upgrade -y
      brew update
      brew upgrade -y
    case Darwin
      brew update
      brew upgrade -y
    case '*'
        echo Open updateall.fish and review it!
end

npm update -g
switch (uname)
    case Linux
      sudo gem update kamal
    case Darwin
      gem update kamal
    case '*'
        echo Open updateall.fish and review it!
end

npx skills update -g -y

snc

~/projects/sync/pull.sh
# Not sure if I want to update Lazy silently
# nvim --headless "+Lazy! sync" +qa
