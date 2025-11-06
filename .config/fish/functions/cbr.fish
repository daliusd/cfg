function cbr -d "Checkout remote branch (fetch first)"
  git fetch --all
  git branch -r |
    grep --invert-match '\->' |
    sed 's/^[[:space:]]*origin\///' |
    fzf --preview="git log origin/{} --color=always --oneline -n 20" |
    xargs git checkout
end
