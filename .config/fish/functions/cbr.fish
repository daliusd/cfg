function cbr -d "Checkout remote branch (fetch first)"
  git fetch --all
  set current_branch (git branch --show-current)
  git branch -r |
    grep --invert-match '\->' |
    sed 's/^[[:space:]]*origin\///' |
    grep --invert-match "^$current_branch\$" |
    fzf --preview="git log origin/{} --color=always --oneline -n 20" |
    xargs git checkout
end
