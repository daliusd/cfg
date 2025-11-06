function msq -d "Squash merge a branch selected with fzf"
  git branch --all |
    grep --invert-match '\->' |
    grep --invert-match '\*' |
    sed 's/^[[:space:]]*//' |
    sed 's/^remotes\/origin\///' |
    sort --unique |
    fzf --preview="git log HEAD..{} --color=always --oneline -n 20 2>/dev/null || git log {} --color=always --oneline -n 20" |
    xargs -I {} git merge --squash {}
end
