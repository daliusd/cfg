function db
  git branch |
    grep --invert-match '\*' |
    cut -c 3- |
    fzf --multi --preview="git log {}" |
    xargs -I {} sh -c 'git branch -D {} && git push origin --delete {} 2>/dev/null || true'
end
