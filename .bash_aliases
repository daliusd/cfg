alias e=nvim
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias cfg='git --git-dir=/Users/daliusd/.cfg/ --work-tree=/Users/daliusd'
    alias ll='ls -alG'
    alias ls='ls -G'
else
    alias cfg='git --git-dir=/home/dalius/.cfg/ --work-tree=/home/dalius'
fi

username='Dalius Dobravolskas'
private_email='dalius.dobravolskas@gmail.com'
work_email='daliusd@wix.com'

alias gitprivate='git config user.email "$private_email" && git config user.name "$username"'
alias gitwork='git config user.email "$work_email" && git config user.name "$username"'

alias gitprivateglobal='git config --global user.email "$private_email" && git config --global user.name "$username"'
alias gitworkglobal='git config --global user.email "$work_email" && git config --global user.name "$username"'
alias cdroot='cd $(git root)'

alias ~='cd ~'
alias ..='cd ..'

alias npmpublic='npm config set registry https://registry.npmjs.org/ && npm config get registry'
alias npmprivate='npm config set registry http://npm.dev.wixpress.com && npm config get registry'

alias fixenvrc='fd --hidden .nvmrc -x sh -c "echo ''use fnm'' > {//}/.envrc"'

alias ga='git add .'
alias gb='git branch'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias gps='git push'
alias gpl='git pull'
alias gl='git log --oneline'
